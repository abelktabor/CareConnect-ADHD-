import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_formatting.dart';
import '../models/activity_entry.dart';
import '../models/appointment.dart';
import '../models/dose_event.dart';
import '../models/medication.dart';
import '../models/person.dart';
import 'care_data_provider.dart';
import 'clock_provider.dart';

/// Read-only views over [careDataProvider], recomputed when the data or the
/// clock changes. Screens watch these instead of filtering lists themselves,
/// so the "what is my next action?" rule lives in exactly one place.

final patientProvider = Provider<Patient>(
  (ref) => ref.watch(careDataProvider).patient,
);

final caregiverProvider = Provider<Caregiver>(
  (ref) => ref.watch(careDataProvider).caregiver,
);

final activeMedicationsProvider = Provider<List<Medication>>(
  (ref) => ref.watch(careDataProvider).activeMedications,
);

final medicationByIdProvider = Provider.family<Medication?, String>(
  (ref, id) => ref.watch(careDataProvider).medicationById(id),
);

/// Today's doses for active medications, earliest first.
final todayDoseEventsProvider = Provider<List<DoseEvent>>((ref) {
  final data = ref.watch(careDataProvider);
  final now = ref.watch(currentTimeProvider);
  final activeIds = data.activeMedications.map((m) => m.id).toSet();
  final today =
      data.doseEvents
          .where(
            (d) =>
                activeIds.contains(d.medicationId) &&
                DateFormatting.isSameDay(d.scheduledFor, now),
          )
          .toList()
        ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
  return today;
});

/// The one dominant next action on the Today screen.
///
/// Rule: the earliest dose still to come today; if nothing is left to come,
/// the most recent overdue dose; otherwise nothing (all logged).
final nextActionDoseProvider = Provider<DoseEvent?>((ref) {
  final today = ref.watch(todayDoseEventsProvider);
  final now = ref.watch(currentTimeProvider);
  final due = today.where((d) => d.isDue).toList();
  for (final dose in due) {
    if (!dose.scheduledFor.isBefore(now)) return dose;
  }
  final overdue = due.where((d) => d.scheduledFor.isBefore(now)).toList();
  return overdue.isEmpty ? null : overdue.last;
});

/// Due doses after the next action ("Later today").
final laterTodayDosesProvider = Provider<List<DoseEvent>>((ref) {
  final today = ref.watch(todayDoseEventsProvider);
  final next = ref.watch(nextActionDoseProvider);
  if (next == null) return const [];
  return today
      .where(
        (d) =>
            d.isDue &&
            d.id != next.id &&
            d.scheduledFor.isAfter(next.scheduledFor),
      )
      .toList();
});

/// Doses whose time has passed without being logged, earliest first.
final overdueDosesProvider = Provider<List<DoseEvent>>((ref) {
  final today = ref.watch(todayDoseEventsProvider);
  final now = ref.watch(currentTimeProvider);
  return today.where((d) => d.isOverdue(now)).toList();
});

/// The dose that best describes a medication's status today, for the
/// Medications list: overdue first, then the next due, then the latest
/// logged one. Null when the medication has no dose today.
final medicationTodayDoseProvider = Provider.family<DoseEvent?, String>((
  ref,
  medicationId,
) {
  final today = ref
      .watch(todayDoseEventsProvider)
      .where((d) => d.medicationId == medicationId)
      .toList();
  if (today.isEmpty) return null;
  final now = ref.watch(currentTimeProvider);

  for (final dose in today) {
    if (dose.isOverdue(now)) return dose;
  }
  for (final dose in today) {
    if (dose.isDue) return dose;
  }
  final logged = today.where((d) => d.recordedAt != null).toList()
    ..sort((a, b) => b.recordedAt!.compareTo(a.recordedAt!));
  return logged.isEmpty ? today.last : logged.first;
});

/// Appointments from the start of today onwards, soonest first.
final upcomingAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final data = ref.watch(careDataProvider);
  final now = ref.watch(currentTimeProvider);
  final start = DateFormatting.startOfDay(now);
  return data.appointments.where((a) => !a.startsAt.isBefore(start)).toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
});

final appointmentByIdProvider = Provider.family<Appointment?, String>(
  (ref, id) => ref.watch(careDataProvider).appointmentById(id),
);

/// Activity Timeline filter.
enum ActivityFilter {
  all('All medications & appointments'),
  medications('Medications only'),
  appointments('Appointments only');

  const ActivityFilter(this.label);

  final String label;

  bool matches(ActivityKind kind) => switch (this) {
    ActivityFilter.all => true,
    ActivityFilter.medications => kind != ActivityKind.appointment,
    ActivityFilter.appointments => kind == ActivityKind.appointment,
  };
}

/// One day of timeline entries, newest first.
@immutable
class ActivityDay {
  const ActivityDay({required this.day, required this.entries});

  final DateTime day;
  final List<ActivityEntry> entries;
}

/// Timeline grouped by calendar day, newest day first.
final activityTimelineProvider =
    Provider.family<List<ActivityDay>, ActivityFilter>((ref, filter) {
      final entries =
          ref
              .watch(careDataProvider)
              .activity
              .where((e) => filter.matches(e.kind))
              .toList()
            ..sort((a, b) => b.at.compareTo(a.at));

      final groups = <DateTime, List<ActivityEntry>>{};
      for (final entry in entries) {
        groups
            .putIfAbsent(DateFormatting.startOfDay(entry.at), () => [])
            .add(entry);
      }
      final days =
          groups.entries
              .map((e) => ActivityDay(day: e.key, entries: e.value))
              .toList()
            ..sort((a, b) => b.day.compareTo(a.day));
      return days;
    });
