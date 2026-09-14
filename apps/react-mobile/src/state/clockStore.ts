/**
 * "Now", refreshed every 30 seconds so "Due in 20 min" stays honest without
 * re-rendering on every tick. When the demo clock setting is on, time is
 * frozen at `kDemoInstant`.
 *
 * Port of lib/state/clock_provider.dart.
 */
import { create } from 'zustand';

import { Clock, FixedClock, kDemoInstant, SystemClock } from '../core/utils/clock';
import { useSettingsStore } from './settingsStore';

interface ClockState {
  clock: Clock;
  now: Date;
  /** Overrides the wall clock (tests use a FixedClock for deterministic time). */
  setClock: (clock: Clock) => void;
  /** Re-reads the clock immediately (used after returning to the app). */
  refresh: () => void;
}

export const useClockStore = create<ClockState>((set, get) => ({
  clock: new SystemClock(),
  now: new SystemClock().now(),
  setClock: (clock) => {
    set({ clock });
    get().refresh();
  },
  refresh: () => {
    const demo = useSettingsStore.getState().demoClock;
    const { clock } = get();
    set({ now: demo ? kDemoInstant : clock.now() });
  },
}));

// The demo-clock toggle should take effect immediately, the same way
// Riverpod's `ref.watch(appSettingsProvider.select((s) => s.demoClock))`
// rebuilds `CurrentTime` the instant the setting changes.
useSettingsStore.subscribe((state, prevState) => {
  if (state.demoClock !== prevState.demoClock) {
    useClockStore.getState().refresh();
  }
});

let ticker: ReturnType<typeof setInterval> | null = null;

/**
 * Starts the 30-second wall-clock tick. A `FixedClock` never changes, so
 * there is nothing to tick — and no timer left pending at the end of a test.
 */
export function startClockTicking(): void {
  if (ticker != null) return;
  ticker = setInterval(() => {
    const { clock } = useClockStore.getState();
    if (clock instanceof FixedClock) return;
    useClockStore.getState().refresh();
  }, 30_000);
}

export function stopClockTicking(): void {
  if (ticker != null) clearInterval(ticker);
  ticker = null;
}
