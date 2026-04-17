import '../../../../shared/content/localized_content_text.dart';

class BilingualTableTopicContent {
  const BilingualTableTopicContent({
    required this.id,
    required this.category,
    required this.text,
  });

  final String id;
  final String category;
  final LocalizedContentText text;

  factory BilingualTableTopicContent.fromJson(Map<String, dynamic> json) {
    return BilingualTableTopicContent(
      id: json['id']?.toString().trim() ?? '',
      category: json['category']?.toString().trim() ?? '',
      text: LocalizedContentText.fromJson(
        (json['text'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
    );
  }
}
