import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/domain/models/category.dart';
import 'package:todo_app/presentation/category_cubit.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showCategoryDialog(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<CategoryCubit, List<TodoCategory>>(
                builder: (context, categories) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryItem(context, category);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, TodoCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(category.icon, color: category.color),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
            content: Column(
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
                                                    ? selectedColor.withOpacity(
                                                      0.2,
                                                    )
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
              TextButton(
                onPressed: () {
                  context.read<CategoryCubit>().deleteCategory(category.id);
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
}
