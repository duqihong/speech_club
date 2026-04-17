import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class SpeakerListScreen extends StatelessWidget {
  const SpeakerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 28,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.flashcardsMySpeeches),
      ),
      body: Center(
        child: Text(
          l10n.flashcardsMySpeeches,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
