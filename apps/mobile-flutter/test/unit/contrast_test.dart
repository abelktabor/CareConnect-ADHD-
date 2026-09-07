import 'package:careconnect_mobile/core/theme/app_colors.dart';
import 'package:careconnect_mobile/core/utils/contrast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Re-verifies every ratio published in the Week 3 design document so the
/// token file cannot drift below WCAG 2.2 AA without a failing test.
void main() {
  group('relative luminance', () {
    test('white is 1 and black is 0', () {
      expect(relativeLuminance(AppColors.white), closeTo(1.0, 0.0001));
      expect(relativeLuminance(const Color(0xFF000000)), closeTo(0.0, 0.0001));
    });

    test('contrast is symmetric and bounded', () {
      final a = contrastRatio(AppColors.primary, AppColors.white);
      final b = contrastRatio(AppColors.white, AppColors.primary);
      expect(a, closeTo(b, 0.0001));
      expect(
        contrastRatio(AppColors.white, const Color(0xFF000000)),
        closeTo(21, 0.01),
      );
      expect(
        contrastRatio(AppColors.white, AppColors.white),
        closeTo(1, 0.0001),
      );
    });
  });

  group('light mode pairs from the design document', () {
    final expected = <String, (Color, Color, double)>{
      'Primary on white': (AppColors.primary, AppColors.white, 7.17),
      'Secondary on white': (AppColors.secondary, AppColors.white, 7.45),
      'Accent on white': (AppColors.accent, AppColors.white, 4.86),
      'Success on white': (AppColors.success, AppColors.white, 5.05),
      'Warning on white': (AppColors.warning, AppColors.white, 5.93),
      'Error on white': (AppColors.error, AppColors.white, 6.54),
      'Info on white': (AppColors.info, AppColors.white, 5.42),
      'Body text on white': (AppColors.neutral900, AppColors.white, 16.94),
      'Body text on Neutral-100': (
        AppColors.neutral900,
        AppColors.neutral100,
        15.52,
      ),
    };

    expected.forEach((name, pair) {
      test('$name ≈ ${pair.$3}:1 and passes AA', () {
        final ratio = contrastRatio(pair.$1, pair.$2);
        expect(ratio, closeTo(pair.$3, 0.05));
        expect(meetsAa(pair.$1, pair.$2), isTrue);
      });
    });

    test('Neutral-500 is UI-only: clears 3:1 but not 4.5:1', () {
      final ratio = contrastRatio(AppColors.neutral500, AppColors.white);
      expect(ratio, closeTo(4.22, 0.05));
      expect(
        meetsAa(AppColors.neutral500, AppColors.white, largeTextOrUi: true),
        isTrue,
      );
      expect(meetsAa(AppColors.neutral500, AppColors.white), isFalse);
    });

    test('Neutral-300 and Neutral-100 are never text colours', () {
      expect(
        meetsAa(AppColors.neutral300, AppColors.white, largeTextOrUi: true),
        isFalse,
      );
      expect(
        meetsAa(AppColors.neutral100, AppColors.white, largeTextOrUi: true),
        isFalse,
      );
    });
  });

  group('dark mode pairs from the design document', () {
    final expected = <String, (Color, double)>{
      'Primary': (AppColors.darkPrimary, 8.33),
      'Secondary': (AppColors.darkSecondary, 8.46),
      'Accent': (AppColors.darkAccent, 7.05),
      'Success': (AppColors.darkSuccess, 9.88),
      'Warning': (AppColors.darkWarning, 8.86),
      'Error': (AppColors.darkError, 7.86),
      'Info': (AppColors.darkInfo, 8.43),
      'Body text': (AppColors.darkBodyText, 16.01),
    };

    expected.forEach((name, pair) {
      test('$name on #101214 ≈ ${pair.$2}:1', () {
        expect(
          contrastRatio(pair.$1, AppColors.darkBackground),
          closeTo(pair.$2, 0.05),
        );
        expect(meetsAa(pair.$1, AppColors.darkBackground), isTrue);
        expect(meetsAa(pair.$1, AppColors.darkSurface), isTrue);
      });
    });
  });

  group('theme extension guarantees', () {
    for (final (label, colors) in [
      ('light', CcColors.light),
      ('dark', CcColors.dark),
    ]) {
      test('$label status and text colours pass on background and surface', () {
        // Accent is only ever a button fill with white text (never text on a
        // surface), so it is held to the 3:1 non-text minimum instead.
        expect(
          meetsAa(colors.accent, colors.surface, largeTextOrUi: true),
          isTrue,
        );
        expect(
          meetsAa(colors.accent, colors.background, largeTextOrUi: true),
          isTrue,
        );
        final foregrounds = {
          'success': colors.success,
          'warning': colors.warning,
          'error': colors.error,
          'info': colors.info,
          'textPrimary': colors.textPrimary,
          'textSecondary': colors.textSecondary,
          'careRecipientPrimary': colors.careRecipientPrimary,
          'caregiverPrimary': colors.caregiverPrimary,
        };
        foregrounds.forEach((name, fg) {
          expect(
            meetsAa(fg, colors.background),
            isTrue,
            reason: '$name on background',
          );
          expect(
            meetsAa(fg, colors.surface),
            isTrue,
            reason: '$name on surface',
          );
        });
        expect(
          meetsAa(colors.disabled, colors.background, largeTextOrUi: true),
          isTrue,
        );
      });
    }

    test('white label text passes on every filled button colour', () {
      for (final bg in [
        AppColors.primary,
        AppColors.primaryDark,
        AppColors.secondary,
        AppColors.accent,
        AppColors.success,
        AppColors.warning,
        AppColors.error,
        AppColors.info,
      ]) {
        expect(meetsAa(AppColors.white, bg), isTrue, reason: '$bg');
      }
    });

    test('copyWith and lerp keep the extension well-formed', () {
      final copied = CcColors.light.copyWith(accent: AppColors.darkAccent);
      expect(copied.accent, AppColors.darkAccent);
      expect(copied.success, CcColors.light.success);
      final mid = CcColors.light.lerp(CcColors.dark, 0.5);
      expect(mid.background, isNot(CcColors.light.background));
      expect(CcColors.light.lerp(null, 0.5), CcColors.light);
    });
  });
}
