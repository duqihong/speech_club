import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('setup hides backend URL and uses club code wording',
      (WidgetTester tester) async {
    await pumpOnlineCountScreen(tester);

    expect(find.text('Online Club Setup'), findsOneWidget);
    expect(find.text('Club Code'), findsOneWidget);
    expect(find.text('Club Slug'), findsNothing);
    expect(find.text('Backend URL'), findsNothing);
    expect(find.text('Advanced Settings'), findsOneWidget);
    expect(
      find.text(
        'Admin PIN is used by club officers to manage online voting. Do not share it with voters.\nVoters do not need this PIN.',
      ),
      findsOneWidget,
    );
    expect(find.text('Save Setup'), findsOneWidget);
    expect(find.text('Create Online Club'), findsOneWidget);

    await tester.ensureVisible(find.text('Advanced Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advanced Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Backend URL'), findsOneWidget);
  });

  testWidgets('club code auto-generates until manually edited',
      (WidgetTester tester) async {
    await pumpOnlineCountScreen(tester);

    await tester.enterText(
        textFieldWithLabel('Club Name'), 'Demo App Test Club');
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

  testWidgets('meeting explanation is visible and meeting id is technical',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'speech_club_online_current_session_id_v1':
          '16b8bd7a-739d-45ef-b13c-6e07c32b9ec2',
      'speech_club_online_current_session_title_v1': 'Regular Meeting',
      'speech_club_online_current_session_date_v1': '2026-06-25',
    });

    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Current Meeting'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Each meeting has its own voting session. Create a meeting, open it, then open one award vote at a time.',
      ),
      findsOneWidget,
    );
    expect(find.text('Step 1: Create Meeting'), findsOneWidget);
    expect(find.text('Meeting status: Draft'), findsOneWidget);
    expect(
      find.text('16b8bd7a-739d-45ef-b13c-6e07c32b9ec2'),
      findsNothing,
    );

    await tester.ensureVisible(find.text('Technical Details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technical Details'));
    await tester.pumpAndSettle();

    expect(
      find.text('Meeting ID: 16b8bd7a-739d-45ef-b13c-6e07c32b9ec2'),
      findsOneWidget,
    );
  });

  testWidgets('voting link card explains same link behavior',
      (WidgetTester tester) async {
    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Voting Link'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'The same link is used for every award. Open one award voting round at a time.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('permanent QR card guides when club code is empty',
      (WidgetTester tester) async {
    await pumpOnlineCountScreen(tester);

    await tester.scrollUntilVisible(
      find.text('Permanent Voting QR'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Permanent Voting QR'), findsOneWidget);
    expect(
      find.text(
        'Use the same QR code for every meeting. The voting page will show only the award currently open for voting.',
      ),
      findsOneWidget,
    );
    expect(find.text('Enter and save a club code first.'), findsOneWidget);
  });

  testWidgets('permanent QR card shows copy actions with club code',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'speech_club_online_base_url_v1':
          'https://speech-club-vote-prototype.duduqihong.workers.dev',
      'speech_club_online_club_name_v1': 'Demo Club',
      'speech_club_online_club_slug_v1': 'demo-club',
      'speech_club_online_admin_pin_v1': '123456',
    });

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
    SharedPreferences.setMockInitialValues(<String, Object>{});
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
    SharedPreferences.setMockInitialValues(<String, Object>{
      'speech_club_online_current_session_id_v1': 'session-1',
      'speech_club_online_current_session_title_v1': 'Regular Meeting',
      'speech_club_online_current_session_date_v1': '2026-06-25',
    });

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
