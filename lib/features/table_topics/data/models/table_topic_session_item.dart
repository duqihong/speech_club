class TableTopicSessionItem {
  const TableTopicSessionItem._({
    required this.sourceType,
    this.topicId,
    this.customText,
  });

  static const String builtInSourceType = 'builtIn';
  static const String customSourceType = 'custom';

  final String sourceType;
  final String? topicId;
  final String? customText;

  bool get isBuiltIn => sourceType == builtInSourceType && topicId != null;

  bool get isCustom => sourceType == customSourceType;

  factory TableTopicSessionItem.builtIn(String topicId) {
    return TableTopicSessionItem._(
      sourceType: builtInSourceType,
      topicId: topicId.trim(),
    );
  }

  factory TableTopicSessionItem.custom(String text) {
    return TableTopicSessionItem._(
      sourceType: customSourceType,
      customText: text,
    );
  }

  factory TableTopicSessionItem.fromJson(Map<String, dynamic> json) {
    final String sourceType = json['sourceType']?.toString().trim() ?? '';
    final String topicId = json['topicId']?.toString().trim() ?? '';
    final String customText = json['customText']?.toString() ?? '';

    if (sourceType == builtInSourceType && topicId.isNotEmpty) {
      return TableTopicSessionItem.builtIn(topicId);
    }

    return TableTopicSessionItem.custom(customText);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sourceType': sourceType,
      if (topicId != null) 'topicId': topicId,
      if (customText != null) 'customText': customText,
    };
  }
}
