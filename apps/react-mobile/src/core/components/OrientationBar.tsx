import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

import { clockTime, fullWordDate } from '../utils/dateFormatting';
import { useTheme } from '../theme/ThemeContext';
import { CcRadius, Space } from '../theme/spacing';
import { bodyEmphasis } from '../theme/typography';

export interface OrientationBarProps {
  now: Date;
  /** "Next: Metformin in 20 minutes" or a calm all-done line. */
  nextLine: string;
}

/**
 * Day, time and the single next thing to do — always visible at the top of
 * the Today screen so the user never has to hold orientation in their head.
 *
 * Exposed as a landmark-style live region: "Tuesday, August 25, 2:14 PM.
 * Next: Metformin in 20 minutes."
 *
 * Port of lib/core/widgets/orientation_bar.dart.
 */
export function OrientationBar({ now, nextLine }: OrientationBarProps) {
  const theme = useTheme();
  const dateLine = `${fullWordDate(now)} · ${clockTime(now)}`;

  return (
    <View
      style={[styles.card, { backgroundColor: theme.colors.surface, borderColor: theme.colors.border }]}
      accessibilityLiveRegion="polite"
      accessible
      accessibilityLabel={`${fullWordDate(now)}, ${clockTime(now)}. ${nextLine}`}
    >
      <Text style={bodyEmphasis(theme.colors.textPrimary)}>{dateLine}</Text>
      <Text style={[theme.text.bodyMedium, { color: theme.colors.textSecondary }]}>{nextLine}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderWidth: 1,
    borderRadius: CcRadius.md,
    paddingHorizontal: Space.md,
    paddingVertical: 12,
  },
});
