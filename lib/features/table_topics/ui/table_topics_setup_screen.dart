import 'dart:math';

import 'package:flutter/material.dart';

import '../../../shared/topic_dedupe.dart';
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

  List<String> _makeBlankTopics() => List<String>.filled(_kTopicCount, '');

  @override
  void initState() {
    super.initState();
    _topics = _makeBlankTopics();
    _controller = TableTopicsController();
    _controller.init();
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
    return ChoiceChip(
      label: Text(
        category,
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

  void _generate10Topics() {
    final library = _controller.library;
    if (library == null) {
      return;
    }

    final List<String> pool = <String>[];
    final Iterable<String> categoriesToUse = _selectedCategories.isEmpty
        ? library.categories.keys
        : _selectedCategories;

    for (final String category in categoriesToUse) {
      pool.addAll(library.categories[category] ?? const <String>[]);
    }
    if (pool.isEmpty) {
      return;
    }

    final Random random = Random();
    final List<String> uniquePool = dedupeTopics(pool);
    if (uniquePool.isEmpty) {
      return;
    }

    final List<String> result = <String>[];
    final Set<String> seen = <String>{};
    bool addIfUnique(String topic) {
      final String trimmed = topic.trim();
      final String key = normalizeTopic(trimmed);
      if (key.isEmpty) {
        return false;
      }
      if (seen.add(key)) {
        result.add(trimmed);
        return true;
      }
      return false;
    }

    final List<String> shuffledUnique = List<String>.from(uniquePool)
      ..shuffle(random);
    for (final String topic in shuffledUnique) {
      addIfUnique(topic);
      if (result.length >= _kTopicCount) {
        break;
      }
    }

    int attempts = 0;
    while (result.length < _kTopicCount && attempts < 5) {
      attempts++;
      final List<String> more = List<String>.from(pool)..shuffle(random);
      for (final String topic in more) {
        addIfUnique(topic);
        if (result.length >= _kTopicCount) {
          break;
        }
      }
    }

    while (result.length < _kTopicCount) {
      result.add('');
    }

    setState(() {
      _topics = result;
    });
    _controller.setGeneratedTopics(result);
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
    _controller.setGeneratedTopics(updated);
  }

  Future<void> _openPresenterMode() async {
    if (_topics.length == _kTopicCount) {
      _controller.setGeneratedTopics(_topics);
    }

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

  void _resetAll() {
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
    return Column(
      children: <Widget>[
        SizedBox(
          height: 52,
          child: Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: _generate10Topics,
                  child: const Text(
                    'Generate 10 Topics',
                    style: _bodyStyle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _openEditTopics,
                  child: const Text(
                    'Edit 10 Topics',
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
                  child: const Text(
                    'Presenter Mode',
                    style: _bodyStyle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetAll,
                  child: const Text(
                    'Reset',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Table Topics')),
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
                    Text('Error: ${_controller.error}'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _controller.init,
                      child: const Text('Retry', style: _smallStyle),
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
                const Text(
                  'Categories Selection',
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
