import 'package:flutter/material.dart';
import 'package:unp_calendario/app/theme/app_theme.dart';
import 'package:unp_calendario/pages/pg_ux_demo_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNP Calendario',
      theme: AppTheme.lightTheme,
      home: const MainPage(),
    );
  }
} 