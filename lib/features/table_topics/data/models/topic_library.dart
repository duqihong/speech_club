class TopicLibrary {
  TopicLibrary({required this.categories});

  final Map<String, List<String>> categories;

  List<String> get categoryNames => categories.keys.toList(growable: false);

  int get totalTopicCount => categories.values
      .fold<int>(0, (int sum, List<String> topics) => sum + topics.length);
}
