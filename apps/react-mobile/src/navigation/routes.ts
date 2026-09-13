/**
 * Route paths, kept in one place for deep links and tests — mirrors
 * lib/router/app_router.dart's `Routes` class. React Navigation's actual
 * screen names (used by `navigation.navigate(...)`) live alongside each
 * navigator; these path strings back the `linking` config in
 * RootNavigator.tsx and the `resolveRedirect` unit tests.
 */
export const Routes = {
  signIn: '/sign-in',
  today: '/patient/today',
  medications: '/patient/medications',
  appointments: '/patient/appointments',
  settings: '/patient/settings',
  dashboard: '/caregiver/dashboard',
  manage: '/caregiver/manage',
  activity: '/caregiver/activity',
  caregiverSettings: '/caregiver/settings',
  newMedication: '/medications/new',
  newAppointment: '/appointments/new',
} as const;
