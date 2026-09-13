import React from 'react';
import { Text } from 'react-native';
import type { TextStyle } from 'react-native';

import { useTheme } from '../theme/ThemeContext';
import { Space } from '../theme/spacing';

export type HeadingLevel = 'h1' | 'h2' | 'h3' | 'h4';

export interface SectionHeadingProps {
  children: string;
  level?: HeadingLevel;
  color?: string;
  style?: TextStyle;
}

/**
 * Heading levels from the type scale, exposed to assistive tech as a header
 * so screen-reader users can jump between sections.
 *
 * Port of lib/core/widgets/section_heading.dart.
 */
export function SectionHeading({ children, level = 'h3', color, style }: SectionHeadingProps) {
  const theme = useTheme();
  const slot = {
    h1: theme.text.headlineLarge,
    h2: theme.text.headlineMedium,
    h3: theme.text.titleLarge,
    h4: theme.text.titleMedium,
  }[level];

  return (
    <Text
      accessibilityRole="header"
      style={[slot, { marginTop: Space.md, marginBottom: Space.sm }, color ? { color } : null, style]}
    >
      {children}
    </Text>
  );
}
