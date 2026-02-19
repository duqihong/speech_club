import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';

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
      home: const HomeScreen(),
    );
  }
}
