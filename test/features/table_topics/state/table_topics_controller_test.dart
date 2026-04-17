import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/table_topics/data/models/category_selection.dart';
import 'package:speech_club/features/table_topics/data/table_topics_repository.dart';
import 'package:speech_club/features/table_topics/data/table_topics_storage.dart';
import 'package:speech_club/features/table_topics/state/table_topics_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('built-in generated topics re-render in the active locale', () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.setGeneratedTopics(
      <String>[
        'Describe your ideal weekday routine.',
        'What is one small habit that improves your day?',
        'How do you usually relax after work or school?',
        'What chore do you dislike the most and why?',
        'What is your favorite part of the day?',
        'How do you stay organized during a busy week?',
        'What is something simple you enjoy doing alone?',
        'Describe a daily routine from your childhood.',
        'What is one thing you always carry with you?',
        'How has your morning routine changed over time?',
      ],
      locale: const Locale('en'),
    );

    expect(controller.topicSet?.topics.first,
        'Describe your ideal weekday routine.');
    expect(controller.topicSet?.items.first.isBuiltIn, isTrue);

    await controller.init(locale: const Locale('zh'));

    expect(controller.topicSet?.topics.first, '请描述你理想中的平日作息。');
    expect(controller.topicSet?.items.first.topicId, 'tt_001');
  });

  test('custom topics stay unchanged across locale switches', () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    controller.useCustomTopics(<String>[
      'My custom topic',
      'Another custom topic',
    ]);

    expect(controller.topicSet?.topics.first, 'My custom topic');
    expect(controller.topicSet?.items.first.isCustom, isTrue);

    await controller.init(locale: const Locale('zh'));

    expect(controller.topicSet?.topics.first, 'My custom topic');
    expect(controller.topicSet?.items.first.customText, 'My custom topic');
  });

  test('legacy plain-string session data still loads safely', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      TableTopicsStorage.sessionKey: jsonEncode(<String, dynamic>{
        'version': 1,
        'randomAll': true,
        'selectedCategories': <String>[],
        'topics': <String>[
          'Legacy topic 1',
          'Legacy topic 2',
          'Legacy topic 3',
          'Legacy topic 4',
          'Legacy topic 5',
          'Legacy topic 6',
          'Legacy topic 7',
          'Legacy topic 8',
          'Legacy topic 9',
          'Legacy topic 10',
        ],
        'used': List<bool>.filled(10, false),
        'isCustomMode': false,
      }),
    });

    final TableTopicsController controller = TableTopicsController();
    await controller.init(locale: const Locale('zh'));

    expect(controller.topicSet?.topics.first, 'Legacy topic 1');
    expect(controller.topicSet?.items.first.isCustom, isTrue);
  });

  test('generate10 still produces a presenter-ready set', () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.generate10();

    expect(controller.topicSet?.topics.length, 10);
    expect(controller.topicSet?.used.length, 10);
    expect(
      controller.topicSet?.items.every((item) => item.isBuiltIn),
      isTrue,
    );
    expect(
      controller.topicSet?.items
          .map((item) => item.topicId!)
          .every((String id) => id.startsWith('tt_')),
      isTrue,
    );
  });

  test('generate10 includes only selected English source expressions',
      () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.generateBuiltInTopics(
      selectedCategories: <String>{
        TableTopicsRepository.englishSourceExpressionsCategory,
      },
      locale: const Locale('en'),
    );

    expect(
      controller.topicSet?.items
          .map((item) => item.topicId!)
          .every((String id) => id.startsWith('expr_en_')),
      isTrue,
    );
  });

  test('generate10 includes only selected Chinese source expressions',
      () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('zh'));
    await controller.generateBuiltInTopics(
      selectedCategories: <String>{
        TableTopicsRepository.chineseSourceExpressionsCategory,
      },
      locale: const Locale('zh'),
    );

    expect(
      controller.topicSet?.items
          .map((item) => item.topicId!)
          .every((String id) => id.startsWith('expr_zh_')),
      isTrue,
    );
  });

  test('reset clears generated topic set and leaves a clean empty state',
      () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.generate10();

    expect(controller.topicSet?.topics.length, 10);

    await controller.resetSession();

    expect(controller.topicSet, isNull);
    expect(controller.selection.selectedCategories, isEmpty);
    expect(controller.selection.randomAll, isTrue);
    expect(controller.isCustomMode, isFalse);
  });

  test('reset clears persisted generated session so old topics do not reload',
      () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.generate10();
    final String previousFirstTopic = controller.topicSet!.topics.first;

    await controller.resetSession();
    await controller.init(locale: const Locale('en'));

    expect(controller.topicSet, isNull);
    expect(controller.selection.selectedCategories, isEmpty);
    expect(controller.selection.randomAll, isTrue);
    expect(previousFirstTopic, isNotEmpty);
  });

  test('generate still works normally after reset', () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.generate10();
    await controller.resetSession();
    await controller.generate10();

    expect(controller.topicSet?.topics.length, 10);
    expect(controller.topicSet?.items.every((item) => item.isBuiltIn), isTrue);
  });

  test(
      'expression built-ins keep source-first paired display across locale switches',
      () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.generateBuiltInTopics(
      selectedCategories: <String>{
        TableTopicsRepository.englishSourceExpressionsCategory,
      },
      locale: const Locale('en'),
    );

    final String firstTopic = controller.topicSet!.topics.first;
    final String firstId = controller.topicSet!.items.first.topicId!;

    expect(firstId.startsWith('expr_en_'), isTrue);
    expect(firstTopic, contains('\n'));

    await controller.init(locale: const Locale('zh'));

    expect(controller.topicSet?.items.first.topicId, firstId);
    expect(controller.topicSet?.topics.first, firstTopic);
  });

  test('selected expression categories persist safely in session state',
      () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    controller.selection = CategorySelection(
      selectedCategories: <String>{
        TableTopicsRepository.chineseSourceExpressionsCategory,
      },
      randomAll: false,
    );
    await controller.persistSession();

    await controller.init(locale: const Locale('zh'));

    expect(
      controller.selection.selectedCategories,
      contains(TableTopicsRepository.chineseSourceExpressionsCategory),
    );
    expect(controller.selection.randomAll, isFalse);
  });

  test('edited built-in text converts safely to custom text', () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.setGeneratedTopics(
      <String>[
        'Describe your ideal weekday routine.',
        'Edited freeform topic',
        'How do you usually relax after work or school?',
        'What chore do you dislike the most and why?',
        'What is your favorite part of the day?',
        'How do you stay organized during a busy week?',
        'What is something simple you enjoy doing alone?',
        'Describe a daily routine from your childhood.',
        'What is one thing you always carry with you?',
        'How has your morning routine changed over time?',
      ],
      locale: const Locale('en'),
    );

    expect(controller.topicSet?.items.first.isBuiltIn, isTrue);
    expect(controller.topicSet?.items[1].isCustom, isTrue);
    expect(controller.topicSet?.items[1].customText, 'Edited freeform topic');
  });
}
