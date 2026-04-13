import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const StockFlowApp());
}

class StockFlowApp extends StatelessWidget {
  const StockFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema,
      home: const DashboardScreen(),
    );
  }
}