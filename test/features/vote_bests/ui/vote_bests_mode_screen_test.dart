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
      find.text('Cloud-supported voting is pending design.'),
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
    expect(find.text('云端投票功能待设计。'), findsOneWidget);
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

  testWidgets('English Online Count placeholder links to Manual Count',
      (WidgetTester tester) async {
    await pumpModeScreen(tester);

    await tester.tap(find.text('Online Count'));
    await tester.pumpAndSettle();

    expect(find.text('Online Count'), findsOneWidget);
    expect(
      find.text(
        'Online voting will be designed later. It may support cloud counting, meeting links, or QR-based voting.',
      ),
      findsOneWidget,
    );
    expect(find.text('For now, please use Manual Count.'), findsOneWidget);
    expect(find.text('Go to Manual Count'), findsOneWidget);

    await tester.tap(find.text('Go to Manual Count'));
    await tester.pumpAndSettle();

    expect(find.text('Manual Count'), findsOneWidget);
    expect(find.text('Best Speaker'), findsOneWidget);
  });

  testWidgets('Chinese Online Count placeholder is localized',
      (WidgetTester tester) async {
    await pumpModeScreen(tester, locale: const Locale('zh'));

    await tester.tap(find.text('在线计票'));
    await tester.pumpAndSettle();

    expect(find.text('在线计票'), findsOneWidget);
    expect(
      find.text('在线投票功能将在后续设计。未来可考虑云端计票、会议链接或二维码投票。'),
      findsOneWidget,
    );
    expect(find.text('目前请先使用手动计票。'), findsOneWidget);
    expect(find.text('前往手动计票'), findsOneWidget);
  });
}
