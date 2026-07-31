import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/workout_plan.dart';
import 'workout_detail_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final List<WorkoutPlan> _plans = [
    WorkoutPlan(id: '1', name: 'Treino A', focus: 'Peito e tríceps'),
    WorkoutPlan(id: '2', name: 'Treino B', focus: 'Costas e bíceps'),
    WorkoutPlan(id: '3', name: 'Treino C', focus: 'Pernas'),
  ];

  Future<void> _createWorkoutPlan() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final focusController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Nova ficha',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome da ficha',
                    hintText: 'Exemplo: Treino D',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome da ficha';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: focusController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Foco do treino',
                    hintText: 'Exemplo: Ombros e braços',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o foco do treino';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Criar ficha'),
            ),
          ],
        );
      },
    );

    if (created == true && mounted) {
      setState(() {
        _plans.add(
          WorkoutPlan(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: nameController.text.trim(),
            focus: focusController.text.trim(),
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ficha criada com sucesso!'),
          backgroundColor: AppColors.greenDark,
        ),
      );
    }

    nameController.dispose();
    focusController.dispose();
  }

  void _deleteWorkoutPlan(WorkoutPlan plan) {
    setState(() {
      _plans.removeWhere((item) => item.id == plan.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plan.name} foi excluído.'),
        backgroundColor: AppColors.greenDark,
      ),
    );
  }

  Future<void> _openWorkoutPlan(WorkoutPlan plan) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return WorkoutDetailScreen(plan: plan);
        },
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createWorkoutPlan,
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nova ficha',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(child: _buildHeader()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(child: _buildSummary()),
                ),
                if (_plans.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyWorkoutPlans(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList.separated(
                      itemCount: _plans.length,
                      separatorBuilder: (_, _) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (context, index) {
                        final plan = _plans[index];

                        return Dismissible(
                          key: ValueKey(plan.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 22),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            _deleteWorkoutPlan(plan);
                          },
                          child: _WorkoutPlanCard(
                            plan: plan,
                            onTap: () {
                              _openWorkoutPlan(plan);
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meus treinos',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Crie fichas e acompanhe sua progressão.',
          style: TextStyle(color: AppColors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.greenDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.card,
            child: Icon(Icons.calendar_month_outlined, color: AppColors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_plans.length} fichas cadastradas',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Organize sua semana de treinamento.',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPlanCard extends StatelessWidget {
  const _WorkoutPlanCard({required this.plan, required this.onTap});

  final WorkoutPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.greenDark,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.fitness_center, color: AppColors.green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.focus,
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${plan.exerciseCount} exercícios',
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWorkoutPlans extends StatelessWidget {
  const _EmptyWorkoutPlans();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, color: AppColors.grey, size: 50),
            SizedBox(height: 14),
            Text(
              'Nenhuma ficha cadastrada',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Use o botão “Nova ficha” para começar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
