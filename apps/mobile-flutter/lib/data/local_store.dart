import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The `SharedPreferences` instance opened in `main()`.
///
/// Deliberately has no default: forgetting to override it is a programming
/// error that should surface immediately rather than silently losing data.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

/// Storage keys, in one place so tests and notifiers cannot drift apart.
abstract final class StoreKeys {
  static const String session = 'cc.session';
  static const String settings = 'cc.settings';
  static const String notifications = 'cc.notifications';
  static const String careData = 'cc.careData';
  static const String medicationDraft = 'cc.draft.medication';
  static const String appointmentDraft = 'cc.draft.appointment';
}

/// Thin JSON layer over `SharedPreferences`.
///
/// Every notifier persists through this class, so persistence is one
/// mockable seam: unit tests use `SharedPreferences.setMockInitialValues`.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  Map<String, dynamic>? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      // Corrupt entry: treat as absent rather than crashing at start-up.
      return null;
    }
  }

  Future<bool> writeJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<bool> remove(String key) => _prefs.remove(key);

  bool contains(String key) => _prefs.containsKey(key);
}

final localStoreProvider = Provider<LocalStore>(
  (ref) => LocalStore(ref.watch(sharedPreferencesProvider)),
);
