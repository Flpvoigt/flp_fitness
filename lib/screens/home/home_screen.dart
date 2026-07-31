import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bom treino, Felipe!',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Vamos evoluir hoje?',
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.card,
                  child: Icon(Icons.person, color: AppColors.green),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.greenDark,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TREINO DE HOJE',
                        style: TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Icon(Icons.fitness_center, color: AppColors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Costas e bíceps',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '8 exercícios • aproximadamente 60 minutos',
                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'INICIAR TREINO',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.background,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
