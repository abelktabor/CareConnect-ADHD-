/**
 * Autosaving drafts for the Add / Edit Medication and Add / Edit Appointment
 * forms. Persisted on every keystroke (debounced) and restored when the form
 * reopens, so leaving mid-way never costs progress.
 *
 * Port of lib/state/draft_providers.dart.
 */
import { create } from 'zustand';

import { remove, StoreKeys, writeJson } from '../data/localStore';
import {
  appointmentDraftIsEditing,
  appointmentDraftIsEmpty,
  medicationDraftIsEditing,
  medicationDraftIsEmpty,
} from '../models/domain';
import { appointmentDraftToJson, medicationDraftToJson } from '../models/serialization';
import {
  emptyAppointmentDraft,
  emptyMedicationDraft,
  type AppointmentDraft,
  type Appointment,
  type Medication,
  type MedicationDraft,
} from '../models/types';

export type AutosaveStatus = 'idle' | 'saving' | 'saved';

/** How long after the last keystroke the draft is written to disk. */
export const AUTOSAVE_DEBOUNCE_MS = 400;

interface DraftState {
  medicationDraft: MedicationDraft;
  medicationAutosave: AutosaveStatus;
  appointmentDraft: AppointmentDraft;
  appointmentAutosave: AutosaveStatus;

  hydrateMedicationDraft: (draft: MedicationDraft) => void;
  hydrateAppointmentDraft: (draft: AppointmentDraft) => void;

  updateMedicationDraft: (change: (draft: MedicationDraft) => MedicationDraft) => void;
  startNewMedicationDraft: () => Promise<void>;
  startEditingMedicationDraft: (medication: Medication) => Promise<void>;
  flushMedicationDraft: () => Promise<void>;
  clearMedicationDraft: () => Promise<void>;

  updateAppointmentDraft: (change: (draft: AppointmentDraft) => AppointmentDraft) => void;
  startNewAppointmentDraft: () => Promise<void>;
  startEditingAppointmentDraft: (appointment: Appointment) => Promise<void>;
  flushAppointmentDraft: () => Promise<void>;
  clearAppointmentDraft: () => Promise<void>;
}

// NOTE: guard these with `!= null`, never plain truthiness — a timer handle
// of `0` is a real, pending timer (it happens whenever one of these is the
// very first setTimeout created against a fresh clock, which is exactly
// what Jest's fake timers do between tests), and `if (debounce)` would skip
// cancelling it, letting a stale debounced save fire alongside the new one.
let medicationDebounce: ReturnType<typeof setTimeout> | null = null;
let appointmentDebounce: ReturnType<typeof setTimeout> | null = null;

export const useDraftStore = create<DraftState>((set, get) => {
  async function saveMedicationDraft(): Promise<void> {
    await writeJson(StoreKeys.medicationDraft, medicationDraftToJson(get().medicationDraft));
    set({ medicationAutosave: 'saved' });
  }

  async function saveAppointmentDraft(): Promise<void> {
    await writeJson(StoreKeys.appointmentDraft, appointmentDraftToJson(get().appointmentDraft));
    set({ appointmentAutosave: 'saved' });
  }

  return {
    medicationDraft: emptyMedicationDraft(),
    medicationAutosave: 'idle',
    appointmentDraft: emptyAppointmentDraft(),
    appointmentAutosave: 'idle',

    hydrateMedicationDraft: (draft) => set({ medicationDraft: draft }),
    hydrateAppointmentDraft: (draft) => set({ appointmentDraft: draft }),

    updateMedicationDraft: (change) => {
      set((state) => ({ medicationDraft: change(state.medicationDraft), medicationAutosave: 'saving' }));
      if (medicationDebounce != null) clearTimeout(medicationDebounce);
      medicationDebounce = setTimeout(() => {
        void saveMedicationDraft();
      }, AUTOSAVE_DEBOUNCE_MS);
    },

    startNewMedicationDraft: async () => {
      const draft = get().medicationDraft;
      if (!medicationDraftIsEditing(draft) && !medicationDraftIsEmpty(draft)) return;
      await get().clearMedicationDraft();
    },

    startEditingMedicationDraft: async (medication) => {
      if (get().medicationDraft.editingId === medication.id) return;
      if (medicationDebounce != null) clearTimeout(medicationDebounce);
      set({
        medicationDraft: {
          editingId: medication.id,
          step: 1,
          name: medication.name,
          dosage: medication.dosage,
          scheduleTimes: medication.scheduleTimes,
          instructions: medication.instructions ?? '',
        },
      });
      await saveMedicationDraft();
    },

    flushMedicationDraft: async () => {
      if (medicationDebounce == null) return;
      clearTimeout(medicationDebounce);
      medicationDebounce = null;
      await saveMedicationDraft();
    },

    clearMedicationDraft: async () => {
      if (medicationDebounce != null) clearTimeout(medicationDebounce);
      medicationDebounce = null;
      set({ medicationDraft: emptyMedicationDraft(), medicationAutosave: 'idle' });
      await remove(StoreKeys.medicationDraft);
    },

    updateAppointmentDraft: (change) => {
      set((state) => ({
        appointmentDraft: change(state.appointmentDraft),
        appointmentAutosave: 'saving',
      }));
      if (appointmentDebounce != null) clearTimeout(appointmentDebounce);
      appointmentDebounce = setTimeout(() => {
        void saveAppointmentDraft();
      }, AUTOSAVE_DEBOUNCE_MS);
    },

    startNewAppointmentDraft: async () => {
      const draft = get().appointmentDraft;
      if (!appointmentDraftIsEditing(draft) && !appointmentDraftIsEmpty(draft)) return;
      await get().clearAppointmentDraft();
    },

    startEditingAppointmentDraft: async (appointment) => {
      if (get().appointmentDraft.editingId === appointment.id) return;
      if (appointmentDebounce != null) clearTimeout(appointmentDebounce);
      set({
        appointmentDraft: {
          editingId: appointment.id,
          step: 1,
          title: appointment.title,
          locationName: appointment.locationName,
          startsAt: appointment.startsAt,
          companionName: appointment.companionName ?? '',
        },
      });
      await saveAppointmentDraft();
    },

    flushAppointmentDraft: async () => {
      if (appointmentDebounce == null) return;
      clearTimeout(appointmentDebounce);
      appointmentDebounce = null;
      await saveAppointmentDraft();
    },

    clearAppointmentDraft: async () => {
      if (appointmentDebounce != null) clearTimeout(appointmentDebounce);
      appointmentDebounce = null;
      set({ appointmentDraft: emptyAppointmentDraft(), appointmentAutosave: 'idle' });
      await remove(StoreKeys.appointmentDraft);
    },
  };
});
