import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/features/table_topics/data/bilingual_table_topics_repository.dart';
import 'package:speech_club/features/table_topics/data/models/bilingual_table_topic_content.dart';
import 'package:speech_club/features/table_topics/data/models/category_selection.dart';
import 'package:speech_club/features/table_topics/data/models/table_topic_session_item.dart';
import 'package:speech_club/features/table_topics/data/table_topics_repository.dart';
import 'package:speech_club/features/table_topics/domain/topic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const List<String> finalCategories = <String>[
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
  ];

  int countChineseCharacters(String text) {
    return RegExp(r'[\u4E00-\u9FFF]').allMatches(text).length;
  }

  Future<List<BilingualTableTopicContent>> loadItems() async {
    final BilingualTableTopicsRepository repository =
        BilingualTableTopicsRepository();
    return (await repository.load()).items;
  }

  test('loads the final bilingual Table Topics catalog', () async {
    final BilingualTableTopicsRepository repository =
        BilingualTableTopicsRepository();

    final bundle = await repository.load();

    expect(bundle.version, 2);
    expect(bundle.items, hasLength(100));
    expect(bundle.items.first.id, 'tt_comm_001');
    expect(bundle.items.first.category, 'Communication');
    expect(
      bundle.items.first.text.forLocale(const Locale('en')),
      'Effective Communication',
    );
    expect(
      bundle.items.first.text.forLocale(const Locale('zh')),
      '一次有效沟通',
    );
  });

  test('catalog has the exact final category order and 10 paired topics each',
      () async {
    final List<BilingualTableTopicContent> items = await loadItems();
    final Map<String, List<BilingualTableTopicContent>> itemsByCategory =
        <String, List<BilingualTableTopicContent>>{};

    for (final BilingualTableTopicContent item in items) {
      final List<BilingualTableTopicContent> categoryItems =
          itemsByCategory.putIfAbsent(
        item.category,
        () => <BilingualTableTopicContent>[],
      );
      categoryItems.add(item);
    }

    expect(itemsByCategory.keys.toList(growable: false), finalCategories);
    for (final String category in finalCategories) {
      final List<BilingualTableTopicContent> categoryItems =
          itemsByCategory[category]!;
      expect(categoryItems, hasLength(10), reason: category);
      expect(
        categoryItems.every(
          (BilingualTableTopicContent item) => item.text.en.trim().isNotEmpty,
        ),
        isTrue,
        reason: '$category has a missing English topic',
      );
      expect(
        categoryItems.every(
          (BilingualTableTopicContent item) => item.text.zh.trim().isNotEmpty,
        ),
        isTrue,
        reason: '$category has a missing Chinese topic',
      );
    }
  });

  test('removed and non-final categories are absent', () async {
    final List<BilingualTableTopicContent> items = await loadItems();
    final Set<String> categories =
        items.map((BilingualTableTopicContent item) => item.category).toSet();

    for (final String category in <String>[
      'Culture',
      'Friendship',
      'Fun & Humor',
      'Values',
      'Chinese-Origin Expressions',
      'Family',
      'Technology',
      'Money',
      'Hobbies',
      'Leadership',
    ]) {
      expect(categories, isNot(contains(category)));
    }
  });

  test('all Chinese topics obey general and specialized length rules',
      () async {
    final List<BilingualTableTopicContent> items = await loadItems();

    for (final BilingualTableTopicContent item in items) {
      final int count = countChineseCharacters(item.text.zh);
      expect(
        count,
        inInclusiveRange(4, 10),
        reason: '${item.id} has $count Chinese characters: ${item.text.zh}',
      );
      if (item.category == TableTopicsRepository.chineseIdiomsCategory) {
        expect(count, 4, reason: item.text.zh);
      }
      if (item.category == TableTopicsRepository.classicalPoetryLinesCategory) {
        expect(count, 7, reason: item.text.zh);
      }
    }
  });

  test('Work and Career contains the requested concise topic pairs', () async {
    final List<BilingualTableTopicContent> items = await loadItems();
    final Map<String, String> workTopics = <String, String>{
      for (final BilingualTableTopicContent item in items.where(
        (BilingualTableTopicContent item) => item.category == 'Work & Career',
      ))
        item.text.zh: item.text.en,
    };

    expect(workTopics, containsPair('工作常被误解', 'Work Misunderstood'));
    expect(workTopics, containsPair('犯错后调整', 'Recovering from Mistakes'));
    expect(workTopics, containsPair('稳定还是成长', 'Stability or Growth'));
    expect(workTopics, containsPair('一次解决问题', 'Solving a Problem'));
    expect(workTopics, containsPair('苦学的技能', 'A Hard-Learned Skill'));
    expect(workTopics, containsPair('一个好主管', 'A Good Manager'));
    expect(workTopics, containsPair('我的职业目标', 'My Career Goal'));
    expect(workTopics, containsPair('最好的建议', 'Best Work Advice'));
    expect(workTopics, containsPair('面对截止日', 'Facing Deadlines'));
    expect(workTopics, containsPair('职场必练技能', 'Essential Work Skill'));
  });

  test('repository library preserves final category order and count', () async {
    final TableTopicsRepository repository = TableTopicsRepository();

    final englishLibrary =
        await repository.getLibrary(locale: const Locale('en'));
    final chineseLibrary =
        await repository.getLibrary(locale: const Locale('zh'));

    expect(englishLibrary.categoryNames, finalCategories);
    expect(chineseLibrary.categoryNames, finalCategories);
    expect(englishLibrary.totalTopicCount, 100);
    expect(chineseLibrary.totalTopicCount, 100);
    expect(
      chineseLibrary.categories['Chinese Idioms'],
      contains('塞翁失马'),
    );
    expect(
      chineseLibrary.categories['Classical Poetry Lines'],
      contains('春风又绿江南岸'),
    );
  });

  test('existing generation flow still returns 10 topics', () async {
    final TableTopicsRepository repository = TableTopicsRepository();
    final library = await repository.getLibrary(locale: const Locale('en'));

    final topicSet = generateTopicSet(
      library: library,
      selection: CategorySelection.defaults(),
    );

    expect(topicSet.topics, hasLength(10));
    expect(topicSet.used, hasLength(10));
  });

  test('built-in generation creates stable built-in session items', () async {
    final TableTopicsRepository repository = TableTopicsRepository();

    final topicSet = await repository.generateBuiltInTopicSet(
      selection: CategorySelection.defaults(),
      locale: const Locale('en'),
    );

    expect(topicSet.topics, hasLength(10));
    expect(topicSet.items, hasLength(10));
    expect(topicSet.items.every((item) => item.isBuiltIn), isTrue);
    expect(
      topicSet.items
          .map((TableTopicSessionItem item) => item.topicId!)
          .every((String id) => id.startsWith('tt_')),
      isTrue,
    );
  });

  test('selected English-origin expressions generate only that category',
      () async {
    final TableTopicsRepository repository = TableTopicsRepository();

    final topicSet = await repository.generateBuiltInTopicSet(
      selection: CategorySelection(
        selectedCategories: <String>{
          TableTopicsRepository.englishOriginExpressionsCategory,
        },
        randomAll: false,
      ),
      locale: const Locale('zh'),
    );

    expect(topicSet.items, hasLength(10));
    expect(
      topicSet.items.every(
        (item) => item.topicId!.startsWith('tt_english_origin_'),
      ),
      isTrue,
    );
    expect(topicSet.topics, contains('破冰的时刻'));
    expect(
      topicSet.topics.every((String topic) => !topic.contains('\n')),
      isTrue,
    );
  });
}
