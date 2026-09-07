import '../core/utils/date_formatting.dart';
import '../models/activity_entry.dart';
import '../models/appointment.dart';
import '../models/care_data.dart';
import '../models/dose_event.dart';
import '../models/medication.dart';
import '../models/person.dart';

/// Fixtures matching the Week 3 Figma frames.
///
/// GUARDRAIL: deliberately and obviously fictional. Emails use the reserved
/// `example.test` domain and phone numbers the 555-01xx range reserved for
/// fiction. Nothing here may resemble a real person or real protected health
/// information (PHI) — CareConnect is a course prototype, not a medical device.
///
/// Dates are generated relative to [seedDay] so the story ("Metformin due in
/// 20 minutes at 2:14 PM, Atorvastatin 45 minutes overdue") holds on whatever
/// day the app is first opened. With the demo clock on, [seedDay] is
/// Tuesday, August 25 and the screens reproduce the Figma exactly.
abstract final class MockData {
  static const String patientId = 'patient-0001';
  static const String caregiverId = 'caregiver-0001';

  static const Patient patient = Patient(
    id: patientId,
    displayName: 'Muhammad R.',
    firstName: 'Muhammad',
    email: 'muhammad@example.test',
    primaryCaregiverId: caregiverId,
  );

  static const Caregiver caregiver = Caregiver(
    id: caregiverId,
    displayName: 'Renee',
    firstName: 'Renee',
    relationshipToPatient: 'your caregiver',
    phone: '555-0142',
    patientIds: [patientId],
  );

  static const List<Medication> medications = [
    Medication(
      id: 'med-metformin',
      patientId: patientId,
      name: 'Metformin',
      dosage: '500 mg',
      scheduleTimes: ['14:34'],
      instructions: 'Take with food.',
    ),
    Medication(
      id: 'med-lisinopril',
      patientId: patientId,
      name: 'Lisinopril',
      dosage: '10 mg',
      scheduleTimes: ['08:00', '18:00'],
    ),
    Medication(
      id: 'med-atorvastatin',
      patientId: patientId,
      name: 'Atorvastatin',
      dosage: '20 mg',
      scheduleTimes: ['13:29'],
    ),
    Medication(
      id: 'med-vitamin-d',
      patientId: patientId,
      name: 'Vitamin D',
      dosage: '1000 IU',
      scheduleTimes: ['08:00'],
      instructions: 'Take with breakfast.',
    ),
  ];

