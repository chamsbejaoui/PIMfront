import 'package:flutter/material.dart';

import 'screens/players_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ClubOdinApp());
}

class ClubOdinApp extends StatelessWidget {
  const ClubOdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Odin Medical AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const PlayersScreen(),
    );
  }
}
