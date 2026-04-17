import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';

import '../models/role_model.dart';

class RoleRepository {
  static final Map<String, List<RoleModel>> _cacheByAsset =
      <String, List<RoleModel>>{};

  Future<List<RoleModel>> loadRoles({required Locale locale}) async {
    final String assetPath = _assetPathForLocale(locale);
    final List<RoleModel>? cached = _cacheByAsset[assetPath];
    if (cached != null) {
      return cached;
    }

    final String jsonStr = await rootBundle.loadString(assetPath);

    final dynamic decoded = jsonDecode(jsonStr);

    // Support BOTH formats:
    // 1) [ {...}, {...} ]
    // 2) { "roles": [ {...}, {...} ] }
    final List<dynamic> list;

    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['roles'] is List) {
      list = decoded['roles'] as List<dynamic>;
    } else {
      throw Exception(
          '$assetPath must be a JSON array or an object with a "roles" array');
    }

    final List<RoleModel> roles =
        list.map((e) => RoleModel.fromJson(e as Map<String, dynamic>)).toList();
    _cacheByAsset[assetPath] = roles;

    return roles;
  }

  String _assetPathForLocale(Locale locale) {
    if (locale.languageCode == 'zh') {
      return 'assets/role_assistant/roles_zh.json';
    }

    return 'assets/role_assistant/roles_en.json';
  }
}
