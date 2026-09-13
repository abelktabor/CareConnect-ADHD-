/**
 * Shared RNTL rendering helper for screen/component tests.
 *
 * Wraps a tree in `SafeAreaProvider` (with fixed `initialMetrics` so
 * `useSafeAreaInsets` never throws or varies under jsdom) and `ThemeProvider`
 * (so every themed component — `CcAppBar`, `ResponsiveBody`, `DoseCard`, …
 * — has the context it needs). Screens that call `useNavigation` /
 * `useRoute` still need those mocked per-test via `jest.mock('@react-navigation/native', ...)`,
 * since the concrete navigation tree differs screen to screen.
 */
import React from 'react';
import { render } from '@testing-library/react-native';
import type { RenderOptions } from '@testing-library/react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import type { Metrics } from 'react-native-safe-area-context';

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
      <ThemeProvider>{ui}</ThemeProvider>
    </SafeAreaProvider>,
    options,
  );
}
