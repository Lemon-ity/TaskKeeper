import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final created = data['createdAt'];
    final updated = data['updatedAt'];

    return Task(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      completed: (data['completed'] as bool?) ?? false,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      updatedAt: updated is Timestamp
          ? updated.toDate()
          : (created is Timestamp ? created.toDate() : DateTime.now()),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
