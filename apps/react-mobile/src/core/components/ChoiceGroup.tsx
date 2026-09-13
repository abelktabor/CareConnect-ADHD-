import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { useTheme } from '../theme/ThemeContext';
import { CcRadius, Space, TapTarget } from '../theme/spacing';
import { bodyEmphasis } from '../theme/typography';

export interface ChoiceOption<T> {
  value: T;
  label: string;
  spoken?: string;
}

export interface ChoiceGroupProps<T> {
  options: ChoiceOption<T>[];
  selected: T | undefined;
  onSelect: (value: T) => void;
  /** Announced as the group's name ("Reminder lead time"). */
  groupLabel: string;
  /** Round chips (Notifications screen) instead of rectangular cards. */
  circular?: boolean;
  testID?: string;
}

/**
 * One option in a single-select group (the round "15 min / 1 hour / 1 day"
 * chips, and the "I am a…" role cards).
 *
 * Exposed to assistive tech as a radio-style item: mutually exclusive, with
 * a checked state, so the selection is announced without colour.
 *
 * Port of lib/core/widgets/choice_group.dart.
 */
export function ChoiceGroup<T extends string>({
  options,
  selected,
  onSelect,
  groupLabel,
  circular = false,
  testID,
}: ChoiceGroupProps<T>) {
  const theme = useTheme();
  return (
    <View
      style={styles.row}
      accessible={false}
      accessibilityRole="radiogroup"
      accessibilityLabel={groupLabel}
      testID={testID}
    >
      {options.map((option) => {
        const isSelected = option.value === selected;
        const shape = circular ? styles.circularShape : styles.rectShape;
        return (
          <Pressable
            key={String(option.value)}
            onPress={() => onSelect(option.value)}
            accessibilityRole="radio"
            accessibilityState={{ selected: isSelected, checked: isSelected }}
            accessibilityLabel={option.spoken ?? option.label}
            style={({ pressed }) => [
              styles.choice,
              shape,
              {
                backgroundColor: isSelected ? theme.primary : theme.colors.background,
                borderColor: isSelected ? theme.primary : theme.colors.border,
                borderWidth: isSelected ? 2 : 1.5,
              },
              pressed ? { opacity: 0.8 } : null,
            ]}
          >
            <Text
              style={[
                bodyEmphasis(isSelected ? theme.onPrimary : theme.primary),
                styles.choiceText,
              ]}
            >
              {option.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    gap: Space.sm + 4,
  },
  choice: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: Space.sm,
    paddingVertical: Space.sm,
  },
  rectShape: {
    minHeight: TapTarget.dominantAction,
    minWidth: TapTarget.minimum,
    borderRadius: CcRadius.md,
  },
  circularShape: {
    minHeight: 64,
    minWidth: TapTarget.minimum,
    borderRadius: 999,
  },
  choiceText: {
    textAlign: 'center',
  },
});
