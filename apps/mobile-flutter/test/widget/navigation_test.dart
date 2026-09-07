import 'package:careconnect_mobile/models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/test_app.dart';

/// Simulates the Android hardware / gesture back button.
Future<void> systemBack(WidgetTester tester) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
    (_) {},
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bottom navigation reaches all four care-recipient tabs', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapNavDestination(tester, 'Medications');
    expect(find.text('Add Medication'), findsOneWidget);

    await tapNavDestination(tester, 'Appointments');
    expect(find.text('Add Appointment'), findsOneWidget);

    await tapNavDestination(tester, 'Settings');
    expect(find.text('App Settings'), findsOneWidget);

    await tapNavDestination(tester, 'Today');
    expect(find.text('Mark as Taken'), findsOneWidget);
  });

  testWidgets('bottom navigation reaches all four caregiver tabs', (
    tester,
  ) async {
    await pumpApp(
      tester,
      role: UserRole.caregiver,
      location: '/caregiver/dashboard',
    );
    for (final (tab, expected) in [
      ('Manage', 'Muhammad R.’s medications and appointments'),
      ('Activity', 'Activity Timeline'),
      ('Settings', 'App Settings'),
      ('Dashboard', 'Needs attention today'),
    ]) {
      await tapNavDestination(tester, tab);
      expect(find.text(expected), findsOneWidget, reason: tab);
    }
  });

  testWidgets('tabs keep their own stacks; re-tapping resets to the root', (
    tester,
  ) async {
    await pumpApp(tester, location: '/patient/medications');
    await tester.tap(find.text('Metformin, 500 mg'));
    await tester.pumpAndSettle();
    expect(find.text('Every day at 2:34 PM'), findsOneWidget);

    await tapNavDestination(tester, 'Today');
    await tapNavDestination(tester, 'Medications');
    expect(find.text('Every day at 2:34 PM'), findsOneWidget);

    await tapNavDestination(tester, 'Medications');
    expect(find.text('Every day at 2:34 PM'), findsNothing);
    expect(find.text('Add Medication'), findsOneWidget);
  });

  testWidgets('the app-bar back button and the system back both pop', (
    tester,
  ) async {
    await pumpApp(tester, location: '/patient/medications');
    await tester.tap(find.text('Metformin, 500 mg'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Add Medication'), findsOneWidget);

    await tester.tap(find.text('Metformin, 500 mg'));
    await tester.pumpAndSettle();
    await systemBack(tester);
    expect(find.text('Every day at 2:34 PM'), findsNothing);
    expect(find.text('Add Medication'), findsOneWidget);
  });

  testWidgets('a deep link into a medication builds the back stack', (
    tester,
  ) async {
    await pumpApp(tester, location: '/patient/medications/med-atorvastatin');
    expect(find.text('Atorvastatin, 20 mg'), findsOneWidget);
    expect(find.text('Overdue · Overdue — 45 min late'), findsOneWidget);
    await systemBack(tester);
    expect(find.text('Add Medication'), findsOneWidget);
  });

  testWidgets('a deep link into settings builds the back stack', (
    tester,
  ) async {
    await pumpApp(tester, location: '/patient/settings/notifications');
    expect(find.text('Daily digest'), findsOneWidget);
    await systemBack(tester);
    expect(find.text('App Settings'), findsOneWidget);
  });

  testWidgets('full-screen forms cover the bottom navigation', (tester) async {
    await pumpApp(tester, location: '/patient/medications');
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.byKey(const Key('add-medication')));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    await systemBack(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  group('redirect guard', () {
    testWidgets('signed out users always land on sign-in', (tester) async {
      await pumpApp(tester, role: null, location: '/patient/today');
      expect(find.text('Continue with Face ID / Passkey'), findsOneWidget);
      await pumpApp(tester, role: null, location: '/caregiver/activity');
      expect(find.text('Continue with Face ID / Passkey'), findsOneWidget);
    });

    testWidgets('roles cannot cross into each other’s screens', (tester) async {
      await pumpApp(
        tester,
        role: UserRole.careRecipient,
        location: '/caregiver/dashboard',
      );
      expect(find.text('Mark as Taken'), findsOneWidget);
      await pumpApp(
        tester,
        role: UserRole.caregiver,
        location: '/patient/today',
      );
      expect(find.text('Needs attention today'), findsOneWidget);
    });

    testWidgets('a signed-in user opening sign-in or the root goes home', (
      tester,
    ) async {
      await pumpApp(tester, role: UserRole.caregiver, location: '/sign-in');
      expect(find.text('Needs attention today'), findsOneWidget);
      await pumpApp(tester, role: UserRole.careRecipient, location: '/');
      expect(find.text('Mark as Taken'), findsOneWidget);
    });
  });

  testWidgets('reduce-motion removes route transitions entirely', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: '/patient/medications',
      disableAnimations: true,
    );
    await tester.tap(find.byKey(const Key('add-medication')));
    await tester.pumpAndSettle();
    final navigator = tester.widget<Navigator>(find.byType(Navigator).first);
    expect(navigator.pages.last, isA<NoTransitionPage<void>>());
  });

  testWidgets('with motion allowed, routes use Material pages', (tester) async {
    await pumpApp(tester, location: '/patient/medications');
    await tester.tap(find.byKey(const Key('add-medication')));
    await tester.pumpAndSettle();
    final navigator = tester.widget<Navigator>(find.byType(Navigator).first);
    expect(navigator.pages.last, isA<MaterialPage<void>>());
  });
}
