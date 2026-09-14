import React from 'react';
import { ScrollView, useWindowDimensions, View } from 'react-native';
import type { ViewStyle } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Breakpoints, Space } from '../theme/spacing';

/**
 * Whether the viewport is wide enough for the two-column "Tablet" and
 * "Landscape" layouts from the Figma.
 *
 * Port of lib/core/widgets/responsive.dart.
 */
export function useIsWideLayout(): boolean {
  const { width } = useWindowDimensions();
  return width >= Breakpoints.tablet;
}

export interface ResponsiveBodyProps {
  primary: React.ReactNode[];
  secondary?: React.ReactNode[];
  contentPadding?: number;
  maxWidth?: number;
}

/**
 * Scrollable screen body that lays `primary` and `secondary` out side by
 * side on wide viewports and stacked on phones.
 *
 * Reading order is the same in both layouts — primary content first — so
 * the screen-reader experience does not change with orientation
 * (SC 1.3.2 Meaningful Sequence).
 */
export function ResponsiveBody({
  primary,
  secondary,
  contentPadding = Space.md,
  maxWidth = Breakpoints.contentMaxWidth,
}: ResponsiveBodyProps) {
  const wide = useIsWideLayout();
  const insets = useSafeAreaInsets();
  const secondaryChildren = secondary ?? [];

  const content =
    wide && secondaryChildren.length > 0 ? (
      <View style={{ flexDirection: 'row', alignItems: 'flex-start' }}>
        <View style={{ flex: 3, gap: Space.sm }}>{primary}</View>
        <View style={{ width: Space.lg }} />
        <View style={{ flex: 2, gap: Space.sm }}>{secondaryChildren}</View>
      </View>
    ) : (
      <View style={{ gap: Space.sm }}>
        {primary}
        {secondaryChildren}
      </View>
    );

  return (
    <ScrollView
      style={{ flex: 1 }}
      contentContainerStyle={{
        padding: contentPadding,
        paddingBottom: contentPadding + insets.bottom,
        alignItems: 'center',
      }}
    >
      <View style={{ width: '100%', maxWidth }}>{content}</View>
    </ScrollView>
  );
}

/** Lays cards out in two columns on wide viewports, one on phones. */
export function ResponsiveCardGrid({ children }: { children: React.ReactNode[] }) {
  const wide = useIsWideLayout();
  if (!wide) {
    return <View style={{ gap: Space.sm }}>{children}</View>;
  }
  const columnStyle: ViewStyle = { flexBasis: '48%', flexGrow: 1 };
  return (
    <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: Space.sm }}>
      {children.map((child, i) => (
        <View key={i} style={columnStyle}>
          {child}
        </View>
      ))}
    </View>
  );
}
