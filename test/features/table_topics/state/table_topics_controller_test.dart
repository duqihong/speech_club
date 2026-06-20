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

  const List<String> communicationTopics = <String>[
    'Effective Communication',
    'Resolving Misunderstanding',
    'Importance of Listening',
    'Speaking with Balance',
    'Silence Communicates',
    'A Warm Word',
    'Expressing True Thoughts',
    'Patience in Communication',
    'Hard Words to Say',
    'Communication Changes Relationships',
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('built-in generated topics re-render in the active locale', () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.setGeneratedTopics(
      communicationTopics,
      locale: const Locale('en'),
    );

    expect(controller.topicSet?.topics.first, 'Effective Communication');
    expect(controller.topicSet?.items.first.isBuiltIn, isTrue);

    await controller.init(locale: const Locale('zh'));

    expect(controller.topicSet?.topics.first, '一次有效沟通');
    expect(controller.topicSet?.items.first.topicId, 'tt_comm_001');
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

  test('stale pre-catalog built-ins do not reopen as blank topics', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      TableTopicsStorage.sessionKey: jsonEncode(<String, dynamic>{
        'version': 2,
        'randomAll': false,
        'selectedCategories': <String>['Friendship'],
        'items': List<Map<String, dynamic>>.generate(
          10,
          (int index) => <String, dynamic>{
            'sourceType': 'builtIn',
            'topicId': 'tt_${(index + 1).toString().padLeft(3, '0')}',
          },
        ),
        'used': List<bool>.filled(10, false),
        'isCustomMode': false,
      }),
    });

    final TableTopicsController controller = TableTopicsController();
    await controller.init(locale: const Locale('en'));

    expect(controller.topicSet, isNull);
    expect(controller.selection.randomAll, isFalse);
    expect(controller.selection.selectedCategories, <String>{'Communication'});
  });

  test('generate10 still produces a presenter-ready set', () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.generate10();

    expect(controller.topicSet?.topics, hasLength(10));
    expect(controller.topicSet?.used, hasLength(10));
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

  test('generate10 includes only selected English-origin expressions',
      () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.generateBuiltInTopics(
      selectedCategories: <String>{
        TableTopicsRepository.englishOriginExpressionsCategory,
      },
      locale: const Locale('en'),
    );

    expect(controller.topicSet?.topics, hasLength(10));
    expect(
      controller.topicSet?.items
          .map((item) => item.topicId!)
          .every((String id) => id.startsWith('tt_english_origin_')),
      isTrue,
    );
  });

  test('reset clears generated topic set and leaves a clean empty state',
      () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.generate10();
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

    expect(controller.topicSet?.topics, hasLength(10));
    expect(controller.topicSet?.items.every((item) => item.isBuiltIn), isTrue);
  });

  test('English-origin topics re-render in the active locale', () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    await controller.generateBuiltInTopics(
      selectedCategories: <String>{
        TableTopicsRepository.englishOriginExpressionsCategory,
      },
      locale: const Locale('en'),
    );

    final String englishTopic = controller.topicSet!.topics.first;
    final String firstId = controller.topicSet!.items.first.topicId!;

    expect(firstId.startsWith('tt_english_origin_'), isTrue);
    expect(englishTopic, isNot(contains('\n')));

    await controller.init(locale: const Locale('zh'));

    expect(controller.topicSet?.items.first.topicId, firstId);
    expect(controller.topicSet?.topics.first, isNot(englishTopic));
    expect(
      RegExp(r'[\u4E00-\u9FFF]').hasMatch(controller.topicSet!.topics.first),
      isTrue,
    );
  });

  test('selected final categories persist safely in session state', () async {
    final TableTopicsController controller = TableTopicsController();

    await controller.init(locale: const Locale('en'));
    controller.selection = CategorySelection(
      selectedCategories: <String>{
        TableTopicsRepository.chineseIdiomsCategory,
      },
      randomAll: false,
    );
    await controller.persistSession();

    await controller.init(locale: const Locale('zh'));

    expect(
      controller.selection.selectedCategories,
      contains(TableTopicsRepository.chineseIdiomsCategory),
    );
    expect(controller.selection.randomAll, isFalse);
  });

  test('edited built-in text converts safely to custom text', () async {
    final TableTopicsController controller = TableTopicsController();
    final List<String> editedTopics = List<String>.from(communicationTopics);
    editedTopics[1] = 'Edited freeform topic';

    await controller.init(locale: const Locale('en'));
    await controller.setGeneratedTopics(
      editedTopics,
      locale: const Locale('en'),
    );

    expect(controller.topicSet?.items.first.isBuiltIn, isTrue);
    expect(controller.topicSet?.items[1].isCustom, isTrue);
    expect(controller.topicSet?.items[1].customText, 'Edited freeform topic');
  });
}
