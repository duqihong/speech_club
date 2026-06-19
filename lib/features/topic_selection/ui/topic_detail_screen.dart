import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/speech_topic.dart';

class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({
    super.key,
    required this.topic,
  });

  final SpeechTopic topic;

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('• $item', style: const TextStyle(fontSize: 17)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        title: Text(topic.titleForLocale(locale)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSectionCard(
                title: l10n.topicSelectionWhyItWorks,
                child: Text(
                  topic.whyItWorksForLocale(locale),
                  style: const TextStyle(fontSize: 18, height: 1.35),
                ),
              ),
              _buildSectionCard(
                title: l10n.topicSelectionPossibleStructure,
                child: _buildBulletList(topic.structureForLocale(locale)),
              ),
              _buildSectionCard(
                title: l10n.topicSelectionStarterQuestions,
                child: _buildBulletList(
                  topic.starterQuestionsForLocale(locale),
                ),
              ),
              _buildSectionCard(
                title: l10n.topicSelectionOpeningLine,
                child: Text(
                  topic.openingLineForLocale(locale),
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.35,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
