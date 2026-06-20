import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/l10n/app_localizations.dart';
import 'package:speech_club/role_assistant/ui/role_assistant_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('English role grid and Timer detail open correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RoleAssistantScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Toastmaster of the Day'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Table Topics Master'), findsOneWidget);
    expect(find.text('Evaluator'), findsOneWidget);
    expect(find.text('Language Evaluator'), findsOneWidget);
    expect(find.text('Ah-Counter'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('General Evaluator'), findsOneWidget);

    await tester.tap(find.text('Timer'));
    await tester.pumpAndSettle();

    expect(find.text('⏱️ Timer'), findsOneWidget);
    expect(find.text('Role Purpose'), findsOneWidget);
    expect(find.text('Checklist'), findsOneWidget);
    expect(find.text('Quick Tips'), findsOneWidget);
    expect(find.text('Example Phrasing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chinese role grid and Timer detail are localized',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RoleAssistantScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('司仪'), findsOneWidget);
    expect(find.text('计时员'), findsOneWidget);
    expect(find.text('即席演讲主持'), findsOneWidget);
    expect(find.text('评论员'), findsOneWidget);
    expect(find.text('语言评论'), findsOneWidget);
    expect(find.text('尾音记录员'), findsOneWidget);
    expect(find.text('演讲者'), findsOneWidget);
    expect(find.text('总评论'), findsOneWidget);

    await tester.tap(find.text('计时员'));
    await tester.pumpAndSettle();

    expect(find.text('⏱️ 计时员'), findsOneWidget);
    expect(find.text('角色职责'), findsOneWidget);
    expect(find.text('检查清单'), findsOneWidget);
    expect(find.text('小贴士'), findsOneWidget);
    expect(find.text('示例话术'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
