import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Service for handling local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int dailyReminderId = 1;
  static const int weeklyAlertId = 2;
  static const int weeklySummaryId = 10;

  /// Initialize the notification service
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions for Android 13+
    await _requestPermissions();
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
      // Request exact alarm permission for Android 12+
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (e) {
      // Ignore permission errors - notifications will still work, just not exact scheduling
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'attendance_channel',
      'Attendance Reminders',
      channelDescription: 'Reminders for attendance tracking',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  /// Schedule daily reminder (Monday to Friday at 8 AM)
  Future<void> scheduleDailyReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Daily attendance reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule for Monday through Friday at 8 PM
    for (int day = DateTime.monday; day <= DateTime.friday; day++) {
      await _notifications.zonedSchedule(
        dailyReminderId + day,
        'Mark Your Attendance',
        "Have you marked today's attendance? Tap to update now!",
        _nextInstanceOfWeekdayTime(day, 20, 0),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Schedule Saturday morning alert for missed goals
  Future<void> scheduleWeeklyAlert() async {
    const androidDetails = AndroidNotificationDetails(
      'weekly_alert_channel',
      'Weekly Alerts',
      channelDescription: 'Weekly attendance goal alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      weeklyAlertId,
      'Weekly Attendance Review',
      'Check if you met your attendance goals this week!',
      _nextInstanceOfWeekdayTime(DateTime.saturday, 9, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Get the next instance of a specific weekday and time
  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Schedule all default notifications
  Future<void> scheduleDefaultNotifications() async {
    try {
      await scheduleDailyReminder();
      await scheduleWeeklyAlert();
      await scheduleWeeklySummary();
    } catch (e) {
      // Scheduling failed - likely due to missing exact alarm permission
      // The app will still work, just without scheduled notifications
    }
  }

  /// Schedule Sunday weekly summary notification
  Future<void> scheduleWeeklySummary() async {
    const androidDetails = AndroidNotificationDetails(
      'weekly_summary_channel',
      'Weekly Summary',
      channelDescription: 'Weekly AI attendance summary',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      weeklySummaryId,
      '📊 Weekly Attendance Summary',
      'Check out how you did this week! Tap to see your personalized summary.',
      _nextInstanceOfWeekdayTime(DateTime.sunday, 10, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Show weekly summary notification with custom message
  Future<void> showWeeklySummaryNotification(String summaryMessage) async {
    final androidDetails = AndroidNotificationDetails(
      'weekly_summary_channel',
      'Weekly Summary',
      channelDescription: 'Weekly AI attendance summary',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(summaryMessage),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      weeklySummaryId + 1,
      '📊 Weekly Attendance Summary',
      summaryMessage,
      details,
    );
  }
}
