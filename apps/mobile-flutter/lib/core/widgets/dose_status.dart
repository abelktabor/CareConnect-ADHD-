import 'package:flutter/material.dart';

import '../../models/dose_event.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatting.dart';

/// The fixed colour + icon pairing for each status. Colour is never the only
/// carrier of meaning (SC 1.4.1): every tone has an icon and a text label.
enum StatusTone {
  due(Icons.schedule),
  taken(Icons.check_circle),
  overdue(Icons.warning),
  skipped(Icons.cancel),
  missed(Icons.warning),
  info(Icons.info),
  success(Icons.check_circle);

  const StatusTone(this.icon);

  final IconData icon;

  Color color(CcColors colors) => switch (this) {
    StatusTone.due => colors.warning,
    StatusTone.taken => colors.success,
    StatusTone.success => colors.success,
    StatusTone.overdue => colors.error,
    StatusTone.missed => colors.error,
    StatusTone.skipped => colors.textSecondary,
    StatusTone.info => colors.info,
  };
}

/// How a dose reads on screen and to a screen reader.
@immutable
class DoseStatusPresentation {
  const DoseStatusPresentation({
    required this.tone,
    required this.label,
    required this.detail,
    required this.spoken,
  });

  /// Derives the presentation for [dose] at [now].
  factory DoseStatusPresentation.of(DoseEvent dose, DateTime now) {
    switch (dose.status) {
      case DoseStatus.due:
        if (dose.isOverdue(now)) {
          final late = DateFormatting.describeDuration(
            now.difference(dose.scheduledFor),
          );
          return DoseStatusPresentation(
            tone: StatusTone.overdue,
            label: 'Overdue',
            detail: DateFormatting.dueLabel(dose.scheduledFor, now),
            spoken: 'Overdue, $late late',
          );
        }
        final delta = dose.scheduledFor.difference(now);
        final spoken = delta > const Duration(hours: 3)
            ? 'Due at ${DateFormatting.clockTime(dose.scheduledFor)}'
            : 'Due in ${DateFormatting.describeDuration(delta)}';
        return DoseStatusPresentation(
          tone: StatusTone.due,
          label: 'Due',
          detail: DateFormatting.dueLabel(dose.scheduledFor, now),
          spoken: spoken,
        );
      case DoseStatus.taken:
        final at = DateFormatting.clockTime(
          dose.recordedAt ?? dose.scheduledFor,
        );
        return DoseStatusPresentation(
          tone: StatusTone.taken,
          label: 'Taken',
          detail: 'Taken at $at',
          spoken: 'Taken at $at',
        );
      case DoseStatus.skipped:
        final at = DateFormatting.clockTime(
          dose.recordedAt ?? dose.scheduledFor,
        );
        return DoseStatusPresentation(
          tone: StatusTone.skipped,
          label: 'Skipped',
          detail: 'Skipped at $at',
          spoken: 'Skipped at $at',
        );
      case DoseStatus.missed:
        final at = DateFormatting.clockTime(dose.scheduledFor);
        return DoseStatusPresentation(
          tone: StatusTone.missed,
          label: 'Missed',
          detail: 'Missed at $at',
          spoken: 'Missed at $at',
        );
    }
  }

  final StatusTone tone;

  /// "Due", "Taken", "Overdue", "Skipped"
  final String label;

  /// "Due in 20 min", "Taken at 8:04 AM", "Overdue — 45 min late"
  final String detail;

  /// Screen-reader phrasing with abbreviations expanded.
  final String spoken;

  /// "Due · Due in 20 min" — the visual chip text from the Figma.
  String get chipText => '$label · $detail';
}
