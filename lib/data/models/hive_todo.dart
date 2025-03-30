import 'package:hive/hive.dart';
import 'package:todo_app/domain/models/todo.dart';

part 'hive_todo.g.dart';

/// Hive model for storing Todo objects in the local database
/// This class is used to serialize/deserialize Todo objects for storage
@HiveType(typeId: 0)
class TodoHive extends HiveObject {
  /// Unique identifier for the todo
  @HiveField(0)
  int id;

  /// The text content of the todo
  @HiveField(1)
  String text;

  /// Whether the todo is completed or not
  @HiveField(2)
  bool isCompleted;

  /// The due date of the todo
  @HiveField(3)
  DateTime date;

  /// The category of the todo
  @HiveField(4)
  String category;

  /// The order of the todo in the list
  @HiveField(5)
  int order;

  /// Creates a new TodoHive object
  TodoHive({
    required this.id,
    required this.text,
    required this.isCompleted,
    required this.date,
    this.category = 'Personal', // Default category
    this.order = 0, // Default order
  });

  /// Converts a Hive object to a domain Todo object
  /// This is used when reading from the database
  Todo toDomain() {
    return Todo(
      id: id,
      text: text,
      isCompleted: isCompleted,
      date: date,
      category: category,
      order: order,
    );
  }

  /// Converts a domain Todo object to a Hive object
  /// This is used when saving to the database
  static TodoHive fromDomain(Todo todo) {
    return TodoHive(
      id: todo.id,
      text: todo.text,
      isCompleted: todo.isCompleted,
      date: todo.date,
      category: todo.category,
      order: todo.order,
    );
  }
}
