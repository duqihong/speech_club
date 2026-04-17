import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../state/table_topics_controller.dart';
import 'presenter_grid_screen.dart';

class CustomTopicsScreen extends StatefulWidget {
  const CustomTopicsScreen({
    super.key,
    required this.controller,
  });

  final TableTopicsController controller;

  @override
  State<CustomTopicsScreen> createState() => _CustomTopicsScreenState();
}

class _CustomTopicsScreenState extends State<CustomTopicsScreen> {
  static const int _fieldCount = 10;
  late final List<TextEditingController> _controllers;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      _fieldCount,
      (int index) {
        final String initial = index < widget.controller.customTopics.length
            ? widget.controller.customTopics[index]
            : '';
        return TextEditingController(text: initial);
      },
    );
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> _collectNonEmptyTopics() {
    return _controllers
        .map((TextEditingController c) => c.text.trim())
        .where((String text) => text.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    await widget.controller.saveCustomTopics(_collectNonEmptyTopics());
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.tableTopicsCustomTopicsSaved)),
    );
  }

  Future<void> _useTheseTopics() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<String> topics = _collectNonEmptyTopics();
    if (topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tableTopicsAddAtLeastOne)),
      );
      return;
    }

    setState(() => _saving = true);
    await widget.controller.saveCustomTopics(topics);
    widget.controller.useCustomTopics(topics);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PresenterGridScreen(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tableTopicsCustomTopics)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(l10n.tableTopicsEnterCustomTopics),
            const SizedBox(height: 12),
            for (int i = 0; i < _fieldCount; i++) ...<Widget>[
              TextField(
                controller: _controllers[i],
                minLines: 1,
                maxLines: 2,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.tableTopicsTopicLabel(i + 1),
                ),
              ),
              const SizedBox(height: 10),
            ],
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(l10n.buttonSave),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _useTheseTopics,
              child: Text(l10n.tableTopicsUseTheseTopics),
            ),
          ],
        ),
      ),
    );
  }
}
