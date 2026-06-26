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

    test('print text is localized and includes voting URL', () {
      const String url = 'https://example.com/c/demo-club?lang=zh';

      final String english = buildVotingPrintText(url, const Locale('en'));
      expect(english, contains('Speech Club Voting'));
      expect(english, contains(url));

      final String chinese = buildVotingPrintText(url, const Locale('zh'));
      expect(chinese, contains('演讲俱乐部投票'));
      expect(chinese, contains(url));
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

    test('owner status parses current session and active award', () {
      final OnlineClubStatus status = OnlineClubStatus.fromJson(
        <String, dynamic>{
          'club': <String, dynamic>{
            'clubId': 'club-1',
            'clubName': 'Demo Club',
            'clubSlug': 'demo-club',
            'expiresAt': '2026-09-26 00:00:00',
          },
          'currentSession': <String, dynamic>{
            'sessionId': 'session-1',
            'clubId': 'club-1',
            'meetingTitle': 'Regular Meeting',
            'meetingDate': '2026-06-26',
            'status': 'open',
            'expiresAt': '2026-07-03 00:00:00',
          },
          'activeAward': <String, dynamic>{
            'awardId': 'award-1',
            'sessionId': 'session-1',
            'awardType': 'best_speaker',
            'status': 'open',
          },
          'summary': <String, dynamic>{
            'hasCurrentSession': true,
            'hasActiveAward': true,
            'canCreateMeeting': false,
            'canCreateClub': false,
            'legacyMultipleSessions': true,
          },
        },
      );

      expect(status.club.expiresAt, '2026-09-26 00:00:00');
      expect(status.currentSession?.id, 'session-1');
      expect(status.currentSession?.status, OnlineRoundStatus.open);
      expect(status.activeAward?.type, OnlineAwardType.bestSpeaker);
      expect(status.summary.legacyMultipleSessions, isTrue);
    });
  });
}
