import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

import { MedicationDetailScreen } from '../screens/medications/MedicationDetailScreen';
import { ManageScreen } from '../screens/caregiver/ManageScreen';
import type { ManageStackParamList } from './types';

const Stack = createNativeStackNavigator<ManageStackParamList>();

/** Caregiver Manage tab: the medications/appointments overview, then a detail push. */
export function ManageStackNavigator() {
  return (
    <Stack.Navigator
      initialRouteName="Manage"
      screenOptions={{ headerShown: false, animation: 'slide_from_right' }}
    >
      <Stack.Screen name="Manage" component={ManageScreen} />
      <Stack.Screen name="MedicationDetail" component={MedicationDetailScreen} />
    </Stack.Navigator>
  );
}
