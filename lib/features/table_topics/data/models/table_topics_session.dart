class TableTopicsSession {
  static const int currentVersion = 1;

  TableTopicsSession({
    this.version = currentVersion,
    required this.randomAll,
    required this.selectedCategories,
    required this.topics,
    required this.used,
    this.isCustomMode = false,
  });

  factory TableTopicsSession.empty() {
    return TableTopicsSession(
      randomAll: true,
      selectedCategories: <String>[],
      topics: <String>[],
      used: <bool>[],
      isCustomMode: false,
    );
  }

  factory TableTopicsSession.fromJson(Map<String, dynamic> json) {
    final int parsedVersion =
        json['version'] is int ? json['version'] as int : currentVersion;
    if (parsedVersion != currentVersion) {
      return TableTopicsSession.empty();
    }

    final List<String> parsedTopics = (json['topics'] is List)
        ? (json['topics'] as List<dynamic>)
            .map((dynamic e) => e.toString())
            .toList()
        : <String>[];
    if (parsedTopics.length > 10) {
      parsedTopics.removeRange(10, parsedTopics.length);
    }
    while (parsedTopics.length < 10) {
      parsedTopics.add('');
    }

    final List<bool> parsedUsed = (json['used'] is List)
        ? (json['used'] as List<dynamic>).map((dynamic e) => e == true).toList()
        : <bool>[];
    if (parsedUsed.length > 10) {
      parsedUsed.removeRange(10, parsedUsed.length);
    }
    while (parsedUsed.length < 10) {
      parsedUsed.add(false);
    }

    return TableTopicsSession(
      version: parsedVersion,
      randomAll: json['randomAll'] is bool ? json['randomAll'] as bool : true,
      selectedCategories: (json['selectedCategories'] is List)
          ? (json['selectedCategories'] as List<dynamic>)
              .map((dynamic e) => e.toString())
              .toList(growable: false)
          : <String>[],
      topics: parsedTopics,
      used: parsedUsed,
      isCustomMode:
          json['isCustomMode'] is bool ? json['isCustomMode'] as bool : false,
    );
  }

  final int version;
  final bool randomAll;
  final List<String> selectedCategories;
  final List<String> topics;
  final List<bool> used;
  final bool isCustomMode;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'randomAll': randomAll,
      'selectedCategories': selectedCategories,
      'topics': topics,
      'used': used,
      'isCustomMode': isCustomMode,
    };
  }
}
