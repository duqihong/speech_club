import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speech_club/localization/app_locale_controller.dart';
import 'package:speech_club/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Settings opens Speech Club Pro screen with placeholder purchase',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      SpeechClubApp(localeController: AppLocaleController()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Speech Club Pro'), findsOneWidget);
    expect(find.text('Online voting subscription'), findsOneWidget);

    await tester.tap(find.text('Speech Club Pro'));
    await tester.pumpAndSettle();

    expect(find.text('Speech Club Pro'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Manual Count and all offline tools remain free.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Manual Count and all offline tools remain free.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Start 3-Month Free Trial'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start 3-Month Free Trial'));
    await tester.pump();

    expect(
      find.text('Purchase will be enabled in a later test phase.'),
      findsOneWidget,
    );
  });

  testWidgets('Chinese Pro screen uses localized copy',
      (WidgetTester tester) async {
    final AppLocaleController localeController = AppLocaleController();
    await localeController.setLocale(AppLocaleController.simplifiedChinese);

    await tester.pumpWidget(
      SpeechClubApp(localeController: localeController),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speech Club Pro'));
    await tester.pumpAndSettle();

    expect(
      find.text('使用一个永久俱乐部二维码，进行现场在线投票。'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('免费使用手动计票'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('免费使用手动计票'), findsOneWidget);
    expect(find.text('手动计票和所有离线工具永久免费。'), findsOneWidget);
  });
}
