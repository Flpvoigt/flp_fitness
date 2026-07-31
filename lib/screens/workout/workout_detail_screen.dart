import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/exercise.dart';
import '../../models/workout_plan.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({required this.plan, super.key});

  final WorkoutPlan plan;

  @override
  State<WorkoutDetailScreen> createState() {
    return _WorkoutDetailScreenState();
  }
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  Future<void> _addExercise() async {
    final nameController = TextEditingController();
    final muscleController = TextEditingController();

    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Novo exercício',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome do exercício',
                  hintText: 'Exemplo: Supino reto',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: muscleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Grupo muscular',
                  hintText: 'Exemplo: Peito',
                  prefixIcon: Icon(Icons.accessibility_new),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final muscle = muscleController.text.trim();

                if (name.isEmpty || muscle.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, [name, muscle]);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    muscleController.dispose();

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      widget.plan.exercises.add(
        Exercise(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: result[0],
          muscleGroup: result[1],
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exercício adicionado!'),
        backgroundColor: AppColors.greenDark,
      ),
    );
  }

  Future<void> _editExercise(Exercise exercise) async {
    final setsController = TextEditingController(
      text: exercise.sets.toString(),
    );
    final repetitionsController = TextEditingController(
      text: exercise.repetitions.toString(),
    );
    final loadController = TextEditingController(
      text: exercise.load.toStringAsFixed(1),
    );
    final restController = TextEditingController(
      text: exercise.restSeconds.toString(),
    );

    final result = await showDialog<List<num>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            exercise.name,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: setsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Séries',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: repetitionsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Repetições',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: loadController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Carga (kg)',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: restController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Descanso (segundos)',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final sets = int.tryParse(setsController.text);
                final repetitions = int.tryParse(repetitionsController.text);
                final load = double.tryParse(
                  loadController.text.replaceAll(',', '.'),
                );
                final rest = int.tryParse(restController.text);

                if (sets == null ||
                    sets <= 0 ||
                    repetitions == null ||
                    repetitions <= 0 ||
                    load == null ||
                    load < 0 ||
                    rest == null ||
                    rest < 0) {
                  return;
                }

                Navigator.pop(dialogContext, [sets, repetitions, load, rest]);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    setsController.dispose();
    repetitionsController.dispose();
    loadController.dispose();
    restController.dispose();

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      exercise.sets = result[0].toInt();
      exercise.repetitions = result[1].toInt();
      exercise.load = result[2].toDouble();
      exercise.restSeconds = result[3].toInt();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exercício atualizado!'),
        backgroundColor: AppColors.greenDark,
      ),
    );
  }

  void _deleteExercise(Exercise exercise) {
    setState(() {
      widget.plan.exercises.removeWhere((item) => item.id == exercise.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
        title: Text(widget.plan.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExercise,
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text(
          'Exercício',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
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
                        child: Icon(
                          Icons.fitness_center,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.plan.focus,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.plan.exerciseCount} exercícios',
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: widget.plan.exercises.isEmpty
                      ? const _EmptyExercises()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: widget.plan.exercises.length,
                          separatorBuilder: (_, _) {
                            return const SizedBox(height: 12);
                          },
                          itemBuilder: (context, index) {
                            final exercise = widget.plan.exercises[index];

                            return Dismissible(
                              key: ValueKey(exercise.id),
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
                                _deleteExercise(exercise);
                              },
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _editExercise(exercise),
                                child: _ExerciseCard(exercise: exercise),
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
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.greenDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${exercise.sets}×',
              style: const TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.muscleGroup,
                  style: const TextStyle(color: AppColors.green, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  '${exercise.sets}×${exercise.repetitions} • '
                  '${exercise.load.toStringAsFixed(1)} kg • '
                  '${exercise.restSeconds}s descanso',
                  style: const TextStyle(color: AppColors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.drag_handle, color: AppColors.grey),
        ],
      ),
    );
  }
}

class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_add, color: AppColors.grey, size: 55),
            SizedBox(height: 14),
            Text(
              'Nenhum exercício',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Adicione os exercícios desta ficha.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
