import 'table_topic_session_item.dart';

class TopicSet {
  TopicSet({
    required this.items,
    required this.topics,
    required this.used,
  }) {
    if (items.length != 10) {
      throw ArgumentError('TopicSet.items must have length 10.');
    }
    if (topics.length != 10) {
      throw ArgumentError('TopicSet.topics must have length 10.');
    }
    if (used.length != 10) {
      throw ArgumentError('TopicSet.used must have length 10.');
    }
  }

  factory TopicSet.fresh(List<String> topics) {
    return TopicSet(
      items: topics.map(TableTopicSessionItem.custom).toList(growable: false),
      topics: topics,
      used: List<bool>.filled(10, false),
    );
  }

  factory TopicSet.fromItems({
    required List<TableTopicSessionItem> items,
    required List<String> topics,
    List<bool>? used,
  }) {
    return TopicSet(
      items: items,
      topics: topics,
      used: used ?? List<bool>.filled(10, false),
    );
  }

  final List<TableTopicSessionItem> items;
  final List<String> topics;
  final List<bool> used;

  TopicSet copyWith({
    List<TableTopicSessionItem>? items,
    List<String>? topics,
    List<bool>? used,
  }) {
    return TopicSet(
      items: items ?? this.items,
      topics: topics ?? this.topics,
      used: used ?? this.used,
    );
  }
}
