import { seedCareData } from '../data/mockData';
import {
  activityFilterMatches,
  getActivityTimeline,
  getLaterTodayDoses,
  getMedicationTodayDose,
  getNextActionDose,
  getOverdueDoses,
  getTodayDoseEvents,
  getUpcomingAppointments,
} from './selectors';

const NOW = new Date(2026, 7, 25, 14, 14);
const data = seedCareData(NOW);

describe('getTodayDoseEvents', () => {
  it('returns only today\'s doses, sorted earliest first', () => {
    const today = getTodayDoseEvents(data, NOW);
    expect(today.every((d) => d.scheduledFor.getDate() === 25)).toBe(true);
    const times = today.map((d) => d.scheduledFor.getTime());
    expect(times).toEqual([...times].sort((a, b) => a - b));
  });
});

describe('getNextActionDose', () => {
  it('picks the earliest still-upcoming due dose', () => {
    const today = getTodayDoseEvents(data, NOW);
    const next = getNextActionDose(today, NOW);
    // Atorvastatin (13:29) is already overdue by 14:14; Metformin (14:34) is next up.
    expect(next?.medicationId).toBe('med-metformin');
  });

  it('falls back to the latest overdue dose when nothing is left to come', () => {
    // At 7 PM, every dose for today has either been logged or has passed.
    const lateNow = new Date(2026, 7, 25, 19, 0);
    const today = getTodayDoseEvents(data, lateNow);
    const next = getNextActionDose(today, lateNow);
    expect(next?.status).toBe('due');
    expect(next!.scheduledFor.getTime()).toBeLessThan(lateNow.getTime());
  });

  it('returns undefined once every dose is logged', () => {
    const allLogged = getTodayDoseEvents(data, NOW).map((d) => ({ ...d, status: 'taken' as const }));
    expect(getNextActionDose(allLogged, NOW)).toBeUndefined();
  });
});

describe('getLaterTodayDoses', () => {
  it('excludes the next dose itself and anything before it', () => {
    const today = getTodayDoseEvents(data, NOW);
    const next = getNextActionDose(today, NOW)!;
    const later = getLaterTodayDoses(today, next);
    expect(later.some((d) => d.id === next.id)).toBe(false);
    expect(later.every((d) => d.scheduledFor.getTime() > next.scheduledFor.getTime())).toBe(true);
  });

  it('is empty when there is no next dose', () => {
    expect(getLaterTodayDoses([], undefined)).toEqual([]);
  });
});

describe('getOverdueDoses', () => {
  it('returns due doses whose time has passed', () => {
    const today = getTodayDoseEvents(data, NOW);
    const overdue = getOverdueDoses(today, NOW);
    expect(overdue.map((d) => d.medicationId)).toEqual(['med-atorvastatin']);
  });
});

describe('getMedicationTodayDose', () => {
  const today = getTodayDoseEvents(data, NOW);

  it('prefers an overdue dose', () => {
    expect(getMedicationTodayDose(today, 'med-atorvastatin', NOW)?.status).toBe('due');
    expect(getMedicationTodayDose(today, 'med-atorvastatin', NOW)?.medicationId).toBe(
      'med-atorvastatin',
    );
  });

  it('falls back to a due (not yet overdue) dose', () => {
    expect(getMedicationTodayDose(today, 'med-metformin', NOW)?.status).toBe('due');
  });

  it('falls back to the latest logged dose when nothing is due', () => {
    const dose = getMedicationTodayDose(today, 'med-vitamin-d', NOW);
    expect(dose?.status).toBe('skipped');
  });

  it('returns undefined for a medication with no dose today', () => {
    expect(getMedicationTodayDose(today, 'not-a-medication', NOW)).toBeUndefined();
  });
});

describe('getUpcomingAppointments', () => {
  it('includes only appointments from today onward, soonest first', () => {
    const upcoming = getUpcomingAppointments(data, NOW);
    expect(upcoming).toHaveLength(3);
    const times = upcoming.map((a) => a.startsAt.getTime());
    expect(times).toEqual([...times].sort((a, b) => a - b));
  });
});

describe('activity timeline', () => {
  it('matches filters correctly', () => {
    expect(activityFilterMatches('all', 'dose')).toBe(true);
    expect(activityFilterMatches('all', 'appointment')).toBe(true);
    expect(activityFilterMatches('medications', 'appointment')).toBe(false);
    expect(activityFilterMatches('medications', 'dose')).toBe(true);
    expect(activityFilterMatches('appointments', 'dose')).toBe(false);
    expect(activityFilterMatches('appointments', 'appointment')).toBe(true);
  });

  it('groups entries by day, newest day first, newest entry first within a day', () => {
    const days = getActivityTimeline(data, 'all');
    expect(days.length).toBeGreaterThanOrEqual(2);
    const dayTimes = days.map((d) => d.day.getTime());
    expect(dayTimes).toEqual([...dayTimes].sort((a, b) => b - a));
    for (const day of days) {
      const entryTimes = day.entries.map((e) => e.at.getTime());
      expect(entryTimes).toEqual([...entryTimes].sort((a, b) => b - a));
    }
  });

  it('the appointments-only filter drops dose and note entries', () => {
    const days = getActivityTimeline(data, 'appointments');
    const allEntries = days.flatMap((d) => d.entries);
    expect(allEntries.every((e) => e.kind === 'appointment')).toBe(true);
    expect(allEntries.length).toBeGreaterThan(0);
  });
});
