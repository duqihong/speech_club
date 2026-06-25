import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_models.dart';

void main() {
  group('online count helpers', () {
    test('candidate multiline parsing trims names and removes empty lines', () {
      expect(
        parseOnlineCandidateLines(' Alice \n\nBob\n  Chen  \n'),
        <String>['Alice', 'Bob', 'Chen'],
      );
    });

    test('club code generation normalizes names', () {
      expect(generateClubCode('Demo App Test Club'), 'demo-app-test-club');
      expect(generateClubCode('Jiangyin Speech Club'), 'jiangyin-speech-club');
      expect(generateClubCode('  My   Club! 2026  '), 'my-club-2026');
      expect(generateClubCode('中文俱乐部'), 'speech-club');
    });

    test('award labels map in English and Chinese', () {
      expect(
        onlineAwardLabel(
          OnlineAwardType.bestSpeaker,
          const Locale('en'),
        ),
        'Best Speaker',
      );
      expect(
        onlineAwardLabel(
          OnlineAwardType.bestTableTopics,
          const Locale('zh'),
        ),
        '最佳即席演讲者',
      );
      expect(
        onlineAwardLabel(
          OnlineAwardType.bestEvaluator,
          const Locale('zh'),
        ),
        '最佳点评者',
      );
    });
  });
}
