import AsyncStorage from '@react-native-async-storage/async-storage';

import { StoreKeys } from '../data/localStore';
import { defaultAppSettings, defaultNotificationSettings } from '../models/serialization';
import { FixedClock } from '../core/utils/clock';
import { useClockStore } from './clockStore';
import { useNotificationSettingsStore } from './notificationSettingsStore';
import { useSessionStore } from './sessionStore';
import { useSettingsStore } from './settingsStore';

beforeEach(async () => {
  await AsyncStorage.clear();
  useSessionStore.setState({ session: null, hydrated: true });
  useSettingsStore.setState({ ...defaultAppSettings(), hydrated: true });
  useNotificationSettingsStore.setState({ ...defaultNotificationSettings(), hydrated: true });
  useClockStore.getState().setClock(new FixedClock(new Date(2026, 7, 25, 9, 0)));
});

describe('sessionStore', () => {
  it('signs in with a trimmed email and persists the session', async () => {
    await useSessionStore.getState().signIn({
      role: 'careRecipient',
      method: 'email',
      email: '  muhammad@example.test  ',
    });
    const session = useSessionStore.getState().session!;
    expect(session.role).toBe('careRecipient');
    expect(session.email).toBe('muhammad@example.test');
    expect(session.signedInAt).toEqual(new Date(2026, 7, 25, 9, 0));

    const stored = await AsyncStorage.getItem(StoreKeys.session);
    expect(JSON.parse(stored!).role).toBe('careRecipient');
  });

  it('stores a null email for a passkey sign-in', async () => {
    await useSessionStore.getState().signIn({ role: 'caregiver', method: 'passkey' });
    expect(useSessionStore.getState().session?.email).toBeNull();
    expect(useSessionStore.getState().session?.method).toBe('passkey');
  });

  it('signs out and clears storage', async () => {
    await useSessionStore.getState().signIn({ role: 'caregiver', method: 'passkey' });
    await useSessionStore.getState().signOut();
    expect(useSessionStore.getState().session).toBeNull();
    expect(await AsyncStorage.getItem(StoreKeys.session)).toBeNull();
  });
});

describe('settingsStore', () => {
  it('updates and persists theme mode', async () => {
    await useSettingsStore.getState().setThemeMode('dark');
    expect(useSettingsStore.getState().themeMode).toBe('dark');
    const stored = await AsyncStorage.getItem(StoreKeys.settings);
    expect(JSON.parse(stored!).themeMode).toBe('dark');
  });

  it('toggling the demo clock refreshes the clock store', async () => {
    expect(useClockStore.getState().now).toEqual(new Date(2026, 7, 25, 9, 0));
    await useSettingsStore.getState().setDemoClock(true);
    expect(useClockStore.getState().now).toEqual(new Date(2026, 7, 25, 14, 14));
    await useSettingsStore.getState().setDemoClock(false);
    expect(useClockStore.getState().now).toEqual(new Date(2026, 7, 25, 9, 0));
  });

  it('updates caregiver sharing', async () => {
    await useSettingsStore.getState().setShareWithCaregiver(false);
    expect(useSettingsStore.getState().shareWithCaregiver).toBe(false);
  });
});

describe('notificationSettingsStore', () => {
  it('updates and persists the daily digest and lead time', async () => {
    await useNotificationSettingsStore.getState().setDailyDigest(false);
    await useNotificationSettingsStore.getState().setLeadTime('oneDay');
    expect(useNotificationSettingsStore.getState().dailyDigest).toBe(false);
    expect(useNotificationSettingsStore.getState().leadTime).toBe('oneDay');
    const stored = await AsyncStorage.getItem(StoreKeys.notifications);
    expect(JSON.parse(stored!)).toEqual({ dailyDigest: false, leadTime: 'oneDay' });
  });
});
