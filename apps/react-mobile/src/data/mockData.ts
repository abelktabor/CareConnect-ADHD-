/**
 * Fixtures matching the Week 3 Figma frames.
 *
 * GUARDRAIL: deliberately and obviously fictional. Emails use the reserved
 * `example.test` domain and phone numbers the 555-01xx range reserved for
 * fiction. Nothing here may resemble a real person or real protected health
 * information (PHI) — CareConnect is a course prototype, not a medical device.
 *
 * Dates are generated relative to `seedDay` so the story ("Metformin due in
 * 20 minutes at 2:14 PM, Atorvastatin 45 minutes overdue") holds on whatever
 * day the app is first opened. With the demo clock on, `seedDay` is
 * Tuesday, August 25 and the screens reproduce the Figma exactly.
 *
 * Port of lib/data/mock_data.dart.
 */
import { startOfDay } from '../core/utils/dateFormatting';
import type {
  ActivityEntry,
  Appointment,
  Caregiver,
  CareData,
  DoseEvent,
  Medication,
  Patient,
} from '../models/types';

export const PATIENT_ID = 'patient-0001';
export const CAREGIVER_ID = 'caregiver-0001';

export const mockPatient: Patient = {
  id: PATIENT_ID,
  displayName: 'Muhammad R.',
  firstName: 'Muhammad',
  email: 'muhammad@example.test',
  primaryCaregiverId: CAREGIVER_ID,
};

export const mockCaregiver: Caregiver = {
  id: CAREGIVER_ID,
  displayName: 'Renee',
  firstName: 'Renee',
  relationshipToPatient: 'your caregiver',
  phone: '555-0142',
  patientIds: [PATIENT_ID],
};

export const mockMedications: Medication[] = [
  {
    id: 'med-metformin',
    patientId: PATIENT_ID,
    name: 'Metformin',
    dosage: '500 mg',
    scheduleTimes: ['14:34'],
    instructions: 'Take with food.',
    active: true,
  },
  {
    id: 'med-lisinopril',
    patientId: PATIENT_ID,
    name: 'Lisinopril',
    dosage: '10 mg',
    scheduleTimes: ['08:00', '18:00'],
    active: true,
  },
  {
    id: 'med-atorvastatin',
    patientId: PATIENT_ID,
    name: 'Atorvastatin',
    dosage: '20 mg',
    scheduleTimes: ['13:29'],
    active: true,
  },
  {
    id: 'med-vitamin-d',
    patientId: PATIENT_ID,
    name: 'Vitamin D',
    dosage: '1000 IU',
    scheduleTimes: ['08:00'],
    instructions: 'Take with breakfast.',
    active: true,
  },
];

function at(day: Date, hour: number, minute: number): Date {
  return new Date(day.getFullYear(), day.getMonth(), day.getDate(), hour, minute);
}

function addDays(day: Date, amount: number): Date {
  return new Date(day.getFullYear(), day.getMonth(), day.getDate() + amount);
}

