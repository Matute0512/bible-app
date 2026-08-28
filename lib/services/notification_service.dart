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
      debugPrint('[notifications] Device timezone: ${timezoneInfo.identifier}');
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
      debugPrint('[notifications] tz.local set to: ${tz.local.name}');
    } on Exception catch (e) {
      // Notifications still schedule, just at UTC until the zone resolves.
      debugPrint('[notifications] Timezone init failed, falling back to UTC: $e');
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    // A plugin failure must never prevent the app from launching.
    try {
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('[notifications] Tapped: ${response.payload}');
          onNotificationTap?.call();
        },
      );
      debugPrint('[notifications] Plugin initialized');
    } on Exception catch (e) {
      // Notification features degrade to no-ops; the reading still works.
      debugPrint('[notifications] Plugin init failed: $e');
    }

    _initialized = true;
  }

  /// Requests the Android 13+ runtime notification permission. No-op on older
  /// Android versions, where the permission is granted at install time.
  ///
  /// Returns whether notifications are allowed after the request.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return false;
    }
    final granted = await android.requestNotificationsPermission() ?? false;
    debugPrint('[notifications] Permission granted: $granted');
    return granted;
  }

  /// Cancels the previous reminder and schedules a new daily one at [time].
  ///
  /// [passageReference] (e.g. `Lucas 5`) is shown in the notification title.
  /// The notification repeats every day at the same local time thanks to
  /// [DateTimeComponents.time].
  ///
  /// Returns `true` when the schedule was accepted. The scheduled time is
  /// built from `tz.local` (the device's zone), so it matches the user's wall
  /// clock. On Android, v22 of the plugin always interprets [scheduledDate] as
  /// an absolute instant (the old `uiLocalNotificationDateInterpretation`
  /// parameter no longer exists), which is exactly what a daily local-time
  /// reminder needs.
  Future<bool> scheduleDailyNotification({
    required TimeOfDay time,
    required String passageReference,
  }) async {
    await _plugin.cancel(id: _dailyNotificationId);
    debugPrint('[notifications] Canceled previous reminder (id=$_dailyNotificationId)');

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
    debugPrint('[notifications] First fire at: $scheduled (${scheduled.location.name}, '
        'day=${scheduled.day}, time=${scheduled.hour}:${scheduled.minute.toString().padLeft(2, '0')})');

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
    debugPrint('[notifications] Daily reminder scheduled: $passageReference');
    return true;
  }
}
