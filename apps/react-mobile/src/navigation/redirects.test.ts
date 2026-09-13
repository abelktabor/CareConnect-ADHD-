import { resolveRedirect } from './redirects';
import type { Session } from '../models/types';

const patientSession: Session = {
  role: 'careRecipient',
  method: 'passkey',
  signedInAt: new Date(2026, 7, 25),
};

const caregiverSession: Session = {
  role: 'caregiver',
  method: 'email',
  signedInAt: new Date(2026, 7, 25),
  email: 'renee@example.test',
};

describe('resolveRedirect', () => {
  it('sends a signed-out user anywhere to sign-in', () => {
    expect(resolveRedirect({ session: null, location: '/patient/today' })).toBe('/sign-in');
    expect(resolveRedirect({ session: null, location: '/' })).toBe('/sign-in');
  });

  it('allows a signed-out user to stay on sign-in', () => {
    expect(resolveRedirect({ session: null, location: '/sign-in' })).toBeNull();
  });

  it('sends a signed-in user away from sign-in and the root to their home', () => {
    expect(resolveRedirect({ session: patientSession, location: '/sign-in' })).toBe(
      '/patient/today',
    );
    expect(resolveRedirect({ session: patientSession, location: '/' })).toBe('/patient/today');
    expect(resolveRedirect({ session: caregiverSession, location: '' })).toBe(
      '/caregiver/dashboard',
    );
  });

  it('keeps a care recipient off caregiver screens', () => {
    expect(resolveRedirect({ session: patientSession, location: '/caregiver/dashboard' })).toBe(
      '/patient/today',
    );
  });

  it('keeps a caregiver off care-recipient screens', () => {
    expect(resolveRedirect({ session: caregiverSession, location: '/patient/medications' })).toBe(
      '/caregiver/dashboard',
    );
  });

  it('allows a signed-in user to stay on their own role\'s screens', () => {
    expect(resolveRedirect({ session: patientSession, location: '/patient/medications' })).toBeNull();
    expect(resolveRedirect({ session: caregiverSession, location: '/caregiver/manage' })).toBeNull();
  });

  it('allows a signed-in user on a shared, role-agnostic path', () => {
    expect(resolveRedirect({ session: patientSession, location: '/medications/new' })).toBeNull();
  });
});
