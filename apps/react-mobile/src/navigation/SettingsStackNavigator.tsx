import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

import { AppSettingsScreen } from '../screens/settings/AppSettingsScreen';
import { CaregiverAccessScreen } from '../screens/settings/CaregiverAccessScreen';
import { NotificationsSettingsScreen } from '../screens/settings/NotificationsSettingsScreen';
import { SettingsScreen } from '../screens/settings/SettingsScreen';
import type { SettingsStackParamList } from './types';

const Stack = createNativeStackNavigator<SettingsStackParamList>();

/**
 * Settings and its three sub-pages, shared by both role tab trees (mirrors
 * the Dart port's `/patient/settings/...` and `/caregiver/settings/...`
 * sharing the same `SettingsScreen`, `NotificationsSettingsScreen` and
 * `AppSettingsScreen` widgets). `SettingsScreen` itself decides whether to
 * show the "My Caregiver Access" row based on the signed-in role.
 */
export function SettingsStackNavigator() {
  return (
    <Stack.Navigator
      initialRouteName="Settings"
      screenOptions={{ headerShown: false, animation: 'slide_from_right' }}
    >
      <Stack.Screen name="Settings" component={SettingsScreen} />
      <Stack.Screen name="Notifications" component={NotificationsSettingsScreen} />
      <Stack.Screen name="CaregiverAccess" component={CaregiverAccessScreen} />
      <Stack.Screen name="AppSettings" component={AppSettingsScreen} />
    </Stack.Navigator>
  );
}
