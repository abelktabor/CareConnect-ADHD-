/**
 * React Navigation param lists for every navigator in the app. Kept in one
 * file so a screen can import exactly the list it needs without reaching
 * into a sibling navigator's file.
 */
import type { NavigatorScreenParams } from '@react-navigation/native';

export type MedicationsStackParamList = {
  Medications: undefined;
  MedicationDetail: { medicationId: string };
};

export type ManageStackParamList = {
  Manage: undefined;
  MedicationDetail: { medicationId: string };
};

/**
 * Shared by both role tab trees. `CaregiverAccess` is only ever linked to
 * from the care-recipient's `SettingsScreen`, but registering it in both
 * stacks keeps this one param list usable everywhere (mirrors the Dart
 * port, where `SettingsScreen` itself hides the row rather than the route
 * tree omitting it).
 */
export type SettingsStackParamList = {
  Settings: undefined;
  Notifications: undefined;
  CaregiverAccess: undefined;
  AppSettings: undefined;
};

export type PatientTabParamList = {
  Today: undefined;
  MedicationsStack: NavigatorScreenParams<MedicationsStackParamList>;
  Appointments: undefined;
  SettingsStack: NavigatorScreenParams<SettingsStackParamList>;
};

export type CaregiverTabParamList = {
  Dashboard: undefined;
  ManageStack: NavigatorScreenParams<ManageStackParamList>;
  Activity: undefined;
  SettingsStack: NavigatorScreenParams<SettingsStackParamList>;
};

/**
 * Root stack. `MedicationForm` and `AppointmentForm` are registered here
 * (not inside either tab tree) so they present as full-screen modals that
 * cover the bottom tab bar — the equivalent of go_router's
 * `parentNavigatorKey: rootNavigatorKey` full-screen routes.
 */
export type RootStackParamList = {
  SignIn: undefined;
  PatientTabs: undefined;
  CaregiverTabs: undefined;
  MedicationForm: { editingId?: string } | undefined;
  AppointmentForm: { editingId?: string } | undefined;
};
