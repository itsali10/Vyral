import 'package:flutter/material.dart';

import 'vyral_typography.dart';

class VyralColors {
  // Global light-mode palette
  static const Color primaryRose = Color(0xFFC98C8C);
  static const Color primaryDark = Color(0xFFA56B6B);
  static const Color primaryLight = Color(0xFFE7B5B5);
  static const Color mainBackground = Color(0xFFF7F3F1);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFEFE7E4);
  static const Color primaryText = Color(0xFF2B2B2B);
  static const Color secondaryText = Color(0xFF6E6E6E);
  static const Color placeholder = Color(0xFFA8A8A8);
  static const Color border = Color(0xFFE5DCD8);
  static const Color inputBackground = Color(0xFFF5EEEB);
  static const Color likeHighlight = Color(0xFFD96C6C);
  static const Color success = Color(0xFF6FBF73);

  static const Color background = Color(0xFF1F2126);
  static const Color surface = Color(0xFF3C3F4A);
  static const Color card = Color(0xFF2D2F38);
  static const Color blueGray = Color(0xFF5B5D6E);
  static const Color softPink = Color(0xFFD8B6BD);
  static const Color dustyRose = Color(0xFFA78A8F);
  static const Color offWhite = Color(0xFFE1DFE3);
  static const Color mutedText = Color(0xFF888890);
  static const Color deepBlack = Color(0xFF1F2126);
  static const Color white = Color(0xFFFFFFFF);

  /// White at 50% opacity (welcome subcopy on gradients).
  static const Color whiteSubtle = Color(0x80FFFFFF);

  /// Primary text on dark cards (feeds, composer).
  static const Color caption = Color(0xFFDADAE5);

  /// Bottom navigation icons when unselected.
  static const Color navUnselected = Color(0xFF666670);

  /// Welcome gradient lower stop.
  static const Color welcomeGradientBottom = Color(0xFF2A2030);

  /// Profile pin / thumbnail variation (darker than [blueGray]).
  static const Color blueGrayDark = Color(0xFF4A4C5C);

  /// Profile pin / thumbnail variation (lighter than [blueGray]).
  static const Color blueGrayLight = Color(0xFF666982);

  static const Color error = Color(0xFFE05A5A);

  /// Explore masonry tile placeholder backs.
  static const List<Color> exploreMasonryShades = [
    blueGray,
    Color(0xFF53566A),
    Color(0xFF4B4E62),
    Color(0xFF585B70),
    Color(0xFF676982),
    Color(0xFF4E5060),
    Color(0xFF626578),
  ];
}

class VyralTextStyles {
  VyralTextStyles._();

  static TextStyle get displayLarge => VyralTypography.display(
        fontSize: 52,
        fontWeight: FontWeight.w600,
        color: VyralColors.white,
      );

  static TextStyle get headingXL => VyralTypography.display(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: VyralColors.white,
      );

  static TextStyle get headingL => VyralTypography.display(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: VyralColors.white,
      );

  static TextStyle get headingM => VyralTypography.display(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: VyralColors.white,
      );

  static TextStyle get headingS => VyralTypography.display(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: VyralColors.white,
      );

  static TextStyle get bodyL => VyralTypography.inter(
        fontSize: 16,
        color: VyralColors.offWhite,
      );

  static TextStyle get bodyM => VyralTypography.inter(
        fontSize: 14,
        color: VyralColors.offWhite,
      );

  static TextStyle get bodyS => VyralTypography.inter(
        fontSize: 12,
        color: VyralColors.offWhite,
      );

  static TextStyle get labelM => VyralTypography.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: VyralColors.offWhite,
      );

  static TextStyle get labelS => VyralTypography.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: VyralColors.offWhite,
      );

  static TextStyle get button => VyralTypography.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: VyralColors.deepBlack,
      );

  static TextStyle get muted => VyralTypography.inter(
        fontSize: 12,
        color: VyralColors.mutedText,
      );

  static TextStyle get rose => VyralTypography.inter(
        fontSize: 12,
        color: VyralColors.dustyRose,
      );
}

class VyralTheme {
  VyralTheme._();

  static ThemeData get light {
    const inter = VyralFonts.inter;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: VyralColors.border),
    );

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: inter,
      scaffoldBackgroundColor: VyralColors.mainBackground,
      dividerColor: VyralColors.border,
      colorScheme: ColorScheme.light(
        primary: VyralColors.primaryRose,
        onPrimary: VyralColors.cardBackground,
        secondary: VyralColors.primaryDark,
        onSecondary: VyralColors.cardBackground,
        surface: VyralColors.secondaryBackground,
        onSurface: VyralColors.primaryText,
        onSurfaceVariant: VyralColors.secondaryText,
        error: VyralColors.error,
        onError: VyralColors.cardBackground,
        outline: VyralColors.border,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: VyralColors.primaryText,
        iconTheme: IconThemeData(color: VyralColors.primaryText),
      ),
      cardTheme: CardThemeData(
        color: VyralColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: VyralColors.border),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: VyralColors.cardBackground,
        selectedItemColor: VyralColors.primaryDark,
        unselectedItemColor: VyralColors.secondaryText,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VyralColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: VyralColors.secondaryText),
        floatingLabelStyle: const TextStyle(color: VyralColors.primaryDark),
        hintStyle: const TextStyle(color: VyralColors.placeholder),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VyralColors.primaryRose, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VyralColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VyralColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VyralColors.primaryRose,
          foregroundColor: VyralColors.cardBackground,
          textStyle: VyralTypography.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: VyralColors.cardBackground,
          ),
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VyralColors.primaryDark,
          side: const BorderSide(color: VyralColors.border),
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }

  static ThemeData get dark {
    const inter = VyralFonts.inter;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: VyralColors.blueGray),
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: VyralColors.background,
      fontFamily: inter,
      dividerColor: VyralColors.blueGray,
      colorScheme: ColorScheme.dark(
        primary: VyralColors.softPink,
        onPrimary: VyralColors.deepBlack,
        secondary: VyralColors.dustyRose,
        onSecondary: VyralColors.white,
        surface: VyralColors.surface,
        onSurface: VyralColors.offWhite,
        onSurfaceVariant: VyralColors.mutedText,
        error: VyralColors.error,
        onError: VyralColors.white,
        outline: VyralColors.blueGray,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: VyralColors.white),
        foregroundColor: VyralColors.offWhite,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: VyralColors.deepBlack,
        selectedItemColor: VyralColors.softPink,
        unselectedItemColor: VyralColors.mutedText,
        elevation: 12,
      ),
      cardTheme: CardThemeData(
        color: VyralColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VyralColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: VyralColors.dustyRose),
        floatingLabelStyle: const TextStyle(color: VyralColors.dustyRose),
        hintStyle: const TextStyle(color: VyralColors.mutedText),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VyralColors.softPink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VyralColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VyralColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VyralColors.softPink,
          foregroundColor: VyralColors.deepBlack,
          textStyle: VyralTextStyles.button,
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VyralColors.white,
          side: const BorderSide(color: VyralColors.blueGray),
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }
}
