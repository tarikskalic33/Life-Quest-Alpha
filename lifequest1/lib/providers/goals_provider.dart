import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../services/goal_persistence_service.dart';
import '../services/in_memory_goal_service.dart';

class GoalsProvider with ChangeNotifier {
  final GoalPersistenceService _service;
  final List<Goal> _goals = [];

  GoalsProvider({GoalPersistenceService? service})
      : _service = service ?? InMemoryGoalService() {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final loaded = await _service.loadGoals();
    _goals.clear();
    _goals.addAll(loaded);
    notifyListeners();
  }

  List<Goal> get goals => List.unmodifiable(_goals);

  List<Goal> getGoalsByStatus(GoalStatus status) {
    return _goals.where((goal) => goal.status == status).toList();
  }

  List<Goal> getGoalsByPriority(GoalPriority priority) {
    return _goals.where((goal) => goal.priority == priority).toList();
  }

  Goal? getGoalById(String id) {
    try {
      return _goals.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addGoal(Goal goal) async {
    await _service.saveGoal(goal);
    await _loadGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    await _service.saveGoal(goal);
    await _loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _service.deleteGoal(id);
    await _loadGoals();
  }

  Future<void> updateGoalProgress(String id, double progress) async {
    final goal = getGoalById(id);
    if (goal != null) {
      goal.progress = progress.clamp(0.0, 1.0);
      if (progress >= 1.0) {
        goal.status = GoalStatus.completed;
      } else if (progress > 0.0) {
        goal.status = GoalStatus.inProgress;
      }
      await _service.saveGoal(goal);
      await _loadGoals();
    }
  }

  Future<void> updateGoalStatus(String id, GoalStatus status) async {
    final goal = getGoalById(id);
    if (goal != null) {
      goal.status = status;
      if (status == GoalStatus.completed) {
        goal.progress = 1.0;
      }
      await _service.saveGoal(goal);
      await _loadGoals();
    }
  }
}