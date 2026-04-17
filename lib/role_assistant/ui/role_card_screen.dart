import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_routes.dart';
import '../../features/flashcards/presentation/my_speech_home_page.dart';
import '../../l10n/app_localizations.dart';
import '../models/role_model.dart';

class RoleCardScreen extends StatefulWidget {
  const RoleCardScreen({
    super.key,
    required this.role,
  });

  final RoleModel role;

  @override
  State<RoleCardScreen> createState() => _RoleCardScreenState();
}

class _RoleCardScreenState extends State<RoleCardScreen> {
  String _toolButtonText(AppLocalizations l10n, String deepLink) {
    if (deepLink == AppRoutes.timer) {
      return l10n.roleAssistantOpenTimerTool;
    }
    if (deepLink == AppRoutes.tableTopics) {
      return l10n.roleAssistantOpenTableTopics;
    }
    return l10n.roleAssistantOpenTool;
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistSection(String key, String title) {
    final List<String> items = widget.role.checklist[key] ?? const <String>[];
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          for (final String item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('✅ $item', style: const TextStyle(fontSize: 17)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.role.icon} ${_roleTitleLabel(l10n, widget.role.id)}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSectionCard(
                title: l10n.roleAssistantRolePurpose,
                child: Text(widget.role.purpose,
                    style: const TextStyle(fontSize: 18)),
              ),
              _buildSectionCard(
                title: l10n.roleAssistantChecklist,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildChecklistSection('before', l10n.roleAssistantBefore),
                    _buildChecklistSection('during', l10n.roleAssistantDuring),
                    _buildChecklistSection('after', l10n.roleAssistantAfter),
                  ],
                ),
              ),
              _buildSectionCard(
                title: l10n.roleAssistantQuickTips,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.role.tips
                      .map((String tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('• $tip',
                                style: const TextStyle(fontSize: 17)),
                          ))
                      .toList(growable: false),
                ),
              ),
              _buildSectionCard(
                title: l10n.roleAssistantExamplePhrasing,
                child: Column(
                  children: widget.role.scripts.map((String script) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(script, style: const TextStyle(fontSize: 17)),
                      trailing: const Icon(Icons.copy),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: script));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.roleAssistantCopied)),
                        );
                      },
                    );
                  }).toList(growable: false),
                ),
              ),
              if (widget.role.id == 'speaker') ...<Widget>[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const MySpeechHomePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.note),
                    label: Text(l10n.roleAssistantOpenSpeakerFlashcard),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (widget.role.deepLink != null)
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(widget.role.deepLink!);
                  },
                  child: Text(_toolButtonText(l10n, widget.role.deepLink!)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleTitleLabel(AppLocalizations l10n, String roleId) {
    switch (roleId) {
      case 'toastmaster_of_the_day':
        return l10n.roleAssistantTitleToastmasterOfTheDay;
      case 'timer':
        return l10n.roleAssistantTitleTimer;
      case 'table_topics_master':
        return l10n.roleAssistantTitleTableTopicsMaster;
      case 'evaluator':
        return l10n.roleAssistantTitleEvaluator;
      case 'language_evaluator':
        return l10n.roleAssistantTitleLanguageEvaluator;
      case 'ah_counter':
        return l10n.roleAssistantTitleAhCounter;
      case 'speaker':
        return l10n.roleAssistantTitleSpeaker;
      case 'general_evaluator':
        return l10n.roleAssistantTitleGeneralEvaluator;
      default:
        return roleId;
    }
  }
}
