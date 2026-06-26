import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_models.dart';
import 'package:speech_club/features/vote_bests/data/vote_results_recipient_repository.dart';
import 'package:speech_club/features/vote_bests/ui/online_count_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpOnlineCountScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnlineCountScreen(),
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

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('no club shows setup mode only and hides backend URL',
      (WidgetTester tester) async {
    await pumpOnlineCountScreen(tester);

    expect(find.text('Online Club Setup'), findsOneWidget);
    expect(find.text('Create Online Club'), findsOneWidget);
    expect(textFieldWithLabel('Club Name'), findsOneWidget);
    expect(textFieldWithLabel('Club Code'), findsOneWidget);
    expect(textFieldWithLabel('Admin PIN'), findsOneWidget);
    expect(find.text('Current Meeting'), findsNothing);
    expect(find.text('Permanent Voting QR'), findsNothing);
    expect(find.text('Results'), findsNothing);
    expect(find.text('Backend URL'), findsNothing);
    expect(find.text('Advanced Settings'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Start Fresh on This Device'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
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

  testWidgets('club code auto-generates until manually edited',
      (WidgetTester tester) async {
    await pumpOnlineCountScreen(tester);

    await tester.enterText(
      textFieldWithLabel('Club Name'),
      'Demo App Test Club',
    );
    await tester.pump();

    TextField codeField = tester.widget<TextField>(
      textFieldWithLabel('Club Code'),
    );
    expect(codeField.controller!.text, 'demo-app-test-club');

    await tester.enterText(textFieldWithLabel('Club Code'), 'custom-code');
    await tester.pump();
    await tester.enterText(textFieldWithLabel('Club Name'), 'Changed Club');
    await tester.pump();

    codeField = tester.widget<TextField>(textFieldWithLabel('Club Code'));
    expect(codeField.controller!.text, 'custom-code');
  });

  testWidgets('saved club shows locked summary and no editable setup fields',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(tester);

    expect(find.text('Online Club Ready'), findsOneWidget);
    expect(find.text('Online club: Demo Club'), findsOneWidget);
    expect(find.text('Club code: demo-club'), findsOneWidget);
    expect(find.text('Check Online Status'), findsOneWidget);
    expect(find.text('Delete Online Club'), findsOneWidget);
    expect(textFieldWithLabel('Club Name'), findsNothing);
    expect(textFieldWithLabel('Club Code'), findsNothing);
    expect(textFieldWithLabel('Admin PIN'), findsNothing);
    expect(find.text('Backend URL'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Start Fresh on This Device'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Reset Online Count on This Device'), findsOneWidget);
    expect(find.text('Start Fresh on This Device'), findsOneWidget);
  });

  testWidgets('saved club with no session shows no current meeting',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(savedClubPrefs());

    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('No current meeting'), findsOneWidget);
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
    expect(find.text('Delete Current Meeting'), findsOneWidget);
    expect(find.text('Create Current Meeting'), findsNothing);
    expect(find.text('Candidate Setup'), findsOneWidget);
    expect(find.text('Results'), findsNothing);
  });

  testWidgets('open current meeting shows award controls and hides setup',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
      savedClubPrefs(
        withSession: true,
        sessionStatus: OnlineRoundStatus.open.value,
      ),
    );

    await pumpOnlineCountScreen(tester);

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
    expect(find.text('Results'), findsNothing);
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
    expect(find.text('Copy Results'), findsOneWidget);
    expect(find.text('Send Results to President'), findsOneWidget);
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
    await tester.scrollUntilVisible(
      find.text('Reset Online Count on This Device'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
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
    await tester.scrollUntilVisible(
      find.text('Start Fresh on This Device'),
      700,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
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

    expect(find.text('English voting page'), findsOneWidget);
    expect(find.text('Copy QR Link'), findsOneWidget);
    expect(find.text('Copy Print Text'), findsOneWidget);
    expect(
      find.text(
        'https://speech-club-vote-prototype.duduqihong.workers.dev/c/demo-club?lang=en',
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
