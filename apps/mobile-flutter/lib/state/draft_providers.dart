import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_store.dart';
import '../models/appointment.dart';
import '../models/drafts.dart';
import '../models/medication.dart';

/// What the autosave indicator shows. Announced through a live region so a
/// screen-reader user hears "Saving…" then "Saved" — never a silent colour
/// change (US-14).
enum AutosaveStatus {
  idle,
  saving,
  saved;

  String get label => switch (this) {
    AutosaveStatus.idle => '',
    AutosaveStatus.saving => 'Saving…',
    AutosaveStatus.saved => 'Saved',
  };
}

class AutosaveNotifier extends Notifier<AutosaveStatus> {
  @override
  AutosaveStatus build() => AutosaveStatus.idle;

  void set(AutosaveStatus status) => state = status;
}

final medicationAutosaveProvider =
    NotifierProvider<AutosaveNotifier, AutosaveStatus>(AutosaveNotifier.new);

final appointmentAutosaveProvider =
    NotifierProvider<AutosaveNotifier, AutosaveStatus>(AutosaveNotifier.new);

/// How long after the last keystroke the draft is written to disk.
const Duration kAutosaveDebounce = Duration(milliseconds: 400);

/// Autosaving draft for the Add / Edit Medication form.
class MedicationDraftNotifier extends Notifier<MedicationDraft> {
  Timer? _debounce;

  @override
  MedicationDraft build() {
    ref.onDispose(() => _debounce?.cancel());
    return ref
        .watch(localStoreProvider)
        .readAs(
          StoreKeys.medicationDraft,
          MedicationDraft.fromJson,
          orElse: MedicationDraft.new,
        );
  }

  /// Applies a change and schedules an autosave.
  void update(MedicationDraft Function(MedicationDraft draft) change) {
    state = change(state);
    _scheduleSave();
  }

  /// Starts a fresh draft, unless one is already in progress for a new
  /// medication — in which case the interrupted work is kept.
  Future<void> startNew() async {
    if (!state.isEditing && !state.isEmpty) return;
    await clear();
  }

  /// Starts (or resumes) editing an existing medication.
  Future<void> startEditing(Medication medication) async {
    if (state.editingId == medication.id) return;
    _debounce?.cancel();
    state = MedicationDraft(
      editingId: medication.id,
      name: medication.name,
      dosage: medication.dosage,
      scheduleTimes: medication.scheduleTimes,
      instructions: medication.instructions ?? '',
    );
    await _save();
  }

  /// Writes any pending change immediately.
  Future<void> flush() async {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      await _save();
    }
  }

  Future<void> clear() async {
    _debounce?.cancel();
    state = const MedicationDraft();
    await ref.read(localStoreProvider).remove(StoreKeys.medicationDraft);
    ref.read(medicationAutosaveProvider.notifier).set(AutosaveStatus.idle);
  }

  void _scheduleSave() {
    ref.read(medicationAutosaveProvider.notifier).set(AutosaveStatus.saving);
    _debounce?.cancel();
    _debounce = Timer(kAutosaveDebounce, () => unawaited(_save()));
  }

  Future<void> _save() async {
    await ref
        .read(localStoreProvider)
        .writeJson(StoreKeys.medicationDraft, state.toJson());
    if (ref.mounted) {
      ref.read(medicationAutosaveProvider.notifier).set(AutosaveStatus.saved);
    }
  }
}

final medicationDraftProvider =
    NotifierProvider<MedicationDraftNotifier, MedicationDraft>(
      MedicationDraftNotifier.new,
    );

/// Autosaving draft for the Add / Edit Appointment form.
class AppointmentDraftNotifier extends Notifier<AppointmentDraft> {
  Timer? _debounce;

  @override
  AppointmentDraft build() {
    ref.onDispose(() => _debounce?.cancel());
    return ref
        .watch(localStoreProvider)
        .readAs(
          StoreKeys.appointmentDraft,
          AppointmentDraft.fromJson,
          orElse: AppointmentDraft.new,
        );
  }

  void update(AppointmentDraft Function(AppointmentDraft draft) change) {
    state = change(state);
    _scheduleSave();
  }

  Future<void> startNew() async {
    if (!state.isEditing && !state.isEmpty) return;
    await clear();
  }

  Future<void> startEditing(Appointment appointment) async {
    if (state.editingId == appointment.id) return;
    _debounce?.cancel();
    state = AppointmentDraft(
      editingId: appointment.id,
      title: appointment.title,
      locationName: appointment.locationName,
      startsAt: appointment.startsAt,
      companionName: appointment.companionName ?? '',
    );
    await _save();
  }

  Future<void> flush() async {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      await _save();
    }
  }

  Future<void> clear() async {
    _debounce?.cancel();
    state = const AppointmentDraft();
    await ref.read(localStoreProvider).remove(StoreKeys.appointmentDraft);
    ref.read(appointmentAutosaveProvider.notifier).set(AutosaveStatus.idle);
  }

  void _scheduleSave() {
    ref.read(appointmentAutosaveProvider.notifier).set(AutosaveStatus.saving);
    _debounce?.cancel();
    _debounce = Timer(kAutosaveDebounce, () => unawaited(_save()));
  }

  Future<void> _save() async {
    await ref
        .read(localStoreProvider)
        .writeJson(StoreKeys.appointmentDraft, state.toJson());
    if (ref.mounted) {
      ref.read(appointmentAutosaveProvider.notifier).set(AutosaveStatus.saved);
    }
  }
}

final appointmentDraftProvider =
    NotifierProvider<AppointmentDraftNotifier, AppointmentDraft>(
      AppointmentDraftNotifier.new,
    );
