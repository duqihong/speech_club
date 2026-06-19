import 'dart:ui';

class VoteCandidate {
  const VoteCandidate({
    required this.id,
    required this.name,
    required this.votes,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int votes;
  final DateTime createdAt;

  VoteCandidate copyWith({
    String? id,
    String? name,
    int? votes,
    DateTime? createdAt,
  }) {
    return VoteCandidate(
      id: id ?? this.id,
      name: name ?? this.name,
      votes: votes ?? this.votes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory VoteCandidate.fromJson(Map<String, dynamic> json) {
    return VoteCandidate(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString().trim() ?? '',
      votes: json['votes'] is int
          ? json['votes'] as int
          : int.tryParse(json['votes']?.toString() ?? '') ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'votes': votes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class VoteAwardCategory {
  const VoteAwardCategory({
    required this.id,
    required this.icon,
    required this.titleEn,
    required this.titleZh,
    required this.candidates,
  });

  final String id;
  final String icon;
  final String titleEn;
  final String titleZh;
  final List<VoteCandidate> candidates;

  int get totalVotes {
    return candidates.fold<int>(
      0,
      (int total, VoteCandidate candidate) => total + candidate.votes,
    );
  }

  String titleForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? titleZh : titleEn;
  }

  VoteAwardCategory copyWith({
    String? id,
    String? icon,
    String? titleEn,
    String? titleZh,
    List<VoteCandidate>? candidates,
  }) {
    return VoteAwardCategory(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      titleEn: titleEn ?? this.titleEn,
      titleZh: titleZh ?? this.titleZh,
      candidates: candidates ?? this.candidates,
    );
  }

  factory VoteAwardCategory.fromJson(Map<String, dynamic> json) {
    return VoteAwardCategory(
      id: json['id']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      titleEn: json['titleEn']?.toString() ?? '',
      titleZh: json['titleZh']?.toString() ?? '',
      candidates: json['candidates'] is List<dynamic>
          ? (json['candidates'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(VoteCandidate.fromJson)
              .where((VoteCandidate candidate) => candidate.name.isNotEmpty)
              .toList(growable: false)
          : <VoteCandidate>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'icon': icon,
      'titleEn': titleEn,
      'titleZh': titleZh,
      'candidates': candidates
          .map((VoteCandidate candidate) => candidate.toJson())
          .toList(),
    };
  }
}

class VoteBestsState {
  const VoteBestsState({
    required this.categories,
  });

  final List<VoteAwardCategory> categories;

  VoteAwardCategory categoryById(String categoryId) {
    return categories.firstWhere(
      (VoteAwardCategory category) => category.id == categoryId,
    );
  }

  VoteBestsState copyWith({
    List<VoteAwardCategory>? categories,
  }) {
    return VoteBestsState(categories: categories ?? this.categories);
  }

  factory VoteBestsState.fromJson(Map<String, dynamic> json) {
    return VoteBestsState(
      categories: json['categories'] is List<dynamic>
          ? (json['categories'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(VoteAwardCategory.fromJson)
              .toList(growable: false)
          : <VoteAwardCategory>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'categories': categories
          .map((VoteAwardCategory category) => category.toJson())
          .toList(),
    };
  }
}
