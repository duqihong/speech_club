import 'package:flutter/material.dart';

import '../data/my_speech_deck.dart';
import '../data/my_speech_storage.dart';

class DeckEditorPage extends StatefulWidget {
  const DeckEditorPage({super.key});

  @override
  State<DeckEditorPage> createState() => _DeckEditorPageState();
}

class _DeckEditorPageState extends State<DeckEditorPage> {
  final MySpeechStorage _storage = MySpeechStorage();

  MySpeechDeck _deck = MySpeechDeck.empty();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDeck();
  }

  Future<void> _loadDeck() async {
    final MySpeechDeck deck = await _storage.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _deck = deck;
      _loading = false;
    });
  }

  Future<String?> _showCardTextDialog({
    required String title,
    String initialText = '',
  }) async {
    final TextEditingController controller =
        TextEditingController(text: initialText);

    final String? result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 6,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              Navigator.of(dialogContext).pop(controller.text.trim());
            },
            decoration: const InputDecoration(
              hintText: 'Type your card text...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<void> _autosave() async {
    await _storage.save(_deck);
    if (!mounted) {
      return;
    }
  }

  Future<void> _addCard() async {
    final String? text = await _showCardTextDialog(title: 'Add Card');
    if (!mounted) {
      return;
    }
    if (text == null || text.isEmpty) {
      return;
    }

    setState(() {
      _deck.cards.add(text);
    });
    await _autosave();
  }

  Future<void> _editCard(int index) async {
    final String? text = await _showCardTextDialog(
      title: 'Edit Card',
      initialText: _deck.cards[index],
    );
    if (!mounted) {
      return;
    }
    if (text == null || text.isEmpty) {
      return;
    }

    setState(() {
      _deck.cards[index] = text;
    });
    await _autosave();
  }

  Future<void> _deleteCard(int index) async {
    setState(() {
      _deck.cards.removeAt(index);
    });
    await _autosave();
  }

  Future<void> _moveUp(int index) async {
    if (index <= 0) {
      return;
    }
    setState(() {
      final String tmp = _deck.cards[index - 1];
      _deck.cards[index - 1] = _deck.cards[index];
      _deck.cards[index] = tmp;
    });
    await _autosave();
  }

  Future<void> _moveDown(int index) async {
    if (index >= _deck.cards.length - 1) {
      return;
    }
    setState(() {
      final String tmp = _deck.cards[index + 1];
      _deck.cards[index + 1] = _deck.cards[index];
      _deck.cards[index] = tmp;
    });
    await _autosave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit My Speech'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _addCard,
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _deck.cards.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _deck.cards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final String text = _deck.cards[index];
                    return _CardTile(
                      index: index,
                      total: _deck.cards.length,
                      text: text,
                      onTap: () => _editCard(index),
                      onDelete: () => _deleteCard(index),
                      onUp: () => _moveUp(index),
                      onDown: () => _moveDown(index),
                    );
                  },
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'No cards yet.\nTap "Add Card" to create your first one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final int index;
  final int total;
  final String text;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onUp;
  final VoidCallback onDown;

  const _CardTile({
    required this.index,
    required this.total,
    required this.text,
    required this.onTap,
    required this.onDelete,
    required this.onUp,
    required this.onDown,
  });

  @override
  Widget build(BuildContext context) {
    final bool canUp = index > 0;
    final bool canDown = index < total - 1;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: <Widget>[
                  IconButton(
                    tooltip: 'Move up',
                    iconSize: 28,
                    onPressed: canUp ? onUp : null,
                    icon: const Icon(Icons.keyboard_arrow_up),
                  ),
                  IconButton(
                    tooltip: 'Move down',
                    iconSize: 28,
                    onPressed: canDown ? onDown : null,
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    iconSize: 26,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
