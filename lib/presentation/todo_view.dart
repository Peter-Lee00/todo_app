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

        return Column(
          children: [
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
              // Base height for date header (20.0) + 3 tasks (3 * 24.0) + minimal padding (8.0)
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
    showModalBottomSheet(
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
                            .toList();

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
                                      date.isAtSameMomentAs(DateTime.now())
                                          ? 'Today'
                                          : '',
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
                                    : ReorderableListView.builder(
                                      onReorder: (oldIndex, newIndex) {
                                        setState(() {
                                          if (oldIndex < newIndex) {
                                            newIndex -= 1;
                                          }
                                          final Todo item = dayTasks.removeAt(
                                            oldIndex,
                                          );
                                          dayTasks.insert(newIndex, item);

                                          // Update the order in the database
                                          context
                                              .read<TodoCubit>()
                                              .reorderTodos(dayTasks);
                                        });
                                      },
                                      proxyDecorator: (
                                        child,
                                        index,
                                        animation,
                                      ) {
                                        return Material(
                                          elevation: 4,
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: child,
                                        );
                                      },
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      itemCount: dayTasks.length,
                                      itemBuilder: (context, index) {
                                        final todo = dayTasks[index];
                                        return _buildTodoItem(
                                          context,
                                          todo.copyWith(order: index),
                                          key: ValueKey(todo.id),
                                        );
                                      },
                                    ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: MouseRegion(
                              onEnter: (_) => _addButtonController.forward(),
                              onExit: (_) => _addButtonController.reverse(),
                              child: AnimatedBuilder(
                                animation: _addButtonController,
                                builder:
                                    (context, child) => InkWell(
                                      onTap: () async {
                                        final textController =
                                            TextEditingController();
                                        final result = await showModalBottomSheet<
                                          bool
                                        >(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          builder:
                                              (context) => StatefulBuilder(
                                                builder:
                                                    (
                                                      context,
                                                      setModalState,
                                                    ) => Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom:
                                                            MediaQuery.of(
                                                              context,
                                                            ).viewInsets.bottom,
                                                        top: 20,
                                                        left: 20,
                                                        right: 20,
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Category selector with manage button
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: BlocBuilder<
                                                                  CategoryCubit,
                                                                  List<
                                                                    TodoCategory
                                                                  >
                                                                >(
                                                                  builder: (
                                                                    context,
                                                                    categories,
                                                                  ) {
                                                                    return SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child: Row(
                                                                        children:
                                                                            categories.map((
                                                                              category,
                                                                            ) {
                                                                              final isSelected =
                                                                                  category.name ==
                                                                                  _selectedCategory;
                                                                              return Padding(
                                                                                padding: const EdgeInsets.only(
                                                                                  right:
                                                                                      8,
                                                                                ),
                                                                                child: GestureDetector(
                                                                                  onTap:
                                                                                      () => setModalState(
                                                                                        () {
                                                                                          _selectedCategory =
                                                                                              category.name;
                                                                                        },
                                                                                      ),
                                                                                  child: Container(
                                                                                    padding: const EdgeInsets.symmetric(
                                                                                      horizontal:
                                                                                          12,
                                                                                      vertical:
                                                                                          6,
                                                                                    ),
                                                                                    decoration: BoxDecoration(
                                                                                      color:
                                                                                          isSelected
                                                                                              ? category.color
                                                                                              : category.color.withOpacity(
                                                                                                0.1,
                                                                                              ),
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
                                                                                          size:
                                                                                              16,
                                                                                        ),
                                                                                        const SizedBox(
                                                                                          width:
                                                                                              4,
                                                                                        ),
                                                                                        Text(
                                                                                          category.name,
                                                                                          style: TextStyle(
                                                                                            color:
                                                                                                isSelected
                                                                                                    ? Colors.white
                                                                                                    : category.color,
                                                                                            fontSize:
                                                                                                12,
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
                                                              ),
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets.only(
                                                                      left: 8,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .grey[200],
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        20,
                                                                      ),
                                                                ),
                                                                child: Material(
                                                                  color:
                                                                      Colors
                                                                          .transparent,
                                                                  child: InkWell(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          20,
                                                                        ),
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (
                                                                                context,
                                                                              ) =>
                                                                                  const CategoryManagementScreen(),
                                                                        ),
                                                                      ).then((
                                                                        _,
                                                                      ) {
                                                                        // Refresh categories when returning from management screen
                                                                        if (context
                                                                            .mounted) {
                                                                          setModalState(
                                                                            () {},
                                                                          );
                                                                        }
                                                                      });
                                                                    },
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            6,
                                                                      ),
                                                                      child: Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.edit_outlined,
                                                                            size:
                                                                                16,
                                                                            color:
                                                                                Colors.grey[700],
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                4,
                                                                          ),
                                                                          Text(
                                                                            'Edit',
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  12,
                                                                              color:
                                                                                  Colors.grey[700],
                                                                              fontWeight:
                                                                                  FontWeight.w500,
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
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          TextField(
                                                            controller:
                                                                textController,
                                                            decoration:
                                                                const InputDecoration(
                                                                  hintText:
                                                                      'Enter task name',
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                ),
                                                            autofocus: true,
                                                          ),
                                                          const Divider(),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              TextButton.icon(
                                                                onPressed:
                                                                    () {},
                                                                icon: const Icon(
                                                                  Icons
                                                                      .calendar_today,
                                                                ),
                                                                label:
                                                                    const Text(
                                                                      'Today',
                                                                    ),
                                                              ),
                                                              TextButton.icon(
                                                                onPressed:
                                                                    () {},
                                                                icon: const Icon(
                                                                  Icons
                                                                      .notifications_none,
                                                                ),
                                                                label:
                                                                    const Text(
                                                                      'Daily',
                                                                    ),
                                                              ),
                                                              IconButton(
                                                                onPressed: () async {
                                                                  if (textController
                                                                      .text
                                                                      .isNotEmpty) {
                                                                    await context
                                                                        .read<
                                                                          TodoCubit
                                                                        >()
                                                                        .addTodo(
                                                                          textController
                                                                              .text,
                                                                          _selectedCategory,
                                                                        );
                                                                    if (context
                                                                        .mounted) {
                                                                      Navigator.pop(
                                                                        context,
                                                                        true,
                                                                      );
                                                                    }
                                                                  }
                                                                },
                                                                icon: const Icon(
                                                                  Icons.send,
                                                                  color:
                                                                      Colors
                                                                          .blue,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                              ),
                                        );

                                        if (result == true && context.mounted) {
                                          context
                                              .read<TodoCubit>()
                                              .loadTodosForDate(date);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue.withOpacity(
                                                0.8 +
                                                    _addButtonController.value *
                                                        0.2,
                                              ),
                                              Colors.blue.shade400.withOpacity(
                                                0.8 +
                                                    _addButtonController.value *
                                                        0.2,
                                              ),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius:
                                                  8 +
                                                  (_addButtonController.value *
                                                      4),
                                              offset: Offset(
                                                0,
                                                4 -
                                                    (_addButtonController
                                                            .value *
                                                        2),
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.white,
                                              size:
                                                  24 +
                                                  (_addButtonController.value *
                                                      2),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Add a Task',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    16 +
                                                    (_addButtonController
                                                            .value *
                                                        1),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
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

  Widget _buildTodoItem(BuildContext context, Todo todo, {Key? key}) {
    return Dismissible(
      key: key ?? Key(todo.id.toString()),
      background: Container(
        color: Colors.green.withOpacity(0.7),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            const Icon(Icons.check, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Complete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red.withOpacity(0.7),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mark as completed
          await context.read<TodoCubit>().toggleTodo(todo.id);
          return false;
        } else {
          // Show delete confirmation
          final bool? delete = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: const Text(
                    'Are you sure you want to delete this task?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
          );
          if (delete == true) {
            await context.read<TodoCubit>().deleteTodo(todo);
            return true;
          }
          return false;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: _getCategoryColor(todo.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _getCategoryColor(todo.category).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  todo.text,
                  style: TextStyle(
                    decoration:
                        todo.isCompleted ? TextDecoration.lineThrough : null,
                    color: todo.isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
              if (!todo.isCompleted) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(todo.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    todo.category,
                    style: TextStyle(
                      color: _getCategoryColor(todo.category),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: () => _showEditTodoDialog(context, todo),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
              ],
            ],
          ),
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

  void _showAddTodoDialog(BuildContext context) {
    final textController = TextEditingController();

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
                          hintText: 'Enter task name',
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
                              );
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
                            onPressed: () {},
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Today'),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications_none),
                            label: const Text('Daily'),
                          ),
                          IconButton(
                            onPressed: () {
                              if (textController.text.isNotEmpty) {
                                context.read<TodoCubit>().addTodo(
                                  textController.text,
                                  _selectedCategory,
                                );
                                Navigator.pop(context);
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

  void _showCategoryDialog(BuildContext context, [TodoCategory? category]) {
    final nameController = TextEditingController(text: category?.name);
    Color selectedColor = category?.color ?? Colors.blue;
    IconData selectedIcon = category?.icon ?? Icons.label;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(category == null ? 'Add Category' : 'Edit Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  StatefulBuilder(
                    builder:
                        (context, setState) => Column(
                          children: [
                            const Text('Select Color'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                                  [
                                        Colors.blue,
                                        Colors.red,
                                        Colors.green,
                                        Colors.orange,
                                        Colors.purple,
                                        Colors.teal,
                                        Colors.pink,
                                        Colors.indigo,
                                        Colors.amber,
                                        Colors.cyan,
                                        Colors.deepOrange,
                                        Colors.lightBlue,
                                      ]
                                      .map(
                                        (color) => GestureDetector(
                                          onTap:
                                              () => setState(
                                                () => selectedColor = color,
                                              ),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border:
                                                  color == selectedColor
                                                      ? Border.all(
                                                        color: Colors.black,
                                                        width: 2,
                                                      )
                                                      : null,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                            const SizedBox(height: 20),
                            const Text('Select Icon'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                                  [
                                        Icons.label,
                                        Icons.work,
                                        Icons.shopping_bag,
                                        Icons.favorite,
                                        Icons.school,
                                        Icons.sports,
                                        Icons.movie,
                                        Icons.book,
                                        Icons.home,
                                        Icons.fitness_center,
                                        Icons.music_note,
                                        Icons.brush,
                                      ]
                                      .map(
                                        (icon) => GestureDetector(
                                          onTap:
                                              () => setState(
                                                () => selectedIcon = icon,
                                              ),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color:
                                                  icon == selectedIcon
                                                      ? selectedColor
                                                          .withOpacity(0.2)
                                                      : null,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              icon,
                                              color:
                                                  icon == selectedIcon
                                                      ? selectedColor
                                                      : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    if (category == null) {
                      context.read<CategoryCubit>().addCategory(
                        nameController.text,
                        selectedColor,
                        selectedIcon,
                      );
                    } else {
                      context.read<CategoryCubit>().updateCategory(
                        category.id,
                        nameController.text,
                        selectedColor,
                        selectedIcon,
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(category == null ? 'Add' : 'Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _animateAndShowDialog(BuildContext context) async {
    final textController = TextEditingController();
    final result = await showModalBottomSheet<bool>(
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
                          hintText: 'Enter task name',
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
                              );
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
                            onPressed: () {},
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Today'),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications_none),
                            label: const Text('Daily'),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (textController.text.isNotEmpty) {
                                await context.read<TodoCubit>().addTodo(
                                  textController.text,
                                  _selectedCategory,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              }
                            },
                            icon: const Icon(Icons.send, color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
    );

    // If task was added successfully, refresh the list
    if (result == true && context.mounted) {
      context.read<TodoCubit>().loadTodosForDate(_selectedDate);
    }
  }

  void _showEditTodoDialog(BuildContext context, Todo todo) {
    final textController = TextEditingController(text: todo.text);
    // Initialize with the todo's current category
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
