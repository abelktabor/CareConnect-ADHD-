import 'package:careconnect_mobile/data/local_store.dart';
import 'package:careconnect_mobile/models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('Settings lists the three rows and navigates', (tester) async {
    await pumpApp(tester, location: '/patient/settings');
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Digest, alerts, and reminder lead time'), findsOneWidget);
    expect(find.text('My Caregiver Access'), findsOneWidget);
    expect(
      find.text('See what Renee can see and manage access'),
      findsOneWidget,
    );
    expect(find.text('App Settings'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-notifications')));
    await tester.pumpAndSettle();
    expect(find.text('Daily digest'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-caregiver-access')));
    await tester.pumpAndSettle();
    expect(find.text('What Renee can see'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-app')));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('caregiver settings has no caregiver-access row', (tester) async {
    await pumpApp(
      tester,
      role: UserRole.caregiver,
      location: '/caregiver/settings',
    );
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('My Caregiver Access'), findsNothing);
    expect(find.text('App Settings'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings-notifications')));
    await tester.pumpAndSettle();
    expect(find.text('Reminder lead time'), findsOneWidget);
  });

  group('Notifications', () {
    testWidgets('toggles persist and overdue alerts are always on', (
      tester,
    ) async {
      final prefs = await pumpApp(
        tester,
        location: '/patient/settings/notifications',
      );
      final digest = find.byKey(const Key('daily-digest'));
      expect(tester.widget<SwitchListTile>(digest).value, isTrue);
      await tester.tap(digest);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(digest).value, isFalse);
      expect(
        prefs.getString(StoreKeys.notifications),
        contains('"dailyDigest":false'),
      );

      final overdue = find.descendant(
        of: find.byKey(const Key('overdue-alerts')),
        matching: find.byType(Switch),
      );
      expect(tester.widget<Switch>(overdue).onChanged, isNull);
      expect(tester.widget<Switch>(overdue).value, isTrue);
      expect(
        find.text('Always escalate immediately — never held for the digest'),
        findsOneWidget,
      );
    });

    testWidgets('lead time is a single-select group of three', (tester) async {
      final handle = tester.ensureSemantics();
      final prefs = await pumpApp(
        tester,
        location: '/patient/settings/notifications',
      );
      expect(find.text('15 min'), findsOneWidget);
      expect(find.text('1 hour'), findsOneWidget);
      expect(find.text('1 day'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('1 hour')),
        matchesSemantics(
          label: '1 hour before',
          isChecked: true,
          hasCheckedState: true,
          isInMutuallyExclusiveGroup: true,
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      await tester.tap(find.text('1 day'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('1 day')),
        matchesSemantics(
          label: '1 day before',
          isChecked: true,
          hasCheckedState: true,
          isInMutuallyExclusiveGroup: true,
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      expect(prefs.getString(StoreKeys.notifications), contains('oneDay'));
      handle.dispose();
    });
  });

  group('My Caregiver Access', () {
    testWidgets('shows exactly what Renee can see and lets sharing pause', (
      tester,
    ) async {
      final prefs = await pumpApp(
        tester,
        location: '/patient/settings/caregiver-access',
      );
      expect(find.text('Renee — your caregiver'), findsOneWidget);
      expect(find.text('What Renee can see'), findsOneWidget);
      expect(find.text('Medication names, doses, and status'), findsOneWidget);
      expect(find.text('Appointment times and locations'), findsOneWidget);
      expect(
        find.text('Whether a dose was taken, skipped, or missed'),
        findsOneWidget,
      );
      expect(find.text('Recent activity timeline'), findsOneWidget);
      expect(
        find.textContaining(
          'Nothing outside this list is ever visible to Renee.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Sharing is on. Renee sees the list above.'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('share-with-caregiver')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Sharing is paused.'), findsOneWidget);
      expect(
        prefs.getString(StoreKeys.settings),
        contains('"shareWithCaregiver":false'),
      );
    });
  });

  group('App Settings', () {
    testWidgets('shows the profile and switches theme', (tester) async {
      final prefs = await pumpApp(tester, location: '/patient/settings/app');
      expect(find.text('Muhammad R.'), findsOneWidget);
      expect(find.text('muhammad@example.test'), findsOneWidget);
      expect(find.text('Signed in as care recipient'), findsOneWidget);
      expect(
        find.text('CareConnect 0.4.0 · Assignment 4 build'),
        findsOneWidget,
      );

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(
        prefs.getString(StoreKeys.settings),
        contains('"themeMode":"dark"'),
      );
      final context = tester.element(find.text('Profile'));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(tester.takeException(), isNull);
    });

    testWidgets('demo clock asks first, then resets sample data', (
      tester,
    ) async {
      final prefs = await pumpApp(
        tester,
        location: '/patient/settings/app',
        clock: FixedClockFuture.far,
      );
      await tester.tap(find.byKey(const Key('demo-clock')));
      await tester.pumpAndSettle();
      expect(find.text('Turn on the demo clock?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SwitchListTile>(find.byKey(const Key('demo-clock')))
            .value,
        isFalse,
      );

      await tester.tap(find.byKey(const Key('demo-clock')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Turn on'));
      await tester.pumpAndSettle();
      expect(find.text('Demo clock on. Sample data reset.'), findsOneWidget);
      expect(prefs.getString(StoreKeys.settings), contains('"demoClock":true'));

      // Turning it off needs no confirmation.
      await tester.tap(find.byKey(const Key('demo-clock')));
      await tester.pumpAndSettle();
      expect(
        prefs.getString(StoreKeys.settings),
        contains('"demoClock":false'),
      );
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('reset sample data confirms, then resets', (tester) async {
      await pumpApp(tester, location: '/patient/settings/app');
      await tester.tap(find.byKey(const Key('reset-sample-data')));
      await tester.pumpAndSettle();
      expect(find.text('Reset sample data?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reset-sample-data')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('Sample data reset'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('sign out returns to the sign-in screen', (tester) async {
      final prefs = await pumpApp(tester, location: '/patient/settings/app');
      await tester.tap(find.byKey(const Key('sign-out')));
      await tester.pumpAndSettle();
      expect(find.text('Continue with Face ID / Passkey'), findsOneWidget);
      expect(prefs.containsKey(StoreKeys.session), isFalse);
    });

    testWidgets('caregiver profile', (tester) async {
      await pumpApp(
        tester,
        role: UserRole.caregiver,
        location: '/caregiver/settings/app',
      );
      expect(find.text('Renee'), findsOneWidget);
      expect(find.text('Signed in as caregiver'), findsOneWidget);
    });
  });
}
