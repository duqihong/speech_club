import '../data/models/category_selection.dart';
import '../data/models/topic_library.dart';

List<String> buildTopicPool({
  required TopicLibrary library,
  required CategorySelection selection,
}) {
  final List<String> allTopics = library.categories.values
      .expand((List<String> topics) => topics)
      .toList(growable: false);

  if (selection.randomAll) {
    return allTopics;
  }

  final List<String> selectedPool = selection.selectedCategories
      .where((String category) => library.categories.containsKey(category))
      .expand((String category) => library.categories[category] ?? <String>[])
      .toList(growable: false);

  if (selectedPool.length < 10) {
    return allTopics;
  }

  return selectedPool;
}
