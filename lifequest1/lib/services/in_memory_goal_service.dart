import 'dart:async';
import '../models/goal.dart';
import 'goal_persistence_service.dart';

class InMemoryGoalService implements GoalPersistenceService {
  final List<Goal> _goals = [];

  @override
  Future<List<Goal>> loadGoals() async {
    return List.unmodifiable(_goals);
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx == -1) {
      _goals.add(goal);
    } else {
      _goals[idx] = goal;
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
  }
}
