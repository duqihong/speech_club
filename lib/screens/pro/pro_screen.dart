import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  void _showPurchasePlaceholder(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.proPurchaseComingSoon)),
    );
  }

  void _returnToPreviousScreen(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Widget _buildFeatureTile(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.check_circle_outline,
            size: 22,
            color: Color(0xFF355E86),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<String> features = <String>[
      l10n.proFeatureOnlineCount,
      l10n.proFeaturePermanentClubQr,
      l10n.proFeatureQrSharing,
      l10n.proFeatureLiveVoteCounter,
      l10n.proFeatureSendResultsByWhatsApp,
      l10n.proFeatureFutureOnlineTools,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(l10n.proTitle),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.workspace_premium_outlined,
                      size: 42,
                      color: Color(0xFF355E86),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.proTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF355E86),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.proSubtitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.proBody,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.proIncludedTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final String feature in features)
                      _buildFeatureTile(feature),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  l10n.proPriceLine,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _showPurchasePlaceholder(context),
              child: Text(l10n.proStartTrialButton),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _returnToPreviousScreen(context),
              child: Text(l10n.proUseManualCountButton),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.proManualCountFreeNote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
