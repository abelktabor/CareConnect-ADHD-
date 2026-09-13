/**
 * Screen 10 — Activity Timeline. Plain-language entries grouped by day,
 * newest first, with a simple filter.
 *
 * Port of lib/features/caregiver/activity_timeline_screen.dart.
 */
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { CcAppBar, EmptyState, ResponsiveBody } from '../../core/components';
import { useTheme } from '../../core/theme/ThemeContext';
import { CcRadius, Space, TapTarget } from '../../core/theme/spacing';
import { bodyEmphasis } from '../../core/theme/typography';
import { dayHeading } from '../../core/utils/dateFormatting';
import { useActivityFilterStore } from '../../state/activityFilterStore';
import { ACTIVITY_FILTER_LABELS, useActivityTimeline } from '../../state/selectors';
import type { ActivityFilter } from '../../state/selectors';

const FILTERS: { value: ActivityFilter; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'medications', label: 'Medications' },
  { value: 'appointments', label: 'Appointments' },
];

export function ActivityTimelineScreen() {
  const theme = useTheme();
  const filter = useActivityFilterStore((s) => s.filter);
  const setFilter = useActivityFilterStore((s) => s.setFilter);
  const days = useActivityTimeline(filter);

  return (
    <View style={{ flex: 1, backgroundColor: theme.colors.background }}>
      <CcAppBar title="Activity Timeline" />
      <ResponsiveBody
        primary={[
          <Text key="filter-label" style={bodyEmphasis(theme.colors.textPrimary)}>
            Filter: {ACTIVITY_FILTER_LABELS[filter]}
          </Text>,
          <View key="sp0" style={{ height: Space.sm }} />,
          <View
            key="filter"
            testID="activity-filter"
            accessibilityRole="radiogroup"
            accessibilityLabel="Activity filter"
            style={styles.segmentRow}
          >
            {FILTERS.map((option) => {
              const selected = option.value === filter;
              return (
                <Pressable
                  key={option.value}
                  accessibilityRole="radio"
                  accessibilityState={{ selected, checked: selected }}
                  accessibilityLabel={option.label}
                  onPress={() => setFilter(option.value)}
                  style={({ pressed }) => [
                    styles.segment,
                    {
                      backgroundColor: selected ? theme.primary : theme.colors.background,
                      borderColor: selected ? theme.primary : theme.colors.border,
                    },
                    pressed ? { opacity: 0.8 } : null,
                  ]}
                >
                  <Text
                    style={[
                      theme.text.labelLarge,
                      { color: selected ? theme.onPrimary : theme.primary },
                    ]}
                  >
                    {option.label}
                  </Text>
                </Pressable>
              );
            })}
          </View>,
          <View key="sp1" style={{ height: Space.sm }} />,
          ...(days.length === 0
            ? [
                <EmptyState
                  key="empty"
                  icon="history"
                  message="No activity to show."
                  detail="Logged doses and appointment changes appear here."
                />,
              ]
            : days.flatMap((day) => [
                <Text
                  key={`heading-${day.day.getTime()}`}
                  accessibilityRole="header"
                  style={[
                    theme.text.labelSmall,
                    { color: theme.colors.textPrimary, fontWeight: '700', marginTop: Space.md, marginBottom: Space.xs },
                  ]}
                >
                  {dayHeading(day.day)}
                </Text>,
                ...day.entries.map((entry) => (
                  <View key={entry.id} style={styles.entryRow}>
                    <View style={[styles.dot, { backgroundColor: theme.colors.info }]} />
                    <Text style={[theme.text.bodyMedium, styles.entryText]}>{entry.summary}</Text>
                  </View>
                )),
              ])),
        ]}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  segmentRow: { flexDirection: 'row', gap: Space.sm },
  segment: {
    flex: 1,
    minHeight: TapTarget.minimum,
    borderWidth: 1.5,
    borderRadius: CcRadius.md,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: Space.xs,
  },
  entryRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    paddingVertical: Space.xs + 2,
  },
  dot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginTop: 7,
    marginLeft: Space.sm,
  },
  entryText: { flex: 1, marginLeft: Space.md },
});
