/**
 * Caregiver "Manage" tab: the care recipient's medications and
 * appointments, each opening the same step-by-step forms (screens 07 and
 * 08) in the caregiver accent.
 *
 * Port of lib/features/caregiver/manage_screen.dart.
 */
import React from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import {
  CallContactButton,
  CcAppBar,
  CcListItem,
  doseStatusChipText,
  doseStatusPresentation,
  ResponsiveBody,
  SectionHeading,
} from '../../core/components';
import { useTheme } from '../../core/theme/ThemeContext';
import { CcRadius, Space, TapTarget } from '../../core/theme/spacing';
import { appointmentSummaryLine, medicationDisplayName } from '../../models/domain';
import type { ManageStackParamList } from '../../navigation/types';
import { useClockStore } from '../../state/clockStore';
import {
  useActiveMedications,
  useMedicationTodayDose,
  usePatient,
  useUpcomingAppointments,
} from '../../state/selectors';

type Nav = NativeStackNavigationProp<ManageStackParamList, 'Manage'>;

export function ManageScreen() {
  const theme = useTheme();
  const navigation = useNavigation<Nav>();
  const patient = usePatient();
  const medications = useActiveMedications();
  const appointments = useUpcomingAppointments();

  const openMedication = (medicationId: string) => navigation.navigate('MedicationDetail', { medicationId });
  const openMedicationForm = (editingId?: string) =>
    navigation.getParent()?.getParent()?.navigate('MedicationForm', editingId ? { editingId } : undefined);
  const openAppointmentForm = (editingId?: string) =>
    navigation.getParent()?.getParent()?.navigate('AppointmentForm', editingId ? { editingId } : undefined);

  return (
    <View style={{ flex: 1, backgroundColor: theme.colors.background }}>
      <CcAppBar
        title="Manage"
        subtitle={`${patient.displayName}’s medications and appointments`}
        actions={[
          <CallContactButton
            key="call"
            contactName={patient.displayName}
            relationship="your care recipient"
            phone="555-0199"
          />,
        ]}
      />
      <ResponsiveBody
        primary={[
          <SectionHeading key="meds-heading">Medications</SectionHeading>,
          ...medications.map((medication) => (
            <ManageMedicationRow
              key={medication.id}
              medicationId={medication.id}
              title={medicationDisplayName(medication)}
              onPress={() => openMedication(medication.id)}
            />
          )),
          <View key="sp1" style={{ height: Space.sm }} />,
          <Pressable
            key="add-med"
            testID="manage-add-medication"
            accessibilityRole="button"
            onPress={() => openMedicationForm()}
            style={({ pressed }) => [
              styles.filledButton,
              { backgroundColor: theme.primary, opacity: pressed ? 0.85 : 1 },
            ]}
          >
            <MaterialIcons name="add" size={20} color={theme.onPrimary} />
            <Text style={[theme.text.labelLarge, { color: theme.onPrimary, marginLeft: Space.sm }]}>
              Add Medication
            </Text>
          </Pressable>,
        ]}
        secondary={[
          <SectionHeading key="appt-heading">Appointments</SectionHeading>,
          ...appointments.map((appointment) => (
            <CcListItem
              key={appointment.id}
              title={appointment.title}
              subtitle={appointmentSummaryLine(appointment)}
              semanticHint="Opens the appointment to edit it"
              onPress={() => openAppointmentForm(appointment.id)}
            />
          )),
          <View key="sp2" style={{ height: Space.sm }} />,
          <Pressable
            key="add-appt"
            testID="manage-add-appointment"
            accessibilityRole="button"
            onPress={() => openAppointmentForm()}
            style={({ pressed }) => [
              styles.filledButton,
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

function ManageMedicationRow({
  medicationId,
  title,
  onPress,
}: {
  medicationId: string;
  title: string;
  onPress: () => void;
}) {
  const now = useClockStore((s) => s.now);
  const dose = useMedicationTodayDose(medicationId);
  const subtitle = dose == null ? 'No dose scheduled today' : doseStatusChipText(doseStatusPresentation(dose, now));
  const tone = dose == null ? 'info' : doseStatusPresentation(dose, now).tone;

  return (
    <CcListItem title={title} subtitle={subtitle} tone={tone} semanticHint="Opens the medication" onPress={onPress} />
  );
}

const styles = StyleSheet.create({
  filledButton: {
    flexDirection: 'row',
    minHeight: TapTarget.minimum + 4,
    borderRadius: CcRadius.md,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
