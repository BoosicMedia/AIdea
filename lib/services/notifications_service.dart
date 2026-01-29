import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    final timeZoneName = DateTime.now().timeZoneName;
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> scheduleDailySummary({
    required int todayTasksCount,
    required int tomorrowIdeasCount,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    await _plugin.cancel(1001);
    await _plugin.cancel(1002);

    if (todayTasksCount > 0) {
      final scheduledDate = _nextInstanceForHour(DateTime.now(), 8);
      await _plugin.zonedSchedule(
        1001,
        'Danas imaš $todayTasksCount taskova',
        'Provjeri kalendar za detalje.',
        scheduledDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    if (tomorrowIdeasCount > 0) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final scheduledDate = _nextInstanceForHour(tomorrow, 20);
      await _plugin.zonedSchedule(
        1002,
        'Sutra imaš $tomorrowIdeasCount ideja',
        'Pripremi se za sutrašnje obaveze.',
        scheduledDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static tz.TZDateTime _nextInstanceForHour(DateTime date, int hour) {
    final scheduled = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
    );
    final now = tz.TZDateTime.now(tz.local);
    if (scheduled.isBefore(now)) {
      return scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static NotificationDetails _notificationDetails() {
    const android = AndroidNotificationDetails(
      'calendar_reminders',
      'Calendar Reminders',
      channelDescription:
          'Reminder notifications for calendar tasks and ideas.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }
}
