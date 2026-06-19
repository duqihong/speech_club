import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    int renderedLineCount(String title) {
      final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
        find.text(title),
      );
      return paragraph
          .getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: title.length),
          )
          .map((TextBox box) => box.top)
          .toSet()
          .length;
    }

    for (final String title in <String>[
      'Timer',
      'Speaker',
      'Committees',
      'Pathways',
    ]) {
      expect(renderedLineCount(title), 1,
          reason: '$title should stay on one line');
    }
    expect(renderedLineCount('Topic Selection'), 2);
    expect(renderedLineCount('Role Assistant'), 2);
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
    tester.view.padding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      SpeechClubApp(localeController: AppLocaleController()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();

    final Finder voteBestsCard = find.ancestor(
      of: find.text('Vote Bests'),
      matching: find.byType(InkWell),
    );
    expect(tester.getBottomRight(voteBestsCard).dy, lessThanOrEqualTo(862));
    expect(tester.takeException(), isNull);
  });
}
