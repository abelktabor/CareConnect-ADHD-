import React from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { useTheme } from '../theme/ThemeContext';
import { CcRadius, Space, TapTarget } from '../theme/spacing';
import { bodyEmphasis } from '../theme/typography';
import { statusToneColor } from './doseStatus';
import type { StatusTone } from './doseStatus';

export interface CcListItemProps {
  title: string;
  subtitle?: string;
  tone?: StatusTone;
  /** Overrides the tone colour for the leading dot (e.g. the role primary). */
  dotColor?: string;
  onPress?: () => void;
  trailing?: React.ReactNode;
  semanticHint?: string;
  testID?: string;
}

/**
 * List row with a tone dot, bold title and plain-language subtitle.
 *
 * Minimum 44pt tall; the whole row is one tap target.
 *
 * Port of lib/core/widgets/cc_list_item.dart.
 */
export function CcListItem({
  title,
  subtitle,
  tone = 'info',
  dotColor,
  onPress,
  trailing,
  semanticHint,
  testID,
}: CcListItemProps) {
  const theme = useTheme();
  const resolvedDotColor = dotColor ?? statusToneColor(tone, theme.colors);

  return (
    <Pressable
      onPress={onPress}
      testID={testID}
      accessibilityRole={onPress ? 'button' : undefined}
      accessibilityLabel={subtitle ? `${title}. ${subtitle}` : title}
      accessibilityHint={semanticHint}
      style={({ pressed }) => [styles.row, pressed && onPress ? { opacity: 0.7 } : null]}
    >
      <View style={[styles.dot, { backgroundColor: resolvedDotColor }]} />
      <View style={styles.textColumn}>
        <Text style={bodyEmphasis(theme.colors.textPrimary)}>{title}</Text>
        {subtitle ? (
          <Text style={[theme.text.bodyMedium, { color: theme.colors.textSecondary }]}>
            {subtitle}
          </Text>
        ) : null}
      </View>
      {trailing ?? (onPress ? <MaterialIcons name="chevron-right" size={24} color={theme.colors.textSecondary} /> : null)}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    minHeight: TapTarget.icon,
    paddingVertical: 12,
    paddingHorizontal: Space.sm,
    borderRadius: CcRadius.md,
  },
  dot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginTop: 6,
  },
  textColumn: {
    flex: 1,
    marginLeft: Space.md,
    gap: 2,
  },
});
