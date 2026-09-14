/**
 * Layout constants shared across screens and components.
 *
 * Port of lib/core/theme/app_spacing.dart.
 */
export const Space = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
} as const;

export const CcRadius = {
  sm: 4,
  md: 8,
  lg: 12,
} as const;

/**
 * Minimum interactive target sizes.
 *
 * WCAG 2.2 SC 2.5.8 requires 24x24 CSS px at Level AA. The design treats
 * 44x44pt (the iOS HIG minimum) as the floor for every control and 48x48 for
 * icon buttons, so one shared set of constants clears both platforms'
 * guidelines.
 */
export const TapTarget = {
  minimum: 44,
  icon: 48,
  /**
   * The single dominant next-action button is taller than the minimum on
   * purpose — it is the one thing a user with ADHD should not have to hunt
   * for.
   */
  dominantAction: 56,
} as const;

/**
 * Responsive breakpoints. Anything at or above `tablet` gets the two-column
 * layouts from the "Tablet" and "Landscape" Figma frames.
 */
export const Breakpoints = {
  tablet: 600,
  contentMaxWidth: 840,
  formMaxWidth: 560,
} as const;
