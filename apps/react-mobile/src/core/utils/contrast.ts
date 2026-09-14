/**
 * WCAG 2.x relative luminance and contrast-ratio maths.
 *
 * This is the same formula the design document used to compute every ratio
 * in its colour tables, and the same one the web workspace's `check:contrast`
 * script runs in CI. Keeping it in the app means the token file is verified
 * by a unit test rather than by eye.
 *
 * Reference: https://www.w3.org/TR/WCAG22/#dfn-relative-luminance
 *
 * Port of lib/core/utils/contrast.dart.
 */

/** Parses a "#RRGGBB" or "#RGB" hex string into 0-1 range channels. */
export function parseHexColor(hex: string): { r: number; g: number; b: number } {
  let value = hex.trim().replace(/^#/, '');
  if (value.length === 3) {
    value = value
      .split('')
      .map((c) => c + c)
      .join('');
  }
  if (value.length !== 6) {
    throw new Error(`Invalid hex color: "${hex}"`);
  }
  const r = parseInt(value.slice(0, 2), 16) / 255;
  const g = parseInt(value.slice(2, 4), 16) / 255;
  const b = parseInt(value.slice(4, 6), 16) / 255;
  return { r, g, b };
}

function linearise(channel: number): number {
  return channel <= 0.03928 ? channel / 12.92 : Math.pow((channel + 0.055) / 1.055, 2.4);
}

/** Relative luminance of a colour in the range 0 (black) to 1 (white). */
export function relativeLuminance(hex: string): number {
  const { r, g, b } = parseHexColor(hex);
  return 0.2126 * linearise(r) + 0.7152 * linearise(g) + 0.0722 * linearise(b);
}

/** Contrast ratio between two colours, from 1:1 to 21:1. */
export function contrastRatio(a: string, b: string): number {
  const la = relativeLuminance(a);
  const lb = relativeLuminance(b);
  const lighter = Math.max(la, lb);
  const darker = Math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

/**
 * Whether `foreground` on `background` meets WCAG 2.2 AA.
 *
 * Normal text needs 4.5:1. Large text (>= 18pt regular or >= 14pt bold) and
 * non-text UI elements such as icons, focus rings and control borders need
 * 3:1 (SC 1.4.3 and SC 1.4.11).
 */
export function meetsAa(
  foreground: string,
  background: string,
  options: { largeTextOrUi?: boolean } = {},
): boolean {
  const ratio = contrastRatio(foreground, background);
  return ratio >= (options.largeTextOrUi ? 3.0 : 4.5);
}
