import 'exercise.dart';

class WorkoutPlan {
  WorkoutPlan({
    required this.id,
    required this.name,
    required this.focus,
    List<Exercise>? exercises,
  }) : exercises = exercises ?? [];

  final String id;
  final String name;
  final String focus;
  final List<Exercise> exercises;

  int get exerciseCount => exercises.length;
}
