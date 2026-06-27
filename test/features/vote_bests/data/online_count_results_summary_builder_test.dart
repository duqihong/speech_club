import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_models.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_results_summary_builder.dart';

void main() {
  const OnlineCountResultsSummaryBuilder builder =
      OnlineCountResultsSummaryBuilder();

  test(
      'builds English final results with winner tie no votes and no candidates',
      () {
    final String summary = builder.build(
      results: _sampleResults(isFinal: true),
      locale: const Locale('en'),
    );

    expect(summary, contains('Speech Club Online Voting Results'));
    expect(summary, contains('Meeting: Regular Meeting'));
    expect(summary, contains('Date: 2026-06-25'));
    expect(summary, contains('Status: Final'));
    expect(summary, contains('Best Speaker\nWinner: Alice'));
    expect(summary, contains('Best Table Topics Speaker\nTie: David, Eva'));
    expect(summary, contains('Best Evaluator\nNo votes counted.'));
    expect(summary, contains('Votes:\n- Alice: 3'));
    expect(summary, contains('No candidates.'));
  });

  test('builds Chinese non-final results', () {
    final String summary = builder.build(
      results: _sampleResults(isFinal: false),
      locale: const Locale('zh'),
    );

    expect(summary, contains('演讲俱乐部在线投票结果'));
    expect(summary, contains('会议：Regular Meeting'));
    expect(summary, contains('日期：2026-06-25'));
    expect(summary, contains('状态：尚未最终确认'));
    expect(summary, contains('最佳演讲者\n获奖者：Alice'));
    expect(summary, contains('最佳即席演讲者\n并列：David, Eva'));
    expect(summary, contains('最佳评论员\n尚未计票。'));
    expect(summary, isNot(contains('最佳点评者')));
    expect(summary, contains('票数：\n- Alice：3'));
    expect(summary, contains('没有候选人。'));
  });
}

OnlineResults _sampleResults({required bool isFinal}) {
  return OnlineResults(
    isFinal: isFinal,
    session: const OnlineSession(
      id: 'session-1',
      clubId: 'club-1',
      meetingTitle: 'Regular Meeting',
      meetingDate: '2026-06-25',
      status: OnlineRoundStatus.closed,
    ),
    awards: const <OnlineAwardResult>[
      OnlineAwardResult(
        awardId: 'award-1',
        type: OnlineAwardType.bestSpeaker,
        status: OnlineRoundStatus.closed,
        hasTie: false,
        winners: <OnlineCandidateResult>[
          OnlineCandidateResult(id: 'candidate-1', name: 'Alice', voteCount: 3),
        ],
        candidates: <OnlineCandidateResult>[
          OnlineCandidateResult(id: 'candidate-1', name: 'Alice', voteCount: 3),
          OnlineCandidateResult(id: 'candidate-2', name: 'Bob', voteCount: 1),
          OnlineCandidateResult(
            id: 'candidate-3',
            name: 'Charlie',
            voteCount: 0,
          ),
        ],
      ),
      OnlineAwardResult(
        awardId: 'award-2',
        type: OnlineAwardType.bestTableTopics,
        status: OnlineRoundStatus.closed,
        hasTie: true,
        winners: <OnlineCandidateResult>[
          OnlineCandidateResult(id: 'candidate-4', name: 'David', voteCount: 2),
          OnlineCandidateResult(id: 'candidate-5', name: 'Eva', voteCount: 2),
        ],
        candidates: <OnlineCandidateResult>[
          OnlineCandidateResult(id: 'candidate-4', name: 'David', voteCount: 2),
          OnlineCandidateResult(id: 'candidate-5', name: 'Eva', voteCount: 2),
          OnlineCandidateResult(id: 'candidate-6', name: 'Frank', voteCount: 0),
        ],
      ),
      OnlineAwardResult(
        awardId: 'award-3',
        type: OnlineAwardType.bestEvaluator,
        status: OnlineRoundStatus.closed,
        hasTie: false,
        winners: <OnlineCandidateResult>[],
        candidates: <OnlineCandidateResult>[
          OnlineCandidateResult(id: 'candidate-7', name: 'Grace', voteCount: 0),
          OnlineCandidateResult(id: 'candidate-8', name: 'Helen', voteCount: 0),
        ],
      ),
      OnlineAwardResult(
        awardId: 'award-4',
        type: OnlineAwardType.bestSpeaker,
        status: OnlineRoundStatus.draft,
        hasTie: false,
        winners: <OnlineCandidateResult>[],
        candidates: <OnlineCandidateResult>[],
      ),
    ],
  );
}
