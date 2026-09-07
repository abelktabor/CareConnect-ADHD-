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
  testWidgets('lists appointments with full-word dates and who is taking me', (
    tester,
  ) async {
    await pumpApp(tester, location: '/patient/appointments');
    expect(find.text('Dr. Alvarez — Cardiology follow-up'), findsOneWidget);
    expect(
      find.text(
        'Tuesday, August 25 · 2:30 PM · Regional Medical · Renee is taking me',
      ),
      findsOneWidget,
    );
    expect(find.text('Physical therapy'), findsOneWidget);
    expect(
      find.text(
        'Thursday, August 27 · 10:00 AM · Riverside PT · Renee is taking me',
      ),
      findsOneWidget,
    );
    expect(find.text('Dr. Chen — Primary care'), findsOneWidget);
    expect(
      find.text(
        'Tuesday, September 1 · 9:15 AM · Community Health · Driving myself',
      ),
      findsOneWidget,
    );
    expect(find.text('Add Appointment'), findsOneWidget);
  });

  testWidgets('adds an appointment through both steps', (tester) async {
    await pumpApp(tester, location: '/patient/appointments');
    await tester.tap(find.byKey(const Key('add-appointment')));
    await tester.pumpAndSettle();
    expect(find.text('Add Appointment'), findsOneWidget);
    expect(find.text('Step 1 of 2 — What & where'), findsOneWidget);

    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter what the appointment is, like Dentist — cleaning'),
      findsOneWidget,
    );
    expect(
      find.text('Enter where it is, like Regional Medical'),
      findsOneWidget,
    );

    await tester.enterText(
      fieldIn(const Key('appointment-title')),
      'Dentist — cleaning',
    );
    await tester.enterText(
      fieldIn(const Key('appointment-location')),
      'Placeholder Dental',
    );
    await settleAutosave(tester);
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2 — Date, time & companion'), findsOneWidget);

    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Choose the date and time'), findsWidgets);

    await tester.tap(fieldIn(const Key('appointment-when')));
    await tester.pumpAndSettle();
    expect(find.text('Which day is the appointment?'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('What time is the appointment?'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Tuesday, August 25 · 2:14 PM'), findsOneWidget);

    await tester.enterText(
      fieldIn(const Key('appointment-companion')),
      'Renee',
    );
    await settleAutosave(tester);
    expect(find.text('Saved'), findsOneWidget);

    await tester.tap(find.text('Save appointment'));
    await tester.pumpAndSettle();
    expect(find.text('Appointment added'), findsOneWidget);
    expect(find.text('Dentist — cleaning'), findsOneWidget);
    expect(
      find.text(
        'Tuesday, August 25 · 2:14 PM · Placeholder Dental · Renee is taking me',
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('editing an appointment prefills, saves and can delete', (
    tester,
  ) async {
    await pumpApp(tester, location: '/patient/appointments');
    await tester.tap(find.text('Dr. Alvarez — Cardiology follow-up'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Appointment'), findsOneWidget);
    expect(
      fieldValue(tester, const Key('appointment-title')),
      'Dr. Alvarez — Cardiology follow-up',
    );
    expect(
      fieldValue(tester, const Key('appointment-location')),
      'Regional Medical',
    );

    await tester.enterText(
      fieldIn(const Key('appointment-title')),
      'Dr. Alvarez — Cardiology',
    );
    await settleAutosave(tester);
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    expect(
      fieldValue(tester, const Key('appointment-when')),
      'Tuesday, August 25 · 2:30 PM',
    );
    expect(fieldValue(tester, const Key('appointment-companion')), 'Renee');
    expect(find.text('Save changes'), findsOneWidget);

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Appointment updated'), findsOneWidget);
    expect(find.text('Dr. Alvarez — Cardiology'), findsOneWidget);

    await tester.tap(find.text('Dr. Alvarez — Cardiology'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-appointment')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this appointment?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-appointment')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Appointment removed'), findsOneWidget);
    expect(find.text('Dr. Alvarez — Cardiology'), findsNothing);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('Back on step 1 returns to the list and keeps the draft', (
    tester,
  ) async {
    await pumpApp(tester, location: '/patient/appointments');
    await tester.tap(find.byKey(const Key('add-appointment')));
    await tester.pumpAndSettle();
    await tester.enterText(fieldIn(const Key('appointment-title')), 'Eye exam');
    await settleAutosave(tester);
    await tester.tap(find.byKey(const Key('form-back')));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 2 — What & where'), findsNothing);
    await tester.tap(find.byKey(const Key('add-appointment')));
    await tester.pumpAndSettle();
    expect(fieldValue(tester, const Key('appointment-title')), 'Eye exam');
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    // Location still missing → stays on step 1 with one error.
    expect(
      find.text('Enter where it is, like Regional Medical'),
      findsOneWidget,
    );
    await settleAutosave(tester);
  });

  testWidgets('empty state once every appointment is deleted', (tester) async {
    await pumpApp(tester, location: '/patient/appointments');
    for (final title in [
      'Dr. Alvarez — Cardiology follow-up',
      'Physical therapy',
      'Dr. Chen — Primary care',
    ]) {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('form-continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete-appointment')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
    }
    expect(find.text('No upcoming appointments.'), findsOneWidget);
    expect(
      find.text('Add one and it will show here with who is taking you.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));
  });
}
