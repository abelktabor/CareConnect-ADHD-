/**
 * Read-only views over `careDataStore`, recomputed from `data` and `now`.
 * Screens use these instead of filtering lists themselves, so the "what is
 * my next action?" rule lives in exactly one place.
 *
 * Each selector is exported twice: as a pure function (`get...`) for unit
 * tests, and as a hook (`use...`) that wires it to the live stores for
 * screens.
 *
 * Port of lib/state/care_selectors.dart.
 */
import { isSameDay, startOfDay } from '../core/utils/dateFormatting';
import { activeMedications, doseIsDue, doseIsOverdue } from '../models/domain';
import type {
  ActivityEntry,
  ActivityKind,
  Appointment,
  CareData,
  DoseEvent,
  Medication,
} from '../models/types';
import { useCareDataStore } from './careDataStore';
import { useClockStore } from './clockStore';

// ── People / medications (thin pass-throughs, kept for parity with the
//    Dart `patientProvider` / `caregiverProvider` / `activeMedicationsProvider`) ──

export function usePatient() {
  return useCareDataStore((s) => s.data.patient);
}

export function useCaregiver() {
  return useCareDataStore((s) => s.data.caregiver);
}

export function useActiveMedications(): Medication[] {
  const data = useCareDataStore((s) => s.data);
  return activeMedications(data);
}

export function useMedicationById(id: string): Medication | undefined {
  return useCareDataStore((s) => s.data.medications.find((m) => m.id === id));
}

export function useAppointmentById(id: string): Appointment | undefined {
  return useCareDataStore((s) => s.data.appointments.find((a) => a.id === id));
}

// ── Doses ────────────────────────────────────────────────────────────────

/** Today's doses for active medications, earliest first. */
export function getTodayDoseEvents(data: CareData, now: Date): DoseEvent[] {
  const activeIds = new Set(activeMedications(data).map((m) => m.id));
  return data.doseEvents
    .filter((d) => activeIds.has(d.medicationId) && isSameDay(d.scheduledFor, now))
    .sort((a, b) => a.scheduledFor.getTime() - b.scheduledFor.getTime());
}

export function useTodayDoseEvents(): DoseEvent[] {
  const data = useCareDataStore((s) => s.data);
  const now = useClockStore((s) => s.now);
  return getTodayDoseEvents(data, now);
}

/**
 * The one dominant next action on the Today screen.
 *
 * Rule: the earliest dose still to come today; if nothing is left to come,
 * the most recent overdue dose; otherwise undefined (all logged).
 */
export function getNextActionDose(today: DoseEvent[], now: Date): DoseEvent | undefined {
  const due = today.filter(doseIsDue);
  for (const dose of due) {
    if (!(dose.scheduledFor.getTime() < now.getTime())) return dose;
  }
  const overdue = due.filter((d) => d.scheduledFor.getTime() < now.getTime());
  return overdue.length === 0 ? undefined : overdue[overdue.length - 1];
}

export function useNextActionDose(): DoseEvent | undefined {
  const today = useTodayDoseEvents();
  const now = useClockStore((s) => s.now);
  return getNextActionDose(today, now);
}

/** Due doses after the next action ("Later today"). */
export function getLaterTodayDoses(today: DoseEvent[], next: DoseEvent | undefined): DoseEvent[] {
  if (next == null) return [];
  return today.filter(
    (d) => doseIsDue(d) && d.id !== next.id && d.scheduledFor.getTime() > next.scheduledFor.getTime(),
  );
}

export function useLaterTodayDoses(): DoseEvent[] {
  const today = useTodayDoseEvents();
  const next = useNextActionDose();
  return getLaterTodayDoses(today, next);
}

/** Doses whose time has passed without being logged, earliest first. */
export function getOverdueDoses(today: DoseEvent[], now: Date): DoseEvent[] {
  return today.filter((d) => doseIsOverdue(d, now));
}

export function useOverdueDoses(): DoseEvent[] {
  const today = useTodayDoseEvents();
  const now = useClockStore((s) => s.now);
  return getOverdueDoses(today, now);
}

/**
 * The dose that best describes a medication's status today, for the
 * Medications list: overdue first, then the next due, then the latest
 * logged one. Undefined when the medication has no dose today.
 */
export function getMedicationTodayDose(
  today: DoseEvent[],
  medicationId: string,
  now: Date,
): DoseEvent | undefined {
  const doses = today.filter((d) => d.medicationId === medicationId);
  if (doses.length === 0) return undefined;

  for (const dose of doses) {
    if (doseIsOverdue(dose, now)) return dose;
  }
  for (const dose of doses) {
    if (doseIsDue(dose)) return dose;
  }
  const logged = doses
    .filter((d) => d.recordedAt != null)
    .sort((a, b) => b.recordedAt!.getTime() - a.recordedAt!.getTime());
  return logged.length === 0 ? doses[doses.length - 1] : logged[0];
}

export function useMedicationTodayDose(medicationId: string): DoseEvent | undefined {
  const today = useTodayDoseEvents();
  const now = useClockStore((s) => s.now);
  return getMedicationTodayDose(today, medicationId, now);
}

// ── Appointments ─────────────────────────────────────────────────────────

/** Appointments from the start of today onwards, soonest first. */
export function getUpcomingAppointments(data: CareData, now: Date): Appointment[] {
  const start = startOfDay(now);
  return data.appointments
    .filter((a) => !(a.startsAt.getTime() < start.getTime()))
    .sort((a, b) => a.startsAt.getTime() - b.startsAt.getTime());
}

export function useUpcomingAppointments(): Appointment[] {
  const data = useCareDataStore((s) => s.data);
  const now = useClockStore((s) => s.now);
  return getUpcomingAppointments(data, now);
}

// ── Activity timeline ────────────────────────────────────────────────────

export type ActivityFilter = 'all' | 'medications' | 'appointments';

export const ACTIVITY_FILTER_LABELS: Record<ActivityFilter, string> = {
  all: 'All medications & appointments',
  medications: 'Medications only',
  appointments: 'Appointments only',
};

export function activityFilterMatches(filter: ActivityFilter, kind: ActivityKind): boolean {
  switch (filter) {
    case 'all':
      return true;
    case 'medications':
      return kind !== 'appointment';
    case 'appointments':
      return kind === 'appointment';
  }
}

/** One day of timeline entries, newest first. */
export interface ActivityDay {
  day: Date;
  entries: ActivityEntry[];
}

/** Timeline grouped by calendar day, newest day first. */
export function getActivityTimeline(data: CareData, filter: ActivityFilter): ActivityDay[] {
  const entries = data.activity
    .filter((e) => activityFilterMatches(filter, e.kind))
    .sort((a, b) => b.at.getTime() - a.at.getTime());

  const groups = new Map<number, ActivityDay>();
  for (const entry of entries) {
    const dayStart = startOfDay(entry.at);
    const key = dayStart.getTime();
    const existing = groups.get(key);
    if (existing) {
      existing.entries.push(entry);
    } else {
      groups.set(key, { day: dayStart, entries: [entry] });
    }
  }
  return [...groups.values()].sort((a, b) => b.day.getTime() - a.day.getTime());
}

export function useActivityTimeline(filter: ActivityFilter): ActivityDay[] {
  const data = useCareDataStore((s) => s.data);
  return getActivityTimeline(data, filter);
}
