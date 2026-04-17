import 'expression_content_item.dart';

class ExpressionContentBundle {
  const ExpressionContentBundle({
    required this.version,
    required this.items,
  });

  final int version;
  final List<ExpressionContentItem> items;

  factory ExpressionContentBundle.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems =
        (json['items'] is List) ? json['items'] as List<dynamic> : <dynamic>[];

    return ExpressionContentBundle(
      version: json['version'] is int
          ? json['version'] as int
          : int.tryParse(json['version']?.toString() ?? '') ?? 1,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(ExpressionContentItem.fromJson)
          .where((ExpressionContentItem item) =>
              item.id.isNotEmpty &&
              item.sourceLocale.isNotEmpty &&
              item.kind.isNotEmpty &&
              item.text.en.isNotEmpty &&
              item.text.zh.isNotEmpty)
          .toList(growable: false),
    );
  }
}
