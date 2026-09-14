/**
 * Screen 06 — Caregiver Dashboard.
 *
 * Defaults to only what needs action today — overdue doses as alerts and
 * the next due dose with "Log now" — rather than a full history that has
 * to be filtered by hand. History is opt-in through "View full history".
 *
 * Port of lib/features/caregiver/caregiver_dashboard_screen.dart.
 */
import React from 'react';
import { useNavigation } from '@react-navigation/native';
import type { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { Pressable, Text, View } from 'react-native';

import { markDoseTaken } from '../patient/TodayScreen';
import {
  AlertCard,
  CallContactButton,
  CcAppBar,
  DoseCard,
  DoseStatusChip,
  EmptyState,
  ResponsiveBody,
  SectionHeading,
} from '../../core/components';
import { useTheme } from '../../core/theme/ThemeContext';
import { Space } from '../../core/theme/spacing';
import { clockTime } from '../../core/utils/dateFormatting';
import { doseIsOverdue, medicationById, medicationDisplayName } from '../../models/domain';
import type { CaregiverTabParamList } from '../../navigation/types';
import { useCareDataStore } from '../../state/careDataStore';
import { useClockStore } from '../../state/clockStore';
import { useNextActionDose, useOverdueDoses, usePatient } from '../../state/selectors';

export function CaregiverDashboardScreen() {
  const theme = useTheme();
  const navigation = useNavigation<BottomTabNavigationProp<CaregiverTabParamList>>();
  const now = useClockStore((s) => s.now);
  const patient = usePatient();
  const data = useCareDataStore((s) => s.data);
  const overdue = useOverdueDoses();
  const nextDose = useNextActionDose();
  const nextMedication = nextDose == null ? undefined : medicationById(data, nextDose.medicationId);
  const showNextCard = nextDose != null && nextMedication != null && !doseIsOverdue(nextDose, now);

  return (
    <View style={{ flex: 1, backgroundColor: theme.colors.background }}>
      <CcAppBar
        title="Caregiver Dashboard"
        subtitle={`${patient.displayName}’s care`}
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
          <SectionHeading key="heading">Needs attention today</SectionHeading>,
          ...(overdue.length === 0 && !showNextCard
            ? [
                <EmptyState
                  key="empty"
                  icon="check-circle"
                  message="Nothing needs attention right now."
                  detail="Every dose so far today has been logged."
                />,
              ]
            : []),
          ...overdue.map((dose) => {
            const medication = medicationById(data, dose.medicationId);
            return (
              <View key={dose.id} style={{ marginBottom: Space.sm }}>
                <AlertCard
                  text={`Overdue — ${clockTime(dose.scheduledFor)} ${medication?.name ?? 'dose'} not yet confirmed`}
                  actionHint="Opens the medication to log it"
                  onPress={() =>
                    navigation.navigate('ManageStack', {
                      screen: 'MedicationDetail',
                      params: { medicationId: dose.medicationId },
                    })
                  }
                />
              </View>
            );
          }),
        ]}
        secondary={[
          ...(showNextCard && nextDose != null && nextMedication != null
            ? [
                <DoseCard
                  key="dashboard-dose-card"
                  testID="dashboard-dose-card"
                  title={medicationDisplayName(nextMedication)}
                  status={<DoseStatusChip dose={nextDose} now={now} />}
                  actionLabel="Log now"
                  onAction={() => void markDoseTaken(nextDose, nextMedication)}
                />,
              ]
            : []),
          <View key="sp" style={{ height: Space.sm }} />,
          <Pressable
            key="history"
            testID="view-full-history"
            accessibilityRole="button"
            onPress={() => navigation.navigate('Activity')}
            style={{ alignSelf: 'flex-start', minHeight: 44, justifyContent: 'center' }}
          >
            <Text style={[theme.text.labelLarge, { color: theme.primary }]}>View full history</Text>
          </Pressable>,
        ]}
      />
    </View>
  );
}
