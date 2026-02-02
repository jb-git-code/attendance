import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// Service for managing local storage using Hive
class LocalStorageService {
  static const String subjectsBoxName = 'subjects';
  static const String attendanceBoxName = 'attendance';
  static const String settingsBoxName = 'settings';

  late Box<Subject> _subjectsBox;
  late Box<AttendanceRecord> _attendanceBox;
  late Box<dynamic> _settingsBox;

  /// Initialize Hive and open all required boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SubjectAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AttendanceRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ClassStatusAdapter());
    }

    // Open boxes
    _subjectsBox = await Hive.openBox<Subject>(subjectsBoxName);
    _attendanceBox = await Hive.openBox<AttendanceRecord>(attendanceBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
  }

  // ============ Subject Operations ============

  /// Get all subjects
  List<Subject> getAllSubjects() {
    return _subjectsBox.values.toList();
  }

  /// Get a subject by ID
  Subject? getSubjectById(String id) {
    try {
      return _subjectsBox.values.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new subject
  Future<void> addSubject(Subject subject) async {
    await _subjectsBox.put(subject.id, subject);
  }

  /// Update an existing subject
  Future<void> updateSubject(Subject subject) async {
    await _subjectsBox.put(subject.id, subject);
  }

  /// Delete a subject and its attendance records
  Future<void> deleteSubject(String id) async {
    await _subjectsBox.delete(id);
    // Also delete all attendance records for this subject
    final recordsToDelete = _attendanceBox.values
        .where((record) => record.subjectId == id)
        .toList();
    for (var record in recordsToDelete) {
      await record.delete();
    }
  }

  // ============ Attendance Operations ============

  /// Get all attendance records
  List<AttendanceRecord> getAllAttendanceRecords() {
    return _attendanceBox.values.toList();
  }

  /// Get attendance records for a specific subject
  List<AttendanceRecord> getAttendanceBySubject(String subjectId) {
    return _attendanceBox.values
        .where((record) => record.subjectId == subjectId)
        .toList();
  }

  /// Get attendance records for a subject within a date range
  List<AttendanceRecord> getAttendanceByDateRange(
    String subjectId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _attendanceBox.values
        .where(
          (record) =>
              record.subjectId == subjectId &&
              record.date.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              record.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Get weekly attendance for a subject
  List<AttendanceRecord> getWeeklyAttendance(String subjectId) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return getAttendanceByDateRange(subjectId, startOfWeek, endOfWeek);
  }

  /// Add an attendance record
  Future<void> addAttendanceRecord(AttendanceRecord record) async {
    await _attendanceBox.put(record.id, record);
  }

  /// Update an attendance record
  Future<void> updateAttendanceRecord(AttendanceRecord record) async {
    await _attendanceBox.put(record.id, record);
  }

  /// Delete an attendance record
  Future<void> deleteAttendanceRecord(String id) async {
    await _attendanceBox.delete(id);
  }

  /// Mark attendance for a subject
  Future<void> markAttendance({
    required String subjectId,
    required bool attended,
    required String recordId,
    DateTime? date,
  }) async {
    final record = AttendanceRecord(
      id: recordId,
      date: date ?? DateTime.now(),
      attended: attended,
      subjectId: subjectId,
    );
    await addAttendanceRecord(record);

    // Update subject's total and attended classes
    final subject = getSubjectById(subjectId);
    if (subject != null) {
      subject.totalClasses += 1;
      if (attended) {
        subject.attendedClasses += 1;
      }
      await updateSubject(subject);
    }
  }

  // ============ Settings Operations ============

  /// Save a setting
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get a setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  // ============ Semester Date Operations ============

  static const String semesterStartDateKey = 'semester_start_date';
  static const String semesterEndDateKey = 'semester_end_date';

  /// Save semester start date
  Future<void> setSemesterStartDate(DateTime date) async {
    await _settingsBox.put(semesterStartDateKey, date.millisecondsSinceEpoch);
  }

  /// Get semester start date
  DateTime? getSemesterStartDate() {
    final millis = _settingsBox.get(semesterStartDateKey) as int?;
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Save semester end date
  Future<void> setSemesterEndDate(DateTime date) async {
    await _settingsBox.put(semesterEndDateKey, date.millisecondsSinceEpoch);
  }

  /// Get semester end date
  DateTime? getSemesterEndDate() {
    final millis = _settingsBox.get(semesterEndDateKey) as int?;
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Clear all data (for logout)
  Future<void> clearAllData() async {
    await _subjectsBox.clear();
    await _attendanceBox.clear();
    await _settingsBox.clear();
  }
}
