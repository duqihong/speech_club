import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../features/flashcards/presentation/my_speech_home_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double logoWidth = (w * 0.58).clamp(220.0, 240.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 18),
              Center(
                child: Image.asset(
                  'assets/branding/logo.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: <Widget>[
                    _HomeCard(
                      icon: Icons.timer_outlined,
                      title: 'Timer',
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.timer);
                      },
                    ),
                    const SizedBox(height: 16),
                    _HomeCard(
                      icon: Icons.mic_none_outlined,
                      title: 'Speaker',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const MySpeechHomePage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _HomeCard(
                      icon: Icons.chat_bubble_outline,
                      title: 'Table Topics',
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.tableTopics);
                      },
                    ),
                    const SizedBox(height: 16),
                    _HomeCard(
                      icon: Icons.group_outlined,
                      title: 'Role Assistant',
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.roleAssistant);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    return Material(
      color: Colors.white.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              Icon(icon, size: 30, color: const Color(0xFF355E86)),
              const SizedBox(width: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF355E86),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
