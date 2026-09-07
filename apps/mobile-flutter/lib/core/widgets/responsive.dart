import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Whether the viewport is wide enough for the two-column "Tablet" and
/// "Landscape" layouts from the Figma.
bool isWideLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

/// Scrollable screen body that lays [primary] and [secondary] out side by
/// side on wide viewports and stacked on phones.
///
/// Reading order is the same in both layouts — primary content first — so
/// the screen-reader experience does not change with orientation
/// (SC 1.3.2 Meaningful Sequence).
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    required this.primary,
    this.secondary,
    this.padding = const EdgeInsets.all(Space.md),
    this.maxWidth = Breakpoints.contentMaxWidth,
    super.key,
  });

  final List<Widget> primary;
  final List<Widget>? secondary;
  final EdgeInsets padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final wide = isWideLayout(context);
    final secondaryChildren = secondary ?? const <Widget>[];

    final Widget content;
    if (wide && secondaryChildren.isNotEmpty) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: primary,
            ),
          ),
          const SizedBox(width: Space.lg),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: secondaryChildren,
            ),
          ),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [...primary, ...secondaryChildren],
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Lays cards out in two columns on wide viewports, one on phones.
class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!isWideLayout(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: Space.sm),
            children[i],
          ],
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - Space.sm) / 2;
        return Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
