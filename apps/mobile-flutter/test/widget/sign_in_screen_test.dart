import 'package:careconnect_mobile/data/local_store.dart';
import 'package:careconnect_mobile/features/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  group('validateEmailAddress', () {
    test('explains what is wrong and how to fix it', () {
      expect(
        validateEmailAddress(''),
        'Enter your email address, like you@email.com',
      );
      expect(validateEmailAddress('   '), contains('Enter your email'));
      expect(validateEmailAddress('foo'), contains('missing something'));
      expect(validateEmailAddress('@foo.com'), contains('missing something'));
      expect(validateEmailAddress('foo@'), contains('missing something'));
      expect(validateEmailAddress('foo@bar'), contains('missing something'));
      expect(validateEmailAddress('you@email.com'), isNull);
      expect(validateEmailAddress('  you@email.com '), isNull);
    });
  });

  testWidgets('shows the Figma sign-in content', (tester) async {
    await pumpApp(tester, role: null, location: '/sign-in');
    expect(find.text('CareConnect'), findsOneWidget);
    expect(
      find.text('Medications and appointments, without the memory test.'),
      findsOneWidget,
    );
    expect(find.text('Continue with Face ID / Passkey'), findsOneWidget);
    expect(find.text('Continue with Email'), findsOneWidget);
    expect(find.text('I am a…'), findsOneWidget);
    expect(find.text('Care Recipient'), findsOneWidget);
    expect(find.text('Caregiver'), findsOneWidget);
  });

  testWidgets('passkey signs a care recipient in and opens Today', (
    tester,
  ) async {
    final prefs = await pumpApp(tester, role: null, location: '/sign-in');
    await tester.tap(find.byKey(const Key('signin-passkey')));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Mark as Taken'), findsOneWidget);
    expect(prefs.containsKey(StoreKeys.session), isTrue);
  });

  testWidgets('choosing Caregiver opens the caregiver dashboard', (
    tester,
  ) async {
    await pumpApp(tester, role: null, location: '/sign-in');
    await tester.tap(find.text('Caregiver'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('signin-passkey')));
    await tester.pumpAndSettle();
    expect(find.text('Caregiver Dashboard'), findsOneWidget);
  });

  testWidgets('email path validates in plain language, then signs in', (
    tester,
  ) async {
    await pumpApp(tester, role: null, location: '/sign-in');
    final field = find.descendant(
      of: find.byKey(const Key('signin-email')),
      matching: find.byType(TextField),
    );

    await tester.tap(find.byKey(const Key('signin-email-button')));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter your email address, like you@email.com'),
      findsOneWidget,
    );

    await tester.enterText(field, 'nope');
    await tester.pump();
    // Typing clears the previous error before the next attempt.
    expect(
      find.text('Enter your email address, like you@email.com'),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('signin-email-button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('missing something'), findsOneWidget);

    await tester.enterText(field, 'muhammad@example.test');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Mark as Taken'), findsOneWidget);
  });

  testWidgets('role chooser exposes radio-style semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, role: null, location: '/sign-in');
    expect(
      tester.getSemantics(find.text('Care Recipient')),
      matchesSemantics(
        label: 'Care Recipient',
        isButton: true,
        isInMutuallyExclusiveGroup: true,
        isChecked: true,
        hasCheckedState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Caregiver')),
      matchesSemantics(
        label: 'Caregiver',
        isButton: true,
        isInMutuallyExclusiveGroup: true,
        hasCheckedState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('stays centred and readable on a tablet', (tester) async {
    await pumpApp(tester, role: null, location: '/sign-in', size: kTablet);
    final button = tester.getSize(find.byKey(const Key('signin-passkey')));
    expect(button.width, lessThanOrEqualTo(560));
    expect(tester.takeException(), isNull);
  });
}
