import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Wraps [FlutterLocalNotificationsPlugin] and the `timezone` package to
/// schedule the daily reading reminder.
class NotificationService {
  NotificationService({this.onNotificationTap});

  /// Invoked when the user taps a notification. Lets the app navigate back to
  /// the Home screen from anywhere.
  final VoidCallback? onNotificationTap;

  /// Notification id of the daily reading reminder.
  static const int _dailyNotificationId = 1000;

  /// Android notification channel for daily reminders.
  static const String _channelId = 'daily_reading';
  static const String _channelName = 'Lectura diaria';
  static const String _channelDescription =
      'Recordatorio diario del pasaje bíblico';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initializes the plugin, the timezone database and the device's local
  /// timezone.
  ///
  /// Must be called once before any other method.
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    // Load the timezone database and point `tz.local` at the device's zone so
    // scheduled times match the user's wall clock. Failing gracefully keeps
    // `tz.local` at UTC instead of crashing app startup.
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } on Exception {
      // Notifications still schedule, just at UTC until the zone resolves.
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    // A plugin failure must never prevent the app from launching.
    try {
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (_) => onNotificationTap?.call(),
      );
    } on Exception {
      // Notification features degrade to no-ops; the reading still works.
    }

    _initialized = true;
  }

  /// Requests the Android 13+ runtime notification permission. No-op on older
  /// Android versions, where the permission is granted at install time.
  Future<void> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  /// Cancels the previous reminder and schedules a new daily one at [time].
  ///
  /// [passageReference] (e.g. `Lucas 5`) is shown in the notification title.
  /// The notification repeats every day at the same local time thanks to
  /// [DateTimeComponents.time].
  Future<void> scheduleDailyNotification({
    required TimeOfDay time,
    required String passageReference,
  }) async {
    await _plugin.cancel(id: _dailyNotificationId);

    // First occurrence: today at [time], or tomorrow if that time already
    // passed today.
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      id: _dailyNotificationId,
      title: 'Tu lectura diaria: $passageReference',
      body: 'Toca para leer el pasaje de hoy',
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
