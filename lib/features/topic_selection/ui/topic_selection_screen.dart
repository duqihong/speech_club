import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/speech_topic.dart';
import '../data/speech_topics_data.dart';
import 'topic_detail_screen.dart';

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  String? _selectedCategoryEn;

  List<SpeechTopic> get _visibleTopics {
    if (_selectedCategoryEn == null) {
      return speechTopics;
    }
    return speechTopics
        .where((SpeechTopic topic) => topic.categoryEn == _selectedCategoryEn)
        .toList(growable: false);
  }

  void _openTopic(SpeechTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TopicDetailScreen(topic: topic),
      ),
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
        title: Text(l10n.topicSelectionTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.topicSelectionIntro,
                  style: const TextStyle(fontSize: 18, height: 1.35),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              key: const Key('topicSelectionCategoryScroll'),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(l10n.topicSelectionAll),
                      selected: _selectedCategoryEn == null,
                      onSelected: (_) {
                        setState(() => _selectedCategoryEn = null);
                      },
                    ),
                  ),
                  for (final SpeechTopicCategory category
                      in speechTopicCategories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(locale.languageCode == 'zh'
                            ? category.zh
                            : category.en),
                        selected: _selectedCategoryEn == category.en,
                        onSelected: (_) {
                          setState(() => _selectedCategoryEn = category.en);
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final SpeechTopic topic in _visibleTopics) ...<Widget>[
              _TopicCard(
                topic: topic,
                locale: locale,
                onTap: () => _openTopic(topic),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.locale,
    required this.onTap,
  });

  final SpeechTopic topic;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                topic.titleForLocale(locale),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                topic.categoryForLocale(locale),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF355E86),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                topic.promptForLocale(locale),
                style: const TextStyle(fontSize: 17, height: 1.35),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.topicSelectionStyleLabel(
                  topic.styleForLocale(locale),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
