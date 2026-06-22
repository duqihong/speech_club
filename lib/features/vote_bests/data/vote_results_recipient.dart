class VoteResultsRecipient {
  const VoteResultsRecipient({
    required this.name,
    required this.phoneNumber,
    required this.updatedAt,
  });

  final String name;
  final String phoneNumber;
  final DateTime updatedAt;

  factory VoteResultsRecipient.fromJson(Map<String, dynamic> json) {
    return VoteResultsRecipient(
      name: json['name']?.toString().trim() ?? '',
      phoneNumber: json['phoneNumber']?.toString().trim() ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'phoneNumber': phoneNumber,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
