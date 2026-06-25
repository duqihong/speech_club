import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/ui/online_count_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpOnlineCountScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
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
        'Use the same link for every award. The page will show only the award currently open for voting.',
      ),
      findsOneWidget,
    );
  });
}
