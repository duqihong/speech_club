import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'online_vote_bests_screen.dart';
import 'vote_bests_screen.dart';

class VoteBestsModeScreen extends StatelessWidget {
  const VoteBestsModeScreen({super.key});

  void _openManualCount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => VoteBestsScreen()),
    );
  }

  void _openOnlineCount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const OnlineVoteBestsScreen()),
    );
  }

  Widget _buildModeCard({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.voteBestsTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  l10n.voteBestsModeIntro,
                  style: const TextStyle(fontSize: 18, height: 1.35),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildModeCard(
              icon: '📝',
              title: l10n.voteBestsManualCount,
              subtitle: l10n.voteBestsManualCountSubtitle,
              onTap: () => _openManualCount(context),
            ),
            const SizedBox(height: 12),
            _buildModeCard(
              icon: '☁️',
              title: l10n.voteBestsOnlineCount,
              subtitle: l10n.voteBestsOnlineCountSubtitle,
              onTap: () => _openOnlineCount(context),
            ),
          ],
        ),
      ),
    );
  }
}
