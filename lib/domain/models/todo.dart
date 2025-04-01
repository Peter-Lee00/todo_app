/*
TO DO MODEL OBJECTS

- id
- text
- isCompleted
*/

import 'package:flutter/material.dart';

/// Represents a Todo item in the application
/// This is the core domain model that contains all the business logic
class Todo {
  /// Unique identifier for the todo
  final String id;

  /// The text content of the todo
  final String text;

  /// The category of the todo (e.g., Personal, Work, Shopping)
  final String category;

  /// The due date of the todo
  final DateTime date;

  /// Whether the todo is completed or not
  final bool isCompleted;

  /// The order of the todo in the list
  /// Used for drag-and-drop reordering
  final int orderIndex;

  /// Creates a new Todo with the given properties
  const Todo({
    required this.id,
    required this.text,
    required this.isCompleted,
    required this.date,
    required this.category,
    required this.orderIndex,
  });

  /// Toggles the completion status of the todo
  /// Returns a new Todo with the opposite completion status
  Todo toggleCompletion() {
    return copyWith(isCompleted: !isCompleted);
  }

  // Convert Todo to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'isCompleted': isCompleted ? 1 : 0,
      'date': date.toIso8601String(),
      'orderIndex': orderIndex,
    };
  }

  // Create Todo from Map (database record)
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      text: map['text'],
      category: map['category'],
      isCompleted: map['isCompleted'] == 1,
      date: DateTime.parse(map['date']),
      orderIndex: map['orderIndex'],
    );
  }

  /// Creates a copy of this Todo with some fields replaced
  /// This is used for immutable updates
  Todo copyWith({
    String? id,
    String? text,
    String? category,
    bool? isCompleted,
    DateTime? date,
    int? orderIndex,
  }) {
    return Todo(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
