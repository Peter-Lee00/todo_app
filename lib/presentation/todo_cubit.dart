/*

TO DO CUBIT - simple state management

Each cubit is a list of todos.

*/

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/data/database/database_helper.dart';
import 'package:todo_app/domain/models/todo.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

/// Cubit for managing Todo state and operations
/// This follows the BLoC pattern for state management
class TodoCubit extends Cubit<List<Todo>> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Currently selected date for filtering todos
  DateTime selectedDate = DateTime.now();

  /// Constructor that takes a TodoRepo and initializes with empty list
  TodoCubit() : super([]) {
    // Load todos from database when cubit is initialized
    loadTodos();
  }

  /// Loads all todos from the repository
  Future<void> loadTodos() async {
    final todos = await _dbHelper.getAllTodos();
    emit(todos);
  }

  /// Loads todos for a specific date
  /// This is used to filter todos by date in the calendar view
  Future<void> loadTodosForDate(DateTime date) async {
    try {
      selectedDate = date;
      final todoList = await _dbHelper.getAllTodos();
      emit(todoList); // Emit all todos instead of filtering here
    } catch (e) {
      emit([]); // Emit empty list on error
      debugPrint('Error loading todos for date: $e');
    }
  }

  /// Adds a new todo with the given text and category
  Future<void> addTodo(String text, String category, [DateTime? date]) async {
    final todo = Todo(
      id: const Uuid().v4(),
      text: text,
      category: category,
      isCompleted: false,
      date: date ?? DateTime.now(),
      orderIndex: DateTime.now().millisecondsSinceEpoch,
    );
    await _dbHelper.insertTodo(todo);
    final todos = await _dbHelper.getAllTodos();
    emit(todos);
  }

  /// Updates an existing todo
  /// Updates the state with the modified todo
  Future<void> updateTodo(Todo todo) async {
    await _dbHelper.updateTodo(todo);
    final todos = await _dbHelper.getAllTodos();
    emit(todos);
  }

  /// Deletes a todo
  /// Updates the state by removing the deleted todo
  Future<void> deleteTodo(Todo todo) async {
    await _dbHelper.deleteTodo(todo.id);
    final todos = await _dbHelper.getAllTodos();
    emit(todos);
  }

  /// Toggles the completion status of a todo
  /// Updates the state with the toggled todo
  Future<void> toggleTodo(String id) async {
    final todo = state.firstWhere((t) => t.id == id);
    final updatedTodo = todo.toggleCompletion();
    await updateTodo(updatedTodo);
  }

  /// Updates the order of todos after reordering
  /// This is used for drag-and-drop reordering
  Future<void> updateTodoOrder(Todo todo) async {
    try {
      await _dbHelper.updateTodo(todo);
      await loadTodosForDate(selectedDate);
    } catch (e) {
      debugPrint('Error updating todo order: $e');
    }
  }

  /// Reorders a list of todos
  /// Updates all todos with their new order
  Future<void> reorderTodos(List<Todo> todos) async {
    await _dbHelper.reorderTodos(todos);
    emit(todos);
  }

  /// Get todos for a specific date
  List<Todo> getTodosForDate(DateTime date) {
    return state
        .where(
          (todo) =>
              todo.date.year == date.year &&
              todo.date.month == date.month &&
              todo.date.day == date.day,
        )
        .toList();
  }

  /// Close database connection when cubit is closed
  @override
  Future<void> close() {
    _dbHelper.close();
    return super.close();
  }
}
