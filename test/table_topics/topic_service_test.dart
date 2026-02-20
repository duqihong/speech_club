import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/features/table_topics/data/models/category_selection.dart';
import 'package:speech_club/features/table_topics/data/models/topic_library.dart';
import 'package:speech_club/features/table_topics/domain/topic_pool.dart';
import 'package:speech_club/features/table_topics/domain/topic_service.dart';

void main() {
  group('Table Topics domain', () {
    test('With small pool (9 total), still returns 10 topics', () {
      final TopicLibrary library =
          TopicLibrary(categories: <String, List<String>>{
        'A': List<String>.generate(5, (int i) => 'A$i'),
        'B': List<String>.generate(4, (int i) => 'B$i'),
      });

      final result = generateTopicSet(
        library: library,
        selection: CategorySelection.defaults(),
        random: Random(42),
      );

      expect(result.topics.length, 10);
      expect(result.used.length, 10);
      expect(result.topics.toSet().length, lessThanOrEqualTo(9));
    });

    test('With larger pool, returns 10 topics and mostly unique', () {
      final TopicLibrary library =
          TopicLibrary(categories: <String, List<String>>{
        'Big': List<String>.generate(20, (int i) => 'Topic $i'),
      });

      final result = generateTopicSet(
        library: library,
        selection: CategorySelection.defaults(),
        random: Random(7),
      );

      expect(result.topics.length, 10);
      expect(result.topics.toSet().length, greaterThanOrEqualTo(9));
    });

    test(
      'With randomAll=false and selected Daily Life, pool is selected category or fallback',
      () {
        final TopicLibrary library = TopicLibrary(
          categories: <String, List<String>>{
            'Daily Life': List<String>.generate(12, (int i) => 'Daily $i'),
            'Travel': List<String>.generate(6, (int i) => 'Travel $i'),
          },
        );
        final CategorySelection selection = CategorySelection(
          selectedCategories: <String>{'Daily Life'},
          randomAll: false,
        );

        final List<String> pool = buildTopicPool(
          library: library,
          selection: selection,
        );

        expect(pool.length, 12);
        expect(pool.every((String topic) => topic.startsWith('Daily')), isTrue);
      },
    );

    test('With randomAll=false and empty selectedCategories, falls back to all',
        () {
      final TopicLibrary library = TopicLibrary(
        categories: <String, List<String>>{
          'Daily Life': List<String>.generate(3, (int i) => 'Daily $i'),
          'Travel': List<String>.generate(8, (int i) => 'Travel $i'),
        },
      );
      final CategorySelection selection = CategorySelection(
        selectedCategories: <String>{},
        randomAll: false,
      );

      final List<String> pool = buildTopicPool(
        library: library,
        selection: selection,
      );

      expect(pool.length, 11);
      expect(pool.any((String t) => t.startsWith('Daily')), isTrue);
      expect(pool.any((String t) => t.startsWith('Travel')), isTrue);
    });
  });
}
