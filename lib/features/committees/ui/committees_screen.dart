import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/committee_guides_data.dart';
import '../data/models/committee_guide.dart';
import 'committee_detail_screen.dart';

class CommitteesScreen extends StatelessWidget {
  const CommitteesScreen({super.key});

  void _openGuide(BuildContext context, CommitteeGuide guide) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CommitteeDetailScreen(guide: guide),
      ),
    );
  }

  Widget _buildCommitteeTile(
    BuildContext context, {
    required CommitteeGuide guide,
  }) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openGuide(context, guide),
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
              Text(
                guide.icon,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    guide.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
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
        title: Text(l10n.committeesTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool isLandscape =
                  constraints.maxWidth > constraints.maxHeight;
              final int crossAxisCount = isLandscape ? 4 : 2;
              const double spacing = 12;

              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;
              final int rows = (committeeGuides.length / crossAxisCount).ceil();

              final double tileWidth =
                  (width - spacing * (crossAxisCount - 1)) / crossAxisCount;
              final double tileHeight = (height - spacing * (rows - 1)) / rows;
              final double childAspectRatio = tileWidth / tileHeight;

              return GridView.builder(
                itemCount: committeeGuides.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final CommitteeGuide guide = committeeGuides[index];
                  return _buildCommitteeTile(context, guide: guide);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
