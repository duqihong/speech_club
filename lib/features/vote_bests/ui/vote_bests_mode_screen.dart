import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../screens/pro/pro_screen.dart';
import '../../../services/pro_entitlement_service.dart';
import 'online_count_screen.dart';
import 'vote_bests_screen.dart';

class VoteBestsModeScreen extends StatefulWidget {
  const VoteBestsModeScreen({
    super.key,
    this.proEntitlementService,
  });

  final ProEntitlementService? proEntitlementService;

  @override
  State<VoteBestsModeScreen> createState() => _VoteBestsModeScreenState();
}

class _VoteBestsModeScreenState extends State<VoteBestsModeScreen> {
  late final ProEntitlementService _proEntitlementService;
  late final bool _ownsProEntitlementService;
  bool _hasLoadedProEntitlement = false;
  bool _isCheckingOnlineCountAccess = false;

  @override
  void initState() {
    super.initState();
    _ownsProEntitlementService = widget.proEntitlementService == null;
    _proEntitlementService =
        widget.proEntitlementService ?? ProEntitlementService();
  }

  @override
  void dispose() {
    if (_ownsProEntitlementService) {
      _proEntitlementService.dispose();
    }
    super.dispose();
  }

  Future<void> _ensureProEntitlementLoaded() async {
    if (_hasLoadedProEntitlement) {
      return;
    }

    await _proEntitlementService.initialize();
    _hasLoadedProEntitlement = true;
  }

  void _openManualCount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => VoteBestsScreen()),
    );
  }

  Future<void> _openOnlineCount() async {
    if (_isCheckingOnlineCountAccess) {
      return;
    }

    setState(() {
      _isCheckingOnlineCountAccess = true;
    });
    await _ensureProEntitlementLoaded();
    if (!mounted) {
      return;
    }
    setState(() {
      _isCheckingOnlineCountAccess = false;
    });

    if (!_proEntitlementService.isProActive) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProScreen(
            proEntitlementService: _proEntitlementService,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OnlineCountScreen()),
    );
  }

  Widget _buildModeCard({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.voteBestsTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  l10n.voteBestsModeIntro,
                  style: const TextStyle(fontSize: 18, height: 1.35),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildModeCard(
              icon: '📝',
              title: l10n.voteBestsManualCount,
              subtitle: l10n.voteBestsManualCountSubtitle,
              onTap: () => _openManualCount(context),
            ),
            const SizedBox(height: 12),
            _buildModeCard(
              icon: '☁️',
              title: l10n.voteBestsOnlineCount,
              subtitle: l10n.voteBestsOnlineCountSubtitle,
              onTap: _isCheckingOnlineCountAccess
                  ? null
                  : () => unawaited(_openOnlineCount()),
            ),
          ],
        ),
      ),
    );
  }
}
