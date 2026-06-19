import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/topic_category_guide.dart';

class TopicCategoryDetailScreen extends StatelessWidget {
  const TopicCategoryDetailScreen({
    super.key,
    required this.guide,
  });

  final TopicCategoryGuide guide;

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

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final String item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• $item', style: const TextStyle(fontSize: 17)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale locale = Localizations.localeOf(context);
    final String title = guide.titleForLocale(locale);

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
                title: l10n.topicSelectionCategoryPurpose,
                child: Text(
                  guide.purposeForLocale(locale),
                  style: const TextStyle(fontSize: 18, height: 1.35),
                ),
              ),
              _buildSectionCard(
                title: l10n.topicSelectionTopicIdeas,
                child: _buildBulletList(guide.topicIdeasForLocale(locale)),
              ),
              _buildSectionCard(
                title: l10n.topicSelectionHowToChoose,
                child: _buildBulletList(guide.choosingTipsForLocale(locale)),
              ),
              _buildSectionCard(
                title: l10n.topicSelectionSpeechStructure,
                child: _buildBulletList(guide.structureForLocale(locale)),
              ),
              _buildSectionCard(
                title: l10n.topicSelectionOpeningLines,
                child: _buildBulletList(guide.openingLinesForLocale(locale)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
