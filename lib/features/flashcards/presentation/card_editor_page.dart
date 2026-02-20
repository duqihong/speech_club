import 'package:flutter/material.dart';

class CardEditorPage extends StatefulWidget {
  final String title;
  final String initialText;

  const CardEditorPage({
    super.key,
    required this.title,
    this.initialText = '',
  });

  @override
  State<CardEditorPage> createState() => _CardEditorPageState();
}

class _CardEditorPageState extends State<CardEditorPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cancel() {
    Navigator.of(context).pop(null);
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final String text = _controller.text.trim();
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancel,
          tooltip: 'Cancel',
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 20, height: 1.3),
                  decoration: InputDecoration(
                    hintText: widget.title.contains('Paste')
                        ? 'Paste your speech here.\n\nUse blank lines to separate cards.'
                        : 'Type your card text...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(16),
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
