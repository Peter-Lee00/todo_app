import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/domain/models/todo.dart';
import 'package:todo_app/presentation/todo_cubit.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime, List<Todo>) onShowTasks;

  const CalendarGrid({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onShowTasks,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, List<Todo>>(
      builder: (context, todos) {
        final daysInMonth =
            DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
        final firstDayOfMonth = DateTime(
          selectedDate.year,
          selectedDate.month,
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
                        selectedDate.isAfter(minDate)
                            ? () {
                              onDateSelected(
                                DateTime(
                                  selectedDate.year,
                                  selectedDate.month - 1,
                                  1,
                                ),
                              );
                            }
                            : null,
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        selectedDate.isBefore(maxDate)
                            ? () {
                              onDateSelected(
                                DateTime(
                                  selectedDate.year,
                                  selectedDate.month + 1,
                                  1,
                                ),
                              );
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
                  selectedDate.year,
                  selectedDate.month,
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
                        final isSelected = day == selectedDate.day;
                        final isToday =
                            DateTime.now().day == day &&
                            DateTime.now().month == selectedDate.month &&
                            DateTime.now().year == selectedDate.year;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              onDateSelected(date);
                              onShowTasks(date, tasks);
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

  Color _getCategoryColor(String category) {
    // This should be moved to a shared utility class
    return Colors.blue; // Default color
  }
}
