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
    // scheduled times match the user's wall clock. See [_initTimezone].
    await _initTimezone();

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
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
          playSound: true,
        ),
      );
      debugPrint(
        '[notifications] Channel "$_channelId" ready (importance=max)',
      );
      // Mark initialized only when plugin + channel are both ready.
      // If init() threw above, _initialized stays false so it can be retried.
      _initialized = true;
    } on Exception catch (e) {
      // Notification features degrade to no-ops; the reading still works.
      debugPrint('[notifications] Plugin init failed: $e');
    }
  }

  /// Resolves the device timezone and points `tz.local` at it.
  ///
  /// The name passed to `tz.getLocation` is also forwarded to the Android
  /// plugin, which parses it with `java.time.ZoneId.of(...)`. That call only
  /// accepts valid IANA names, so the fallback MUST be a real IANA zone
  /// ('UTC') and never a synthetic name like 'Fixed offset ...' — an invalid
  /// name makes the native side throw and the reminder is silently dropped.
  Future<void> _initTimezone() async {
    tz.initializeTimeZones();
    String targetTimeZone = 'UTC'; // Safe fallback by default.

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      // v5 of flutter_timezone returns a TimezoneInfo, not a String.
      final deviceTz = timezoneInfo.identifier;
      debugPrint('[notifications] Device timezone from plugin: $deviceTz');

      // Explicit mapping of known aliases to canonical IANA names that
      // ZoneId.of() accepts (some Android devices report legacy aliases).
      if (deviceTz == 'America/Buenos_Aires') {
        targetTimeZone = 'America/Argentina/Buenos_Aires';
      } else {
        targetTimeZone = deviceTz;
      }

      tz.setLocalLocation(tz.getLocation(targetTimeZone));
      debugPrint(
        '[notifications] tz.local set successfully to: ${tz.local.name}',
      );
    } catch (e) {
      debugPrint(
        '[notifications] Timezone lookup failed for "$targetTimeZone" '
        '($e). Falling back to UTC.',
      );
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  /// Requests runtime notification permission.
  ///
  /// On Android 13+ this requests POST_NOTIFICATIONS.
  /// On iOS/macOS this requests alert, sound, and badge permissions.
  /// Returns `true` when the system granted permission.
  Future<bool> requestPermission() async {
    // Android 13+ (API 33+) requires POST_NOTIFICATIONS at runtime.
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission() ?? false;
      debugPrint(
        granted
            ? '[notifications] Permission GRANTED'
            : '[notifications] ⚠️ Permission DENIED — Android 13+ requires '
                  'POST_NOTIFICATIONS to show any notification',
      );
      return granted;
    }

    // iOS / macOS — use the Darwin implementation.
    final darwin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (darwin != null) {
      final granted =
          await darwin.requestPermissions(
            alert: true,
            sound: true,
            badge: true,
          ) ??
          false;
      debugPrint(
        granted
            ? '[notifications] iOS Permission GRANTED'
            : '[notifications] ⚠️ iOS Permission DENIED',
      );
      return granted;
    }

    // Unsupported platform or plugin not initialised — assume allowed.
    return true;
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
    // cancel({required int id}) — named argument required in flutter_local_notifications v22.
    await _plugin.cancel(id: _dailyNotificationId);
    debugPrint(
      '[notifications] Canceled previous reminder (id=$_dailyNotificationId)',
    );

    // Device wall clock vs. the zone `tz.local` was resolved to. If these
    // differ by hours, the timezone setup is wrong and the reminder will fire
    // at the wrong local hour.
    final deviceNow = DateTime.now();
    debugPrint(
      '[notifications] Hora actual del dispositivo: $deviceNow '
      '(UTC offset ${deviceNow.timeZoneOffset})',
    );
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
      debugPrint(
        '[notifications] Hora de hoy ya pasó, se programa para mañana',
      );
      scheduled = scheduled.add(const Duration(days: 1));
    }
    debugPrint(
      '[notifications] Hora programada para la notificación: $scheduled '
      '(${scheduled.location.name}) — UTC: ${scheduled.toUtc()}',
    );

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

    try {
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
    } on Exception catch (e) {
      // SCHEDULE_EXACT_ALARM may be missing on Android 12+ — degrade silently.
      debugPrint('[notifications] Failed to schedule reminder: $e');
      return false;
    }
  }
}
