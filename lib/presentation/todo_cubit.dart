/*

TO DO CUBIT - simple state management

Each cubit is a list of todos.

*/

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/domain/models/todo.dart';
import 'package:todo_app/domain/models/id_generator.dart';
import 'package:todo_app/domain/repository/todo_repo.dart';
import 'package:flutter/foundation.dart';

/// Cubit for managing Todo state and operations
/// This follows the BLoC pattern for state management
class TodoCubit extends Cubit<List<Todo>> {
  /// Repository for todo operations
  final TodoRepo todoRepo;

  /// Currently selected date for filtering todos
  DateTime selectedDate = DateTime.now();

  /// Constructor that takes a TodoRepo and initializes with empty list
  TodoCubit(this.todoRepo) : super([]) {
    // Load todos for the current date on initialization
    loadTodosForDate(DateTime.now());
  }

  /// Loads all todos from the repository
  Future<void> loadTodos() async {
    try {
      final todoList = await todoRepo.getTodos();
      emit(todoList);
    } catch (e) {
      emit([]); // Emit empty list on error
      debugPrint('Error loading todos: $e');
    }
  }

  /// Loads todos for a specific date
  /// This is used to filter todos by date in the calendar view
  Future<void> loadTodosForDate(DateTime date) async {
    try {
      selectedDate = date;
      final todoList = await todoRepo.getTodos();
      final filteredTodos =
          todoList
              .where(
                (todo) =>
                    todo.date.year == date.year &&
                    todo.date.month == date.month &&
                    todo.date.day == date.day,
              )
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order)); // Sort by order
      emit(filteredTodos);
    } catch (e) {
      emit([]); // Emit empty list on error
      debugPrint('Error loading todos for date: $e');
    }
  }

  /// Adds a new todo with the given text and category
  Future<void> addTodo(String text, String category) async {
    try {
      final newTodo = Todo(
        id: IdGenerator.nextId(),
        text: text,
        date: selectedDate,
        category: category,
      );

      await todoRepo.addTodo(newTodo);
      await loadTodosForDate(selectedDate);
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  /// Adds a new todo with order
  /// Updates the state with the new todo
  Future<void> addTodoWithOrder(Todo todo) async {
    try {
      await todoRepo.addTodo(todo);
      await loadTodosForDate(selectedDate);
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  /// Deletes a todo
  /// Updates the state by removing the deleted todo
  Future<void> deleteTodo(Todo todo) async {
    try {
      await todoRepo.deleteTodo(todo);
      await loadTodosForDate(selectedDate);
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }

  /// Toggles the completion status of a todo
  /// Updates the state with the toggled todo
  Future<void> toggleTodo(int id) async {
    try {
      await todoRepo.toggleTodo(id);
      await loadTodosForDate(selectedDate);
    } catch (e) {
      debugPrint('Error toggling todo: $e');
    }
  }

  /// Updates an existing todo
  /// Updates the state with the modified todo
  Future<void> updateTodo(Todo todo) async {
    try {
      await todoRepo.updateTodo(todo);
      await loadTodosForDate(selectedDate);
    } catch (e) {
      debugPrint('Error updating todo: $e');
    }
  }

  /// Updates the order of todos after reordering
  /// This is used for drag-and-drop reordering
  Future<void> updateTodoOrder(Todo todo) async {
    try {
      await todoRepo.updateTodo(todo);
      await loadTodosForDate(selectedDate);
    } catch (e) {
      debugPrint('Error updating todo order: $e');
    }
  }

  /// Reorders a list of todos
  /// Updates all todos with their new order
  Future<void> reorderTodos(List<Todo> todos) async {
    try {
      // Update all todos with their new order
      for (int i = 0; i < todos.length; i++) {
        final todo = todos[i].copyWith(order: i);
        await todoRepo.updateTodo(todo);
      }
      // Load the updated list
      final updatedTodos =
          todos
              .map((todo) => todo.copyWith(order: todos.indexOf(todo)))
              .toList();
      emit(updatedTodos);
    } catch (e) {
      debugPrint('Error reordering todos: $e');
    }
  }
}
