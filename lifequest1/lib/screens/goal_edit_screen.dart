import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/goals_provider.dart';

class GoalEditScreen extends StatefulWidget {
  final String? goalId; // null -> create

  const GoalEditScreen({super.key, this.goalId});

  @override
  State<GoalEditScreen> createState() => _GoalEditScreenState();
}

class _GoalEditScreenState extends State<GoalEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  DateTime? _dueDate;
  GoalPriority _priority = GoalPriority.medium;
  double _progress = 0.0;

  bool _isInit = true;
  Goal? _editingGoal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      if (widget.goalId != null) {
        final provider = Provider.of<GoalsProvider>(context, listen: false);
        _editingGoal = provider.getGoalById(widget.goalId!);
        if (_editingGoal != null) {
          _title = _editingGoal!.title;
          _description = _editingGoal!.description;
          _dueDate = _editingGoal!.dueDate;
          _priority = _editingGoal!.priority;
          _progress = _editingGoal!.progress;
        }
      } else {
        _title = '';
        _description = '';
      }
      _isInit = false;
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final provider = Provider.of<GoalsProvider>(context, listen: false);
    if (_editingGoal != null) {
      _editingGoal!.title = _title;
      _editingGoal!.description = _description;
      _editingGoal!.dueDate = _dueDate;
      _editingGoal!.priority = _priority;
      _editingGoal!.progress = _progress;
      provider.updateGoal(_editingGoal!);
    } else {
      final newGoal = Goal(
        title: _title,
        description: _description,
        dueDate: _dueDate,
        priority: _priority,
        progress: _progress,
      );
      provider.addGoal(newGoal);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingGoal != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Goal' : 'Create Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                  (v == null || v
                      .trim()
                      .isEmpty) ? 'Required' : null,
                  onSaved: (v) => _title = v!.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _description,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (v) => _description = v ?? '',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(_dueDate != null
                          ? 'Due: ${_dueDate!
                          .toLocal()
                          .toString()
                          .split(' ')
                          .first}'
                          : 'No due date'),
                    ),
                    TextButton(
                        onPressed: _pickDueDate, child: const Text('Pick')),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<GoalPriority>(
                  initialValue: _priority,
                  items: GoalPriority.values
                      .map((p) =>
                      DropdownMenuItem(value: p, child: Text(p
                          .toString()
                          .split('.')
                          .last)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _priority = v ?? GoalPriority.medium),
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
                const SizedBox(height: 12),
                Text('Progress: ${(_progress * 100).round()}%'),
                Slider(
                  value: _progress,
                  onChanged: (v) => setState(() => _progress = v),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}