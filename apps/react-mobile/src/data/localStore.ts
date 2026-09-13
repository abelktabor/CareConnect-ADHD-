/**
 * Thin JSON layer over AsyncStorage.
 *
 * Every store persists through this module, so persistence is one mockable
 * seam: unit tests use `@react-native-async-storage/async-storage/jest/async-storage-mock`
 * (wired up in jest.setup.js).
 *
 * Port of lib/data/local_store.dart.
 */
import AsyncStorage from '@react-native-async-storage/async-storage';

/** Storage keys, in one place so tests and stores cannot drift apart. */
export const StoreKeys = {
  session: 'cc.session',
  settings: 'cc.settings',
  notifications: 'cc.notifications',
  careData: 'cc.careData',
  medicationDraft: 'cc.draft.medication',
  appointmentDraft: 'cc.draft.appointment',
} as const;

export async function readJson(key: string): Promise<Record<string, unknown> | null> {
  const raw = await AsyncStorage.getItem(key);
  if (raw === null || raw.length === 0) return null;
  try {
    const decoded = JSON.parse(raw);
    return decoded !== null && typeof decoded === 'object' && !Array.isArray(decoded)
      ? (decoded as Record<string, unknown>)
      : null;
  } catch {
    // Corrupt entry: treat as absent rather than crashing at start-up.
    return null;
  }
}

/**
 * Reads a stored document and rebuilds it with `fromJson`, falling back to
 * `orElse` if the entry is missing, corrupt, or the wrong shape.
 *
 * Deserialisation is the one place untrusted-shaped data crosses into the
 * domain model: the JSON is valid but its fields may be missing or of the
 * wrong type (a truncated write, an app-update migration artefact, or an
 * edited storage file on a rooted device). Letting that throw during store
 * hydration would leave the app unable to start at all, so it fails closed
 * to a known-good value instead (NIST SSDF PW.5.1 — fail securely; error
 * handling must not deny service).
 */
export async function readAs<T>(
  key: string,
  fromJson: (json: Record<string, unknown>) => T,
  orElse: () => T,
): Promise<T> {
  const json = await readJson(key);
  if (json === null) return orElse();
  try {
    return fromJson(json);
  } catch {
    // Any malformed document is discarded, not partially trusted.
    await remove(key);
    return orElse();
  }
}

export async function writeJson(key: string, value: Record<string, unknown>): Promise<void> {
  await AsyncStorage.setItem(key, JSON.stringify(value));
}

export async function remove(key: string): Promise<void> {
  await AsyncStorage.removeItem(key);
}

export async function contains(key: string): Promise<boolean> {
  const raw = await AsyncStorage.getItem(key);
  return raw !== null;
}
