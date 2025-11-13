import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import 'goal_edit_screen.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GoalsProvider>(context);
    final goal = provider.getGoalById(goalId);

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goal')),
        body: const Center(child: Text('Goal not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => GoalEditScreen(goalId: goal.id),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              provider.deleteGoal(goal.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.description, style: Theme
                .of(context)
                .textTheme
                .bodyLarge),
            const SizedBox(height: 12),
            Row(children: [
              Text('Status: ${goal.status
                  .toString()
                  .split('.')
                  .last}'),
              const SizedBox(width: 12),
              Text('Priority: ${goal.priority
                  .toString()
                  .split('.')
                  .last}'),
            ]),
            const SizedBox(height: 12),
            if (goal.dueDate != null) Text('Due: ${goal.dueDate!
                .toLocal()
                .toString()
                .split(' ')
                .first}'),
            const SizedBox(height: 12),
            Text('Progress'),
            Slider(
              value: goal.progress,
              onChanged: (v) {
                provider.updateGoalProgress(goal.id, v);
              },
            ),
          ],
        ),
      ),
    );
  }
}