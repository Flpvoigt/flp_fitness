import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'screens/app_shell.dart';

class FlpFitnessApp extends StatelessWidget {
  const FlpFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FLP Fitness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.green,
          surface: AppColors.card,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: AppColors.card,
          indicatorColor: AppColors.greenDark,
          iconTheme: WidgetStatePropertyAll(
            IconThemeData(color: AppColors.grey),
          ),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(color: AppColors.white, fontSize: 12),
          ),
        ),
      ),
      home: const AppShell(),
    );
  }
}
