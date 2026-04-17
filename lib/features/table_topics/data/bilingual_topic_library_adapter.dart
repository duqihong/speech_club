import 'dart:ui';

import 'models/bilingual_table_topics_content_bundle.dart';
import 'models/topic_library.dart';

class BilingualTopicLibraryAdapter {
  const BilingualTopicLibraryAdapter();

  TopicLibrary toTopicLibrary({
    required BilingualTableTopicsContentBundle bundle,
    required Locale locale,
  }) {
    final Map<String, List<String>> categories = <String, List<String>>{};

    for (final item in bundle.items) {
      final String text = item.text.forLocale(locale).trim();
      if (text.isEmpty) {
        continue;
      }

      categories.putIfAbsent(item.category, () => <String>[]).add(text);
    }

    return TopicLibrary(categories: categories);
  }
}
