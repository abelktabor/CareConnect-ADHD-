import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { useTheme } from '../theme/ThemeContext';
import { CcRadius, Space, TapTarget } from '../theme/spacing';

export interface DoseCardProps {
  /** "Metformin, 500 mg" */
  title: string;
  status: React.ReactNode;
  actionLabel: string;
  onAction?: () => void;
  instructions?: string | null;
  /** Dominant cards use the accent colour and the taller target. */
  dominant?: boolean;
  testID?: string;
}

/**
 * The single dominant next-action card.
 *
 * Exactly one of these is visually dominant per screen, and its button is
 * the only Focus Coral element on that screen, so the accent keeps meaning.
 *
 * Port of lib/core/widgets/dose_card.dart.
 */
export function DoseCard({
  title,
  status,
  actionLabel,
  onAction,
  instructions,
  dominant = true,
  testID,
}: DoseCardProps) {
  const theme = useTheme();
  return (
    <View style={[styles.card, { backgroundColor: theme.colors.surface, borderColor: theme.colors.border }]}>
      <Text accessibilityRole="header" style={theme.text.titleLarge}>
        {title}
      </Text>
      <View style={styles.statusSpacer}>{status}</View>
      {instructions ? (
        <Text style={[theme.text.bodyMedium, styles.instructions]}>{instructions}</Text>
      ) : null}
      <Pressable
        testID={testID}
        onPress={onAction}
        disabled={!onAction}
        accessibilityRole="button"
        accessibilityLabel={actionLabel}
        style={({ pressed }) => [
          styles.button,
          {
            backgroundColor: dominant ? theme.colors.accent : theme.primary,
            opacity: !onAction ? 0.5 : pressed ? 0.85 : 1,
          },
          dominant ? styles.dominantButton : null,
        ]}
      >
        <Text style={[theme.text.labelLarge, { color: theme.onPrimary }]}>{actionLabel}</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderWidth: 1,
    borderRadius: CcRadius.md,
    padding: Space.md,
  },
  statusSpacer: { marginTop: Space.xs },
  instructions: { marginTop: Space.xs },
  button: {
    marginTop: Space.md,
    minHeight: TapTarget.minimum + 8,
    borderRadius: CcRadius.md,
    alignItems: 'center',
    justifyContent: 'center',
  },
  dominantButton: {
    minHeight: TapTarget.dominantAction,
  },
});
