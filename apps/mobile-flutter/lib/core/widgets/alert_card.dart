import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Urgent alert row: error-coloured left border, alert icon and text, all in
/// the accessible name ("Overdue, alert, 1:29 PM Atorvastatin not yet
/// confirmed"). Tapping opens the related item.
class AlertCard extends StatelessWidget {
  const AlertCard({required this.text, this.onTap, this.actionHint, super.key});

  final String text;
  final VoidCallback? onTap;

  /// What tapping does, for the screen-reader hint ("Opens the dose").
  final String? actionHint;

  @override
  Widget build(BuildContext context) {
    final colors = context.ccColors;
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        label: 'Alert: $text',
        hint: actionHint,
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(CcRadius.md),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(CcRadius.md),
            child: ExcludeSemantics(
              child: Container(
                constraints: const BoxConstraints(minHeight: TapTarget.icon),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: colors.error, width: 4),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.md,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: colors.error, size: 22),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Text(
                        text,
                        style: AppTypography.bodyEmphasis.copyWith(
                          color: colors.error,
                        ),
                      ),
                    ),
                    if (onTap != null)
                      Icon(Icons.chevron_right, color: colors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
