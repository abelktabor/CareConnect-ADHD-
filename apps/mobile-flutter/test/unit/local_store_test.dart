import 'package:careconnect_mobile/core/utils/clock.dart';
import 'package:careconnect_mobile/data/local_store.dart';
import 'package:careconnect_mobile/models/notification_settings.dart';
import 'package:careconnect_mobile/state/care_data_provider.dart';
import 'package:careconnect_mobile/state/clock_provider.dart';
import 'package:careconnect_mobile/state/draft_providers.dart';
import 'package:careconnect_mobile/state/notification_settings_provider.dart';
import 'package:careconnect_mobile/state/session_provider.dart';
import 'package:careconnect_mobile/state/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'cc.corrupt': '{not json'});
    store = LocalStore(await SharedPreferences.getInstance());
  });

  test('missing keys read as null', () {
    expect(store.readJson('cc.missing'), isNull);
    expect(store.contains('cc.missing'), isFalse);
  });

  test('writes and reads JSON documents', () async {
    await store.writeJson('cc.thing', {'a': 1, 'b': 'two'});
    expect(store.contains('cc.thing'), isTrue);
    expect(store.readJson('cc.thing'), {'a': 1, 'b': 'two'});
  });

  test('corrupt entries read as null instead of throwing', () {
    expect(store.readJson('cc.corrupt'), isNull);
  });

  test('remove forgets a key', () async {
    await store.writeJson('cc.thing', {'a': 1});
    await store.remove('cc.thing');
    expect(store.readJson('cc.thing'), isNull);
  });

  test('sharedPreferencesProvider must be overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Riverpod 3 wraps provider errors, so match on the message.
    expect(
      () => container.read(sharedPreferencesProvider),
      throwsA(
        predicate<Object>((e) => e.toString().contains('must be overridden')),
      ),
    );
  });

  group('readAs — fail securely on malformed stored documents', () {
    // A stored document is structurally untrusted: a truncated write, a
    // device migration, or an edited preferences file on a rooted device can
    // leave valid JSON with the wrong shape. Deserialising that inside a
    // provider's build() must not leave the app unable to start
    // (NIST SSDF PW.5.1 — fail securely).
    Map<String, dynamic> strict(Map<String, dynamic> json) => {
      'value': json['value']! as String,
    };

    test('returns the document when it is well formed', () async {
      await store.writeJson('cc.doc', {'value': 'ok'});
      expect(
        store.readAs('cc.doc', strict, orElse: () => {'value': 'fallback'}),
        {'value': 'ok'},
      );
    });

    test('falls back when the key is absent', () {
      expect(
        store.readAs('cc.absent', strict, orElse: () => {'value': 'fallback'}),
        {'value': 'fallback'},
      );
    });

    test('falls back when the stored JSON is corrupt', () {
      expect(
        store.readAs('cc.corrupt', strict, orElse: () => {'value': 'fallback'}),
        {'value': 'fallback'},
      );
    });

    test('falls back and discards a document of the wrong shape', () async {
      await store.writeJson('cc.doc', {'unexpected': 1});
      expect(
        store.readAs('cc.doc', strict, orElse: () => {'value': 'fallback'}),
        {'value': 'fallback'},
      );
      // The bad document is dropped rather than left to fail again.
      await Future<void>.delayed(Duration.zero);
      expect(store.contains('cc.doc'), isFalse);
    });
  });

  test(
    'the app still starts when every stored document is malformed',
    () async {
      SharedPreferences.setMockInitialValues({
        StoreKeys.session: '{"role":42}',
        StoreKeys.settings: '{"themeMode":[]}',
        StoreKeys.notifications: '"not-an-object"',
        StoreKeys.careData: '{"patient":null}',
        StoreKeys.medicationDraft: '{"step":"two"}',
        StoreKeys.appointmentDraft: '{"startsAt":"not-a-date"}',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(FixedClock.at(2026, 8, 25, 14, 14)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(sessionProvider), isNull);
      expect(container.read(appSettingsProvider), const AppSettings());
      expect(
        container.read(notificationSettingsProvider),
        const NotificationSettings(),
      );
      expect(container.read(careDataProvider).medications, isNotEmpty);
      expect(container.read(medicationDraftProvider).isEmpty, isTrue);
      expect(container.read(appointmentDraftProvider).isEmpty, isTrue);
    },
  );

  test('localStoreProvider wraps the injected preferences', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    expect(container.read(localStoreProvider), isA<LocalStore>());
  });
}
