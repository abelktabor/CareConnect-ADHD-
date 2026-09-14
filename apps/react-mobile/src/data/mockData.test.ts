import { isSameDay } from '../core/utils/dateFormatting';
import { activeMedications, medicationById } from '../models/domain';
import { CAREGIVER_ID, PATIENT_ID, seedCareData } from './mockData';

describe('seedCareData', () => {
  const seedDay = new Date(2026, 7, 25, 14, 14);
  const data = seedCareData(seedDay);

  it('seeds the patient and caregiver from the mock roster', () => {
    expect(data.patient.id).toBe(PATIENT_ID);
    expect(data.caregiver.id).toBe(CAREGIVER_ID);
    expect(data.patient.primaryCaregiverId).toBe(CAREGIVER_ID);
  });

  it('seeds four active medications', () => {
    expect(activeMedications(data)).toHaveLength(4);
  });

  it('seeds doses for both yesterday and today', () => {
    const yesterday = new Date(2026, 7, 24);
    const hasYesterday = data.doseEvents.some((d) => isSameDay(d.scheduledFor, yesterday));
    const hasToday = data.doseEvents.some((d) => isSameDay(d.scheduledFor, seedDay));
    expect(hasYesterday).toBe(true);
    expect(hasToday).toBe(true);
  });

  it('matches the Week 3 Figma story: Metformin due soon, Atorvastatin overdue', () => {
    const metformin = data.doseEvents.find((d) => d.id === 'dose-metformin')!;
    const atorvastatin = data.doseEvents.find((d) => d.id === 'dose-atorvastatin')!;
    expect(metformin.status).toBe('due');
    expect(metformin.scheduledFor.getTime()).toBeGreaterThan(seedDay.getTime());
    expect(atorvastatin.status).toBe('due');
    expect(atorvastatin.scheduledFor.getTime()).toBeLessThan(seedDay.getTime());
  });

  it('seeds three upcoming appointments', () => {
    expect(data.appointments).toHaveLength(3);
    expect(medicationById(data, 'med-metformin')?.name).toBe('Metformin');
  });

  it('seeds a non-empty activity feed', () => {
    expect(data.activity.length).toBeGreaterThan(0);
  });

  it('is deterministic for the same seed day', () => {
    const again = seedCareData(seedDay);
    expect(again.doseEvents).toEqual(data.doseEvents);
  });
});
