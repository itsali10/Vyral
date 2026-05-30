import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/create_post_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/search_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/home_feed_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/auth_service.dart';
import 'services/settings_preferences.dart';
import 'theme/theme_scope.dart';
import 'theme/vyral_theme.dart';
import 'widgets/auth_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show UI immediately; avoid blocking first paint on slow emulator/API.
  await AuthService.instance.loadFromDisk();
  runApp(const VyralApp());

  unawaited(_bootstrapAfterLaunch());
}

Future<void> _bootstrapAfterLaunch() async {
  try {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  } catch (_) {
    // Some emulators crash system services during cold start (DeadSystemException).
  }
  await AuthService.instance.validateSession();
  if (AuthService.instance.isLoggedIn) {
    await SettingsPreferences.instance.loadFromApi();
  }
}

/// Observes navigation so screens like [HomeFeedScreen] can refresh on return.
final RouteObserver<ModalRoute<void>> vyralRouteObserver =
    RouteObserver<ModalRoute<void>>();

final GlobalKey<NavigatorState> vyralNavigatorKey = GlobalKey<NavigatorState>();

class VyralApp extends StatefulWidget {
  const VyralApp({super.key});

  @override
  State<VyralApp> createState() => _VyralAppState();
}

class _VyralAppState extends State<VyralApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    setState(() {});
    if (!AuthService.instance.isLoggedIn) {
      vyralNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  String get initialRoute {
    return AuthService.instance.isLoggedIn ? '/home' : '/';
  }

  Widget _guard(Widget child) => AuthGuard(child: child);

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      themeMode: _themeMode,
      toggleTheme: _toggleTheme,
      onThemeModeChanged: _setThemeMode,
      child: ListenableBuilder(
        listenable: AuthService.instance,
        builder: (context, _) {
          return MaterialApp(
            navigatorKey: vyralNavigatorKey,
            navigatorObservers: [vyralRouteObserver],
            debugShowCheckedModeBanner: false,
            title: 'Vyral',
            theme: VyralTheme.light,
            darkTheme: VyralTheme.dark,
            themeMode: _themeMode,
            initialRoute: initialRoute,
            onGenerateRoute: (settings) {
              final name = settings.name ?? '/';
              if (vyralRouteRequiresAuth(name) &&
                  !AuthService.instance.isLoggedIn) {
                return MaterialPageRoute<void>(
                  settings: const RouteSettings(name: '/'),
                  builder: (_) => const WelcomeScreen(),
                );
              }
              return null;
            },
            routes: {
              '/': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/home': (context) => _guard(const HomeFeedScreen()),
              '/explore': (context) => _guard(const ExploreScreen()),
              '/create': (context) => _guard(const CreatePostScreen()),
              '/profile': (context) => _guard(const ProfileScreen()),
              '/user': (context) {
                final userId =
                    ModalRoute.of(context)?.settings.arguments as String?;
                return _guard(ProfileScreen(userId: userId));
              },
              '/saved': (context) => _guard(const SavedScreen()),
              '/settings': (context) => _guard(const SettingsScreen()),
              '/search': (context) => _guard(const SearchScreen()),
            },
          );
        },
      ),
    );
  }
}
