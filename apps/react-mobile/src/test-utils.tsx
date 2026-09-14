/**
 * Shared RNTL rendering helper for screen/component tests.
 *
 * Wraps a tree in `SafeAreaProvider` (with fixed `initialMetrics` so
 * `useSafeAreaInsets` never throws or varies under jsdom) and `ThemeProvider`
 * (so every themed component — `CcAppBar`, `ResponsiveBody`, `DoseCard`, …
 * — has the context it needs), plus `SnackbarHost` — mirroring App.tsx's
 * `AppShell`, which mounts it once near the root. `showUndoSnackbar` /
 * `showConfirmationSnackbar` just update a standalone zustand store; without
 * `SnackbarHost` in the tree, nothing ever renders the "Undo" banner those
 * calls queue, so any test asserting on it (e.g. TodayScreen's "marks the
 * next dose taken and offers undo") would never find it. Screens that call
 * `useNavigation` / `useRoute` still need those mocked per-test via
 * `jest.mock('@react-navigation/native', ...)`, since the concrete
 * navigation tree differs screen to screen.
 */
import React from 'react';
import { render } from '@testing-library/react-native';
import type { RenderOptions } from '@testing-library/react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import type { Metrics } from 'react-native-safe-area-context';

import { SnackbarHost } from './core/components';
import { ThemeProvider } from './core/theme/ThemeContext';

const TEST_METRICS: Metrics = {
  frame: { x: 0, y: 0, width: 390, height: 844 },
  insets: { top: 47, left: 0, right: 0, bottom: 34 },
};

export function renderWithProviders(
  ui: React.ReactElement,
  options?: RenderOptions,
) {
  return render(
    <SafeAreaProvider initialMetrics={TEST_METRICS}>
      <ThemeProvider>
        {ui}
        <SnackbarHost />
      </ThemeProvider>
    </SafeAreaProvider>,
    options,
  );
}
