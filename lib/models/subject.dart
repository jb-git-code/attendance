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

  /// Check if class is scheduled for today
  bool get hasClassToday {
    final today = DateTime.now().weekday;
    return today <= 5 && scheduledDays.contains(today);
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
