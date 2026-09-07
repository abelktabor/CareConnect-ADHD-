import 'package:careconnect_mobile/data/local_store.dart';
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

  test('localStoreProvider wraps the injected preferences', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    expect(container.read(localStoreProvider), isA<LocalStore>());
  });
}
