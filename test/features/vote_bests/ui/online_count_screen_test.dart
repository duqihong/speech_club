import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_api.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_models.dart';
import 'package:speech_club/features/vote_bests/data/vote_results_recipient_repository.dart';
import 'package:speech_club/features/vote_bests/ui/online_count_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpOnlineCountScreen(
    WidgetTester tester, {
    List<OnlineAward> debugInitialAwards = const <OnlineAward>[],
    Locale? locale,
    TextScaler? textScaler,
    OnlineCountApi? api,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: textScaler == null
            ? null
            : (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: child!,
                );
              },
        home: OnlineCountScreen(
          api: api,
          debugInitialAwards: debugInitialAwards,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder textFieldWithLabel(String label) {
    return find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField && widget.decoration?.labelText == label,
    );
  }

  Finder awardCard(String suffix) {
    return find.byKey(ValueKey<String>('onlineAwardCard_$suffix'));
  }

  Finder awardControl(String control, String suffix) {
    return find.byKey(ValueKey<String>('onlineAward${control}_$suffix'));
  }

  Future<void> scrollToAward(
    WidgetTester tester,
    String suffix,
  ) async {
    if (awardCard(suffix).evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('onlineAwardManagement')),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(
      awardCard(suffix),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollToTop(WidgetTester tester) async {
    for (int index = 0; index < 3; index += 1) {
      await tester.drag(
        find.byType(Scrollable).first,
        const Offset(0, 1200),
      );
      await tester.pumpAndSettle();
    }
  }

  Future<void> revealAwardControl(
    WidgetTester tester, {
    required String suffix,
    required String awardLabel,
    required Finder control,
  }) async {
    await scrollToAward(tester, suffix);
    if (control.evaluate().isEmpty) {
      await tester.tap(
        find.descendant(
          of: awardCard(suffix),
          matching: find.text(awardLabel),
        ),
      );
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(control);
    await tester.pumpAndSettle();
  }

  Future<void> openDangerZone(
    WidgetTester tester, {
    String? actionLabel,
  }) async {
    await tester.scrollUntilVisible(
      find.text('Manage & Reset'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manage & Reset'));
    await tester.pumpAndSettle();
    if (actionLabel != null) {
      await tester.scrollUntilVisible(
        find.text(actionLabel),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }
  }

  Future<void> openAdvancedSettings(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Advanced Settings'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advanced Settings'));
    await tester.pumpAndSettle();
  }

  Future<void> openTechnicalSettings(WidgetTester tester) async {
    await openDangerZone(tester);
    await tester.scrollUntilVisible(
      find.text('Technical Settings'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technical Settings'));
    await tester.pumpAndSettle();
  }

  Map<String, Object> savedClubPrefs({
    bool withSession = false,
    String sessionStatus = 'draft',
    String sessionTitle = 'Regular Meeting',
    String? formMeetingTitle,
  }) {
    return <String, Object>{
      'speech_club_online_owner_token_v1': 'owner-token',
      'speech_club_online_base_url_v1':
          'https://speech-club-vote.duduqihong.workers.dev',
      'speech_club_online_club_name_v1': 'Demo Club',
      'speech_club_online_club_slug_v1': 'demo-club',
      'speech_club_online_admin_pin_v1': '123456',
      if (formMeetingTitle != null)
        'speech_club_online_current_session_title_v1': formMeetingTitle,
      if (withSession) ...<String, Object>{
        'speech_club_online_current_session_id_v1': 'session-1',
        'speech_club_online_current_session_title_v1': sessionTitle,
        'speech_club_online_current_session_date_v1': '2026-06-26',
        'speech_club_online_current_session_status_v1': sessionStatus,
      },
    };
  }

  Map<String, Object> candidateDraftPrefs({
    String sessionId = 'session-1',
    String bestSpeaker = 'Alice',
    String bestTableTopics = 'Cara',
    String bestEvaluator = 'Eva',
  }) {
    return <String, Object>{
      'speech_club_online_candidate_draft_${sessionId}_best_speaker_v1':
          bestSpeaker,
      'speech_club_online_candidate_draft_${sessionId}_best_table_topics_v1':
          bestTableTopics,
      'speech_club_online_candidate_draft_${sessionId}_best_evaluator_v1':
          bestEvaluator,
    };
  }

  Map<String, Object> candidateSavedPrefs({
    String sessionId = 'session-1',
    String bestSpeaker = 'Alice',
    String bestTableTopics = 'Cara',
    String bestEvaluator = 'Eva',
  }) {
    return <String, Object>{
      'speech_club_online_candidate_saved_text_${sessionId}_best_speaker_v1':
          bestSpeaker,
      'speech_club_online_candidate_saved_text_${sessionId}_best_table_topics_v1':
          bestTableTopics,
      'speech_club_online_candidate_saved_text_${sessionId}_best_evaluator_v1':
          bestEvaluator,
    };
  }

  Map<String, Object> awardStatePrefs({
    String sessionId = 'session-1',
    String bestSpeakerStatus = 'draft',
    String bestTableTopicsStatus = 'draft',
    String bestEvaluatorStatus = 'draft',
  }) {
    return <String, Object>{
      'speech_club_online_award_id_${sessionId}_best_speaker_v1': 'award-1',
      'speech_club_online_award_status_${sessionId}_best_speaker_v1':
          bestSpeakerStatus,
      'speech_club_online_award_id_${sessionId}_best_table_topics_v1':
          'award-2',
      'speech_club_online_award_status_${sessionId}_best_table_topics_v1':
          bestTableTopicsStatus,
      'speech_club_online_award_id_${sessionId}_best_evaluator_v1': 'award-3',
      'speech_club_online_award_status_${sessionId}_best_evaluator_v1':
          bestEvaluatorStatus,
    };
  }

  List<OnlineAward> debugAwardsForSession() {
    return const <OnlineAward>[
      OnlineAward(
        id: 'award-1',
        sessionId: 'session-1',
        type: OnlineAwardType.bestSpeaker,
        status: OnlineRoundStatus.open,
      ),
      OnlineAward(
        id: 'award-2',
        sessionId: 'session-1',
        type: OnlineAwardType.bestTableTopics,
        status: OnlineRoundStatus.draft,
      ),
      OnlineAward(
        id: 'award-3',
        sessionId: 'session-1',
        type: OnlineAwardType.bestEvaluator,
        status: OnlineRoundStatus.closed,
      ),
    ];
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('no club shows setup mode only and hides backend URL',
      (WidgetTester tester) async {
    await pumpOnlineCountScreen(
      tester,
      debugInitialAwards: debugAwardsForSession(),
    );

    expect(find.text('Online Club Setup'), findsOneWidget);
    expect(find.text('Create Online Club'), findsOneWidget);
    expect(textFieldWithLabel('Club Name'), findsOneWidget);
    expect(textFieldWithLabel('Club Code'), findsNothing);
    expect(textFieldWithLabel('Admin PIN'), findsNothing);
    expect(find.text('Current Meeting'), findsNothing);
    expect(find.text('Permanent Voting QR'), findsNothing);
    expect(find.text('Share QR Code'), findsNothing);
    expect(find.text('Results'), findsNothing);
    expect(find.text('Danger Zone'), findsNothing);
    expect(find.text('Manage & Reset'), findsNothing);
    expect(find.text('Advanced Settings'), findsOneWidget);
    expect(find.text('Backend URL'), findsNothing);
    expect(find.text('Start Fresh on This Device'), findsNothing);
    expect(find.text('Reset Online Count on This Device'), findsNothing);

    await openAdvancedSettings(tester);
    expect(
      find.text(
        'Use this only if online setup is stuck or this device already has an old online club.',
      ),
      findsOneWidget,
    );
    expect(find.text('Backend URL'), findsOneWidget);
    expect(find.text('Start Fresh on This Device'), findsOneWidget);
    expect(find.text('Reset Online Count on This Device'), findsNothing);
  });

  test('online count UI state helper maps saved setup and meeting status', () {
    expect(
      resolveOnlineCountUiState(hasOnlineClub: false),
      OnlineCountUiState.noOnlineClub,
    );
    expect(
      resolveOnlineCountUiState(hasOnlineClub: true),
      OnlineCountUiState.clubReadyNoMeeting,
    );
    expect(
      resolveOnlineCountUiState(
        hasOnlineClub: true,
        sessionStatus: OnlineRoundStatus.draft,
      ),
      OnlineCountUiState.meetingDraft,
    );
    expect(
      resolveOnlineCountUiState(
        hasOnlineClub: true,
        sessionStatus: OnlineRoundStatus.open,
      ),
      OnlineCountUiState.meetingOpen,
    );
    expect(
      resolveOnlineCountUiState(
        hasOnlineClub: true,
        sessionStatus: OnlineRoundStatus.closed,
      ),
      OnlineCountUiState.meetingClosed,
    );
  });

  testWidgets('saved club shows locked summary and no editable setup fields',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(tester);

    expect(find.text('Current Status'), findsNothing);
    expect(find.text('Online Club Ready'), findsOneWidget);
    expect(find.text('Next step: Create Current Meeting'), findsWidgets);
    expect(find.text('Club: Demo Club'), findsOneWidget);
    expect(find.text('Club code: demo-club'), findsNothing);
    expect(find.text('Voting QR is ready below.'), findsNothing);
    expect(
      find.text(
        'Voting Link: https://speech-club-vote.duduqihong.workers.dev/c/demo-club',
      ),
      findsNothing,
    );
    expect(find.text('Check Online Status'), findsNothing);
    expect(find.text('Delete Online Club'), findsNothing);
    expect(textFieldWithLabel('Club Name'), findsNothing);
    expect(textFieldWithLabel('Club Code'), findsNothing);
    expect(textFieldWithLabel('Admin PIN'), findsNothing);
    expect(find.text('Backend URL'), findsNothing);

    expect(find.text('Reset Online Count on This Device'), findsNothing);
    expect(find.text('Start Fresh on This Device'), findsNothing);
    expect(find.text('Advanced Settings'), findsNothing);
    expect(find.text('Danger Zone'), findsNothing);
    expect(find.text('Manage & Reset'), findsNothing);

    await openDangerZone(tester, actionLabel: 'Start Fresh on This Device');
    expect(find.text('Manage & Reset'), findsOneWidget);
    expect(find.text('Danger Zone'), findsNothing);
    expect(
      find.text(
        'Use these options only if setup is wrong or you need to reset online voting.',
      ),
      findsOneWidget,
    );
    expect(find.text('Delete Online Club'), findsOneWidget);
    expect(find.text('Reset Online Count on This Device'), findsNothing);
    expect(find.text('Start Fresh on This Device'), findsOneWidget);
    expect(find.text('Technical Settings'), findsOneWidget);
  });

  testWidgets('check online status lives under technical settings',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(tester);

    expect(find.text('Check Online Status'), findsNothing);

    await openTechnicalSettings(tester);

    expect(find.text('Check Online Status'), findsOneWidget);
    expect(find.text('Copy Voting Link'), findsOneWidget);
    expect(find.text('Club code: demo-club'), findsOneWidget);
    expect(
      find.text(
        'The voting page follows each voter’s phone language.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Use this only if the screen looks out of sync with online voting.',
      ),
      findsOneWidget,
    );
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('saved club with no session shows no current meeting',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(
      tester,
      debugInitialAwards: debugAwardsForSession(),
    );

    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('No current meeting'), findsOneWidget);
    expect(
      find.text('Next step: Create Current Meeting'),
      findsOneWidget,
    );
    expect(find.text('Create Current Meeting'), findsOneWidget);
    expect(find.text('Candidate Setup'), findsNothing);
    expect(find.text('Results'), findsNothing);
  });

  testWidgets('English no-session meeting form defaults to Regular Meeting',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(tester);
    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final TextField titleField = tester.widget<TextField>(
      textFieldWithLabel('Meeting Title'),
    );
    expect(titleField.controller!.text, 'Regular Meeting');
  });

  testWidgets('Chinese no-session meeting form defaults to localized title',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(tester, locale: const Locale('zh'));
    await tester.scrollUntilVisible(
      find.text('当前会议'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final TextField titleField = tester.widget<TextField>(
      textFieldWithLabel('会议名称'),
    );
    expect(titleField.controller!.text, '例会');
    expect(find.text('Regular Meeting'), findsNothing);
  });

  testWidgets('Chinese no-session form keeps user-edited meeting title',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
      savedClubPrefs(formMeetingTitle: 'Regular Meeting of Minister'),
    );

    await pumpOnlineCountScreen(tester, locale: const Locale('zh'));
    await tester.scrollUntilVisible(
      find.text('当前会议'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final TextField titleField = tester.widget<TextField>(
      textFieldWithLabel('会议名称'),
    );
    expect(titleField.controller!.text, 'Regular Meeting of Minister');
  });

  testWidgets('draft current meeting blocks create and hides results',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(withSession: true),
      ...awardStatePrefs(),
    });

    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Status: Preparing'), findsOneWidget);
    expect(
      find.text('Next step: Add candidates for an award'),
      findsOneWidget,
    );
    expect(find.text('Current Status'), findsNothing);
    expect(find.text('Meeting is prepared, but voting is not open yet.'),
        findsNothing);
    expect(find.text('Delete Current Meeting'), findsNothing);
    expect(find.text('Create Current Meeting'), findsNothing);
    expect(find.text('Candidate Setup'), findsNothing);
    expect(find.text('Voting Round'), findsNothing);
    expect(find.text('Award Management'), findsOneWidget);
    expect(awardCard('bestSpeaker'), findsOneWidget);
    expect(awardCard('tableTopics'), findsOneWidget);
    expect(awardCard('evaluator'), findsOneWidget);
    expect(find.text('Add candidates'), findsNWidgets(3));
    final TextField speakerField = tester.widget<TextField>(
      awardControl('Candidates', 'bestSpeaker'),
    );
    expect(speakerField.enabled, isTrue);
    expect(speakerField.controller!.text, isEmpty);
    expect(awardControl('Open', 'bestSpeaker'), findsNothing);
    for (final String sampleName in <String>[
      'Alice',
      'Bob',
      'Charlie',
      'David',
      'Eva',
      'Frank',
      'Grace',
      'Helen',
      'Ivan',
    ]) {
      expect(find.text(sampleName), findsNothing);
    }
    await scrollToTop(tester);
    expect(find.text('Ready for award voting?'), findsOneWidget);
    expect(
      find.text(
        'Save candidates for at least one award before opening the voting '
        'session. You can add other awards later.',
      ),
      findsOneWidget,
    );
    final FilledButton openMeetingButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Open Voting Session'),
    );
    expect(openMeetingButton.onPressed, isNull);
    expect(find.text('Open Meeting'), findsNothing);
    expect(find.text('Results'), findsNothing);
  });

  testWidgets('Chinese draft Online Count uses evaluator wording',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(withSession: true),
      ...awardStatePrefs(),
    });

    await pumpOnlineCountScreen(tester, locale: const Locale('zh'));

    await tester.scrollUntilVisible(
      find.text('奖项管理'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('候选人设置'), findsNothing);
    expect(find.text('投票轮次'), findsNothing);
    expect(find.text('奖项管理'), findsOneWidget);
    await scrollToAward(tester, 'evaluator');
    expect(find.text('最佳评论员'), findsOneWidget);
    expect(find.text('添加候选人'), findsWidgets);
    expect(find.text('最佳点评者'), findsNothing);
    expect(find.text('保存点评候选人'), findsNothing);
    expect(tester.takeException(), isNull);

    await scrollToTop(tester);

    expect(
      find.text(
        '请先为至少一个奖项保存候选人，再开启投票。其他奖项的候选人可以稍后添加。',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Chinese award cards fit iPhone 11 with enlarged text',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.open.value,
      ),
      ...candidateDraftPrefs(),
      ...candidateSavedPrefs(),
      ...awardStatePrefs(),
    });

    await pumpOnlineCountScreen(
      tester,
      locale: const Locale('zh'),
      textScaler: const TextScaler.linear(1.5),
    );
    await scrollToAward(tester, 'bestSpeaker');

    expect(find.text('奖项管理'), findsOneWidget);
    expect(find.text('已准备'), findsNWidgets(3));
    expect(find.text('编辑候选人'), findsOneWidget);
    expect(find.text('开放投票'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'draft candidates restore from local draft storage and stay editable',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(withSession: true),
      'speech_club_online_candidate_draft_session-1_best_speaker_v1':
          'Alice\nBen',
      'speech_club_online_candidate_draft_session-1_best_table_topics_v1':
          'Cara',
      'speech_club_online_candidate_draft_session-1_best_evaluator_v1': 'Eva',
      ...awardStatePrefs(),
    });

    await pumpOnlineCountScreen(tester);

    await scrollToAward(tester, 'bestSpeaker');
    expect(find.text('Unsaved changes'), findsNWidgets(3));
    final Finder speakerCandidates = awardControl(
      'Candidates',
      'bestSpeaker',
    );
    await revealAwardControl(
      tester,
      suffix: 'bestSpeaker',
      awardLabel: 'Best Speaker',
      control: speakerCandidates,
    );
    final TextField speakerField = tester.widget<TextField>(speakerCandidates);
    expect(speakerField.controller!.text, 'Alice\nBen');
    expect(speakerField.enabled, isTrue);
    final OutlinedButton saveSpeakerButton = tester.widget<OutlinedButton>(
      awardControl('Save', 'bestSpeaker'),
    );
    expect(saveSpeakerButton.onPressed, isNotNull);
  });

  testWidgets('typing candidate text persists after rebuilding screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(withSession: true),
      ...awardStatePrefs(),
    });

    await pumpOnlineCountScreen(tester);
    await scrollToAward(tester, 'bestSpeaker');
    await tester.enterText(
      awardControl('Candidates', 'bestSpeaker'),
      'Alice',
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await pumpOnlineCountScreen(tester);
    await scrollToAward(tester, 'bestSpeaker');

    expect(find.text('Alice'), findsOneWidget);
    final OutlinedButton saveSpeakerButton = tester.widget<OutlinedButton>(
      awardControl('Save', 'bestSpeaker'),
    );
    expect(saveSpeakerButton.onPressed, isNotNull);
  });

  testWidgets(
      'only Best Speaker saved enables Open Voting Session after rebuild',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(withSession: true),
      ...candidateDraftPrefs(bestTableTopics: '', bestEvaluator: ''),
      ...candidateSavedPrefs(bestTableTopics: '', bestEvaluator: ''),
      ...awardStatePrefs(),
    });

    await pumpOnlineCountScreen(tester);
    await scrollToAward(tester, 'bestSpeaker');
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(awardControl('Edit', 'bestSpeaker'), findsOneWidget);
    final FilledButton draftOpenButton = tester.widget<FilledButton>(
      awardControl('Open', 'bestSpeaker'),
    );
    expect(draftOpenButton.onPressed, isNull);
    expect(find.text('Add candidates'), findsNWidgets(2));

    await scrollToTop(tester);

    FilledButton openMeetingButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Open Voting Session'),
    );
    expect(openMeetingButton.onPressed, isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await pumpOnlineCountScreen(tester);

    openMeetingButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Open Voting Session'),
    );
    expect(openMeetingButton.onPressed, isNotNull);
  });

  testWidgets('editing the only ready award disables Open Voting Session',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(withSession: true),
      ...candidateDraftPrefs(bestTableTopics: '', bestEvaluator: ''),
      ...candidateSavedPrefs(bestTableTopics: '', bestEvaluator: ''),
      ...awardStatePrefs(),
    });

    await pumpOnlineCountScreen(tester);
    await scrollToAward(tester, 'bestSpeaker');
    await tester.tap(awardControl('Edit', 'bestSpeaker'));
    await tester.pumpAndSettle();
    final Finder speakerCandidates = awardControl('Candidates', 'bestSpeaker');
    expect(
      tester.widget<TextField>(speakerCandidates).controller!.text,
      'Alice',
    );

    await tester.enterText(
      speakerCandidates,
      'Alice\nBen',
    );
    await tester.pumpAndSettle();
    expect(find.text('Unsaved changes'), findsOneWidget);
    await scrollToTop(tester);

    final FilledButton openMeetingButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Open Voting Session'),
    );
    expect(openMeetingButton.onPressed, isNull);
    expect(
      find.text(
        'Save candidates for at least one award before opening the voting '
        'session. You can add other awards later.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('saving candidate edits restores compact Ready state',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(withSession: true),
      ...candidateDraftPrefs(bestTableTopics: '', bestEvaluator: ''),
      ...candidateSavedPrefs(bestTableTopics: '', bestEvaluator: ''),
      ...awardStatePrefs(),
    });
    final OnlineCountApi api = OnlineCountApi(
      baseUrl: 'https://example.com',
      client: MockClient((http.Request request) async {
        expect(request.url.path, '/api/admin/session/session-1/candidates');
        return http.Response(
          '{"ok":true,"candidates":['
          '{"candidateId":"candidate-1","awardId":"award-1",'
          '"candidateName":"Alice"},'
          '{"candidateId":"candidate-2","awardId":"award-1",'
          '"candidateName":"Ben"}]}',
          200,
        );
      }),
    );

    await pumpOnlineCountScreen(tester, api: api);
    await scrollToAward(tester, 'bestSpeaker');
    await tester.tap(awardControl('Edit', 'bestSpeaker'));
    await tester.pumpAndSettle();
    await tester.enterText(
      awardControl('Candidates', 'bestSpeaker'),
      'Alice\nBen',
    );
    await tester.pumpAndSettle();

    expect(find.text('Unsaved changes'), findsOneWidget);
    await tester.tap(awardControl('Save', 'bestSpeaker'));
    await tester.pumpAndSettle();

    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Alice · Ben'), findsOneWidget);
    expect(awardControl('Candidates', 'bestSpeaker'), findsNothing);
    expect(awardControl('Edit', 'bestSpeaker'), findsOneWidget);
    await scrollToTop(tester);
    final FilledButton openMeetingButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Open Voting Session'),
    );
    expect(openMeetingButton.onPressed, isNotNull);
  });

  testWidgets('one ready award still allows opening when another is edited',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(withSession: true),
      ...candidateDraftPrefs(),
      ...candidateSavedPrefs(),
      ...awardStatePrefs(),
    });

    await pumpOnlineCountScreen(tester);
    await scrollToAward(tester, 'bestSpeaker');
    await tester.tap(awardControl('Edit', 'bestSpeaker'));
    await tester.pumpAndSettle();

    await tester.enterText(
      awardControl('Candidates', 'bestSpeaker'),
      'Alice\nBen',
    );
    await tester.pumpAndSettle();
    await scrollToTop(tester);

    final FilledButton openMeetingButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Open Voting Session'),
    );
    expect(openMeetingButton.onPressed, isNotNull);
    expect(
      find.text(
        'Save candidates for at least one award before opening the voting '
        'session. You can add other awards later.',
      ),
      findsNothing,
    );
  });

  testWidgets('open current meeting keeps per-award candidate setup visible',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.open.value,
      ),
      ...candidateDraftPrefs(
        bestSpeaker: 'Alice',
        bestTableTopics: 'Cara',
        bestEvaluator: 'Eva',
      ),
      ...candidateSavedPrefs(
        bestSpeaker: 'Alice',
        bestTableTopics: '',
        bestEvaluator: 'Eva',
      ),
    });

    await pumpOnlineCountScreen(
      tester,
      debugInitialAwards: debugAwardsForSession(),
    );

    expect(find.text('Current Status', skipOffstage: false), findsNothing);
    expect(find.text('Meeting Open', skipOffstage: false), findsNothing);
    expect(find.text('Current vote: Best Speaker'), findsNothing);
    expect(
      find.text('Next step: Best Speaker voting is currently open'),
      findsWidgets,
    );
    expect(find.text('Open Meeting', skipOffstage: false), findsNothing);
    expect(find.text('Close Meeting', skipOffstage: false), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Status: Voting Session Open'), findsWidgets);
    expect(find.text('Close Voting Session'), findsOneWidget);
    expect(find.text('Create Current Meeting'), findsNothing);
    expect(find.text('Candidate Setup'), findsNothing);
    expect(find.text('Voting Round'), findsNothing);
    expect(find.text('Award Management'), findsOneWidget);
    expect(awardCard('bestSpeaker'), findsOneWidget);
    expect(awardCard('tableTopics'), findsOneWidget);
    expect(awardCard('evaluator'), findsOneWidget);
    expect(find.text('Voting open'), findsOneWidget);
    expect(find.text('Unsaved changes'), findsOneWidget);
    expect(find.text('Voting closed'), findsOneWidget);
    expect(awardControl('Candidates', 'bestSpeaker'), findsNothing);
    expect(awardControl('Candidates', 'evaluator'), findsNothing);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Votes received: 0'), findsOneWidget);
    final FilledButton closeVotingButton = tester.widget<FilledButton>(
      awardControl('Close', 'bestSpeaker'),
    );
    expect(closeVotingButton.onPressed, isNotNull);
    final OutlinedButton refreshVoteCountButton = tester.widget<OutlinedButton>(
      awardControl('Refresh', 'bestSpeaker'),
    );
    expect(refreshVoteCountButton.onPressed, isNotNull);

    await revealAwardControl(
      tester,
      suffix: 'tableTopics',
      awardLabel: 'Best Table Topics Speaker',
      control: awardControl('Candidates', 'tableTopics'),
    );
    final TextField tableTopicsField = tester.widget<TextField>(
      awardControl('Candidates', 'tableTopics'),
    );
    expect(tableTopicsField.enabled, isTrue);
    expect(tableTopicsField.controller!.text, 'Cara');
    final OutlinedButton tableTopicsSaveButton = tester.widget<OutlinedButton>(
      awardControl('Save', 'tableTopics'),
    );
    expect(tableTopicsSaveButton.onPressed, isNotNull);

    expect(find.text('Open · Votes received: 0'), findsNothing);
    expect(find.text('Status: Open'), findsNothing);
    expect(find.text('Final votes: 0'), findsOneWidget);
    expect(find.text('Results'), findsNothing);
  });

  testWidgets('open meeting with no ready award prompts for first candidates',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.open.value,
      ),
      ...awardStatePrefs(),
    });

    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Status: Voting Session Open'), findsOneWidget);
    expect(
      find.text('Next step: Add candidates for Best Speaker'),
      findsWidgets,
    );

    await scrollToAward(tester, 'bestSpeaker');
    expect(find.text('Award Management'), findsOneWidget);
    expect(find.text('Add candidates'), findsNWidgets(3));
    expect(awardControl('Candidates', 'bestSpeaker'), findsOneWidget);
    expect(awardControl('Open', 'bestSpeaker'), findsNothing);
    expect(find.text('Refresh Vote Count'), findsNothing);
  });

  testWidgets('restored open meeting enables only its ready draft award',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.open.value,
      ),
      ...candidateDraftPrefs(
        bestSpeaker: '',
        bestTableTopics: 'Cara',
        bestEvaluator: '',
      ),
      ...candidateSavedPrefs(
        bestSpeaker: '',
        bestTableTopics: 'Cara',
        bestEvaluator: '',
      ),
      ...awardStatePrefs(),
    });

    await pumpOnlineCountScreen(tester);
    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Next step: Open Best Table Topics Speaker voting'),
      findsOneWidget,
    );

    await scrollToAward(tester, 'tableTopics');
    expect(find.text('Ready'), findsOneWidget);
    final FilledButton tableTopicsOpenButton = tester.widget<FilledButton>(
      awardControl('Open', 'tableTopics'),
    );
    expect(tableTopicsOpenButton.onPressed, isNotNull);
    expect(awardControl('Open', 'bestSpeaker'), findsNothing);
    expect(awardControl('Open', 'evaluator'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await pumpOnlineCountScreen(tester);
    await scrollToAward(tester, 'tableTopics');

    final FilledButton rebuiltOpenButton = tester.widget<FilledButton>(
      awardControl('Open', 'tableTopics'),
    );
    expect(rebuiltOpenButton.onPressed, isNotNull);
    expect(find.text('Cara'), findsOneWidget);
  });

  testWidgets('unsaved edits disable only that award Open Voting action',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.open.value,
      ),
      ...candidateDraftPrefs(
        bestSpeaker: '',
        bestTableTopics: 'Cara',
        bestEvaluator: '',
      ),
      ...candidateSavedPrefs(
        bestSpeaker: '',
        bestTableTopics: 'Cara',
        bestEvaluator: '',
      ),
      ...awardStatePrefs(),
    });

    await pumpOnlineCountScreen(tester);
    await scrollToAward(tester, 'tableTopics');
    await tester.tap(awardControl('Edit', 'tableTopics'));
    await tester.pumpAndSettle();

    await tester.enterText(
      awardControl('Candidates', 'tableTopics'),
      'Cara\nDana',
    );
    await tester.pumpAndSettle();
    expect(find.text('Unsaved changes'), findsOneWidget);
    expect(awardControl('Save', 'tableTopics'), findsOneWidget);
    expect(awardControl('Open', 'tableTopics'), findsNothing);

    await scrollToTop(tester);

    expect(
      find.text('Next step: Add candidates for Best Speaker'),
      findsWidgets,
    );

    expect(find.text('Open Voting'), findsNothing);
  });

  testWidgets('restored open award only enables Close Voting for that award',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.open.value,
      ),
      ...awardStatePrefs(bestSpeakerStatus: OnlineRoundStatus.open.value),
    });

    await pumpOnlineCountScreen(tester);
    await scrollToAward(tester, 'bestSpeaker');

    final FilledButton closeVotingButton = tester.widget<FilledButton>(
      awardControl('Close', 'bestSpeaker'),
    );
    expect(closeVotingButton.onPressed, isNotNull);
    expect(
      find.text('Vote counts auto-refresh every 5 seconds.'),
      findsOneWidget,
    );
    final OutlinedButton refreshVoteCountButton = tester.widget<OutlinedButton>(
      awardControl('Refresh', 'bestSpeaker'),
    );
    expect(refreshVoteCountButton.onPressed, isNotNull);
    expect(awardControl('Candidates', 'bestSpeaker'), findsNothing);
    expect(awardCard('tableTopics'), findsOneWidget);
    expect(awardCard('evaluator'), findsOneWidget);
    expect(find.text('Open Voting'), findsNothing);
  });

  testWidgets(
      'closed Best Speaker is preserved while ready Table Topics can open',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.open.value,
      ),
      ...candidateDraftPrefs(
        bestSpeaker: 'Alice',
        bestTableTopics: 'Cara',
        bestEvaluator: '',
      ),
      ...candidateSavedPrefs(
        bestSpeaker: 'Alice',
        bestTableTopics: 'Cara',
        bestEvaluator: '',
      ),
      ...awardStatePrefs(bestSpeakerStatus: OnlineRoundStatus.closed.value),
    });

    await pumpOnlineCountScreen(tester);
    await scrollToAward(tester, 'bestSpeaker');
    expect(find.text('Voting closed'), findsOneWidget);
    expect(find.text('Final votes: 0'), findsOneWidget);
    expect(awardControl('Candidates', 'bestSpeaker'), findsNothing);
    expect(awardControl('Edit', 'bestSpeaker'), findsNothing);
    await tester.tap(
      find.descendant(
        of: awardCard('bestSpeaker'),
        matching: find.text('Best Speaker'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);

    await scrollToAward(tester, 'tableTopics');
    expect(find.text('Cara'), findsOneWidget);
    expect(find.text('Status: Closed', skipOffstage: false), findsNothing);
    final FilledButton tableTopicsOpenButton = tester.widget<FilledButton>(
      awardControl('Open', 'tableTopics'),
    );
    expect(tableTopicsOpenButton.onPressed, isNotNull);
    expect(awardCard('evaluator'), findsOneWidget);
  });

  testWidgets('open meeting with all awards closed points to close meeting',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ...savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.open.value,
      ),
      ...awardStatePrefs(
        bestSpeakerStatus: OnlineRoundStatus.closed.value,
        bestTableTopicsStatus: OnlineRoundStatus.closed.value,
        bestEvaluatorStatus: OnlineRoundStatus.closed.value,
      ),
    });

    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('All voting rounds are closed.'), findsOneWidget);
    expect(find.text('Next step: Close Voting Session'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Award Management'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Voting Round'), findsNothing);
    expect(
      find.text(
        'All voting rounds are closed. Close the voting session to finalize results.',
      ),
      findsOneWidget,
    );
    expect(find.text('Voting closed'), findsNWidgets(3));
    expect(find.text('Final votes: 0'), findsNWidgets(3));
    expect(find.text('Status: Closed', skipOffstage: false), findsNothing);
    expect(find.text('Refresh Vote Count'), findsNothing);
  });

  testWidgets('disposing while vote polling is active does not throw',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
      savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.open.value,
      ),
    );

    await pumpOnlineCountScreen(
      tester,
      debugInitialAwards: debugAwardsForSession(),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 6));

    expect(tester.takeException(), isNull);
  });

  testWidgets('start fresh cancels active vote polling without throwing',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
      savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.open.value,
      ),
    );

    await pumpOnlineCountScreen(
      tester,
      debugInitialAwards: debugAwardsForSession(),
    );
    final SharedPreferences beforePrefs = await SharedPreferences.getInstance();
    expect(
      beforePrefs.getString('speech_club_online_owner_token_v1'),
      'owner-token',
    );
    await openDangerZone(tester, actionLabel: 'Start Fresh on This Device');
    await tester.tap(find.text('Start Fresh on This Device'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      findsNothing,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Start Fresh'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));

    expect(tester.takeException(), isNull);
    expect(find.text('Online Club Setup'), findsOneWidget);
    final SharedPreferences afterPrefs = await SharedPreferences.getInstance();
    final String? newOwnerToken =
        afterPrefs.getString('speech_club_online_owner_token_v1');
    expect(newOwnerToken, isNotNull);
    expect(newOwnerToken, isNot('owner-token'));
    expect(afterPrefs.getString('speech_club_online_club_name_v1'), isNull);
  });

  testWidgets('closed current meeting shows result actions only',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
      savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.closed.value,
      ),
    );

    await pumpOnlineCountScreen(tester);

    expect(find.text('Current Status'), findsNothing);
    expect(find.text('Meeting Closed'), findsNothing);
    expect(find.text('Results are final'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Status: Voting Session Closed'), findsOneWidget);
    expect(find.text('Next step: Refresh and send results'), findsOneWidget);
    expect(find.text('Open Meeting', skipOffstage: false), findsNothing);
    expect(find.text('Close Meeting', skipOffstage: false), findsNothing);
    expect(find.text('Create Current Meeting'), findsNothing);
    expect(find.text('Candidate Setup'), findsNothing);
    expect(find.text('Voting Round'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Results'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Refresh Results'), findsOneWidget);
    expect(find.text('Refresh Vote Count'), findsNothing);
    expect(
      find.text('Tap Refresh Results first, then check the final results.'),
      findsOneWidget,
    );
    expect(find.text('Final Results'), findsOneWidget);
    expect(find.text('No results loaded yet.'), findsOneWidget);
    expect(find.text('Set President Contact'), findsOneWidget);
    expect(find.text('Copy Results'), findsOneWidget);
    expect(find.text('Send Results to President'), findsOneWidget);
    expect(find.text('Delete Current Meeting'), findsOneWidget);

    final OutlinedButton sendButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Send Results to President'),
    );
    expect(sendButton.onPressed, isNull);
    final OutlinedButton copyButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Copy Results'),
    );
    expect(copyButton.onPressed, isNull);
  });

  testWidgets('delete current meeting confirmation has no typed field',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs(withSession: true));

    await pumpOnlineCountScreen(tester);
    await openDangerZone(tester, actionLabel: 'Delete Current Meeting');
    await tester.tap(find.text('Delete Current Meeting'));
    await tester.pumpAndSettle();

    expect(find.text('Delete current meeting?'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      findsNothing,
    );
    expect(
      find.textContaining(
        'Please send or copy results before deleting this meeting.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('Deleting this meeting will not change the QR code.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Manual Count data will not be deleted.'),
      findsOneWidget,
    );
    final TextButton deleteButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Delete Current Meeting'),
    );
    expect(deleteButton.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete current meeting?'), findsNothing);
  });

  testWidgets('delete online club confirmation has no typed field',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(tester);
    await openDangerZone(tester, actionLabel: 'Delete Online Club');
    await tester.tap(find.text('Delete Online Club'));
    await tester.pumpAndSettle();

    expect(find.text('Delete online club?'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      findsNothing,
    );
    expect(
      find.textContaining('The old QR code will no longer be usable.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Manual Count data will not be deleted.'),
      findsOneWidget,
    );
    final TextButton deleteButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Delete Online Club'),
    );
    expect(deleteButton.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete online club?'), findsNothing);
  });

  testWidgets('start fresh confirmation has no typed field',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(tester);
    await openDangerZone(tester, actionLabel: 'Start Fresh on This Device');
    await tester.tap(find.text('Start Fresh on This Device'));
    await tester.pumpAndSettle();

    expect(find.text('Start fresh on this device?'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      findsNothing,
    );
    expect(
      find.textContaining('The old QR code should no longer be used.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Manual Count data will not be deleted.'),
      findsOneWidget,
    );
    final TextButton startFreshButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Start Fresh'),
    );
    expect(startFreshButton.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Start fresh on this device?'), findsNothing);
  });

  testWidgets('permanent QR card keeps technical copy out of main flow',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Permanent Voting QR'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('English voting page'), findsNothing);
    expect(find.text('中文'), findsNothing);
    expect(find.text('Auto'), findsNothing);
    expect(
      find.text(
        'Reusable for every meeting.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'The voting page follows each voter’s phone language.',
      ),
      findsNothing,
    );
    expect(
      find.text(
        'Deleting a meeting keeps this QR. Deleting the club or starting fresh makes it unusable.',
      ),
      findsNothing,
    );
    expect(find.text('Copy Voting Link'), findsNothing);
    expect(find.text('Share QR Code'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Share QR Code'), findsOneWidget);
    expect(
        find.widgetWithText(OutlinedButton, 'Copy Voting Link'), findsNothing);
    expect(find.text('Copy Print Text'), findsNothing);
    expect(find.text('Voting Link'), findsNothing);
    expect(
      find.text(
        'https://speech-club-vote.duduqihong.workers.dev/c/demo-club',
      ),
      findsNothing,
    );

    await openTechnicalSettings(tester);
    expect(find.text('Copy Voting Link'), findsOneWidget);
    expect(
      find.text(
        'The voting page follows each voter’s phone language.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('results card shows send button and shared president contact',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
      savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.closed.value,
      ),
    );
    await VoteResultsRecipientRepository().save(
      name: 'Ada President',
      phoneNumber: '+65 9664 5650',
    );

    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Results'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Refresh Results'), findsOneWidget);
    expect(find.text('Send Results to President'), findsOneWidget);
    expect(find.text('Copy Results'), findsOneWidget);
    expect(find.text('Final Results'), findsOneWidget);
    expect(find.text('President Contact'), findsOneWidget);
    expect(find.text('Ada President · +65 9664 5650'), findsOneWidget);
  });

  testWidgets('send and copy results are disabled before refresh',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
      savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.closed.value,
      ),
    );

    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Send Results to President'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final OutlinedButton sendButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Send Results to President'),
    );
    expect(sendButton.onPressed, isNull);
    final OutlinedButton copyButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Copy Results'),
    );
    expect(copyButton.onPressed, isNull);
    expect(find.text('No results loaded yet.'), findsOneWidget);
  });
}
