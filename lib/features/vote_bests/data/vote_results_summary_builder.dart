import 'dart:ui';

import 'vote_models.dart';

class VoteResultsSummaryBuilder {
  const VoteResultsSummaryBuilder();

  String build({
    required VoteBestsState state,
    required Locale locale,
  }) {
    final bool isChinese = locale.languageCode == 'zh';
    final List<String> sections = <String>[
      isChinese ? '演讲俱乐部投票结果' : 'Speech Club Voting Results',
    ];

    for (final VoteAwardCategory category in state.categories) {
      sections.add(_buildCategory(category, isChinese: isChinese));
    }

    return sections.join('\n\n');
  }

  String _buildCategory(
    VoteAwardCategory category, {
    required bool isChinese,
  }) {
    final List<String> lines = <String>[
      isChinese ? category.titleZh : category.titleEn,
    ];
    if (category.candidates.isEmpty) {
      lines.add(isChinese ? '没有候选人。' : 'No candidates.');
      return lines.join('\n');
    }

    final List<VoteCandidate> candidates =
        List<VoteCandidate>.of(category.candidates)
          ..sort((VoteCandidate a, VoteCandidate b) {
            final int voteComparison = b.votes.compareTo(a.votes);
            if (voteComparison != 0) {
              return voteComparison;
            }
            final int timeComparison = a.createdAt.compareTo(b.createdAt);
            return timeComparison != 0
                ? timeComparison
                : a.name.compareTo(b.name);
          });
    final int highestVotes = candidates.first.votes;

    if (highestVotes == 0) {
      lines.add(isChinese ? '还没有计票。' : 'No votes counted yet.');
    } else {
      final List<VoteCandidate> winners = candidates
          .where((VoteCandidate candidate) => candidate.votes == highestVotes)
          .toList(growable: false);
      if (winners.length == 1) {
        final VoteCandidate winner = winners.single;
        lines.add(
          isChinese
              ? '获奖者：${winner.name} — ${winner.votes} 票'
              : 'Winner: ${winner.name} — ${_englishVotes(winner.votes)}',
        );
      } else {
        final String names = winners
            .map((VoteCandidate candidate) => candidate.name)
            .join(isChinese ? '、' : ', ');
        lines.add(
          isChinese
              ? '并列：$names — 各 $highestVotes 票'
              : 'Tie: $names — ${_englishVotes(highestVotes)} each',
        );
      }
    }

    lines.add(isChinese ? '全部票数：' : 'All votes:');
    for (final VoteCandidate candidate in candidates) {
      lines.add(
        isChinese
            ? '- ${candidate.name}：${candidate.votes} 票'
            : '- ${candidate.name}: ${_englishVotes(candidate.votes)}',
      );
    }
    return lines.join('\n');
  }

  String _englishVotes(int votes) => '$votes ${votes == 1 ? 'vote' : 'votes'}';
}
