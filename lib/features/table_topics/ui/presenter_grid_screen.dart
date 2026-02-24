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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presenter Mode'),
        centerTitle: true,
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
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 12, 4, 12),
                    child: Text(
                      'Long press a tile to toggle used/unused.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        final bool isWide = constraints.maxWidth >= 700;
                        final int crossAxisCount = isWide ? 5 : 3;

                        return GridView.builder(
                          itemCount: 10,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.95,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final bool used = topicSet.used[index];

                            return _GridTopicButton(
                              number: index + 1,
                              used: used,
                              onTap: () => _openTopic(index),
                              onLongPress: () =>
                                  widget.controller.markUsed(index, !used),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
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
    required this.used,
    required this.onTap,
    required this.onLongPress,
  });

  final int number;
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
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
              if (used)
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.check_circle,
                    size: 20,
                    color: colors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
