import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/models/committee_guide.dart';

class CommitteeDetailScreen extends StatelessWidget {
  const CommitteeDetailScreen({
    super.key,
    required this.guide,
  });

  final CommitteeGuide guide;

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildResponsibilitySection(
    CommitteeResponsibilitySection section,
  ) {
    if (section.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            section.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          for (final String item in section.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('✅ $item', style: const TextStyle(fontSize: 17)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale locale = Localizations.localeOf(context);
    final String title = guide.titleForLocale(locale);
    final String rolePurpose = guide.rolePurposeForLocale(locale);
    final List<CommitteeResponsibilitySection> sections =
        guide.sectionsForLocale(locale);
    final List<String> quickTips = guide.quickTipsForLocale(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text('${guide.icon} $title'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSectionCard(
                title: l10n.committeesRolePurpose,
                child: Text(
                  rolePurpose,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              _buildSectionCard(
                title: l10n.committeesKeyResponsibilities,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sections
                      .map(_buildResponsibilitySection)
                      .toList(growable: false),
                ),
              ),
              _buildSectionCard(
                title: l10n.committeesQuickTips,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: quickTips
                      .map(
                        (String tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $tip',
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
