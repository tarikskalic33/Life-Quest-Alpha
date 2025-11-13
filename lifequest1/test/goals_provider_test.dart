import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest1/models/goal.dart';
import 'package:lifequest1/providers/goals_provider.dart';
import 'package:lifequest1/services/in_memory_goal_service.dart';

void main() {
  group('GoalsProvider', () {
    late GoalsProvider provider;

    setUp(() {
      provider = GoalsProvider(service: InMemoryGoalService());
    });

    test('add and retrieve goal', () async {
      final g = Goal(title: 'Test', description: 'desc');
      await provider.addGoal(g);
      expect(provider.goals.length, 1);
      expect(provider.getGoalById(g.id)!.title, 'Test');
    });

    test('update progress and status', () async {
      final g = Goal(title: 'P', description: 'd');
      await provider.addGoal(g);
      await provider.updateGoalProgress(g.id, 0.5);
      final updated = provider.getGoalById(g.id)!;
      expect(updated.progress, 0.5);
      expect(updated.status, GoalStatus.inProgress);

      await provider.updateGoalProgress(g.id, 1.0);
      expect(provider.getGoalById(g.id)!.status, GoalStatus.completed);
    });

    test('delete goal', () async {
      final g = Goal(title: 'ToDelete', description: 'd');
      await provider.addGoal(g);
      expect(provider.goals.length, 1);
      await provider.deleteGoal(g.id);
      expect(provider.goals.isEmpty, true);
    });
  });
}