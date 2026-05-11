import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'screens/create_post_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/home_feed_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';

/// Drives [GoRouter] redirect re-evaluation when [FirebaseAuth] session changes.
class GoRouterAuthRefresh extends ChangeNotifier {
  GoRouterAuthRefresh() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

final _goRouterAuthRefresh = GoRouterAuthRefresh();

/// Declarative routing alternative to [MaterialApp.routes] in `lib/main.dart`.
///
/// Use with:
/// ```dart
/// MaterialApp.router(
///   routerConfig: appRouter,
///   theme: VyralTheme.dark,
///   debugShowCheckedModeBanner: false,
/// )
/// ```
final GoRouter appRouter = GoRouter(
  refreshListenable: _goRouterAuthRefresh,
  initialLocation:
      FirebaseAuth.instance.currentUser != null ? '/home' : '/',
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final path = state.uri.path;
    const publicPaths = {'/', '/login', '/signup'};
    if (!loggedIn && !publicPaths.contains(path)) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeFeedScreen(),
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) => const ExploreScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/saved',
      builder: (context, state) => const SavedScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
