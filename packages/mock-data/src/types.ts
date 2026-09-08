/**
 * CareConnect domain types.
 *
 * Mirrors docs/DATA-MODEL.md. This package is the single source of truth for
 * the shape of the data across web, mobile, and desktop.
 */

export type Uuid = string;
/** ISO-8601 date, e.g. "2026-08-24" */
export type IsoDate = string;
/** ISO-8601 timestamp, e.g. "2026-08-24T08:05:00-04:00" */
export type IsoDateTime = string;
/** 24-hour local time, e.g. "08:00" */
export type LocalTime = string;

export type Role = 'patient' | 'caregiver';

export interface Person {
  id: Uuid;
  role: Role;
  /** Preferred name — what the orientation bar greets the user with. */
  displayName: string;
  /** Fictional email. Never a real address. */
  email: string;
}

export interface Patient extends Person {
  role: 'patient';
  /** The caregiver reachable from the persistent "Call my caregiver" action. */
  primaryCaregiverId: Uuid | null;
  timeZone: string;
}

export interface Caregiver extends Person {
  role: 'caregiver';
  /** Relationship shown to the patient, in plain language: "your sister". */
  relationshipToPatient: string;
  patientIds: Uuid[];
  phone: string;
}

export type DoseStatus = 'due' | 'taken' | 'skipped' | 'missed';

export interface Medication {
  id: Uuid;
  patientId: Uuid;
  /** Brand or common name as the patient recognizes it. */
  name: string;
  /** Plain-language dose — "one white tablet", never "1 tab PO QD". */
  doseDescription: string;
  /** Path to the pill image used for recognition over recall. */
  imageUrl: string | null;
  /** Alt text for the pill image (SC 1.1.1). */
  imageAlt: string | null;
  /** Local times the dose is due each day. */
  scheduleTimes: LocalTime[];
  /** Short plain-language note: "take with food". */
  instructions: string | null;
  active: boolean;
}

export interface DoseEvent {
  id: Uuid;
  medicationId: Uuid;
  patientId: Uuid;
  /** When the dose was scheduled for. */
  scheduledFor: IsoDateTime;
  status: DoseStatus;
  /** When the patient acted. Null while status is "due" or "missed". */
  recordedAt: IsoDateTime | null;
  /**
   * Undo window. Every state change offers a 10-second undo, so a mis-tap
   * never becomes something the patient has to ask a caregiver to fix.
   */
  undoableUntil: IsoDateTime | null;
}

export interface Appointment {
  id: Uuid;
  patientId: Uuid;
  /** Plain-language title: "Dentist — cleaning". */
  title: string;
  startsAt: IsoDateTime;
  /** Full-word display date: "Tuesday, August 25". Never "8/25". */
  displayDate: string;
  locationName: string;
  locationAddress: string;
  /** "Who is taking me" — answers the question without a phone call. */
  accompaniedByCaregiverId: Uuid | null;
  notes: string | null;
}

/** A multi-step task, presented as "Step 2 of 4" with save-and-resume. */
export interface Task {
  id: Uuid;
  patientId: Uuid;
  title: string;
  steps: TaskStep[];
  /** Index of the step to resume at. Persisted so work is never lost. */
  currentStepIndex: number;
  completedAt: IsoDateTime | null;
}

export interface TaskStep {
  id: Uuid;
  /** Short, direct instruction. One action per step. */
  instruction: string;
  completedAt: IsoDateTime | null;
}

export type ReminderChannel = 'in-app' | 'push';

/** User-controlled reminder settings — frequency and snooze are the user's call. */
export interface ReminderPreference {
  id: Uuid;
  patientId: Uuid;
  subject: 'medication' | 'appointment';
  enabled: boolean;
  channel: ReminderChannel;
  /** Minutes before the event to notify. */
  leadTimeMinutes: number;
  /** Snooze options offered, in minutes. Empty disables snooze. */
  snoozeOptionsMinutes: number[];
  /** Hard cap on repeats so reminders never become nagging. */
  maxRepeats: number;
}

export interface ActivityEntry {
  id: Uuid;
  patientId: Uuid;
  at: IsoDateTime;
  /** Plain-language summary for the caregiver timeline. */
  summary: string;
  kind: 'dose' | 'appointment' | 'task' | 'check-in';
}
