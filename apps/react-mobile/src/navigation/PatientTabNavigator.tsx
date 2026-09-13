import React from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

import { useTheme } from '../core/theme/ThemeContext';
import { AppointmentsScreen } from '../screens/patient/AppointmentsScreen';
import { TodayScreen } from '../screens/patient/TodayScreen';
import { MedicationsStackNavigator } from './MedicationsStackNavigator';
import { SettingsStackNavigator } from './SettingsStackNavigator';
import type { PatientTabParamList } from './types';

const Tab = createBottomTabNavigator<PatientTabParamList>();

/**
 * Bottom tab navigation for the care recipient: Today, Medications,
 * Appointments, Settings. Labels are always shown — icons alone are a
 * memory test. Port of lib/features/patient/patient_shell.dart.
 */
export function PatientTabNavigator() {
  const theme = useTheme();

  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: theme.primary,
        tabBarInactiveTintColor: theme.colors.textSecondary,
        tabBarLabelStyle: { fontWeight: '600' },
      }}
    >
      <Tab.Screen
        name="Today"
        component={TodayScreen}
        options={{
          tabBarIcon: ({ color, size }) => <MaterialIcons name="today" color={color} size={size} />,
        }}
      />
      <Tab.Screen
        name="MedicationsStack"
        component={MedicationsStackNavigator}
        options={{
          title: 'Medications',
          tabBarIcon: ({ color, size }) => (
            <MaterialIcons name="local-pharmacy" color={color} size={size} />
          ),
        }}
        listeners={({ navigation }) => ({
          tabPress: (e) => {
            // Re-tapping the current tab returns to its first screen, same
            // as go_router's `initialLocation: true` on a repeat tab press.
            if (navigation.isFocused()) {
              e.preventDefault();
              navigation.navigate('MedicationsStack', { screen: 'Medications' });
            }
          },
        })}
      />
      <Tab.Screen
        name="Appointments"
        component={AppointmentsScreen}
        options={{
          tabBarIcon: ({ color, size }) => <MaterialIcons name="event" color={color} size={size} />,
        }}
      />
      <Tab.Screen
        name="SettingsStack"
        component={SettingsStackNavigator}
        options={{
          title: 'Settings',
          tabBarIcon: ({ color, size }) => <MaterialIcons name="settings" color={color} size={size} />,
        }}
        listeners={({ navigation }) => ({
          tabPress: (e) => {
            if (navigation.isFocused()) {
              e.preventDefault();
              navigation.navigate('SettingsStack', { screen: 'Settings' });
            }
          },
        })}
      />
    </Tab.Navigator>
  );
}
