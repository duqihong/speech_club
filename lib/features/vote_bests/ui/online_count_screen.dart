import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../l10n/app_localizations.dart';
import '../data/online_count/online_count_api.dart';
import '../data/online_count/online_count_models.dart';
import '../data/online_count/online_count_storage.dart';

class OnlineCountScreen extends StatefulWidget {
  const OnlineCountScreen({super.key});

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
  String? _busyAction;
  String _lastGeneratedClubCode = '';
  bool _clubCodeManuallyEdited = false;
  bool _clubCreated = false;
  bool _loaded = false;
  _QrLinkType? _selectedQrType;

  @override
  void initState() {
    super.initState();
    _meetingDateController.text = _todayText();
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
      if (setup.currentSessionId.isNotEmpty) {
        _session = OnlineSession(
          id: setup.currentSessionId,
          clubId: '',
          meetingTitle: _meetingTitleController.text,
          meetingDate: _meetingDateController.text,
          status: OnlineRoundStatus.draft,
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
      await _api().createClub(
        clubName: _clubNameController.text.trim(),
        clubSlug: _clubSlugController.text.trim(),
        adminPin: _adminPinController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() => _clubCreated = true);
      await _saveSetup(showMessage: false);
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
      final OnlineSession session = await _api().createSession(
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
      );
      if (!mounted) {
        return;
      }
      setState(() => _session = updated.copyWith(awards: _awards));
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
      );
      _replaceAward(updated);
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
      );
      _replaceAward(updated);
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
    await _copyText(
        _buildResultsText(results, Localizations.localeOf(context)));
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

  bool get _canSaveSetup => _hasCloudSetup();

  bool get _canCreateOnlineClub => _hasCloudSetup();

  bool get _canCreateMeeting =>
      _hasCloudSetup() &&
      _meetingTitleController.text.trim().isNotEmpty &&
      _meetingDateController.text.trim().isNotEmpty;

  bool get _canOpenMeeting =>
      _session != null && _session!.status == OnlineRoundStatus.draft;

  bool get _canCloseMeeting =>
      _session != null && _session!.status == OnlineRoundStatus.open;

  OnlineAward? _awardForType(OnlineAwardType type) {
    for (final OnlineAward award in _awards) {
      if (award.type == type) {
        return award;
      }
    }
    return null;
  }

  String _friendlyError(OnlineCountApiException error, AppLocalizations l10n) {
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
          children: <Widget>[
            _buildCloudSetupCard(l10n),
            _buildMeetingCard(l10n),
            _buildCandidateSetupCard(l10n),
            _buildVotingRoundCard(l10n),
            _buildPermanentQrCard(l10n),
            _buildVotingLinkCard(l10n),
            _buildResultsCard(l10n),
          ],
        ),
      ),
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
          child: FilledButton.icon(
            onPressed: _canSaveSetup ? () => _saveSetup() : null,
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.onlineCountSaveSetup),
          ),
        ),
        const SizedBox(height: 10),
        _fullWidthButton(
          child: OutlinedButton.icon(
            onPressed: _canCreateOnlineClub && _busyAction != 'createClub'
                ? () => _createClub()
                : null,
            icon: const Icon(Icons.add_business_outlined),
            label: Text(l10n.onlineCountCreateClub),
          ),
        ),
        const SizedBox(height: 14),
        _buildSetupStatus(l10n),
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

  Widget _buildMeetingCard(AppLocalizations l10n) {
    final Locale locale = Localizations.localeOf(context);
    return _SectionCard(
      title: l10n.onlineCountCurrentMeeting,
      icon: Icons.event_note_outlined,
      children: <Widget>[
        _BodyText(l10n.onlineCountMeetingExplanation),
        const SizedBox(height: 10),
        _MeetingGuide(l10n: l10n),
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
        if (_session == null)
          Text(
            l10n.onlineCountNoSessionYet,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          )
        else
          _InfoBlock(
            lines: <String>[
              '${l10n.onlineCountSessionStatus}: '
                  '${_sessionStatusLabel(_session!.status, locale)}',
              _sessionStatusHelp(_session!.status, l10n),
            ],
          ),
        const SizedBox(height: 10),
        _fullWidthButton(
          child: FilledButton.icon(
            onPressed: _canCreateMeeting && _busyAction != 'createMeeting'
                ? () => _createMeeting()
                : null,
            icon: const Icon(Icons.add_circle_outline),
            label: Text(l10n.onlineCountCreateMeeting),
          ),
        ),
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
              onPressed: _copyResults,
              icon: const Icon(Icons.copy_outlined),
              label: Text(l10n.onlineCountCopyResults),
            ),
          ],
        ),
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

  Widget _buildSetupStatus(AppLocalizations l10n) {
    final String clubName = _clubNameController.text.trim();
    final String clubCode = _clubSlugController.text.trim();
    if (clubName.isEmpty && clubCode.isEmpty) {
      return const SizedBox.shrink();
    }
    return _InfoBlock(
      lines: <String>[
        if (clubName.isNotEmpty)
          '${l10n.onlineCountOnlineClubLabel}: $clubName',
        if (clubCode.isNotEmpty) '${l10n.onlineCountClubCodeLabel}: $clubCode',
        _clubCreated
            ? l10n.onlineCountClubReady
            : l10n.onlineCountLinkReadyAfterCreate,
      ],
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

  String _buildResultsText(OnlineResults results, Locale locale) {
    final bool isChinese = locale.languageCode == 'zh';
    final List<String> sections = <String>[
      isChinese ? '演讲俱乐部在线投票结果' : 'Speech Club Online Voting Results',
      results.isFinal
          ? (isChinese ? '最终结果' : 'Final results')
          : (isChinese ? '结果尚未最终确认' : 'Results are not final yet'),
    ];

    for (final OnlineAwardResult award in results.awards) {
      final List<String> lines = <String>[
        onlineAwardLabel(award.type, locale),
      ];
      if (award.winners.isEmpty) {
        lines.add(isChinese ? '还没有计票。' : 'No votes counted yet.');
      } else if (award.hasTie) {
        final String names = award.winners
            .map((OnlineCandidateResult candidate) => candidate.name)
            .join(isChinese ? '、' : ', ');
        lines.add(isChinese ? '并列：$names' : 'Tie: $names');
      } else {
        lines.add(
          isChinese
              ? '获奖者：${award.winners.single.name}'
              : 'Winner: ${award.winners.single.name}',
        );
      }
      lines.add(isChinese ? '全部票数：' : 'All votes:');
      for (final OnlineCandidateResult candidate in award.candidates) {
        lines.add(
          isChinese
              ? '- ${candidate.name}：${candidate.voteCount} 票'
              : '- ${candidate.name}: ${candidate.voteCount} votes',
        );
      }
      sections.add(lines.join('\n'));
    }
    return sections.join('\n\n');
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

class _MeetingGuide extends StatelessWidget {
  const _MeetingGuide({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _GuideStep(
              title: l10n.onlineCountMeetingStep1Title,
              body: l10n.onlineCountMeetingStep1Body,
            ),
            _GuideStep(
              title: l10n.onlineCountMeetingStep2Title,
              body: l10n.onlineCountMeetingStep2Body,
            ),
            _GuideStep(
              title: l10n.onlineCountMeetingStep3Title,
              body: l10n.onlineCountMeetingStep3Body,
            ),
            _GuideStep(
              title: l10n.onlineCountMeetingStep4Title,
              body: l10n.onlineCountMeetingStep4Body,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            body,
            style: const TextStyle(color: Colors.black54, height: 1.25),
          ),
        ],
      ),
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
