/**
 * Pure routing guard, kept free of React Navigation so it is trivially
 * unit-tested.
 *
 * - Signed out -> everything goes to `/sign-in`.
 * - Signed in -> `/sign-in` and `/` go to the role's home.
 * - A care recipient cannot land on caregiver screens, and vice versa.
 *
 * `RootNavigator` enforces the same policy structurally (it swaps the whole
 * navigator tree on `session`), so this function documents and unit-tests
 * the policy rather than being wired into a URL-based guard the way
 * go_router's `redirect` callback is in the Dart port.
 *
 * Port of lib/router/redirects.dart.
 */
import { roleHomeLocation, roleRoutePrefix } from '../models/types';
import type { Session, UserRole } from '../models/types';

const SIGN_IN = '/sign-in';

export function resolveRedirect({
  session,
  location,
}: {
  session: Session | null;
  location: string;
}): string | null {
  if (session == null) {
    return location === SIGN_IN ? null : SIGN_IN;
  }
  const home = roleHomeLocation(session.role);
  if (location === SIGN_IN || location === '/' || location === '') {
    return home;
  }
  const otherRole: UserRole = session.role === 'caregiver' ? 'careRecipient' : 'caregiver';
  if (location.startsWith(roleRoutePrefix(otherRole))) {
    return home;
  }
  return null;
}
