import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:bible_app/models/bible_chapter.dart';
import 'package:bible_app/models/bible_book.dart';
import 'package:bible_app/services/bible_api_service.dart';
import 'package:bible_app/services/notification_service.dart';
import 'package:bible_app/providers/app_providers.dart';

void main() {
  group('UserPreferencesProvider', () {
    test('initializes with default values if no prefs exist', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for shared preferences to be ready
      await container.read(sharedPreferencesProvider.future);

      final prefs = await container.read(userPreferencesProvider.future);
      expect(prefs.fontSizeMultiplier, 1.0);
      expect(prefs.notificationsEnabled, true);
    });

    test('updates font size and persists', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);

      await container
          .read(userPreferencesProvider.notifier)
          .setFontSizeMultiplier(1.5);

      final prefs = await container.read(userPreferencesProvider.future);
      expect(prefs.fontSizeMultiplier, 1.5);

      // Check if it was persisted
      final sp = await SharedPreferences.getInstance();
      expect(sp.getDouble('font_size_multiplier'), 1.5);
    });

    test('updates notification time and persists', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);

      const newTime = TimeOfDay(hour: 7, minute: 30);
      await container
          .read(userPreferencesProvider.notifier)
          .setNotificationTime(newTime);

      final prefs = await container.read(userPreferencesProvider.future);
      expect(prefs.notificationTime.hour, 7);
      expect(prefs.notificationTime.minute, 30);

      // Check if it was persisted
      final sp = await SharedPreferences.getInstance();
      expect(sp.getInt('notification_hour'), 7);
      expect(sp.getInt('notification_minute'), 30);
    });
  });

  group('DailyReadingNotifier', () {
    test('loads initial state correctly', () async {
      SharedPreferences.setMockInitialValues({
        'installation_date': DateTime.now().toIso8601String(),
      });

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(MockBibleApiService()),
          notificationServiceProvider.overrideWithValue(
            MockNotificationService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);

      // Initially loading
      final initial = container.read(dailyReadingProvider);
      expect(initial.isLoading, true);

      // Wait for load
      final state = await container.read(dailyReadingProvider.future);
      expect(state, isA<Loaded>());

      final loadedState = state as Loaded;
      expect(loadedState.chapter.reference, 'Génesis 1');
      expect(loadedState.currentIndex, 0);
    });

    test('goToChapter navigation works', () async {
      SharedPreferences.setMockInitialValues({
        'installation_date': DateTime.now().toIso8601String(),
      });

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(MockBibleApiService()),
          notificationServiceProvider.overrideWithValue(
            MockNotificationService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);
      await container.read(dailyReadingProvider.future);

      // Navigate forward
      await container.read(dailyReadingProvider.notifier).goToChapter(1);
      final nextState = container.read(dailyReadingProvider).requireValue;
      expect(nextState, isA<Loaded>());

      final loadedState = nextState as Loaded;
      expect(loadedState.currentIndex, 1);
    });
  });
}

class MockBibleApiService implements BibleApiService {
  @override
  Future<List<BibleBook>> fetchBooks(String translationId) async {
    return [BibleBook(id: 'GEN', name: 'Génesis', order: 1, chapterCount: 50)];
  }

  @override
  Future<BibleChapter> fetchChapter({
    required String translationId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) async {
    return BibleChapter(
      bookId: bookId,
      bookName: bookName,
      chapterNumber: chapterNumber,
      verses: [],
    );
  }
}

class MockNotificationService implements NotificationService {
  @override
  VoidCallback? get onNotificationTap => null;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async {
    return true;
  }

  @override
  Future<bool> scheduleDailyNotification({
    required TimeOfDay time,
    required String passageReference,
  }) async {
    return true;
  }
}
