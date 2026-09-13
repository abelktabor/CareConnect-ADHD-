// @ts-check
//
// Pinned to ESLint 8.x (see package.json) rather than 9.x: eslint-plugin-
// react-native@4.1.0's peerDependencies only go up to ^8, and there is no
// newer release that supports ESLint 9. 8.57+ still understands this flat
// config format natively, so nothing here needs to change if that plugin
// is ever dropped in favour of ESLint 9.
const js = require('@eslint/js');
const tseslint = require('typescript-eslint');
const react = require('eslint-plugin-react');
const reactHooks = require('eslint-plugin-react-hooks');
const reactNative = require('eslint-plugin-react-native');
const globals = require('globals');

module.exports = tseslint.config(
  {
    ignores: ['node_modules/**', '.expo/**', 'coverage/**', 'babel.config.js'],
  },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ['**/*.{ts,tsx}'],
    plugins: {
      react,
      'react-hooks': reactHooks,
      'react-native': reactNative,
    },
    languageOptions: {
      parserOptions: {
        ecmaFeatures: { jsx: true },
      },
      globals: {
        ...globals.node,
        ...globals.jest,
        ...reactNative.environments['react-native'].globals,
      },
    },
    settings: {
      react: { version: 'detect' },
    },
    rules: {
      ...react.configs.recommended.rules,
      ...reactHooks.configs.recommended.rules,
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'warn',
      'react-native/no-unused-styles': 'error',
      'react-native/no-inline-styles': 'off',
      'react-native/no-color-literals': 'off',
    },
  },
  {
    files: ['**/*.test.{ts,tsx}'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'off',
    },
  },
  {
    // Plain CommonJS config/setup files (not covered by the ts/tsx block
    // above) run under Node and, for the Jest setup files, inside Jest.
    files: ['eslint.config.js', 'jest.config.js', 'jest.setup.js', 'jest.setup.after-env.js'],
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.jest,
      },
    },
    rules: {
      // These are plain CommonJS files by necessity (the flat config format
      // itself, and Jest config/setup loaded outside the TS/ESM pipeline).
      '@typescript-eslint/no-require-imports': 'off',
    },
  },
);
