import 'dart:convert';

import 'package:careconnect_mobile/app.dart';
import 'package:careconnect_mobile/core/utils/clock.dart';
import 'package:careconnect_mobile/data/local_store.dart';
import 'package:careconnect_mobile/models/session.dart';
import 'package:careconnect_mobile/models/user_role.dart';
import 'package:careconnect_mobile/router/app_router.dart';
import 'package:careconnect_mobile/state/clock_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The instant every Figma frame is drawn at. Seeded data is relative to it,
/// so "Metformin due in 20 min" and "Atorvastatin 45 min late" hold.
final DateTime kTestNow = kDemoInstant;

/// Phone (Pixel 8 logical size) and tablet viewports.
const Size kPhone = Size(412, 915);
const Size kTablet = Size(834, 1194);
const Size kPhoneLandscape = Size(915, 412);

/// A clock whose "now" can be moved forward inside a test.
class MutableClock implements Clock {
  MutableClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}

/// Serialises a signed-in session into the mock preferences map.
Map<String, Object> sessionPrefs(UserRole role, {DateTime? at}) => {
  StoreKeys.session: jsonEncode(
    Session(
      role: role,
      method: SignInMethod.passkey,
      signedInAt: at ?? kTestNow,
    ).toJson(),
  ),
};

/// Builds a [ProviderContainer] with in-memory preferences and a fixed clock.
Future<ProviderContainer> createContainer({
  Map<String, Object> prefs = const {},
  Clock? clock,
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      clockProvider.overrideWithValue(clock ?? FixedClock(kTestNow)),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Pumps the whole app (router, theme, persistence) at [location].
///
/// * [role] null → signed out, so the router lands on `/sign-in`.
/// * [size] sets the logical viewport (phone by default).
/// * [textScale] emulates OS font scaling (2.0 = the 200% reflow check).
Future<SharedPreferences> pumpApp(
  WidgetTester tester, {
  String location = '/patient/today',
  UserRole? role = UserRole.careRecipient,
  Map<String, Object> prefs = const {},
  Clock? clock,
  Size size = kPhone,
  double textScale = 1.0,
  bool disableAnimations = false,
  List<Override> overrides = const [],
}) async {
  final allPrefs = <String, Object>{
    ...prefs,
    if (role != null) ...sessionPrefs(role),
  };
  SharedPreferences.setMockInitialValues(allPrefs);
  final sp = await SharedPreferences.getInstance();

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  if (disableAnimations) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        clockProvider.overrideWithValue(clock ?? FixedClock(kTestNow)),
        initialLocationProvider.overrideWithValue(location),
        ...overrides,
      ],
      child: const CareConnectApp(),
    ),
  );
  await tester.pumpAndSettle();
  return sp;
}

/// Runs the four built-in accessibility guidelines against the current tree.
Future<void> expectMeetsAccessibilityGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

/// Clocks far enough ahead that every seeded appointment is in the past.
abstract final class FixedClockFuture {
  static final Clock far = FixedClock(DateTime(2030, 1, 1, 12));
}

/// Taps a bottom-navigation destination by label.
///
/// "Today", "Medications", "Settings" and friends appear both in the app bar
/// and in the navigation bar, so tests scope the tap to the [NavigationBar].
Future<void> tapNavDestination(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

/// Finds a widget's text inside the app bar only.
Finder appBarText(String text) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(text));

/// Taps a segmented-button option by label (the Activity Timeline filter
/// shares its labels with bottom-navigation destinations).
Future<void> tapFilter(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(const Key('activity-filter')),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}
