import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'vote_bests_screen.dart';

class OnlineVoteBestsScreen extends StatelessWidget {
  const OnlineVoteBestsScreen({super.key});

  void _openManualCount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => VoteBestsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.voteBestsOnlineCount),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.voteBestsOnlineDescription,
                      style: const TextStyle(fontSize: 18, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.voteBestsOnlineNote,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () => _openManualCount(context),
                icon: const Icon(Icons.edit_note),
                label: Text(l10n.voteBestsGoToManualCount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
