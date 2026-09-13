/**
 * Screen 11 — Settings. Three plain rows; the destinations differ slightly
 * by role (caregivers have no "My Caregiver Access").
 *
 * Port of lib/features/settings/settings_screen.dart.
 */
import React from 'react';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { View } from 'react-native';

import { CallContactButton, CcAppBar, CcListItem, ResponsiveBody } from '../../core/components';
import { useTheme } from '../../core/theme/ThemeContext';
import type { SettingsStackParamList } from '../../navigation/types';
import { useCaregiver, usePatient } from '../../state/selectors';
import { useCurrentRole } from '../../state/sessionStore';

type Nav = NativeStackNavigationProp<SettingsStackParamList, 'Settings'>;

export function SettingsScreen() {
  const theme = useTheme();
  const navigation = useNavigation<Nav>();
  const role = useCurrentRole();
  const caregiver = useCaregiver();
  const patient = usePatient();

  return (
    <View style={{ flex: 1, backgroundColor: theme.colors.background }}>
      <CcAppBar
        title="Settings"
        actions={[
          role === 'careRecipient' ? (
            <CallContactButton
              key="call"
              contactName={caregiver.displayName}
              relationship={caregiver.relationshipToPatient}
              phone={caregiver.phone}
            />
          ) : (
            <CallContactButton
              key="call"
              contactName={patient.displayName}
              relationship="your care recipient"
              phone="555-0199"
            />
          ),
        ]}
      />
      <ResponsiveBody
        primary={[
          <CcListItem
            key="notifications"
            testID="settings-notifications"
            title="Notifications"
            subtitle="Digest, alerts, and reminder lead time"
            dotColor={theme.primary}
            onPress={() => navigation.navigate('Notifications')}
          />,
          ...(role === 'careRecipient'
            ? [
                <CcListItem
                  key="caregiver-access"
                  testID="settings-caregiver-access"
                  title="My Caregiver Access"
                  subtitle={`See what ${caregiver.displayName} can see and manage access`}
                  dotColor={theme.primary}
                  onPress={() => navigation.navigate('CaregiverAccess')}
                />,
              ]
            : []),
          <CcListItem
            key="app"
            testID="settings-app"
            title="App Settings"
            subtitle="Profile, account, and general preferences"
            dotColor={theme.primary}
            onPress={() => navigation.navigate('AppSettings')}
          />,
        ]}
      />
    </View>
  );
}
