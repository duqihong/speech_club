import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/bilingual_table_topics_content_bundle.dart';

class BilingualTableTopicsRepository {
  static const String _assetPath =
      'assets/content/table_topics/table_topics_bilingual.json';

  BilingualTableTopicsContentBundle? _cachedBundle;

  Future<BilingualTableTopicsContentBundle> load() async {
    if (_cachedBundle != null) {
      return _cachedBundle!;
    }

    final String raw = await rootBundle.loadString(_assetPath);
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
          'Table topics content must be a JSON object.');
    }

    final BilingualTableTopicsContentBundle bundle =
        BilingualTableTopicsContentBundle.fromJson(decoded);
    _cachedBundle = bundle;
    return bundle;
  }
}
