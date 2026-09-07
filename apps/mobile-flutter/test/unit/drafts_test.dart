import 'package:careconnect_mobile/data/local_store.dart';
import 'package:careconnect_mobile/data/mock_data.dart';
import 'package:careconnect_mobile/models/drafts.dart';
import 'package:careconnect_mobile/state/draft_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

Future<void> settle() =>
    Future<void>.delayed(kAutosaveDebounce + const Duration(milliseconds: 50));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('medication draft', () {
    test('autosaves after the debounce and reports Saving → Saved', () async {
      final container = await createContainer();
      final notifier = container.read(medicationDraftProvider.notifier);

      notifier.update((d) => d.copyWith(name: 'Metoprolol'));
      expect(container.read(medicationAutosaveProvider), AutosaveStatus.saving);
      notifier.update((d) => d.copyWith(dosage: '25 mg'));
      await settle();

      expect(container.read(medicationAutosaveProvider), AutosaveStatus.saved);
      final prefs = await SharedPreferences.getInstance();
      final reloaded = await createContainer(
        prefs: {
          StoreKeys.medicationDraft: prefs.getString(
            StoreKeys.medicationDraft,
          )!,
        },
      );
      final restored = reloaded.read(medicationDraftProvider);
      expect(restored.name, 'Metoprolol');
      expect(restored.dosage, '25 mg');
    });

    test('flush writes pending changes immediately', () async {
      final container = await createContainer();
      final notifier = container.read(medicationDraftProvider.notifier);
      notifier.update((d) => d.copyWith(name: 'Metoprolol', step: 2));
      await notifier.flush();
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(StoreKeys.medicationDraft),
        contains('Metoprolol'),
      );
      expect(container.read(medicationAutosaveProvider), AutosaveStatus.saved);
      await notifier.flush(); // nothing pending — no-op
    });

    test(
      'startNew keeps an interrupted new draft but replaces an edit',
      () async {
        final container = await createContainer();
        final notifier = container.read(medicationDraftProvider.notifier);
        notifier.update((d) => d.copyWith(name: 'Half typed'));
        await notifier.startNew();
        expect(container.read(medicationDraftProvider).name, 'Half typed');

        await notifier.startEditing(MockData.medications.first);
        expect(container.read(medicationDraftProvider).isEditing, isTrue);
        await notifier.startNew();
        expect(
          container.read(medicationDraftProvider),
          const MedicationDraft(),
        );
        await settle();
      },
    );

    test(
      'startEditing prefills from the medication and is idempotent',
      () async {
        final container = await createContainer();
        final notifier = container.read(medicationDraftProvider.notifier);
        final med = MockData.medications.first;
        await notifier.startEditing(med);
        final draft = container.read(medicationDraftProvider);
        expect(draft.editingId, med.id);
        expect(draft.name, 'Metformin');
        expect(draft.scheduleTimes, med.scheduleTimes);
        expect(draft.instructions, 'Take with food.');

        notifier.update((d) => d.copyWith(step: 3));
        await notifier.startEditing(med);
        expect(container.read(medicationDraftProvider).step, 3);
        await settle();
      },
    );

    test('clear removes the draft and resets the indicator', () async {
      final container = await createContainer();
      final notifier = container.read(medicationDraftProvider.notifier);
      notifier.update((d) => d.copyWith(name: 'X'));
      await notifier.clear();
      expect(container.read(medicationDraftProvider).isEmpty, isTrue);
      expect(container.read(medicationAutosaveProvider), AutosaveStatus.idle);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(StoreKeys.medicationDraft), isFalse);
    });
  });

  group('appointment draft', () {
    test('autosaves, restores, flushes and clears', () async {
      final container = await createContainer();
      final notifier = container.read(appointmentDraftProvider.notifier);
      notifier.update(
        (d) => d.copyWith(title: 'Dentist', startsAt: DateTime(2026, 9, 1, 9)),
      );
      expect(
        container.read(appointmentAutosaveProvider),
        AutosaveStatus.saving,
      );
      await settle();
      expect(container.read(appointmentAutosaveProvider), AutosaveStatus.saved);

      final prefs = await SharedPreferences.getInstance();
      final reloaded = await createContainer(
        prefs: {
          StoreKeys.appointmentDraft: prefs.getString(
            StoreKeys.appointmentDraft,
          )!,
        },
      );
      expect(reloaded.read(appointmentDraftProvider).title, 'Dentist');
      expect(
        reloaded.read(appointmentDraftProvider).startsAt,
        DateTime(2026, 9, 1, 9),
      );

      notifier.update((d) => d.copyWith(step: 2));
      await notifier.flush();
      await notifier.flush();
      await notifier.clear();
      expect(
        container.read(appointmentDraftProvider),
        const AppointmentDraft(),
      );
      expect(container.read(appointmentAutosaveProvider), AutosaveStatus.idle);
    });

    test('startNew and startEditing', () async {
      final container = await createContainer();
      final notifier = container.read(appointmentDraftProvider.notifier);
      final appt = MockData.seed(kTestNow).appointments.first;
      notifier.update((d) => d.copyWith(title: 'In progress'));
      await notifier.startNew();
      expect(container.read(appointmentDraftProvider).title, 'In progress');

      await notifier.startEditing(appt);
      expect(container.read(appointmentDraftProvider).editingId, appt.id);
      expect(container.read(appointmentDraftProvider).companionName, 'Renee');
      await notifier.startEditing(appt);
      await notifier.startNew();
      expect(container.read(appointmentDraftProvider).isEmpty, isTrue);
      await settle();
    });
  });

  test('AutosaveStatus labels', () {
    expect(AutosaveStatus.idle.label, '');
    expect(AutosaveStatus.saving.label, 'Saving…');
    expect(AutosaveStatus.saved.label, 'Saved');
  });
}
