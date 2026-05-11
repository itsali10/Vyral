import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/create_post_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/home_feed_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/theme_scope.dart';
import 'theme/vyral_theme.dart';

/// Alternative declarative routing: see [appRouter] in `lib/router.dart` and use
/// `MaterialApp.router(routerConfig: appRouter, theme: VyralTheme.dark, ...)`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e, st) {
    debugPrint('Firebase.initializeApp failed (add Firebase config): $e');
    debugPrint('$st');
  }
  runApp(VyralApp(firebaseReady: firebaseReady));
}

class VyralApp extends StatefulWidget {
  const VyralApp({
    super.key,
    required this.firebaseReady,
  });

  final bool firebaseReady;

  @override
  State<VyralApp> createState() => _VyralAppState();
}

class _VyralAppState extends State<VyralApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  String get initialRoute {
    if (!widget.firebaseReady) return '/';
    return FirebaseAuth.instance.currentUser != null ? '/home' : '/';
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      themeMode: _themeMode,
      toggleTheme: _toggleTheme,
      onThemeModeChanged: _setThemeMode,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vyral',
        theme: VyralTheme.light,
        darkTheme: VyralTheme.dark,
        themeMode: _themeMode,
        initialRoute: initialRoute,
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomeFeedScreen(),
          '/explore': (context) => const ExploreScreen(),
          '/create': (context) => const CreatePostScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/saved': (context) => const SavedScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
