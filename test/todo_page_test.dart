import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:task_manager_app/pages/todo_page.dart';
import 'package:task_manager_app/services/todo_service.dart';
import 'package:task_manager_app/models/todo_model.dart';

class MockTodoService extends Mock implements TodoService {}

void main() {
  testWidgets('Add todo calls service and closes dialog', (tester) async {
    final mock = MockTodoService();

    when(
      () => mock.getTodos('u1'),
    ).thenAnswer((_) => Stream<List<Todo>>.value(<Todo>[]));
    when(() => mock.addTodo('u1', 'My task', 'Desc')).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: TodoPage(userId: 'u1', todoService: mock),
      ),
    );

    // Open add dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter title & description
    await tester.enterText(find.byType(TextField).at(0), 'My task');
    await tester.enterText(find.byType(TextField).at(1), 'Desc');

    // Tap Add
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    // Verify
    verify(() => mock.addTodo('u1', 'My task', 'Desc')).called(1);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Add todo while unmounted does not throw', (tester) async {
    final mock = MockTodoService();

    when(
      () => mock.getTodos('u1'),
    ).thenAnswer((_) => Stream<List<Todo>>.value(<Todo>[]));

    final completer = Completer<void>();
    when(
      () => mock.addTodo('u1', 'Long task', 'Desc'),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(
      MaterialApp(
        home: TodoPage(userId: 'u1', todoService: mock),
      ),
    );

    // Open add dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter title & description
    await tester.enterText(find.byType(TextField).at(0), 'Long task');
    await tester.enterText(find.byType(TextField).at(1), 'Desc');

    // Tap Add (starts the pending future)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pump();

    // Unmount the page immediately
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    // Complete the pending add
    completer.complete();
    await tester.pumpAndSettle();

    // If we reach here without errors, the mounted guard worked
    expect(true, isTrue);
  });

  testWidgets('Renders todos and delete calls service', (tester) async {
    final mock = MockTodoService();

    final todo = Todo(
      id: 't1',
      title: 'Buy milk',
      description: '2 liters',
      createdAt: DateTime.now(),
    );

    when(
      () => mock.getTodos('u1'),
    ).thenAnswer((_) => Stream<List<Todo>>.value(<Todo>[todo]));
    when(() => mock.deleteTodo('t1')).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: TodoPage(userId: 'u1', todoService: mock),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the item shows
    expect(find.text('Buy milk'), findsOneWidget);

    // Tap delete and verify service call
    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete).first);
    await tester.pumpAndSettle();

    verify(() => mock.deleteTodo('t1')).called(1);
  });
}
