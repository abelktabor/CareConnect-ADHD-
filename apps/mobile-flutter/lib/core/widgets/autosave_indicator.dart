import 'package:flutter/material.dart';

import '../../state/draft_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// "Saving…" / "Saved" with a dot, announced through a polite live region.
class AutosaveIndicator extends StatelessWidget {
  const AutosaveIndicator({required this.status, super.key});

  final AutosaveStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.ccColors;
    if (status == AutosaveStatus.idle) {
      // Keep the slot so the layout does not jump when saving starts.
      return const SizedBox(height: 24);
    }
    final saved = status == AutosaveStatus.saved;
    final color = saved ? colors.success : colors.textSecondary;
    return Semantics(
      liveRegion: true,
      label: saved ? 'Saved' : 'Saving',
      excludeSemantics: true,
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            Icon(
              saved ? Icons.check_circle : Icons.circle,
              size: 14,
              color: color,
            ),
            const SizedBox(width: Space.sm),
            Text(
              status.label,
              style: AppTypography.bodyEmphasis.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
