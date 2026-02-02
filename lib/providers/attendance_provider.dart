import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';

/// Provider for managing subjects and attendance
class AttendanceProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  final Uuid _uuid = const Uuid();

  List<Subject> _subjects = [];
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;
  String? _error;

  // Semester dates
  DateTime? _semesterStartDate;
  DateTime? _semesterEndDate;

  List<Subject> get subjects => _subjects;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get semesterStartDate => _semesterStartDate;
  DateTime? get semesterEndDate => _semesterEndDate;

  /// Check if semester has ended
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

  /// Check if semester dates are set
  bool get hasSemesterDates =>
      _semesterStartDate != null && _semesterEndDate != null;

  AttendanceProvider(this._storageService) {
    loadData();
  }

  /// Load all data from local storage
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

  // ============ Semester Operations ============

  /// Set semester start date
  Future<void> setSemesterStartDate(DateTime date) async {
    await _storageService.setSemesterStartDate(date);
    _semesterStartDate = date;
    notifyListeners();
  }

  /// Set semester end date
  Future<void> setSemesterEndDate(DateTime date) async {
    await _storageService.setSemesterEndDate(date);
    _semesterEndDate = date;
    notifyListeners();
  }

  /// Get remaining weeks in semester
  int getRemainingWeeks() {
    if (_semesterEndDate == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(_semesterEndDate!)) return 0;
    return (_semesterEndDate!.difference(now).inDays / 7).ceil();
  }

  /// Get remaining days in semester
  int getRemainingDays() {
    if (_semesterEndDate == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(_semesterEndDate!)) return 0;
    return _semesterEndDate!.difference(now).inDays;
  }

  /// Calculate remaining classes for a subject until semester end
  int getRemainingClasses(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null || _semesterEndDate == null) return 0;

    final now = DateTime.now();
    if (now.isAfter(_semesterEndDate!)) return 0;

    // Count remaining scheduled days until semester end
    int remainingClasses = 0;
    DateTime current = DateTime(now.year, now.month, now.day);
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

  /// Get semester status message
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

  // ============ Subject Operations ============

  /// Add a new subject
  Future<bool> addSubject({
    required String name,
    required String icon,
    required int classesPerWeek,
    required int weeklyGoal,
    double overallGoalPercentage = 75.0,
    List<int> scheduledDays = const [],
  }) async {
    _clearError();
    try {
      final subject = Subject(
        id: _uuid.v4(),
        name: name,
        icon: icon,
        classesPerWeek: classesPerWeek,
        weeklyGoal: weeklyGoal,
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

  /// Update an existing subject
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

  /// Delete a subject
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

  /// Get a subject by ID
  Subject? getSubjectById(String id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============ Attendance Operations ============

  /// Mark attendance for a subject with status
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

      // Update subject counts based on status
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

  /// Update attendance status for a record
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

      // Check if we can still edit (before midnight)
      if (!record.canEdit) {
        _setError('Cannot edit attendance after midnight');
        return false;
      }

      final oldStatus = record.status;
      final subject = getSubjectById(record.subjectId);

      if (subject != null) {
        // Revert old status effects
        if (oldStatus != ClassStatus.cancelled) {
          subject.totalClasses -= 1;
          if (oldStatus == ClassStatus.attended) {
            subject.attendedClasses -= 1;
          }
        }

        // Apply new status effects
        if (newStatus != ClassStatus.cancelled) {
          subject.totalClasses += 1;
          if (newStatus == ClassStatus.attended) {
            subject.attendedClasses += 1;
          }
        }

        await _storageService.updateSubject(subject);
      }

      // Update the record
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

  /// Get today's attendance record for a subject
  AttendanceRecord? getTodayAttendance(String subjectId) {
    final now = DateTime.now();
    try {
      return _attendanceRecords.firstWhere(
        (record) =>
            record.subjectId == subjectId &&
            record.date.year == now.year &&
            record.date.month == now.month &&
            record.date.day == now.day,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if subject needs status update today
  bool needsStatusUpdate(String subjectId) {
    // Don't show update prompt if semester has ended
    if (isSemesterEnded) return false;

    final subject = getSubjectById(subjectId);
    if (subject == null) return false;

    // Check if today is a scheduled day
    if (!subject.hasClassToday) return false;

    // Check if already marked today
    final todayRecord = getTodayAttendance(subjectId);
    return todayRecord == null;
  }

  /// Check if today's attendance can still be edited
  bool canEditTodayAttendance(String subjectId) {
    if (isSemesterEnded) return false;
    final todayRecord = getTodayAttendance(subjectId);
    if (todayRecord == null) return true;
    return todayRecord.canEdit;
  }

  /// Mark attendance for a subject (legacy method)
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

  /// Get attendance records for a subject
  List<AttendanceRecord> getAttendanceBySubject(String subjectId) {
    return _attendanceRecords
        .where((record) => record.subjectId == subjectId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get weekly attendance for a subject
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

  /// Get weekly attendance count for a subject
  int getWeeklyAttendedCount(String subjectId) {
    return getWeeklyAttendance(
      subjectId,
    ).where((record) => record.attended).length;
  }

  /// Check if weekly goal is met for a subject
  bool isWeeklyGoalMet(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return false;
    return getWeeklyAttendedCount(subjectId) >= subject.weeklyGoal;
  }

  /// Get overall attendance statistics
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

  /// Clear all data (for logout)
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

  /// Force refresh UI - useful after setting semester dates
  void refresh() {
    notifyListeners();
  }

  // ============ Attendance Prediction ============

  /// Calculate predicted attendance percentage if user attends next class
  double getPredictedAttendanceIfAttend(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return 0;

    final totalAfter = subject.totalClasses + 1;
    final attendedAfter = subject.attendedClasses + 1;
    return (attendedAfter / totalAfter) * 100;
  }

  /// Calculate predicted attendance percentage if user misses next class
  double getPredictedAttendanceIfMiss(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return 0;

    final totalAfter = subject.totalClasses + 1;
    final attendedAfter = subject.attendedClasses;
    return (attendedAfter / totalAfter) * 100;
  }

  /// Check if missing next class will drop below threshold
  bool willDropBelowThreshold(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return false;

    final predictedIfMiss = getPredictedAttendanceIfMiss(subjectId);
    return predictedIfMiss < subject.overallGoalPercentage;
  }

  /// Get warning message for attendance prediction
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

  // ============ Bunk Calculator ============

  /// Calculate how many classes can be safely skipped
  ///
  /// Formula when remaining classes are known:
  ///   Max Bunks = floor(A + R - (P/100) × (T + R))
  ///
  /// Formula when no remaining classes:
  ///   Max Bunks = floor((100 × A) / P - T)
  ///
  /// Where:
  ///   A = Classes already attended
  ///   T = Total classes already conducted
  ///   P = Minimum required attendance percentage (e.g., 75)
  ///   R = Remaining classes in semester
  ///
  /// Result is clamped between 0 and R
  int calculateSafeBunks(String subjectId) {
    final subject = getSubjectById(subjectId);
    if (subject == null) return 0;

    final A = subject.attendedClasses; // Attended classes
    final T = subject.totalClasses; // Total classes conducted
    final P = subject.overallGoalPercentage; // Required percentage (e.g., 75)

    int maxBunks;

    // If semester dates are set, use the formula with remaining classes
    if (hasSemesterDates) {
      final R = getRemainingClasses(subjectId);

      // If no remaining classes, can't bunk
      if (R == 0) return 0;

      // Formula: Max Bunks = floor(A + R - (P/100) × (T + R))
      // This calculates: how many of the remaining classes can be skipped
      // while maintaining >= P% attendance at semester end
      final targetFraction = P / 100;
      final totalAtEnd = T + R;
      final minAttendedNeeded = (targetFraction * totalAtEnd).ceil();
      final classesStillNeedToAttend = minAttendedNeeded - A;

      if (classesStillNeedToAttend <= 0) {
        // Already attended enough, can skip all remaining
        maxBunks = R;
      } else if (classesStillNeedToAttend > R) {
        // Can't reach target even if attending all remaining
        maxBunks = 0;
      } else {
        // Can skip some classes
        maxBunks = R - classesStillNeedToAttend;
      }

      // Clamp to valid range
      if (maxBunks < 0) maxBunks = 0;
      if (maxBunks > R) maxBunks = R;
    } else {
      // No semester dates - need at least some classes conducted
      if (T == 0) return 0;

      // Formula: Max Bunks = floor((100 × A) / P - T)
      final maxBunksDouble = (100 * A) / P - T;
      maxBunks = maxBunksDouble.floor();

      // Clamp to minimum 0
      if (maxBunks < 0) maxBunks = 0;
    }

    return maxBunks;
  }

  /// Get bunk calculator message (with semester awareness)
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

    // If no classes conducted yet
    if (T == 0) {
      if (hasSemesterDates && R > 0) {
        // Calculate based on remaining classes only
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

    // Calculate total at semester end and minimum needed
    final totalAtEnd = T + R;
    final minNeeded = ((P / 100) * totalAtEnd).ceil();

    // Debug info
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

  /// Calculate how many classes needed to recover to target percentage
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

      // Safety limit
      if (classesNeeded > 100) break;
    }

    return classesNeeded;
  }

  /// Get semester-aware prediction warning
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

  // ============ Weekly Summary ============

  /// Generate weekly AI summary
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

    // Generate summary message
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
