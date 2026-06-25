import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'online_count_models.dart';

class OnlineCountApiException implements Exception {
  const OnlineCountApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  final String code;
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class OnlineCountApi {
  OnlineCountApi({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = _normalizeBaseUrl(baseUrl ?? defaultBaseUrl),
        _client = client ?? http.Client();

  static const String defaultBaseUrl =
      'https://speech-club-vote-prototype.duduqihong.workers.dev';
  static const Duration _timeout = Duration(seconds: 15);

  final String baseUrl;
  final http.Client _client;

  Future<OnlineClub> createClub({
    required String clubName,
    required String clubSlug,
    required String adminPin,
  }) async {
    final Map<String, dynamic> json = await _postJson(
      '/api/admin/club',
      body: <String, String>{
        'clubName': clubName,
        'clubSlug': clubSlug,
        'adminPin': adminPin,
      },
    );
    return OnlineClub.fromJson(<String, dynamic>{
      ...json,
      'clubName': clubName,
    });
  }

  Future<OnlineSession> createSession({
    required String clubSlug,
    required String adminPin,
    required String meetingTitle,
    required String meetingDate,
  }) async {
    final Map<String, dynamic> json = await _postJson(
      '/api/admin/club/${Uri.encodeComponent(clubSlug)}/session',
      adminPin: adminPin,
      body: <String, String>{
        'meetingTitle': meetingTitle,
        'meetingDate': meetingDate,
      },
    );
    final List<OnlineAward> awards = _readList(json['awards'])
        .map(OnlineAward.fromJson)
        .toList(growable: false);
    return OnlineSession.fromJson(
      _readMap(json['session']),
      awards: awards,
    );
  }

  Future<List<OnlineCandidate>> replaceCandidates({
    required String sessionId,
    required String adminPin,
    required String awardType,
    required List<String> candidates,
  }) async {
    final Map<String, dynamic> json = await _postJson(
      '/api/admin/session/${Uri.encodeComponent(sessionId)}/candidates',
      adminPin: adminPin,
      body: <String, dynamic>{
        'awardType': awardType,
        'candidates': candidates,
      },
    );
    return _readList(json['candidates'])
        .map(OnlineCandidate.fromJson)
        .toList(growable: false);
  }

  Future<OnlineSession> openSession({
    required String sessionId,
    required String adminPin,
  }) async {
    final Map<String, dynamic> json = await _postJson(
      '/api/admin/session/${Uri.encodeComponent(sessionId)}/open',
      adminPin: adminPin,
    );
    return OnlineSession.fromJson(_readMap(json['session']));
  }

  Future<OnlineAward> openAward({
    required String sessionId,
    required String awardId,
    required String adminPin,
  }) async {
    final Map<String, dynamic> json = await _postJson(
      '/api/admin/session/${Uri.encodeComponent(sessionId)}/award/'
      '${Uri.encodeComponent(awardId)}/open',
      adminPin: adminPin,
    );
    return OnlineAward.fromJson(_readMap(json['award']));
  }

  Future<OnlineAward> closeAward({
    required String sessionId,
    required String awardId,
    required String adminPin,
  }) async {
    final Map<String, dynamic> json = await _postJson(
      '/api/admin/session/${Uri.encodeComponent(sessionId)}/award/'
      '${Uri.encodeComponent(awardId)}/close',
      adminPin: adminPin,
    );
    return OnlineAward.fromJson(_readMap(json['award']));
  }

  Future<OnlineSession> closeSession({
    required String sessionId,
    required String adminPin,
  }) async {
    final Map<String, dynamic> json = await _postJson(
      '/api/admin/session/${Uri.encodeComponent(sessionId)}/close',
      adminPin: adminPin,
    );
    return OnlineSession.fromJson(_readMap(json['session']));
  }

  Future<OnlineResults> getResults({
    required String sessionId,
    required String adminPin,
  }) async {
    final Map<String, dynamic> json = await _getJson(
      '/api/admin/session/${Uri.encodeComponent(sessionId)}/results',
      adminPin: adminPin,
    );
    return OnlineResults.fromJson(json);
  }

  String votingLinkForClub(String clubSlug, {String? lang}) {
    final String path = '$baseUrl/c/${Uri.encodeComponent(clubSlug)}';
    if (lang == 'zh' || lang == 'en') {
      return '$path?lang=$lang';
    }
    return path;
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    String? adminPin,
  }) async {
    final http.Response response = await _client
        .get(_uri(path), headers: _headers(adminPin))
        .timeout(_timeout);
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postJson(
    String path, {
    String? adminPin,
    Map<String, dynamic>? body,
  }) async {
    final http.Response response = await _client
        .post(
          _uri(path),
          headers: _headers(adminPin),
          body: jsonEncode(body ?? <String, dynamic>{}),
        )
        .timeout(_timeout);
    return _decodeResponse(response);
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers(String? adminPin) {
    return <String, String>{
      'Content-Type': 'application/json',
      if (adminPin != null) 'X-Admin-Pin': adminPin,
    };
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final Object? decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } on FormatException {
      throw OnlineCountApiException(
        code: 'BAD_RESPONSE',
        message: 'Could not read the online voting service response.',
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> json =
        decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (response.statusCode >= 400 || json['ok'] == false) {
      throw OnlineCountApiException(
        code: json['code']?.toString() ?? 'REQUEST_FAILED',
        message: json['message']?.toString() ??
            'Could not connect to online voting service.',
        statusCode: response.statusCode,
      );
    }
    return json;
  }

  static String _normalizeBaseUrl(String value) {
    final String trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}

Map<String, dynamic> _readMap(Object? value) {
  return value is Map<String, dynamic> ? value : <String, dynamic>{};
}

List<Map<String, dynamic>> _readList(Object? value) {
  if (value is! List<dynamic>) {
    return <Map<String, dynamic>>[];
  }
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}
