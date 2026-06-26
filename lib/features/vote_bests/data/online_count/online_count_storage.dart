import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'online_count_api.dart';
import 'online_count_models.dart';

class OnlineCountSetup {
  const OnlineCountSetup({
    required this.ownerToken,
    required this.baseUrl,
    required this.clubName,
    required this.clubSlug,
    required this.adminPin,
    required this.currentSessionId,
    required this.currentSessionTitle,
    required this.currentSessionDate,
    required this.currentSessionStatus,
  });

  factory OnlineCountSetup.empty() {
    return OnlineCountSetup(
      ownerToken: '',
      baseUrl: OnlineCountApi.defaultBaseUrl,
      clubName: '',
      clubSlug: '',
      adminPin: '',
      currentSessionId: '',
      currentSessionTitle: 'Regular Meeting',
      currentSessionDate: '',
      currentSessionStatus: OnlineRoundStatus.draft.value,
    );
  }

  final String ownerToken;
  final String baseUrl;
  final String clubName;
  final String clubSlug;
  final String adminPin;
  final String currentSessionId;
  final String currentSessionTitle;
  final String currentSessionDate;
  final String currentSessionStatus;

  OnlineCountSetup copyWith({
    String? ownerToken,
    String? baseUrl,
    String? clubName,
    String? clubSlug,
    String? adminPin,
    String? currentSessionId,
    String? currentSessionTitle,
    String? currentSessionDate,
    String? currentSessionStatus,
  }) {
    return OnlineCountSetup(
      ownerToken: ownerToken ?? this.ownerToken,
      baseUrl: baseUrl ?? this.baseUrl,
      clubName: clubName ?? this.clubName,
      clubSlug: clubSlug ?? this.clubSlug,
      adminPin: adminPin ?? this.adminPin,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      currentSessionTitle: currentSessionTitle ?? this.currentSessionTitle,
      currentSessionDate: currentSessionDate ?? this.currentSessionDate,
      currentSessionStatus: currentSessionStatus ?? this.currentSessionStatus,
    );
  }
}

class OnlineCountStorage {
  static const String _ownerTokenKey = 'speech_club_online_owner_token_v1';
  static const String _baseUrlKey = 'speech_club_online_base_url_v1';
  static const String _clubNameKey = 'speech_club_online_club_name_v1';
  static const String _clubSlugKey = 'speech_club_online_club_slug_v1';
  static const String _adminPinKey = 'speech_club_online_admin_pin_v1';
  static const String _sessionIdKey =
      'speech_club_online_current_session_id_v1';
  static const String _sessionTitleKey =
      'speech_club_online_current_session_title_v1';
  static const String _sessionDateKey =
      'speech_club_online_current_session_date_v1';
  static const String _sessionStatusKey =
      'speech_club_online_current_session_status_v1';
  static const String _candidateDraftPrefix =
      'speech_club_online_candidate_draft_';

  Future<OnlineCountSetup> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String ownerToken = await _loadOrCreateOwnerToken(prefs);
    return OnlineCountSetup(
      ownerToken: ownerToken,
      baseUrl: prefs.getString(_baseUrlKey) ?? OnlineCountApi.defaultBaseUrl,
      clubName: prefs.getString(_clubNameKey) ?? '',
      clubSlug: prefs.getString(_clubSlugKey) ?? '',
      adminPin: prefs.getString(_adminPinKey) ?? '',
      currentSessionId: prefs.getString(_sessionIdKey) ?? '',
      currentSessionTitle:
          prefs.getString(_sessionTitleKey) ?? 'Regular Meeting',
      currentSessionDate: prefs.getString(_sessionDateKey) ?? '',
      currentSessionStatus:
          prefs.getString(_sessionStatusKey) ?? OnlineRoundStatus.draft.value,
    );
  }

  Future<void> saveSetup(OnlineCountSetup setup) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ownerTokenKey, setup.ownerToken);
    await prefs.setString(_baseUrlKey, setup.baseUrl);
    await prefs.setString(_clubNameKey, setup.clubName);
    await prefs.setString(_clubSlugKey, setup.clubSlug);
    await prefs.setString(_adminPinKey, setup.adminPin);
    await prefs.setString(_sessionIdKey, setup.currentSessionId);
    await prefs.setString(_sessionTitleKey, setup.currentSessionTitle);
    await prefs.setString(_sessionDateKey, setup.currentSessionDate);
    await prefs.setString(_sessionStatusKey, setup.currentSessionStatus);
  }

  Future<void> resetOnlineCountOnThisDevice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _loadOrCreateOwnerToken(prefs);
    await _clearLocalSetup(prefs);
    await _clearCandidateDrafts(prefs);
  }

  Future<void> startFreshOnThisDevice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ownerTokenKey, _generateOwnerToken());
    await _clearLocalSetup(prefs);
    await _clearCandidateDrafts(prefs);
  }

  Future<void> saveCandidateDraft({
    required String sessionId,
    required String awardType,
    required String text,
  }) async {
    if (sessionId.isEmpty || awardType.isEmpty) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_candidateDraftKey(sessionId, awardType), text);
  }

  Future<String?> loadCandidateDraft({
    required String sessionId,
    required String awardType,
  }) async {
    if (sessionId.isEmpty || awardType.isEmpty) {
      return null;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_candidateDraftKey(sessionId, awardType));
  }

  Future<void> clearCandidateDraftsForSession(String sessionId) async {
    if (sessionId.isEmpty) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _clearCandidateDrafts(
      prefs,
      sessionPrefix: _candidateDraftSessionPrefix(sessionId),
    );
  }

  Future<void> clearAllOnlineCandidateDrafts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _clearCandidateDrafts(prefs);
  }

  Future<void> _clearLocalSetup(SharedPreferences prefs) async {
    await prefs.setString(_baseUrlKey, OnlineCountApi.defaultBaseUrl);
    await prefs.remove(_clubNameKey);
    await prefs.remove(_clubSlugKey);
    await prefs.remove(_adminPinKey);
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_sessionTitleKey);
    await prefs.remove(_sessionDateKey);
    await prefs.remove(_sessionStatusKey);
  }

  Future<String> _loadOrCreateOwnerToken(SharedPreferences prefs) async {
    final String? existing = prefs.getString(_ownerTokenKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final String token = _generateOwnerToken();
    await prefs.setString(_ownerTokenKey, token);
    return token;
  }

  static String _generateOwnerToken() {
    final Random random = Random.secure();
    final int partA = random.nextInt(1 << 32);
    final int partB = random.nextInt(1 << 32);
    return 'owner-${DateTime.now().microsecondsSinceEpoch}-$partA-$partB';
  }

  static String _candidateDraftKey(String sessionId, String awardType) {
    return '${_candidateDraftSessionPrefix(sessionId)}'
        '${Uri.encodeComponent(awardType)}_v1';
  }

  static String _candidateDraftSessionPrefix(String sessionId) {
    return '$_candidateDraftPrefix${Uri.encodeComponent(sessionId)}_';
  }

  Future<void> _clearCandidateDrafts(
    SharedPreferences prefs, {
    String? sessionPrefix,
  }) async {
    final String prefix = sessionPrefix ?? _candidateDraftPrefix;
    final Iterable<String> keys = prefs
        .getKeys()
        .where((String key) => key.startsWith(prefix))
        .toList(growable: false);
    for (final String key in keys) {
      await prefs.remove(key);
    }
  }
}
