import React from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { StyleSheet, Text, View } from 'react-native';

import type { AutosaveStatus } from '../../state/draftStore';
import { useTheme } from '../theme/ThemeContext';
import { Space } from '../theme/spacing';
import { bodyEmphasis } from '../theme/typography';

const LABELS: Record<AutosaveStatus, string> = {
  idle: '',
  saving: 'Saving…',
  saved: 'Saved',
};

/**
 * "Saving…" / "Saved" with a dot, announced through a polite live region.
 *
 * Port of lib/core/widgets/autosave_indicator.dart.
 */
export function AutosaveIndicator({ status }: { status: AutosaveStatus }) {
  const theme = useTheme();
  if (status === 'idle') {
    // Keep the slot so the layout does not jump when saving starts.
    return <View style={styles.slot} />;
  }
  const saved = status === 'saved';
  const color = saved ? theme.colors.success : theme.colors.textSecondary;
  return (
    <View
      style={[styles.slot, styles.row]}
      accessibilityLiveRegion="polite"
      accessible
      accessibilityLabel={saved ? 'Saved' : 'Saving'}
    >
      <MaterialIcons name={saved ? 'check-circle' : 'circle'} size={14} color={color} />
      <Text style={[bodyEmphasis(color), styles.text]}>{LABELS[status]}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  slot: { height: 24, justifyContent: 'center' },
  row: { flexDirection: 'row', alignItems: 'center' },
  text: { marginLeft: Space.sm },
});
