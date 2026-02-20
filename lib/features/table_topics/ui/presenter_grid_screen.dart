import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../state/table_topics_controller.dart';
import 'topic_fullscreen_view.dart';

class PresenterGridScreen extends StatefulWidget {
  const PresenterGridScreen({
    super.key,
    required this.controller,
  });

  final TableTopicsController controller;

  @override
  State<PresenterGridScreen> createState() => _PresenterGridScreenState();
}

class _PresenterGridScreenState extends State<PresenterGridScreen> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _openTopic(int index) async {
    final topicSet = widget.controller.topicSet;
    if (topicSet == null || index >= topicSet.topics.length) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TopicFullscreenView(
          controller: widget.controller,
          index: index,
          topic: topicSet.topics[index],
        ),
      ),
    );

    WakelockPlus.enable();
  }

  Future<void> _confirmReset() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset session?'),
          content: const Text(
            'This will clear the current 10 topics and used marks.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    widget.controller.resetSession();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  String _preview(String topic) {
    final String firstLine = topic.split('\n').first.trim();
    if (firstLine.isEmpty) {
      return '—';
    }
    if (firstLine.length <= 30) {
      return firstLine;
    }
    return '${firstLine.substring(0, 30)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presenter Mode'),
        actions: <Widget>[
          TextButton(
            onPressed: _confirmReset,
            child: const Text('Reset'),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (BuildContext context, _) {
            final topicSet = widget.controller.topicSet;
            if (topicSet == null || topicSet.topics.length != 10) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No 10-topic set found. Return to setup and generate topics.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: GridView.builder(
                      itemCount: 10,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.95,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final bool used = topicSet.used[index];
                        final String topic = topicSet.topics[index];

                        return _GridTopicButton(
                          number: index + 1,
                          preview: _preview(topic),
                          used: used,
                          onTap: () => _openTopic(index),
                          onLongPress: () =>
                              widget.controller.markUsed(index, !used),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Long press a tile to toggle used/unused.'),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _confirmReset,
                      child: const Text('Reset Session'),
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

class _GridTopicButton extends StatelessWidget {
  const _GridTopicButton({
    required this.number,
    required this.preview,
    required this.used,
    required this.onTap,
    required this.onLongPress,
  });

  final int number;
  final String preview;
  final bool used;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: used
          ? colors.surfaceContainerHighest.withValues(alpha: 0.7)
          : colors.primaryContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (used)
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: colors.primary,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: used ? colors.onSurfaceVariant : colors.onSurface,
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
