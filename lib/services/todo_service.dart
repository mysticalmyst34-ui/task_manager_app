import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Todo>> getTodos(String userId) {
    return _firestore
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Todo.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addTodo(String userId, String title, String description) async {
    await _firestore.collection('todos').add({
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteTodo(String id) async {
    await _firestore.collection('todos').doc(id).delete();
  }
}
