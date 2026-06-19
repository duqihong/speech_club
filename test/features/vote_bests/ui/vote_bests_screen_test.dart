import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/ui/vote_bests_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';
import 'package:speech_club/localization/app_locale_controller.dart';
import 'package:speech_club/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('English home shows Vote Bests', (WidgetTester tester) async {
    await tester.pumpWidget(
      SpeechClubApp(localeController: AppLocaleController()),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Vote Bests'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Vote Bests'), findsOneWidget);
  });

  testWidgets('Chinese home shows Vote Bests', (WidgetTester tester) async {
    final AppLocaleController localeController = AppLocaleController();
    await localeController.setLocale(AppLocaleController.simplifiedChinese);

    await tester.pumpWidget(
      SpeechClubApp(localeController: localeController),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('最佳投票'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('最佳投票'), findsOneWidget);
  });

  testWidgets('Vote Bests screen shows English award categories',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VoteBestsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Best Speaker'), findsOneWidget);
    expect(find.text('Best Table Topics Speaker'), findsOneWidget);
    expect(find.text('Best Evaluator'), findsOneWidget);
  });

  testWidgets('Vote Bests screen shows Chinese award categories',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VoteBestsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('最佳演讲者'), findsOneWidget);
    expect(find.text('最佳即席演讲者'), findsOneWidget);
    expect(find.text('最佳点评者'), findsOneWidget);
  });

  testWidgets('tapping Best Speaker opens detail page',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VoteBestsScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Best Speaker'));
    await tester.pumpAndSettle();

    expect(find.text('🗣️ Best Speaker'), findsOneWidget);
    expect(find.text('Add Candidate'), findsOneWidget);
  });

  testWidgets('adding a candidate and tapping +1 updates vote count',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VoteBestsScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Best Speaker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Candidate'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsWidgets);
    expect(find.text('Votes: 0'), findsOneWidget);

    await tester.tap(find.text('+1').first);
    await tester.pumpAndSettle();

    expect(find.text('Votes: 1'), findsOneWidget);
    expect(find.text('Current leader: Alice'), findsOneWidget);
  });
}
