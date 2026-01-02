import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: KabaddiApp()));
}

class KabaddiApp extends StatelessWidget {
  const KabaddiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.theme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
