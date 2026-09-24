import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/app_providers.dart';
import 'screens/dashboard_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/reading_screen.dart';

/// Shared navigator key. Used by [NotificationService] to navigate from a
/// background tap without needing a BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// [FIX-ROUTER-01] The old redirect used `await ref.read(...)` inside a
/// `Provider<GoRouter>`, which is illegal (Providers must be sync).
/// Replaced with a `listenable`-based approach: the router refreshes
/// whenever [sharedPreferencesProvider] emits, and the redirect reads the
/// already-resolved value synchronously via `.value`.
///
/// [FIX-ROUTER-02] Used `routerProvider.notifier` → replaced with a plain
/// `Provider` that holds an immutable `GoRouter` instance for the lifetime
/// of the app, which is the recommended GoRouter + Riverpod pattern.
final routerProvider = Provider<GoRouter>((ref) {
  // Watch the preferences AsyncValue so the router rebuilds after init.
  final prefsAsync = ref.watch(sharedPreferencesProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/dashboard',
    // Re-evaluate redirect every time the prefs state changes.
    refreshListenable: _RouterRefreshListenable(ref),
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/reading',
        builder: (context, state) => const ReadingScreen(),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const ExploreScreen(),
      ),
    ],
    redirect: (context, state) {
      // Prefs not yet loaded → show nothing (GoRouter will call this again
      // when `refreshListenable` notifies).
      if (!prefsAsync.hasValue) return null;

      // Use the reading-plan service to check onboarding synchronously via
      // a cached SharedPreferences value (already loaded above).
      final prefs = prefsAsync.requireValue;
      // Key is defined as ReadingPlanService._installationDateKey = 'installation_date_utc'
      final hasInstallation = prefs.containsKey('installation_date_utc');

      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!hasInstallation) {
        return isOnboarding ? null : '/onboarding';
      }

      if (isOnboarding) return '/dashboard';

      return null;
    },
  );
});

/// A [Listenable] that forwards notifications from a Riverpod provider
/// to GoRouter's refresh mechanism.
class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    ref.listen<dynamic>(sharedPreferencesProvider, (_, _) => notifyListeners());
  }
}
