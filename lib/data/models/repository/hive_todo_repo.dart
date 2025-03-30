import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/data/models/hive_todo.dart';
import 'package:todo_app/domain/models/todo.dart';
import 'package:todo_app/domain/repository/todo_repo.dart';

/// HiveTodoRepo implements TodoRepo interface to provide local storage
/// functionality using Hive database
class HiveTodoRepo implements TodoRepo {
  // The Hive box that stores our todos
  final Box<TodoHive> _todoBox;

  HiveTodoRepo(this._todoBox);

  @override
  Future<List<Todo>> getTodos() async {
    try {
      // Convert Hive objects to domain objects and sort by order
      return _todoBox.values.map((todo) => todo.toDomain()).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      debugPrint('Error getting todos: $e');
      // Return empty list on error to prevent app crashes
      return [];
    }
  }

  @override
  Future<void> addTodo(Todo todo) async {
    try {
      // Find the highest order number among existing todos
      final currentTodos = await getTodos();
      final highestOrder =
          currentTodos.isEmpty
              ? -1 // If no todos exist, start from -1
              : currentTodos
                  .map((t) => t.order)
                  .reduce((max, order) => order > max ? order : max);

      // Create new todo with next order number
      final todoWithOrder = todo.copyWith(order: highestOrder + 1);
      await _todoBox.put(todo.id, TodoHive.fromDomain(todoWithOrder));

      // Perform box compaction if we have too many items
      // This helps maintain database performance
      if (_todoBox.length > 100) {
        await _todoBox.compact();
      }
    } catch (e) {
      debugPrint('Error adding todo: $e');
      // Rethrow to let UI handle the error
      rethrow;
    }
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    try {
      // Remove the todo from the box
      await _todoBox.delete(todo.id);

      // Reorder remaining todos to maintain consecutive ordering
      // This prevents gaps in the order numbers
      final remainingTodos = await getTodos();
      for (var i = 0; i < remainingTodos.length; i++) {
        final currentTodo = remainingTodos[i];
        if (currentTodo.order > todo.order) {
          // Decrease order of all todos that came after the deleted one
          await updateTodo(currentTodo.copyWith(order: currentTodo.order - 1));
        }
      }
    } catch (e) {
      debugPrint('Error deleting todo: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleTodo(int id) async {
    try {
      // Get the todo from the box
      final todo = _todoBox.get(id);
      if (todo != null) {
        // Toggle completion status and save
        final updatedTodo = todo.toDomain().toggleCompletion();
        await _todoBox.put(id, TodoHive.fromDomain(updatedTodo));
      }
    } catch (e) {
      debugPrint('Error toggling todo: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    try {
      // Update the todo in the box
      // This preserves all fields including order
      await _todoBox.put(todo.id, TodoHive.fromDomain(todo));
    } catch (e) {
      debugPrint('Error updating todo: $e');
      rethrow;
    }
  }

  /// Ensures all todos are properly saved to disk
  /// This is useful before app shutdown or when forcing a save
  Future<void> backupTodos() async {
    try {
      // Flush writes all pending changes to disk
      await _todoBox.flush();
    } catch (e) {
      debugPrint('Error backing up todos: $e');
    }
  }

  /// Attempts to restore todos from disk and clean up storage
  /// This can help recover from corruption or optimize storage
  Future<void> restoreFromBackup() async {
    try {
      // Compact removes unused space and can help with corruption
      await _todoBox.compact();
    } catch (e) {
      debugPrint('Error restoring todos: $e');
    }
  }
}
