class TopicSet {
  TopicSet({required this.topics, required this.used}) {
    if (topics.length != 10) {
      throw ArgumentError('TopicSet.topics must have length 10.');
    }
    if (used.length != 10) {
      throw ArgumentError('TopicSet.used must have length 10.');
    }
  }

  factory TopicSet.fresh(List<String> topics) {
    return TopicSet(
      topics: topics,
      used: List<bool>.filled(10, false),
    );
  }

  final List<String> topics;
  final List<bool> used;

  TopicSet copyWith({List<String>? topics, List<bool>? used}) {
    return TopicSet(
      topics: topics ?? this.topics,
      used: used ?? this.used,
    );
  }
}
