import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/local_store.dart';

/// Entry point.
///
/// `SharedPreferences` is opened *before* the widget tree exists and injected
/// through Riverpod so every notifier can read persisted state synchronously in
/// its `build()`. That keeps the first frame free of loading spinners — the
/// orientation bar and the next dose are visible the moment the app opens,
/// which is the "attention recovery" requirement from the accessibility plan.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const CareConnectApp(),
    ),
  );
}
