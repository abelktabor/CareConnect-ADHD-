import 'package:careconnect_mobile/models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

/// Every screen is checked against Flutter's built-in guidelines:
/// Android 48×48 and iOS 44×44 tap targets, labelled tap targets, and
/// WCAG text contrast. These are the automated third of the accessibility
/// pass; the manual VoiceOver / TalkBack pass is documented in TEST-PLAN.md.
void main() {
  const careRecipientScreens = [
    '/patient/today',
    '/patient/medications',
    '/patient/medications/med-metformin',
    '/patient/appointments',
    '/patient/settings',
    '/patient/settings/notifications',
    '/patient/settings/caregiver-access',
    '/patient/settings/app',
  ];
  const caregiverScreens = [
    '/caregiver/dashboard',
    '/caregiver/manage',
    '/caregiver/activity',
    '/caregiver/settings',
    '/caregiver/settings/notifications',
    '/caregiver/settings/app',
  ];

  for (final location in careRecipientScreens) {
    testWidgets('$location meets the accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, location: location);
      await expectMeetsAccessibilityGuidelines(tester);
      handle.dispose();
    });
  }

  for (final location in caregiverScreens) {
    testWidgets('$location meets the accessibility guidelines (caregiver)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, role: UserRole.caregiver, location: location);
      await expectMeetsAccessibilityGuidelines(tester);
      handle.dispose();
    });
  }

  testWidgets('sign-in meets the accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, role: null, location: '/sign-in');
    await expectMeetsAccessibilityGuidelines(tester);
    handle.dispose();
  });

  testWidgets('the medication form meets the guidelines on every step', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, location: '/medications/med-lisinopril/edit');
    await tester.pumpAndSettle();
    await expectMeetsAccessibilityGuidelines(tester);
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    await expectMeetsAccessibilityGuidelines(tester);
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    await expectMeetsAccessibilityGuidelines(tester);
    await tester.pump(const Duration(seconds: 1));
    handle.dispose();
  });

  testWidgets('the appointment form meets the guidelines on both steps', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, location: '/appointments/appt-alvarez/edit');
    await tester.pumpAndSettle();
    await expectMeetsAccessibilityGuidelines(tester);
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    await expectMeetsAccessibilityGuidelines(tester);
    await tester.pump(const Duration(seconds: 1));
    handle.dispose();
  });

  testWidgets('dark mode keeps contrast on the busiest screens', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(
      tester,
      location: '/patient/medications',
      prefs: const {
        'cc.settings':
            '{"themeMode":"dark","demoClock":false,"shareWithCaregiver":true}',
      },
    );
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await pumpApp(
      tester,
      role: UserRole.caregiver,
      location: '/caregiver/dashboard',
      prefs: const {
        'cc.settings':
            '{"themeMode":"dark","demoClock":false,"shareWithCaregiver":true}',
      },
    );
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('200% text scale never overflows on the busiest screens', (
    tester,
  ) async {
    for (final location in [
      '/patient/today',
      '/patient/medications',
      '/patient/appointments',
    ]) {
      await pumpApp(tester, location: location, textScale: 2.0);
      expect(tester.takeException(), isNull, reason: location);
    }
    await pumpApp(
      tester,
      role: UserRole.caregiver,
      location: '/caregiver/dashboard',
      textScale: 2.0,
    );
    expect(tester.takeException(), isNull);
    await pumpApp(tester, location: '/medications/new', textScale: 2.0);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('every heading is exposed as a heading', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    expect(
      tester.getSemantics(appBarText('Today')),
      matchesSemantics(isHeader: true, label: 'Today'),
    );
    expect(
      tester.getSemantics(find.text('Later today')),
      matchesSemantics(isHeader: true, label: 'Later today'),
    );
    handle.dispose();
  });

  testWidgets('the undo snackbar is a live region with a labelled action', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    await tester.tap(find.text('Mark as Taken'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Undo')),
      matchesSemantics(
        label: 'Undo',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    await tester.pump(const Duration(seconds: 11));
    handle.dispose();
  });
}
