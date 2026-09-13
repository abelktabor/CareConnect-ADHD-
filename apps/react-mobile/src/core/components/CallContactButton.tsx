import React, { useState } from 'react';
import { MaterialIcons } from '@expo/vector-icons';
import { Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { useTheme } from '../theme/ThemeContext';
import { CcRadius, Space, TapTarget } from '../theme/spacing';
import { showConfirmationSnackbar } from './UndoSnackbar';

export interface CallContactButtonProps {
  contactName: string;
  /** "your caregiver" / "your care recipient" */
  relationship: string;
  phone: string;
}

/**
 * The persistent "Call my caregiver" action (WCAG 2.2 SC 3.2.6 Consistent
 * Help). Always the top-right 48x48 icon button on every care-recipient
 * screen; the caregiver experience mirrors it with "Call Muhammad".
 *
 * Port of lib/core/widgets/call_contact_button.dart.
 */
export function CallContactButton({ contactName, relationship, phone }: CallContactButtonProps) {
  const theme = useTheme();
  const insets = useSafeAreaInsets();
  const [open, setOpen] = useState(false);
  const label = `Call ${contactName}, ${relationship}`;

  return (
    <>
      <Pressable
        onPress={() => setOpen(true)}
        accessibilityRole="button"
        accessibilityLabel={label}
        hitSlop={8}
        style={styles.iconButton}
      >
        <MaterialIcons name="phone" size={26} color={theme.onPrimary} />
      </Pressable>

      <Modal visible={open} transparent animationType="slide" onRequestClose={() => setOpen(false)}>
        <Pressable style={styles.backdrop} onPress={() => setOpen(false)} accessibilityLabel="Close">
          <Pressable
            style={[
              styles.sheet,
              { backgroundColor: theme.colors.background, paddingBottom: insets.bottom + Space.lg },
            ]}
            onPress={() => {
              /* swallow to avoid closing when tapping inside the sheet */
            }}
          >
            <View style={styles.handle} />
            <Text accessibilityRole="header" style={theme.text.titleLarge}>
              Call {contactName}?
            </Text>
            <Text style={[theme.text.bodyLarge, styles.detailLine]}>
              {contactName} — {relationship} · {phone}
            </Text>
            <Pressable
              accessibilityRole="button"
              accessibilityLabel={`Call ${phone}`}
              onPress={() => {
                setOpen(false);
                showConfirmationSnackbar(
                  `This prototype does not place calls. ${contactName}’s number is ${phone}.`,
                );
              }}
              style={[styles.primaryButton, { backgroundColor: theme.primary }]}
            >
              <MaterialIcons name="phone" size={20} color={theme.onPrimary} />
              <Text style={[theme.text.labelLarge, { color: theme.onPrimary, marginLeft: Space.sm }]}>
                Call {phone}
              </Text>
            </Pressable>
            <Pressable
              accessibilityRole="button"
              onPress={() => setOpen(false)}
              style={styles.secondaryButton}
            >
              <Text style={[theme.text.labelLarge, { color: theme.primary }]}>Not now</Text>
            </Pressable>
          </Pressable>
        </Pressable>
      </Modal>
    </>
  );
}

const styles = StyleSheet.create({
  iconButton: {
    width: TapTarget.icon,
    height: TapTarget.icon,
    alignItems: 'center',
    justifyContent: 'center',
  },
  backdrop: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.4)',
    justifyContent: 'flex-end',
  },
  sheet: {
    borderTopLeftRadius: CcRadius.lg,
    borderTopRightRadius: CcRadius.lg,
    padding: Space.lg,
  },
  handle: {
    alignSelf: 'center',
    width: 40,
    height: 4,
    borderRadius: 2,
    backgroundColor: '#C7CBCE',
    marginBottom: Space.md,
  },
  detailLine: { marginTop: Space.sm, marginBottom: Space.lg },
  primaryButton: {
    flexDirection: 'row',
    minHeight: TapTarget.minimum + 4,
    borderRadius: CcRadius.md,
    alignItems: 'center',
    justifyContent: 'center',
  },
  secondaryButton: {
    marginTop: Space.sm,
    minHeight: TapTarget.minimum,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
