import type { TextStyle } from 'react-native';

/**
 * Typography scale from the Week 3 design document.
 *
 * The system font (undefined `fontFamily`, i.e. San Francisco / Roboto) is
 * used deliberately (no custom webfont) so text renders with the exact
 * metrics each OS screen reader and Dynamic Type / font-scaling engine
 * already expects. Nothing in the product is set below 16px — the
 * accessibility-first floor for body copy and labels.
 *
 * Port of lib/core/theme/app_typography.dart. React Native's `lineHeight` is
 * an absolute pixel value (unlike Flutter's multiplier `height`), so it is
 * computed here as `fontSize * multiplier`.
 */
export const AppTypography = {
  h1Size: 32,
  h2Size: 24,
  h3Size: 20,
  h4Size: 18,
  bodyLargeSize: 18,
  bodySize: 16,
};

/**
 * Body-Emphasis: 16px / 600 / 1.5 line height — status text paired with an
 * icon ("Taken · 8:04 AM"), form labels.
 */
export function bodyEmphasis(color: string): TextStyle {
  return {
    fontSize: AppTypography.bodySize,
    fontWeight: '600',
    lineHeight: AppTypography.bodySize * 1.5,
    color,
  };
}

export interface TextTheme {
  headlineLarge: TextStyle;
  headlineMedium: TextStyle;
  titleLarge: TextStyle;
  titleMedium: TextStyle;
  titleSmall: TextStyle;
  bodyLarge: TextStyle;
  bodyMedium: TextStyle;
  bodySmall: TextStyle;
  labelLarge: TextStyle;
  labelMedium: TextStyle;
  labelSmall: TextStyle;
}

/**
 * Maps the design scale onto named text styles.
 *
 * | Design       | Slot           |
 * | ------------ | -------------- |
 * | H1           | headlineLarge  |
 * | H2           | headlineMedium |
 * | H3           | titleLarge     |
 * | H4           | titleMedium    |
 * | Body-Large   | bodyLarge      |
 * | Body         | bodyMedium     |
 * | Button/Label | labelLarge     |
 */
export function buildTextTheme(textColor: string, secondaryColor: string): TextTheme {
  return {
    headlineLarge: {
      fontSize: AppTypography.h1Size,
      fontWeight: '700',
      lineHeight: AppTypography.h1Size * 1.3,
      color: textColor,
    },
    headlineMedium: {
      fontSize: AppTypography.h2Size,
      fontWeight: '700',
      lineHeight: AppTypography.h2Size * 1.35,
      color: textColor,
    },
    titleLarge: {
      fontSize: AppTypography.h3Size,
      fontWeight: '600',
      lineHeight: AppTypography.h3Size * 1.4,
      color: textColor,
    },
    titleMedium: {
      fontSize: AppTypography.h4Size,
      fontWeight: '600',
      lineHeight: AppTypography.h4Size * 1.4,
      color: textColor,
    },
    // Small titles are never below the 16px floor.
    titleSmall: {
      fontSize: AppTypography.bodySize,
      fontWeight: '600',
      lineHeight: AppTypography.bodySize * 1.5,
      color: textColor,
    },
    bodyLarge: {
      fontSize: AppTypography.bodyLargeSize,
      fontWeight: '400',
      lineHeight: AppTypography.bodyLargeSize * 1.5,
      color: textColor,
    },
    bodyMedium: {
      fontSize: AppTypography.bodySize,
      fontWeight: '400',
      lineHeight: AppTypography.bodySize * 1.5,
      color: textColor,
    },
    bodySmall: {
      fontSize: AppTypography.bodySize,
      fontWeight: '400',
      lineHeight: AppTypography.bodySize * 1.5,
      color: secondaryColor,
    },
    labelLarge: {
      fontSize: AppTypography.bodySize,
      fontWeight: '600',
      lineHeight: AppTypography.bodySize * 1.2,
      color: textColor,
    },
    labelMedium: {
      fontSize: AppTypography.bodySize,
      fontWeight: '600',
      lineHeight: AppTypography.bodySize * 1.2,
      color: textColor,
    },
    labelSmall: {
      fontSize: AppTypography.bodySize,
      fontWeight: '500',
      lineHeight: AppTypography.bodySize * 1.2,
      color: secondaryColor,
    },
  };
}
