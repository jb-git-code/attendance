part of 'attendance_record.dart';

class AttendanceRecordAdapter extends TypeAdapter<AttendanceRecord> {
  @override
  final int typeId = 1;

  @override
  AttendanceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceRecord(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      attended: fields[2] as bool,
      subjectId: fields[3] as String,
      status:
          (fields[4] as ClassStatus?) ??
          (fields[2] as bool ? ClassStatus.attended : ClassStatus.missed),
      statusUpdatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.attended)
      ..writeByte(3)
      ..write(obj.subjectId)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.statusUpdatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClassStatusAdapter extends TypeAdapter<ClassStatus> {
  @override
  final int typeId = 2;

  @override
  ClassStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ClassStatus.attended;
      case 1:
        return ClassStatus.missed;
      case 2:
        return ClassStatus.cancelled;
      default:
        return ClassStatus.attended;
    }
  }

  @override
  void write(BinaryWriter writer, ClassStatus obj) {
    switch (obj) {
      case ClassStatus.attended:
        writer.writeByte(0);
        break;
      case ClassStatus.missed:
        writer.writeByte(1);
        break;
      case ClassStatus.cancelled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
