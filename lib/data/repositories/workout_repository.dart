import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/workout_plan.dart';

class WorkoutRepository {
  static const String _storageKey = 'flp_fitness_workout_plans_v1';

  Future<List<WorkoutPlan>> loadPlans() async {
    final preferences = await SharedPreferences.getInstance();
    final storedValue = preferences.getString(_storageKey);

    if (storedValue == null || storedValue.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(storedValue) as List<dynamic>;

      return decoded
          .map(
            (item) => WorkoutPlan.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePlans(List<WorkoutPlan> plans) async {
    final preferences = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      plans.map((plan) => plan.toMap()).toList(),
    );

    await preferences.setString(_storageKey, encoded);
  }

  Future<void> clearPlans() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
