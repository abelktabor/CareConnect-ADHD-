/// An injectable source of "now".
///
/// Everything time-dependent (dose status, "Due in 20 min", the orientation
/// bar) reads the clock through Riverpod rather than calling `DateTime.now()`
/// directly, so tests and the in-app demo mode can freeze time.
abstract class Clock {
  DateTime now();
}

/// Wall-clock time.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// A clock frozen at a fixed instant.
class FixedClock implements Clock {
  const FixedClock(this.instant);

  /// Convenience for tests: `FixedClock.at(2026, 8, 25, 14, 14)`.
  factory FixedClock.at(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
  ]) => FixedClock(DateTime(year, month, day, hour, minute));

  final DateTime instant;

  @override
  DateTime now() => instant;
}

/// The moment every Week 3 Figma frame is drawn at: Tuesday, August 25 at
/// 2:14 PM. Switching the app's demo clock on reproduces those frames exactly.
final DateTime kDemoInstant = DateTime(2026, 8, 25, 14, 14);