  /// Builds the full seed for the calendar day containing [seedDay].
  static CareData seed(DateTime seedDay) {
    final day = DateFormatting.startOfDay(seedDay);
    final yesterday = day.subtract(const Duration(days: 1));

    DateTime at(DateTime d, int hour, int minute) =>
        DateTime(d.year, d.month, d.day, hour, minute);

    final doseEvents = <DoseEvent>[
      // Yesterday: everything logged, so the caregiver timeline has history.
      DoseEvent(
        id: 'dose-y-lisinopril-am',
        medicationId: 'med-lisinopril',
        scheduledFor: at(yesterday, 8, 0),
        status: DoseStatus.taken,
        recordedAt: at(yesterday, 8, 2),
      ),
      DoseEvent(
        id: 'dose-y-vitamin-d',
        medicationId: 'med-vitamin-d',
        scheduledFor: at(yesterday, 8, 0),
        status: DoseStatus.taken,
        recordedAt: at(yesterday, 8, 3),
      ),
      DoseEvent(
        id: 'dose-y-atorvastatin',
        medicationId: 'med-atorvastatin',
        scheduledFor: at(yesterday, 13, 29),
        status: DoseStatus.taken,
        recordedAt: at(yesterday, 13, 40),
      ),
      DoseEvent(
        id: 'dose-y-metformin',
        medicationId: 'med-metformin',
        scheduledFor: at(yesterday, 14, 34),
        status: DoseStatus.taken,
        recordedAt: at(yesterday, 14, 30),
      ),
      DoseEvent(
        id: 'dose-y-lisinopril-pm',
        medicationId: 'med-lisinopril',
        scheduledFor: at(yesterday, 18, 0),
        status: DoseStatus.taken,
        recordedAt: at(yesterday, 18, 12),
      ),
      // Today, as drawn in the Figma at 2:14 PM.
      DoseEvent(
        id: 'dose-lisinopril-am',
        medicationId: 'med-lisinopril',
        scheduledFor: at(day, 8, 0),
        status: DoseStatus.taken,
        recordedAt: at(day, 8, 4),
      ),
      DoseEvent(
        id: 'dose-vitamin-d',
        medicationId: 'med-vitamin-d',
        scheduledFor: at(day, 8, 0),
        status: DoseStatus.skipped,
        recordedAt: at(day, 8, 15),
      ),
      DoseEvent(
        id: 'dose-atorvastatin',
        medicationId: 'med-atorvastatin',
        scheduledFor: at(day, 13, 29),
      ),
      DoseEvent(
        id: 'dose-metformin',
        medicationId: 'med-metformin',
        scheduledFor: at(day, 14, 34),
      ),
      DoseEvent(
        id: 'dose-lisinopril-pm',
        medicationId: 'med-lisinopril',
        scheduledFor: at(day, 18, 0),
      ),
    ];

    final appointments = <Appointment>[
      Appointment(
        id: 'appt-alvarez',
        patientId: patientId,
        title: 'Dr. Alvarez — Cardiology follow-up',
        startsAt: at(day, 14, 30),
        locationName: 'Regional Medical',
        companionName: 'Renee',
        notes: 'Bring the medication list.',
      ),
      Appointment(
        id: 'appt-pt',
        patientId: patientId,
        title: 'Physical therapy',
        startsAt: at(day.add(const Duration(days: 2)), 10, 0),
        locationName: 'Riverside PT',
        companionName: 'Renee',
      ),
      Appointment(
        id: 'appt-chen',
        patientId: patientId,
        title: 'Dr. Chen — Primary care',
        startsAt: at(day.add(const Duration(days: 7)), 9, 15),
        locationName: 'Community Health',
      ),
    ];

    final activity = <ActivityEntry>[
      ActivityEntry(
        id: 'act-01',
        at: at(day, 8, 4),
        summary: 'Muhammad logged Lisinopril taken at 8:04 AM',
        kind: ActivityKind.dose,
      ),
      ActivityEntry(
        id: 'act-02',
        at: at(day, 8, 15),
        summary: 'Muhammad skipped Vitamin D at 8:15 AM',
        kind: ActivityKind.dose,
      ),
      ActivityEntry(
        id: 'act-03',
        at: at(day, 12, 0),
        summary: 'Reminder sent for 6:00 PM Lisinopril dose',
        kind: ActivityKind.reminder,
      ),
      ActivityEntry(
        id: 'act-04',
        at: at(day, 13, 5),
        summary: 'Muhammad updated the appointment time to 2:30 PM',
        kind: ActivityKind.appointment,
      ),
      ActivityEntry(
        id: 'act-05',
        at: at(yesterday, 9, 30),
        summary: 'Muhammad confirmed the 2:30 PM cardiology appointment',
        kind: ActivityKind.appointment,
      ),
      ActivityEntry(
        id: 'act-06',
        at: at(yesterday, 11, 15),
        summary: 'Renee added a note to Lisinopril',
        kind: ActivityKind.note,
      ),
      ActivityEntry(
        id: 'act-07',
        at: at(yesterday, 16, 45),
        summary: 'Muhammad marked the Atorvastatin refill step complete',
        kind: ActivityKind.task,
      ),
    ];

    return CareData(
      patient: patient,
      caregiver: caregiver,
      medications: medications,
      doseEvents: doseEvents,
      appointments: appointments,
      activity: activity,
      seededOn: day,
    );
  }
}
