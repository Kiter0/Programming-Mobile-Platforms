import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/app_screens.dart';
import 'services/auth_service.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthService auth) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/movies',
    refreshListenable: auth,

    redirect: (context, state) {
      final path = state.uri.path;
      final isLogin = path == '/login';
      final isAdmin = path == '/admin';
      final isTickets = path == '/tickets';

      // Гість має увійти для перегляду квитків або адмінпанелі.
      if ((isTickets || isAdmin) && !auth.isLoggedIn) {
        return Uri(
          path: '/login',
          queryParameters: {'from': state.uri.toString()},
        ).toString();
      }

      // Звичайний користувач не може відкрити адмінпанель.
      if (isAdmin && !auth.isAdmin) {
        return '/movies';
      }

      // Після входу повертаємо користувача на початкову адресу.
      if (isLogin && auth.isLoggedIn) {
        final from = state.uri.queryParameters['from'];
        final destination = Uri.tryParse(from ?? '');
        final destinationPath = destination?.path;

        if (destinationPath == '/admin' && !auth.isAdmin) {
          return '/movies';
        }

        if (destinationPath != null &&
            destinationPath.startsWith('/') &&
            destinationPath != '/login') {
          return destination.toString();
        }

        return '/movies';
      }

      return null;
    },

    errorBuilder: (context, state) => const NotFoundScreen(),

    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/movies'),

      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(auth: auth),
      ),

      GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CinemaScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Вкладка «Афіша».
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/movies',
                builder: (context, state) => const MoviesScreen(),
                routes: [
                  GoRoute(
                    path: ':movieId',
                    builder: (context, state) => MovieDetailScreen(
                      movieId: state.pathParameters['movieId']!,
                      auth: auth,
                    ),
                    routes: [
                      GoRoute(
                        path: 'session/:sessionId/seats',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => SeatsScreen(
                          movieId: state.pathParameters['movieId']!,
                          sessionId: state.pathParameters['sessionId']!,
                          auth: auth,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Вкладка «Мої квитки».
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tickets',
                builder: (context, state) => const TicketsScreen(),
              ),
            ],
          ),

          // Вкладка «Профіль».
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => ProfileScreen(auth: auth),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
