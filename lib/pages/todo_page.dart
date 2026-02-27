import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';

class TodoPage extends StatefulWidget {
  final String userId;
  const TodoPage({super.key, required this.userId});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TodoService _todoService = TodoService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Todo? _editingTodo;

  // ---------------- DIALOG ----------------
  void _openTodoDialog({Todo? todo}) {
    if (todo != null) {
      _editingTodo = todo;
      _titleController.text = todo.title;
      _descriptionController.text = todo.description;
    } else {
      _editingTodo = null;
      _titleController.clear();
      _descriptionController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(todo == null ? 'Add Task' : 'Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.trim().isEmpty) return;

              if (_editingTodo == null) {
                await _todoService.addTodo(
                  userId: widget.userId,
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                );
              } else {
                await _todoService.updateTodo(
                  id: _editingTodo!.id,
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                );
              }

              Navigator.pop(context);
            },
            child: Text(todo == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: StreamBuilder<List<Todo>>(
        stream: _todoService.getTodos(widget.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final todos = snapshot.data!;

          if (todos.isEmpty) {
            return const Center(child: Text('No tasks yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: _glassDecoration(),
                      child: Row(
                        children: [
                          Checkbox(
                            value: todo.isCompleted,
                            onChanged: (_) {
                              _todoService.toggleTodoStatus(
                                todo.id,
                                todo.isCompleted,
                              );
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  todo.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (todo.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      todo.description,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _openTodoDialog(todo: todo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _todoService.deleteTodo(todo.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTodoDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------------- GLASS DECORATION ----------------
  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.25),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    );
  }
}

Widget _priorityChip(String p) {
  final color = p == 'high'
      ? Colors.red
      : p == 'medium'
      ? Colors.orange
      : Colors.green;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(p.toUpperCase(), style: TextStyle(color: color, fontSize: 12)),
  );
}
