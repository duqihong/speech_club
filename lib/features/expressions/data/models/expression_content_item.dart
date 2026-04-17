import '../../../../shared/content/localized_content_text.dart';

class ExpressionContentItem {
  const ExpressionContentItem({
    required this.id,
    required this.sourceLocale,
    required this.kind,
    required this.text,
  });

  final String id;
  final String sourceLocale;
  final String kind;
  final LocalizedContentText text;

  factory ExpressionContentItem.fromJson(Map<String, dynamic> json) {
    return ExpressionContentItem(
      id: json['id']?.toString().trim() ?? '',
      sourceLocale: json['sourceLocale']?.toString().trim() ?? '',
      kind: json['kind']?.toString().trim() ?? '',
      text: LocalizedContentText.fromJson(
        (json['text'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
    );
  }
}
