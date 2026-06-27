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

  testWidgets('Timer and Flashcards open from home without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppLocaleController localeController = AppLocaleController();
    await tester.pumpWidget(
      SpeechClubApp(localeController: localeController),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Timer'));
    await tester.pumpAndSettle();

    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flashcards'));
    await tester.pumpAndSettle();

    expect(find.text('Speech Flashcards'), findsOneWidget);
    expect(find.text('Create simple cards to guide your prepared speech.'),
        findsOneWidget);
    expect(find.text('Edit Flashcards'), findsOneWidget);
    expect(find.text('Start Practice'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await localeController.setLocale(AppLocaleController.simplifiedChinese);
    await tester.pumpAndSettle();
    await tester.tap(find.text('演讲卡片'));
    await tester.pumpAndSettle();

    expect(find.text('演讲卡片'), findsWidgets);
    expect(find.text('编辑卡片'), findsOneWidget);
    expect(find.text('开始练习'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
