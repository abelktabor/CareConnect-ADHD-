import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/clock.dart';
import 'settings_provider.dart';

/// The wall clock. Tests override this with a [FixedClock].
final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// "Now", refreshed every 30 seconds so "Due in 20 min" stays honest without
/// rebuilding on every second. When the demo clock setting is on, time is
/// frozen at [kDemoInstant].
class CurrentTime extends Notifier<DateTime> {
  Timer? _ticker;

  @override
  DateTime build() {
    final demo = ref.watch(appSettingsProvider.select((s) => s.demoClock));
    final clock = ref.watch(clockProvider);

    _ticker?.cancel();
    ref.onDispose(() => _ticker?.cancel());

    if (demo) return kDemoInstant;

    // A fixed clock never changes, so there is nothing to tick — and no timer
    // left pending at the end of a widget test.
    if (clock is! FixedClock) {
      _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
        state = clock.now();
      });
    }
    return clock.now();
  }

  /// Re-reads the clock immediately (used after returning to the app).
  void refresh() {
    if (ref.read(appSettingsProvider).demoClock) {
      state = kDemoInstant;
    } else {
      state = ref.read(clockProvider).now();
    }
  }
}

final currentTimeProvider = NotifierProvider<CurrentTime, DateTime>(
  CurrentTime.new,
);
