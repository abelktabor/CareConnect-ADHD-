import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// WCAG 2.x relative luminance and contrast-ratio maths.
///
/// This is the same formula the design document used to compute every ratio in
/// its colour tables, and the same one the web workspace's `check:contrast`
/// script runs in CI. Keeping it in the app means the token file is verified by
/// a unit test rather than by eye.
///
/// Reference: https://www.w3.org/TR/WCAG22/#dfn-relative-luminance
double _linearise(double channel) {
  return channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}

/// Relative luminance of [color] in the range 0 (black) to 1 (white).
double relativeLuminance(Color color) {
  final r = _linearise(color.r);
  final g = _linearise(color.g);
  final b = _linearise(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Contrast ratio between two colours, from 1:1 to 21:1.
double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Whether [foreground] on [background] meets WCAG 2.2 AA.
///
/// Normal text needs 4.5:1. Large text (≥ 18pt regular or ≥ 14pt bold) and
/// non-text UI elements such as icons, focus rings and control borders need
/// 3:1 (SC 1.4.3 and SC 1.4.11).
bool meetsAa(Color foreground, Color background, {bool largeTextOrUi = false}) {
  final ratio = contrastRatio(foreground, background);
  return ratio >= (largeTextOrUi ? 3.0 : 4.5);
}
