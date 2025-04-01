import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/domain/models/todo.dart';
import 'package:todo_app/domain/models/category.dart';
import 'package:todo_app/presentation/category_cubit.dart';
import 'package:todo_app/presentation/todo_cubit.dart';
import 'package:todo_app/presentation/screens/category_management_screen.dart';

class TaskListView extends StatelessWidget {
  final DateTime date;
  final List<Todo> tasks;
  final IconData selectedMood;
  final Function() onMoodSelected;
  final Function() onAddTask;

  const TaskListView({
    super.key,
    required this.date,
    required this.tasks,
    required this.selectedMood,
    required this.onMoodSelected,
    required this.onAddTask,
  });

  String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      final difference = date.difference(now).inDays;
      if (difference > 0) {
        return 'D-$difference';
      }
      return '${DateFormat('E').format(date)}, ${DateFormat('dd/MM').format(date)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('E').format(date)}, ${date.day} ${DateFormat('MMM').format(date)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      getFormattedDate(date),
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(selectedMood),
                  onPressed: onMoodSelected,
                  tooltip: 'Select Mood',
                ),
              ],
            ),
          ),
          Expanded(
            child:
                tasks.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks for this day',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ReorderableListView.builder(
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final List<Todo> reorderedTasks = List.from(tasks);
                        final Todo item = reorderedTasks.removeAt(oldIndex);
                        reorderedTasks.insert(newIndex, item);

                        // Update all tasks with new order
                        context.read<TodoCubit>().reorderTodos(reorderedTasks);
                      },
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final todo = tasks[index];
                        return _buildTodoItem(
                          context,
                          todo,
                          key: ValueKey(todo.id),
                        );
                      },
                    ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: Material(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onAddTask,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(
                        'Add a Task',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(BuildContext context, Todo todo, {Key? key}) {
    return Dismissible(
      key: key ?? ValueKey(todo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.green,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showDeleteConfirmation(context, todo);
          return false;
        } else if (direction == DismissDirection.endToStart) {
          context.read<TodoCubit>().toggleTodo(todo.id);
          return false;
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: _getCategoryColor(context, todo.category).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            todo.text,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: Text(
            todo.category,
            style: TextStyle(
              color: _getCategoryColor(context, todo.category),
              fontSize: 12,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showEditOptions(context, todo),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Todo todo) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Are you sure you want to delete it?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<TodoCubit>().deleteTodo(todo);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditOptions(BuildContext context, Todo todo) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Task'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditTodoDialog(context, todo);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete Task'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, todo);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showEditTodoDialog(BuildContext context, Todo todo) {
    final textController = TextEditingController(text: todo.text);
    String selectedCategory = todo.category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: 'Edit task name',
                          border: InputBorder.none,
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const CategoryManagementScreen(),
                                ),
                              ).then((_) {
                                if (context.mounted) {
                                  setModalState(() {});
                                }
                              });
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Manage'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      BlocBuilder<CategoryCubit, List<TodoCategory>>(
                        builder: (context, categories) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  categories.map((category) {
                                    final isSelected =
                                        category.name == selectedCategory;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: GestureDetector(
                                        onTap:
                                            () => setModalState(() {
                                              selectedCategory = category.name;
                                            }),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? category.color
                                                    : category.color
                                                        .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                category.icon,
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : category.color,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                category.name,
                                                style: TextStyle(
                                                  color:
                                                      isSelected
                                                          ? Colors.white
                                                          : category.color,
                                                  fontWeight:
                                                      isSelected
                                                          ? FontWeight.bold
                                                          : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (textController.text.isNotEmpty) {
                                context.read<TodoCubit>().updateTodo(
                                  todo.copyWith(
                                    text: textController.text,
                                    category: selectedCategory,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  static Color _getCategoryColor(BuildContext context, String category) {
    final categories = context.read<CategoryCubit>().state;
    final matchingCategory = categories.firstWhere(
      (cat) => cat.name.toLowerCase() == category.toLowerCase(),
      orElse:
          () => TodoCategory(
            id: '-1',
            name: 'Default',
            color: Colors.blue,
            icon: Icons.label,
          ),
    );
    return matchingCategory.color;
  }
}
