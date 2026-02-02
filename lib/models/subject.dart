import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 0)
class Subject extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  int classesPerWeek;

  @HiveField(4)
  int weeklyGoal;

  @HiveField(5)
  int totalClasses;

  @HiveField(6)
  int attendedClasses;

  @HiveField(7)
  double overallGoalPercentage;

  /// List of scheduled days (1 = Monday, 2 = Tuesday, ..., 5 = Friday)
  @HiveField(8)
  List<int> scheduledDays;

  Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.classesPerWeek,
    required this.weeklyGoal,
    this.totalClasses = 0,
    this.attendedClasses = 0,
    this.overallGoalPercentage = 75.0,
    this.scheduledDays = const [],
  });

  double get attendancePercentage {
    if (totalClasses == 0) return 0;
    return (attendedClasses / totalClasses) * 100;
  }

  bool get isGoalMet => attendancePercentage >= overallGoalPercentage;

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

  /// Check if class is scheduled for the current academic day
  /// Academic day starts at 8 AM on weekdays
  bool get hasClassToday {
    final now = DateTime.now();
    final academicDay = getAcademicDay(now);
    final dayOfWeek = academicDay.weekday;
    // Only weekdays (Mon-Fri) and must be in scheduled days
    return dayOfWeek <= 5 && scheduledDays.contains(dayOfWeek);
  }

  Subject copyWith({
    String? id,
    String? name,
    String? icon,
    int? classesPerWeek,
    int? weeklyGoal,
    int? totalClasses,
    int? attendedClasses,
    double? overallGoalPercentage,
    List<int>? scheduledDays,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      classesPerWeek: classesPerWeek ?? this.classesPerWeek,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      totalClasses: totalClasses ?? this.totalClasses,
      attendedClasses: attendedClasses ?? this.attendedClasses,
      overallGoalPercentage:
          overallGoalPercentage ?? this.overallGoalPercentage,
      scheduledDays: scheduledDays ?? this.scheduledDays,
    );
  }
}
