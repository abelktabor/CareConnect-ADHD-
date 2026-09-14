import React from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

import { useTheme } from '../core/theme/ThemeContext';
import { ActivityTimelineScreen } from '../screens/caregiver/ActivityTimelineScreen';
import { CaregiverDashboardScreen } from '../screens/caregiver/CaregiverDashboardScreen';
import { ManageStackNavigator } from './ManageStackNavigator';
import { SettingsStackNavigator } from './SettingsStackNavigator';
import type { CaregiverTabParamList } from './types';

const Tab = createBottomTabNavigator<CaregiverTabParamList>();

/**
 * Bottom tab navigation for the caregiver: Dashboard, Manage, Activity,
 * Settings. Same positions and behaviour as the care-recipient shell, in
 * the Dusk Violet accent. Port of lib/features/caregiver/caregiver_shell.dart.
 */
export function CaregiverTabNavigator() {
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
        name="Dashboard"
        component={CaregiverDashboardScreen}
        options={{
          tabBarIcon: ({ color, size }) => <MaterialIcons name="dashboard" color={color} size={size} />,
        }}
      />
      <Tab.Screen
        name="ManageStack"
        component={ManageStackNavigator}
        options={{
          title: 'Manage',
          tabBarIcon: ({ color, size }) => <MaterialIcons name="edit" color={color} size={size} />,
        }}
        listeners={({ navigation }) => ({
          tabPress: (e) => {
            if (navigation.isFocused()) {
              e.preventDefault();
              navigation.navigate('ManageStack', { screen: 'Manage' });
            }
          },
        })}
      />
      <Tab.Screen
        name="Activity"
        component={ActivityTimelineScreen}
        options={{
          tabBarIcon: ({ color, size }) => <MaterialIcons name="history" color={color} size={size} />,
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
