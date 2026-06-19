import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/topic_category_guide.dart';
import '../data/topic_category_guides_data.dart';
import 'topic_category_detail_screen.dart';

class TopicSelectionScreen extends StatelessWidget {
  const TopicSelectionScreen({super.key});

  void _openCategory(BuildContext context, TopicCategoryGuide guide) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TopicCategoryDetailScreen(guide: guide),
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context, {
    required TopicCategoryGuide guide,
  }) {
    final Locale locale = Localizations.localeOf(context);

    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openCategory(context, guide),
        child: Container(
          padding: const EdgeInsets.all(12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(guide.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 8),
              Text(
                guide.titleForLocale(locale),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  guide.hintForLocale(locale),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.25,
                  ),
                ),
              ),
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
        title: Text(l10n.topicSelectionTitle),
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
                  l10n.topicSelectionIntro,
                  style: const TextStyle(fontSize: 18, height: 1.35),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: topicCategoryGuides.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (BuildContext context, int index) {
                final TopicCategoryGuide guide = topicCategoryGuides[index];
                return _buildCategoryTile(context, guide: guide);
              },
            ),
          ],
        ),
      ),
    );
  }
}
