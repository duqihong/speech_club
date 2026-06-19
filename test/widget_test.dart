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

  testWidgets('English home screen shows all feature cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      SpeechClubApp(localeController: AppLocaleController()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Speech Club'), findsWidgets);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Expressions'), findsNothing);
    expect(find.text('Topic Selection'), findsOneWidget);
    expect(find.text('Table Topics'), findsOneWidget);
    expect(find.text('Role Assistant'), findsOneWidget);
    expect(find.text('Committees'), findsOneWidget);
    expect(find.text('Pathways'), findsOneWidget);
    expect(find.text('Vote Bests'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chinese home screen shows all feature cards',
      (WidgetTester tester) async {
    final AppLocaleController localeController = AppLocaleController();
    await localeController.setLocale(AppLocaleController.simplifiedChinese);

    await tester.pumpWidget(
      SpeechClubApp(localeController: localeController),
    );
    await tester.pumpAndSettle();

    for (final String title in <String>[
      '计时器',
      '演讲卡片',
      '选题助手',
      '即席演讲',
      '角色助手',
      '委员职责',
      '学习路径',
      '最佳投票',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home grid has no overflow on an iPhone 11-sized viewport',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      SpeechClubApp(localeController: AppLocaleController()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
