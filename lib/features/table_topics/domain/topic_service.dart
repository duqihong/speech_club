import 'dart:math';

import '../data/models/category_selection.dart';
import '../data/models/topic_library.dart';
import '../data/models/topic_set.dart';
import 'topic_generator.dart';
import 'topic_pool.dart';

TopicSet generateTopicSet({
  required TopicLibrary library,
  required CategorySelection selection,
  Random? random,
}) {
  final List<String> pool = buildTopicPool(
    library: library,
    selection: selection,
  );
  final List<String> topics = generateTenTopics(pool, random: random);
  return TopicSet.fresh(topics);
}
