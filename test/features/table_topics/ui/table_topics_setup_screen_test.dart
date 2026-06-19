import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/table_topics/ui/table_topics_setup_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Chinese Work and Career generates 10 concise topics',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TableTopicsSetupScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final Finder categoryScrollerContainer = find.byWidgetPredicate(
      (Widget widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal,
    );
    final Finder categoryScroller = find.descendant(
      of: categoryScrollerContainer,
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('工作与职业'),
      200,
      scrollable: categoryScroller,
    );
    await tester.tap(find.text('工作与职业'));
    await tester.tap(find.text('生成 10 个题目'));
    await tester.pumpAndSettle();

    final List<String> renderedTopics = tester
        .widgetList<Text>(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is Text &&
                RegExp(r'^\d+\. \S').hasMatch(widget.data ?? ''),
          ),
        )
        .map((Text widget) => widget.data!.replaceFirst(RegExp(r'^\d+\. '), ''))
        .toList(growable: false);

    expect(renderedTopics, hasLength(10));
    for (final String topic in renderedTopics) {
      final int count = RegExp(r'[\u4E00-\u9FFF]').allMatches(topic).length;
      expect(count, inInclusiveRange(4, 10), reason: topic);
    }
    expect(tester.takeException(), isNull);
  });
}
