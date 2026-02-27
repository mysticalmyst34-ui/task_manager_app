import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // READ
  Stream<List<Todo>> getTodos(String userId) {
    return _db
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Todo.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // CREATE
  Future<void> addTodo({
    required String userId,
    required String title,
    required String description,
  }) async {
    await _db.collection('todos').add({
      'userId': userId,
      'title': title,
      'description': description,
      'isCompleted': false,
      'createdAt': Timestamp.now(),
    });
  }

  // UPDATE
  Future<void> updateTodo({
    required String id,
    required String title,
    required String description,
  }) async {
    await _db.collection('todos').doc(id).update({
      'title': title,
      'description': description,
    });
  }

  // DELETE
  Future<void> deleteTodo(String id) async {
    await _db.collection('todos').doc(id).delete();
  }

  // TOGGLE CHECKBOX
  Future<void> toggleTodoStatus(String id, bool current) async {
    await _db.collection('todos').doc(id).update({'isCompleted': !current});
  }
}
