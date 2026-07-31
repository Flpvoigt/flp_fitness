class Exercise {
  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.sets = 3,
    this.repetitions = 10,
    this.load = 0,
    this.restSeconds = 60,
  });

  final String id;
  final String name;
  final String muscleGroup;

  int sets;
  int repetitions;
  double load;
  int restSeconds;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'sets': sets,
      'repetitions': repetitions,
      'load': load,
      'restSeconds': restSeconds,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscleGroup'] as String? ?? '',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      repetitions: (map['repetitions'] as num?)?.toInt() ?? 10,
      load: (map['load'] as num?)?.toDouble() ?? 0,
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 60,
    );
  }
}
