import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/domain/models/category.dart';
import 'package:todo_app/presentation/category_cubit.dart';
import 'package:todo_app/presentation/screens/category_management_screen.dart';
import 'package:todo_app/presentation/todo_cubit.dart';

class TaskCreationDialog extends StatefulWidget {
  final DateTime date;
  final String selectedCategory;

  const TaskCreationDialog({
    super.key,
    required this.date,
    required this.selectedCategory,
  });

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  late TextEditingController textController;
  late String selectedCategory;
  late DateTime date;
  bool hasNotification = false;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    selectedCategory = widget.selectedCategory;
    date = widget.date;
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryManagementScreen(),
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
                        final isSelected = category.name == selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap:
                                  () => setState(
                                    () => selectedCategory = category.name,
                                  ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? category.color
                                          : category.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
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
                                            isSelected ? FontWeight.bold : null,
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
                color: hasNotification ? Colors.blue[100] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap:
                      () => setState(() => hasNotification = !hasNotification),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      hasNotification
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: hasNotification ? Colors.blue : Colors.grey[600],
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
                    context.read<TodoCubit>().addTodo(
                      textController.text,
                      selectedCategory,
                      date,
                    );
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
                      'Please enter what to do',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildOptionChip(
                            context,
                            icon: Icons.calendar_today,
                            label: '',
                            isSelected: true,
                            onTap: () {},
                          ),
                          _buildOptionChip(
                            context,
                            icon: Icons.close,
                            label: '',
                            isSelected: false,
                            onTap: () => Navigator.pop(context),
                          ),
                          _buildOptionChip(
                            context,
                            label: 'normal',
                            isSelected: selectedOption == 'normal',
                            onTap:
                                () => setState(() => selectedOption = 'normal'),
                          ),
                          _buildOptionChip(
                            context,
                            label: 'period',
                            isSelected: selectedOption == 'period',
                            onTap:
                                () => setState(() => selectedOption = 'period'),
                          ),
                          _buildOptionChip(
                            context,
                            label: 'repeat',
                            isSelected: selectedOption == 'repeat',
                            onTap:
                                () => setState(() => selectedOption = 'repeat'),
                          ),
                        ],
                      ),
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
                        itemCount: 42,
                        itemBuilder: (context, index) {
                          final firstDayOfMonth = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            1,
                          );
                          final firstWeekday = firstDayOfMonth.weekday % 7;
                          final day = index - firstWeekday + 1;
                          final date = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            day,
                          );

                          if (day < 1 ||
                              day >
                                  DateTime(
                                    selectedDate.year,
                                    selectedDate.month + 1,
                                    0,
                                  ).day) {
                            return const SizedBox();
                          }

                          final isSelected =
                              date.year == selectedDate.year &&
                              date.month == selectedDate.month &&
                              date.day == selectedDate.day;

                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedDate = date);
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
}
