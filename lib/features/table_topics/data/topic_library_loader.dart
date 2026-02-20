import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/topic_library.dart';

class TopicLibraryLoader {
  Future<TopicLibrary> load() async {
    try {
      final String raw =
          await rootBundle.loadString('assets/table_topics/topics.json');
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Top-level JSON must be an object.');
      }

      final Map<String, List<String>> categories = <String, List<String>>{};
      decoded.forEach((String key, dynamic value) {
        if (value is! List) {
          throw FormatException('Category "$key" must be a JSON array.');
        }
        categories[key] = value
            .map((dynamic item) => item.toString())
            .map((String s) => s.trim())
            .where((String s) => s.isNotEmpty)
            .toList(growable: false);
      });

      return TopicLibrary(categories: categories);
    } catch (e) {
      throw Exception('Failed to load table topics library: $e');
    }
  }
}
