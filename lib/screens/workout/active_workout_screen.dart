import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/exercise.dart';
import '../../models/workout_plan.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key, required this.plan});

  final WorkoutPlan plan;

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final Map<String, List<bool>> _completedSets = {};
  final Map<String, TextEditingController> _repetitionsControllers = {};
  final Map<String, TextEditingController> _loadControllers = {};

  Timer? _workoutTimer;
  Timer? _restTimer;

  int _elapsedSeconds = 0;
  int _remainingRestSeconds = 0;

  @override
  void initState() {
    super.initState();

    for (final exercise in widget.plan.exercises) {
      _completedSets[exercise.id] = List.filled(exercise.sets, false);

      for (var index = 0; index < exercise.sets; index++) {
        final key = '${exercise.id}-$index';

        _repetitionsControllers[key] = TextEditingController(
          text: exercise.repetitions.toString(),
        );

        _loadControllers[key] = TextEditingController(
          text: exercise.load.toStringAsFixed(exercise.load % 1 == 0 ? 0 : 1),
        );
      }
    }

    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();

    for (final controller in _repetitionsControllers.values) {
      controller.dispose();
    }

    for (final controller in _loadControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  int get _totalSets {
    return widget.plan.exercises.fold(
      0,
      (total, exercise) => total + exercise.sets,
    );
  }

  int get _completedCount {
    return _completedSets.values.fold(
      0,
      (total, sets) => total + sets.where((completed) => completed).length,
    );
  }

  double get _progress {
    if (_totalSets == 0) {
      return 0;
    }

    return _completedCount / _totalSets;
  }

  double get _totalVolume {
    var volume = 0.0;

    for (final exercise in widget.plan.exercises) {
      final completed = _completedSets[exercise.id]!;

      for (var index = 0; index < completed.length; index++) {
        if (!completed[index]) {
          continue;
        }

        final key = '${exercise.id}-$index';
        final repetitions =
            int.tryParse(_repetitionsControllers[key]?.text ?? '') ?? 0;

        final load =
            double.tryParse(
              (_loadControllers[key]?.text ?? '').replaceAll(',', '.'),
            ) ??
            0;

        volume += repetitions * load;
      }
    }

    return volume;
  }

  void _toggleSet(Exercise exercise, int index) {
    final sets = _completedSets[exercise.id]!;
    final completed = !sets[index];

    setState(() {
      sets[index] = completed;
    });

    if (completed && exercise.restSeconds > 0) {
      _startRest(exercise.restSeconds);
    }
  }

  void _startRest(int seconds) {
    _restTimer?.cancel();

    setState(() {
      _remainingRestSeconds = seconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingRestSeconds <= 1) {
        timer.cancel();

        setState(() {
          _remainingRestSeconds = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Descanso concluído. Próxima série!'),
            backgroundColor: AppColors.greenDark,
          ),
        );

        return;
      }

      setState(() {
        _remainingRestSeconds--;
      });
    });
  }

  void _skipRest() {
    _restTimer?.cancel();

    setState(() {
      _remainingRestSeconds = 0;
    });
  }

  Future<void> _finishWorkout() async {
    _workoutTimer?.cancel();
    _restTimer?.cancel();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Row(
            children: [
              Icon(Icons.emoji_events, color: AppColors.green),
              SizedBox(width: 10),
              Text(
                'Treino finalizado!',
                style: TextStyle(color: AppColors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SummaryRow(
                label: 'Duração',
                value: _formatTime(_elapsedSeconds),
              ),
              _SummaryRow(
                label: 'Séries concluídas',
                value: '$_completedCount/$_totalSets',
              ),
              _SummaryRow(
                label: 'Volume total',
                value: '${_totalVolume.toStringAsFixed(0)} kg',
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.background,
              ),
              child: const Text('CONCLUIR'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Sair do treino?',
            style: TextStyle(color: AppColors.white),
          ),
          content: const Text(
            'O progresso deste treino será perdido.',
            style: TextStyle(color: AppColors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('CONTINUAR'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'SAIR',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        if (await _confirmExit() && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.plan.name, style: const TextStyle(fontSize: 17)),
              Text(
                _formatTime(_elapsedSeconds),
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Center(
                child: Text(
                  '$_completedCount/$_totalSets',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              backgroundColor: AppColors.card,
              color: AppColors.green,
            ),
            if (_remainingRestSeconds > 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.greenDark,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Descanso: ${_formatTime(_remainingRestSeconds)}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _skipRest,
                      child: const Text('PULAR'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                itemCount: widget.plan.exercises.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, exerciseIndex) {
                  final exercise = widget.plan.exercises[exerciseIndex];

                  return _ActiveExerciseCard(
                    exercise: exercise,
                    completedSets: _completedSets[exercise.id]!,
                    repetitionsControllers: _repetitionsControllers,
                    loadControllers: _loadControllers,
                    onToggleSet: (index) => _toggleSet(exercise, index),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _completedCount == 0 ? null : _finishWorkout,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: AppColors.green,
              foregroundColor: AppColors.background,
              disabledBackgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.flag),
            label: const Text(
              'FINALIZAR TREINO',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveExerciseCard extends StatelessWidget {
  const _ActiveExerciseCard({
    required this.exercise,
    required this.completedSets,
    required this.repetitionsControllers,
    required this.loadControllers,
    required this.onToggleSet,
  });

  final Exercise exercise;
  final List<bool> completedSets;
  final Map<String, TextEditingController> repetitionsControllers;
  final Map<String, TextEditingController> loadControllers;
  final ValueChanged<int> onToggleSet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${exercise.muscleGroup} • ${exercise.restSeconds}s de descanso',
            style: const TextStyle(color: AppColors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              SizedBox(width: 38, child: Text('SÉRIE', style: _labelStyle)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'REPS',
                  textAlign: TextAlign.center,
                  style: _labelStyle,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'KG',
                  textAlign: TextAlign.center,
                  style: _labelStyle,
                ),
              ),
              SizedBox(width: 50),
            ],
          ),
          const SizedBox(height: 7),
          for (var index = 0; index < exercise.sets; index++)
            _SetRow(
              number: index + 1,
              completed: completedSets[index],
              repetitionsController:
                  repetitionsControllers['${exercise.id}-$index']!,
              loadController: loadControllers['${exercise.id}-$index']!,
              onToggle: () => onToggleSet(index),
            ),
        ],
      ),
    );
  }

  static const _labelStyle = TextStyle(
    color: AppColors.grey,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.number,
    required this.completed,
    required this.repetitionsController,
    required this.loadController,
    required this.onToggle,
  });

  final int number;
  final bool completed;
  final TextEditingController repetitionsController;
  final TextEditingController loadController;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: repetitionsController,
              enabled: !completed,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: loadController,
              enabled: !completed,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            child: IconButton.filled(
              onPressed: onToggle,
              style: IconButton.styleFrom(
                backgroundColor: completed
                    ? AppColors.green
                    : AppColors.cardLight,
                foregroundColor: completed
                    ? AppColors.background
                    : AppColors.grey,
              ),
              icon: Icon(completed ? Icons.check : Icons.circle_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.grey)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
