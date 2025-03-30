/*
TO DO MODEL OBJECTS

- id
- text
- isCompleted
*/

/// Represents a Todo item in the application
/// This is the core domain model that contains all the business logic
class Todo {
  /// Unique identifier for the todo
  final int id;

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
  final int order;

  /// Creates a new Todo with the given properties
  Todo({
    required this.id,
    required this.text,
    required this.category,
    required this.date,
    this.isCompleted = false, // initially, todo is incomplete
    this.order = 0, // Default order value
  });

  /// Creates a copy of this Todo with some fields replaced
  /// This is used for immutable updates
  Todo copyWith({
    int? id,
    String? text,
    String? category,
    DateTime? date,
    bool? isCompleted,
    int? order,
  }) {
    return Todo(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }

  /// Toggles the completion status of the todo
  /// Returns a new Todo with the opposite completion status
  Todo toggleCompletion() {
    return copyWith(isCompleted: !isCompleted);
  }
}
