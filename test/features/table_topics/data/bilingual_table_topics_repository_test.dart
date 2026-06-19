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

  int countChineseCharacters(String text) {
    return RegExp(r'[\u4E00-\u9FFF]').allMatches(text).length;
  }

  test('loads bilingual table topics content from assets', () async {
    final BilingualTableTopicsRepository repository =
        BilingualTableTopicsRepository();

    final bundle = await repository.load();

    expect(bundle.version, 1);
    expect(bundle.items.length, 200);
    expect(bundle.items.first.id, 'tt_001');
    expect(bundle.items.first.category, 'Daily Life');
  });

  test('resolves bilingual table topic text by locale', () async {
    final BilingualTableTopicsRepository repository =
        BilingualTableTopicsRepository();

    final bundle = await repository.load();
    final firstItem = bundle.items.first;

    expect(
      firstItem.text.forLocale(const Locale('en')),
      'Ideal Weekday Routine',
    );
    expect(
      firstItem.text.forLocale(const Locale('zh')),
      '理想平日作息',
    );
  });

  test('all Chinese topics have 4 to 10 Chinese characters', () async {
    final BilingualTableTopicsRepository repository =
        BilingualTableTopicsRepository();

    final bundle = await repository.load();

    for (final BilingualTableTopicContent item in bundle.items) {
      final int count = countChineseCharacters(item.text.zh);
      expect(
        count,
        inInclusiveRange(4, 10),
        reason: '${item.id} has $count Chinese characters: ${item.text.zh}',
      );
    }
  });

  test('every category has matching non-empty Chinese and English topics',
      () async {
    final BilingualTableTopicsRepository repository =
        BilingualTableTopicsRepository();

    final bundle = await repository.load();
    final Map<String, List<BilingualTableTopicContent>> itemsByCategory =
        <String, List<BilingualTableTopicContent>>{};

    for (final BilingualTableTopicContent item in bundle.items) {
      final List<BilingualTableTopicContent> categoryItems =
          itemsByCategory.putIfAbsent(
        item.category,
        () => <BilingualTableTopicContent>[],
      );
      categoryItems.add(item);
    }

    expect(itemsByCategory, isNotEmpty);
    for (final MapEntry<String, List<BilingualTableTopicContent>> entry
        in itemsByCategory.entries) {
      final List<String> englishTopics = entry.value
          .map((BilingualTableTopicContent item) => item.text.en.trim())
          .where((String text) => text.isNotEmpty)
          .toList(growable: false);
      final List<String> chineseTopics = entry.value
          .map((BilingualTableTopicContent item) => item.text.zh.trim())
          .where((String text) => text.isNotEmpty)
          .toList(growable: false);

      expect(entry.value, isNotEmpty, reason: '${entry.key} is empty');
      expect(englishTopics, hasLength(entry.value.length));
      expect(chineseTopics, hasLength(entry.value.length));
      expect(chineseTopics.length, englishTopics.length);
    }
  });

  test('Work and Career contains the requested concise topic pairs', () async {
    final BilingualTableTopicsRepository repository =
        BilingualTableTopicsRepository();

    final bundle = await repository.load();
    final Map<String, String> workTopics = <String, String>{
      for (final BilingualTableTopicContent item in bundle.items.where(
          (BilingualTableTopicContent item) =>
              item.category == 'Work & Career'))
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

  test('maps repository-backed built-in topics into the existing library shape',
      () async {
    final TableTopicsRepository repository = TableTopicsRepository();

    final library = await repository.getLibrary(locale: const Locale('zh'));

    expect(library.categoryNames, contains('Daily Life'));
    expect(
      library.categoryNames,
      contains(TableTopicsRepository.englishSourceExpressionsCategory),
    );
    expect(
      library.categoryNames,
      contains(TableTopicsRepository.chineseSourceExpressionsCategory),
    );
    expect(library.totalTopicCount, 400);
    expect(library.categories['Daily Life']?.first, '理想平日作息');
    expect(
      library.categories[TableTopicsRepository.englishSourceExpressionsCategory]
          ?.first,
      'Break the ice\n打破僵局',
    );
    expect(
      library.categories[TableTopicsRepository.chineseSourceExpressionsCategory]
          ?.first,
      '勇敢迈出第一步\nTake the first step bravely',
    );
  });

  test('existing generation flow still returns 10 topics from built-in content',
      () async {
    final TableTopicsRepository repository = TableTopicsRepository();
    final library = await repository.getLibrary(locale: const Locale('en'));

    final topicSet = generateTopicSet(
      library: library,
      selection: CategorySelection.defaults(),
    );

    expect(topicSet.topics.length, 10);
    expect(topicSet.used.length, 10);
  });

  test('built-in generation creates stable built-in session items directly',
      () async {
    final TableTopicsRepository repository = TableTopicsRepository();

    final topicSet = await repository.generateBuiltInTopicSet(
      selection: CategorySelection.defaults(),
      locale: const Locale('en'),
    );

    expect(topicSet.topics.length, 10);
    expect(topicSet.items.length, 10);
    expect(topicSet.items.every((item) => item.isBuiltIn), isTrue);
    expect(topicSet.items.every((item) => item.topicId != null), isTrue);
  });

  test(
      'default built-in generation excludes expression categories when none are selected',
      () async {
    final TableTopicsRepository repository = TableTopicsRepository();
    final topicSet = await repository.generateBuiltInTopicSet(
      selection: CategorySelection.defaults(),
      locale: const Locale('en'),
    );

    expect(
      topicSet.items
          .map((TableTopicSessionItem item) => item.topicId!)
          .every((String id) => id.startsWith('tt_')),
      isTrue,
    );
    expect(
      topicSet.topics.every((String topic) => !topic.contains('\n')),
      isTrue,
    );
  });

  test(
      'english source expressions category generates built-in expression items',
      () async {
    final TableTopicsRepository repository = TableTopicsRepository();

    final topicSet = await repository.generateBuiltInTopicSet(
      selection: CategorySelection(
        selectedCategories: <String>{
          TableTopicsRepository.englishSourceExpressionsCategory,
        },
        randomAll: false,
      ),
      locale: const Locale('zh'),
    );

    expect(topicSet.items.every((item) => item.isBuiltIn), isTrue);
    expect(
      topicSet.items.every((item) => item.topicId!.startsWith('expr_en_')),
      isTrue,
    );
    expect(
      topicSet.topics.every(
        (topic) => topic.contains('\n') && topic.indexOf('\n') > 0,
      ),
      isTrue,
    );
  });

  test(
      'selected English source expressions do not pull in unselected Chinese source expressions',
      () async {
    final TableTopicsRepository repository = TableTopicsRepository();

    final topicSet = await repository.generateBuiltInTopicSet(
      selection: CategorySelection(
        selectedCategories: <String>{
          'Daily Life',
          TableTopicsRepository.englishSourceExpressionsCategory,
        },
        randomAll: false,
      ),
      locale: const Locale('en'),
    );

    expect(
      topicSet.items
          .map((TableTopicSessionItem item) => item.topicId!)
          .every((String id) => !id.startsWith('expr_zh_')),
      isTrue,
    );
  });

  test(
      'chinese source expressions category generates built-in expression items',
      () async {
    final TableTopicsRepository repository = TableTopicsRepository();

    final topicSet = await repository.generateBuiltInTopicSet(
      selection: CategorySelection(
        selectedCategories: <String>{
          TableTopicsRepository.chineseSourceExpressionsCategory,
        },
        randomAll: false,
      ),
      locale: const Locale('en'),
    );

    expect(topicSet.items.every((item) => item.isBuiltIn), isTrue);
    expect(
      topicSet.items.every((item) => item.topicId!.startsWith('expr_zh_')),
      isTrue,
    );
    expect(
      topicSet.topics.every(
        (topic) => topic.contains('\n') && topic.indexOf('\n') > 0,
      ),
      isTrue,
    );
  });

  test(
      'selected Chinese source expressions do not pull in unselected English source expressions',
      () async {
    final TableTopicsRepository repository = TableTopicsRepository();

    final topicSet = await repository.generateBuiltInTopicSet(
      selection: CategorySelection(
        selectedCategories: <String>{
          'Daily Life',
          TableTopicsRepository.chineseSourceExpressionsCategory,
        },
        randomAll: false,
      ),
      locale: const Locale('zh'),
    );

    expect(
      topicSet.items
          .map((TableTopicSessionItem item) => item.topicId!)
          .every((String id) => !id.startsWith('expr_en_')),
      isTrue,
    );
  });
}
