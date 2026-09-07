import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/date_formatting.dart';

/// Day, time and the single next thing to do — always visible at the top of
/// the Today screen so the user never has to hold orientation in their head.
///
/// Exposed as a landmark-style live region: "Tuesday, August 25, 2:14 PM.
/// Next: Metformin in 20 minutes."
class OrientationBar extends StatelessWidget {
  const OrientationBar({required this.now, required this.nextLine, super.key});

  final DateTime now;

  /// "Next: Metformin in 20 minutes" or a calm all-done line.
  final String nextLine;

  @override
  Widget build(BuildContext context) {
    final colors = context.ccColors;
    final theme = Theme.of(context);
    final dateLine =
        '${DateFormatting.fullWordDate(now)} · '
        '${DateFormatting.clockTime(now)}';

    return Semantics(
      container: true,
      liveRegion: true,
      label:
          '${DateFormatting.fullWordDate(now)}, '
          '${DateFormatting.clockTime(now)}. $nextLine',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.md,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLine,
                style: AppTypography.bodyEmphasis.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              Text(
                nextLine,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
