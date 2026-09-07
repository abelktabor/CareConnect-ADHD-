import 'package:flutter/material.dart';

/// Colour tokens from the Week 3 Figma "Mobile Design in Figma — Color
/// Palette". Every value here was contrast-verified in the design document and
/// is re-verified by `test/unit/contrast_test.dart`, so a token cannot drift
/// below WCAG 2.2 AA without a failing test.
///
/// Rule from the requirements: status is **never** carried by colour alone.
/// Each status colour is always rendered next to its fixed icon and a text
/// label (see `StatusChip`).
abstract final class AppColors {
  // ── Light mode ────────────────────────────────────────────────────────────

  /// Primary — Harbor Teal. Care-recipient buttons, active nav, links.
  static const Color primary = Color(0xFF1B5E7A);

  /// Primary Dark — pressed / hover state of primary controls.
  static const Color primaryDark = Color(0xFF154A61);

  /// Secondary — Dusk Violet. Caregiver-mode surfaces and nav accents.
  static const Color secondary = Color(0xFF5B4B8A);

  /// Accent — Focus Coral. The single dominant next-action CTA only.
  static const Color accent = Color(0xFFC24A34);

  /// Success — paired with check-circle (filled).
  static const Color success = Color(0xFF2E7D4F);

  /// Warning — paired with clock. Due soon, snoozed, refill running low.
  static const Color warning = Color(0xFF8A5A00);

  /// Error — paired with alert-triangle (filled). Overdue / missed.
  static const Color error = Color(0xFFB3261E);

  /// Info — paired with info-circle. Last-synced, plain-language confirmations.
  static const Color info = Color(0xFF2B6CB0);

  /// Neutral-900 — primary body text (16.94:1 on white).
  static const Color neutral900 = Color(0xFF1A1D1F);

  /// Neutral-700 — secondary text, captions.
  static const Color neutral700 = Color(0xFF4A4F54);

  /// Neutral-500 — disabled text/icons. UI-level 3:1 use only, never body text.
  static const Color neutral500 = Color(0xFF767C82);

  /// Neutral-300 — borders and dividers (non-text).
  static const Color neutral300 = Color(0xFFC7CBCE);

  /// Neutral-100 — card / surface background, light mode.
  static const Color neutral100 = Color(0xFFF4F5F6);

  /// App background, light mode.
  static const Color white = Color(0xFFFFFFFF);

  // ── Dark mode ─────────────────────────────────────────────────────────────

  static const Color darkBackground = Color(0xFF101214);
  static const Color darkSurface = Color(0xFF1C1F22);
  static const Color darkPrimary = Color(0xFF5FB8D6);
  static const Color darkSecondary = Color(0xFFB9A3E8);
  static const Color darkAccent = Color(0xFFE8836A);
  static const Color darkSuccess = Color(0xFF6FCF97);
  static const Color darkWarning = Color(0xFFE0A93B);
  static const Color darkError = Color(0xFFF28B82);
  static const Color darkInfo = Color(0xFF7FB2E8);
  static const Color darkBodyText = Color(0xFFECEDEE);
  static const Color darkSecondaryText = Color(0xFFB8BCC0);
  static const Color darkBorder = Color(0xFF3A3F44);
}

/// Semantic colour roles resolved for the current brightness.
///
/// Exposed as a [ThemeExtension] so widgets ask `context.ccColors.warning`
/// instead of hard-coding a hex — the same "never hardcode a colour" rule the
/// web workspaces enforce through `@careconnect/design-tokens`.
@immutable
class CcColors extends ThemeExtension<CcColors> {
  const CcColors({
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.textPrimary,
    required this.textSecondary,
    required this.disabled,
    required this.border,
    required this.surface,
    required this.background,
    required this.careRecipientPrimary,
    required this.caregiverPrimary,
  });

  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color textPrimary;
  final Color textSecondary;
  final Color disabled;
  final Color border;
  final Color surface;
  final Color background;
  final Color careRecipientPrimary;
  final Color caregiverPrimary;

  static const CcColors light = CcColors(
    accent: AppColors.accent,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
    textPrimary: AppColors.neutral900,
    textSecondary: AppColors.neutral700,
    disabled: AppColors.neutral500,
    border: AppColors.neutral300,
    surface: AppColors.neutral100,
    background: AppColors.white,
    careRecipientPrimary: AppColors.primary,
    caregiverPrimary: AppColors.secondary,
  );

  static const CcColors dark = CcColors(
    accent: AppColors.darkAccent,
    success: AppColors.darkSuccess,
    warning: AppColors.darkWarning,
    error: AppColors.darkError,
    info: AppColors.darkInfo,
    textPrimary: AppColors.darkBodyText,
    textSecondary: AppColors.darkSecondaryText,
    disabled: AppColors.neutral500,
    border: AppColors.darkBorder,
    surface: AppColors.darkSurface,
    background: AppColors.darkBackground,
    careRecipientPrimary: AppColors.darkPrimary,
    caregiverPrimary: AppColors.darkSecondary,
  );

  @override
  CcColors copyWith({
    Color? accent,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? textPrimary,
    Color? textSecondary,
    Color? disabled,
    Color? border,
    Color? surface,
    Color? background,
    Color? careRecipientPrimary,
    Color? caregiverPrimary,
  }) {
    return CcColors(
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      disabled: disabled ?? this.disabled,
      border: border ?? this.border,
      surface: surface ?? this.surface,
      background: background ?? this.background,
      careRecipientPrimary: careRecipientPrimary ?? this.careRecipientPrimary,
      caregiverPrimary: caregiverPrimary ?? this.caregiverPrimary,
    );
  }

  @override
  CcColors lerp(ThemeExtension<CcColors>? other, double t) {
    if (other is! CcColors) return this;
    return CcColors(
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      background: Color.lerp(background, other.background, t)!,
      careRecipientPrimary: Color.lerp(
        careRecipientPrimary,
        other.careRecipientPrimary,
        t,
      )!,
      caregiverPrimary: Color.lerp(
        caregiverPrimary,
        other.caregiverPrimary,
        t,
      )!,
    );
  }
}

/// Convenience accessor: `context.ccColors.success`.
extension CcColorsContext on BuildContext {
  CcColors get ccColors =>
      Theme.of(this).extension<CcColors>() ?? CcColors.light;
}
