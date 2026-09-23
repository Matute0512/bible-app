import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which translation/canon the app reads from.
enum BibleTranslation {
  /// Protestant canon (66 books), served by `spa_rvg`.
  evangelical,

  /// Catholic canon (73 books), served by `spa_blm`.
  catholic;

  /// The translation id understood by the Free Use Bible API.
  String get translationId => switch (this) {
    BibleTranslation.evangelical => 'spa_rvg',
    BibleTranslation.catholic => 'spa_blm',
  };
}

/// Persisted user preferences for the app.
///
/// Values are loaded once at startup via [load] and kept in memory while
/// running. Every setter persists immediately, so preferences survive
/// restarts without an explicit save step.
class UserPreferences {
  UserPreferences({
    this.fontSizeMultiplier = 1.0,
    this.translation = BibleTranslation.evangelical,
    this.notificationsEnabled = true,
    this.notificationHour = 8,
    this.notificationMinute = 0,
    required this.prefs,
  });

  final SharedPreferences prefs;

  static const String _fontSizeKey = 'font_size_multiplier';
  static const String _translationKey = 'translation';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationHourKey = 'notification_hour';
  static const String _notificationMinuteKey = 'notification_minute';

  /// Scales the base biblical text size (18sp) to respect the user's
  /// preference. 1.0 means the default size.
  double fontSizeMultiplier;

  /// Which canon the reading plan is built from.
  BibleTranslation translation;

  /// Master switch for the daily notification reminder.
  bool notificationsEnabled;

  /// Hour (0-23) of the local time at which the daily reminder fires.
  int notificationHour;

  /// Minute (0-59) of the local time at which the daily reminder fires.
  int notificationMinute;

  /// Convenience accessor for the [TimeOfDay] form of the reminder time.
  TimeOfDay get notificationTime =>
      TimeOfDay(hour: notificationHour, minute: notificationMinute);

  /// The translation id understood by the Free Use Bible API.
  String get translationId => translation.translationId;

  /// Reads persisted values, falling back to defaults when a key is absent.
  static Future<UserPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPreferences(
      prefs: prefs,
      fontSizeMultiplier: prefs.getDouble(_fontSizeKey) ?? 1.0,
      translation: prefs.getString(_translationKey) == 'catholic'
          ? BibleTranslation.catholic
          : BibleTranslation.evangelical,
      notificationsEnabled: prefs.getBool(_notificationsEnabledKey) ?? true,
      notificationHour: prefs.getInt(_notificationHourKey) ?? 8,
      notificationMinute: prefs.getInt(_notificationMinuteKey) ?? 0,
    );
  }

  /// Persists [fontSizeMultiplier].
  Future<void> setFontSizeMultiplier(double value) async {
    fontSizeMultiplier = value;
    await prefs.setDouble(_fontSizeKey, value);
  }

  /// Persists [translation].
  Future<void> setTranslation(BibleTranslation value) async {
    translation = value;
    await prefs.setString(
      _translationKey,
      value == BibleTranslation.catholic ? 'catholic' : 'evangelical',
    );
  }

  /// Persists the notification enablement switch.
  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  /// Persists the notification time.
  Future<void> setNotificationTime(TimeOfDay value) async {
    notificationHour = value.hour;
    notificationMinute = value.minute;
    await prefs.setInt(_notificationHourKey, value.hour);
    await prefs.setInt(_notificationMinuteKey, value.minute);
  }
}
