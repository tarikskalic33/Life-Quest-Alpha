import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal.dart';
import 'goal_persistence_service.dart';

class FirebaseGoalService implements GoalPersistenceService {
  final _collection = FirebaseFirestore.instance.collection('goals');

  @override
  Future<List<Goal>> loadGoals() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Goal.fromJson(doc.data())).toList();
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    await _collection.doc(goal.id).set(goal.toJson());
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _collection.doc(id).delete();
  }
}
