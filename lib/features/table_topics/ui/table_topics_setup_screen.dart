import 'package:flutter/material.dart';

import 'custom_topics_screen.dart';
import 'presenter_grid_screen.dart';
import '../state/table_topics_controller.dart';

class TableTopicsSetupScreen extends StatefulWidget {
  const TableTopicsSetupScreen({super.key});

  @override
  State<TableTopicsSetupScreen> createState() => _TableTopicsSetupScreenState();
}

class _TableTopicsSetupScreenState extends State<TableTopicsSetupScreen> {
  late final TableTopicsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TableTopicsController();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                    const Text('Table Topics'),
                    const SizedBox(height: 8),
                    Text('Error: ${_controller.error}'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _controller.init,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final library = _controller.library;
            final List<String> categories =
                library?.categoryNames ?? const <String>[];
            final int totalTopics = library?.totalTopicCount ?? 0;
            final topicSet = _controller.topicSet;
            final bool canEnterPresenter =
                topicSet != null && topicSet.topics.length == 10;
            final List<String> customPreview =
                _controller.customTopics.take(3).toList();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Table Topics',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Categories=${categories.length} TotalTopics=$totalTopics',
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Auto Generate'),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Custom'),
                      ),
                    ],
                    selected: <bool>{_controller.isCustomMode},
                    onSelectionChanged: (Set<bool> values) {
                      _controller.setCustomMode(values.first);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (!_controller.isCustomMode) ...<Widget>[
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Random All'),
                      value: _controller.selection.randomAll,
                      onChanged: _controller.toggleRandomAll,
                    ),
                    if (!_controller.selection.randomAll) ...<Widget>[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((String category) {
                          final bool selected = _controller
                              .selection.selectedCategories
                              .contains(category);
                          return FilterChip(
                            label: Text(category),
                            selected: selected,
                            onSelected: (_) =>
                                _controller.toggleCategory(category),
                          );
                        }).toList(growable: false),
                      ),
                    ],
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed:
                          library == null ? null : _controller.generate10,
                      child: const Text('Generate 10 Topics'),
                    ),
                  ] else ...<Widget>[
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CustomTopicsScreen(
                              controller: _controller,
                            ),
                          ),
                        );
                      },
                      child: const Text('Edit Custom Topics'),
                    ),
                    const SizedBox(height: 8),
                    if (_controller.customTopics.isEmpty)
                      const Text('No saved custom topics yet.')
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Saved Custom Topics',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          for (int i = 0; i < customPreview.length; i++)
                            Text('${i + 1}. ${customPreview[i]}'),
                          if (_controller.customTopics.length >
                              customPreview.length)
                            Text(
                                '+${_controller.customTopics.length - customPreview.length} more'),
                        ],
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _controller.customTopics.isEmpty
                          ? null
                          : () {
                              _controller
                                  .useCustomTopics(_controller.customTopics);
                            },
                      child: const Text('Use Custom Topics'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: canEnterPresenter
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PresenterGridScreen(
                                    controller: _controller),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Presenter Mode'),
                  ),
                  const SizedBox(height: 12),
                  if (topicSet == null)
                    const Text('No topics generated yet.')
                  else
                    const Text(
                      'Generated Topics',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: topicSet == null
                        ? const SizedBox.shrink()
                        : ListView.separated(
                            itemCount: topicSet.topics.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                    '${index + 1}. ${topicSet.topics[index]}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
