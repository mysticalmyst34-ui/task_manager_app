import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String userId;
  final String title;
  final String description;
  final bool isCompleted;
  final String priority;
  final DateTime? dueDate;

  Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.priority,
    this.dueDate,
  });

  factory Todo.fromMap(String id, Map<String, dynamic> data) {
    return Todo(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      priority: data['priority'] ?? 'medium',
      dueDate: data['dueDate'] is Timestamp
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
    );
  }
}
