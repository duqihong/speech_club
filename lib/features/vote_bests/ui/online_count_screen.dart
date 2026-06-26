import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../l10n/app_localizations.dart';
import '../data/online_count/online_count_api.dart';
import '../data/online_count/online_count_models.dart';
import '../data/online_count/online_count_results_summary_builder.dart';
import '../data/online_count/online_count_storage.dart';
import '../data/vote_results_recipient.dart';
import '../data/vote_results_recipient_repository.dart';
import '../data/vote_results_share_helper.dart';
import '../data/whatsapp_phone_normalizer.dart';
import 'president_contact_dialog.dart';

enum OnlineCountUiState {
  noOnlineClub,
  clubReadyNoMeeting,
  meetingDraft,
  meetingOpen,
  meetingClosed,
}

OnlineCountUiState resolveOnlineCountUiState({
  required bool hasOnlineClub,
  OnlineRoundStatus? sessionStatus,
}) {
  if (!hasOnlineClub) {
    return OnlineCountUiState.noOnlineClub;
  }
  return switch (sessionStatus) {
    null => OnlineCountUiState.clubReadyNoMeeting,
    OnlineRoundStatus.draft => OnlineCountUiState.meetingDraft,
    OnlineRoundStatus.open => OnlineCountUiState.meetingOpen,
    OnlineRoundStatus.closed => OnlineCountUiState.meetingClosed,
  };
}

class OnlineCountScreen extends StatefulWidget {
  OnlineCountScreen({
    super.key,
    VoteResultsRecipientRepository? recipientRepository,
    OnlineCountResultsSummaryBuilder? summaryBuilder,
    LaunchPresidentWhatsApp? launchWhatsAppToPresident,
  })  : recipientRepository =
            recipientRepository ?? VoteResultsRecipientRepository(),
        summaryBuilder =
            summaryBuilder ?? const OnlineCountResultsSummaryBuilder(),
        launchWhatsAppToPresident =
            launchWhatsAppToPresident ?? launchWhatsAppToPresidentDefault;

  final VoteResultsRecipientRepository recipientRepository;
  final OnlineCountResultsSummaryBuilder summaryBuilder;
  final LaunchPresidentWhatsApp launchWhatsAppToPresident;

  @override
  State<OnlineCountScreen> createState() => _OnlineCountScreenState();
}

class _OnlineCountScreenState extends State<OnlineCountScreen> {
  final OnlineCountStorage _storage = OnlineCountStorage();
  final TextEditingController _baseUrlController = TextEditingController(
    text: OnlineCountApi.defaultBaseUrl,
  );
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _clubSlugController = TextEditingController();
  final TextEditingController _adminPinController = TextEditingController();
  final TextEditingController _meetingTitleController = TextEditingController(
    text: 'Regular Meeting',
  );
  final TextEditingController _meetingDateController = TextEditingController();
  final Map<OnlineAwardType, TextEditingController> _candidateControllers =
      <OnlineAwardType, TextEditingController>{
    for (final OnlineAwardType type in OnlineAwardType.values)
      type: TextEditingController(),
  };

  OnlineSession? _session;
  List<OnlineAward> _awards = <OnlineAward>[];
  OnlineResults? _results;
  String _ownerToken = '';
  String? _busyAction;
  String _lastGeneratedClubCode = '';
  bool _clubCodeManuallyEdited = false;
  bool _clubCreated = false;
  bool _loaded = false;
  bool _legacyMultipleSessions = false;
  OnlineAward? _activeAward;
  _QrLinkType? _selectedQrType;
  late Future<VoteResultsRecipient?> _recipientFuture;

  @override
  void initState() {
    super.initState();
    _meetingDateController.text = _todayText();
    _recipientFuture = widget.recipientRepository.load();
    _loadSetup();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _clubNameController.dispose();
    _clubSlugController.dispose();
    _adminPinController.dispose();
    _meetingTitleController.dispose();
    _meetingDateController.dispose();
    for (final TextEditingController controller
        in _candidateControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSetup() async {
    final OnlineCountSetup setup = await _storage.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _ownerToken = setup.ownerToken;
      _baseUrlController.text = setup.baseUrl;
      _clubNameController.text = setup.clubName;
      _clubSlugController.text = setup.clubSlug;
      _lastGeneratedClubCode = generateClubCode(setup.clubName);
      _clubCodeManuallyEdited =
          setup.clubSlug.isNotEmpty && setup.clubSlug != _lastGeneratedClubCode;
      _adminPinController.text = setup.adminPin;
      _meetingTitleController.text = setup.currentSessionTitle.isEmpty
          ? 'Regular Meeting'
          : setup.currentSessionTitle;
      _meetingDateController.text = setup.currentSessionDate.isEmpty
          ? _todayText()
          : setup.currentSessionDate;
      _clubCreated = _hasSavedClub(setup);
      if (setup.currentSessionId.isNotEmpty) {
        _session = OnlineSession(
          id: setup.currentSessionId,
          clubId: '',
          meetingTitle: _meetingTitleController.text,
          meetingDate: _meetingDateController.text,
          status: OnlineRoundStatus.fromValue(setup.currentSessionStatus),
        );
      }
      _loaded = true;
    });
  }

  OnlineCountApi _api() {
    return OnlineCountApi(baseUrl: _baseUrlController.text);
  }

