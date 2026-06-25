import 'dart:ui';

enum OnlineAwardType {
  bestSpeaker('best_speaker'),
  bestTableTopics('best_table_topics'),
  bestEvaluator('best_evaluator');

  const OnlineAwardType(this.value);

  final String value;

  static OnlineAwardType? fromValue(String value) {
    for (final OnlineAwardType type in OnlineAwardType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }
}

enum OnlineRoundStatus {
  draft('draft'),
  open('open'),
  closed('closed');

  const OnlineRoundStatus(this.value);

  final String value;

  static OnlineRoundStatus fromValue(String? value) {
    for (final OnlineRoundStatus status in OnlineRoundStatus.values) {
      if (status.value == value) {
        return status;
      }
    }
    return OnlineRoundStatus.draft;
  }
}

class OnlineClub {
  const OnlineClub({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;

  factory OnlineClub.fromJson(Map<String, dynamic> json) {
    return OnlineClub(
      id: _readString(json, 'clubId', 'club_id'),
      name: _readString(json, 'clubName', 'club_name'),
      slug: _readString(json, 'clubSlug', 'club_slug'),
    );
  }
}

class OnlineSession {
  const OnlineSession({
    required this.id,
    required this.clubId,
    required this.meetingTitle,
    required this.meetingDate,
    required this.status,
    this.awards = const <OnlineAward>[],
  });

  final String id;
  final String clubId;
  final String meetingTitle;
  final String meetingDate;
  final OnlineRoundStatus status;
  final List<OnlineAward> awards;

  factory OnlineSession.fromJson(
    Map<String, dynamic> json, {
    List<OnlineAward> awards = const <OnlineAward>[],
  }) {
    return OnlineSession(
      id: _readString(json, 'sessionId', 'session_id'),
      clubId: _readString(json, 'clubId', 'club_id'),
      meetingTitle: _readString(json, 'meetingTitle', 'meeting_title'),
      meetingDate: _readString(json, 'meetingDate', 'meeting_date'),
      status: OnlineRoundStatus.fromValue(
        _readString(json, 'status', 'status'),
      ),
      awards: awards,
    );
  }

  OnlineSession copyWith({
    OnlineRoundStatus? status,
    List<OnlineAward>? awards,
  }) {
    return OnlineSession(
      id: id,
      clubId: clubId,
      meetingTitle: meetingTitle,
      meetingDate: meetingDate,
      status: status ?? this.status,
      awards: awards ?? this.awards,
    );
  }
}

class OnlineAward {
  const OnlineAward({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.status,
  });

  final String id;
  final String sessionId;
  final OnlineAwardType type;
  final OnlineRoundStatus status;

  factory OnlineAward.fromJson(Map<String, dynamic> json) {
    final String awardType = _readString(json, 'awardType', 'award_type');
    return OnlineAward(
      id: _readString(json, 'awardId', 'award_id'),
      sessionId: _readString(json, 'sessionId', 'session_id'),
      type: OnlineAwardType.fromValue(awardType) ?? OnlineAwardType.bestSpeaker,
      status: OnlineRoundStatus.fromValue(
        _readString(json, 'status', 'awardStatus', 'award_status'),
      ),
    );
  }
}

class OnlineCandidate {
  const OnlineCandidate({
    required this.id,
    required this.awardId,
    required this.name,
  });

  final String id;
  final String awardId;
  final String name;

  factory OnlineCandidate.fromJson(Map<String, dynamic> json) {
    return OnlineCandidate(
      id: _readString(json, 'candidateId', 'candidate_id'),
      awardId: _readString(json, 'awardId', 'award_id'),
      name: _readString(json, 'candidateName', 'candidate_name'),
    );
  }
}

class OnlineResults {
  const OnlineResults({
    required this.session,
    required this.isFinal,
    required this.awards,
  });

  final OnlineSession session;
  final bool isFinal;
  final List<OnlineAwardResult> awards;

  factory OnlineResults.fromJson(Map<String, dynamic> json) {
    return OnlineResults(
      session: OnlineSession.fromJson(
        _readMap(json['session']),
      ),
      isFinal: json['isFinal'] == true,
      awards: _readList(json['results'])
          .map(OnlineAwardResult.fromJson)
          .toList(growable: false),
    );
  }
}

class OnlineAwardResult {
  const OnlineAwardResult({
    required this.awardId,
    required this.type,
    required this.status,
    required this.candidates,
    required this.winners,
    required this.hasTie,
  });

  final String awardId;
  final OnlineAwardType type;
  final OnlineRoundStatus status;
  final List<OnlineCandidateResult> candidates;
  final List<OnlineCandidateResult> winners;
  final bool hasTie;

  factory OnlineAwardResult.fromJson(Map<String, dynamic> json) {
    final String awardType = _readString(json, 'awardType', 'award_type');
    return OnlineAwardResult(
      awardId: _readString(json, 'awardId', 'award_id'),
      type: OnlineAwardType.fromValue(awardType) ?? OnlineAwardType.bestSpeaker,
      status: OnlineRoundStatus.fromValue(
        _readString(json, 'awardStatus', 'award_status', 'status'),
      ),
      candidates: _readList(json['candidates'])
          .map(OnlineCandidateResult.fromJson)
          .toList(growable: false),
      winners: _readList(json['winners'])
          .map(OnlineCandidateResult.fromJson)
          .toList(growable: false),
      hasTie: json['hasTie'] == true,
    );
  }
}

class OnlineCandidateResult {
  const OnlineCandidateResult({
    required this.id,
    required this.name,
    required this.voteCount,
  });

  final String id;
  final String name;
  final int voteCount;

  factory OnlineCandidateResult.fromJson(Map<String, dynamic> json) {
    return OnlineCandidateResult(
      id: _readString(json, 'candidateId', 'candidate_id'),
      name: _readString(json, 'candidateName', 'candidate_name'),
      voteCount: _readInt(json, 'voteCount', 'vote_count'),
    );
  }
}

List<String> parseOnlineCandidateLines(String value) {
  return value
      .split('\n')
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty)
      .toList(growable: false);
}

String generateClubCode(String clubName) {
  final String code = clubName
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'[^a-z0-9-]'), '')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return code.isEmpty ? 'speech-club' : code;
}

