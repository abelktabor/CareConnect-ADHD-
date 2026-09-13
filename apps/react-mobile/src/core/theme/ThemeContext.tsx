import React, { createContext, useContext, useMemo } from 'react';
import { useColorScheme } from 'react-native';
import type { TextStyle } from 'react-native';

import { useSettingsStore } from '../../state/settingsStore';
import { useCurrentRole } from '../../state/sessionStore';
import type { UserRole } from '../../models/types';
import { AppColors, ccColorsDark, ccColorsLight } from './colors';
import type { CcColors } from './colors';
import { bodyEmphasis, buildTextTheme } from './typography';
import type { TextTheme } from './typography';

export type ColorScheme = 'light' | 'dark';

export interface Theme {
  colorScheme: ColorScheme;
  role: UserRole;
  colors: CcColors;
  /** Role-accented primary: Harbor Teal for care recipients, Dusk Violet for caregivers. */
  primary: string;
  onPrimary: string;
  text: TextTheme;
  bodyEmphasis: TextStyle;
  /** 2px focus outline in the accent colour (WCAG 2.2 SC 2.4.7 Focus Visible). */
  focusBorderColor: string;
}

function buildTheme(colorScheme: ColorScheme, role: UserRole): Theme {
  const isDark = colorScheme === 'dark';
  const colors = isDark ? ccColorsDark : ccColorsLight;
  const primary = role === 'caregiver' ? colors.caregiverPrimary : colors.careRecipientPrimary;
  const onPrimary = isDark ? AppColors.darkBackground : AppColors.white;
  return {
    colorScheme,
    role,
    colors,
    primary,
    onPrimary,
    text: buildTextTheme(colors.textPrimary, colors.textSecondary),
    bodyEmphasis: bodyEmphasis(colors.textPrimary),
    focusBorderColor: colors.accent,
  };
}

const ThemeContext = createContext<Theme | null>(null);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const systemScheme = useColorScheme();
  const themeMode = useSettingsStore((s) => s.themeMode);
  const role = useCurrentRole();

  const resolvedScheme: ColorScheme =
    themeMode === 'system' ? (systemScheme === 'dark' ? 'dark' : 'light') : themeMode;

  const theme = useMemo(() => buildTheme(resolvedScheme, role), [resolvedScheme, role]);

  return <ThemeContext.Provider value={theme}>{children}</ThemeContext.Provider>;
}

export function useTheme(): Theme {
  const theme = useContext(ThemeContext);
  if (!theme) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return theme;
}
