import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/table_topics/ui/table_topics_setup_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder,
  ) async {
    for (int attempt = 0; attempt < 20; attempt += 1) {
      await tester.pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    expect(finder, findsWidgets);
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    required Locale locale,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TableTopicsSetupScreen(),
      ),
    );
    await pumpUntilFound(tester, find.byType(ChoiceChip));
  }

  List<String> categoryLabels(WidgetTester tester) {
    return tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .map((ChoiceChip chip) => (chip.label as Text).data!)
        .toList(growable: false);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('final categories and Chinese generation render correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    await pumpScreen(tester, locale: const Locale('zh'));

    expect(categoryLabels(tester), <String>[
      '沟通',
      '日常生活',
      '教育',
      '旅行',
      '工作与职业',
      '英语来源表达',
      '美食',
      '健康与运动',
      '成语',
      '诗句',
    ]);
    for (final String removed in <String>[
      '文化',
      '友情',
      '趣味幽默',
      '价值观',
      '中文来源表达',
    ]) {
      expect(find.text(removed), findsNothing);
    }
    expect(find.text('英语来源表达'), findsOneWidget);

    await pumpScreen(tester, locale: const Locale('en'));

    expect(categoryLabels(tester), <String>[
      'Communication',
      'Daily Life',
      'Education',
      'Travel',
      'Work & Career',
      'English-Origin Expressions',
      'Food',
      'Health & Exercise',
      'Chinese Idioms',
      'Classical Poetry Lines',
    ]);
    for (final String removed in <String>[
      'Culture',
      'Friendship',
      'Humor',
      'Values',
      'Chinese-Origin Expressions',
    ]) {
      expect(find.text(removed), findsNothing);
    }
    expect(find.text('English-Origin Expressions'), findsOneWidget);

    await pumpScreen(tester, locale: const Locale('zh'));

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
    await pumpUntilFound(
      tester,
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && RegExp(r'^1\. \S').hasMatch(widget.data ?? ''),
      ),
    );

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

    await tester.tap(find.text('编辑 10 个题目'));
    await tester.pumpAndSettle();
    expect(find.text('编辑题目'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    await tester.enterText(find.byType(TextField).first, '回归测试题目');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('1. 回归测试题目'), findsOneWidget);

    await tester.tap(find.text('展示模式'));
    await tester.pumpAndSettle();
    expect(find.text('展示模式'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('重置'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && RegExp(r'^\d+\. \S').hasMatch(widget.data ?? ''),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
