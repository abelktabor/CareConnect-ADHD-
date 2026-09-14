/**
 * Screen 03 — Medications List.
 *
 * Every medication with its status for today as icon + text. Tapping a
 * card opens the detail; "+ Add Medication" starts the three-step form.
 *
 * Port of lib/features/patient/medications_screen.dart.
 */
import React from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import {
  CallContactButton,
  CcAppBar,
  DoseStatusChip,
  EmptyState,
  ResponsiveBody,
  ResponsiveCardGrid,
  StatusChip,
} from '../../core/components';
import { useTheme } from '../../core/theme/ThemeContext';
import { CcRadius, Space, TapTarget } from '../../core/theme/spacing';
import { medicationDisplayName } from '../../models/domain';
import type { Medication } from '../../models/types';
import type { MedicationsStackParamList } from '../../navigation/types';
import { useClockStore } from '../../state/clockStore';
import { useActiveMedications, useCaregiver, useMedicationTodayDose } from '../../state/selectors';

type Nav = NativeStackNavigationProp<MedicationsStackParamList, 'Medications'>;

export function MedicationsScreen() {
  const theme = useTheme();
  const navigation = useNavigation<Nav>();
  const medications = useActiveMedications();
  const caregiver = useCaregiver();

  return (
    <View style={{ flex: 1, backgroundColor: theme.colors.background }}>
      <CcAppBar
        title="Medications"
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
          medications.length === 0 ? (
            <EmptyState
              key="empty"
              icon="medication"
              message="No medications yet."
              detail="Add one and its doses will appear on Today."
            />
          ) : (
            <ResponsiveCardGrid key="grid">
              {medications.map((medication) => (
                <MedicationCard
                  key={medication.id}
                  medication={medication}
                  onPress={() =>
                    navigation.navigate('MedicationDetail', { medicationId: medication.id })
                  }
                />
              ))}
            </ResponsiveCardGrid>
          ),
          <View key="sp" style={{ height: Space.md }} />,
          <Pressable
            key="add"
            testID="add-medication"
            accessibilityRole="button"
            onPress={() => navigation.getParent()?.getParent()?.navigate('MedicationForm')}
            style={({ pressed }) => [
              styles.addButton,
              { backgroundColor: theme.primary, opacity: pressed ? 0.85 : 1 },
            ]}
          >
            <MaterialIcons name="add" size={20} color={theme.onPrimary} />
            <Text style={[theme.text.labelLarge, { color: theme.onPrimary, marginLeft: Space.sm }]}>
              Add Medication
            </Text>
          </Pressable>,
        ]}
      />
    </View>
  );
}

function MedicationCard({ medication, onPress }: { medication: Medication; onPress: () => void }) {
  const theme = useTheme();
  const now = useClockStore((s) => s.now);
  const dose = useMedicationTodayDose(medication.id);

  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityHint="Opens the medication"
      accessibilityLabel={medicationDisplayName(medication)}
      style={({ pressed }) => [
        styles.card,
        { backgroundColor: theme.colors.surface, borderColor: theme.colors.border },
        pressed ? { opacity: 0.85 } : null,
      ]}
    >
      <Text style={theme.text.titleMedium}>{medicationDisplayName(medication)}</Text>
      <View style={{ height: Space.xs }} />
      {dose != null ? (
        <DoseStatusChip dose={dose} now={now} />
      ) : (
        <StatusChip tone="info" text="No dose scheduled today" spoken="Status: no dose scheduled today" />
      )}
      {medication.instructions != null ? (
        <>
          <View style={{ height: Space.xs }} />
          <Text style={[theme.text.bodyMedium, { color: theme.colors.textSecondary }]}>
            {medication.instructions}
          </Text>
        </>
      ) : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    minHeight: TapTarget.dominantAction,
    borderWidth: 1,
    borderRadius: CcRadius.md,
    padding: Space.md,
  },
  addButton: {
    flexDirection: 'row',
    minHeight: TapTarget.minimum + 4,
    borderRadius: CcRadius.md,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
