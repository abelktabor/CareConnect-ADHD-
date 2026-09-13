import React from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { useTheme } from '../theme/ThemeContext';
import { Space, TapTarget } from '../theme/spacing';

export interface CcAppBarProps {
  title: string;
  subtitle?: string;
  showBack?: boolean;
  onBack?: () => void;
  actions?: React.ReactNode[];
}

/**
 * Top app bar in the role colour, with optional subtitle and back button.
 *
 * Renders inside the screen's own safe-area padding so the trailing contact
 * action is never hidden behind a notch or the status bar. Screens render
 * this themselves (navigators are configured with `headerShown: false`) so
 * every screen keeps exact control over title, subtitle and actions, the
 * same as the Dart port's per-screen `CcAppBar`.
 *
 * Port of lib/core/widgets/cc_app_bar.dart.
 */
export function CcAppBar({ title, subtitle, showBack = false, onBack, actions = [] }: CcAppBarProps) {
  const theme = useTheme();
  const insets = useSafeAreaInsets();

  return (
    <View
      style={[
        styles.bar,
        {
          backgroundColor: theme.primary,
          paddingTop: insets.top + Space.sm,
          minHeight: (subtitle ? 84 : 64) + insets.top,
        },
      ]}
    >
      {showBack ? (
        <Pressable
          onPress={onBack}
          accessibilityRole="button"
          accessibilityLabel="Back"
          style={styles.backButton}
          hitSlop={8}
        >
          <MaterialIcons name="arrow-back-ios-new" size={22} color={theme.onPrimary} />
        </Pressable>
      ) : (
        <View style={{ width: Space.md }} />
      )}
      <View style={styles.titleColumn}>
        <Text
          accessibilityRole="header"
          numberOfLines={1}
          style={[theme.text.headlineMedium, { color: theme.onPrimary }]}
        >
          {title}
        </Text>
        {subtitle ? (
          <Text numberOfLines={1} style={[theme.text.bodyMedium, { color: theme.onPrimary }]}>
            {subtitle}
          </Text>
        ) : null}
      </View>
      <View style={styles.actions}>{actions}</View>
    </View>
  );
}

const styles = StyleSheet.create({
  bar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingBottom: Space.sm,
    paddingHorizontal: Space.sm,
  },
  backButton: {
    width: TapTarget.icon,
    height: TapTarget.icon,
    alignItems: 'center',
    justifyContent: 'center',
  },
  titleColumn: {
    flex: 1,
    marginLeft: Space.sm,
    justifyContent: 'center',
  },
  actions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Space.sm,
  },
});
