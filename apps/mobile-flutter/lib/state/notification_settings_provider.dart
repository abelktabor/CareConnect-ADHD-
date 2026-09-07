import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_store.dart';
import '../models/notification_settings.dart';

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    final json = ref
        .watch(localStoreProvider)
        .readJson(StoreKeys.notifications);
    return json == null
        ? const NotificationSettings()
        : NotificationSettings.fromJson(json);
  }

  Future<void> setDailyDigest({required bool enabled}) =>
      _update(state.copyWith(dailyDigest: enabled));

  Future<void> setLeadTime(ReminderLeadTime leadTime) =>
      _update(state.copyWith(leadTime: leadTime));

  Future<void> _update(NotificationSettings next) async {
    state = next;
    await ref
        .read(localStoreProvider)
        .writeJson(StoreKeys.notifications, next.toJson());
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );
