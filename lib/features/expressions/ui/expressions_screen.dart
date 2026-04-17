import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/expression_content_repository.dart';
import '../data/models/expression_content_bundle.dart';
import '../data/models/expression_content_item.dart';

class ExpressionsScreen extends StatefulWidget {
  const ExpressionsScreen({super.key});

  @override
  State<ExpressionsScreen> createState() => _ExpressionsScreenState();
}

class _ExpressionsScreenState extends State<ExpressionsScreen> {
  late final Future<_ExpressionsScreenData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_ExpressionsScreenData> _loadData() async {
    final ExpressionContentRepository repository =
        ExpressionContentRepository();
    final List<Object> bundles = await Future.wait<Object>(<Future<Object>>[
      repository.loadEnglishSource(),
      repository.loadChineseSource(),
    ]);

    return _ExpressionsScreenData(
      englishBundle: bundles[0] as ExpressionContentBundle,
      chineseBundle: bundles[1] as ExpressionContentBundle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.expressionsTitle),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: l10n.expressionsEnglishTab),
              Tab(text: l10n.expressionsChineseTab),
            ],
          ),
        ),
        body: FutureBuilder<_ExpressionsScreenData>(
          future: _dataFuture,
          builder: (BuildContext context,
              AsyncSnapshot<_ExpressionsScreenData> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '${l10n.expressionsLoadError}: ${snapshot.error ?? ''}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final _ExpressionsScreenData data = snapshot.data!;
            return TabBarView(
              children: <Widget>[
                _ExpressionsList(
                  items: data.englishBundle.items,
                  sourceTextForItem: (ExpressionContentItem item) =>
                      item.text.en,
                  translationTextForItem: (ExpressionContentItem item) =>
                      item.text.zh,
                ),
                _ExpressionsList(
                  items: data.chineseBundle.items,
                  sourceTextForItem: (ExpressionContentItem item) =>
                      item.text.zh,
                  translationTextForItem: (ExpressionContentItem item) =>
                      item.text.en,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ExpressionsList extends StatelessWidget {
  const _ExpressionsList({
    required this.items,
    required this.sourceTextForItem,
    required this.translationTextForItem,
  });

  final List<ExpressionContentItem> items;
  final String Function(ExpressionContentItem item) sourceTextForItem;
  final String Function(ExpressionContentItem item) translationTextForItem;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        final ExpressionContentItem item = items[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _kindLabel(l10n, item.kind),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.expressionsSourceLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  sourceTextForItem(item),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.expressionsTranslationLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  translationTextForItem(item),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _kindLabel(AppLocalizations l10n, String kind) {
    switch (kind) {
      case 'idiom':
        return l10n.expressionsKindIdiom;
      case 'slang':
        return l10n.expressionsKindSlang;
      case 'proverb':
        return l10n.expressionsKindProverb;
      case 'phrase':
        return l10n.expressionsKindPhrase;
      case 'chengyu':
        return l10n.expressionsKindChengyu;
      case 'saying':
        return l10n.expressionsKindSaying;
      default:
        return kind;
    }
  }
}

class _ExpressionsScreenData {
  const _ExpressionsScreenData({
    required this.englishBundle,
    required this.chineseBundle,
  });

  final ExpressionContentBundle englishBundle;
  final ExpressionContentBundle chineseBundle;
}
