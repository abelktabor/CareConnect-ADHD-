/**
 * General app preferences (App Settings screen).
 *
 * Port of lib/state/settings_provider.dart.
 */
import { create } from 'zustand';

import { StoreKeys, writeJson } from '../data/localStore';
import { appSettingsToJson, defaultAppSettings } from '../models/serialization';
import type { AppSettings, ThemeModePreference } from '../models/types';

interface SettingsState extends AppSettings {
  hydrated: boolean;
  hydrate: (settings: AppSettings) => void;
  setThemeMode: (mode: ThemeModePreference) => Promise<void>;
  setDemoClock: (enabled: boolean) => Promise<void>;
  setShareWithCaregiver: (enabled: boolean) => Promise<void>;
}

export const useSettingsStore = create<SettingsState>((set, get) => ({
  ...defaultAppSettings(),
  hydrated: false,
  hydrate: (settings) => set({ ...settings, hydrated: true }),
  setThemeMode: async (themeMode) => {
    set({ themeMode });
    await persist(get());
  },
  setDemoClock: async (demoClock) => {
    set({ demoClock });
    await persist(get());
  },
  setShareWithCaregiver: async (shareWithCaregiver) => {
    set({ shareWithCaregiver });
    await persist(get());
  },
}));

async function persist(state: SettingsState): Promise<void> {
  await writeJson(
    StoreKeys.settings,
    appSettingsToJson({
      themeMode: state.themeMode,
      demoClock: state.demoClock,
      shareWithCaregiver: state.shareWithCaregiver,
    }),
  );
}
