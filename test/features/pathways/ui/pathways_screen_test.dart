import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/pathways/ui/pathways_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';
import 'package:speech_club/localization/app_locale_controller.dart';
import 'package:speech_club/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Home screen shows Pathways in English',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      SpeechClubApp(localeController: AppLocaleController()),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Pathways'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Pathways'), findsOneWidget);
  });

  testWidgets('Home screen shows Pathways in Chinese',
      (WidgetTester tester) async {
    final AppLocaleController localeController = AppLocaleController();
    await localeController.setLocale(AppLocaleController.simplifiedChinese);

    await tester.pumpWidget(
      SpeechClubApp(localeController: localeController),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('学习路径'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('学习路径'), findsOneWidget);
  });

  testWidgets('Pathways screen shows six path cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PathwaysScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dynamic Leadership'), findsOneWidget);
    expect(find.text('Engaging Humor'), findsOneWidget);
    expect(find.text('Motivational Strategies'), findsOneWidget);
    expect(find.text('Persuasive Influence'), findsOneWidget);
    expect(find.text('Presentation Mastery'), findsOneWidget);
    expect(find.text('Visionary Communication'), findsOneWidget);
    expect(
      find.textContaining('Use this as a simple club guide'),
      findsOneWidget,
    );
  });

  testWidgets('Chinese Pathways screen shows localized path cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PathwaysScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('动态领导力'), findsOneWidget);
    expect(find.text('幽默演讲'), findsOneWidget);
    expect(find.text('激励策略'), findsOneWidget);
    expect(find.text('说服影响力'), findsOneWidget);
    expect(find.text('演讲精进'), findsOneWidget);
    expect(find.text('愿景沟通'), findsOneWidget);
    expect(find.textContaining('这是俱乐部内使用的简明参考'), findsOneWidget);
  });

  testWidgets('English Presentation Mastery detail shows guide sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PathwaysScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('pathwaysList')),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Presentation Mastery'));
    await tester.pumpAndSettle();

    expect(find.text('🎤 Presentation Mastery'), findsOneWidget);
    expect(find.text('What This Path Builds'), findsOneWidget);
    expect(find.text('Good For Members Who Want To'), findsOneWidget);
    expect(find.text('Typical Speech Focus'), findsOneWidget);
    expect(find.text('How to Start'), findsOneWidget);
    expect(find.text('Mentor Tips'), findsOneWidget);
    expect(
      find.textContaining('Use this as a simple club guide'),
      findsNothing,
    );
  });

  testWidgets('Chinese Presentation Mastery detail shows guide sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PathwaysScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('pathwaysList')),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('演讲精进'));
    await tester.pumpAndSettle();

    expect(find.text('🎤 演讲精进'), findsOneWidget);
    expect(find.text('这条路径训练什么'), findsOneWidget);
    expect(find.text('适合这样的会员'), findsOneWidget);
    expect(find.text('常见演讲重点'), findsOneWidget);
    expect(find.text('如何开始'), findsOneWidget);
    expect(find.text('导师提示'), findsOneWidget);
    expect(find.textContaining('这是俱乐部内使用的简明参考'), findsNothing);
  });
}
