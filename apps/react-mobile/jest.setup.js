/* eslint-disable @typescript-eslint/no-require-imports */
require('@testing-library/react-native/extend-expect');

jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock'),
);

// The native date/time picker renders a platform UI that has no meaningful
// behaviour under jsdom/RN test renderer; screens call it imperatively via
// `open()` helpers in tests instead of driving the native picker.
jest.mock('@react-native-community/datetimepicker', () => {
  const React = require('react');
  const { View } = require('react-native');
  const MockDateTimePicker = (props) => React.createElement(View, { testID: 'mock-datetimepicker', ...props });
  return { __esModule: true, default: MockDateTimePicker };
});
