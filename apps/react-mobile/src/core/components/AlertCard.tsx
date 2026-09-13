import React from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { useTheme } from '../theme/ThemeContext';
import { CcRadius, Space, TapTarget } from '../theme/spacing';
import { bodyEmphasis } from '../theme/typography';

export interface AlertCardProps {
  text: string;
  onPress?: () => void;
  /** What tapping does, for the screen-reader hint ("Opens the dose"). */
  actionHint?: string;
  testID?: string;
}

/**
 * Urgent alert row: error-coloured left border, alert icon and text, all in
 * the accessible name ("Overdue, alert, 1:29 PM Atorvastatin not yet
 * confirmed"). Tapping opens the related item.
 *
 * Port of lib/core/widgets/alert_card.dart.
 */
export function AlertCard({ text, onPress, actionHint, testID }: AlertCardProps) {
  const theme = useTheme();
  return (
    <Pressable
      testID={testID}
      onPress={onPress}
      accessibilityRole={onPress ? 'button' : undefined}
      accessibilityLabel={`Alert: ${text}`}
      accessibilityHint={actionHint}
      style={({ pressed }) => [
        styles.card,
        {
          backgroundColor: theme.colors.surface,
          borderLeftColor: theme.colors.error,
        },
        pressed && onPress ? { opacity: 0.8 } : null,
      ]}
    >
      <MaterialIcons name="error" size={22} color={theme.colors.error} />
      <Text style={[bodyEmphasis(theme.colors.error), styles.text]} numberOfLines={3}>
        {text}
      </Text>
      {onPress ? <MaterialIcons name="chevron-right" size={22} color={theme.colors.textSecondary} /> : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: TapTarget.icon,
    borderLeftWidth: 4,
    borderRadius: CcRadius.md,
    paddingHorizontal: Space.md,
    paddingVertical: 12,
  },
  text: {
    flex: 1,
    marginLeft: Space.sm,
  },
});
