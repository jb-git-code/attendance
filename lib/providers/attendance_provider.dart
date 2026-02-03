import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  final Uuid _uuid = const Uuid();

  List<Subject> _subjects = [];
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;
  String? _error;

  DateTime? _semesterStartDate;
  DateTime? _semesterEndDate;

  List<Subject> get subjects => _subjects;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get semesterStartDate => _semesterStartDate;
  DateTime? get semesterEndDate => _semesterEndDate;

  bool get isSemesterEnded {
    if (_semesterEndDate == null) return false;
    final now = DateTime.now();
    final endOfDay = DateTime(
      _semesterEndDate!.year,
      _semesterEndDate!.month,
      _semesterEndDate!.day,
      23,
      59,
      59,
    );
    return now.isAfter(endOfDay);
  }

  bool get hasSemesterDates =>
      _semesterStartDate != null && _semesterEndDate != null;

  AttendanceProvider(this._storageService) {
    loadData();
  }

  Future<void> loadData() async {
    _setLoading(true);
    try {
      _subjects = _storageService.getAllSubjects();
      _attendanceRecords = _storageService.getAllAttendanceRecords();
      _semesterStartDate = _storageService.getSemesterStartDate();
      _semesterEndDate = _storageService.getSemesterEndDate();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> setSemesterStartDate(DateTime date) async {
    await _storageService.setSemesterStartDate(date);
    _semesterStartDate = date;
    notifyListeners();
  }

  Future<void> setSemesterEndDate(DateTime date) async {
    await _storageService.setSemesterEndDate(date);
    _semesterEndDate = date;
    notifyListeners();
  }

  int getRemainingWeeks() {
    if (_semesterEndDate == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(_semesterEndDate!)) return 0;
    return (_semesterEndDate!.difference(now).inDays / 7).ceil();
  }

  int getRemainingDays() {
    if (_semesterEndDate == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(_semesterEndDate!)) return 0;
    return _semesterEndDate!.difference(now).inDays;
  }

  int calculateGapClasses(List<int> scheduledDays) {
    if (_semesterStartDate == null) return 0;
    if (scheduledDays.isEmpty) return 0;

    final now = DateTime.now();
    final academicDay = AttendanceRecord.getAcademicDay(now);

    if (academicDay.isBefore(_semesterStartDate!)) return 0;

    final semesterStartDay = DateTime(
      _semesterStartDate!.year,
      _semesterStartDate!.month,
      _semesterStartDate!.day,
    );

    int gapClasses = 0;
    DateTime current = semesterStartDay;
    final yesterday = DateTime(
      academicDay.year,
      academicDay.month,
      academicDay.day,
    );

    while (current.isBefore(yesterday)) {
      if (current.weekday <= 5 && scheduledDays.contains(current.weekday)) {
        gapClasses++;
      }
      current = current.add(const Duration(days: 1));
    }

    return gapClasses;
  }

  bool needsBackdatedAttendance() {
    if (_semesterStartDate == null) return false;
    final now = DateTime.now();
    final academicDay = AttendanceRecord.getAcademicDay(now);
    final semesterStartDay = DateTime(
      _semesterStartDate!.year,
      _semesterStartDate!.month,
      _semesterStartDate!.day,
    );
    return academicDay.isAfter(semesterStartDay);
  }

  int getDaysSinceSemesterStart() {
    if (_semesterStartDate == null) return 0;
    final now = DateTime.now();
    final academicDay = AttendanceRecord.getAcademicDay(now);
    return academicDay.difference(_semesterStartDate!).inDays;
  }

  int getRemainingClasses(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null || _semesterEndDate == null) return 0;

    final now = DateTime.now();
    if (now.isAfter(_semesterEndDate!)) return 0;

    final academicDay = AttendanceRecord.getAcademicDay(now);

    int remainingClasses = 0;
    DateTime current = DateTime(
      academicDay.year,
      academicDay.month,
      academicDay.day + 1,
    );
    final endDate = DateTime(
      _semesterEndDate!.year,
      _semesterEndDate!.month,
      _semesterEndDate!.day,
    );

    while (!current.isAfter(endDate)) {
      if (subject.scheduledDays.contains(current.weekday)) {
        remainingClasses++;
      }
      current = current.add(const Duration(days: 1));
    }

    return remainingClasses;
  }

  String getSemesterStatusMessage() {
    if (_semesterEndDate == null) {
      return 'Semester end date not set';
    }
    if (isSemesterEnded) {
      return 'Semester completed. Attendance is locked.';
    }
    final weeks = getRemainingWeeks();
    final days = getRemainingDays();
    if (weeks > 1) {
      return 'Semester ends in $weeks weeks';
    } else if (days > 1) {
      return 'Semester ends in $days days';
    } else if (days == 1) {
      return 'Semester ends tomorrow';
    } else {
      return 'Last day of semester';
    }
  }

  Future<bool> addSubject({
    required String name,
    required String icon,
    required int classesPerWeek,
    required int weeklyGoal,
    double overallGoalPercentage = 75.0,
    List<int> scheduledDays = const [],
    double? backdatedAttendancePercentage,
  }) async {
    _clearError();
    try {
      int initialTotalClasses = 0;
      int initialAttendedClasses = 0;

      if (backdatedAttendancePercentage != null && scheduledDays.isNotEmpty) {
        final gapClasses = calculateGapClasses(scheduledDays);
        if (gapClasses > 0) {
          initialTotalClasses = gapClasses;
          initialAttendedClasses =
              (gapClasses * backdatedAttendancePercentage / 100).round();
          if (initialAttendedClasses > initialTotalClasses) {
            initialAttendedClasses = initialTotalClasses;
          }
        }
      }

      final subject = Subject(
        id: _uuid.v4(),
        name: name,
        icon: icon,
        classesPerWeek: classesPerWeek,
        weeklyGoal: weeklyGoal,
        totalClasses: initialTotalClasses,
        attendedClasses: initialAttendedClasses,
        overallGoalPercentage: overallGoalPercentage,
        scheduledDays: scheduledDays,
      );
      await _storageService.addSubject(subject);
      _subjects.add(subject);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateSubject(Subject subject) async {
    _clearError();
    try {
      await _storageService.updateSubject(subject);
      final index = _subjects.indexWhere((s) => s.id == subject.id);
      if (index != -1) {
        _subjects[index] = subject;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteSubject(String id) async {
    _clearError();
    try {
      await _storageService.deleteSubject(id);
      _subjects.removeWhere((s) => s.id == id);
      _attendanceRecords.removeWhere((r) => r.subjectId == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Subject? getSubjectById(String id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> markAttendanceWithStatus({
    required String subjectId,
    required ClassStatus status,
    DateTime? date,
  }) async {
    _clearError();
    try {
      final recordDate = date ?? DateTime.now();
      final recordId = _uuid.v4();

      final record = AttendanceRecord(
        id: recordId,
        date: recordDate,
        attended: status == ClassStatus.attended,
        subjectId: subjectId,
        status: status,
        statusUpdatedAt: DateTime.now(),
      );

      await _storageService.addAttendanceRecord(record);
      _attendanceRecords.add(record);

      final subject = getSubjectById(subjectId);
      if (subject != null && status != ClassStatus.cancelled) {
        subject.totalClasses += 1;
        if (status == ClassStatus.attended) {
          subject.attendedClasses += 1;
        }
        await _storageService.updateSubject(subject);
        _subjects = _storageService.getAllSubjects();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateAttendanceStatus({
    required String recordId,
    required ClassStatus newStatus,
  }) async {
    _clearError();
    try {
      final recordIndex = _attendanceRecords.indexWhere(
        (r) => r.id == recordId,
      );
      if (recordIndex == -1) return false;

      final record = _attendanceRecords[recordIndex];

      if (!record.canEdit) {
        _setError('Cannot edit attendance after midnight');
        return false;
      }

      final oldStatus = record.status;
      final subject = getSubjectById(record.subjectId);

      if (subject != null) {
        if (oldStatus != ClassStatus.cancelled) {
          subject.totalClasses -= 1;
          if (oldStatus == ClassStatus.attended) {
            subject.attendedClasses -= 1;
          }
        }

        if (newStatus != ClassStatus.cancelled) {
          subject.totalClasses += 1;
          if (newStatus == ClassStatus.attended) {
            subject.attendedClasses += 1;
          }
        }

        await _storageService.updateSubject(subject);
      }

      final updatedRecord = record.copyWith(
        status: newStatus,
        attended: newStatus == ClassStatus.attended,
        statusUpdatedAt: DateTime.now(),
      );

      await _storageService.updateAttendanceRecord(updatedRecord);
      _attendanceRecords[recordIndex] = updatedRecord;
      _subjects = _storageService.getAllSubjects();

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  AttendanceRecord? getTodayAttendance(String subjectId) {
    final now = DateTime.now();
    final academicDay = AttendanceRecord.getAcademicDay(now);
    try {
      return _attendanceRecords.firstWhere(
        (record) =>
            record.subjectId == subjectId &&
            record.date.year == academicDay.year &&
            record.date.month == academicDay.month &&
            record.date.day == academicDay.day,
      );
    } catch (e) {
      return null;
    }
  }

  bool needsStatusUpdate(String subjectId) {
    if (isSemesterEnded) return false;

    final subject = getSubjectById(subjectId);
    if (subject == null) return false;

    if (!subject.hasClassToday) return false;

    final todayRecord = getTodayAttendance(subjectId);
    return todayRecord == null;
  }

  bool canEditTodayAttendance(String subjectId) {
    if (isSemesterEnded) return false;
    final todayRecord = getTodayAttendance(subjectId);
    if (todayRecord == null) return true;
    return todayRecord.canEdit;
  }

  Future<bool> markAttendance({
    required String subjectId,
    required bool attended,
    DateTime? date,
  }) async {
    return markAttendanceWithStatus(
      subjectId: subjectId,
      status: attended ? ClassStatus.attended : ClassStatus.missed,
      date: date,
    );
  }

  List<AttendanceRecord> getAttendanceBySubject(String subjectId) {
    return _attendanceRecords
        .where((record) => record.subjectId == subjectId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<AttendanceRecord> getWeeklyAttendance(String subjectId) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    return _attendanceRecords
        .where(
          (record) =>
              record.subjectId == subjectId &&
              record.date.isAfter(startDate.subtract(const Duration(days: 1))),
        )
        .toList();
  }

  int getWeeklyAttendedCount(String subjectId) {
    return getWeeklyAttendance(
      subjectId,
    ).where((record) => record.attended).length;
  }

  bool isWeeklyGoalMet(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return false;
    return getWeeklyAttendedCount(subjectId) >= subject.weeklyGoal;
  }

  Map<String, dynamic> getOverallStats() {
    int totalClasses = 0;
    int totalAttended = 0;

    for (var subject in _subjects) {
      totalClasses += subject.totalClasses;
      totalAttended += subject.attendedClasses;
    }

    double percentage = totalClasses > 0
        ? (totalAttended / totalClasses) * 100
        : 0;

    return {
      'totalClasses': totalClasses,
      'totalAttended': totalAttended,
      'percentage': percentage,
      'subjectCount': _subjects.length,
    };
  }

  Future<void> clearAllData() async {
    await _storageService.clearAllData();
    _subjects.clear();
    _attendanceRecords.clear();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  double getPredictedAttendanceIfAttend(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return 0;

    final totalAfter = subject.totalClasses + 1;
    final attendedAfter = subject.attendedClasses + 1;
    return (attendedAfter / totalAfter) * 100;
  }

  double getPredictedAttendanceIfMiss(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return 0;

    final totalAfter = subject.totalClasses + 1;
    final attendedAfter = subject.attendedClasses;
    return (attendedAfter / totalAfter) * 100;
  }

  bool willDropBelowThreshold(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return false;

    final predictedIfMiss = getPredictedAttendanceIfMiss(subjectId);
    return predictedIfMiss < subject.overallGoalPercentage;
  }

  String? getAttendanceWarning(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return null;

    if (subject.totalClasses == 0) return null;

    final predictedIfMiss = getPredictedAttendanceIfMiss(subjectId);
    if (predictedIfMiss < subject.overallGoalPercentage) {
      return 'Warning: Missing the next class will drop your attendance to ${predictedIfMiss.toStringAsFixed(1)}%';
    }
    return null;
  }

  int calculateSafeBunks(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return 0;

    final A = subject.attendedClasses;
    final T = subject.totalClasses;
    final P = subject.overallGoalPercentage;

    int maxBunks;

    if (hasSemesterDates) {
      final R = getRemainingClasses(subjectId);

      if (R == 0) return 0;

      final targetFraction = P / 100;
      final totalAtEnd = T + R;
      final minAttendedNeeded = (targetFraction * totalAtEnd).ceil();
      final classesStillNeedToAttend = minAttendedNeeded - A;

      if (classesStillNeedToAttend <= 0) {
        maxBunks = R;
      } else if (classesStillNeedToAttend > R) {
        maxBunks = 0;
      } else {
        maxBunks = R - classesStillNeedToAttend;
      }

      if (maxBunks < 0) maxBunks = 0;
      if (maxBunks > R) maxBunks = R;
    } else {
      if (T == 0) return 0;

      final maxBunksDouble = (100 * A) / P - T;
      maxBunks = maxBunksDouble.floor();

      if (maxBunks < 0) maxBunks = 0;
    }

    return maxBunks;
  }

  String getBunkMessage(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return 'Subject not found';

    if (isSemesterEnded) {
      return 'Semester completed. Attendance is locked.';
    }

    final A = subject.attendedClasses;
    final T = subject.totalClasses;
    final P = subject.overallGoalPercentage;
    final R = hasSemesterDates ? getRemainingClasses(subjectId) : 0;

    if (T == 0) {
      if (hasSemesterDates && R > 0) {
        final totalAtEnd = R;
        final minNeeded = ((P / 100) * totalAtEnd).ceil();
        final safeBunks = R - minNeeded;

        if (safeBunks > 0) {
          return 'You can safely miss $safeBunks of $R classes and stay above ${P.toInt()}%\n(No classes conducted yet)';
        } else {
          return 'Must attend all $R remaining classes for ${P.toInt()}%\n(No classes conducted yet)';
        }
      }
      return 'Set semester dates to see bunk allowance\n(No classes conducted yet)';
    }

    final safeBunks = calculateSafeBunks(subjectId);

    final totalAtEnd = T + R;
    final minNeeded = ((P / 100) * totalAtEnd).ceil();

    String calculationDetail;
    if (hasSemesterDates && R > 0) {
      calculationDetail =
          '(Attended: $A, Conducted: $T, Remaining: $R, Need: $minNeeded/$totalAtEnd)';
    } else {
      calculationDetail = '(Attended: $A, Total: $T, Target: ${P.toInt()}%)';
    }

    if (safeBunks == 0) {
      if (A < minNeeded) {
        final classesNeeded = minNeeded - A;
        if (R > 0) {
          if (classesNeeded > R) {
            return 'Cannot reach ${P.toInt()}% - need $classesNeeded more but only $R left!\n$calculationDetail';
          }
          return 'Must attend next $classesNeeded of $R remaining classes!\n$calculationDetail';
        }
        return 'You cannot miss any classes! Attend more to recover.\n$calculationDetail';
      }
      return 'You cannot miss any more classes to stay above ${P.toInt()}%\n$calculationDetail';
    }

    String message =
        'You can safely miss $safeBunks class${safeBunks == 1 ? '' : 'es'} and stay above ${P.toInt()}%';

    message += '\n$calculationDetail';

    return message;
  }

  int getClassesNeededToRecover(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return 0;

    final attended = subject.attendedClasses;
    var total = subject.totalClasses;
    final targetPercentage = subject.overallGoalPercentage / 100;

    if (total == 0) return 0;

    int classesNeeded = 0;
    var currentAttended = attended;

    while ((currentAttended / total) < targetPercentage) {
      classesNeeded++;
      currentAttended++;
      total++;

      if (classesNeeded > 100) break;
    }

    return classesNeeded;
  }

  String? getSemesterAwareWarning(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return null;

    if (!hasSemesterDates) return getAttendanceWarning(subjectId);
    if (isSemesterEnded) return 'Semester completed. Attendance is locked.';

    final remainingClasses = getRemainingClasses(subjectId);
    final safeBunks = calculateSafeBunks(subjectId);

    if (remainingClasses == 0) {
      return 'No more classes scheduled this semester.';
    }

    if (subject.attendancePercentage < subject.overallGoalPercentage) {
      final classesNeeded = getClassesNeededToRecover(subjectId);
      if (classesNeeded > remainingClasses) {
        return '⚠️ Cannot reach ${subject.overallGoalPercentage.toInt()}% with only $remainingClasses classes left. Need to attend $classesNeeded more.';
      }
      return 'Attend the next $classesNeeded classes to reach ${subject.overallGoalPercentage.toInt()}%. Only $remainingClasses classes left!';
    }

    if (safeBunks == 0) {
      return 'You must attend all remaining $remainingClasses classes to stay above ${subject.overallGoalPercentage.toInt()}%';
    }

    return null;
  }

  Map<String, dynamic> generateWeeklySummary() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    int totalClassesThisWeek = 0;
    int totalAttendedThisWeek = 0;
    List<String> achievedSubjects = [];
    List<String> needsAttentionSubjects = [];

    for (var subject in _subjects) {
      final weeklyRecords = _attendanceRecords.where(
        (record) =>
            record.subjectId == subject.id &&
            record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            record.status != ClassStatus.cancelled,
      );

      final attendedCount = weeklyRecords.where((r) => r.attended).length;
      final totalCount = weeklyRecords.length;

      totalClassesThisWeek += totalCount;
      totalAttendedThisWeek += attendedCount;

      if (totalCount > 0) {
        final weeklyPercentage = (attendedCount / totalCount) * 100;
        if (weeklyPercentage >= subject.overallGoalPercentage) {
          achievedSubjects.add(subject.name);
        } else {
          needsAttentionSubjects.add(subject.name);
        }
      }
    }

    String message = _generateSummaryMessage(
      totalClassesThisWeek,
      totalAttendedThisWeek,
      achievedSubjects,
      needsAttentionSubjects,
    );

    return {
      'totalClasses': totalClassesThisWeek,
      'totalAttended': totalAttendedThisWeek,
      'achievedSubjects': achievedSubjects,
      'needsAttentionSubjects': needsAttentionSubjects,
      'message': message,
      'generatedAt': now,
    };
  }

  String _generateSummaryMessage(
    int totalClasses,
    int totalAttended,
    List<String> achieved,
    List<String> needsAttention,
  ) {
    if (totalClasses == 0) {
      return 'No classes recorded this week. Start tracking your attendance! 📚';
    }

    final percentage = (totalAttended / totalClasses * 100).toStringAsFixed(0);
    StringBuffer message = StringBuffer();

    message.write(
      'This week you attended $totalAttended out of $totalClasses classes ($percentage%). ',
    );

    if (achieved.isNotEmpty) {
      if (achieved.length == 1) {
        message.write('Great job in ${achieved[0]}! 👍 ');
      } else {
        message.write('Great job in ${achieved.take(2).join(" & ")}! 👍 ');
      }
    }

    if (needsAttention.isNotEmpty) {
      if (needsAttention.length == 1) {
        message.write('${needsAttention[0]} needs attention next week. ⚠️ ');
      } else {
        message.write(
          '${needsAttention.take(2).join(" & ")} need attention. ⚠️ ',
        );
      }
    }

    if (totalAttended == totalClasses) {
      message.write('Perfect attendance! 🌟');
    } else if (totalAttended >= totalClasses * 0.8) {
      message.write('Keep going! 💪');
    } else if (totalAttended >= totalClasses * 0.6) {
      message.write('Room for improvement! 📈');
    } else {
      message.write('Let\'s do better next week! 🎯');
    }

    return message.toString();
  }
}
