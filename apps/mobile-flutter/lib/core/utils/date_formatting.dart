import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Plain-language date and time formatting.
///
/// The requirement is that no screen ever shows a numeric date like "8/25":
/// people with time blindness parse "Tuesday, August 25" far more reliably.
/// Every string a user sees comes from one of these helpers so the rule is
/// enforced in one place and covered by `test/unit/date_formatting_test.dart`.
abstract final class DateFormatting {
  static final DateFormat _fullWordDate = DateFormat('EEEE, MMMM d');
  static final DateFormat _clockTime = DateFormat('h:mm a');
  static final DateFormat _dayHeading = DateFormat('EEEE, MMMM d');

  /// "Tuesday, August 25"
  static String fullWordDate(DateTime dateTime) =>
      _fullWordDate.format(dateTime);

  /// "2:14 PM"
  static String clockTime(DateTime dateTime) => _clockTime.format(dateTime);

  /// "Tuesday, August 25 · 2:30 PM"
  static String dateAndTime(DateTime dateTime) =>
      '${fullWordDate(dateTime)} · ${clockTime(dateTime)}';

  /// "TUESDAY, AUGUST 25" — timeline day headings.
  static String dayHeading(DateTime dateTime) =>
      _dayHeading.format(dateTime).toUpperCase();

  /// Parses a 24-hour local time such as "08:00" into a [TimeOfDay].
  static TimeOfDay parseLocalTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) {
      throw FormatException('Expected HH:mm, got "$hhmm"');
    }
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw FormatException('Time out of range: "$hhmm"');
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Formats a [TimeOfDay] as the storage form "08:00".
  static String toLocalTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// "8:00 AM" from the storage form "08:00".
  static String localTimeLabel(String hhmm) {
    final t = parseLocalTime(hhmm);
    return clockTime(DateTime(2000, 1, 1, t.hour, t.minute));
  }

  /// Combines a calendar day with a wall-clock time.
  static DateTime combine(DateTime day, TimeOfDay time) =>
      DateTime(day.year, day.month, day.day, time.hour, time.minute);

  /// Midnight at the start of [dateTime]'s day.
  static DateTime startOfDay(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Plain-language duration: "20 minutes", "1 hour", "2 hours", "1 day".
  ///
  /// [abbreviated] gives the compact chip form: "20 min", "1 hour", "2 hours".
  static String describeDuration(
    Duration duration, {
    bool abbreviated = false,
  }) {
    final minutes = duration.inMinutes.abs();
    if (minutes < 1) {
      return abbreviated ? 'under a min' : 'under a minute';
    }
    if (minutes < 60) {
      final unit = abbreviated ? 'min' : (minutes == 1 ? 'minute' : 'minutes');
      return '$minutes $unit';
    }
    final hours = duration.inHours.abs();
    if (hours < 24) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }
    final days = duration.inDays.abs();
    return '$days ${days == 1 ? 'day' : 'days'}';
  }

  /// Status text for a dose that has not been logged yet.
  ///
  /// * Upcoming within three hours → "Due in 20 min"
  /// * Later today → "Due at 6:00 PM"
  /// * Past its time → "Overdue — 45 min late"
  static String dueLabel(DateTime scheduledFor, DateTime now) {
    final delta = scheduledFor.difference(now);
    if (delta.isNegative) {
      return 'Overdue — ${describeDuration(delta, abbreviated: true)} late';
    }
    if (delta > const Duration(hours: 3)) {
      return 'Due at ${clockTime(scheduledFor)}';
    }
    return 'Due in ${describeDuration(delta, abbreviated: true)}';
  }

  /// Orientation-bar sentence: "Next: Metformin in 20 minutes".
  static String nextSentence(String name, DateTime scheduledFor, DateTime now) {
    final delta = scheduledFor.difference(now);
    if (delta.isNegative) {
      return 'Next: $name — ${describeDuration(delta)} overdue';
    }
    if (delta > const Duration(hours: 3)) {
      return 'Next: $name at ${clockTime(scheduledFor)}';
    }
    return 'Next: $name in ${describeDuration(delta)}';
  }
}
