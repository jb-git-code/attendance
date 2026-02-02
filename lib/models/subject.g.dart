// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 0;

  @override
  Subject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subject(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      classesPerWeek: fields[3] as int,
      weeklyGoal: fields[4] as int,
      totalClasses: fields[5] as int,
      attendedClasses: fields[6] as int,
      overallGoalPercentage: fields[7] as double,
      scheduledDays: (fields[8] as List?)?.cast<int>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.classesPerWeek)
      ..writeByte(4)
      ..write(obj.weeklyGoal)
      ..writeByte(5)
      ..write(obj.totalClasses)
      ..writeByte(6)
      ..write(obj.attendedClasses)
      ..writeByte(7)
      ..write(obj.overallGoalPercentage)
      ..writeByte(8)
      ..write(obj.scheduledDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
