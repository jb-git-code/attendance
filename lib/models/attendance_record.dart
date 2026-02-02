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

  /// The hour when a new attendance cycle starts (8 AM)
  static const int cycleStartHour = 8;

  /// Get the academic day for a given DateTime
  /// Before 8 AM, it's still considered the previous day
  static DateTime getAcademicDay(DateTime dateTime) {
    if (dateTime.hour < cycleStartHour) {
      // Before 8 AM, consider it the previous day
      return DateTime(dateTime.year, dateTime.month, dateTime.day - 1);
    }
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Check if the record can still be edited (before 8 AM of the next day)
  bool get canEdit {
    final now = DateTime.now();
    // Editing allowed until 8 AM the next day
    final nextDay8AM = DateTime(
      date.year,
      date.month,
      date.day + 1,
      cycleStartHour,
    );
    return now.isBefore(nextDay8AM);
  }

  /// Check if this record is for the current academic day
  /// Academic day starts at 8 AM and ends at 8 AM the next day
  bool get isToday {
    final now = DateTime.now();
    final currentAcademicDay = getAcademicDay(now);
    final recordDay = DateTime(date.year, date.month, date.day);
    return currentAcademicDay.year == recordDay.year &&
        currentAcademicDay.month == recordDay.month &&
        currentAcademicDay.day == recordDay.day;
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
