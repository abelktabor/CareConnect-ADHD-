import React from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { StyleSheet, Text, View } from 'react-native';

import { useTheme } from '../theme/ThemeContext';
import { CcRadius, Space } from '../theme/spacing';

export interface EmptyStateProps {
  icon: keyof typeof MaterialIcons.glyphMap;
  message: string;
  detail?: string;
}

/**
 * Calm, plain-language empty state. No exclamation marks, no illustration
 * competing for attention — just what is true and what to do next.
 *
 * Port of lib/core/widgets/empty_state.dart.
 */
export function EmptyState({ icon, message, detail }: EmptyStateProps) {
  const theme = useTheme();
  return (
    <View
      style={[styles.card, { backgroundColor: theme.colors.surface, borderColor: theme.colors.border }]}
    >
      <MaterialIcons name={icon} size={36} color={theme.colors.success} />
      <Text style={[theme.text.titleMedium, styles.message]}>{message}</Text>
      {detail ? <Text style={[theme.text.bodyMedium, styles.detail, { color: theme.colors.textSecondary }]}>{detail}</Text> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderWidth: 1,
    borderRadius: CcRadius.md,
    padding: Space.lg,
    alignItems: 'center',
  },
  message: {
    marginTop: Space.sm,
    textAlign: 'center',
  },
  detail: {
    marginTop: Space.xs,
    textAlign: 'center',
  },
});
