import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'my_speech_deck.dart';

class MySpeechStorage {
  static const String key = 'flashcards_my_speech_v1';

  Future<MySpeechDeck> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return MySpeechDeck.empty();
    }

    try {
      final Map<String, dynamic> map = json.decode(raw) as Map<String, dynamic>;
      return MySpeechDeck.fromJson(map);
    } catch (_) {
      return MySpeechDeck.empty();
    }
  }

  Future<void> save(MySpeechDeck deck) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = json.encode(deck.toJson());
    await prefs.setString(key, raw);
  }
}
