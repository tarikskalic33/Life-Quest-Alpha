import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/goals_provider.dart';
import 'goal_detail_screen.dart';
import 'goal_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LifeQuest Platinum'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Not Started'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
              Tab(text: 'On Hold'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GoalList(status: GoalStatus.notStarted),
            _GoalList(status: GoalStatus.inProgress),
            _GoalList(status: GoalStatus.completed),
            _GoalList(status: GoalStatus.onHold),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const GoalEditScreen(),
            ));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _GoalList extends StatelessWidget {
  final GoalStatus status;

  const _GoalList({required this.status});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        final goals = goalsProvider.getGoalsByStatus(status);

        if (goals.isEmpty) {
          return Center(
            child: Text('No ${status
                .toString()
                .split('.')
                .last} goals'),
          );
        }

        return ListView.builder(
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(goal.title),
                subtitle: Text(goal.description),
                trailing: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: goal.progress,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => GoalDetailScreen(goalId: goal.id),
                  ));
                },
              ),
            );
          },
        );
      },
    );
  }
}