/* eslint-disable @typescript-eslint/no-require-imports */
// Runs via `setupFilesAfterEnv`, AFTER Jest's test framework installs the
// global `expect` — required, since this extends it with RNTL's matchers
// (toBeVisible, toHaveTextContent, etc.).
require('@testing-library/react-native/extend-expect');
