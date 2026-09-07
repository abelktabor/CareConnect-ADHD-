import 'package:careconnect_mobile/core/utils/clock.dart';
import 'package:careconnect_mobile/data/local_store.dart';
import 'package:careconnect_mobile/models/notification_settings.dart';
import 'package:careconnect_mobile/models/session.dart';
import 'package:careconnect_mobile/models/user_role.dart';
import 'package:careconnect_mobile/state/clock_provider.dart';
import 'package:careconnect_mobile/state/notification_settings_provider.dart';
import 'package:careconnect_mobile/state/session_provider.dart';
import 'package:careconnect_mobile/state/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('session', () {
    test('starts signed out and defaults the role to care recipient', () async {
      final container = await createContainer();
      expect(container.read(sessionProvider), isNull);
      expect(container.read(currentRoleProvider), UserRole.careRecipient);
    });

    test('signIn persists and signOut clears', () async {
      final container = await createContainer();
      await container
          .read(sessionProvider.notifier)
          .signIn(
            role: UserRole.caregiver,
            method: SignInMethod.email,
            email: '  renee@example.test ',
          );
      final session = container.read(sessionProvider)!;
      expect(session.role, UserRole.caregiver);
      expect(session.email, 'renee@example.test');
      expect(session.signedInAt, kTestNow);
      expect(container.read(currentRoleProvider), UserRole.caregiver);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(StoreKeys.session), isTrue);

      await container.read(sessionProvider.notifier).signOut();
      expect(container.read(sessionProvider), isNull);
      expect(prefs.containsKey(StoreKeys.session), isFalse);
    });

    test('blank emails are stored as null', () async {
      final container = await createContainer();
      await container
          .read(sessionProvider.notifier)
          .signIn(
            role: UserRole.careRecipient,
            method: SignInMethod.passkey,
            email: '   ',
          );
      expect(container.read(sessionProvider)!.email, isNull);
    });

    test('restores a persisted session', () async {
      final container = await createContainer(
        prefs: sessionPrefs(UserRole.caregiver),
      );
      expect(container.read(sessionProvider)!.role, UserRole.caregiver);
    });
  });

  group('app settings', () {
    test('defaults and persistence', () async {
      final container = await createContainer();
      expect(container.read(appSettingsProvider), const AppSettings());
      expect(container.read(themeModeProvider), ThemeMode.system);

      final notifier = container.read(appSettingsProvider.notifier);
      await notifier.setThemeMode(ThemeMode.dark);
      await notifier.setShareWithCaregiver(enabled: false);
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(container.read(appSettingsProvider).shareWithCaregiver, isFalse);

      final prefs = await SharedPreferences.getInstance();
      final reloaded = await createContainer(
        prefs: {StoreKeys.settings: prefs.getString(StoreKeys.settings)!},
      );
      expect(reloaded.read(appSettingsProvider).themeMode, ThemeMode.dark);
      expect(reloaded.read(appSettingsProvider).shareWithCaregiver, isFalse);
    });

    test('JSON ignores unknown theme modes', () {
      expect(
        AppSettings.fromJson(const {'themeMode': 'sepia'}).themeMode,
        ThemeMode.system,
      );
      const a = AppSettings(demoClock: true);
      expect(a.hashCode, AppSettings.fromJson(a.toJson()).hashCode);
    });
  });

  group('clock', () {
    test('follows the injected clock', () async {
      final clock = MutableClock(kTestNow);
      final container = await createContainer(clock: clock);
      expect(container.read(currentTimeProvider), kTestNow);
      clock.current = kTestNow.add(const Duration(minutes: 5));
      container.read(currentTimeProvider.notifier).refresh();
      expect(
        container.read(currentTimeProvider),
        kTestNow.add(const Duration(minutes: 5)),
      );
    });

    test('demo clock freezes time at the design instant', () async {
      final container = await createContainer(clock: FixedClock.at(2030, 1, 1));
      await container
          .read(appSettingsProvider.notifier)
          .setDemoClock(enabled: true);
      expect(container.read(currentTimeProvider), kDemoInstant);
      container.read(currentTimeProvider.notifier).refresh();
      expect(container.read(currentTimeProvider), kDemoInstant);
      await container
          .read(appSettingsProvider.notifier)
          .setDemoClock(enabled: false);
      expect(container.read(currentTimeProvider), DateTime(2030));
    });

    test('SystemClock reports wall time', () {
      final before = DateTime.now();
      final now = const SystemClock().now();
      expect(now.isBefore(before), isFalse);
    });
  });

  group('notification settings', () {
    test('defaults, updates and persistence', () async {
      final container = await createContainer();
      expect(
        container.read(notificationSettingsProvider),
        const NotificationSettings(),
      );
      final notifier = container.read(notificationSettingsProvider.notifier);
      await notifier.setDailyDigest(enabled: false);
      await notifier.setLeadTime(ReminderLeadTime.fifteenMinutes);
      final prefs = await SharedPreferences.getInstance();
      final reloaded = await createContainer(
        prefs: {
          StoreKeys.notifications: prefs.getString(StoreKeys.notifications)!,
        },
      );
      final settings = reloaded.read(notificationSettingsProvider);
      expect(settings.dailyDigest, isFalse);
      expect(settings.leadTime, ReminderLeadTime.fifteenMinutes);
    });
  });
}
