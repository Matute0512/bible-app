import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/app_providers.dart';
import 'screens/dashboard_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/reading_screen.dart';
import 'services/reading_plan_service.dart';

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
  // [FIX-RO-01] Do NOT call ref.watch inside a Provider<GoRouter> body.
  // Watching a provider causes the Provider to rebuild on every emission,
  // which creates a brand-new GoRouter instance and resets the navigation
  // stack. Instead, _RouterRefreshListenable re-evaluates only the redirect
  // function, leaving the router instance stable.
  final listenable = _RouterRefreshListenable(ref);
  ref.onDispose(listenable.dispose); // [FIX-RO-03] dispose ChangeNotifier

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: listenable,
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
      // [FIX-RO-01] Read synchronously inside the redirect — called only when
      // _RouterRefreshListenable notifies, not on every provider emission.
      final prefsAsync = ref.read(sharedPreferencesProvider);
      if (!prefsAsync.hasValue) return null;

      final prefs = prefsAsync.requireValue;
      // [FIX-RO-02] Reference the key constant from ReadingPlanService so a
      // rename stays in sync automatically.
      final hasInstallation =
          prefs.containsKey(ReadingPlanService.installationDateKey);

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