String buildVotingPrintText(String url, Locale locale) {
  final bool isChinese = locale.languageCode == 'zh';
  if (isChinese) {
    return <String>[
      '演讲俱乐部投票',
      '请在会议中扫描此二维码进行投票。',
      '每个奖项投票都使用同一个二维码。',
      '投票链接：',
      url,
    ].join('\n');
  }
  return <String>[
    'Speech Club Voting',
    'Scan this QR code to vote during the meeting.',
    'The same QR code is used for each award vote.',
    'Voting link:',
    url,
  ].join('\n');
}

String onlineAwardLabel(OnlineAwardType type, Locale locale) {
  final bool isChinese = locale.languageCode == 'zh';
  return switch (type) {
    OnlineAwardType.bestSpeaker => isChinese ? '最佳演讲者' : 'Best Speaker',
    OnlineAwardType.bestTableTopics =>
      isChinese ? '最佳即席演讲者' : 'Best Table Topics Speaker',
    OnlineAwardType.bestEvaluator => isChinese ? '最佳点评者' : 'Best Evaluator',
  };
}

String onlineStatusLabel(OnlineRoundStatus status, Locale locale) {
  final bool isChinese = locale.languageCode == 'zh';
  return switch (status) {
    OnlineRoundStatus.draft => isChinese ? '草稿' : 'Draft',
    OnlineRoundStatus.open => isChinese ? '开放' : 'Open',
    OnlineRoundStatus.closed => isChinese ? '已结束' : 'Closed',
  };
}

String _readString(
  Map<String, dynamic> json,
  String key, [
  String? key2,
  String? key3,
]) {
  final Object? value = json[key] ??
      (key2 == null ? null : json[key2]) ??
      (key3 == null ? null : json[key3]);
  return value?.toString() ?? '';
}

int _readInt(Map<String, dynamic> json, String key, String key2) {
  final Object? value = json[key] ?? json[key2];
  return value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
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
