import 'package:flutter/material.dart';

/// Bundled font families declared in [pubspec.yaml].
abstract final class VyralFonts {
  static const String inter = 'Inter';
  /// Variable font (Google Fonts OFL); use [FontWeight] 400–900 in [TextStyle].
  static const String display = 'PlayfairDisplay';
}

/// App typography using bundled Inter + Playfair Display (no runtime network fetch).
abstract final class VyralTypography {
  VyralTypography._();

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: VyralFonts.inter,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  static TextStyle display({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: VyralFonts.display,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
