/**
 * An injectable source of "now".
 *
 * Everything time-dependent (dose status, "Due in 20 min", the orientation
 * bar) reads the clock through the Zustand clock store rather than calling
 * `new Date()` directly, so tests and the in-app demo mode can freeze time.
 *
 * Port of lib/core/utils/clock.dart.
 */
export interface Clock {
  now(): Date;
}

/** Wall-clock time. */
export class SystemClock implements Clock {
  now(): Date {
    return new Date();
  }
}

/** A clock frozen at a fixed instant. */
export class FixedClock implements Clock {
  constructor(private readonly instant: Date) {}

  /** Convenience for tests: `FixedClock.at(2026, 8, 25, 14, 14)` (1-indexed month, like the Dart port). */
  static at(year: number, month = 1, day = 1, hour = 0, minute = 0): FixedClock {
    return new FixedClock(new Date(year, month - 1, day, hour, minute));
  }

  now(): Date {
    return this.instant;
  }
}

/**
 * The moment every Week 3 Figma frame is drawn at: Tuesday, August 25 at
 * 2:14 PM. Switching the app's demo clock on reproduces those frames exactly.
 */
export const kDemoInstant: Date = new Date(2026, 7, 25, 14, 14);
