import 'package:flutter/material.dart';
import 'workout/workout_screen.dart';

import '../core/theme/app_colors.dart';
import 'home/home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    WorkoutScreen(),
    FeatureScreen(
      title: 'Evolução',
      subtitle: 'Acompanhe peso, medidas e desempenho.',
      icon: Icons.show_chart,
    ),
    FeatureScreen(
      title: 'Nutrição',
      subtitle: 'Controle calorias e macronutrientes.',
      icon: Icons.restaurant,
    ),
    FeatureScreen(
      title: 'FLP Personal Bot',
      subtitle: 'Seu assistente pessoal de treino e dieta.',
      icon: Icons.smart_toy_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        height: 72,
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.greenDark,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.green),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center, color: AppColors.green),
            label: 'Treino',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            selectedIcon: Icon(Icons.show_chart, color: AppColors.green),
            label: 'Evolução',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant, color: AppColors.green),
            label: 'Dieta',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy, color: AppColors.green),
            label: 'FLP Bot',
          ),
        ],
      ),
    );
  }
}

class FeatureScreen extends StatelessWidget {
  const FeatureScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.grey, fontSize: 14),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.greenDark,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Icon(icon, size: 54, color: AppColors.green),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
