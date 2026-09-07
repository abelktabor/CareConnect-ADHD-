import 'package:careconnect_mobile/core/utils/date_formatting.dart';
import 'package:careconnect_mobile/data/mock_data.dart';
import 'package:careconnect_mobile/models/dose_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final day = DateTime(2026, 8, 25, 14, 14);
  final seed = MockData.seed(day);

  test('seeds relative to the given day', () {
    expect(seed.seededOn, DateTime(2026, 8, 25));
    final today = seed.doseEvents
        .where((d) => DateFormatting.isSameDay(d.scheduledFor, day))
        .toList();
    expect(today, hasLength(5));
    final yesterday = seed.doseEvents
        .where(
          (d) =>
              DateFormatting.isSameDay(d.scheduledFor, DateTime(2026, 8, 24)),
        )
        .toList();
    expect(yesterday, hasLength(5));
    expect(yesterday.every((d) => d.status == DoseStatus.taken), isTrue);
  });

  test('matches the Week 3 Figma story at 2:14 PM', () {
    final metformin = seed.doseById('dose-metformin')!;
    expect(metformin.scheduledFor, DateTime(2026, 8, 25, 14, 34));
    expect(metformin.isDue, isTrue);
    final atorvastatin = seed.doseById('dose-atorvastatin')!;
    expect(atorvastatin.isOverdue(day), isTrue);
    expect(seed.doseById('dose-lisinopril-am')!.status, DoseStatus.taken);
    expect(seed.doseById('dose-vitamin-d')!.status, DoseStatus.skipped);
    expect(
      seed.appointments.map((a) => a.title),
      contains('Dr. Alvarez — Cardiology follow-up'),
    );
  });

  test('every schedule time parses', () {
    for (final med in seed.medications) {
      for (final time in med.scheduleTimes) {
        expect(() => DateFormatting.parseLocalTime(time), returnsNormally);
      }
      expect(med.patientId, MockData.patientId);
    }
  });

  test('ids are unique across every collection', () {
    final ids = [
      ...seed.medications.map((m) => m.id),
      ...seed.doseEvents.map((d) => d.id),
      ...seed.appointments.map((a) => a.id),
      ...seed.activity.map((a) => a.id),
    ];
    expect(ids.toSet().length, ids.length);
  });

  test('data is obviously fictional — no real PHI', () {
    expect(seed.patient.email, endsWith('@example.test'));
    expect(seed.caregiver.phone, startsWith('555-01'));
    expect(seed.caregiver.patientIds, [seed.patient.id]);
    expect(seed.patient.primaryCaregiverId, seed.caregiver.id);
  });

  test('is a pure function of the day', () {
    final again = MockData.seed(DateTime(2026, 8, 25, 3));
    expect(again.doseEvents, equals(seed.doseEvents));
    final other = MockData.seed(DateTime(2026, 9, 6));
    expect(
      other.doseById('dose-metformin')!.scheduledFor,
      DateTime(2026, 9, 6, 14, 34),
    );
  });
}
