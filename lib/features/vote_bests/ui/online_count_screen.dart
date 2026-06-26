import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../l10n/app_localizations.dart';
import '../data/online_count/online_count_api.dart';
import '../data/online_count/online_count_models.dart';
import '../data/online_count/online_count_qr_share_helper.dart';
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
    this.debugInitialAwards = const <OnlineAward>[],
  })  : recipientRepository =
            recipientRepository ?? VoteResultsRecipientRepository(),
        summaryBuilder =
            summaryBuilder ?? const OnlineCountResultsSummaryBuilder(),
        launchWhatsAppToPresident =
            launchWhatsAppToPresident ?? launchWhatsAppToPresidentDefault;

  final VoteResultsRecipientRepository recipientRepository;
  final OnlineCountResultsSummaryBuilder summaryBuilder;
  final LaunchPresidentWhatsApp launchWhatsAppToPresident;
  final List<OnlineAward> debugInitialAwards;

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
  final Map<OnlineAwardType, VoidCallback> _candidateDraftListeners =
      <OnlineAwardType, VoidCallback>{};

  OnlineSession? _session;
  List<OnlineAward> _awards = <OnlineAward>[];
  OnlineResults? _results;
  String _ownerToken = '';
  String? _busyAction;
  final Map<OnlineAwardType, String> _savedCandidateFingerprints =
      <OnlineAwardType, String>{};
  bool _clubCreated = false;
  bool _loaded = false;
  bool _legacyMultipleSessions = false;
  OnlineAward? _activeAward;
  Timer? _voteCountTimer;
  bool _voteCountRefreshInFlight = false;
  bool _voteCountRefreshFailed = false;
  DateTime? _lastVoteCountRefreshAt;
  Map<String, int> _voteTotalsByAwardType = <String, int>{};
  late Future<VoteResultsRecipient?> _recipientFuture;
  bool _elementActive = true;
  bool _restoringCandidateDrafts = false;

  bool get _canUseContext => mounted && _elementActive;
  bool get _canUpdateState => mounted && _elementActive;

  @override
  void initState() {
    super.initState();
    _meetingDateController.text = _todayText();
    _recipientFuture = widget.recipientRepository.load();
    for (final MapEntry<OnlineAwardType, TextEditingController> entry
        in _candidateControllers.entries) {
      void listener() => _onCandidateDraftChanged(entry.key);
      _candidateDraftListeners[entry.key] = listener;
      entry.value.addListener(listener);
    }
    _loadSetup();
  }

  @override
  void dispose() {
    _elementActive = false;
    _stopVoteCountPolling();
    for (final MapEntry<OnlineAwardType, TextEditingController> entry
        in _candidateControllers.entries) {
      final VoidCallback? listener = _candidateDraftListeners[entry.key];
      if (listener != null) {
        entry.value.removeListener(listener);
      }
    }
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

  @override
  void deactivate() {
    _elementActive = false;
    _stopVoteCountPolling();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    _elementActive = true;
    _syncVoteCountPolling();
  }

  Future<void> _loadSetup() async {
    final OnlineCountSetup setup = await _storage.load();
    final List<OnlineAward> storedAwards = setup.currentSessionId.isEmpty
        ? <OnlineAward>[]
        : await _storage.loadAwardStates(setup.currentSessionId);
    if (!_canUpdateState) {
      return;
    }
    setState(() {
      _ownerToken = setup.ownerToken;
      _baseUrlController.text = setup.baseUrl;
      _clubNameController.text = setup.clubName;
      _clubSlugController.text = setup.clubSlug;
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
        _awards =
            storedAwards.isNotEmpty ? storedAwards : widget.debugInitialAwards;
      }
      _loaded = true;
    });
    if (setup.currentSessionId.isNotEmpty) {
      await _restoreCandidateStateForSession(setup.currentSessionId);
    }
    _syncVoteCountPolling();
  }

  void _onCandidateDraftChanged(OnlineAwardType type) {
    if (_restoringCandidateDrafts || !_canUpdateState) {
      return;
    }
    setState(() {});
    final String? sessionId = _session?.id;
    if (sessionId == null || sessionId.isEmpty) {
      return;
    }
    final String text = _candidateControllers[type]?.text ?? '';
    unawaited(
      _storage.saveCandidateDraft(
        sessionId: sessionId,
        awardType: type.value,
        text: text,
      ),
    );
  }

  Future<void> _restoreCandidateStateForSession(String sessionId) async {
    if (sessionId.isEmpty) {
      return;
    }
    final Map<OnlineAwardType, String?> drafts = <OnlineAwardType, String?>{};
    final Map<OnlineAwardType, String?> savedTexts =
        <OnlineAwardType, String?>{};
    for (final OnlineAwardType type in OnlineAwardType.values) {
      drafts[type] = await _storage.loadCandidateDraft(
        sessionId: sessionId,
        awardType: type.value,
      );
      savedTexts[type] = await _storage.loadCandidateSavedText(
        sessionId: sessionId,
        awardType: type.value,
      );
    }
    if (!_canUpdateState || _session?.id != sessionId) {
      return;
    }
    _restoringCandidateDrafts = true;
    try {
      for (final OnlineAwardType type in OnlineAwardType.values) {
        final String? draft = drafts[type];
        if (draft != null) {
          _candidateControllers[type]?.text = draft;
        }
      }
    } finally {
      _restoringCandidateDrafts = false;
    }
    if (_canUpdateState) {
      setState(() {
        _savedCandidateFingerprints
          ..clear()
          ..addEntries(
            savedTexts.entries
                .where(
                  (MapEntry<OnlineAwardType, String?> entry) =>
                      entry.value != null,
                )
                .map(
                  (MapEntry<OnlineAwardType, String?> entry) =>
                      MapEntry<OnlineAwardType, String>(
                    entry.key,
                    entry.value!,
                  ),
                ),
          );
      });
    }
  }

  OnlineCountApi _api() {
    return OnlineCountApi(baseUrl: _baseUrlController.text);
  }

  Future<void> _runAction(
    String action,
    Future<void> Function() operation, {
    String? failureMessage,
  }) async {
    if (_busyAction != null || !_canUseContext) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() => _busyAction = action);
    try {
      await operation();
    } on OnlineCountApiException catch (error) {
      _showMessage(failureMessage ?? _friendlyError(error, l10n));
    } on TimeoutException {
      _showMessage(failureMessage ?? l10n.onlineCountCouldNotConnect);
    } catch (_) {
      _showMessage(failureMessage ?? l10n.onlineCountCouldNotConnect);
    } finally {
      if (_canUpdateState) {
        setState(() => _busyAction = null);
      }
    }
  }

  Future<void> _saveSetup({bool showMessage = true}) async {
    final String savedMessage = showMessage && _canUseContext
        ? AppLocalizations.of(context)!.onlineCountSaved
        : '';
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
    if (showMessage && savedMessage.isNotEmpty) {
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
      final String clubName = _clubNameController.text.trim();
      final String clubCode = generateClubCode(clubName);
      final String adminPin = generateAdminPin();
      _clubSlugController.text = clubCode;
      _adminPinController.text = adminPin;
      await _api().createOwnerClub(
        ownerToken: _ownerToken,
        clubName: clubName,
        clubSlug: clubCode,
        adminPin: adminPin,
      );
      if (!_canUpdateState) {
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
      if (!_canUpdateState) {
        return;
      }
      setState(() {
        _session = session;
        _awards = session.awards;
        _results = null;
        _activeAward = null;
        _legacyMultipleSessions = false;
        _savedCandidateFingerprints.clear();
        _clearVoteCountState();
      });
      await _storage.saveAwardStates(
        sessionId: session.id,
        awards: session.awards,
      );
      await _saveSetup(showMessage: false);
      _syncVoteCountPolling();
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
      _showMessage(l10n.onlineCountAddAllCandidatesBeforeOpening);
      return;
    }
    await _runAction('openMeeting', () async {
      final OnlineSession updated = await _api().openSession(
        sessionId: session.id,
        adminPin: _adminPinController.text.trim(),
        ownerToken: _ownerToken,
      );
      if (!_canUpdateState) {
        return;
      }
      setState(() => _session = updated.copyWith(awards: _awards));
      await _saveSetup(showMessage: false);
      await _storage.saveAwardStates(
        sessionId: session.id,
        awards: _awards,
      );
      _syncVoteCountPolling();
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
      if (!_canUpdateState) {
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
        _activeAward = null;
      });
      await _storage.saveAwardStates(
        sessionId: session.id,
        awards: _awards,
      );
      await _refreshResults(showErrors: false);
      await _saveSetup(showMessage: false);
      _syncVoteCountPolling();
      _showMessage(l10n.onlineCountActionComplete);
    });
  }

  Future<void> _saveCandidates(OnlineAwardType type) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final OnlineSession? session = _session;
    final OnlineAward? award = _awardForType(type);
    if (session == null) {
      _showMessage(l10n.onlineCountCreateMeetingFirst);
      return;
    }
    if (session.status != OnlineRoundStatus.draft ||
        (award != null && award.status != OnlineRoundStatus.draft)) {
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
      if (_canUpdateState) {
        setState(() {
          _savedCandidateFingerprints[type] = _candidateFingerprint(candidates);
        });
      }
      await _storage.saveCandidateSavedText(
        sessionId: session.id,
        awardType: type.value,
        normalizedText: _candidateFingerprint(candidates),
      );
      _showMessage(l10n.onlineCountCandidatesSaved);
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
      await _storage.saveAwardState(
        sessionId: session.id,
        awardType: updated.type,
        awardId: updated.id,
        status: updated.status,
      );
      unawaited(_refreshVoteCounts(showError: false));
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
      await _storage.saveAwardState(
        sessionId: session.id,
        awardType: updated.type,
        awardId: updated.id,
        status: updated.status,
      );
      unawaited(_refreshVoteCounts(showError: false));
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
      if (!_canUpdateState) {
        return;
      }
      setState(() {
        _results = results;
        _voteTotalsByAwardType = buildAwardVoteTotals(results);
        _lastVoteCountRefreshAt = DateTime.now();
        _voteCountRefreshFailed = false;
      });
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
      failureMessage: l10n.onlineCountCouldNotCheckStatus,
    );
  }

  Future<void> _syncOnlineStatusFromCloud({required bool showMessage}) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final OnlineClubStatus status = await _api().getOwnerClubStatus(
      ownerToken: _ownerToken,
      clubSlug: _clubSlugController.text.trim(),
      adminPin: _adminPinController.text.trim(),
    );
    if (!_canUpdateState) {
      return;
    }
    final String? previousSessionId = _session?.id;
    final String? refreshedSessionId = status.currentSession?.id;
    final List<OnlineAward> storedAwards = refreshedSessionId == null
        ? <OnlineAward>[]
        : await _storage.loadAwardStates(refreshedSessionId);
    if (!_canUpdateState) {
      return;
    }
    final List<OnlineAward> refreshedAwards = _awardsForStatusRefresh(
      sessionId: refreshedSessionId,
      previousSessionId: previousSessionId,
      cloudAwards: status.currentSession?.awards ?? <OnlineAward>[],
      storedAwards: storedAwards,
      activeAward: status.activeAward,
    );
    setState(() {
      _clubCreated = true;
      _legacyMultipleSessions = status.summary.legacyMultipleSessions;
      _activeAward = status.activeAward;
      if (status.currentSession == null) {
        _session = null;
        _awards = <OnlineAward>[];
        _results = null;
        _clearVoteCountState();
        _meetingTitleController.text = _meetingTitleController.text.isEmpty
            ? 'Regular Meeting'
            : _meetingTitleController.text;
        _meetingDateController.text = _meetingDateController.text.isEmpty
            ? _todayText()
            : _meetingDateController.text;
      } else {
        _session = status.currentSession;
        _awards = refreshedAwards;
        _meetingTitleController.text = status.currentSession!.meetingTitle;
        _meetingDateController.text = status.currentSession!.meetingDate;
      }
    });
    if (refreshedSessionId != null && refreshedAwards.isNotEmpty) {
      await _storage.saveAwardStates(
        sessionId: refreshedSessionId,
        awards: refreshedAwards,
      );
    }
    if (refreshedSessionId != null &&
        refreshedSessionId.isNotEmpty &&
        refreshedSessionId != previousSessionId) {
      await _restoreCandidateStateForSession(refreshedSessionId);
    }
    await _saveSetup(showMessage: false);
    _syncVoteCountPolling();
    if (showMessage && status.currentSession == null) {
      _showMessage(l10n.onlineCountNoCurrentMeetingFound);
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
    _stopVoteCountPolling();
    await _runAction('deleteMeeting', () async {
      await _api().deleteCurrentMeeting(
        ownerToken: _ownerToken,
        sessionId: session.id,
        adminPin: _adminPinController.text.trim(),
      );
      if (!_canUpdateState) {
        return;
      }
      setState(() {
        _session = null;
        _awards = <OnlineAward>[];
        _results = null;
        _activeAward = null;
        _legacyMultipleSessions = false;
        _savedCandidateFingerprints.clear();
        _clearVoteCountState();
        _meetingTitleController.text = 'Regular Meeting';
        _meetingDateController.text = _todayText();
        for (final TextEditingController controller
            in _candidateControllers.values) {
          controller.clear();
        }
      });
      await _storage.clearOnlineStateForSession(session.id);
      await _saveSetup(showMessage: false);
      _syncVoteCountPolling();
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
    _stopVoteCountPolling();
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
    _stopVoteCountPolling();
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
    _stopVoteCountPolling();
    await _storage.startFreshOnThisDevice();
    final OnlineCountSetup setup = await _storage.load();
    if (!_canUpdateState) {
      return;
    }
    _applyEmptySetup(setup);
    _showMessage(l10n.onlineCountStartedFresh);
  }

  Future<void> _resetLocalOnlineCount({required bool showMessage}) async {
    final String resetMessage = showMessage && _canUseContext
        ? AppLocalizations.of(context)!.onlineCountDeviceSetupReset
        : '';
    await _storage.resetOnlineCountOnThisDevice();
    final OnlineCountSetup setup = await _storage.load();
    if (!_canUpdateState) {
      return;
    }
    _applyEmptySetup(setup);
    if (showMessage && resetMessage.isNotEmpty) {
      _showMessage(resetMessage);
    }
  }

  void _applyEmptySetup(OnlineCountSetup setup) {
    if (!_canUpdateState) {
      return;
    }
    _stopVoteCountPolling();
    setState(() {
      _ownerToken = setup.ownerToken;
      _baseUrlController.text = setup.baseUrl;
      _clubNameController.clear();
      _clubSlugController.clear();
      _adminPinController.clear();
      _meetingTitleController.text = 'Regular Meeting';
      _meetingDateController.text = _todayText();
      _clubCreated = false;
      _session = null;
      _awards = <OnlineAward>[];
      _results = null;
      _activeAward = null;
      _legacyMultipleSessions = false;
      _savedCandidateFingerprints.clear();
      _clearVoteCountState();
      for (final TextEditingController controller
          in _candidateControllers.values) {
        controller.clear();
      }
    });
  }

  void _syncVoteCountPolling() {
    if (!_canUpdateState) {
      _stopVoteCountPolling();
      return;
    }
    if (_session?.status == OnlineRoundStatus.open && _hasCloudSetup()) {
      _startVoteCountPolling();
    } else {
      _stopVoteCountPolling();
    }
  }

  void _startVoteCountPolling() {
    if (!_canUpdateState || _voteCountTimer != null) {
      return;
    }
    _voteCountTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => unawaited(_refreshVoteCounts(showError: false)),
    );
  }

  void _stopVoteCountPolling() {
    _voteCountTimer?.cancel();
    _voteCountTimer = null;
  }

  Future<void> _refreshVoteCounts({required bool showError}) async {
    if (!_canUpdateState) {
      return;
    }
    final String refreshErrorMessage = showError && _canUseContext
        ? AppLocalizations.of(context)!.onlineCountCouldNotRefreshVoteCount
        : '';
    final OnlineSession? session = _session;
    if (_voteCountRefreshInFlight || session == null || !_hasCloudSetup()) {
      return;
    }
    final String sessionId = session.id;
    _voteCountRefreshInFlight = true;
    if (showError) {
      setState(() => _busyAction = 'refreshVoteCount');
    }
    try {
      final OnlineResults results = await _api().getResults(
        sessionId: sessionId,
        adminPin: _adminPinController.text.trim(),
        ownerToken: _ownerToken,
      );
      if (!_canUpdateState || _session?.id != sessionId || !_hasCloudSetup()) {
        return;
      }
      setState(() {
        _voteTotalsByAwardType = buildAwardVoteTotals(results);
        _lastVoteCountRefreshAt = DateTime.now();
        _voteCountRefreshFailed = false;
      });
    } catch (_) {
      if (!_canUpdateState || _session?.id != sessionId || !_hasCloudSetup()) {
        return;
      }
      setState(() => _voteCountRefreshFailed = true);
      if (showError && refreshErrorMessage.isNotEmpty) {
        _showMessage(refreshErrorMessage);
      }
    } finally {
      _voteCountRefreshInFlight = false;
      if (_canUpdateState && showError && _busyAction == 'refreshVoteCount') {
        setState(() => _busyAction = null);
      }
    }
  }

  void _clearVoteCountState() {
    _voteTotalsByAwardType = <String, int>{};
    _lastVoteCountRefreshAt = null;
    _voteCountRefreshFailed = false;
  }

  void _replaceAward(OnlineAward updated) {
    if (!_canUpdateState) {
      return;
    }
    setState(() {
      _awards = _awards
          .map(
            (OnlineAward award) => award.id == updated.id ? updated : award,
          )
          .toList(growable: false);
    });
  }

  List<OnlineAward> _awardsForStatusRefresh({
    required String? sessionId,
    required String? previousSessionId,
    required List<OnlineAward> cloudAwards,
    required List<OnlineAward> storedAwards,
    required OnlineAward? activeAward,
  }) {
    if (sessionId == null || sessionId.isEmpty) {
      return <OnlineAward>[];
    }
    final List<OnlineAward> sameSessionAwards =
        sessionId == previousSessionId ? _awards : <OnlineAward>[];
    final List<OnlineAward> baseAwards = cloudAwards.isNotEmpty
        ? cloudAwards
        : storedAwards.isNotEmpty
            ? storedAwards
            : sameSessionAwards;
    if (activeAward == null || activeAward.sessionId != sessionId) {
      return baseAwards;
    }
    bool replaced = false;
    final List<OnlineAward> merged = baseAwards.map((OnlineAward award) {
      if (award.type != activeAward.type) {
        return award;
      }
      replaced = true;
      return activeAward;
    }).toList(growable: true);
    if (!replaced) {
      merged.add(activeAward);
    }
    return merged;
  }

  Future<void> _copyText(String text) async {
    if (!mounted) {
      return;
    }
    if (!_elementActive) {
      return;
    }
    final String copiedMessage =
        AppLocalizations.of(context)!.onlineCountCopied;
    await Clipboard.setData(ClipboardData(text: text));
    _showMessage(copiedMessage);
  }

  Future<void> _shareQrCode({required String url}) async {
    if (_busyAction != null ||
        url.isEmpty ||
        !_hasCloudSetup() ||
        !_canUseContext) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale locale = Localizations.localeOf(context);
    final String clubName = _clubNameController.text.trim();
    final String clubCode = _clubSlugController.text.trim();
    setState(() => _busyAction = 'shareQrCode');
    try {
      await shareVotingQrCode(
        url: url,
        clubName: clubName,
        clubCode: clubCode,
        languageCode: _QrLinkType.auto.name,
        shareText: buildVotingQrShareText(
          clubName: clubName,
          languageCode: locale.languageCode,
        ),
      );
      if (!_canUseContext) {
        return;
      }
      _showMessage(l10n.onlineCountQrReadyToShare);
    } catch (_) {
      if (!_canUseContext) {
        return;
      }
      _showMessage(l10n.onlineCountCouldNotShareQr);
    } finally {
      if (_canUpdateState) {
        setState(() => _busyAction = null);
      }
    }
  }

  Future<void> _copyResults() async {
    if (!_canUseContext) {
      return;
    }
    final OnlineResults? results = _results;
    if (results == null) {
      _showMessage(AppLocalizations.of(context)!.onlineCountNoResultsYet);
      return;
    }
    await _copyText(_buildOnlineResultsSummary(results));
  }

  Future<void> _sendResultsToPresident() async {
    if (!_canUseContext) {
      return;
    }
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
    if (!_canUseContext) {
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
    if (!_canUseContext) {
      return;
    }
    if (opened) {
      _showMessage(l10n.voteBestsWhatsAppOpened);
    } else {
      _copySummaryToClipboard(summary);
      if (_canUseContext) {
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
    if (!_elementActive) {
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

    if (input == null || !_canUseContext) {
      return;
    }
    final VoteResultsRecipient recipient =
        await widget.recipientRepository.save(
      name: input.name,
      phoneNumber: input.phoneNumber,
    );
    if (_canUpdateState) {
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
    setState(() {});
  }

  bool _hasCloudSetup() {
    return _baseUrlController.text.trim().isNotEmpty &&
        _clubNameController.text.trim().isNotEmpty &&
        _clubSlugController.text.trim().isNotEmpty &&
        _adminPinController.text.trim().isNotEmpty;
  }

  bool get _canCreateOnlineClub =>
      _baseUrlController.text.trim().isNotEmpty &&
      _clubNameController.text.trim().isNotEmpty;

  bool get _canCreateMeeting =>
      _hasCloudSetup() &&
      _session == null &&
      _meetingTitleController.text.trim().isNotEmpty &&
      _meetingDateController.text.trim().isNotEmpty;

  bool get _canOpenMeeting =>
      _session != null &&
      _session!.status == OnlineRoundStatus.draft &&
      _allAwardCandidatesSaved;

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

  bool get _allAwardCandidatesSaved {
    return OnlineAwardType.values.every((OnlineAwardType type) {
      final List<String> candidates = parseOnlineCandidateLines(
        _candidateControllers[type]?.text ?? '',
      );
      return candidates.isNotEmpty &&
          _savedCandidateFingerprints[type] ==
              _candidateFingerprint(candidates);
    });
  }

  bool _canEditCandidatesForAward(OnlineAward? award) {
    final OnlineSession? session = _session;
    if (session == null || session.status != OnlineRoundStatus.draft) {
      return false;
    }
    return award == null || award.status == OnlineRoundStatus.draft;
  }

  bool _hasCandidateLines(OnlineAwardType type) {
    return parseOnlineCandidateLines(
      _candidateControllers[type]?.text ?? '',
    ).isNotEmpty;
  }

  String _candidateFingerprint(List<String> candidates) {
    return candidates.join('\n');
  }

  List<OnlineAward> _awardsForVoteCountDisplay() {
    final OnlineSession? session = _session;
    if (_awards.isNotEmpty || session == null) {
      return _awards;
    }
    return <OnlineAward>[
      for (final OnlineAwardType type in OnlineAwardType.values)
        OnlineAward(
          id: '',
          sessionId: session.id,
          type: type,
          status: OnlineRoundStatus.draft,
        ),
    ];
  }

  int _voteCountForAward(OnlineAward award) {
    return _voteTotalsByAwardType[award.type.value] ?? 0;
  }

  bool get _hasOpenAward => _openAwardForDisplay() != null;

  OnlineAward? _openAwardForDisplay() {
    if (_activeAward != null) {
      return _activeAward;
    }
    for (final OnlineAward award in _awards) {
      if (award.status == OnlineRoundStatus.open) {
        return award;
      }
    }
    return null;
  }

  String _voteCountLabel(OnlineAward award, AppLocalizations l10n) {
    final int voteCount = _voteCountForAward(award);
    return switch (award.status) {
      OnlineRoundStatus.open =>
        '${l10n.onlineCountOpen} · ${l10n.onlineCountVotesReceived}: $voteCount',
      OnlineRoundStatus.closed => '${l10n.onlineCountFinalVotes}: $voteCount',
      OnlineRoundStatus.draft => '${l10n.onlineCountVotesReceived}: $voteCount',
    };
  }

  String _statusSummaryTitle(AppLocalizations l10n) {
    return switch (_uiState) {
      OnlineCountUiState.noOnlineClub => l10n.onlineCountCloudSetup,
      OnlineCountUiState.clubReadyNoMeeting => l10n.onlineCountCurrentStatus,
      OnlineCountUiState.meetingDraft => l10n.onlineCountCurrentStatus,
      OnlineCountUiState.meetingOpen => l10n.onlineCountMeetingOpenTitle,
      OnlineCountUiState.meetingClosed => l10n.onlineCountMeetingClosedTitle,
    };
  }

  List<String> _statusSummaryLines(AppLocalizations l10n) {
    final Locale locale = Localizations.localeOf(context);
    return switch (_uiState) {
      OnlineCountUiState.noOnlineClub => <String>[],
      OnlineCountUiState.clubReadyNoMeeting => <String>[
          '${l10n.onlineCountCurrentMeeting}: ${l10n.onlineCountNotCreated}',
          '${l10n.onlineCountNextStep}: ${l10n.onlineCountCreateCurrentMeeting}',
        ],
      OnlineCountUiState.meetingDraft => <String>[
          '${l10n.onlineCountCurrentMeeting}: ${_session?.meetingTitle ?? ''}',
          '${l10n.onlineCountNextStep}: ${l10n.onlineCountNextStepAddCandidates}',
        ],
      OnlineCountUiState.meetingOpen => <String>[
          '${l10n.onlineCountCurrentVote}: ${_currentVoteSummary(locale, l10n)}',
          '${l10n.onlineCountVotesReceived}: ${_currentVoteCount()}',
          '${l10n.onlineCountNextStep}: ${l10n.onlineCountNextStepCloseVoting}',
        ],
      OnlineCountUiState.meetingClosed => <String>[
          l10n.onlineCountResultsAreFinal,
          '${l10n.onlineCountNextStep}: ${l10n.onlineCountNextStepSendOrDelete}',
        ],
    };
  }

  String _currentVoteSummary(Locale locale, AppLocalizations l10n) {
    final OnlineAward? award = _openAwardForDisplay();
    if (award == null) {
      return l10n.onlineCountNotOpened;
    }
    return onlineAwardLabel(award.type, locale);
  }

  int _currentVoteCount() {
    final OnlineAward? award = _openAwardForDisplay();
    return award == null ? 0 : _voteCountForAward(award);
  }

  String _meetingHelperText(AppLocalizations l10n) {
    final OnlineSession? session = _session;
    if (session == null) {
      return l10n.onlineCountNoMeetingHelper;
    }
    return switch (session.status) {
      OnlineRoundStatus.draft => l10n.onlineCountDraftMeetingHelper,
      OnlineRoundStatus.open => l10n.onlineCountOpenMeetingHelper,
      OnlineRoundStatus.closed => l10n.onlineCountClosedMeetingHelper,
    };
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
    if (!_canUseContext) {
      return false;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _TypedConfirmationDialog(
        title: title,
        message: message,
        requiredText: requiredText,
        confirmationLabel: confirmationLabel,
      ),
    );
    return _canUseContext && confirmed == true;
  }

  void _showMessage(String message) {
    if (!_canUseContext) {
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
          _buildStatusSummaryCard(l10n),
          _buildLockedClubCard(l10n),
          _buildPermanentQrCard(l10n),
          _buildMeetingCard(l10n),
          _buildDangerZoneCard(l10n),
        ],
      OnlineCountUiState.meetingDraft => <Widget>[
          _buildStatusSummaryCard(l10n),
          _buildLockedClubCard(l10n),
          _buildPermanentQrCard(l10n),
          _buildMeetingCard(l10n),
          _buildCandidateSetupCard(l10n),
          _buildOpenMeetingCard(l10n),
          _buildDangerZoneCard(l10n),
        ],
      OnlineCountUiState.meetingOpen => <Widget>[
          _buildStatusSummaryCard(l10n),
          _buildLockedClubCard(l10n),
          _buildPermanentQrCard(l10n),
          _buildMeetingCard(l10n),
          _buildVotingRoundCard(l10n),
          _buildDangerZoneCard(l10n),
        ],
      OnlineCountUiState.meetingClosed => <Widget>[
          _buildStatusSummaryCard(l10n),
          _buildLockedClubCard(l10n),
          _buildPermanentQrCard(l10n),
          _buildMeetingCard(l10n),
          _buildResultsCard(l10n),
          _buildDangerZoneCard(l10n),
        ],
    };
  }

  Widget _buildStatusSummaryCard(AppLocalizations l10n) {
    return _SectionCard(
      title: _statusSummaryTitle(l10n),
      icon: Icons.flag_circle_outlined,
      children: <Widget>[
        _InfoBlock(lines: _statusSummaryLines(l10n)),
      ],
    );
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
      ],
    );
  }

  Widget _buildLockedClubCard(AppLocalizations l10n) {
    final String clubName = _clubNameController.text.trim();
    final String clubCode = _clubSlugController.text.trim();

    return _SectionCard(
      title: l10n.onlineCountClubReadyTitle,
      icon: Icons.verified_outlined,
      children: <Widget>[
        _InfoBlock(
          lines: <String>[
            '${l10n.onlineCountOnlineClubLabel}: $clubName',
            '${l10n.onlineCountClubCodeLabel}: $clubCode',
            l10n.onlineCountVotingLinkAvailableBelow,
            if (_legacyMultipleSessions) l10n.onlineCountLegacySessionsWarning,
            if (_activeAward != null)
              '${l10n.onlineCountVotingRound}: '
                  '${onlineAwardLabel(_activeAward!.type, Localizations.localeOf(context))}',
          ],
        ),
        const SizedBox(height: 12),
        _buttonWrap(
          <Widget>[
            OutlinedButton.icon(
              onPressed: _busyAction == 'deleteClub' ? null : _deleteOnlineClub,
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(l10n.onlineCountDeleteOnlineClub),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDangerZoneCard(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const Icon(Icons.warning_amber_outlined),
        title: Text(
          l10n.onlineCountDangerZone,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: <Widget>[
          _BodyText(l10n.onlineCountDangerZoneHelp),
          const SizedBox(height: 8),
          _fullWidthButton(
            child: OutlinedButton.icon(
              onPressed: _resetOnlineCountOnThisDevice,
              icon: const Icon(Icons.restart_alt_outlined),
              label: Text(l10n.onlineCountResetDeviceSetup),
            ),
          ),
          const SizedBox(height: 10),
          _fullWidthButton(
            child: OutlinedButton.icon(
              onPressed: _startFreshOnThisDevice,
              icon: const Icon(Icons.refresh_outlined),
              label: Text(l10n.onlineCountStartFreshDevice),
            ),
          ),
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text(
              l10n.onlineCountTechnicalSettings,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            children: <Widget>[
              _BodyText(l10n.onlineCountTechnicalSettingsHelp),
              const SizedBox(height: 8),
              _fullWidthButton(
                child: OutlinedButton.icon(
                  onPressed: _busyAction == 'checkStatus'
                      ? null
                      : () => _checkOnlineStatus(),
                  icon: const Icon(Icons.cloud_sync_outlined),
                  label: Text(l10n.onlineCountCheckOnlineStatus),
                ),
              ),
              const SizedBox(height: 8),
              _BodyText(l10n.onlineCountCheckOnlineStatusHelp),
              const SizedBox(height: 12),
              _textField(
                controller: _baseUrlController,
                label: l10n.onlineCountBackendUrl,
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(AppLocalizations l10n) {
    final Locale locale = Localizations.localeOf(context);
    return _SectionCard(
      title: l10n.onlineCountCurrentMeeting,
      icon: Icons.event_note_outlined,
      children: <Widget>[
        _BodyText(_meetingHelperText(l10n)),
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
            _session!.status == OnlineRoundStatus.open) ...<Widget>[
          const SizedBox(height: 10),
          _fullWidthButton(
            child: FilledButton.icon(
              onPressed: _canCloseMeeting && _busyAction != 'closeMeeting'
                  ? () => _closeMeeting()
                  : null,
              icon: const Icon(Icons.stop_circle_outlined),
              label: Text(l10n.onlineCountCloseMeeting),
            ),
          ),
        ],
        if (_session != null &&
            _session!.status != OnlineRoundStatus.closed) ...<Widget>[
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
          final bool canEdit = _canEditCandidatesForAward(award);
          final bool canSave = canEdit && _hasCandidateLines(type);
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
                        canSave && _busyAction != 'saveCandidates-${type.value}'
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

  Widget _buildOpenMeetingCard(AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.onlineCountReadyToStartVoting,
      icon: Icons.play_circle_outline,
      children: <Widget>[
        if (!_allAwardCandidatesSaved) ...<Widget>[
          _BodyText(l10n.onlineCountAddAllCandidatesBeforeOpening),
          const SizedBox(height: 8),
        ],
        _fullWidthButton(
          child: FilledButton.icon(
            onPressed: _canOpenMeeting && _busyAction != 'openMeeting'
                ? () => _openMeeting()
                : null,
            icon: const Icon(Icons.play_arrow_outlined),
            label: Text(l10n.onlineCountOpenMeeting),
          ),
        ),
      ],
    );
  }

  Widget _buildVotingRoundCard(AppLocalizations l10n) {
    final Locale locale = Localizations.localeOf(context);
    final List<OnlineAward> awards = _awardsForVoteCountDisplay();
    final bool hasOpenAward = _hasOpenAward;
    return _SectionCard(
      title: l10n.onlineCountVotingRound,
      icon: Icons.how_to_vote_outlined,
      children: <Widget>[
        _buttonWrap(
          <Widget>[
            OutlinedButton.icon(
              onPressed: _busyAction == 'refreshVoteCount'
                  ? null
                  : () => _refreshVoteCounts(showError: true),
              icon: const Icon(Icons.refresh_outlined),
              label: Text(l10n.onlineCountRefreshVoteCount),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _lastVoteCountRefreshAt == null
              ? l10n.onlineCountVoteCountsAutoRefresh
              : l10n.onlineCountVoteCountsLastUpdated,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        if (_voteCountRefreshFailed) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            l10n.onlineCountCouldNotRefreshVoteCount,
            style: const TextStyle(fontSize: 14, color: Colors.redAccent),
          ),
        ],
        const SizedBox(height: 12),
        if (awards.isEmpty)
          Text(
            l10n.onlineCountNoSessionYet,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          )
        else
          for (final OnlineAward award in awards)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: award.status == OnlineRoundStatus.open
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: award.status == OnlineRoundStatus.open
                        ? Colors.green.shade300
                        : Colors.black12,
                  ),
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
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.onlineCountAwardStatusLabel}: '
                        '${onlineStatusLabel(award.status, locale)}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _voteCountLabel(award, l10n),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: award.status == OnlineRoundStatus.open
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (award.status == OnlineRoundStatus.open)
                        _fullWidthButton(
                          child: FilledButton.icon(
                            onPressed: award.id.isNotEmpty &&
                                    _busyAction != 'closeAward-${award.id}'
                                ? () => _closeAward(award)
                                : null,
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: Text(l10n.onlineCountCloseVoting),
                          ),
                        )
                      else if (award.status == OnlineRoundStatus.draft)
                        _fullWidthButton(
                          child: FilledButton.icon(
                            onPressed:
                                _session?.status == OnlineRoundStatus.open &&
                                        !hasOpenAward &&
                                        award.id.isNotEmpty &&
                                        _busyAction != 'openAward-${award.id}'
                                    ? () => _openAward(award)
                                    : null,
                            icon: const Icon(Icons.play_arrow_outlined),
                            label: Text(l10n.onlineCountOpenVoting),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildPermanentQrCard(AppLocalizations l10n) {
    final String clubCode = _clubSlugController.text.trim();
    final String baseUrl = _baseUrlController.text.trim();
    final String url = _qrUrl(_QrLinkType.auto);

    return _SectionCard(
      title: l10n.onlineCountPermanentVotingQr,
      icon: Icons.qr_code_2_outlined,
      children: <Widget>[
        _BodyText(l10n.onlineCountPermanentVotingQrHelp),
        _BodyText(l10n.onlineCountQrScheduleShareHelp),
        _BodyText(l10n.onlineCountQrLifecycleReminder),
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
          const SizedBox(height: 8),
          _fullWidthButton(
            child: FilledButton.icon(
              onPressed: _busyAction == 'shareQrCode'
                  ? null
                  : () => _shareQrCode(url: url),
              icon: const Icon(Icons.ios_share_outlined),
              label: Text(l10n.onlineCountShareQrCode),
            ),
          ),
          const SizedBox(height: 10),
          _fullWidthButton(
            child: OutlinedButton.icon(
              onPressed: () => _copyText(url),
              icon: const Icon(Icons.copy_outlined),
              label: Text(l10n.onlineCountCopyQrLink),
            ),
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
        _BodyText(l10n.onlineCountClosedMeetingHelper),
        const SizedBox(height: 8),
        _fullWidthButton(
          child: FilledButton.icon(
            onPressed: _busyAction == 'refreshResults'
                ? null
                : () => _refreshResults(),
            icon: const Icon(Icons.refresh_outlined),
            label: Text(l10n.onlineCountRefreshResults),
          ),
        ),
        const SizedBox(height: 10),
        _fullWidthButton(
          child: OutlinedButton.icon(
            onPressed: _sendResultsToPresident,
            icon: const Icon(Icons.send_outlined),
            label: Text(l10n.voteBestsSendResultsToPresident),
          ),
        ),
        const SizedBox(height: 10),
        _fullWidthButton(
          child: OutlinedButton.icon(
            onPressed: _copyResults,
            icon: const Icon(Icons.copy_outlined),
            label: Text(l10n.onlineCountCopyResults),
          ),
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
        if (_session != null) ...<Widget>[
          const SizedBox(height: 4),
          _fullWidthButton(
            child: OutlinedButton.icon(
              onPressed:
                  _busyAction == 'deleteMeeting' ? null : _deleteCurrentMeeting,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.onlineCountDeleteCurrentMeeting),
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

  static String _todayText() {
    final DateTime now = DateTime.now();
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}

enum _QrLinkType { zh, en, auto }

class _TypedConfirmationDialog extends StatefulWidget {
  const _TypedConfirmationDialog({
    required this.title,
    required this.message,
    required this.requiredText,
    required this.confirmationLabel,
  });

  final String title;
  final String message;
  final String requiredText;
  final String confirmationLabel;

  @override
  State<_TypedConfirmationDialog> createState() =>
      _TypedConfirmationDialogState();
}

class _TypedConfirmationDialogState extends State<_TypedConfirmationDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canConfirm = _controller.text.trim() == widget.requiredText;
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.message),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: widget.confirmationLabel,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(materialLocalizations.cancelButtonLabel),
        ),
        FilledButton(
          onPressed: canConfirm ? () => Navigator.of(context).pop(true) : null,
          child: Text(materialLocalizations.okButtonLabel),
        ),
      ],
    );
  }
}

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
