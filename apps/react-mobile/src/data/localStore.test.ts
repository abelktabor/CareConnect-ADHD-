import AsyncStorage from '@react-native-async-storage/async-storage';

import { contains, readAs, readJson, remove, StoreKeys, writeJson } from './localStore';

beforeEach(async () => {
  await AsyncStorage.clear();
});

describe('writeJson / readJson', () => {
  it('round-trips a plain object', async () => {
    await writeJson(StoreKeys.settings, { demoClock: true, themeMode: 'dark' });
    expect(await readJson(StoreKeys.settings)).toEqual({ demoClock: true, themeMode: 'dark' });
  });

  it('returns null when nothing is stored', async () => {
    expect(await readJson('missing-key')).toBeNull();
  });

  it('returns null for corrupt JSON rather than throwing', async () => {
    await AsyncStorage.setItem(StoreKeys.settings, '{not valid json');
    expect(await readJson(StoreKeys.settings)).toBeNull();
  });

  it('returns null when the stored value is not a JSON object', async () => {
    await AsyncStorage.setItem(StoreKeys.settings, JSON.stringify([1, 2, 3]));
    expect(await readJson(StoreKeys.settings)).toBeNull();
  });
});

describe('readAs', () => {
  const fromJson = (json: Record<string, unknown>) => ({ n: json.n as number });

  it('rebuilds a typed value from storage', async () => {
    await writeJson('k', { n: 5 });
    const value = await readAs('k', fromJson, () => ({ n: 0 }));
    expect(value).toEqual({ n: 5 });
  });

  it('falls back when nothing is stored', async () => {
    const value = await readAs('missing', fromJson, () => ({ n: -1 }));
    expect(value).toEqual({ n: -1 });
  });

  it('falls back and discards the entry when fromJson throws', async () => {
    await writeJson('k', { wrong: 'shape' });
    const throwing = () => {
      throw new Error('bad shape');
    };
    const value = await readAs('k', throwing, () => ({ n: -1 }));
    expect(value).toEqual({ n: -1 });
    expect(await contains('k')).toBe(false);
  });
});

describe('remove / contains', () => {
  it('reports presence and absence', async () => {
    expect(await contains(StoreKeys.session)).toBe(false);
    await writeJson(StoreKeys.session, { role: 'caregiver' });
    expect(await contains(StoreKeys.session)).toBe(true);
    await remove(StoreKeys.session);
    expect(await contains(StoreKeys.session)).toBe(false);
  });
});
