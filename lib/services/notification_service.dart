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

  /// Initializes the plugin, the timezone database, the channel and the
  /// device's local timezone.
  ///
  /// Must be called once before any other method.
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    // Load the timezone database and point `tz.local` at the device's zone so
    // scheduled times match the user's wall clock. If the device's IANA name
    // cannot be resolved, fall back to a fixed-offset zone instead of silently
    // staying at UTC (which would fire the reminder at the wrong local hour).
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      debugPrint('[notifications] Device timezone: ${timezoneInfo.identifier}');
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
      debugPrint('[notifications] tz.local set to: ${tz.local.name}');
    } on Exception catch (e) {
      debugPrint('[notifications] Timezone lookup failed ($e); '
          'falling back to the device UTC offset');
      _setFallbackFixedOffsetLocation();
      debugPrint('[notifications] tz.local set to fixed offset: ${tz.local.name}');
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

      // Create the channel explicitly with max importance and sound. Android
      // only applies channel settings on first creation, so this guarantees
      // fresh installs get the loud, heads-up reminder. (`playSound` is also
      // set in the details below, but the channel is what really controls it.)
      final android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
          playSound: true,
        ),
      );
      debugPrint('[notifications] Channel "$_channelId" ready (importance=max)');
    } on Exception catch (e) {
      // Notification features degrade to no-ops; the reading still works.
      debugPrint('[notifications] Plugin init failed: $e');
    }

    _initialized = true;
  }

  /// Builds a [tz.Location] with the device's current UTC offset, used when the
  /// IANA timezone name returned by the platform cannot be resolved by the
  /// `timezone` package. Keeps the wall-clock hour correct (no DST tracking,
  /// which is acceptable for a daily reminder).
  void _setFallbackFixedOffsetLocation() {
    final offset = DateTime.now().timeZoneOffset;
    tz.setLocalLocation(tz.Location(
      'Fixed offset $offset',
      [0],
      [0],
      [tz.TimeZone(offset, isDst: false, abbreviation: 'UTC$offset')],
    ));
  }

  /// Requests the Android 13+ runtime notification permission. No-op on older
  /// Android versions, where the permission is granted at install time.
  ///
  /// This is the correct v22 API (`requestNotificationsPermission`); there is
  /// no `RequestNotificationsPermissionDetails` class in this version.
  ///
  /// Returns whether notifications are allowed after the request.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return false;
    }
    final granted = await android.requestNotificationsPermission() ?? false;
    if (granted) {
      debugPrint('[notifications] Permission GRANTED');
    } else {
      debugPrint('[notifications] ⚠️ Permission DENIED — Android 13+ requires '
          'POST_NOTIFICATIONS to show any notification');
    }
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
    debugPrint(
        '[notifications] Canceled previous reminder (id=$_dailyNotificationId)');

    // Device wall clock vs. the zone `tz.local` was resolved to. If these
    // differ by hours, the timezone setup is wrong and the reminder will fire
    // at the wrong local hour.
    final deviceNow = DateTime.now();
    debugPrint('[notifications] Hora actual del dispositivo: $deviceNow '
        '(UTC offset ${deviceNow.timeZoneOffset})');
    final now = tz.TZDateTime.now(tz.local);
    debugPrint('[notifications] tz.local now: $now (${tz.local.name})');

    // First occurrence: today at [time], or tomorrow if that time already
    // passed today.
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      debugPrint('[notifications] Hora de hoy ya pasó, se programa para mañana');
      scheduled = scheduled.add(const Duration(days: 1));
    }
    debugPrint('[notifications] Hora programada para la notificación: $scheduled '
        '(${scheduled.location.name}) — UTC: ${scheduled.toUtc()}');

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
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
