import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../state/table_topics_controller.dart';

class TopicFullscreenView extends StatefulWidget {
  const TopicFullscreenView({
    super.key,
    required this.controller,
    required this.index,
    required this.topic,
  });

  final TableTopicsController controller;
  final int index;
  final String topic;

  @override
  State<TopicFullscreenView> createState() => _TopicFullscreenViewState();
}

class _TopicFullscreenViewState extends State<TopicFullscreenView> {
  @override
  void initState() {
    super.initState();
    widget.controller.markUsed(widget.index, true);
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String displayTopic = widget.topic.trim().isEmpty
        ? l10n.tableTopicsPlaceholderTopic
        : widget.topic;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Text(
                  displayTopic,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 6,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: l10n.buttonBack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
