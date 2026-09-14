/**
 * The selected Activity Timeline filter, kept across tab switches (but not
 * persisted to disk — matching the in-memory-only Riverpod notifier in
 * lib/features/caregiver/activity_timeline_screen.dart).
 */
import { create } from 'zustand';

import type { ActivityFilter } from './selectors';

interface ActivityFilterState {
  filter: ActivityFilter;
  setFilter: (filter: ActivityFilter) => void;
}

export const useActivityFilterStore = create<ActivityFilterState>((set) => ({
  filter: 'all',
  setFilter: (filter) => set({ filter }),
}));
