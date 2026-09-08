import 'package:flutter/foundation.dart';

/// How far ahead a reminder fires. The three choices from the Notifications
/// screen — the user, not the app, decides how they want to be interrupted.
enum ReminderLeadTime {
  fifteenMinutes(minutes: 15, label: '15 min', spoken: '15 minutes before'),
  oneHour(minutes: 60, label: '1 hour', spoken: '1 hour before'),
  oneDay(minutes: 1440, label: '1 day', spoken: '1 day before');

  const ReminderLeadTime({
    required this.minutes,
    required this.label,
    required this.spoken,
  });

  final int minutes;

  /// Chip text.
  final String label;

  /// Screen-reader phrasing.
  final String spoken;

  static ReminderLeadTime fromStorage(String? value) =>
      ReminderLeadTime.values.firstWhere(
        (lead) => lead.name == value,
        orElse: () => ReminderLeadTime.oneHour,
      );
}

/// User-controlled reminder preferences (Must-Have 5: users control
/// reminders, frequency and snooze).
@immutable
class NotificationSettings {
  const NotificationSettings({
    this.dailyDigest = true,
    this.leadTime = ReminderLeadTime.oneHour,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        dailyDigest: json['dailyDigest'] as bool? ?? true,
        leadTime: ReminderLeadTime.fromStorage(json['leadTime'] as String?),
      );

  /// One summary a day instead of a stream of pings.
  final bool dailyDigest;
  final ReminderLeadTime leadTime;

  /// Overdue alerts always escalate immediately and are never held for the
  /// digest (US-16). This is not a preference, so it is a constant, and the
  /// Notifications screen shows it as a disabled, always-on control with an
  /// explanation rather than hiding it.
  static const bool overdueAlertsAlwaysOn = true;

  NotificationSettings copyWith({
    bool? dailyDigest,
    ReminderLeadTime? leadTime,
  }) {
    return NotificationSettings(
      dailyDigest: dailyDigest ?? this.dailyDigest,
      leadTime: leadTime ?? this.leadTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'dailyDigest': dailyDigest,
    'leadTime': leadTime.name,
  };

  @override
  bool operator ==(Object other) =>
      other is NotificationSettings &&
      other.dailyDigest == dailyDigest &&
      other.leadTime == leadTime;

  @override
  int get hashCode => Object.hash(dailyDigest, leadTime);
}
