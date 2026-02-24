import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'features/table_topics/ui/table_topics_setup_screen.dart';
import 'role_assistant/ui/role_assistant_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/timer/timer_screen.dart';

void main() {
  runApp(const SpeechClubApp());
}

class SpeechClubApp extends StatelessWidget {
  const SpeechClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      routes: <String, WidgetBuilder>{
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.timer: (_) => const TimerScreen(),
        AppRoutes.tableTopics: (_) => const TableTopicsSetupScreen(),
        AppRoutes.roleAssistant: (_) => const RoleAssistantScreen(),
      },
    );
  }
}
