/// Layout constants shared across screens and widgets.
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class CcRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
}

/// Minimum interactive target sizes.
///
/// WCAG 2.2 SC 2.5.8 requires 24×24 CSS px at Level AA. The design treats
/// 44×44pt (the iOS HIG minimum) as the floor for every control and 48×48 for
/// icon buttons, so one shared component clears both platforms' guidelines.
abstract final class TapTarget {
  static const double minimum = 44;
  static const double icon = 48;

  /// The single dominant next-action button is taller than the minimum on
  /// purpose — it is the one thing a user with ADHD should not have to hunt for.
  static const double dominantAction = 56;
}

/// Responsive breakpoints. Anything at or above [tablet] gets the two-column
/// layouts from the "Tablet" and "Landscape" Figma frames.
abstract final class Breakpoints {
  static const double tablet = 600;
  static const double contentMaxWidth = 840;
  static const double formMaxWidth = 560;
}
