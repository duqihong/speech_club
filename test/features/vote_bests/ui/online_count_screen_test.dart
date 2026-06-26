import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_models.dart';
import 'package:speech_club/features/vote_bests/data/vote_results_recipient_repository.dart';
import 'package:speech_club/features/vote_bests/ui/online_count_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpOnlineCountScreen(
    WidgetTester tester, {
    List<OnlineAward> debugInitialAwards = const <OnlineAward>[],
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnlineCountScreen(debugInitialAwards: debugInitialAwards),
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

  Future<void> openDangerZone(
    WidgetTester tester, {
    String? actionLabel,
  }) async {
    await tester.scrollUntilVisible(
      find.text('Danger Zone'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danger Zone'));
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
  }) {
    return <String, Object>{
      'speech_club_online_owner_token_v1': 'owner-token',
      'speech_club_online_base_url_v1':
          'https://speech-club-vote-prototype.duduqihong.workers.dev',
      'speech_club_online_club_name_v1': 'Demo Club',
      'speech_club_online_club_slug_v1': 'demo-club',
      'speech_club_online_admin_pin_v1': '123456',
      if (withSession) ...<String, Object>{
        'speech_club_online_current_session_id_v1': 'session-1',
        'speech_club_online_current_session_title_v1': 'Regular Meeting',
        'speech_club_online_current_session_date_v1': '2026-06-26',
        'speech_club_online_current_session_status_v1': sessionStatus,
      },
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
    expect(find.text('Backend URL'), findsNothing);
    expect(find.text('Advanced Settings'), findsNothing);
    expect(find.text('Start Fresh on This Device'), findsNothing);

    await openDangerZone(tester, actionLabel: 'Start Fresh on This Device');
    expect(find.text('Start Fresh on This Device'), findsOneWidget);
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

    expect(find.text('Current Status'), findsOneWidget);
    expect(find.text('Online Club Ready'), findsOneWidget);
    expect(find.text('Current Meeting: Not created'), findsOneWidget);
    expect(find.text('Next step: Create Current Meeting'), findsOneWidget);
    expect(find.text('Club: Demo Club'), findsOneWidget);
    expect(find.text('Club code: demo-club'), findsOneWidget);
    expect(find.text('Voting QR is ready below.'), findsOneWidget);
    expect(
      find.text(
        'Voting Link: https://speech-club-vote-prototype.duduqihong.workers.dev/c/demo-club',
      ),
      findsNothing,
    );
    expect(find.text('Check Online Status'), findsNothing);
    expect(find.text('Delete Online Club'), findsOneWidget);
    expect(textFieldWithLabel('Club Name'), findsNothing);
    expect(textFieldWithLabel('Club Code'), findsNothing);
    expect(textFieldWithLabel('Admin PIN'), findsNothing);
    expect(find.text('Backend URL'), findsNothing);

    expect(find.text('Reset Online Count on This Device'), findsNothing);
    expect(find.text('Start Fresh on This Device'), findsNothing);

    await openDangerZone(tester, actionLabel: 'Start Fresh on This Device');
    expect(find.text('Reset Online Count on This Device'), findsOneWidget);
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
      find.text('Create a meeting before adding candidates or opening voting.'),
      findsOneWidget,
    );
    expect(find.text('Create Current Meeting'), findsOneWidget);
    expect(find.text('Candidate Setup'), findsNothing);
    expect(find.text('Results'), findsNothing);
  });

  testWidgets('draft current meeting blocks create and hides results',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs(withSession: true));

    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Meeting status: Draft'), findsOneWidget);
    expect(find.text('Add candidates, then open the meeting.'), findsOneWidget);
    expect(find.text('Delete Current Meeting'), findsOneWidget);
    expect(find.text('Create Current Meeting'), findsNothing);
    expect(find.text('Candidate Setup'), findsOneWidget);
    final Iterable<TextField> candidateFields = tester.widgetList<TextField>(
      textFieldWithLabel('One candidate per line'),
    );
    expect(candidateFields.length, 3);
    expect(
      candidateFields.every((TextField field) => field.enabled == true),
      isTrue,
    );
    await tester.scrollUntilVisible(
      find.text('Ready to start voting?'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Ready to start voting?'), findsOneWidget);
    expect(
      find.text('Save candidates for all awards before opening the meeting.'),
      findsOneWidget,
    );
    final FilledButton openMeetingButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Open Meeting'),
    );
    expect(openMeetingButton.onPressed, isNull);
    expect(find.text('Results'), findsNothing);
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
    });

    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Candidate Setup'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Alice\nBen'), findsOneWidget);
    expect(find.text('Cara'), findsOneWidget);
    expect(find.text('Eva'), findsOneWidget);
    final Iterable<TextField> candidateFields = tester.widgetList<TextField>(
      textFieldWithLabel('One candidate per line'),
    );
    expect(
      candidateFields.every((TextField field) => field.enabled == true),
      isTrue,
    );
    final OutlinedButton saveSpeakerButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Save Best Speaker Candidates'),
    );
    expect(saveSpeakerButton.onPressed, isNotNull);
  });

  testWidgets('typing candidate text persists after rebuilding screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs(withSession: true));

    await pumpOnlineCountScreen(tester);
    await tester.scrollUntilVisible(
      find.text('Candidate Setup'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      textFieldWithLabel('One candidate per line').first,
      'Alice',
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await pumpOnlineCountScreen(tester);
    await tester.scrollUntilVisible(
      find.text('Candidate Setup'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    final OutlinedButton saveSpeakerButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Save Best Speaker Candidates'),
    );
    expect(saveSpeakerButton.onPressed, isNotNull);
  });

  testWidgets('open current meeting shows award controls and hides setup',
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

    expect(find.text('Meeting Open'), findsOneWidget);
    expect(find.text('Current vote: Best Speaker'), findsOneWidget);
    expect(find.text('Next step: Close voting when ready'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Meeting status: Open'), findsOneWidget);
    expect(find.text('Create Current Meeting'), findsNothing);
    expect(find.text('Candidate Setup'), findsNothing);
    expect(find.text('Voting Round'), findsOneWidget);
    expect(find.text('Refresh Vote Count'), findsOneWidget);
    expect(
      find.text('Vote counts auto-refresh every 5 seconds.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Open · Votes received: 0'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Open · Votes received: 0'), findsOneWidget);
    expect(find.text('Status: Open'), findsOneWidget);
    expect(find.text('Votes received: 0'), findsWidgets);
    expect(find.text('Final votes: 0'), findsOneWidget);
    expect(find.text('Results'), findsNothing);
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
    await openDangerZone(tester, actionLabel: 'Start Fresh on This Device');
    await tester.tap(find.text('Start Fresh on This Device'));
    await tester.pumpAndSettle();
    await tester.enterText(
      textFieldWithLabel('Type FRESH to continue'),
      'FRESH',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'OK'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));

    expect(tester.takeException(), isNull);
    expect(find.text('Online Club Setup'), findsOneWidget);
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

    expect(find.text('Meeting Closed'), findsOneWidget);
    expect(find.text('Results are final'), findsOneWidget);
    expect(
      find.text('Next step: Send results or delete meeting'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Meeting status: Closed'), findsOneWidget);
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
    expect(find.text('Copy Results'), findsOneWidget);
    expect(find.text('Send Results to President'), findsOneWidget);
    expect(find.text('Delete Current Meeting'), findsOneWidget);
  });

  testWidgets('delete current meeting confirmation requires DELETE',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs(withSession: true));

    await pumpOnlineCountScreen(tester);
    await tester.scrollUntilVisible(
      find.text('Delete Current Meeting'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Current Meeting'));
    await tester.pumpAndSettle();

    expect(find.text('Type DELETE to continue'), findsOneWidget);
    FilledButton okButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'OK'),
    );
    expect(okButton.onPressed, isNull);

    await tester.enterText(
        textFieldWithLabel('Type DELETE to continue'), 'DELETE');
    await tester.pumpAndSettle();

    okButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'OK'),
    );
    expect(okButton.onPressed, isNotNull);
  });

  testWidgets('reset local setup confirmation requires RESET',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(tester);
    await openDangerZone(
      tester,
      actionLabel: 'Reset Online Count on This Device',
    );
    await tester.tap(find.text('Reset Online Count on This Device'));
    await tester.pumpAndSettle();

    expect(find.text('Type RESET to continue'), findsOneWidget);
    FilledButton okButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'OK'),
    );
    expect(okButton.onPressed, isNull);

    await tester.enterText(
        textFieldWithLabel('Type RESET to continue'), 'RESET');
    await tester.pumpAndSettle();

    okButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'OK'),
    );
    expect(okButton.onPressed, isNotNull);
  });

  testWidgets('start fresh confirmation requires FRESH',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(tester);
    await openDangerZone(tester, actionLabel: 'Start Fresh on This Device');
    await tester.tap(find.text('Start Fresh on This Device'));
    await tester.pumpAndSettle();

    expect(find.text('Start fresh?'), findsOneWidget);
    expect(find.text('Type FRESH to continue'), findsOneWidget);
    FilledButton okButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'OK'),
    );
    expect(okButton.onPressed, isNull);

    await tester.enterText(
        textFieldWithLabel('Type FRESH to continue'), 'FRESH');
    await tester.pumpAndSettle();

    okButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'OK'),
    );
    expect(okButton.onPressed, isNotNull);
  });

  testWidgets('permanent QR card shows copy actions after club setup',
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
        'This QR code belongs to this online club.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'It can be reused for every meeting.\nThe voting page will follow the voter’s phone language.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Deleting a meeting keeps this QR. Deleting the club or starting fresh makes the old QR unusable.',
      ),
      findsOneWidget,
    );
    expect(find.text('Copy Link'), findsOneWidget);
    expect(find.text('Share QR Code'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Share QR Code'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Copy Link'), findsOneWidget);
    expect(find.text('Copy Print Text'), findsNothing);
    expect(find.text('Voting Link'), findsNothing);
    expect(
      find.text(
        'https://speech-club-vote-prototype.duduqihong.workers.dev/c/demo-club',
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
    expect(find.text('President Contact'), findsOneWidget);
    expect(find.text('Ada President · +65 9664 5650'), findsOneWidget);
  });

  testWidgets('send results asks to refresh before sending stale results',
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
    await tester.tap(find.text('Send Results to President'));
    await tester.pumpAndSettle();

    expect(find.text('Please refresh results first.'), findsOneWidget);
  });
}
