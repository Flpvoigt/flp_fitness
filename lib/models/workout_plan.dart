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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'focus': focus,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    final exercisesData = map['exercises'] as List<dynamic>? ?? [];

    return WorkoutPlan(
      id: map['id'] as String,
      name: map['name'] as String,
      focus: map['focus'] as String? ?? '',
      exercises: exercisesData
          .map(
            (exercise) => Exercise.fromMap(
              Map<String, dynamic>.from(exercise as Map),
            ),
          )
          .toList(),
    );
  }
}
