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

  testWidgets('Topic Selection screen shows 8 category cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TopicSelectionScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Topic Selection'), findsOneWidget);
    expect(
      find.text(
        'Almost any topic can become a speech if it connects to your experience, feeling, or point of view.',
      ),
      findsOneWidget,
    );
    expect(find.text('Personal Experience'), findsOneWidget);
    expect(find.text('Hobbies'), findsOneWidget);
    expect(find.text('People Stories'), findsOneWidget);
    expect(find.text('Life Observations'), findsOneWidget);
    expect(find.text('Knowledge Sharing'), findsOneWidget);
    expect(find.text('Opinions'), findsOneWidget);
    expect(find.text('Culture & Memories'), findsOneWidget);
    expect(find.text('Dreams & Wishes'), findsOneWidget);
  });

  testWidgets('Chinese Topic Selection screen shows localized categories',
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

    expect(find.text('个人经历'), findsOneWidget);
    expect(find.text('兴趣爱好'), findsOneWidget);
    expect(find.text('人物故事'), findsOneWidget);
    expect(find.text('生活观察'), findsOneWidget);
    expect(find.text('知识分享'), findsOneWidget);
    expect(find.text('观点表达'), findsOneWidget);
    expect(find.text('文化与回忆'), findsOneWidget);
    expect(find.text('梦想与愿望'), findsOneWidget);
  });

  testWidgets('tapping Chinese Personal Experience opens detail page',
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
    await tester.tap(find.text('个人经历'));
    await tester.pumpAndSettle();

    expect(find.text('🧳 个人经历'), findsOneWidget);
    expect(find.text('这类题目适合什么'), findsOneWidget);
    expect(find.text('可以讲这些题目'), findsOneWidget);
    expect(find.text('怎样选一个好题目'), findsOneWidget);
    expect(find.text('可以这样组织'), findsOneWidget);
    expect(find.text('开场句参考'), findsOneWidget);
  });

  testWidgets('English Personal Experience detail shows guide sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TopicSelectionScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Personal Experience'));
    await tester.pumpAndSettle();

    expect(find.text('🧳 Personal Experience'), findsOneWidget);
    expect(find.text('Category Purpose'), findsOneWidget);
    expect(find.text('Topic Ideas'), findsOneWidget);
    expect(find.text('How to Choose'), findsOneWidget);
    expect(find.text('Speech Structure'), findsOneWidget);
    expect(find.text('Opening Lines'), findsOneWidget);
  });
}
