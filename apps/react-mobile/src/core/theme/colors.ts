/**
 * Colour tokens from the Week 3 Figma "Mobile Design in Figma — Color
 * Palette". Every value here was contrast-verified in the design document and
 * is re-verified by `contrast.test.ts`, so a token cannot drift below WCAG
 * 2.2 AA without a failing test.
 *
 * Rule from the requirements: status is **never** carried by colour alone.
 * Each status colour is always rendered next to its fixed icon and a text
 * label (see `StatusChip`).
 *
 * Port of lib/core/theme/app_colors.dart.
 */
export const AppColors = {
  // Light mode
  /** Primary — Harbor Teal. Care-recipient buttons, active nav, links. */
  primary: '#1B5E7A',
  /** Primary Dark — pressed / hover state of primary controls. */
  primaryDark: '#154A61',
  /** Secondary — Dusk Violet. Caregiver-mode surfaces and nav accents. */
  secondary: '#5B4B8A',
  /** Accent — Focus Coral. The single dominant next-action CTA only. */
  accent: '#C24A34',
  /** Success — paired with check-circle (filled). */
  success: '#2E7D4F',
  /** Warning — paired with clock. Due soon, snoozed, refill running low. */
  warning: '#8A5A00',
  /** Error — paired with alert-triangle (filled). Overdue / missed. */
  error: '#B3261E',
  /** Info — paired with info-circle. Last-synced, plain-language confirmations. */
  info: '#2B6CB0',
  /** Neutral-900 — primary body text (16.94:1 on white). */
  neutral900: '#1A1D1F',
  /** Neutral-700 — secondary text, captions. */
  neutral700: '#4A4F54',
  /** Neutral-500 — disabled text/icons. UI-level 3:1 use only, never body text. */
  neutral500: '#767C82',
  /** Neutral-300 — borders and dividers (non-text). */
  neutral300: '#C7CBCE',
  /** Neutral-100 — card / surface background, light mode. */
  neutral100: '#F4F5F6',
  /** App background, light mode. */
  white: '#FFFFFF',

  // Dark mode
  darkBackground: '#101214',
  darkSurface: '#1C1F22',
  darkPrimary: '#5FB8D6',
  darkSecondary: '#B9A3E8',
  darkAccent: '#E8836A',
  darkSuccess: '#6FCF97',
  darkWarning: '#E0A93B',
  darkError: '#F28B82',
  darkInfo: '#7FB2E8',
  darkBodyText: '#ECEDEE',
  darkSecondaryText: '#B8BCC0',
  darkBorder: '#3A3F44',
} as const;

/** Semantic colour roles resolved for the current brightness. */
export interface CcColors {
  accent: string;
  success: string;
  warning: string;
  error: string;
  info: string;
  textPrimary: string;
  textSecondary: string;
  disabled: string;
  border: string;
  surface: string;
  background: string;
  careRecipientPrimary: string;
  caregiverPrimary: string;
}

export const ccColorsLight: CcColors = {
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
};

export const ccColorsDark: CcColors = {
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
};
