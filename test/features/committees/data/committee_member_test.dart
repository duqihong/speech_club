import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/features/committees/data/models/committee_member.dart';

void main() {
  test('serializes and deserializes committee member JSON', () {
    final DateTime updatedAt = DateTime.utc(2026, 6, 19, 10, 30);
    final CommitteeMember member = CommitteeMember(
      id: 'member-1',
      roleTitle: 'President',
      memberName: 'Du Qihong',
      phoneOrEmail: 'president@email.com',
      note: 'Main club contact',
      sortOrder: 1,
      updatedAt: updatedAt,
    );

    final Map<String, dynamic> json = member.toJson();
    final CommitteeMember restored = CommitteeMember.fromJson(json);

    expect(json['id'], 'member-1');
    expect(json['roleTitle'], 'President');
    expect(restored.memberName, 'Du Qihong');
    expect(restored.phoneOrEmail, 'president@email.com');
    expect(restored.note, 'Main club contact');
    expect(restored.sortOrder, 1);
    expect(restored.updatedAt, updatedAt);
  });

  test('trims empty optional fields when deserializing', () {
    final CommitteeMember member = CommitteeMember.fromJson(
      <String, dynamic>{
        'id': 'member-1',
        'roleTitle': ' Treasurer ',
        'memberName': ' ',
        'phoneOrEmail': ' ',
        'note': '',
        'sortOrder': '3',
        'updatedAt': '2026-06-19T10:30:00.000Z',
      },
    );

    expect(member.roleTitle, 'Treasurer');
    expect(member.memberName, '');
    expect(member.phoneOrEmail, isNull);
    expect(member.note, isNull);
    expect(member.sortOrder, 3);
  });
}
