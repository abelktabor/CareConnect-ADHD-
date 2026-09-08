/**
 * Mock fixtures.
 *
 * GUARDRAIL: this data is deliberately and obviously fictional. Names are drawn
 * from placeholder conventions, emails use the reserved `example.test` domain,
 * phone numbers use the 555-01xx range reserved for fiction, and addresses are
 * invented. Nothing here may resemble a real person or real protected health
 * information (PHI), even as a placeholder. CareConnect is a course prototype,
 * not a medical device.
 */

import type {
  Appointment,
  Caregiver,
  DoseEvent,
  Medication,
  Patient,
  ReminderPreference,
  Task,
} from './types.ts';

export const PATIENT: Patient = {
  id: 'patient-0001',
  role: 'patient',
  displayName: 'Sam Example',
  email: 'sam@example.test',
  primaryCaregiverId: 'caregiver-0001',
  timeZone: 'America/New_York',
};

export const CAREGIVER: Caregiver = {
  id: 'caregiver-0001',
  role: 'caregiver',
  displayName: 'Alex Placeholder',
  email: 'alex@example.test',
  relationshipToPatient: 'your sister',
  patientIds: [PATIENT.id],
  phone: '555-0142',
};

export const MEDICATIONS: Medication[] = [
  {
    id: 'med-0001',
    patientId: PATIENT.id,
    name: 'Morning focus tablet',
    doseDescription: 'one white tablet',
    imageUrl: null,
    imageAlt: 'A round white tablet',
    scheduleTimes: ['08:00'],
    instructions: 'Take with breakfast.',
    active: true,
  },
  {
    id: 'med-0002',
    patientId: PATIENT.id,
    name: 'Afternoon booster',
    doseDescription: 'one small blue capsule',
    imageUrl: null,
    imageAlt: 'A small blue capsule',
    scheduleTimes: ['13:00'],
    instructions: null,
    active: true,
  },
  {
    id: 'med-0003',
    patientId: PATIENT.id,
    name: 'Evening vitamin',
    doseDescription: 'one yellow tablet',
    imageUrl: null,
    imageAlt: 'A yellow oval tablet',
    scheduleTimes: ['20:00'],
    instructions: 'Take with water.',
    active: true,
  },
];

export const DOSE_EVENTS: DoseEvent[] = [
  {
    id: 'dose-0001',
    medicationId: 'med-0001',
    patientId: PATIENT.id,
    scheduledFor: '2026-08-24T08:00:00-04:00',
    status: 'taken',
    recordedAt: '2026-08-24T08:06:00-04:00',
    undoableUntil: null,
  },
  {
    id: 'dose-0002',
    medicationId: 'med-0002',
    patientId: PATIENT.id,
    scheduledFor: '2026-08-24T13:00:00-04:00',
    status: 'due',
    recordedAt: null,
    undoableUntil: null,
  },
  {
    id: 'dose-0003',
    medicationId: 'med-0003',
    patientId: PATIENT.id,
    scheduledFor: '2026-08-24T20:00:00-04:00',
    status: 'due',
    recordedAt: null,
    undoableUntil: null,
  },
];

export const APPOINTMENTS: Appointment[] = [
  {
    id: 'appt-0001',
    patientId: PATIENT.id,
    title: 'Dentist — cleaning',
    startsAt: '2026-08-25T09:30:00-04:00',
    displayDate: 'Tuesday, August 25',
    locationName: 'Placeholder Dental',
    locationAddress: '100 Example Street, Sample City',
    accompaniedByCaregiverId: CAREGIVER.id,
    notes: 'Bring the insurance card.',
  },
  {
    id: 'appt-0002',
    patientId: PATIENT.id,
    title: 'Check-in with Dr. Placeholder',
    startsAt: '2026-08-28T14:00:00-04:00',
    displayDate: 'Friday, August 28',
    locationName: 'Sample City Clinic',
    locationAddress: '200 Example Avenue, Sample City',
    accompaniedByCaregiverId: null,
    notes: null,
  },
];

export const TASKS: Task[] = [
  {
    id: 'task-0001',
    patientId: PATIENT.id,
    title: 'Refill the week’s pill organizer',
    currentStepIndex: 1,
    completedAt: null,
    steps: [
      { id: 'step-1', instruction: 'Get the pill organizer from the kitchen shelf.', completedAt: '2026-08-24T18:00:00-04:00' },
      { id: 'step-2', instruction: 'Open the three medication bottles.', completedAt: null },
      { id: 'step-3', instruction: 'Fill one compartment for each day.', completedAt: null },
      { id: 'step-4', instruction: 'Put the organizer back on the shelf.', completedAt: null },
    ],
  },
];

export const REMINDER_PREFERENCES: ReminderPreference[] = [
  {
    id: 'reminder-0001',
    patientId: PATIENT.id,
    subject: 'medication',
    enabled: true,
    channel: 'in-app',
    leadTimeMinutes: 0,
    snoozeOptionsMinutes: [10, 30],
    maxRepeats: 2,
  },
  {
    id: 'reminder-0002',
    patientId: PATIENT.id,
    subject: 'appointment',
    enabled: true,
    channel: 'in-app',
    leadTimeMinutes: 60,
    snoozeOptionsMinutes: [15],
    maxRepeats: 1,
  },
];
