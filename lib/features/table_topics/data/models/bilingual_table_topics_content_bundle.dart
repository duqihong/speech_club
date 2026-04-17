import 'bilingual_table_topic_content.dart';

class BilingualTableTopicsContentBundle {
  const BilingualTableTopicsContentBundle({
    required this.version,
    required this.items,
  });

  final int version;
  final List<BilingualTableTopicContent> items;

  factory BilingualTableTopicsContentBundle.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawItems =
        (json['items'] is List) ? json['items'] as List<dynamic> : <dynamic>[];

    return BilingualTableTopicsContentBundle(
      version: json['version'] is int
          ? json['version'] as int
          : int.tryParse(json['version']?.toString() ?? '') ?? 1,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(BilingualTableTopicContent.fromJson)
          .where((BilingualTableTopicContent item) =>
              item.id.isNotEmpty &&
              item.category.isNotEmpty &&
              item.text.en.isNotEmpty &&
              item.text.zh.isNotEmpty)
          .toList(growable: false),
    );
  }
}
