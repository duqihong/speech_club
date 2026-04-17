import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/features/table_topics/data/bilingual_table_topics_repository.dart';
import 'package:speech_club/features/table_topics/data/models/category_selection.dart';
import 'package:speech_club/features/table_topics/data/table_topics_repository.dart';
import 'package:speech_club/features/table_topics/domain/topic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      'Describe your ideal weekday routine.',
    );
    expect(
      firstItem.text.forLocale(const Locale('zh')),
      '请描述你理想中的平日作息。',
    );
  });

  test('maps repository-backed built-in topics into the existing library shape',
      () async {
    final TableTopicsRepository repository = TableTopicsRepository();

    final library = await repository.getLibrary(locale: const Locale('zh'));

    expect(library.categoryNames, contains('Daily Life'));
    expect(library.totalTopicCount, 200);
    expect(library.categories['Daily Life']?.first, '请描述你理想中的平日作息。');
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
}
