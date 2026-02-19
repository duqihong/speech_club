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
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: null,
          minLines: 6,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: 'Type your card text...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
