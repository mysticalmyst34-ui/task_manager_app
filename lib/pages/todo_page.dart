import 'package:flutter/material.dart';
import '../services/todo_service.dart';
import '../models/todo_model.dart';

class TodoPage extends StatefulWidget {
  final String userId;
  final TodoService todoService;

  TodoPage({super.key, required this.userId, TodoService? todoService})
    : todoService = todoService ?? TodoService();

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();

  void _addTodo() async {
    if (_title.text.trim().isEmpty) return;

    await widget.todoService.addTodo(
      widget.userId,
      _title.text.trim(),
      _desc.text.trim(),
    );

    if (!mounted) return;
    _title.clear();
    _desc.clear();
    Navigator.pop(context);
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _desc,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(onPressed: _addTodo, child: const Text("Add")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Tasks")),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Todo>>(
        stream: widget.todoService.getTodos(widget.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final todos = snapshot.data!;
          if (todos.isEmpty) return const Center(child: Text("No tasks yet"));

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (_, i) {
              final t = todos[i];
              return ListTile(
                title: Text(t.title),
                subtitle: Text(t.description),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => widget.todoService.deleteTodo(t.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
