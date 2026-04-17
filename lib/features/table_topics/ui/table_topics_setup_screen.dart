import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../state/table_topics_controller.dart';
import 'edit_topics_screen.dart';
import 'presenter_grid_screen.dart';

class TableTopicsSetupScreen extends StatefulWidget {
  const TableTopicsSetupScreen({super.key});

  @override
  State<TableTopicsSetupScreen> createState() => _TableTopicsSetupScreenState();
}

class _TableTopicsSetupScreenState extends State<TableTopicsSetupScreen> {
  static const int _kTopicCount = 10;
  static const TextStyle _titleStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static const TextStyle _bodyStyle = TextStyle(fontSize: 17);
  static const TextStyle _smallStyle = TextStyle(fontSize: 15);

  late final TableTopicsController _controller;
  final Set<String> _selectedCategories = <String>{};
  List<String> _topics = <String>[];
  bool _hydratedFromController = false;
  Locale? _loadedLocale;

  List<String> _makeBlankTopics() => List<String>.filled(_kTopicCount, '');

  @override
  void initState() {
    super.initState();
    _topics = _makeBlankTopics();
    _controller = TableTopicsController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Locale locale = Localizations.localeOf(context);
    if (_loadedLocale?.languageCode == locale.languageCode) {
      return;
    }

    _loadedLocale = locale;
    _hydratedFromController = false;
    _controller.init(locale: locale);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _hydrateFromController() {
    if (_hydratedFromController ||
        _controller.loading ||
        _controller.error != null) {
      return;
    }
    _hydratedFromController = true;
    _selectedCategories
      ..clear()
      ..addAll(_controller.selection.selectedCategories);
    _topics =
        List<String>.from(_controller.topicSet?.topics ?? _makeBlankTopics());
  }

  Widget _buildCategoryChip(String category) {
    final bool selected = _selectedCategories.contains(category);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return ChoiceChip(
      label: Text(
        _categoryLabel(l10n, category),
        style: _bodyStyle,
        overflow: TextOverflow.ellipsis,
      ),
      selected: selected,
      onSelected: (_) {
        setState(() {
          if (selected) {
            _selectedCategories.remove(category);
          } else {
            _selectedCategories.add(category);
          }
        });
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _generate10Topics() async {
    await _controller.generateBuiltInTopics(
      selectedCategories: _selectedCategories,
      locale: _loadedLocale,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _topics =
          List<String>.from(_controller.topicSet?.topics ?? _makeBlankTopics());
    });
  }

  Future<void> _openEditTopics() async {
    final List<String>? updated =
        await Navigator.of(context).push<List<String>>(
      MaterialPageRoute<List<String>>(
        builder: (_) =>
            EditTopicsScreen(initialTopics: List<String>.from(_topics)),
      ),
    );

    if (updated == null || updated.length != _kTopicCount) {
      return;
    }

    setState(() {
      _topics = updated;
    });
    await _controller.setGeneratedTopics(
      updated,
      locale: _loadedLocale,
    );
  }

  Future<void> _openPresenterMode() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PresenterGridScreen(controller: _controller),
      ),
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _topics =
          List<String>.from(_controller.topicSet?.topics ?? _makeBlankTopics());
    });
  }

  Future<void> _resetAll() async {
    await _controller.resetSession();
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedCategories.clear();
      _topics = _makeBlankTopics();
    });
  }

  Widget _buildCategoryScroller(List<String> categories) {
    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (final String category in categories) ...<Widget>[
              _buildCategoryChip(category),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionRows() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        SizedBox(
          height: 52,
          child: Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: _generate10Topics,
                  child: Text(
                    l10n.tableTopicsGenerate10,
                    style: _bodyStyle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _openEditTopics,
                  child: Text(
                    l10n.tableTopicsEdit10,
                    style: _bodyStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: _openPresenterMode,
                  child: Text(
                    l10n.tableTopicsPresenterMode,
                    style: _bodyStyle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetAll,
                  child: Text(
                    l10n.buttonReset,
                    style: _bodyStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTopicList() {
    return _topics.asMap().entries.map((MapEntry<int, String> entry) {
      final String text = entry.value.trim();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          '${entry.key + 1}. ${text.isEmpty ? '' : text}',
          style: _bodyStyle,
        ),
      );
    }).toList(growable: false);
  }

  String _categoryLabel(AppLocalizations l10n, String category) {
    switch (category) {
      case 'Daily Life':
        return l10n.tableTopicsCategoryDailyLife;
      case 'Family':
        return l10n.tableTopicsCategoryFamily;
      case 'Travel':
        return l10n.tableTopicsCategoryTravel;
      case 'Work & Career':
        return l10n.tableTopicsCategoryWorkCareer;
      case 'Friendship':
        return l10n.tableTopicsCategoryFriendship;
      case 'Health & Fitness':
        return l10n.tableTopicsCategoryHealthFitness;
      case 'Food':
        return l10n.tableTopicsCategoryFood;
      case 'Technology':
        return l10n.tableTopicsCategoryTechnology;
      case 'Money':
        return l10n.tableTopicsCategoryMoney;
      case 'Education':
        return l10n.tableTopicsCategoryEducation;
      case 'Hobbies':
        return l10n.tableTopicsCategoryHobbies;
      case 'Leadership':
        return l10n.tableTopicsCategoryLeadership;
      case 'Communication':
        return l10n.tableTopicsCategoryCommunication;
      case 'Values':
        return l10n.tableTopicsCategoryValues;
      case 'Culture':
        return l10n.tableTopicsCategoryCulture;
      case 'Fun & Humor':
        return l10n.tableTopicsCategoryFunHumor;
      case 'english_source_expressions':
        return l10n.tableTopicsCategoryEnglishSourceExpressions;
      case 'chinese_source_expressions':
        return l10n.tableTopicsCategoryChineseSourceExpressions;
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tableTopicsTitle)),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, _) {
            if (_controller.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_controller.error != null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        '${l10n.tableTopicsErrorPrefix}: ${_controller.error}'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _controller.init(locale: _loadedLocale),
                      child: Text(l10n.buttonRetry, style: _smallStyle),
                    ),
                  ],
                ),
              );
            }

            _hydrateFromController();

            final List<String> categories = List<String>.from(
              _controller.library?.categoryNames ?? const <String>[],
            )..sort();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              children: <Widget>[
                Text(
                  l10n.tableTopicsCategoriesSelection,
                  style: _titleStyle,
                ),
                const SizedBox(height: 10),
                _buildCategoryScroller(categories),
                const SizedBox(height: 16),
                _buildActionRows(),
                const SizedBox(height: 18),
                ..._buildTopicList(),
              ],
            );
          },
        ),
      ),
    );
  }
}
