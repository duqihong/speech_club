import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_routes.dart';
import '../../features/flashcards/presentation/my_speech_home_page.dart';
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
  String _toolButtonText(String deepLink) {
    if (deepLink == AppRoutes.timer) {
      return 'Open Timer Tool';
    }
    if (deepLink == AppRoutes.tableTopics) {
      return 'Open Table Topics';
    }
    return 'Open Tool';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role.icon} ${widget.role.title}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSectionCard(
                title: 'Role Purpose',
                child: Text(widget.role.purpose,
                    style: const TextStyle(fontSize: 18)),
              ),
              _buildSectionCard(
                title: 'Checklist',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildChecklistSection('before', 'Before'),
                    _buildChecklistSection('during', 'During'),
                    _buildChecklistSection('after', 'After'),
                  ],
                ),
              ),
              _buildSectionCard(
                title: 'Quick Tips',
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
                title: 'Example Phrasing',
                child: Column(
                  children: widget.role.scripts.map((String script) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(script, style: const TextStyle(fontSize: 17)),
                      trailing: const Icon(Icons.copy),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: script));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied')),
                        );
                      },
                    );
                  }).toList(growable: false),
                ),
              ),
              if (widget.role.title == 'Speaker') ...<Widget>[
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
                    label: const Text('Open Speaker Flashcard'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (widget.role.deepLink != null)
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(widget.role.deepLink!);
                  },
                  child: Text(_toolButtonText(widget.role.deepLink!)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
