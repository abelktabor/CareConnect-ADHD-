import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'dose_status.dart';

/// List row with a tone dot, bold title and plain-language subtitle.
///
/// Minimum 44pt tall; the whole row is one tap target.
class CcListItem extends StatelessWidget {
  const CcListItem({
    required this.title,
    this.subtitle,
    this.tone = StatusTone.info,
    this.dotColor,
    this.onTap,
    this.trailing,
    this.semanticHint,
    super.key,
  });

  final String title;
  final String? subtitle;
  final StatusTone tone;

  /// Overrides the tone colour for the leading dot (e.g. the role primary).
  final Color? dotColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ccColors;
    final dotColor = this.dotColor ?? tone.color(colors);

    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        hint: semanticHint,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CcRadius.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: TapTarget.icon),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.sm,
                vertical: 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ExcludeSemantics(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.bodyEmphasis.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty)
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: Space.sm),
                    trailing!,
                  ] else if (onTap != null)
                    Icon(Icons.chevron_right, color: colors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
