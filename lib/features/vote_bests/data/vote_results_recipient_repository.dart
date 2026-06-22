import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'vote_results_recipient.dart';

class VoteResultsRecipientRepository {
  VoteResultsRecipientRepository({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  static const String storageKey =
      'speech_club_vote_bests_president_contact_v1';

  final DateTime Function() _now;

  Future<VoteResultsRecipient?> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final VoteResultsRecipient recipient =
          VoteResultsRecipient.fromJson(decoded);
      if (recipient.name.isEmpty || recipient.phoneNumber.isEmpty) {
        return null;
      }
      return recipient;
    } catch (_) {
      return null;
    }
  }

  Future<VoteResultsRecipient> save({
    required String name,
    required String phoneNumber,
  }) async {
    final String trimmedName = name.trim();
    final String trimmedPhoneNumber = phoneNumber.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'President name is required.');
    }
    if (trimmedPhoneNumber.isEmpty) {
      throw ArgumentError.value(
        phoneNumber,
        'phoneNumber',
        'Phone number is required.',
      );
    }

    final VoteResultsRecipient recipient = VoteResultsRecipient(
      name: trimmedName,
      phoneNumber: trimmedPhoneNumber,
      updatedAt: _now(),
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(recipient.toJson()));
    return recipient;
  }
}
