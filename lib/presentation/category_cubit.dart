import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/domain/models/category.dart';

class CategoryCubit extends Cubit<List<TodoCategory>> {
  CategoryCubit() : super(_defaultCategories);

  static final List<TodoCategory> _defaultCategories = [
    TodoCategory(
      id: 'daily',
      name: 'Daily',
      color: Colors.blue,
      icon: Icons.calendar_today,
    ),
    TodoCategory(
      id: 'work',
      name: 'Work',
      color: Colors.purple,
      icon: Icons.work,
    ),
    TodoCategory(
      id: 'personal',
      name: 'Personal',
      color: Colors.orange,
      icon: Icons.person,
    ),
    TodoCategory(
      id: 'shopping',
      name: 'Shopping',
      color: Colors.green,
      icon: Icons.shopping_bag,
    ),
    TodoCategory(
      id: 'health',
      name: 'Health',
      color: Colors.red,
      icon: Icons.favorite,
    ),
  ];

  void addCategory(String name, Color color, IconData icon) {
    final newCategory = TodoCategory(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      color: color,
      icon: icon,
    );

    emit([...state, newCategory]);
  }

  void updateCategory(String id, String name, Color color, IconData icon) {
    final updatedCategories =
        state.map((category) {
          if (category.id == id) {
            return category.copyWith(name: name, color: color, icon: icon);
          }
          return category;
        }).toList();

    emit(updatedCategories);
  }

  void deleteCategory(String id) {
    final updatedCategories =
        state.where((category) => category.id != id).toList();
    emit(updatedCategories);
  }

  TodoCategory? getCategoryById(String id) {
    try {
      return state.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}
