import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/topic_selection/ui/topic_selection_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';
import 'package:speech_club/localization/app_locale_controller.dart';
import 'package:speech_club/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Home screen shows Topic Selection in English',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      SpeechClubApp(localeController: AppLocaleController()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Topic Selection'), findsOneWidget);
  });

  testWidgets('Home screen shows Topic Selection in Chinese',
      (WidgetTester tester) async {
    final AppLocaleController localeController = AppLocaleController();
    await localeController.setLocale(AppLocaleController.simplifiedChinese);

    await tester.pumpWidget(
      SpeechClubApp(localeController: localeController),
    );
    await tester.pumpAndSettle();

    expect(find.text('选题助手'), findsOneWidget);
  });

  testWidgets('Topic Selection screen renders intro text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TopicSelectionScreen(),
      ),
    );

    expect(find.text('Topic Selection'), findsOneWidget);
    expect(
      find.text(
        'Choose a topic you care about. A good speech starts with a real thought, story, or lesson.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('category filter switches between Personal Growth and All',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TopicSelectionScreen(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('A turning point in my life'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('topicSelectionCategoryScroll')),
      const Offset(-700, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Personal Growth'));
    await tester.pumpAndSettle();

    expect(find.text('How I handle worry'), findsOneWidget);
    expect(find.text('A turning point in my life'), findsNothing);

    await tester.drag(
      find.byKey(const Key('topicSelectionCategoryScroll')),
      const Offset(700, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'All'));
    await tester.pumpAndSettle();

    expect(find.text('A turning point in my life'), findsOneWidget);
  });

  testWidgets('tapping a topic opens detail page', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TopicSelectionScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('A turning point in my life'));
    await tester.pumpAndSettle();

    expect(find.text('Why this topic works'), findsOneWidget);
    expect(find.text('Possible structure'), findsOneWidget);
    expect(find.text('Starter questions'), findsOneWidget);
    expect(find.text('Opening line'), findsOneWidget);
  });

  testWidgets('Chinese detail page shows localized section headings',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TopicSelectionScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('我人生中的一个转折点'));
    await tester.pumpAndSettle();

    expect(find.text('为什么这个题目适合演讲'), findsOneWidget);
    expect(find.text('可以这样组织'), findsOneWidget);
    expect(find.text('启发问题'), findsOneWidget);
    expect(find.text('开场句参考'), findsOneWidget);
  });
}
