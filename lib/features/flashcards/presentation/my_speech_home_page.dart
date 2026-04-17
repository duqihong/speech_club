import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/my_speech_storage.dart';
import 'deck_editor_page.dart';
import 'presenter_page.dart';

class MySpeechHomePage extends StatefulWidget {
  const MySpeechHomePage({super.key});

  @override
  State<MySpeechHomePage> createState() => _MySpeechHomePageState();
}

class _MySpeechHomePageState extends State<MySpeechHomePage> {
  final MySpeechStorage _storage = MySpeechStorage();

  Future<void> _startPresentation() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final deck = await _storage.load();
    if (!mounted) {
      return;
    }

    if (deck.cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.flashcardsNoCardsYet)),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PresenterPage(cards: deck.cards),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.flashcardsMySpeech),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const DeckEditorPage(),
                    ),
                  );
                },
                child: Text(
                  l10n.flashcardsEditCards,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _startPresentation,
                child: Text(
                  l10n.flashcardsStartPresentation,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
