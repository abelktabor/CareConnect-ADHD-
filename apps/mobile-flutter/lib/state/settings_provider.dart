import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_store.dart';

/// General app preferences (App Settings screen).
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.demoClock = false,
    this.shareWithCaregiver = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode: ThemeMode.values.firstWhere(
      (m) => m.name == json['themeMode'],
      orElse: () => ThemeMode.system,
    ),
    demoClock: json['demoClock'] as bool? ?? false,
    shareWithCaregiver: json['shareWithCaregiver'] as bool? ?? true,
  );

  final ThemeMode themeMode;

  /// Freezes the clock at the Week 3 design instant (Tuesday, August 25,
  /// 2:14 PM) so every screen matches the Figma frames.
  final bool demoClock;

  /// Whether the caregiver can see the care recipient's data
  /// (My Caregiver Access screen).
  final bool shareWithCaregiver;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? demoClock,
    bool? shareWithCaregiver,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      demoClock: demoClock ?? this.demoClock,
      shareWithCaregiver: shareWithCaregiver ?? this.shareWithCaregiver,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'demoClock': demoClock,
    'shareWithCaregiver': shareWithCaregiver,
  };

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.demoClock == demoClock &&
      other.shareWithCaregiver == shareWithCaregiver;

  @override
  int get hashCode => Object.hash(themeMode, demoClock, shareWithCaregiver);
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref
        .watch(localStoreProvider)
        .readAs(
          StoreKeys.settings,
          AppSettings.fromJson,
          orElse: AppSettings.new,
        );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  Future<void> setDemoClock({required bool enabled}) =>
      _update(state.copyWith(demoClock: enabled));

  Future<void> setShareWithCaregiver({required bool enabled}) =>
      _update(state.copyWith(shareWithCaregiver: enabled));

  Future<void> _update(AppSettings next) async {
    state = next;
    await ref
        .read(localStoreProvider)
        .writeJson(StoreKeys.settings, next.toJson());
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(appSettingsProvider.select((s) => s.themeMode)),
);
