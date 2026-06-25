import 'dart:ui';

import 'online_count_models.dart';

class OnlineCountResultsSummaryBuilder {
  const OnlineCountResultsSummaryBuilder();

  String build({
    required OnlineResults results,
    required Locale locale,
  }) {
    final bool isChinese = locale.languageCode == 'zh';
    final List<String> sections = <String>[
      isChinese ? '演讲俱乐部在线投票结果' : 'Speech Club Online Voting Results',
      isChinese
          ? '会议：${results.session.meetingTitle}'
          : 'Meeting: ${results.session.meetingTitle}',
      isChinese
          ? '日期：${results.session.meetingDate}'
          : 'Date: ${results.session.meetingDate}',
      isChinese
          ? '状态：${results.isFinal ? '最终结果' : '尚未最终确认'}'
          : 'Status: ${results.isFinal ? 'Final' : 'Not final yet'}',
    ];

    for (final OnlineAwardResult award in results.awards) {
      sections.add(_buildAward(award, locale: locale));
    }

    return sections.join('\n\n');
  }

  String _buildAward(OnlineAwardResult award, {required Locale locale}) {
    final bool isChinese = locale.languageCode == 'zh';
    final List<String> lines = <String>[
      onlineAwardLabel(award.type, locale),
    ];

    if (award.candidates.isEmpty) {
      lines.add(isChinese ? '没有候选人。' : 'No candidates.');
      return lines.join('\n');
    }

    if (award.winners.isEmpty) {
      lines.add(isChinese ? '尚未计票。' : 'No votes counted.');
    } else if (award.hasTie) {
      final String names = award.winners
          .map((OnlineCandidateResult candidate) => candidate.name)
          .join(', ');
      lines.add(isChinese ? '并列：$names' : 'Tie: $names');
    } else {
      final String name = award.winners.single.name;
      lines.add(isChinese ? '获奖者：$name' : 'Winner: $name');
    }

    lines.add(isChinese ? '票数：' : 'Votes:');
    for (final OnlineCandidateResult candidate in award.candidates) {
      lines.add(
        isChinese
            ? '- ${candidate.name}：${candidate.voteCount}'
            : '- ${candidate.name}: ${candidate.voteCount}',
      );
    }

    return lines.join('\n');
  }
}
