import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

import { useTheme } from '../theme/ThemeContext';
import { CcRadius, Space } from '../theme/spacing';
import { bodyEmphasis } from '../theme/typography';

export interface StepIndicatorProps {
  step: number;
  totalSteps: number;
  title: string;
  subtitle?: string;
}

/**
 * "Step 1 of 3 — Medication details" with a progress bar filled to the
 * matching fraction, not just a step count.
 *
 * The whole indicator is a live region: when the step changes, assistive
 * tech announces "Step 2 of 3, Schedule" without moving focus.
 *
 * Port of lib/core/widgets/step_indicator.dart.
 */
export function StepIndicator({ step, totalSteps, title, subtitle }: StepIndicatorProps) {
  const theme = useTheme();
  const fraction = Math.min(1, Math.max(0, step / totalSteps));
  const heading = `Step ${step} of ${totalSteps} — ${title}`;

  return (
    <View
      accessibilityLiveRegion="polite"
      accessible
      accessibilityLabel={`Step ${step} of ${totalSteps}, ${title}`}
    >
      <Text style={bodyEmphasis(theme.colors.textPrimary)}>{heading}</Text>
      {subtitle ? (
        <Text style={[theme.text.bodyMedium, { color: theme.colors.textSecondary }]}>{subtitle}</Text>
      ) : null}
      <View
        style={[styles.track, { backgroundColor: theme.colors.border }]}
        accessibilityRole="progressbar"
        accessibilityValue={{ min: 0, max: totalSteps, now: step }}
      >
        <View style={[styles.fill, { width: `${fraction * 100}%`, backgroundColor: theme.primary }]} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  track: {
    marginTop: Space.sm,
    height: 8,
    borderRadius: CcRadius.sm,
    overflow: 'hidden',
  },
  fill: {
    height: '100%',
  },
});
