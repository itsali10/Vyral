import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../screens/welcome_screen.dart';

/// Wraps a screen that requires a logged-in session.
class AuthGuard extends StatefulWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
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
    if (!AuthService.instance.isLoggedIn && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.instance.isLoggedIn) {
      return const WelcomeScreen();
    }
    return widget.child;
  }
}

/// Routes that require authentication.
const vyralProtectedRoutes = <String>{
  '/home',
  '/explore',
  '/create',
  '/profile',
  '/saved',
  '/settings',
  '/user',
};

bool vyralRouteRequiresAuth(String? name) {
  if (name == null) return false;
  return vyralProtectedRoutes.contains(name);
}
