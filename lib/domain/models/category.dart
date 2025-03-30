import 'package:flutter/material.dart';

class TodoCategory {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  const TodoCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  TodoCategory copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
  }) {
    return TodoCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}
