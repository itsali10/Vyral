import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/theme/theme_scope.dart';
import 'package:frontend/theme/vyral_theme.dart';

void main() {
  testWidgets('WelcomeScreen shows primary actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      ThemeScope(
        themeMode: ThemeMode.dark,
        toggleTheme: () {},
        onThemeModeChanged: (_) {},
        child: MaterialApp(
          theme: VyralTheme.light,
          darkTheme: VyralTheme.dark,
          themeMode: ThemeMode.dark,
          home: const WelcomeScreen(),
        ),
      ),
    );

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
