import React from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { StyleSheet, Text, View } from 'react-native';

import { useTheme } from '../theme/ThemeContext';
import { Space } from '../theme/spacing';
import { bodyEmphasis } from '../theme/typography';
import type { DoseEvent } from '../../models/types';
import { doseStatusChipText, doseStatusPresentation, statusToneColor, statusToneIcon } from './doseStatus';
import type { StatusTone } from './doseStatus';

export interface StatusChipProps {
  tone: StatusTone;
  text: string;
  /** Screen-reader phrasing. Falls back to `text`. */
  spoken?: string;
}

/** Icon + text status indicator. Never colour alone. Port of StatusChip.dart. */
export function StatusChip({ tone, text, spoken }: StatusChipProps) {
  const theme = useTheme();
  const color = statusToneColor(tone, theme.colors);
  return (
    <View style={styles.row} accessible accessibilityLabel={spoken ?? text}>
      <MaterialIcons name={statusToneIcon(tone)} size={18} color={color} />
      <Text style={[bodyEmphasis(color), styles.text]} numberOfLines={2}>
        {text}
      </Text>
    </View>
  );
}

/** Builds the chip for a dose at `now` — port of `StatusChip.dose(...)`. */
export function DoseStatusChip({ dose, now }: { dose: DoseEvent; now: Date }) {
  const presentation = doseStatusPresentation(dose, now);
  return (
    <StatusChip
      tone={presentation.tone}
      text={doseStatusChipText(presentation)}
      spoken={`Status: ${presentation.spoken}`}
    />
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  text: {
    marginLeft: Space.xs + 2,
    flexShrink: 1,
  },
});
