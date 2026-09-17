import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasks(String uid) {
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Stream<List<Task>> getTasks(String uid) {
    return _tasks(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(Task.fromFirestore).toList();
    });
  }

  Future<void> createTask({
    required String uid,
    required String title,
    required String description,
  }) async {
    final now = DateTime.now();
    final ref = _tasks(uid).doc();

    await ref.set({
      'title': title.trim(),
      'description': description.trim(),
      'completed': false,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  Future<void> updateTask({
    required String uid,
    required Task task,
    required String title,
    required String description,
  }) async {
    await _tasks(uid).doc(task.id).update({
      'title': title.trim(),
      'description': description.trim(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteTask({
    required String uid,
    required String taskId,
  }) {
    return _tasks(uid).doc(taskId).delete();
  }

  Future<void> toggleTaskCompletion({
    required String uid,
    required Task task,
    required bool completed,
  }) {
    return _tasks(uid).doc(task.id).update({
      'completed': completed,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
