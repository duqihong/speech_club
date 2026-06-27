import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: <Widget>[
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.workspace_premium_outlined,
                  color: Color(0xFF355E86),
                ),
                title: Text(l10n.proTitle),
                subtitle: Text(l10n.settingsProSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.pro),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
