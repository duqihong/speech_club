class CommitteeMember {
  const CommitteeMember({
    required this.id,
    required this.roleTitle,
    required this.memberName,
    required this.sortOrder,
    required this.updatedAt,
    this.phoneOrEmail,
    this.note,
  });

  final String id;
  final String roleTitle;
  final String memberName;
  final String? phoneOrEmail;
  final String? note;
  final int sortOrder;
  final DateTime updatedAt;

  static const Object _unchanged = Object();

  CommitteeMember copyWith({
    String? id,
    String? roleTitle,
    String? memberName,
    Object? phoneOrEmail = _unchanged,
    Object? note = _unchanged,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return CommitteeMember(
      id: id ?? this.id,
      roleTitle: roleTitle ?? this.roleTitle,
      memberName: memberName ?? this.memberName,
      phoneOrEmail: phoneOrEmail == _unchanged
          ? this.phoneOrEmail
          : phoneOrEmail as String?,
      note: note == _unchanged ? this.note : note as String?,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CommitteeMember.fromJson(Map<String, dynamic> json) {
    return CommitteeMember(
      id: json['id']?.toString() ?? '',
      roleTitle: json['roleTitle']?.toString().trim() ?? '',
      memberName: json['memberName']?.toString().trim() ?? '',
      phoneOrEmail: _optionalString(json['phoneOrEmail']),
      note: _optionalString(json['note']),
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder'] as int
          : int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'roleTitle': roleTitle,
      'memberName': memberName,
      if (phoneOrEmail != null && phoneOrEmail!.isNotEmpty)
        'phoneOrEmail': phoneOrEmail,
      if (note != null && note!.isNotEmpty) 'note': note,
      'sortOrder': sortOrder,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static String? _optionalString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
