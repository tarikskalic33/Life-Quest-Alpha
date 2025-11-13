import '../models/goal.dart';

abstract class GoalPersistenceService {
  Future<List<Goal>> loadGoals();

  Future<void> saveGoal(Goal goal);

  Future<void> deleteGoal(String id);
}
