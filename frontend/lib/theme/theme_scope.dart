import 'package:flutter/material.dart';

/// Provides app-wide theme mode toggle. Place as an ancestor of [MaterialApp].
class ThemeScope extends InheritedWidget {
  const ThemeScope({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required this.onThemeModeChanged,
    required super.child,
  });

  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  /// Sets [ThemeMode] for the whole app (light / dark / system).
  final ValueChanged<ThemeMode> onThemeModeChanged;

  static ThemeScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope not found above MaterialApp');
    return scope!;
  }

  @override
  bool updateShouldNotify(ThemeScope oldWidget) => themeMode != oldWidget.themeMode;
}
