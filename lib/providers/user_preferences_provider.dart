import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_preferences.dart';
import 'reading_plan_provider.dart';
import 'shared_preferences_provider.dart';

class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  @override
  Future<UserPreferences> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);

    // We can read directly using the logic from UserPreferences.load,
    // or adapt it. For now, since UserPreferences constructor takes prefs:
    return UserPreferences(
      prefs: prefs,
      fontSizeMultiplier: prefs.getDouble('font_size_multiplier') ?? 1.0,
      translation: prefs.getString('translation') == 'catholic'
          ? BibleTranslation.catholic
          : BibleTranslation.evangelical,
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      notificationHour: prefs.getInt('notification_hour') ?? 8,
      notificationMinute: prefs.getInt('notification_minute') ?? 0,
    );
  }

  Future<void> setFontSizeMultiplier(double value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setDouble('font_size_multiplier', value);
    state = AsyncData(state.requireValue..fontSizeMultiplier = value);
  }

  Future<void> setTranslation(BibleTranslation value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(
      'translation',
      value == BibleTranslation.catholic ? 'catholic' : 'evangelical',
    );
    state = AsyncData(state.requireValue..translation = value);
    // Invalidate the reading plan when translation changes.
    ref.invalidate(readingPlanProvider);
    ref.invalidate(dailyReadingProvider);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('notifications_enabled', value);
    state = AsyncData(state.requireValue..notificationsEnabled = value);
  }

  Future<void> setNotificationTime(TimeOfDay value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setInt('notification_hour', value.hour);
    await prefs.setInt('notification_minute', value.minute);
    state = AsyncData(
      state.requireValue
        ..notificationHour = value.hour
        ..notificationMinute = value.minute,
    );
  }
}

final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences>(
      UserPreferencesNotifier.new,
    );
