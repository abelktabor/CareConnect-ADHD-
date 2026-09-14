import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { create } from 'zustand';

import { DOSE_UNDO_WINDOW_MS } from '../../models/types';
import { CcRadius, Space } from '../theme/spacing';

/** Standard confirmation banner duration (Material's default snackbar timing). */
const CONFIRMATION_DURATION_MS = 4000;

interface SnackbarState {
  visible: boolean;
  message: string;
  actionLabel?: string;
  onAction?: () => void;
  key: number;
  hide: () => void;
}

let dismissTimer: ReturnType<typeof setTimeout> | null = null;
let keyCounter = 0;

const useSnackbarStore = create<SnackbarState>((set) => ({
  visible: false,
  message: '',
  actionLabel: undefined,
  onAction: undefined,
  key: 0,
  hide: () => set({ visible: false }),
}));

function present(message: string, durationMs: number, actionLabel?: string, onAction?: () => void): void {
  if (dismissTimer) clearTimeout(dismissTimer);
  keyCounter += 1;
  useSnackbarStore.setState({ visible: true, message, actionLabel, onAction, key: keyCounter });
  dismissTimer = setTimeout(() => {
    useSnackbarStore.getState().hide();
  }, durationMs);
}

/**
 * Shows the reversible confirmation used for every routine action.
 *
 * Bottom-anchored, auto-dismissing after the 10-second undo window, and
 * announced through a live region. Undo is additive — nothing is forfeited
 * when the window closes (WCAG SC 2.2.1 Timing Adjustable).
 *
 * Port of `showUndoSnackBar` in lib/core/widgets/undo_snackbar.dart.
 */
export function showUndoSnackbar({ message, onUndo }: { message: string; onUndo: () => void }): void {
  present(message, DOSE_UNDO_WINDOW_MS, 'Undo', () => {
    if (dismissTimer) clearTimeout(dismissTimer);
    useSnackbarStore.getState().hide();
    onUndo();
  });
}

/** A plain confirmation with no action. Port of `showConfirmationSnackBar`. */
export function showConfirmationSnackbar(message: string): void {
  present(message, CONFIRMATION_DURATION_MS);
}

/**
 * Renders the currently active snackbar. Mount exactly once, near the root
 * (see App.tsx) — the equivalent of Flutter's app-wide `ScaffoldMessenger`.
 */
export function SnackbarHost() {
  const { visible, message, actionLabel, onAction, key } = useSnackbarStore();
  const insets = useSafeAreaInsets();

  if (!visible) return null;

  return (
    <View
      key={key}
      pointerEvents="box-none"
      style={[styles.container, { paddingBottom: insets.bottom + Space.md }]}
    >
      <View
        style={styles.bar}
        accessibilityLiveRegion="polite"
        accessible
        accessibilityLabel={message}
      >
        <Text style={styles.message} numberOfLines={3}>
          {message}
        </Text>
        {actionLabel && onAction ? (
          <Pressable onPress={onAction} accessibilityRole="button" accessibilityLabel={actionLabel} hitSlop={8}>
            <Text style={styles.action}>{actionLabel}</Text>
          </Pressable>
        ) : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    paddingHorizontal: Space.md,
    alignItems: 'center',
  },
  bar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#1A1D1F',
    borderRadius: CcRadius.md,
    paddingHorizontal: Space.md,
    paddingVertical: 12,
    width: '100%',
    maxWidth: 560,
  },
  message: {
    color: '#FFFFFF',
    flex: 1,
    fontSize: 16,
  },
  action: {
    color: '#5FB8D6',
    fontWeight: '700',
    marginLeft: Space.md,
  },
});
