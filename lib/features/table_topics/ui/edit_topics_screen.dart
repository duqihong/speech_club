import 'package:flutter/material.dart';

class EditTopicsScreen extends StatefulWidget {
  const EditTopicsScreen({
    super.key,
    required this.initialTopics,
  });

  final List<String> initialTopics;

  @override
  State<EditTopicsScreen> createState() => _EditTopicsScreenState();
}

class _EditTopicsScreenState extends State<EditTopicsScreen> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final List<String> padded = List<String>.from(widget.initialTopics);
    if (padded.length > 10) {
      padded.removeRange(10, padded.length);
    }
    while (padded.length < 10) {
      padded.add('');
    }
    _controllers = List<TextEditingController>.generate(
      10,
      (int i) => TextEditingController(text: padded[i]),
    );
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    final List<String> updated = _controllers
        .map((TextEditingController c) => c.text.trim())
        .toList(growable: false);
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Topics'),
        actions: <Widget>[
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _controllers.length,
          itemBuilder: (BuildContext context, int i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _controllers[i],
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Topic ${i + 1}',
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
