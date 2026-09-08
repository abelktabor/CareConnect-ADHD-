import 'package:careconnect_mobile/app.dart';
import 'package:careconnect_mobile/data/local_store.dart';
import 'package:careconnect_mobile/state/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end journey on a real device or emulator:
///
///   sign in → Today → mark taken → undo → add a medication through all three
///   steps → sign out → sign in as caregiver → dashboard → log now → timeline.
///
/// Run with:
///   flutter test integration_test/app_test.dart -d `device`
///
/// The demo clock is switched on first so the seeded story ("Metformin due in
/// 20 minutes at 2:14 PM") holds regardless of the real time of day.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder fieldIn(Key key) =>
      find.descendant(of: find.byKey(key), matching: find.byType(TextField));

  testWidgets('care recipient and caregiver journeys', (tester) async {
    SharedPreferences.setMockInitialValues({
      StoreKeys.settings:
          '{"themeMode":"light","demoClock":true,"shareWithCaregiver":true}',
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const CareConnectApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Sign in as the care recipient with a passkey.
    expect(find.text('CareConnect'), findsOneWidget);
    await tester.tap(find.byKey(const Key('signin-passkey')));
    await tester.pumpAndSettle();

    // Today: orientation + dominant action.
    expect(find.text('Tuesday, August 25 · 2:14 PM'), findsOneWidget);
    expect(find.text('Next: Metformin in 20 minutes'), findsOneWidget);
    await tester.tap(find.text('Mark as Taken'));
    await tester.pumpAndSettle();
    expect(find.text('Metformin logged at 2:14 PM'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Next: Metformin in 20 minutes'), findsOneWidget);

    // Medications → Add Medication (three steps).
    await tester.tap(find.text('Medications'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-medication')));
    await tester.pumpAndSettle();
    await tester.enterText(fieldIn(const Key('medication-name')), 'Metoprolol');
    await tester.enterText(fieldIn(const Key('medication-dosage')), '25 mg');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('form-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save medication'));
    await tester.pumpAndSettle();
    expect(find.text('Metoprolol, 25 mg'), findsOneWidget);

    // Sign out from App Settings.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-app')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sign-out')));
    await tester.pumpAndSettle();

    // Caregiver journey.
    await tester.tap(find.text('Caregiver'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('signin-passkey')));
    await tester.pumpAndSettle();
    expect(find.text('Caregiver Dashboard'), findsOneWidget);
    expect(find.text('Needs attention today'), findsOneWidget);
    await tester.tap(find.text('Log now'));
    await tester.pumpAndSettle();
    expect(find.text('Metformin logged at 2:14 PM'), findsOneWidget);
    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(
      find.text('Renee logged Metformin taken at 2:14 PM'),
      findsOneWidget,
    );

    // Persistence survives a restart of the widget tree.
    final container = ProviderScope.containerOf(
      tester.element(find.text('Activity Timeline')),
    );
    expect(container.read(appSettingsProvider).demoClock, isTrue);
  });
}
