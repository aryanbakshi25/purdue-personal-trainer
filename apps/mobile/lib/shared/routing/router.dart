import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/schedule/schedule_screen.dart';
import '../../features/schedule/schedule_edit_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';

/// Notifier that triggers GoRouter redirect when auth or profile state changes.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(userProfileProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileState = ref.watch(userProfileProvider);
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnLogin = state.matchedLocation == '/login';
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      // Not logged in → login
      if (!isLoggedIn && !isOnLogin) return '/login';

      if (isLoggedIn) {
        // Still loading profile → don't redirect yet
        if (profileState.isLoading) return isOnLogin ? '/onboarding' : null;

        final hasProfile = profileState.valueOrNull != null;

        if (!hasProfile && !isOnOnboarding) return '/onboarding';
        if (hasProfile && (isOnOnboarding || isOnLogin)) return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/schedule',
        name: 'schedule',
        builder: (context, state) => const ScheduleScreen(),
        routes: [
          GoRoute(
            path: 'edit/:blockId',
            name: 'schedule-edit',
            builder: (context, state) {
              final blockId = state.pathParameters['blockId'];
              return ScheduleEditScreen(blockId: blockId);
            },
          ),
          GoRoute(
            path: 'new',
            name: 'schedule-new',
            builder: (context, state) =>
                const ScheduleEditScreen(blockId: null),
          ),
        ],
      ),
      // Deep-link placeholder for UPlate integration (Phase 2)
      GoRoute(
        path: '/uplate',
        name: 'uplate',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('UPlate Integration')),
          body: const Center(
            child: Text(
              'UPlate integration coming soon.\n'
              'This will link to dining recommendations.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
