import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/domain/models/category.dart';
import 'package:todo_app/presentation/category_cubit.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<CategoryCubit, List<TodoCategory>>(
        builder: (context, categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories yet. Add one to get started!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(context, category);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, TodoCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(category.icon, color: category.color, size: 24),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showCategoryDialog(context, category),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, category),
            ),
          ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Color',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder:
                        (context, setState) => Wrap(
                          spacing: 12,
                          runSpacing: 12,
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
                                        width: 48,
                                        height: 48,
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
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Icon',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder:
                        (context, setState) => Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              [
                                    Icons.home,
                                    Icons.work,
                                    Icons.school,
                                    Icons.shopping_bag,
                                    Icons.favorite,
                                    Icons.fitness_center,
                                    Icons.restaurant,
                                    Icons.movie,
                                    Icons.sports,
                                    Icons.brush,
                                    Icons.music_note,
                                    Icons.book,
                                    Icons.computer,
                                    Icons.pets,
                                    Icons.flight,
                                    Icons.beach_access,
                                  ]
                                  .map(
                                    (icon) => GestureDetector(
                                      onTap:
                                          () => setState(
                                            () => selectedIcon = icon,
                                          ),
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color:
                                              icon == selectedIcon
                                                  ? selectedColor.withOpacity(
                                                    0.1,
                                                  )
                                                  : Colors.grey[100],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          icon,
                                          color:
                                              icon == selectedIcon
                                                  ? selectedColor
                                                  : Colors.grey,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
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
              FilledButton(
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

  void _showDeleteDialog(BuildContext context, TodoCategory category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Category'),
            content: Text(
              'Are you sure you want to delete "${category.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  context.read<CategoryCubit>().deleteCategory(category.id);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
