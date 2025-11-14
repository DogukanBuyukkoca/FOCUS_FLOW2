import 'package:hive/hive.dart';
import 'models.dart';

// Goal Adapter
class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 0;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      isCompleted: fields[3] as bool,
      createdAt: fields[4] as DateTime,
      completedAt: fields[5] as DateTime?,
      dueDate: fields[6] as DateTime?,
      linkedSessions: fields[7] as int?,
      category: GoalCategory.values[fields[8] as int],
      priority: GoalPriority.values[fields[9] as int],
      subTasks: (fields[10] as List).cast<SubTask>(),
      repeatType: RepeatType.values[fields[11] as int],
      tags: (fields[12] as List).cast<String>(),
      notes: fields[13] as String?,
      streak: fields[14] as int,
      progress: fields[15] as double,
      reminderTime: fields[16] as DateTime?,
      completionHistory: (fields[17] as List).cast<DateTime>(),
      estimatedMinutes: fields[18] as int,
      actualMinutes: fields[19] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.linkedSessions)
      ..writeByte(8)
      ..write(obj.category.index)
      ..writeByte(9)
      ..write(obj.priority.index)
      ..writeByte(10)
      ..write(obj.subTasks)
      ..writeByte(11)
      ..write(obj.repeatType.index)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.streak)
      ..writeByte(15)
      ..write(obj.progress)
      ..writeByte(16)
      ..write(obj.reminderTime)
      ..writeByte(17)
      ..write(obj.completionHistory)
      ..writeByte(18)
      ..write(obj.estimatedMinutes)
      ..writeByte(19)
      ..write(obj.actualMinutes);
  }
}

// SubTask Adapter
class SubTaskAdapter extends TypeAdapter<SubTask> {
  @override
  final int typeId = 1;

  @override
  SubTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubTask(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SubTask obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted);
  }
}