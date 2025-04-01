/*

TO DO VIEW: responsible for UI

- use BlocBuilder

*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/domain/models/todo.dart';
import 'package:todo_app/domain/models/category.dart';
import 'package:todo_app/presentation/category_cubit.dart';
import 'package:todo_app/presentation/todo_cubit.dart';
import 'package:todo_app/presentation/screens/category_management_screen.dart';

/// A view that displays a calendar and manages todo items
class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late PageController _pageController;
  String _selectedCategory = 'Daily';
  IconData _selectedMood = Icons.mood_outlined;
  late AnimationController _addButtonController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _pageController = PageController(initialPage: 0);
    _addButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    // Load todos when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoCubit>().loadTodos();
    });
  }

  @override
  void dispose() {
    _addButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            switch (value) {
                              case 'diary':
                                // Handle diary action
                                break;
                              case 'display':
                                // Handle display settings
                                break;
                              case 'category':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const CategoryManagementScreen(),
                                  ),
                                );
                                break;
                            }
                          },
                          itemBuilder:
                              (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'diary',
                                  child: Row(
                                    children: [
                                      Icon(Icons.book_outlined),
                                      SizedBox(width: 8),
                                      Text('Diary'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'display',
                                  child: Row(
                                    children: [
                                      Icon(Icons.view_agenda_outlined),
                                      SizedBox(width: 8),
                                      Text('Display for calendar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'category',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined),
                                      SizedBox(width: 8),
                                      Text('Edit Category'),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCalendarGrid(),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return BlocBuilder<TodoCubit, List<Todo>>(
      builder: (context, todos) {
        final daysInMonth =
            DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
        final firstDayOfMonth = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          1,
        );
        final firstWeekday = firstDayOfMonth.weekday;
        final adjustedFirstWeekday = firstWeekday == 7 ? 0 : firstWeekday;

        // Calculate date range limits (10 years from now)
        final now = DateTime.now();
        final minDate = DateTime(now.year, now.month, 1);
        final maxDate = DateTime(now.year + 10, now.month, 1);

        return Column(
          children: [
            // Month navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:
                        _selectedDate.isAfter(minDate)
                            ? () {
                              setState(() {
                                _selectedDate = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month - 1,
                                  1,
                                );
                              });
                            }
                            : null,
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        _selectedDate.isBefore(maxDate)
                            ? () {
                              setState(() {
                                _selectedDate = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month + 1,
                                  1,
                                );
                              });
                            }
                            : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Weekday headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map(
                          (day) => SizedBox(
                            width: 40,
                            child: Text(
                              day,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Calendar weeks
            ...List.generate(6, (weekIndex) {
              // Calculate the tasks for each day in this week
              final weekDays = List.generate(7, (dayIndex) {
                final index = weekIndex * 7 + dayIndex;
                final adjustedIndex = index - adjustedFirstWeekday;
                if (adjustedIndex < 0 || adjustedIndex >= daysInMonth) {
                  return null;
                }
                final day = adjustedIndex + 1;
                final date = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  day,
                );
                final dayTasks =
                    todos
                        .where(
                          (todo) =>
                              todo.date.year == date.year &&
                              todo.date.month == date.month &&
                              todo.date.day == date.day,
                        )
                        .toList();
                return {'date': date, 'tasks': dayTasks, 'day': day};
              });

              // Find the maximum number of tasks in this week
              final maxTasksInWeek = weekDays
                  .where((day) => day != null)
                  .map((day) => day!['tasks'] as List<Todo>)
                  .map((tasks) => tasks.length)
                  .fold(0, (max, count) => count > max ? count : max);

              // Calculate row height based on maximum tasks
              final baseHeight = 100.0; // Height to comfortably show 3 tasks
              final rowHeight =
                  maxTasksInWeek > 3
                      ? baseHeight + ((maxTasksInWeek - 3) * 24.0)
                      : baseHeight;

              return Container(
                height: rowHeight,
                margin: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children:
                      weekDays.map((dayData) {
                        if (dayData == null) {
                          return const Expanded(child: SizedBox());
                        }

                        final date = dayData['date'] as DateTime;
                        final tasks = dayData['tasks'] as List<Todo>;
                        final day = dayData['day'] as int;
                        final isSelected = day == _selectedDate.day;
                        final isToday =
                            DateTime.now().day == day &&
                            DateTime.now().month == _selectedDate.month &&
                            DateTime.now().year == _selectedDate.year;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedDate = date);
                              _showTasksForDate(context, date, tasks);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.blue[50]
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  // Date number
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colors.blue
                                              : Colors.transparent,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      day.toString(),
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : isToday
                                                ? Colors.blue
                                                : (date.weekday ==
                                                    DateTime.sunday)
                                                ? Colors.red
                                                : (date.weekday ==
                                                    DateTime.saturday)
                                                ? Colors.blue
                                                : Colors.black87,
                                        fontWeight:
                                            isSelected || isToday
                                                ? FontWeight.bold
                                                : null,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  // Task indicators
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children:
                                            tasks.map((task) {
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  top: 2,
                                                  left: 2,
                                                  right: 2,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 4,
                                                    ),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: _getCategoryColor(
                                                    task.category,
                                                  ).withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  task.text,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _getCategoryColor(
                                                      task.category,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            }).toList(),
                                      ),
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
            }),
          ],
        );
      },
    );
  }

  void _showTasksForDate(
    BuildContext context,
    DateTime date,
    List<Todo> tasks,
  ) {
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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (
                  context,
                  scrollController,
                ) => BlocBuilder<TodoCubit, List<Todo>>(
                  builder: (context, allTodos) {
                    final dayTasks =
                        allTodos
                            .where(
                              (todo) =>
                                  todo.date.year == date.year &&
                                  todo.date.month == date.month &&
                                  todo.date.day == date.day,
                            )
                            .toList()
                          ..sort(
                            (a, b) => a.orderIndex.compareTo(b.orderIndex),
                          );

                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
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
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(_selectedMood),
                                  onPressed: () => _showMoodSelector(context),
                                  tooltip: 'Select Mood',
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child:
                                dayTasks.isEmpty
                                    ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                    : _buildTaskList(dayTasks),
                          ),
                          Container(
                            margin: const EdgeInsets.all(16),
                            child: Material(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _showAddTodoDialog(context, date),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Add a Task',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
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
                  },
                ),
          ),
    );
  }

  Widget _buildTaskList(List<Todo> todos) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: todos.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final item = todos.removeAt(oldIndex);
        todos.insert(newIndex, item);
        // Update order indices
        for (var i = 0; i < todos.length; i++) {
          todos[i] = todos[i].copyWith(orderIndex: i);
        }
        context.read<TodoCubit>().reorderTodos(todos);
      },
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _buildTodoItem(context, todo, key: ValueKey(todo.id));
      },
    );
  }

  void _showAddTodoDialog(BuildContext context, DateTime date) {
    final textController = TextEditingController();
    bool hasNotification = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
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
                      // Task input field
                      TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: 'Enter task details...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 1,
                        autofocus: true,
                      ),
                      const SizedBox(height: 20),

                      // Category header with management button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
                              );
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Add / Edit'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Category selection
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
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          onTap:
                                              () => setState(
                                                () =>
                                                    _selectedCategory =
                                                        category.name,
                                              ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? category.color
                                                      : category.color
                                                          .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color:
                                                    isSelected
                                                        ? category.color
                                                        : Colors.transparent,
                                                width: 2,
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
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  category.name,
                                                  style: TextStyle(
                                                    color:
                                                        isSelected
                                                            ? Colors.white
                                                            : category.color,
                                                    fontSize: 14,
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
                                      ),
                                    );
                                  }).toList(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Date and notification selection
                      Row(
                        children: [
                          // Date selection
                          Expanded(
                            child: Material(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  _showDatePicker(
                                    context,
                                    date,
                                    (newDate) => setState(() => date = newDate),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        DateFormat('E, MMM d').format(date),
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey[400],
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Notification toggle
                          Material(
                            color:
                                hasNotification
                                    ? Colors.blue[100]
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap:
                                  () => setState(
                                    () => hasNotification = !hasNotification,
                                  ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  hasNotification
                                      ? Icons.notifications_active
                                      : Icons.notifications_none,
                                  color:
                                      hasNotification
                                          ? Colors.blue
                                          : Colors.grey[600],
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (textController.text.isNotEmpty) {
                                _createTask(textController.text, date);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Add Task'),
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

  Widget _buildOptionChip(
    BuildContext context, {
    IconData? icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child:
            icon != null
                ? Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 20,
                )
                : Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w500 : null,
                  ),
                ),
      ),
    );
  }

  void _showDatePicker(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDateSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              DateTime selectedDate = initialDate;
              String selectedOption = 'normal';

              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildOptionChip(
                          context,
                          label: 'Today',
                          isSelected: selectedOption == 'today',
                          onTap: () {
                            setState(() {
                              selectedOption = 'today';
                              selectedDate = DateTime.now();
                            });
                          },
                        ),
                        _buildOptionChip(
                          context,
                          label: 'Tomorrow',
                          isSelected: selectedOption == 'tomorrow',
                          onTap: () {
                            setState(() {
                              selectedOption = 'tomorrow';
                              selectedDate = DateTime.now().add(
                                const Duration(days: 1),
                              );
                            });
                          },
                        ),
                        _buildOptionChip(
                          context,
                          label: 'Next Week',
                          isSelected: selectedOption == 'nextWeek',
                          onTap: () {
                            setState(() {
                              selectedOption = 'nextWeek';
                              selectedDate = DateTime.now().add(
                                const Duration(days: 7),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      DateFormat('MMMM yyyy').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                              .map(
                                (day) => Text(
                                  day,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1,
                            ),
                        itemCount:
                            DateTime(
                              selectedDate.year,
                              selectedDate.month + 1,
                              0,
                            ).day,
                        itemBuilder: (context, index) {
                          final day = index + 1;
                          final date = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            day,
                          );
                          final isSelected = day == selectedDate.day;
                          final isToday =
                              DateTime.now().day == day &&
                              DateTime.now().month == selectedDate.month &&
                              DateTime.now().year == selectedDate.year;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDate = date;
                                selectedOption = 'normal';
                              });
                              onDateSelected(date);
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : null,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  day.toString(),
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black,
                                    fontWeight:
                                        isSelected ? FontWeight.bold : null,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
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
          color: _getCategoryColor(todo.category).withOpacity(0.1),
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
              color: _getCategoryColor(todo.category),
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

  Color _getCategoryColor(String category) {
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

  void _showEditTodoDialog(BuildContext context, Todo todo) {
    final textController = TextEditingController(text: todo.text);
    // Initialize with the todo's current category and date
    String selectedCategory = todo.category;
    DateTime selectedDate = todo.date;

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
                                // Refresh categories when returning from management screen
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
                      // Date selection
                      Material(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            _showDatePicker(
                              context,
                              selectedDate,
                              (newDate) =>
                                  setModalState(() => selectedDate = newDate),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('E, MMM d').format(selectedDate),
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
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
                                    date: selectedDate,
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

  void _showMoodSelector(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('How are you feeling today?'),
            content: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildMoodOption(Icons.sentiment_very_satisfied, 'Very Happy'),
                _buildMoodOption(Icons.sentiment_satisfied, 'Happy'),
                _buildMoodOption(Icons.sentiment_neutral, 'Neutral'),
                _buildMoodOption(Icons.sentiment_dissatisfied, 'Sad'),
                _buildMoodOption(Icons.sentiment_very_dissatisfied, 'Very Sad'),
                _buildMoodOption(Icons.sick, 'Sick'),
                _buildMoodOption(Icons.local_cafe, 'Tired'),
                _buildMoodOption(Icons.celebration, 'Celebrating'),
              ],
            ),
          ),
    );
  }

  Widget _buildMoodOption(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMood = icon);
        Navigator.pop(context);
      },
      child: Tooltip(
        message: label,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _selectedMood == icon ? Colors.blue.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 32,
            color: _selectedMood == icon ? Colors.blue : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
