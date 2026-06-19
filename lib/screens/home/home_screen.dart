import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../features/flashcards/presentation/my_speech_home_page.dart';
import '../../l10n/app_localizations.dart';
import '../../localization/app_locale_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.localeController,
  });

  final AppLocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double logoWidth = (mediaQuery.size.width * 0.34).clamp(116.0, 148.0);

    final List<_HomeDestination> destinations = <_HomeDestination>[
      _HomeDestination(
        icon: Icons.timer_outlined,
        title: l10n.navTimer,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.timer),
      ),
      _HomeDestination(
        icon: Icons.mic_none_outlined,
        title: l10n.navSpeaker,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const MySpeechHomePage(),
            ),
          );
        },
      ),
      _HomeDestination(
        icon: Icons.lightbulb_outline,
        title: l10n.navTopicSelection,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.topicSelection),
      ),
      _HomeDestination(
        icon: Icons.chat_bubble_outline,
        title: l10n.navTableTopics,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.tableTopics),
      ),
      _HomeDestination(
        icon: Icons.group_outlined,
        title: l10n.navRoleAssistant,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.roleAssistant),
      ),
      _HomeDestination(
        icon: Icons.badge_outlined,
        title: l10n.navCommittees,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.committees),
      ),
      _HomeDestination(
        icon: Icons.route_outlined,
        title: l10n.navPathways,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.pathways),
      ),
      _HomeDestination(
        icon: Icons.emoji_events_outlined,
        title: l10n.navVoteBests,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.voteBests),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        title: Text(l10n.appTitle),
        actions: <Widget>[
          PopupMenuButton<Locale>(
            tooltip: l10n.languageMenuLabel,
            icon: const Icon(Icons.language),
            onSelected: localeController.setLocale,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              PopupMenuItem<Locale>(
                value: AppLocaleController.english,
                child: Text(l10n.languageEnglish),
              ),
              PopupMenuItem<Locale>(
                value: AppLocaleController.simplifiedChinese,
                child: Text(l10n.languageSimplifiedChinese),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset(
                'assets/branding/logo.png',
                width: logoWidth,
                height: logoWidth,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 14),
              GridView.builder(
                itemCount: destinations.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 132,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final _HomeDestination destination = destinations[index];
                  return _HomeCard(
                    icon: destination.icon,
                    title: destination.title,
                    onTap: destination.onTap,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeDestination {
  const _HomeDestination({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isChinese = Localizations.localeOf(context).languageCode == 'zh';

    return Material(
      color: Colors.white.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 30, color: const Color(0xFF355E86)),
              const SizedBox(height: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isChinese ? 28 : 24,
                      fontWeight: FontWeight.w600,
                      height: 1.08,
                      color: const Color(0xFF355E86),
                    ),
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
