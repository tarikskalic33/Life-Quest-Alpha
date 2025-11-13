import 'package:uuid/uuid.dart';

enum GoalStatus {
  notStarted,
  inProgress,
  completed,
  onHold
}

enum GoalPriority {
  low,
  medium,
  high,
  critical
}

class Goal {
  final String id;
  String title;
  String description;
  DateTime createdAt;
  DateTime? dueDate;
  GoalStatus status;
  GoalPriority priority;
  double progress; // 0.0 to 1.0
  List<String> subGoals;
  List<String> tags;

  Goal({
    String? id,
    required this.title,
    required this.description,
    DateTime? createdAt,
    this.dueDate,
    this.status = GoalStatus.notStarted,
    this.priority = GoalPriority.medium,
    this.progress = 0.0,
    List<String>? subGoals,
    List<String>? tags,
  })
      :
        id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        subGoals = subGoals ?? [],
        tags = tags ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status.toString(),
      'priority': priority.toString(),
      'progress': progress,
      'subGoals': subGoals,
      'tags': tags,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: GoalStatus.values.firstWhere(
            (e) => e.toString() == json['status'],
        orElse: () => GoalStatus.notStarted,
      ),
      priority: GoalPriority.values.firstWhere(
            (e) => e.toString() == json['priority'],
        orElse: () => GoalPriority.medium,
      ),
      progress: json['progress'],
      subGoals: List<String>.from(json['subGoals']),
      tags: List<String>.from(json['tags']),
    );
  }
}