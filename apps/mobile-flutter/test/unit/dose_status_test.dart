import 'package:careconnect_mobile/core/theme/app_colors.dart';
import 'package:careconnect_mobile/core/widgets/dose_status.dart';
import 'package:careconnect_mobile/models/dose_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 25, 14, 14);
  DoseEvent dose(
    DateTime at, {
    DoseStatus status = DoseStatus.due,
    DateTime? recordedAt,
  }) => DoseEvent(
    id: 'd',
    medicationId: 'm',
    scheduledFor: at,
    status: status,
    recordedAt: recordedAt,
  );

  test('due soon → warning tone, clock icon, "Due · Due in 20 min"', () {
    final p = DoseStatusPresentation.of(
      dose(DateTime(2026, 8, 25, 14, 34)),
      now,
    );
    expect(p.tone, StatusTone.due);
    expect(p.tone.icon, Icons.schedule);
    expect(p.chipText, 'Due · Due in 20 min');
    expect(p.spoken, 'Due in 20 minutes');
  });

  test('due later today → "Due at 6:00 PM"', () {
    final p = DoseStatusPresentation.of(dose(DateTime(2026, 8, 25, 18)), now);
    expect(p.chipText, 'Due · Due at 6:00 PM');
    expect(p.spoken, 'Due at 6:00 PM');
  });

  test('overdue → error tone, "Overdue · Overdue — 45 min late"', () {
    final p = DoseStatusPresentation.of(
      dose(DateTime(2026, 8, 25, 13, 29)),
      now,
    );
    expect(p.tone, StatusTone.overdue);
    expect(p.label, 'Overdue');
    expect(p.chipText, 'Overdue · Overdue — 45 min late');
    expect(p.spoken, 'Overdue, 45 minutes late');
  });

  test('taken → success tone with the recorded time', () {
    final p = DoseStatusPresentation.of(
      dose(
        DateTime(2026, 8, 25, 8),
        status: DoseStatus.taken,
        recordedAt: DateTime(2026, 8, 25, 8, 4),
      ),
      now,
    );
    expect(p.tone, StatusTone.taken);
    expect(p.chipText, 'Taken · Taken at 8:04 AM');
    expect(p.tone.icon, Icons.check_circle);
  });

  test('skipped and missed', () {
    final skipped = DoseStatusPresentation.of(
      dose(
        DateTime(2026, 8, 25, 8),
        status: DoseStatus.skipped,
        recordedAt: DateTime(2026, 8, 25, 8, 15),
      ),
      now,
    );
    expect(skipped.chipText, 'Skipped · Skipped at 8:15 AM');
    expect(skipped.tone, StatusTone.skipped);
    final missed = DoseStatusPresentation.of(
      dose(DateTime(2026, 8, 24, 8), status: DoseStatus.missed),
      now,
    );
    expect(missed.chipText, 'Missed · Missed at 8:00 AM');
    expect(missed.tone, StatusTone.missed);
    // Falls back to the scheduled time when nothing was recorded.
    final takenNoTime = DoseStatusPresentation.of(
      dose(DateTime(2026, 8, 25, 9), status: DoseStatus.taken),
      now,
    );
    expect(takenNoTime.detail, 'Taken at 9:00 AM');
  });

  test('every tone resolves to a colour in both palettes', () {
    for (final tone in StatusTone.values) {
      expect(tone.color(CcColors.light), isA<Color>());
      expect(tone.color(CcColors.dark), isA<Color>());
    }
    expect(StatusTone.due.color(CcColors.light), AppColors.warning);
    expect(StatusTone.overdue.color(CcColors.light), AppColors.error);
    expect(StatusTone.success.color(CcColors.light), AppColors.success);
    expect(StatusTone.info.color(CcColors.dark), AppColors.darkInfo);
    expect(StatusTone.skipped.color(CcColors.light), AppColors.neutral700);
  });
}
