import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

import { MedicationDetailScreen } from '../screens/medications/MedicationDetailScreen';
import { MedicationsScreen } from '../screens/medications/MedicationsScreen';
import type { MedicationsStackParamList } from './types';

const Stack = createNativeStackNavigator<MedicationsStackParamList>();

/** Care-recipient Medications tab: the list, then a detail push. */
export function MedicationsStackNavigator() {
  return (
    <Stack.Navigator
      initialRouteName="Medications"
      screenOptions={{ headerShown: false, animation: 'slide_from_right' }}
    >
      <Stack.Screen name="Medications" component={MedicationsScreen} />
      <Stack.Screen name="MedicationDetail" component={MedicationDetailScreen} />
    </Stack.Navigator>
  );
}
