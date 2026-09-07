/**
 * Verifies every documented color pair still meets its WCAG 2.2 AA threshold.
 * Run with `npm run check:contrast`. Exits non-zero on failure so CI can gate.
 */
import { color } from '../src/index.ts';

const luminance = (hex) => {
  const h = hex.replace('#', '');
  const chan = [0, 2, 4]
    .map((i) => parseInt(h.slice(i, i + 2), 16) / 255)
    .map((v) => (v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
  return 0.2126 * chan[0] + 0.7152 * chan[1] + 0.0722 * chan[2];
};

const ratio = (a, b) => {
  const [la, lb] = [luminance(a), luminance(b)];
  return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
};

const WHITE = color.surface.base;

// [label, foreground, background, minimum]
// 4.5 = SC 1.4.3 normal text · 3.0 = SC 1.4.11 UI components and large text
const PAIRS = [
  ['text.primary', color.text.primary, WHITE, 4.5],
  ['text.secondary', color.text.secondary, WHITE, 4.5],
  ['text.muted', color.text.muted, WHITE, 4.5],
  ['text.inverse on inverse', color.text.inverse, color.surface.inverse, 4.5],
  ['primary.default', color.primary.default, WHITE, 4.5],
  ['status.success', color.status.success, WHITE, 4.5],
  ['status.warning', color.status.warning, WHITE, 4.5],
  ['status.danger', color.status.danger, WHITE, 4.5],
  ['status.info', color.status.info, WHITE, 4.5],
  ['border.default', color.border.default, WHITE, 3.0],
  ['border.strong', color.border.strong, WHITE, 3.0],
  ['border.focus', color.border.focus, WHITE, 3.0],
];

let failures = 0;
for (const [label, fg, bg, min] of PAIRS) {
  const r = ratio(fg, bg);
  const ok = r >= min;
  if (!ok) failures += 1;
  console.log(
    `${ok ? 'PASS' : 'FAIL'}  ${label.padEnd(26)} ${r.toFixed(2)}:1  (min ${min}:1)`,
  );
}

if (failures > 0) {
  console.error(`\n${failures} contrast pair(s) below the WCAG 2.2 AA threshold.`);
  process.exit(1);
}
console.log('\nAll contrast pairs meet WCAG 2.2 AA.');
