import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/data/vote_models.dart';
import 'package:speech_club/features/vote_bests/data/vote_results_recipient.dart';
import 'package:speech_club/features/vote_bests/data/vote_results_recipient_repository.dart';
import 'package:speech_club/features/vote_bests/data/vote_results_summary_builder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const VoteResultsSummaryBuilder summaryBuilder = VoteResultsSummaryBuilder();
  final DateTime baseTime = DateTime.utc(2026, 6, 22, 10);

  VoteCandidate candidate(String name, int votes, int order) {
    return VoteCandidate(
      id: 'candidate-$order',
      name: name,
      votes: votes,
      createdAt: baseTime.add(Duration(minutes: order)),
    );
  }

  VoteBestsState stateWithCandidates(List<VoteCandidate> candidates) {
    return VoteBestsState(
      categories: <VoteAwardCategory>[
        VoteAwardCategory(
          id: 'best_speaker',
          icon: '🗣️',
          titleEn: 'Best Speaker',
          titleZh: '最佳演讲者',
          candidates: candidates,
        ),
      ],
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('VoteResultsRecipient serializes and deserializes correctly', () {
    final VoteResultsRecipient recipient = VoteResultsRecipient(
      name: 'David',
      phoneNumber: '+65 9123 4567',
      updatedAt: baseTime,
    );

    final VoteResultsRecipient restored =
        VoteResultsRecipient.fromJson(recipient.toJson());

    expect(restored.name, 'David');
    expect(restored.phoneNumber, '+65 9123 4567');
    expect(restored.updatedAt, baseTime);
  });

  test('president contact saves and loads', () async {
    final VoteResultsRecipientRepository repository =
        VoteResultsRecipientRepository(now: () => baseTime);

    await repository.save(name: ' David ', phoneNumber: ' +65 9123 4567 ');
    final VoteResultsRecipient? restored = await repository.load();

    expect(restored?.name, 'David');
    expect(restored?.phoneNumber, '+65 9123 4567');
    expect(restored?.updatedAt, baseTime);
  });

  test('English summary reports a clear winner', () {
    final String summary = summaryBuilder.build(
      state: stateWithCandidates(<VoteCandidate>[
        candidate('Alice', 5, 1),
        candidate('Ben', 3, 2),
      ]),
      locale: const Locale('en'),
    );

    expect(summary, contains('Speech Club Voting Results'));
    expect(summary, contains('Winner: Alice — 5 votes'));
    expect(summary, contains('- Ben: 3 votes'));
  });

  test('English summary reports a tie', () {
    final String summary = summaryBuilder.build(
      state: stateWithCandidates(<VoteCandidate>[
        candidate('David', 3, 1),
        candidate('Susan', 3, 2),
        candidate('Helen', 1, 3),
      ]),
      locale: const Locale('en'),
    );

    expect(summary, contains('Tie: David, Susan — 3 votes each'));
    expect(summary, contains('All votes:'));
  });

  test('English summary reports no candidates', () {
    final String summary = summaryBuilder.build(
      state: stateWithCandidates(<VoteCandidate>[]),
      locale: const Locale('en'),
    );

    expect(summary, contains('Best Speaker\nNo candidates.'));
  });

  test('Chinese summary reports a clear winner', () {
    final String summary = summaryBuilder.build(
      state: stateWithCandidates(<VoteCandidate>[
        candidate('Alice', 5, 1),
        candidate('Ben', 3, 2),
      ]),
      locale: const Locale('zh'),
    );

    expect(summary, contains('演讲俱乐部投票结果'));
    expect(summary, contains('获奖者：Alice — 5 票'));
    expect(summary, contains('- Ben：3 票'));
  });

  test('Chinese summary reports a tie', () {
    final String summary = summaryBuilder.build(
      state: stateWithCandidates(<VoteCandidate>[
        candidate('David', 3, 1),
        candidate('Susan', 3, 2),
        candidate('Helen', 1, 3),
      ]),
      locale: const Locale('zh'),
    );

    expect(summary, contains('并列：David、Susan — 各 3 票'));
    expect(summary, contains('全部票数：'));
  });

  test('Chinese summary reports no candidates', () {
    final String summary = summaryBuilder.build(
      state: stateWithCandidates(<VoteCandidate>[]),
      locale: const Locale('zh'),
    );

    expect(summary, contains('最佳演讲者\n没有候选人。'));
  });

  test('summary reports candidates with no counted votes', () {
    final String english = summaryBuilder.build(
      state: stateWithCandidates(<VoteCandidate>[
        candidate('Alice', 0, 1),
      ]),
      locale: const Locale('en'),
    );
    final String chinese = summaryBuilder.build(
      state: stateWithCandidates(<VoteCandidate>[
        candidate('Alice', 0, 1),
      ]),
      locale: const Locale('zh'),
    );

    expect(english, contains('No votes counted yet.'));
    expect(chinese, contains('还没有计票。'));
  });
}
