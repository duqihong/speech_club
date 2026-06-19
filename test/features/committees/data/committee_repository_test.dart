import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/committees/data/committee_repository.dart';
import 'package:speech_club/features/committees/data/models/committee_member.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DateTime now;
  late CommitteeRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    now = DateTime.utc(2026, 6, 19, 10);
    repository = CommitteeRepository(now: () => now);
  });

  test('loads default roles when no saved data exists', () async {
    final List<CommitteeMember> members = await repository.loadMembers();

    expect(members.length, 8);
    expect(members.first.roleTitle, 'President');
    expect(members.last.roleTitle, 'Immediate Past President');
    expect(members.every((CommitteeMember member) => member.memberName.isEmpty),
        isTrue);
  });

  test('saving edited committee member persists data', () async {
    final List<CommitteeMember> members = await repository.loadMembers();
    final CommitteeMember president = members.first.copyWith(
      memberName: 'Du Qihong',
      phoneOrEmail: 'president@email.com',
      note: 'Main club contact',
    );

    await repository.saveMember(president);

    final CommitteeRepository secondRepository =
        CommitteeRepository(now: () => now);
    final List<CommitteeMember> restored = await secondRepository.loadMembers();

    expect(restored.first.memberName, 'Du Qihong');
    expect(restored.first.phoneOrEmail, 'president@email.com');
    expect(restored.first.note, 'Main club contact');
  });

  test('reset default roles restores default roles', () async {
    final List<CommitteeMember> members = await repository.loadMembers();
    await repository.saveMember(
      members.first.copyWith(memberName: 'Du Qihong'),
    );

    final List<CommitteeMember> resetMembers =
        await repository.resetDefaultRoles();

    expect(resetMembers.length, 8);
    expect(resetMembers.first.roleTitle, 'President');
    expect(resetMembers.first.memberName, '');
  });
}
