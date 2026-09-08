import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Heading levels from the type scale, each exposed to assistive tech as a
/// heading so screen-reader users can jump between sections.
enum HeadingLevel { h1, h2, h3, h4 }

class SectionHeading extends StatelessWidget {
  const SectionHeading(
    this.text, {
    this.level = HeadingLevel.h3,
    this.padding = const EdgeInsets.only(top: Space.md, bottom: Space.sm),
    this.color,
    super.key,
  });

  final String text;
  final HeadingLevel level;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = switch (level) {
      HeadingLevel.h1 => textTheme.headlineLarge,
      HeadingLevel.h2 => textTheme.headlineMedium,
      HeadingLevel.h3 => textTheme.titleLarge,
      HeadingLevel.h4 => textTheme.titleMedium,
    };
    return Padding(
      padding: padding,
      child: Semantics(
        header: true,
        child: Text(text, style: style?.copyWith(color: color)),
      ),
    );
  }
}
