import 'package:hive/hive.dart';

part 'attendance_record.g.dart';

/// Status of a class attendance
@HiveType(typeId: 2)
enum ClassStatus {
  @HiveField(0)
  attended,

  @HiveField(1)
  missed,

  @HiveField(2)
  cancelled,
}

@HiveType(typeId: 1)
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  bool attended;

  @HiveField(3)
  String subjectId;

  /// The status of the class (attended, missed, cancelled)
  @HiveField(4)
  ClassStatus status;

  /// Timestamp when the status was last updated
  @HiveField(5)
  DateTime? statusUpdatedAt;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.attended,
    required this.subjectId,
    this.status = ClassStatus.missed,
    this.statusUpdatedAt,
  });

  /// Check if the record can still be edited (before midnight of the class date)
  bool get canEdit {
    final now = DateTime.now();
    final midnight = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return now.isBefore(midnight) || now.isAtSameMomentAs(midnight);
  }

  /// Check if this record is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  AttendanceRecord copyWith({
    String? id,
    DateTime? date,
    bool? attended,
    String? subjectId,
    ClassStatus? status,
    DateTime? statusUpdatedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      attended: attended ?? this.attended,
      subjectId: subjectId ?? this.subjectId,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
    );
  }
}
