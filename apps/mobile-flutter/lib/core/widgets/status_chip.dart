import 'package:flutter/material.dart';

import '../../models/dose_event.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'dose_status.dart';

/// Icon + text status indicator. Never colour alone.
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.tone,
    required this.text,
    this.spoken,
    super.key,
  });

  /// Builds the chip for a dose at [now].
  factory StatusChip.dose(DoseEvent dose, DateTime now, {Key? key}) {
    final p = DoseStatusPresentation.of(dose, now);
    return StatusChip(
      key: key,
      tone: p.tone,
      text: p.chipText,
      spoken: 'Status: ${p.spoken}',
    );
  }

  final StatusTone tone;
  final String text;

  /// Screen-reader phrasing. Falls back to [text].
  final String? spoken;

  @override
  Widget build(BuildContext context) {
    final color = tone.color(context.ccColors);
    return Semantics(
      label: spoken ?? text,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tone.icon, size: 18, color: color),
          const SizedBox(width: Space.xs + 2),
          Flexible(
            child: Text(
              text,
              style: AppTypography.bodyEmphasis.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