/** Builds the full seed for the calendar day containing `seedDay`. */
export function seedCareData(seedDay: Date): CareData {
  const day = startOfDay(seedDay);
  const yesterday = addDays(day, -1);

  const doseEvents: DoseEvent[] = [
    // Yesterday: everything logged, so the caregiver timeline has history.
    {
      id: 'dose-y-lisinopril-am',
      medicationId: 'med-lisinopril',
      scheduledFor: at(yesterday, 8, 0),
      status: 'taken',
      recordedAt: at(yesterday, 8, 2),
    },
    {
      id: 'dose-y-vitamin-d',
      medicationId: 'med-vitamin-d',
      scheduledFor: at(yesterday, 8, 0),
      status: 'taken',
      recordedAt: at(yesterday, 8, 3),
    },
    {
      id: 'dose-y-atorvastatin',
      medicationId: 'med-atorvastatin',
      scheduledFor: at(yesterday, 13, 29),
      status: 'taken',
      recordedAt: at(yesterday, 13, 40),
    },
    {
      id: 'dose-y-metformin',
      medicationId: 'med-metformin',
      scheduledFor: at(yesterday, 14, 34),
      status: 'taken',
      recordedAt: at(yesterday, 14, 30),
    },
    {
      id: 'dose-y-lisinopril-pm',
      medicationId: 'med-lisinopril',
      scheduledFor: at(yesterday, 18, 0),
      status: 'taken',
      recordedAt: at(yesterday, 18, 12),
    },
    // Today, as drawn in the Figma at 2:14 PM.
    {
      id: 'dose-lisinopril-am',
      medicationId: 'med-lisinopril',
      scheduledFor: at(day, 8, 0),
      status: 'taken',
      recordedAt: at(day, 8, 4),
    },
    {
      id: 'dose-vitamin-d',
      medicationId: 'med-vitamin-d',
      scheduledFor: at(day, 8, 0),
      status: 'skipped',
      recordedAt: at(day, 8, 15),
    },
    {
      id: 'dose-atorvastatin',
      medicationId: 'med-atorvastatin',
      scheduledFor: at(day, 13, 29),
      status: 'due',
    },
    {
      id: 'dose-metformin',
      medicationId: 'med-metformin',
      scheduledFor: at(day, 14, 34),
      status: 'due',
    },
    {
      id: 'dose-lisinopril-pm',
      medicationId: 'med-lisinopril',
      scheduledFor: at(day, 18, 0),
      status: 'due',
    },
  ];

  const appointments: Appointment[] = [
    {
      id: 'appt-alvarez',
      patientId: PATIENT_ID,
      title: 'Dr. Alvarez — Cardiology follow-up',
      startsAt: at(day, 14, 30),
      locationName: 'Regional Medical',
      companionName: 'Renee',
      notes: 'Bring the medication list.',
    },
    {
      id: 'appt-pt',
      patientId: PATIENT_ID,
      title: 'Physical therapy',
      startsAt: at(addDays(day, 2), 10, 0),
      locationName: 'Riverside PT',
      companionName: 'Renee',
    },
    {
      id: 'appt-chen',
      patientId: PATIENT_ID,
      title: 'Dr. Chen — Primary care',
      startsAt: at(addDays(day, 7), 9, 15),
      locationName: 'Community Health',
    },
  ];

  const activity: ActivityEntry[] = [
    {
      id: 'act-01',
      at: at(day, 8, 4),
      summary: 'Muhammad logged Lisinopril taken at 8:04 AM',
      kind: 'dose',
    },
    {
      id: 'act-02',
      at: at(day, 8, 15),
      summary: 'Muhammad skipped Vitamin D at 8:15 AM',
      kind: 'dose',
    },
    {
      id: 'act-03',
      at: at(day, 12, 0),
      summary: 'Reminder sent for 6:00 PM Lisinopril dose',
      kind: 'reminder',
    },
    {
      id: 'act-04',
      at: at(day, 13, 5),
      summary: 'Muhammad updated the appointment time to 2:30 PM',
      kind: 'appointment',
    },
    {
      id: 'act-05',
      at: at(yesterday, 9, 30),
      summary: 'Muhammad confirmed the 2:30 PM cardiology appointment',
      kind: 'appointment',
    },
    {
      id: 'act-06',
      at: at(yesterday, 11, 15),
      summary: 'Renee added a note to Lisinopril',
      kind: 'note',
    },
    {
      id: 'act-07',
      at: at(yesterday, 16, 45),
      summary: 'Muhammad marked the Atorvastatin refill step complete',
      kind: 'task',
    },
  ];

  return {
    patient: mockPatient,
    caregiver: mockCaregiver,
    medications: mockMedications,
    doseEvents,
    appointments,
    activity,
    seededOn: day,
  };
}
