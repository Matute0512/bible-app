import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible_app/models/bible_book.dart';
import 'package:bible_app/models/bible_chapter.dart';
import 'package:bible_app/providers/app_providers.dart';
import 'package:bible_app/services/bible_api_service.dart';
import 'package:bible_app/services/notification_service.dart';

// ---------------------------------------------------------------------------
// Helper: build a ProviderContainer with mocked API + Notifications + Prefs
// ---------------------------------------------------------------------------

/// [FIX-TEST-01] Both DailyReadingNotifier tests used the wrong SharedPreferences
/// key `'installation_date'` instead of the real key `'installation_date_utc'`
/// defined in ReadingPlanService. This caused the mock to NOT register an
/// installation date, so the notifier called `getInstallationDate()`, which
/// wrote a NEW date and always returned elapsed=0. The tests happened to pass
/// only because index 0 is the expected value — but the bug masked test intent.
ProviderContainer _makeContainer() {
  return ProviderContainer(
    overrides: [
      apiServiceProvider.overrideWithValue(MockBibleApiService()),
      notificationServiceProvider.overrideWithValue(MockNotificationService()),
    ],
  );
}

void main() {
  // -------------------------------------------------------------------------
  // UserPreferencesProvider
  // -------------------------------------------------------------------------
  group('UserPreferencesProvider', () {
    test('initializes with default values if no prefs exist', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);

      final prefs = await container.read(userPreferencesProvider.future);
      expect(prefs.fontSizeMultiplier, 1.0);
      expect(prefs.notificationsEnabled, true);
    });

    test(
      'setFontSizeMultiplier updates state and persists to SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({});

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(sharedPreferencesProvider.future);
        await container
            .read(userPreferencesProvider.notifier)
            .setFontSizeMultiplier(1.5);

        final prefs = await container.read(userPreferencesProvider.future);
        expect(prefs.fontSizeMultiplier, 1.5);

        final sp = await SharedPreferences.getInstance();
        expect(sp.getDouble('font_size_multiplier'), 1.5);
      },
    );

    test(
      'setNotificationTime updates state and persists to SharedPreferences',
      () async {
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

        final sp = await SharedPreferences.getInstance();
        expect(sp.getInt('notification_hour'), 7);
        expect(sp.getInt('notification_minute'), 30);
      },
    );
  });

  // -------------------------------------------------------------------------
  // DailyReadingNotifier
  // -------------------------------------------------------------------------
  group('DailyReadingNotifier', () {
    test('loads initial state as Loaded with index 0 on day 0', () async {
      // Use the CORRECT key: 'installation_date_utc' (ReadingPlanService._installationDateKey)
      SharedPreferences.setMockInitialValues({
        'installation_date_utc': DateTime.now().toUtc().toIso8601String(),
      });

      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);

      // Before resolving it should be loading.
      expect(container.read(dailyReadingProvider).isLoading, isTrue);

      final state = await container.read(dailyReadingProvider.future);
      expect(state, isA<Loaded>());

      final loaded = state as Loaded;
      expect(loaded.currentIndex, 0);
      expect(loaded.chapter.reference, 'Génesis 1');
    });

    test('goToChapter(+1) advances currentIndex to 1', () async {
      SharedPreferences.setMockInitialValues({
        'installation_date_utc': DateTime.now().toUtc().toIso8601String(),
      });

      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);
      await container.read(dailyReadingProvider.future);

      await container.read(dailyReadingProvider.notifier).goToChapter(1);

      final state = container.read(dailyReadingProvider).requireValue;
      expect(state, isA<Loaded>());
      expect((state as Loaded).currentIndex, 1);
    });

    test(
      'goToChapter wraps around to last chapter when going back from index 0',
      () async {
        SharedPreferences.setMockInitialValues({
          'installation_date_utc': DateTime.now().toUtc().toIso8601String(),
        });

        final container = _makeContainer();
        addTearDown(container.dispose);

        await container.read(sharedPreferencesProvider.future);
        await container.read(dailyReadingProvider.future);

        // Mock has 1 book (GEN) with 50 chapters → plan length = 50
        await container.read(dailyReadingProvider.notifier).goToChapter(-1);

        final state = container.read(dailyReadingProvider).requireValue;
        expect(state, isA<Loaded>());
        expect((state as Loaded).currentIndex, 49); // 50 - 1 = last chapter
      },
    );

    // [NEW-TEST] loadFreeChapter: tests the FreeReadingLoaded state path
    test('loadFreeChapter transitions to FreeReadingLoaded', () async {
      SharedPreferences.setMockInitialValues({
        'installation_date_utc': DateTime.now().toUtc().toIso8601String(),
      });

      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);
      await container.read(dailyReadingProvider.future);

      await container
          .read(dailyReadingProvider.notifier)
          .loadFreeChapter('LUK', 'Lucas', 4);

      final state = container.read(dailyReadingProvider).requireValue;
      expect(state, isA<FreeReadingLoaded>());
      expect((state as FreeReadingLoaded).chapter.bookId, 'LUK');
      expect(state.chapter.chapterNumber, 4);
    });

    test('goToChapter is a no-op when in FreeReadingLoaded state', () async {
      SharedPreferences.setMockInitialValues({
        'installation_date_utc': DateTime.now().toUtc().toIso8601String(),
      });

      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);
      await container.read(dailyReadingProvider.future);

      // Enter free reading mode
      await container
          .read(dailyReadingProvider.notifier)
          .loadFreeChapter('LUK', 'Lucas', 4);

      // Should not crash or change state type
      await container.read(dailyReadingProvider.notifier).goToChapter(1);

      final state = container.read(dailyReadingProvider).requireValue;
      // Still free reading — goToChapter is a no-op because state is not Loaded
      expect(state, isA<FreeReadingLoaded>());
    });
  });
}

// ---------------------------------------------------------------------------
// Mock implementations
// ---------------------------------------------------------------------------

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
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> scheduleDailyNotification({
    required TimeOfDay time,
    required String passageReference,
  }) async => true;
}
