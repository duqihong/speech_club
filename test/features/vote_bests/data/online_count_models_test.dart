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
