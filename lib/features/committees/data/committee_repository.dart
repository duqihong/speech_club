import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'models/committee_member.dart';

class CommitteeRepository {
  CommitteeRepository({
    Uuid? uuid,
    DateTime Function()? now,
  })  : _uuid = uuid ?? const Uuid(),
        _now = now ?? DateTime.now;

  static const String storageKey = 'committees.members_v1';
  static const List<String> defaultRoleTitles = <String>[
    'President',
    'Vice President Education',
    'Vice President Membership',
    'Vice President Public Relations',
    'Secretary',
    'Treasurer',
    'Sergeant at Arms',
    'Immediate Past President',
  ];

  final Uuid _uuid;
  final DateTime Function() _now;

  Future<List<CommitteeMember>> loadMembers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      final List<CommitteeMember> members = createDefaultMembers();
      await _saveMembers(members);
      return members;
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return <CommitteeMember>[];
      }

      final List<CommitteeMember> members = decoded
          .whereType<Map<String, dynamic>>()
          .map(CommitteeMember.fromJson)
          .where((CommitteeMember member) => member.roleTitle.isNotEmpty)
          .toList();
      members.sort(_compareMembers);
      return members;
    } catch (_) {
      return <CommitteeMember>[];
    }
  }

  Future<void> saveMember(CommitteeMember member) async {
    final List<CommitteeMember> members = await loadMembers();
    final int index = members.indexWhere(
      (CommitteeMember item) => item.id == member.id,
    );

    final CommitteeMember updated = member.copyWith(updatedAt: _now());
    if (index == -1) {
      members.add(updated.copyWith(sortOrder: _nextSortOrder(members)));
    } else {
      members[index] = updated;
    }

    members.sort(_compareMembers);
    await _saveMembers(members);
  }

  Future<CommitteeMember> createCustomRole() async {
    final List<CommitteeMember> members = await loadMembers();
    return CommitteeMember(
      id: _uuid.v4(),
      roleTitle: '',
      memberName: '',
      sortOrder: _nextSortOrder(members),
      updatedAt: _now(),
    );
  }

  Future<List<CommitteeMember>> resetDefaultRoles() async {
    final List<CommitteeMember> members = createDefaultMembers();
    await _saveMembers(members);
    return members;
  }

  List<CommitteeMember> createDefaultMembers() {
    final DateTime timestamp = _now();
    return <CommitteeMember>[
      for (int i = 0; i < defaultRoleTitles.length; i++)
        CommitteeMember(
          id: 'default-${i + 1}',
          roleTitle: defaultRoleTitles[i],
          memberName: '',
          sortOrder: i,
          updatedAt: timestamp,
        ),
    ];
  }

  Future<void> _saveMembers(List<CommitteeMember> members) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    members.sort(_compareMembers);
    await prefs.setString(
      storageKey,
      jsonEncode(
        members.map((CommitteeMember member) => member.toJson()).toList(),
      ),
    );
  }

  int _nextSortOrder(List<CommitteeMember> members) {
    if (members.isEmpty) {
      return 0;
    }
    return members
            .map((CommitteeMember member) => member.sortOrder)
            .reduce((int a, int b) => a > b ? a : b) +
        1;
  }

  static int _compareMembers(CommitteeMember a, CommitteeMember b) {
    final int sortCompare = a.sortOrder.compareTo(b.sortOrder);
    if (sortCompare != 0) {
      return sortCompare;
    }
    return a.roleTitle.compareTo(b.roleTitle);
  }
}
