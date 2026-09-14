/**
 * Signed-in state. `session` is null until the sign-in screen completes.
 *
 * There is no real authentication this term; the point of the screen is the
 * accessible pattern (passkey first, email second, no password) and the role
 * choice that drives the rest of the app.
 *
 * Port of lib/state/session_provider.dart.
 */
import { create } from 'zustand';

import { remove, StoreKeys, writeJson } from '../data/localStore';
import { sessionToJson } from '../models/serialization';
import type { Session, SignInMethod, UserRole } from '../models/types';
import { useClockStore } from './clockStore';

interface SessionState {
  session: Session | null;
  hydrated: boolean;
  hydrate: (session: Session | null) => void;
  signIn: (params: { role: UserRole; method: SignInMethod; email?: string }) => Promise<void>;
  signOut: () => Promise<void>;
}

export const useSessionStore = create<SessionState>((set) => ({
  session: null,
  hydrated: false,
  hydrate: (session) => set({ session, hydrated: true }),
  signIn: async ({ role, method, email }) => {
    const trimmed = email?.trim();
    const session: Session = {
      role,
      method,
      signedInAt: useClockStore.getState().now,
      email: trimmed && trimmed.length > 0 ? trimmed : null,
    };
    set({ session });
    await writeJson(StoreKeys.session, sessionToJson(session));
  },
  signOut: async () => {
    set({ session: null });
    await remove(StoreKeys.session);
  },
}));

/**
 * The signed-in role, defaulting to care recipient before sign-in so the
 * sign-in screen itself is themed in the care-recipient teal.
 */
export function useCurrentRole(): UserRole {
  return useSessionStore((s) => s.session?.role ?? 'careRecipient');
}
