import 'package:flutter/material.dart';

/// Typography scale from the Week 3 design document.
///
/// The system font stack is used deliberately (no custom webfont) so text
/// renders with the exact metrics each OS screen reader and Dynamic Type /
/// font-scaling engine already expects. Nothing in the product is set below
/// 16px — the accessibility-first floor for body copy and labels.
abstract final class AppTypography {
  static const double h1Size = 32;
  static const double h2Size = 24;
  static const double h3Size = 20;
  static const double h4Size = 18;
  static const double bodyLargeSize = 18;
  static const double bodySize = 16;

  /// Body-Emphasis: 16px / 600 / 1.5 — status text paired with an icon
  /// ("Taken · 8:04 AM"), form labels.
  static const TextStyle bodyEmphasis = TextStyle(
    fontSize: bodySize,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  /// Maps the design scale onto Material's [TextTheme] slots.
  ///
  /// | Design      | TextTheme slot   |
  /// | ----------- | ---------------- |
  /// | H1          | headlineLarge    |
  /// | H2          | headlineMedium   |
  /// | H3          | titleLarge       |
  /// | H4          | titleMedium      |
  /// | Body-Large  | bodyLarge        |
  /// | Body        | bodyMedium       |
  /// | Button/Label| labelLarge       |
  static TextTheme textTheme(Color textColor, Color secondaryColor) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: h1Size,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: h2Size,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: h3Size,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: h4Size,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textColor,
      ),
      // Small titles are never below the 16px floor.
      titleSmall: TextStyle(
        fontSize: bodySize,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: bodyLargeSize,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: bodySize,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: bodySize,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondaryColor,
      ),
      labelLarge: TextStyle(
        fontSize: bodySize,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: bodySize,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: bodySize,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: secondaryColor,
      ),
    );
  }
}
