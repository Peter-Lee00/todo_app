// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoHiveAdapter extends TypeAdapter<TodoHive> {
  @override
  final int typeId = 0;

  @override
  TodoHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoHive(
      id: fields[0] as int,
      text: fields[1] as String,
      isCompleted: fields[2] as bool,
      date: fields[3] as DateTime,
      category: fields[4] as String,
      order: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TodoHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
