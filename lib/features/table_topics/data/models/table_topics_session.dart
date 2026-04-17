import 'table_topic_session_item.dart';

class TableTopicsSession {
  static const int currentVersion = 2;

  TableTopicsSession({
    this.version = currentVersion,
    required this.randomAll,
    required this.selectedCategories,
    required this.items,
    required this.used,
    this.isCustomMode = false,
  });

  factory TableTopicsSession.empty() {
    return TableTopicsSession(
      randomAll: true,
      selectedCategories: <String>[],
      items: <TableTopicSessionItem>[],
      used: <bool>[],
      isCustomMode: false,
    );
  }

  factory TableTopicsSession.fromJson(Map<String, dynamic> json) {
    final int parsedVersion = json['version'] is int
        ? json['version'] as int
        : int.tryParse(json['version']?.toString() ?? '') ?? 1;
    if (parsedVersion != 1 && parsedVersion != currentVersion) {
      return TableTopicsSession.empty();
    }

    final List<TableTopicSessionItem> parsedItems =
        parsedVersion == currentVersion
            ? _parseItems(json['items'])
            : _parseLegacyTopics(json['topics']);

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
      items: parsedItems,
      used: parsedUsed,
      isCustomMode:
          json['isCustomMode'] is bool ? json['isCustomMode'] as bool : false,
    );
  }

  final int version;
  final bool randomAll;
  final List<String> selectedCategories;
  final List<TableTopicSessionItem> items;
  final List<bool> used;
  final bool isCustomMode;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'randomAll': randomAll,
      'selectedCategories': selectedCategories,
      'items':
          items.map((TableTopicSessionItem item) => item.toJson()).toList(),
      'used': used,
      'isCustomMode': isCustomMode,
    };
  }

  static List<TableTopicSessionItem> _parseItems(dynamic rawItems) {
    final List<TableTopicSessionItem> items = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(TableTopicSessionItem.fromJson)
            .toList()
        : <TableTopicSessionItem>[];

    if (items.length > 10) {
      items.removeRange(10, items.length);
    }
    while (items.length < 10) {
      items.add(TableTopicSessionItem.custom(''));
    }
    return items;
  }

  static List<TableTopicSessionItem> _parseLegacyTopics(dynamic rawTopics) {
    final List<TableTopicSessionItem> items = (rawTopics is List)
        ? rawTopics
            .map((dynamic e) => TableTopicSessionItem.custom(e.toString()))
            .toList()
        : <TableTopicSessionItem>[];

    if (items.length > 10) {
      items.removeRange(10, items.length);
    }
    while (items.length < 10) {
      items.add(TableTopicSessionItem.custom(''));
    }
    return items;
  }
}
