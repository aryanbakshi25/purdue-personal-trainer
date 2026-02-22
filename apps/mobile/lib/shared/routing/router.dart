import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/schedule/schedule_screen.dart';
import '../../features/schedule/schedule_edit_screen.dart';
import '../../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLogin) return '/login';
      if (isLoggedIn && isOnLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
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
