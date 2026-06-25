import 'package:shared_preferences/shared_preferences.dart';

import 'online_count_api.dart';

class OnlineCountSetup {
  const OnlineCountSetup({
    required this.baseUrl,
    required this.clubName,
    required this.clubSlug,
    required this.adminPin,
    required this.currentSessionId,
    required this.currentSessionTitle,
    required this.currentSessionDate,
  });

  factory OnlineCountSetup.empty() {
    return const OnlineCountSetup(
      baseUrl: OnlineCountApi.defaultBaseUrl,
      clubName: '',
      clubSlug: '',
      adminPin: '',
      currentSessionId: '',
      currentSessionTitle: 'Regular Meeting',
      currentSessionDate: '',
    );
  }

  final String baseUrl;
  final String clubName;
  final String clubSlug;
  final String adminPin;
  final String currentSessionId;
  final String currentSessionTitle;
  final String currentSessionDate;

  OnlineCountSetup copyWith({
    String? baseUrl,
    String? clubName,
    String? clubSlug,
    String? adminPin,
    String? currentSessionId,
    String? currentSessionTitle,
    String? currentSessionDate,
  }) {
    return OnlineCountSetup(
      baseUrl: baseUrl ?? this.baseUrl,
      clubName: clubName ?? this.clubName,
      clubSlug: clubSlug ?? this.clubSlug,
      adminPin: adminPin ?? this.adminPin,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      currentSessionTitle: currentSessionTitle ?? this.currentSessionTitle,
      currentSessionDate: currentSessionDate ?? this.currentSessionDate,
    );
  }
}

class OnlineCountStorage {
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

  Future<OnlineCountSetup> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return OnlineCountSetup(
      baseUrl: prefs.getString(_baseUrlKey) ?? OnlineCountApi.defaultBaseUrl,
      clubName: prefs.getString(_clubNameKey) ?? '',
      clubSlug: prefs.getString(_clubSlugKey) ?? '',
      adminPin: prefs.getString(_adminPinKey) ?? '',
      currentSessionId: prefs.getString(_sessionIdKey) ?? '',
      currentSessionTitle:
          prefs.getString(_sessionTitleKey) ?? 'Regular Meeting',
      currentSessionDate: prefs.getString(_sessionDateKey) ?? '',
    );
  }

  Future<void> saveSetup(OnlineCountSetup setup) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, setup.baseUrl);
    await prefs.setString(_clubNameKey, setup.clubName);
    await prefs.setString(_clubSlugKey, setup.clubSlug);
    await prefs.setString(_adminPinKey, setup.adminPin);
    await prefs.setString(_sessionIdKey, setup.currentSessionId);
    await prefs.setString(_sessionTitleKey, setup.currentSessionTitle);
    await prefs.setString(_sessionDateKey, setup.currentSessionDate);
  }
}
