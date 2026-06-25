import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/ui/vote_bests_mode_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpModeScreen(
    WidgetTester tester, {
    Locale? locale,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const VoteBestsModeScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('English mode selection shows both counting modes',
      (WidgetTester tester) async {
    await pumpModeScreen(tester);

    expect(find.text('Vote Bests'), findsOneWidget);
    expect(
      find.text('Choose how you want to count meeting award votes.'),
      findsOneWidget,
    );
    expect(find.text('Manual Count'), findsOneWidget);
    expect(find.text('Online Count'), findsOneWidget);
    expect(
      find.text('Count votes locally on this device.'),
      findsOneWidget,
    );
    expect(
      find.text('Create cloud voting rounds and collect online votes.'),
      findsOneWidget,
    );
  });

  testWidgets('Chinese mode selection shows both counting modes',
      (WidgetTester tester) async {
    await pumpModeScreen(tester, locale: const Locale('zh'));

    expect(find.text('最佳投票'), findsOneWidget);
    expect(find.text('选择本次例会奖项的计票方式。'), findsOneWidget);
    expect(find.text('手动计票'), findsOneWidget);
    expect(find.text('在线计票'), findsOneWidget);
    expect(find.text('在本机手动添加候选人和票数。'), findsOneWidget);
    expect(find.text('创建云端投票轮次并收集线上投票。'), findsOneWidget);
  });

  testWidgets('Manual Count opens the existing English tally flow',
      (WidgetTester tester) async {
    await pumpModeScreen(tester);

    await tester.tap(find.text('Manual Count'));
    await tester.pumpAndSettle();

    expect(find.text('Best Speaker'), findsOneWidget);
    expect(find.text('Best Table Topics Speaker'), findsOneWidget);
    expect(find.text('Best Evaluator'), findsOneWidget);
  });

  testWidgets('Manual Count opens the existing Chinese tally flow',
      (WidgetTester tester) async {
    await pumpModeScreen(tester, locale: const Locale('zh'));

    await tester.tap(find.text('手动计票'));
    await tester.pumpAndSettle();

    expect(find.text('最佳演讲者'), findsOneWidget);
    expect(find.text('最佳即席演讲者'), findsOneWidget);
    expect(find.text('最佳点评者'), findsOneWidget);
  });

  testWidgets('English Online Count opens admin MVP',
      (WidgetTester tester) async {
    await pumpModeScreen(tester);

    await tester.tap(find.text('Online Count'));
    await tester.pumpAndSettle();

    expect(find.text('Online Count'), findsOneWidget);
    expect(find.text('Cloud Setup'), findsOneWidget);
    expect(find.text('Current Meeting'), findsOneWidget);
    expect(find.text('Backend URL'), findsOneWidget);
    expect(find.text('Create Club'), findsOneWidget);
  });

  testWidgets('Chinese Online Count admin MVP is localized',
      (WidgetTester tester) async {
    await pumpModeScreen(tester, locale: const Locale('zh'));

    await tester.tap(find.text('在线计票'));
    await tester.pumpAndSettle();

    expect(find.text('在线计票'), findsOneWidget);
    expect(find.text('云端设置'), findsOneWidget);
    expect(find.text('当前会议'), findsOneWidget);
    expect(find.text('后台网址'), findsOneWidget);
    expect(find.text('创建俱乐部'), findsOneWidget);
  });
}
