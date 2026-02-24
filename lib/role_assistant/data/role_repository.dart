import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/role_model.dart';

class RoleRepository {
  List<RoleModel>? _cache;

  Future<List<RoleModel>> loadRoles() async {
    if (_cache != null) return _cache!;

    final jsonStr =
        await rootBundle.loadString('assets/role_assistant/roles.json');

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
          'roles.json must be a JSON array or an object with a "roles" array');
    }

    _cache = list
        .map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cache!;
  }
}
