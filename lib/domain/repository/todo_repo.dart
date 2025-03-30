/*
define what the app can do.
*/

import 'package:todo_app/domain/models/todo.dart';

/// Repository interface for Todo operations
/// This defines the contract that any Todo repository must implement
/// This follows the Repository pattern for data access abstraction
abstract class TodoRepo {
  /// Retrieves all todos from the storage
  /// Returns a Future<List<Todo>> to handle asynchronous operations
  Future<List<Todo>> getTodos();

  /// Adds a new todo to the storage
  /// Takes a Todo object and returns a Future<void>
  Future<void> addTodo(Todo todo);

  /// Deletes a todo from the storage
  /// Takes a Todo object and returns a Future<void>
  Future<void> deleteTodo(Todo todo);

  /// Toggles the completion status of a todo
  /// Takes the todo's ID and returns a Future<void>
  Future<void> toggleTodo(int id);

  /// Updates an existing todo in the storage
  /// Takes a Todo object and returns a Future<void>
  Future<void> updateTodo(Todo todo);
}