  Future<void> _runAction(
    String action,
    Future<void> Function() operation,
  ) async {
    if (_busyAction != null) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() => _busyAction = action);
    try {
      await operation();
    } on OnlineCountApiException catch (error) {
      _showMessage(_friendlyError(error, l10n));
    } on TimeoutException {
      _showMessage(l10n.onlineCountCouldNotConnect);
    } catch (_) {
      _showMessage(l10n.onlineCountCouldNotConnect);
    } finally {
      if (mounted) {
        setState(() => _busyAction = null);
      }
    }
  }

  Future<void> _saveSetup({bool showMessage = true}) async {
    final String savedMessage = AppLocalizations.of(context)!.onlineCountSaved;
    await _storage.saveSetup(
      OnlineCountSetup(
        baseUrl: _baseUrlController.text.trim(),
        clubName: _clubNameController.text.trim(),
        clubSlug: _clubSlugController.text.trim(),
        adminPin: _adminPinController.text.trim(),
        currentSessionId: _session?.id ?? '',
        currentSessionTitle: _meetingTitleController.text.trim(),
        currentSessionDate: _meetingDateController.text.trim(),
        currentSessionStatus:
            _session?.status.value ?? OnlineRoundStatus.draft.value,
        ownerToken: _ownerToken,
      ),
    );
    if (showMessage) {
      _showMessage(savedMessage);
    }
  }

  Future<void> _createClub() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (!_canCreateOnlineClub) {
      _showMessage(l10n.onlineCountPleaseCompleteSetup);
      return;
    }
    await _runAction('createClub', () async {
      await _api().createOwnerClub(
        ownerToken: _ownerToken,
        clubName: _clubNameController.text.trim(),
        clubSlug: _clubSlugController.text.trim(),
        adminPin: _adminPinController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() => _clubCreated = true);
      await _saveSetup(showMessage: false);
      await _syncOnlineStatusFromCloud(showMessage: false);
      _showMessage(l10n.onlineCountClubReady);
    });
  }

  Future<void> _createMeeting() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (!_canCreateMeeting) {
      _showMessage(l10n.onlineCountPleaseCompleteSetup);
      return;
    }
    await _runAction('createMeeting', () async {
      final OnlineSession session = await _api().createCurrentMeeting(
        ownerToken: _ownerToken,
        clubSlug: _clubSlugController.text.trim(),
        adminPin: _adminPinController.text.trim(),
        meetingTitle: _meetingTitleController.text.trim(),
        meetingDate: _meetingDateController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _session = session;
        _awards = session.awards;
        _results = null;
        _activeAward = null;
        _legacyMultipleSessions = false;
      });
      await _saveSetup(showMessage: false);
      _showMessage(l10n.onlineCountActionComplete);
    });
  }

  Future<void> _openMeeting() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final OnlineSession? session = _session;
    if (session == null) {
      _showMessage(l10n.onlineCountCreateMeetingFirst);
      return;
    }
    if (!_canOpenMeeting) {
      _showMessage(l10n.onlineCountOpenMeetingFirst);
      return;
    }
    await _runAction('openMeeting', () async {
      final OnlineSession updated = await _api().openSession(
        sessionId: session.id,
        adminPin: _adminPinController.text.trim(),
        ownerToken: _ownerToken,
      );
      if (!mounted) {
        return;
      }
      setState(() => _session = updated.copyWith(awards: _awards));
      await _saveSetup(showMessage: false);
      _showMessage(l10n.onlineCountActionComplete);
    });
  }

  Future<void> _closeMeeting() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final OnlineSession? session = _session;
    if (session == null) {
      _showMessage(l10n.onlineCountCreateMeetingFirst);
      return;
    }
    if (!_canCloseMeeting) {
      _showMessage(l10n.onlineCountOpenMeetingFirst);
      return;
    }
    await _runAction('closeMeeting', () async {
      final OnlineSession updated = await _api().closeSession(
        sessionId: session.id,
        adminPin: _adminPinController.text.trim(),
        ownerToken: _ownerToken,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _session = updated.copyWith(awards: _awards);
        _awards = _awards
            .map(
              (OnlineAward award) => award.status == OnlineRoundStatus.open
                  ? OnlineAward(
                      id: award.id,
                      sessionId: award.sessionId,
                      type: award.type,
                      status: OnlineRoundStatus.closed,
                    )
                  : award,
            )
            .toList(growable: false);
      });
      await _refreshResults(showErrors: false);
      await _saveSetup(showMessage: false);
      _showMessage(l10n.onlineCountActionComplete);
    });
  }

  Future<void> _saveCandidates(OnlineAwardType type) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final OnlineSession? session = _session;
    final OnlineAward? award = _awardForType(type);
    if (session == null || award == null) {
      _showMessage(l10n.onlineCountCreateMeetingFirst);
      return;
    }
    if (award.status != OnlineRoundStatus.draft) {
      _showMessage(l10n.onlineCountAddCandidatesFirst);
      return;
    }
    final List<String> candidates = parseOnlineCandidateLines(
      _candidateControllers[type]?.text ?? '',
    );
    if (candidates.isEmpty) {
      _showMessage(l10n.voteBestsPleaseEnterName);
      return;
    }
    await _runAction('saveCandidates-${type.value}', () async {
      await _api().replaceCandidates(
        sessionId: session.id,
        adminPin: _adminPinController.text.trim(),
        awardType: type.value,
        candidates: candidates,
        ownerToken: _ownerToken,
      );
      _showMessage(l10n.onlineCountSaved);
    });
  }

  Future<void> _openAward(OnlineAward award) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final OnlineSession? session = _session;
    if (session == null) {
      _showMessage(l10n.onlineCountCreateMeetingFirst);
      return;
    }
    if (session.status != OnlineRoundStatus.open) {
      _showMessage(l10n.onlineCountOpenMeetingFirst);
      return;
    }
    if (award.status != OnlineRoundStatus.draft) {
      _showMessage(l10n.onlineCountAddCandidatesFirst);
      return;
    }
    await _runAction('openAward-${award.id}', () async {
      final OnlineAward updated = await _api().openAward(
        sessionId: session.id,
        awardId: award.id,
        adminPin: _adminPinController.text.trim(),
        ownerToken: _ownerToken,
      );
      _replaceAward(updated);
      setState(() => _activeAward = updated);
      _showMessage(l10n.onlineCountActionComplete);
    });
  }

  Future<void> _closeAward(OnlineAward award) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final OnlineSession? session = _session;
    if (session == null) {
      _showMessage(l10n.onlineCountCreateMeetingFirst);
      return;
    }
    if (award.status != OnlineRoundStatus.open) {
      _showMessage(l10n.onlineCountOpenMeetingFirst);
      return;
    }
    await _runAction('closeAward-${award.id}', () async {
      final OnlineAward updated = await _api().closeAward(
        sessionId: session.id,
        awardId: award.id,
        adminPin: _adminPinController.text.trim(),
        ownerToken: _ownerToken,
      );
      _replaceAward(updated);
      setState(() => _activeAward = null);
      _showMessage(l10n.onlineCountActionComplete);
    });
  }

  Future<void> _refreshResults({bool showErrors = true}) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final OnlineSession? session = _session;
    if (session == null || !_hasCloudSetup()) {
      if (showErrors) {
        _showMessage(l10n.onlineCountPleaseCompleteSetup);
      }
      return;
    }
    await _runAction('refreshResults', () async {
      final OnlineResults results = await _api().getResults(
        sessionId: session.id,
        adminPin: _adminPinController.text.trim(),
        ownerToken: _ownerToken,
      );
      if (!mounted) {
        return;
      }
      setState(() => _results = results);
      if (showErrors) {
        _showMessage(l10n.onlineCountActionComplete);
      }
    });
  }

  Future<void> _checkOnlineStatus({bool showMessage = true}) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (!_hasCloudSetup()) {
      _showMessage(l10n.onlineCountPleaseCompleteSetup);
      return;
    }
    await _runAction(
      'checkStatus',
      () => _syncOnlineStatusFromCloud(showMessage: showMessage),
    );
  }

  Future<void> _syncOnlineStatusFromCloud({required bool showMessage}) async {
    final String actionCompleteMessage =
        AppLocalizations.of(context)!.onlineCountActionComplete;
    final OnlineClubStatus status = await _api().getOwnerClubStatus(
      ownerToken: _ownerToken,
      clubSlug: _clubSlugController.text.trim(),
      adminPin: _adminPinController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _clubCreated = true;
      _legacyMultipleSessions = status.summary.legacyMultipleSessions;
      _activeAward = status.activeAward;
      if (status.currentSession == null) {
        _session = null;
        _awards = <OnlineAward>[];
        _results = null;
        _meetingTitleController.text = _meetingTitleController.text.isEmpty
            ? 'Regular Meeting'
            : _meetingTitleController.text;
        _meetingDateController.text = _meetingDateController.text.isEmpty
            ? _todayText()
            : _meetingDateController.text;
      } else {
        _session = status.currentSession;
        _meetingTitleController.text = status.currentSession!.meetingTitle;
        _meetingDateController.text = status.currentSession!.meetingDate;
      }
    });
    await _saveSetup(showMessage: false);
    if (showMessage) {
      _showMessage(actionCompleteMessage);
    }
  }

  Future<void> _deleteCurrentMeeting() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final OnlineSession? session = _session;
    if (session == null) {
      _showMessage(l10n.onlineCountCreateMeetingFirst);
      return;
    }
    final bool confirmed = await _confirmTypedAction(
      title: l10n.onlineCountDeleteCurrentMeeting,
      message: l10n.onlineCountDeleteCurrentMeetingWarning,
      requiredText: 'DELETE',
      confirmationLabel: l10n.onlineCountTypeDeleteToContinue,
    );
    if (!confirmed) {
      return;
    }
    await _runAction('deleteMeeting', () async {
      await _api().deleteCurrentMeeting(
        ownerToken: _ownerToken,
        sessionId: session.id,
        adminPin: _adminPinController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _session = null;
        _awards = <OnlineAward>[];
        _results = null;
        _activeAward = null;
        _legacyMultipleSessions = false;
        _meetingTitleController.text = 'Regular Meeting';
        _meetingDateController.text = _todayText();
        for (final TextEditingController controller
            in _candidateControllers.values) {
          controller.clear();
        }
      });
      await _saveSetup(showMessage: false);
      _showMessage(l10n.onlineCountCurrentMeetingDeleted);
    });
  }

  Future<void> _deleteOnlineClub() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (!_hasCloudSetup()) {
      _showMessage(l10n.onlineCountPleaseCompleteSetup);
      return;
    }
    final bool confirmed = await _confirmTypedAction(
      title: l10n.onlineCountDeleteOnlineClub,
      message: l10n.onlineCountDeleteOnlineClubWarning,
      requiredText: 'DELETE',
      confirmationLabel: l10n.onlineCountTypeDeleteToContinue,
    );
    if (!confirmed) {
      return;
    }
    await _runAction('deleteClub', () async {
      await _api().deleteOnlineClub(
        ownerToken: _ownerToken,
        clubSlug: _clubSlugController.text.trim(),
        adminPin: _adminPinController.text.trim(),
      );
      await _resetLocalOnlineCount(showMessage: false);
      _showMessage(l10n.onlineCountOnlineClubDeleted);
    });
  }

  Future<void> _resetOnlineCountOnThisDevice() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool confirmed = await _confirmTypedAction(
      title: l10n.onlineCountResetDeviceSetup,
      message: l10n.onlineCountResetDeviceSetupWarning,
      requiredText: 'RESET',
      confirmationLabel: l10n.onlineCountTypeResetToContinue,
    );
    if (!confirmed) {
      return;
    }
    await _resetLocalOnlineCount(showMessage: false);
    _showMessage(l10n.onlineCountDeviceSetupReset);
  }

  Future<void> _startFreshOnThisDevice() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool confirmed = await _confirmTypedAction(
      title: l10n.onlineCountStartFreshTitle,
      message: l10n.onlineCountStartFreshWarning,
      requiredText: 'FRESH',
      confirmationLabel: l10n.onlineCountTypeFreshToContinue,
    );
    if (!confirmed) {
      return;
    }
    await _storage.startFreshOnThisDevice();
    final OnlineCountSetup setup = await _storage.load();
    if (!mounted) {
      return;
    }
    _applyEmptySetup(setup);
    _showMessage(l10n.onlineCountStartedFresh);
  }

  Future<void> _resetLocalOnlineCount({required bool showMessage}) async {
    await _storage.resetOnlineCountOnThisDevice();
    final OnlineCountSetup setup = await _storage.load();
    if (!mounted) {
      return;
    }
    _applyEmptySetup(setup);
    if (showMessage) {
      _showMessage(AppLocalizations.of(context)!.onlineCountDeviceSetupReset);
    }
  }

  void _applyEmptySetup(OnlineCountSetup setup) {
    setState(() {
      _ownerToken = setup.ownerToken;
      _baseUrlController.text = setup.baseUrl;
      _clubNameController.clear();
      _clubSlugController.clear();
      _adminPinController.clear();
      _meetingTitleController.text = 'Regular Meeting';
      _meetingDateController.text = _todayText();
      _lastGeneratedClubCode = '';
      _clubCodeManuallyEdited = false;
      _clubCreated = false;
      _session = null;
      _awards = <OnlineAward>[];
      _results = null;
      _activeAward = null;
      _legacyMultipleSessions = false;
      for (final TextEditingController controller
          in _candidateControllers.values) {
        controller.clear();
      }
    });
  }

  void _replaceAward(OnlineAward updated) {
    setState(() {
      _awards = _awards
          .map(
            (OnlineAward award) => award.id == updated.id ? updated : award,
          )
          .toList(growable: false);
    });
  }

  Future<void> _copyText(String text) async {
    final String copiedMessage =
        AppLocalizations.of(context)!.onlineCountCopied;
    await Clipboard.setData(ClipboardData(text: text));
    _showMessage(copiedMessage);
  }

  Future<void> _copyResults() async {
    final OnlineResults? results = _results;
    if (results == null) {
      _showMessage(AppLocalizations.of(context)!.onlineCountNoResultsYet);
      return;
    }
    await _copyText(_buildOnlineResultsSummary(results));
  }

  Future<void> _sendResultsToPresident() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (_session == null) {
      _showMessage(l10n.onlineCountCreateMeetingFirst);
      return;
    }
    final OnlineResults? results = _results;
    if (results == null) {
      _showMessage(l10n.onlineCountRefreshResultsFirst);
      return;
    }

    final VoteResultsRecipient? recipient =
        await widget.recipientRepository.load();
    if (!mounted) {
      return;
    }
    if (recipient == null ||
        normalizeWhatsAppPhone(recipient.phoneNumber) == null) {
      _showMessage(l10n.voteBestsMissingPresidentPhoneNumber);
      return;
    }

    final String summary = _buildOnlineResultsSummary(results);
    final bool opened = await widget.launchWhatsAppToPresident(
      rawPhone: recipient.phoneNumber,
      message: summary,
    );
    if (!mounted) {
      return;
    }
    if (opened) {
      _showMessage(l10n.voteBestsWhatsAppOpened);
    } else {
      _copySummaryToClipboard(summary);
      if (mounted) {
        _showMessage(l10n.voteBestsWhatsAppOpenFailedCopied);
      }
    }
  }

  Future<void> _showContactDialog() async {
    final VoteResultsRecipient? currentRecipient =
        await widget.recipientRepository.load();
    if (!mounted) {
      return;
    }

    final PresidentContactInput? input =
        await showDialog<PresidentContactInput>(
      context: context,
      builder: (_) => PresidentContactDialog(
        initialName: currentRecipient?.name ?? '',
        initialPhoneNumber: currentRecipient?.phoneNumber ?? '',
      ),
    );

    if (input == null) {
      return;
    }
    final VoteResultsRecipient recipient =
        await widget.recipientRepository.save(
      name: input.name,
      phoneNumber: input.phoneNumber,
    );
    if (mounted) {
      setState(() {
        _recipientFuture = Future<VoteResultsRecipient?>.value(recipient);
      });
    }
  }

  void _copySummaryToClipboard(String summary) {
    unawaited(
      Clipboard.setData(ClipboardData(text: summary)).catchError((_) {}),
    );
  }

  String _buildOnlineResultsSummary(OnlineResults results) {
    return widget.summaryBuilder.build(
      results: results,
      locale: Localizations.localeOf(context),
    );
  }

  void _onClubNameChanged(String value) {
    final String generated = generateClubCode(value);
    final bool shouldAutoUpdate = _clubSlugController.text.trim().isEmpty ||
        (!_clubCodeManuallyEdited &&
            _clubSlugController.text == _lastGeneratedClubCode);
    setState(() {
      if (shouldAutoUpdate) {
        _clubSlugController.text = generated;
        _clubSlugController.selection = TextSelection.collapsed(
          offset: _clubSlugController.text.length,
        );
        _lastGeneratedClubCode = generated;
      }
    });
  }

  void _onClubCodeChanged(String value) {
    final String normalized = value.trim();
    setState(() {
      _clubCodeManuallyEdited =
          normalized.isNotEmpty && normalized != _lastGeneratedClubCode;
    });
  }

  bool _hasCloudSetup() {
    return _baseUrlController.text.trim().isNotEmpty &&
        _clubNameController.text.trim().isNotEmpty &&
        _clubSlugController.text.trim().isNotEmpty &&
        _adminPinController.text.trim().isNotEmpty;
  }

  bool get _canCreateOnlineClub => _hasCloudSetup();

  bool get _canCreateMeeting =>
      _hasCloudSetup() &&
      _session == null &&
      _meetingTitleController.text.trim().isNotEmpty &&
      _meetingDateController.text.trim().isNotEmpty;

  bool get _canOpenMeeting =>
      _session != null && _session!.status == OnlineRoundStatus.draft;

  bool get _canCloseMeeting =>
      _session != null && _session!.status == OnlineRoundStatus.open;

  OnlineCountUiState get _uiState {
    return resolveOnlineCountUiState(
      hasOnlineClub: _clubCreated && _hasCloudSetup(),
      sessionStatus: _session?.status,
    );
  }

  OnlineAward? _awardForType(OnlineAwardType type) {
    for (final OnlineAward award in _awards) {
      if (award.type == type) {
        return award;
      }
    }
    return null;
  }

  String _friendlyError(OnlineCountApiException error, AppLocalizations l10n) {
    if (error.code == 'OWNER_ALREADY_HAS_ACTIVE_CLUB') {
      return l10n.onlineCountOwnerAlreadyHasClub;
    }
    if (error.code == 'CLUB_SLUG_EXISTS') {
      return l10n.onlineCountClubSlugExists;
    }
    if (error.code == 'CURRENT_MEETING_EXISTS') {
      return l10n.onlineCountCurrentMeetingExists;
    }
    if (error.code == 'MISSING_OWNER_TOKEN' ||
        error.code == 'INVALID_OWNER_TOKEN' ||
        error.code == 'INVALID_ADMIN_PIN') {
      return l10n.onlineCountOwnerOrAdminInvalid;
    }
    if (error.code == 'OPEN_AWARD_EXISTS') {
      return l10n.onlineCountAnotherAwardOpen;
    }
    if (error.code == 'NO_CANDIDATES') {
      return l10n.onlineCountAddCandidatesFirst;
    }
    if (error.code == 'SESSION_NOT_OPEN') {
      return l10n.onlineCountOpenMeetingFirst;
    }
    if (error.code == 'DUPLICATE_CLUB') {
      return l10n.onlineCountClubMayExist;
    }
    if (error.code == 'BAD_RESPONSE') {
      return l10n.onlineCountCouldNotConnect;
    }
    return error.message.isEmpty
        ? l10n.onlineCountCouldNotConnect
        : error.message;
  }

  bool _hasSavedClub(OnlineCountSetup setup) {
    return setup.clubName.isNotEmpty &&
        setup.clubSlug.isNotEmpty &&
        setup.adminPin.isNotEmpty;
  }

  Future<bool> _confirmTypedAction({
    required String title,
    required String message,
    required String requiredText,
    required String confirmationLabel,
  }) async {
    final TextEditingController controller = TextEditingController();
    try {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (
              BuildContext context,
              StateSetter setDialogState,
            ) {
              final bool canConfirm = controller.text.trim() == requiredText;
              return AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(message),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: confirmationLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                        MaterialLocalizations.of(context).cancelButtonLabel),
                  ),
                  FilledButton(
                    onPressed: canConfirm
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    child:
                        Text(MaterialLocalizations.of(context).okButtonLabel),
                  ),
                ],
              );
            },
          );
        },
      );
      return confirmed == true;
    } finally {
      controller.dispose();
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.voteBestsOnlineCount)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.voteBestsOnlineCount),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: _buildStateSections(l10n),
        ),
      ),
    );
  }

  List<Widget> _buildStateSections(AppLocalizations l10n) {
    return switch (_uiState) {
      OnlineCountUiState.noOnlineClub => <Widget>[
          _buildCloudSetupCard(l10n),
          _buildDangerZoneCard(l10n),
        ],
      OnlineCountUiState.clubReadyNoMeeting => <Widget>[
          _buildLockedClubCard(l10n),
          _buildPermanentQrCard(l10n),
          _buildVotingLinkCard(l10n),
          _buildMeetingCard(l10n),
          _buildDangerZoneCard(l10n),
        ],
      OnlineCountUiState.meetingDraft => <Widget>[
          _buildLockedClubCard(l10n),
          _buildPermanentQrCard(l10n),
          _buildVotingLinkCard(l10n),
          _buildMeetingCard(l10n),
          _buildCandidateSetupCard(l10n),
          _buildDangerZoneCard(l10n),
        ],
      OnlineCountUiState.meetingOpen => <Widget>[
          _buildLockedClubCard(l10n),
          _buildPermanentQrCard(l10n),
          _buildVotingLinkCard(l10n),
          _buildMeetingCard(l10n),
          _buildVotingRoundCard(l10n),
          _buildDangerZoneCard(l10n),
        ],
      OnlineCountUiState.meetingClosed => <Widget>[
          _buildLockedClubCard(l10n),
          _buildPermanentQrCard(l10n),
          _buildVotingLinkCard(l10n),
          _buildMeetingCard(l10n),
          _buildResultsCard(l10n),
          _buildDangerZoneCard(l10n),
        ],
    };
  }

  Widget _buildCloudSetupCard(AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.onlineCountCloudSetup,
      icon: Icons.cloud_outlined,
      children: <Widget>[
        _BodyText(l10n.onlineCountSetupPurpose),
        _textField(
          controller: _clubNameController,
          label: l10n.onlineCountClubName,
          onChanged: _onClubNameChanged,
        ),
        _textField(
          controller: _clubSlugController,
          label: l10n.onlineCountClubSlug,
          helperText: l10n.onlineCountSlugHelp,
          onChanged: _onClubCodeChanged,
        ),
        _textField(
          controller: _adminPinController,
          label: l10n.onlineCountAdminPin,
          helperText:
              '${l10n.onlineCountAdminPinHelp}\n${l10n.onlineCountAdminPinVoterNote}',
          obscureText: true,
          keyboardType: TextInputType.number,
        ),
        _BodyText(l10n.onlineCountSetupButtonHelp),
        const SizedBox(height: 8),
        _fullWidthButton(
          child: OutlinedButton.icon(
            onPressed: _canCreateOnlineClub && _busyAction != 'createClub'
                ? () => _createClub()
                : null,
            icon: const Icon(Icons.add_business_outlined),
            label: Text(l10n.onlineCountCreateClub),
          ),
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Text(
            l10n.onlineCountAdvancedSettings,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          children: <Widget>[
            _BodyText(l10n.onlineCountBackendUrlHelp),
            _textField(
              controller: _baseUrlController,
              label: l10n.onlineCountBackendUrl,
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLockedClubCard(AppLocalizations l10n) {
    final String clubName = _clubNameController.text.trim();
    final String clubCode = _clubSlugController.text.trim();
    final String link =
        clubCode.isEmpty ? '' : _api().votingLinkForClub(clubCode);

    return _SectionCard(
      title: l10n.onlineCountClubReadyTitle,
      icon: Icons.verified_outlined,
      children: <Widget>[
        _InfoBlock(
          lines: <String>[
            '${l10n.onlineCountOnlineClubLabel}: $clubName',
            '${l10n.onlineCountClubCodeLabel}: $clubCode',
            '${l10n.onlineCountVotingLink}: $link',
            if (_legacyMultipleSessions) l10n.onlineCountLegacySessionsWarning,
            if (_activeAward != null)
              '${l10n.onlineCountVotingRound}: '
                  '${onlineAwardLabel(_activeAward!.type, Localizations.localeOf(context))}',
          ],
        ),
        const SizedBox(height: 12),
        _buttonWrap(
          <Widget>[
            FilledButton.icon(
              onPressed: _busyAction == 'checkStatus'
                  ? null
                  : () => _checkOnlineStatus(),
              icon: const Icon(Icons.cloud_sync_outlined),
              label: Text(l10n.onlineCountCheckOnlineStatus),
            ),
            OutlinedButton.icon(
              onPressed: _busyAction == 'deleteClub' ? null : _deleteOnlineClub,
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(l10n.onlineCountDeleteOnlineClub),
            ),
          ],
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Text(
            l10n.onlineCountAdvancedSettings,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          children: <Widget>[
            _BodyText(l10n.onlineCountBackendUrlHelp),
            _textField(
              controller: _baseUrlController,
              label: l10n.onlineCountBackendUrl,
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDangerZoneCard(AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.onlineCountDangerZone,
      icon: Icons.warning_amber_outlined,
      children: <Widget>[
        _BodyText(l10n.onlineCountDangerZoneHelp),
        const SizedBox(height: 8),
        _buttonWrap(
          <Widget>[
            OutlinedButton.icon(
              onPressed: _resetOnlineCountOnThisDevice,
              icon: const Icon(Icons.restart_alt_outlined),
              label: Text(l10n.onlineCountResetDeviceSetup),
            ),
            OutlinedButton.icon(
              onPressed: _startFreshOnThisDevice,
              icon: const Icon(Icons.refresh_outlined),
              label: Text(l10n.onlineCountStartFreshDevice),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeetingCard(AppLocalizations l10n) {
    final Locale locale = Localizations.localeOf(context);
    return _SectionCard(
      title: l10n.onlineCountCurrentMeeting,
      icon: Icons.event_note_outlined,
      children: <Widget>[
        _BodyText(l10n.onlineCountMeetingExplanation),
        const SizedBox(height: 10),
        if (_session == null)
          _InfoBlock(lines: <String>[l10n.onlineCountNoCurrentMeeting])
        else ...<Widget>[
          _InfoBlock(
            lines: <String>[
              '${l10n.onlineCountMeetingTitle}: ${_session!.meetingTitle}',
              '${l10n.onlineCountMeetingDate}: ${_session!.meetingDate}',
              '${l10n.onlineCountSessionStatus}: '
                  '${_sessionStatusLabel(_session!.status, locale)}',
              _sessionStatusHelp(_session!.status, l10n),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (_session == null) ...<Widget>[
          const SizedBox(height: 14),
          _textField(
            controller: _meetingTitleController,
            label: l10n.onlineCountMeetingTitle,
          ),
          _textField(
            controller: _meetingDateController,
            label: l10n.onlineCountMeetingDate,
            keyboardType: TextInputType.datetime,
          ),
        ],
        const SizedBox(height: 10),
        if (_session == null)
          _fullWidthButton(
            child: FilledButton.icon(
              onPressed: _canCreateMeeting && _busyAction != 'createMeeting'
                  ? () => _createMeeting()
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              label: Text(l10n.onlineCountCreateCurrentMeeting),
            ),
          ),
        if (_session != null &&
            _session!.status == OnlineRoundStatus.draft) ...<Widget>[
          const SizedBox(height: 10),
          _fullWidthButton(
            child: OutlinedButton.icon(
              onPressed: _canOpenMeeting && _busyAction != 'openMeeting'
                  ? () => _openMeeting()
                  : null,
              icon: const Icon(Icons.play_arrow_outlined),
              label: Text(l10n.onlineCountOpenMeeting),
            ),
          ),
        ],
        if (_session != null &&
            _session!.status == OnlineRoundStatus.open) ...<Widget>[
          const SizedBox(height: 10),
          _fullWidthButton(
            child: OutlinedButton.icon(
              onPressed: _canCloseMeeting && _busyAction != 'closeMeeting'
                  ? () => _closeMeeting()
                  : null,
              icon: const Icon(Icons.stop_circle_outlined),
              label: Text(l10n.onlineCountCloseMeeting),
            ),
          ),
        ],
        if (_session != null) ...<Widget>[
          const SizedBox(height: 10),
          _fullWidthButton(
            child: OutlinedButton.icon(
              onPressed:
                  _busyAction == 'deleteMeeting' ? null : _deleteCurrentMeeting,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.onlineCountDeleteCurrentMeeting),
            ),
          ),
        ],
        if (_session != null)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text(
              l10n.onlineCountTechnicalDetails,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            children: <Widget>[
              _InfoBlock(lines: <String>[
                '${l10n.onlineCountSessionId}: ${_session!.id}'
              ]),
            ],
          ),
      ],
    );
  }

  Widget _buildCandidateSetupCard(AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.onlineCountCandidateSetup,
      icon: Icons.groups_outlined,
      children: OnlineAwardType.values.map(
        (OnlineAwardType type) {
          final OnlineAward? award = _awardForType(type);
          final bool canEdit = award != null &&
              award.status == OnlineRoundStatus.draft &&
              _session != null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  onlineAwardLabel(type, Localizations.localeOf(context)),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _textField(
                  controller: _candidateControllers[type]!,
                  label: l10n.onlineCountCandidateHint,
                  minLines: 3,
                  maxLines: 6,
                  enabled: canEdit,
                ),
                _fullWidthButton(
                  child: OutlinedButton.icon(
                    onPressed:
                        canEdit && _busyAction != 'saveCandidates-${type.value}'
                            ? () => _saveCandidates(type)
                            : null,
                    icon: const Icon(Icons.check_outlined),
                    label: Text(_saveCandidatesLabel(type, l10n)),
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(growable: false),
    );
  }

  Widget _buildVotingRoundCard(AppLocalizations l10n) {
    final Locale locale = Localizations.localeOf(context);
    return _SectionCard(
      title: l10n.onlineCountVotingRound,
      icon: Icons.how_to_vote_outlined,
      children: <Widget>[
        if (_awards.isEmpty)
          Text(
            l10n.onlineCountNoSessionYet,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          )
        else
          for (final OnlineAward award in _awards)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              onlineAwardLabel(award.type, locale),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _StatusPill(
                            label: onlineStatusLabel(award.status, locale),
                            status: award.status,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buttonWrap(
                        <Widget>[
                          FilledButton.icon(
                            onPressed: _session?.status ==
                                        OnlineRoundStatus.open &&
                                    award.status == OnlineRoundStatus.draft &&
                                    _busyAction != 'openAward-${award.id}'
                                ? () => _openAward(award)
                                : null,
                            icon: const Icon(Icons.play_arrow_outlined),
                            label: Text(l10n.onlineCountOpenVoting),
                          ),
                          OutlinedButton.icon(
                            onPressed: award.status == OnlineRoundStatus.open &&
                                    _busyAction != 'closeAward-${award.id}'
                                ? () => _closeAward(award)
                                : null,
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: Text(l10n.onlineCountCloseVoting),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildVotingLinkCard(AppLocalizations l10n) {
    final String clubSlug = _clubSlugController.text.trim();
    final OnlineCountApi api = _api();
    final String autoLink =
        clubSlug.isEmpty ? '' : api.votingLinkForClub(clubSlug);
    final String zhLink =
        clubSlug.isEmpty ? '' : api.votingLinkForClub(clubSlug, lang: 'zh');
    final String enLink =
        clubSlug.isEmpty ? '' : api.votingLinkForClub(clubSlug, lang: 'en');

    return _SectionCard(
      title: l10n.onlineCountVotingLink,
      icon: Icons.link_outlined,
      children: <Widget>[
        _BodyText(l10n.onlineCountVotingLinkHelp),
        const SizedBox(height: 10),
        _LinkBlock(link: zhLink),
        const SizedBox(height: 8),
        _LinkBlock(link: enLink),
        const SizedBox(height: 8),
        _LinkBlock(link: autoLink),
        _buttonWrap(
          <Widget>[
            FilledButton.icon(
              onPressed: zhLink.isEmpty ? null : () => _copyText(zhLink),
              icon: const Icon(Icons.copy_outlined),
              label: Text(l10n.onlineCountCopyChineseLink),
            ),
            OutlinedButton.icon(
              onPressed: enLink.isEmpty ? null : () => _copyText(enLink),
              icon: const Icon(Icons.copy_outlined),
              label: Text(l10n.onlineCountCopyEnglishLink),
            ),
            OutlinedButton.icon(
              onPressed: autoLink.isEmpty ? null : () => _copyText(autoLink),
              icon: const Icon(Icons.copy_outlined),
              label: Text(l10n.onlineCountCopyAutoLink),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPermanentQrCard(AppLocalizations l10n) {
    final Locale locale = Localizations.localeOf(context);
    final _QrLinkType selectedType = _currentQrType(locale);
    final String clubCode = _clubSlugController.text.trim();
    final String baseUrl = _baseUrlController.text.trim();
    final String url = _qrUrl(selectedType);

    return _SectionCard(
      title: l10n.onlineCountPermanentVotingQr,
      icon: Icons.qr_code_2_outlined,
      children: <Widget>[
        _BodyText(l10n.onlineCountPermanentVotingQrHelp),
        const SizedBox(height: 12),
        if (baseUrl.isEmpty)
          Text(
            l10n.onlineCountCompleteSetupFirst,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          )
        else if (clubCode.isEmpty)
          Text(
            l10n.onlineCountEnterClubCodeFirst,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          )
        else ...<Widget>[
          SegmentedButton<_QrLinkType>(
            segments: <ButtonSegment<_QrLinkType>>[
              ButtonSegment<_QrLinkType>(
                value: _QrLinkType.zh,
                label: Text(l10n.onlineCountQrChinese),
              ),
              ButtonSegment<_QrLinkType>(
                value: _QrLinkType.en,
                label: Text(l10n.onlineCountQrEnglish),
              ),
              ButtonSegment<_QrLinkType>(
                value: _QrLinkType.auto,
                label: Text(l10n.onlineCountQrAuto),
              ),
            ],
            selected: <_QrLinkType>{selectedType},
            onSelectionChanged: (Set<_QrLinkType> value) {
              setState(() => _selectedQrType = value.single);
            },
          ),
          const SizedBox(height: 14),
          Text(
            _qrLabel(selectedType, l10n),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: 240,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _LinkBlock(link: url),
          _buttonWrap(
            <Widget>[
              FilledButton.icon(
                onPressed: () => _copyText(url),
                icon: const Icon(Icons.copy_outlined),
                label: Text(l10n.onlineCountCopyQrLink),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyText(buildVotingPrintText(url, locale)),
                icon: const Icon(Icons.print_outlined),
                label: Text(l10n.onlineCountCopyPrintText),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildResultsCard(AppLocalizations l10n) {
    final Locale locale = Localizations.localeOf(context);
    return _SectionCard(
      title: l10n.onlineCountResults,
      icon: Icons.emoji_events_outlined,
      children: <Widget>[
        _buttonWrap(
          <Widget>[
            FilledButton.icon(
              onPressed: _busyAction == 'refreshResults'
                  ? null
                  : () => _refreshResults(),
              icon: const Icon(Icons.refresh_outlined),
              label: Text(l10n.onlineCountRefreshResults),
            ),
            OutlinedButton.icon(
              onPressed: _sendResultsToPresident,
              icon: const Icon(Icons.send_outlined),
              label: Text(l10n.voteBestsSendResultsToPresident),
            ),
            OutlinedButton.icon(
              onPressed: _copyResults,
              icon: const Icon(Icons.copy_outlined),
              label: Text(l10n.onlineCountCopyResults),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildPresidentContactCard(l10n),
        const SizedBox(height: 10),
        if (_results == null)
          Text(
            l10n.onlineCountNoResultsYet,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          )
        else ...<Widget>[
          Text(
            _results!.isFinal
                ? l10n.onlineCountFinalResults
                : l10n.onlineCountResultsNotFinal,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final OnlineAwardResult award in _results!.awards)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ResultAwardView(
                result: award,
                locale: locale,
                l10n: l10n,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildPresidentContactCard(AppLocalizations l10n) {
    return FutureBuilder<VoteResultsRecipient?>(
      future: _recipientFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<VoteResultsRecipient?> snapshot,
      ) {
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: ListTile(
            minVerticalPadding: 14,
            leading: const Icon(Icons.contact_phone_outlined),
            title: Text(
              l10n.voteBestsPresidentContact,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              snapshot.connectionState == ConnectionState.waiting
                  ? '...'
                  : snapshot.data == null
                      ? l10n.voteBestsContactNotSet
                      : '${snapshot.data!.name} · ${snapshot.data!.phoneNumber}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showContactDialog,
          ),
        );
      },
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    bool obscureText = false,
    bool enabled = true,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: obscureText ? 1 : maxLines,
        onChanged: onChanged ?? (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _fullWidthButton({required Widget child}) {
    return SizedBox(width: double.infinity, height: 50, child: child);
  }

  Widget _buttonWrap(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: children,
      ),
    );
  }

  String _saveCandidatesLabel(OnlineAwardType type, AppLocalizations l10n) {
    return switch (type) {
      OnlineAwardType.bestSpeaker => l10n.onlineCountSaveBestSpeakerCandidates,
      OnlineAwardType.bestTableTopics =>
        l10n.onlineCountSaveTableTopicsCandidates,
      OnlineAwardType.bestEvaluator => l10n.onlineCountSaveEvaluatorCandidates,
    };
  }

  String _sessionStatusLabel(OnlineRoundStatus status, Locale locale) {
    final bool isChinese = locale.languageCode == 'zh';
    return switch (status) {
      OnlineRoundStatus.draft => isChinese ? '草稿' : 'Draft',
      OnlineRoundStatus.open => isChinese ? '开放中' : 'Open',
      OnlineRoundStatus.closed => isChinese ? '已结束' : 'Closed',
    };
  }

  String _sessionStatusHelp(OnlineRoundStatus status, AppLocalizations l10n) {
    return switch (status) {
      OnlineRoundStatus.draft => l10n.onlineCountDraftHelp,
      OnlineRoundStatus.open => l10n.onlineCountOpenHelp,
      OnlineRoundStatus.closed => l10n.onlineCountClosedHelp,
    };
  }

  _QrLinkType _currentQrType(Locale locale) {
    return _selectedQrType ??
        (locale.languageCode == 'zh' ? _QrLinkType.zh : _QrLinkType.en);
  }

  String _qrUrl(_QrLinkType type) {
    final String clubCode = _clubSlugController.text.trim();
    if (clubCode.isEmpty) {
      return '';
    }
    return switch (type) {
      _QrLinkType.zh => _api().votingLinkForClub(clubCode, lang: 'zh'),
      _QrLinkType.en => _api().votingLinkForClub(clubCode, lang: 'en'),
      _QrLinkType.auto => _api().votingLinkForClub(clubCode),
    };
  }

  String _qrLabel(_QrLinkType type, AppLocalizations l10n) {
    return switch (type) {
      _QrLinkType.zh => l10n.onlineCountChineseVotingPage,
      _QrLinkType.en => l10n.onlineCountEnglishVotingPage,
      _QrLinkType.auto => l10n.onlineCountAutoLanguage,
    };
  }

  static String _todayText() {
    final DateTime now = DateTime.now();
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}

enum _QrLinkType { zh, en, auto }

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.35),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.status,
  });

  final String label;
  final OnlineRoundStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      OnlineRoundStatus.draft => Colors.blueGrey,
      OnlineRoundStatus.open => Colors.green,
      OnlineRoundStatus.closed => Colors.deepOrange,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines
              .map(
                (String line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SelectableText(
                    line,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _LinkBlock extends StatelessWidget {
  const _LinkBlock({required this.link});

  final String link;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SelectableText(
          link.isEmpty ? '-' : link,
          style: const TextStyle(fontSize: 14, height: 1.35),
        ),
      ),
    );
  }
}

class _ResultAwardView extends StatelessWidget {
  const _ResultAwardView({
    required this.result,
    required this.locale,
    required this.l10n,
  });

  final OnlineAwardResult result;
  final Locale locale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final String topLine;
    if (result.winners.isEmpty) {
      topLine = l10n.voteBestsNoVotesYet;
    } else if (result.hasTie) {
      topLine = l10n.onlineCountTie(
        result.winners
            .map((OnlineCandidateResult candidate) => candidate.name)
            .join(locale.languageCode == 'zh' ? '、' : ', '),
      );
    } else {
      topLine = l10n.onlineCountWinner(result.winners.single.name);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    onlineAwardLabel(result.type, locale),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusPill(
                  label: onlineStatusLabel(result.status, locale),
                  status: result.status,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              topLine,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            for (final OnlineCandidateResult candidate in result.candidates)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        candidate.name,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Text(
                      l10n.onlineCountVotes(candidate.voteCount),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
