class RoleModel {
  RoleModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.priority,
    required this.purpose,
    required this.checklist,
    required this.tips,
    required this.scripts,
    this.deepLink,
  });

  final String id;
  final String title;
  final String icon;
  final String priority;
  final String purpose;
  final Map<String, List<String>> checklist;
  final List<String> tips;
  final List<String> scripts;
  final String? deepLink;

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> checklistRaw =
        (json['checklist'] is Map<String, dynamic>)
            ? json['checklist'] as Map<String, dynamic>
            : <String, dynamic>{};

    final Map<String, List<String>> parsedChecklist = <String, List<String>>{};
    checklistRaw.forEach((String key, dynamic value) {
      if (value is List) {
        parsedChecklist[key] = value
            .map((dynamic item) => item.toString().trim())
            .where((String item) => item.isNotEmpty)
            .toList(growable: false);
      }
    });

    return RoleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      checklist: parsedChecklist,
      tips: (json['tips'] is List)
          ? (json['tips'] as List<dynamic>)
              .map((dynamic item) => item.toString().trim())
              .where((String item) => item.isNotEmpty)
              .toList(growable: false)
          : <String>[],
      scripts: (json['scripts'] is List)
          ? (json['scripts'] as List<dynamic>)
              .map((dynamic item) => item.toString().trim())
              .where((String item) => item.isNotEmpty)
              .toList(growable: false)
          : <String>[],
      deepLink: json['deepLink']?.toString(),
    );
  }
}
