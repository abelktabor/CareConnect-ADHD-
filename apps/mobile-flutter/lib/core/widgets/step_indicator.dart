import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// "Step 1 of 3 — Medication details" with a progress bar filled to the
/// matching fraction (1/3, 2/3, 3/3), not just a step count.
///
/// The whole indicator is a live region: when the step changes, assistive
/// tech announces "Step 2 of 3, Schedule" without moving focus.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    required this.step,
    required this.totalSteps,
    required this.title,
    this.subtitle,
    super.key,
  }) : assert(step >= 1 && step <= totalSteps, 'step out of range');

  final int step;
  final int totalSteps;
  final String title;
  final String? subtitle;

  double get fraction => step / totalSteps;

  @override
  Widget build(BuildContext context) {
    final colors = context.ccColors;
    final theme = Theme.of(context);
    final heading = 'Step $step of $totalSteps — $title';

    return Semantics(
      liveRegion: true,
      label: 'Step $step of $totalSteps, $title',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: AppTypography.bodyEmphasis.copyWith(
              color: colors.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          const SizedBox(height: Space.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(CcRadius.sm),
            child: LinearProgressIndicator(value: fraction, minHeight: 8),
          ),
        ],
      ),
    );
  }
}
