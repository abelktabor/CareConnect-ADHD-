/**
 * User-controlled reminder preferences (Notifications screen).
 *
 * Port of lib/state/notification_settings_provider.dart.
 */
import { create } from 'zustand';

import { StoreKeys, writeJson } from '../data/localStore';
import { defaultNotificationSettings, notificationSettingsToJson } from '../models/serialization';
import type { NotificationSettings, ReminderLeadTime } from '../models/types';

interface NotificationSettingsState extends NotificationSettings {
  hydrated: boolean;
  hydrate: (settings: NotificationSettings) => void;
  setDailyDigest: (enabled: boolean) => Promise<void>;
  setLeadTime: (leadTime: ReminderLeadTime) => Promise<void>;
}

export const useNotificationSettingsStore = create<NotificationSettingsState>((set, get) => ({
  ...defaultNotificationSettings(),
  hydrated: false,
  hydrate: (settings) => set({ ...settings, hydrated: true }),
  setDailyDigest: async (dailyDigest) => {
    set({ dailyDigest });
    await persist(get());
  },
  setLeadTime: async (leadTime) => {
    set({ leadTime });
    await persist(get());
  },
}));

async function persist(state: NotificationSettingsState): Promise<void> {
  await writeJson(
    StoreKeys.notifications,
    notificationSettingsToJson({ dailyDigest: state.dailyDigest, leadTime: state.leadTime }),
  );
}
