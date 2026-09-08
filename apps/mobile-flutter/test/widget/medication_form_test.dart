import 'package:careconnect_mobile/state/draft_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Finder fieldIn(Key key) =>
    find.descendant(of: find.byKey(key), matching: find.byType(TextField));

String fieldValue(WidgetTester tester, Key key) =>
    tester.widget<TextField>(fieldIn(key)).controller!.text;

Future<void> settleAutosave(WidgetTester tester) async {
  await tester.pump(kAutosaveDebounce + const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('walks through all three steps and saves', (tester) async {
    await pumpApp(tester, location: '/patient/medications');
    await tester.tap(find.byKey(const Key('add-medication')));
    await tester.pumpAndSettle();

    expect(find.text('Add Medication'), findsOneWidget);
    expect(find.text('Step 1 of 3 — Medication details'), findsOneWidget);
    expect(find.text('Add medication details'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      closeTo(1 / 3, 0.001),
    );

    // Plain-language errors, one per empty field.
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter the medication name, like Metformin'),
      findsOneWidget,
    );
    expect(find.text('Enter the dose, like 25 mg'), findsOneWidget);

    await tester.enterText(fieldIn(const Key('medication-name')), 'Metoprolol');
    await tester.pump();
    expect(find.text('Saving…'), findsOneWidget);
    await tester.enterText(fieldIn(const Key('medication-dosage')), '25 mg');
    await settleAutosave(tester);
    expect(find.text('Saved'), findsOneWidget);

    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 3 — Schedule'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      closeTo(2 / 3, 0.001),
    );

    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Add at least one time, like 8:00 AM'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-time')));
    await tester.pumpAndSettle();
    expect(find.text('When is this dose due?'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('8:00 AM'), findsOneWidget);

    await tester.enterText(
      fieldIn(const Key('medication-instructions')),
      'With water',
    );
    await settleAutosave(tester);

    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Step 3 of 3 — Review'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      closeTo(1, 0.001),
    );
    expect(find.text('Metoprolol'), findsOneWidget);
    expect(find.text('25 mg'), findsOneWidget);
    expect(find.text('8:00 AM'), findsOneWidget);
    expect(find.text('With water'), findsOneWidget);
    expect(find.text('Save medication'), findsOneWidget);

    await tester.tap(find.text('Save medication'));
    await tester.pumpAndSettle();
    expect(find.text('Metoprolol added'), findsOneWidget);
    expect(find.text('Metoprolol, 25 mg'), findsOneWidget);
    // The new medication's 8:00 AM dose is already overdue at 2:14 PM.
    expect(find.text('Overdue · Overdue — 6 hours late'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('leaving mid-form keeps the draft and restores it', (
    tester,
  ) async {
    await pumpApp(tester, location: '/patient/medications');
    await tester.tap(find.byKey(const Key('add-medication')));
    await tester.pumpAndSettle();
    await tester.enterText(fieldIn(const Key('medication-name')), 'Half typed');
    await settleAutosave(tester);

    await tester.tap(find.byKey(const Key('form-back')));
    await tester.pumpAndSettle();
    expect(find.text('Add Medication'), findsOneWidget); // the list button
    expect(find.text('Step 1 of 3 — Medication details'), findsNothing);

    await tester.tap(find.byKey(const Key('add-medication')));
    await tester.pumpAndSettle();
    expect(fieldValue(tester, const Key('medication-name')), 'Half typed');
    await settleAutosave(tester);
  });

  testWidgets('Back moves to the previous step and removing a time works', (
    tester,
  ) async {
    await pumpApp(tester, location: '/patient/medications');
    await tester.tap(find.byKey(const Key('add-medication')));
    await tester.pumpAndSettle();
    await tester.enterText(fieldIn(const Key('medication-name')), 'X');
    await tester.enterText(fieldIn(const Key('medication-dosage')), '1 mg');
    await settleAutosave(tester);
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('time-08:00')), findsOneWidget);
    await tester.tap(find.byTooltip('Remove 8:00 AM'));
    await settleAutosave(tester);
    expect(find.byKey(const Key('time-08:00')), findsNothing);
    expect(find.text('No times yet.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('form-back')));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 3 — Medication details'), findsOneWidget);
    await settleAutosave(tester);
  });

  testWidgets('editing prefills every field and saves changes', (tester) async {
    await pumpApp(tester, location: '/patient/medications/med-metformin');
    await tester.tap(find.byKey(const Key('edit-medication')));
    await tester.pumpAndSettle();
    expect(find.text('Edit Medication'), findsOneWidget);
    expect(fieldValue(tester, const Key('medication-name')), 'Metformin');
    expect(fieldValue(tester, const Key('medication-dosage')), '500 mg');

    await tester.enterText(
      fieldIn(const Key('medication-name')),
      'Metformin XR',
    );
    await settleAutosave(tester);
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    expect(find.text('2:34 PM'), findsOneWidget);
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Save changes'), findsOneWidget);
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Metformin XR updated'), findsOneWidget);
    expect(find.text('Metformin XR, 500 mg'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('deep-linking straight to the edit form works', (tester) async {
    await pumpApp(tester, location: '/medications/med-lisinopril/edit');
    await tester.pumpAndSettle();
    expect(find.text('Edit Medication'), findsOneWidget);
    expect(fieldValue(tester, const Key('medication-name')), 'Lisinopril');
    await settleAutosave(tester);
  });

  testWidgets('step indicator is announced as a live region', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, location: '/medications/new');
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Step 1 of 3 — Medication details')),
      matchesSemantics(
        label: 'Step 1 of 3, Medication details',
        isLiveRegion: true,
      ),
    );
    handle.dispose();
  });
}
