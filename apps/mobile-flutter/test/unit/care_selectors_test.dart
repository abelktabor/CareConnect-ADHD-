import 'package:careconnect_mobile/core/utils/clock.dart';
import 'package:careconnect_mobile/data/local_store.dart';
import 'package:careconnect_mobile/models/activity_entry.dart';
import 'package:careconnect_mobile/models/dose_event.dart';
import 'package:careconnect_mobile/state/care_data_provider.dart';
import 'package:careconnect_mobile/state/care_selectors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('today’s doses are sorted and limited to active medications', () async {
    final container = await createContainer();
    final today = container.read(todayDoseEventsProvider);
    expect(today.map((d) => d.id), [
      'dose-lisinopril-am',
      'dose-vitamin-d',
      'dose-atorvastatin',
      'dose-metformin',
      'dose-lisinopril-pm',
    ]);
    await container
        .read(careDataProvider.notifier)
        .deleteMedication('med-metformin');
    expect(
      container.read(todayDoseEventsProvider).map((d) => d.id),
      isNot(contains('dose-metformin')),
    );
  });

  group('next action', () {
    test('is the earliest dose still to come (Metformin in 20 min)', () async {
      final container = await createContainer();
      expect(container.read(nextActionDoseProvider)!.id, 'dose-metformin');
      expect(container.read(laterTodayDosesProvider).map((d) => d.id), [
        'dose-lisinopril-pm',
      ]);
      expect(container.read(overdueDosesProvider).map((d) => d.id), [
        'dose-atorvastatin',
      ]);
    });

    test('falls back to the most recent overdue dose', () async {
      final container = await createContainer(
        clock: FixedClock.at(2026, 8, 25, 19),
      );
      expect(container.read(nextActionDoseProvider)!.id, 'dose-lisinopril-pm');
      expect(container.read(laterTodayDosesProvider), isEmpty);
      expect(container.read(overdueDosesProvider), hasLength(3));
    });

    test('is null once everything is logged', () async {
      final container = await createContainer();
      final notifier = container.read(careDataProvider.notifier);
      for (final id in [
        'dose-atorvastatin',
        'dose-metformin',
        'dose-lisinopril-pm',
      ]) {
        await notifier.markTaken(id);
      }
      expect(container.read(nextActionDoseProvider), isNull);
      expect(container.read(laterTodayDosesProvider), isEmpty);
      expect(container.read(overdueDosesProvider), isEmpty);
    });
  });

  group('medicationTodayDoseProvider', () {
    test('prefers overdue, then due, then the latest logged dose', () async {
      final container = await createContainer();
      expect(
        container
            .read(medicationTodayDoseProvider('med-atorvastatin'))!
            .isOverdue(kTestNow),
        isTrue,
      );
      expect(
        container.read(medicationTodayDoseProvider('med-lisinopril'))!.id,
        'dose-lisinopril-pm',
      );
      expect(
        container.read(medicationTodayDoseProvider('med-vitamin-d'))!.status,
        DoseStatus.skipped,
      );
      expect(container.read(medicationTodayDoseProvider('ghost')), isNull);

      await container
          .read(careDataProvider.notifier)
          .markTaken('dose-lisinopril-pm');
      expect(
        container.read(medicationTodayDoseProvider('med-lisinopril'))!.id,
        'dose-lisinopril-pm',
      );
    });
  });

  test('upcoming appointments exclude the past and are sorted', () async {
    final container = await createContainer();
    final upcoming = container.read(upcomingAppointmentsProvider);
    expect(upcoming.map((a) => a.id), ['appt-alvarez', 'appt-pt', 'appt-chen']);
    expect(
      container.read(appointmentByIdProvider('appt-pt'))!.locationName,
      'Riverside PT',
    );

    // Reload the same persisted data three days later: today's appointment
    // has passed and drops off the list.
    final prefs = await SharedPreferences.getInstance();
    final later = await createContainer(
      prefs: {StoreKeys.careData: prefs.getString(StoreKeys.careData)!},
      clock: FixedClock.at(2026, 8, 28),
    );
    expect(later.read(upcomingAppointmentsProvider).map((a) => a.id), [
      'appt-chen',
    ]);
  });

  group('activity timeline', () {
    test('groups by day, newest first', () async {
      final container = await createContainer();
      final days = container.read(activityTimelineProvider(ActivityFilter.all));
      expect(days.first.day, DateTime(2026, 8, 25));
      expect(days.last.day, DateTime(2026, 8, 24));
      final times = days.first.entries.map((e) => e.at).toList();
      expect(times, equals(List.of(times)..sort((a, b) => b.compareTo(a))));
    });

    test('filters medications vs appointments', () async {
      final container = await createContainer();
      final meds = container
          .read(activityTimelineProvider(ActivityFilter.medications))
          .expand((d) => d.entries);
      expect(meds.every((e) => e.kind != ActivityKind.appointment), isTrue);
      final appts = container
          .read(activityTimelineProvider(ActivityFilter.appointments))
          .expand((d) => d.entries);
      expect(appts.every((e) => e.kind == ActivityKind.appointment), isTrue);
      expect(appts, isNotEmpty);
      expect(ActivityFilter.all.label, 'All medications & appointments');
    });
  });

  test('patient and caregiver selectors', () async {
    final container = await createContainer();
    expect(container.read(patientProvider).displayName, 'Muhammad R.');
    expect(container.read(caregiverProvider).firstName, 'Renee');
    expect(container.read(activeMedicationsProvider), hasLength(4));
    expect(
      container.read(medicationByIdProvider('med-metformin'))!.dosage,
      '500 mg',
    );
  });
}
