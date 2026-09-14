/**
 * Screen 04 — Appointments List.
 *
 * Each row carries the full-word date, the time, the place and who is
 * taking the care recipient — nothing to look up on another screen.
 *
 * Port of lib/features/patient/appointments_screen.dart.
 */
import React from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import type { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { CallContactButton, CcAppBar, CcListItem, EmptyState, ResponsiveBody } from '../../core/components';
import { useTheme } from '../../core/theme/ThemeContext';
import { CcRadius, Space, TapTarget } from '../../core/theme/spacing';
import { appointmentSummaryLine } from '../../models/domain';
import type { PatientTabParamList } from '../../navigation/types';
import { useCaregiver, useUpcomingAppointments } from '../../state/selectors';

export function AppointmentsScreen() {
  const theme = useTheme();
  const navigation = useNavigation<BottomTabNavigationProp<PatientTabParamList>>();
  const appointments = useUpcomingAppointments();
  const caregiver = useCaregiver();

  const openForm = (editingId?: string) => {
    navigation.getParent()?.navigate('AppointmentForm', editingId ? { editingId } : undefined);
  };

  return (
    <View style={{ flex: 1, backgroundColor: theme.colors.background }}>
      <CcAppBar
        title="Appointments"
        actions={[
          <CallContactButton
            key="call"
            contactName={caregiver.displayName}
            relationship={caregiver.relationshipToPatient}
            phone={caregiver.phone}
          />,
        ]}
      />
      <ResponsiveBody
        primary={[
          appointments.length === 0 ? (
            <EmptyState
              key="empty"
              icon="event-available"
              message="No upcoming appointments."
              detail="Add one and it will show here with who is taking you."
            />
          ) : (
            appointments.map((appointment) => (
              <CcListItem
                key={appointment.id}
                title={appointment.title}
                subtitle={appointmentSummaryLine(appointment)}
                semanticHint="Opens the appointment to edit it"
                onPress={() => openForm(appointment.id)}
              />
            ))
          ),
          <View key="sp" style={{ height: Space.md }} />,
          <Pressable
            key="add"
            testID="add-appointment"
            accessibilityRole="button"
            onPress={() => openForm()}
            style={({ pressed }) => [
              styles.addButton,
              { backgroundColor: theme.primary, opacity: pressed ? 0.85 : 1 },
            ]}
          >
            <MaterialIcons name="add" size={20} color={theme.onPrimary} />
            <Text style={[theme.text.labelLarge, { color: theme.onPrimary, marginLeft: Space.sm }]}>
              Add Appointment
            </Text>
          </Pressable>,
        ]}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  addButton: {
    flexDirection: 'row',
    minHeight: TapTarget.minimum + 4,
    borderRadius: CcRadius.md,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
