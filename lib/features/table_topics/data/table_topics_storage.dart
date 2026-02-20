import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/table_topics_session.dart';

class TableTopicsStorage {
  static const String sessionKey = 'table_topics.session_v1';
  static const String customKey = 'table_topics.custom_topics_v1';

  Future<void> saveSession(TableTopicsSession session) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sessionKey, jsonEncode(session.toJson()));
  }

  Future<TableTopicsSession?> loadSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return TableTopicsSession.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionKey);
  }

  Future<void> saveCustomTopics(List<String> topics) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(customKey, jsonEncode(topics));
  }

  Future<List<String>> loadCustomTopics() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(customKey);
    if (raw == null || raw.isEmpty) {
      return <String>[];
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return <String>[];
      }
      return decoded
          .map((dynamic e) => e.toString())
          .map((String e) => e.trim())
          .where((String e) => e.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return <String>[];
    }
  }
}
