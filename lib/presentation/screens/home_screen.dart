import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/domain/models/todo.dart';
import 'package:todo_app/domain/models/category.dart';
import 'package:todo_app/presentation/todo_cubit.dart';
import 'package:todo_app/presentation/category_cubit.dart';
import 'package:todo_app/presentation/theme_cubit.dart';
import 'package:todo_app/presentation/screens/category_management_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Personal';

  @override
  void initState() {
    super.initState();
    // Load todos when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoCubit>().loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDarkMode) {
        final backgroundColor =
            isDarkMode ? Colors.grey[900] : Colors.grey[100];
        final textColor = isDarkMode ? Colors.white : Colors.grey[800];
        final boxColor = isDarkMode ? Colors.grey[800] : Colors.white;
        final iconColor = isDarkMode ? Colors.white70 : Colors.grey[600];

        return Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: backgroundColor,
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
              selectedItemColor: isDarkMode ? Colors.white : Colors.blue,
              unselectedItemColor: iconColor,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
            ),
          ),
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor:
                  isDarkMode ? Colors.grey[900] : Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  Text(
                    'Plans',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: iconColor),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: iconColor,
                  ),
                  onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: iconColor),
                  onPressed: () {
                    // TODO: Navigate to settings screen
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Friends section
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFriendCircle('You', Icons.person, true),
                          _buildFriendCircle('Friend 1', Icons.person, false),
                          _buildFriendCircle('Friend 2', Icons.person, false),
                          _buildAddFriendCircle(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Unchecked Tasks Section
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder:
                              (context) => Container(
                                decoration: BoxDecoration(
                                  color: boxColor,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Unchecked Tasks',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: iconColor,
                                            ),
                                            onPressed:
                                                () => Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      BlocBuilder<TodoCubit, List<Todo>>(
                                        builder: (context, todos) {
                                          final now = DateTime.now();
                                          final today = DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                          );
                                          final pastUncompletedTasks =
                                              todos.where((todo) {
                                                final todoDate = DateTime(
                                                  todo.date.year,
                                                  todo.date.month,
                                                  todo.date.day,
                                                );
                                                return !todo.isCompleted &&
                                                    todoDate.isBefore(today);
                                              }).toList();

                                          if (pastUncompletedTasks.isEmpty) {
                                            return Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Text(
                                                  'No uncompleted tasks from the past',
                                                  style: TextStyle(
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                pastUncompletedTasks.length,
                                            itemBuilder:
                                                (
                                                  context,
                                                  index,
                                                ) => _buildTaskTile(
                                                  pastUncompletedTasks[index],
                                                  context,
                                                  isDarkMode,
                                                ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (isDarkMode ? Colors.black : Colors.grey)
                                  .withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Unchecked Tasks',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Icon(Icons.chevron_right, color: iconColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Today's Tasks Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (isDarkMode ? Colors.black : Colors.grey)
                                .withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sat, ${DateTime.now().day}/${DateTime.now().month}',
                            style: TextStyle(color: iconColor, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () => _showAddTodoDialog(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? Colors.grey[700]
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: iconColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add a Task',
                                    style: TextStyle(
                                      color: iconColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<TodoCubit, List<Todo>>(
                            builder: (context, todos) {
                              final todayTasks =
                                  todos
                                      .where(
                                        (todo) =>
                                            todo.date.year ==
                                                DateTime.now().year &&
                                            todo.date.month ==
                                                DateTime.now().month &&
                                            todo.date.day == DateTime.now().day,
                                      )
                                      .toList();

                              if (todayTasks.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No tasks for today',
                                      style: TextStyle(color: iconColor),
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children:
                                    todayTasks
                                        .map(
                                          (todo) => _buildTaskTile(
                                            todo,
                                            context,
                                            isDarkMode,
                                          ),
                                        )
                                        .toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFriendCircle(String name, IconData icon, bool isUser) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDarkMode) {
        final backgroundColor =
            isDarkMode ? Colors.grey[850] : Colors.grey[300];
        final iconColor = isDarkMode ? Colors.white70 : Colors.grey[600];
        final textColor = isDarkMode ? Colors.white70 : Colors.grey[600];

        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: isUser ? FontWeight.w500 : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddFriendCircle() {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDarkMode) {
        final backgroundColor =
            isDarkMode ? Colors.grey[850] : Colors.grey[300];
        final iconColor = isDarkMode ? Colors.white70 : Colors.grey[600];
        final textColor = isDarkMode ? Colors.white70 : Colors.grey[600];

        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
                    width: 1,
                  ),
                ),
                child: Icon(Icons.add, color: iconColor, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                'Add Friend',
                style: TextStyle(color: textColor, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskTile(Todo todo, BuildContext context, bool isDarkMode) {
    return BlocBuilder<CategoryCubit, List<TodoCategory>>(
      builder: (context, categories) {
        final category = categories.firstWhere(
          (cat) => cat.name == todo.category,
          orElse:
              () => TodoCategory(
                id: '0',
                name: todo.category,
                color: Colors.grey,
                icon: Icons.circle,
              ),
        );

        return Dismissible(
          key: Key('todo_${todo.id}'),
          background: Container(
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(isDarkMode ? 0.3 : 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              Icons.check_circle_outline,
              color: isDarkMode ? Colors.green[300] : Colors.green,
            ),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(isDarkMode ? 0.3 : 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              Icons.delete_outline,
              color: isDarkMode ? Colors.red[300] : Colors.red,
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              await context.read<TodoCubit>().toggleTodo(todo.id);
              return false;
            } else {
              final bool? result = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor:
                        isDarkMode ? Colors.grey[850] : Colors.white,
                    title: Text(
                      'Delete Task',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to delete this task?',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'DELETE',
                          style: TextStyle(
                            color: isDarkMode ? Colors.red[300] : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
              if (result ?? false) {
                context.read<TodoCubit>().deleteTodo(todo);
              }
              return false;
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: category.color.withOpacity(isDarkMode ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: category.color.withOpacity(isDarkMode ? 0.3 : 0.2),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? category.color.withOpacity(0.8)
                              : category.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) {
                      context.read<TodoCubit>().toggleTodo(todo.id);
                    },
                    activeColor:
                        isDarkMode
                            ? category.color.withOpacity(0.8)
                            : category.color,
                  ),
                ],
              ),
              title: Row(
                children: [
                  Icon(
                    category.icon,
                    color:
                        isDarkMode
                            ? category.color.withOpacity(0.8)
                            : category.color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      todo.text,
                      style: TextStyle(
                        decoration:
                            todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        color:
                            isDarkMode
                                ? (todo.isCompleted
                                    ? Colors.grey[500]
                                    : Colors.white)
                                : (todo.isCompleted
                                    ? Colors.grey[600]
                                    : Colors.black87),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final textController = TextEditingController();
    final isDarkMode = context.read<ThemeCubit>().isDarkMode;
    DateTime selectedDate = DateTime.now();

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
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
                        decoration: InputDecoration(
                          hintText: 'Enter task name',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
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
                            icon: Icon(
                              Icons.edit,
                              color:
                                  isDarkMode
                                      ? Colors.white70
                                      : Colors.grey[700],
                            ),
                            label: Text(
                              'Manage',
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[700],
                              ),
                            ),
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
                                        category.name == _selectedCategory;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: GestureDetector(
                                        onTap:
                                            () => setModalState(() {
                                              _selectedCategory = category.name;
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
                          TextButton.icon(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.blue,
                                        onPrimary:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                        surface:
                                            isDarkMode
                                                ? Colors.grey[850]!
                                                : Colors.white,
                                        onSurface:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                      dialogBackgroundColor:
                                          isDarkMode
                                              ? Colors.grey[850]
                                              : Colors.white,
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setModalState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            icon: Icon(
                              Icons.calendar_today,
                              color:
                                  isDarkMode
                                      ? Colors.white70
                                      : Colors.grey[700],
                            ),
                            label: Text(
                              getFormattedDate(selectedDate),
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[700],
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.notifications_none,
                              color:
                                  isDarkMode
                                      ? Colors.white70
                                      : Colors.grey[700],
                            ),
                            label: Text(
                              'Daily',
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[700],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (textController.text.isNotEmpty) {
                                await _createTask(
                                  textController.text,
                                  selectedDate,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                            icon: const Icon(Icons.send, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _createTask(String text, DateTime date) async {
    if (text.isNotEmpty) {
      await context.read<TodoCubit>().addTodo(text, _selectedCategory, date);
      // Refresh the todos
      context.read<TodoCubit>().loadTodos();
    }
  }
}
