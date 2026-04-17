import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/expression_content_bundle.dart';

class ExpressionContentRepository {
  static const String _englishSourceAssetPath =
      'assets/content/expressions/expressions_en_source.json';
  static const String _chineseSourceAssetPath =
      'assets/content/expressions/expressions_zh_source.json';

  final Map<String, ExpressionContentBundle> _cacheByAsset =
      <String, ExpressionContentBundle>{};

  Future<ExpressionContentBundle> loadEnglishSource() {
    return _load(_englishSourceAssetPath);
  }

  Future<ExpressionContentBundle> loadChineseSource() {
    return _load(_chineseSourceAssetPath);
  }

  Future<ExpressionContentBundle> _load(String assetPath) async {
    final ExpressionContentBundle? cached = _cacheByAsset[assetPath];
    if (cached != null) {
      return cached;
    }

    final String raw = await rootBundle.loadString(assetPath);
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('$assetPath must be a JSON object.');
    }

    final ExpressionContentBundle bundle =
        ExpressionContentBundle.fromJson(decoded);
    _cacheByAsset[assetPath] = bundle;
    return bundle;
  }
}
