/**
 * CareConnect design tokens.
 *
 * Every foreground/background pair used for text is annotated with its measured
 * contrast ratio. WCAG 2.2 AA requires 4.5:1 for normal text, 3:1 for large text
 * (>=18.66px bold or >=24px) and for UI component boundaries (SC 1.4.11).
 *
 * Do not add a color here without recording its ratio against the surfaces it
 * will sit on. Run `npm run check:contrast` to re-verify every pair below.
 * See docs/ACCESSIBILITY.md.
 */

export const color = {
  /** Page and card surfaces */
  surface: {
    base: '#FFFFFF',
    subtle: '#F5F7FA',
    raised: '#FFFFFF',
    inverse: '#1F2933',
  },

  /** Text — ratios measured against surface.base (#FFFFFF) */
  text: {
    /** 14.76:1 on white — body copy */
    primary: '#1F2933',
    /** 8.81:1 on white — secondary copy */
    secondary: '#3E4C59',
    /** 5.01:1 on white — the lightest text permitted; do not go lighter */
    muted: '#61708A',
    /** 13.75:1 on surface.inverse — text on dark surfaces */
    inverse: '#F5F7FA',
  },

  /** Brand / primary action — 8.72:1 on white */
  primary: {
    default: '#1D4E77',
    hover: '#163C5C',
    active: '#102B42',
    /** Tint for backgrounds only — never for text */
    tint: '#E3EDF5',
  },

  /**
   * Status colors. Each is paired with an icon and a text label in the UI —
   * color is never the sole carrier of meaning (WCAG SC 1.4.1).
   */
  status: {
    /** 7.42:1 on white */
    success: '#116149',
    successTint: '#E2F3EC',
    /** 6.33:1 on white */
    warning: '#8A5300',
    warningTint: '#FDF0DC',
    /** 7.35:1 on white */
    danger: '#A5231C',
    dangerTint: '#FBE7E6',
    /** 8.72:1 on white */
    info: '#1D4E77',
    infoTint: '#E3EDF5',
  },

  /** Borders vs surface.base — default 3.10:1, strong 5.01:1, focus 5.69:1 (SC 1.4.11) */
  border: {
    default: '#8494A8',
    strong: '#61708A',
    focus: '#0B63CE',
  },
} as const;

/** 4px base scale. */
export const space = {
  none: '0',
  xs: '0.25rem',
  sm: '0.5rem',
  md: '1rem',
  lg: '1.5rem',
  xl: '2rem',
  '2xl': '3rem',
  '3xl': '4rem',
} as const;

/**
 * Minimum interactive target size.
 *
 * WCAG 2.2 SC 2.5.8 (Target Size, Minimum) requires 24x24 CSS px at Level AA.
 * The team standard is 44x44 — larger targets reduce mis-taps, which matters
 * for the ADHD design lean, and 10px of slop is cheaper than an undo flow.
 */
export const target = {
  wcagMinimum: '24px',
  teamMinimum: '44px',
} as const;

export const typography = {
  fontFamily: {
    sans: "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
  },
  /** Body text is never smaller than 16px — no small print in this product. */
  size: {
    body: '1rem',
    bodyLarge: '1.125rem',
    heading: '1.5rem',
    headingLarge: '2rem',
    display: '2.5rem',
  },
  weight: {
    regular: '400',
    medium: '500',
    bold: '700',
  },
  /** Generous line height aids tracking for readers who lose their place. */
  lineHeight: {
    tight: '1.25',
    normal: '1.5',
    relaxed: '1.7',
  },
} as const;

export const radius = {
  sm: '0.25rem',
  md: '0.5rem',
  lg: '0.75rem',
  full: '9999px',
} as const;

/**
 * Motion. Every duration here must be wrapped in a `prefers-reduced-motion`
 * guard at the point of use — the accessibility requirements forbid
 * unnecessary animation outright.
 */
export const motion = {
  duration: {
    instant: '0ms',
    fast: '120ms',
    normal: '200ms',
  },
  easing: {
    standard: 'cubic-bezier(0.2, 0, 0, 1)',
  },
} as const;

/** Focus ring — must remain visible against every surface (SC 2.4.7, 2.4.11). */
export const focusRing = {
  width: '3px',
  offset: '2px',
  color: color.border.focus,
} as const;

export const tokens = {
  color,
  space,
  target,
  typography,
  radius,
  motion,
  focusRing,
} as const;

export type Tokens = typeof tokens;
