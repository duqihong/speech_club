import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/role_assistant/data/role_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads English role content for English locale', () async {
    final RoleRepository repository = RoleRepository();

    final roles = await repository.loadRoles(locale: const Locale('en'));
    final timerRole = roles.firstWhere((role) => role.id == 'timer');

    expect(timerRole.purpose,
        'You protect fairness and rhythm. Timing helps everyone improve and keeps the meeting on track.');
  });

  test('loads Chinese role content for Chinese locale', () async {
    final RoleRepository repository = RoleRepository();

    final roles = await repository.loadRoles(locale: const Locale('zh'));
    final timerRole = roles.firstWhere((role) => role.id == 'timer');

    expect(timerRole.purpose, '你负责守护公平与节奏。准确计时能帮助大家进步，也让会议顺利进行。');
  });

  test('keeps built-in role ids stable across locales', () async {
    final RoleRepository repository = RoleRepository();

    final englishRoles = await repository.loadRoles(locale: const Locale('en'));
    final chineseRoles = await repository.loadRoles(locale: const Locale('zh'));

    expect(
      chineseRoles.map((role) => role.id).toList(),
      englishRoles.map((role) => role.id).toList(),
    );
  });
}
