import 'package:careconnect_mobile/core/utils/date_formatting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 25, 14, 14);

  group('full-word dates (never numeric)', () {
    test('fullWordDate', () {
      expect(DateFormatting.fullWordDate(now), 'Tuesday, August 25');
      expect(
        DateFormatting.fullWordDate(DateTime(2026, 9, 1)),
        'Tuesday, September 1',
      );
    });

    test('clockTime and dateAndTime', () {
      expect(DateFormatting.clockTime(now), '2:14 PM');
      expect(DateFormatting.clockTime(DateTime(2026, 8, 25, 8, 4)), '8:04 AM');
      expect(DateFormatting.clockTime(DateTime(2026, 8, 25, 0, 5)), '12:05 AM');
      expect(
        DateFormatting.dateAndTime(DateTime(2026, 8, 25, 14, 30)),
        'Tuesday, August 25 · 2:30 PM',
      );
    });

    test('dayHeading is upper-case', () {
      expect(DateFormatting.dayHeading(now), 'TUESDAY, AUGUST 25');
    });

    test('no formatter output contains a numeric slash date', () {
      for (final s in [
        DateFormatting.fullWordDate(now),
        DateFormatting.dateAndTime(now),
        DateFormatting.dayHeading(now),
      ]) {
        expect(s, isNot(contains('/')));
      }
    });
  });

  group('local times', () {
    test('parse and format storage form', () {
      expect(
        DateFormatting.parseLocalTime('08:00'),
        const TimeOfDay(hour: 8, minute: 0),
      );
      expect(
        DateFormatting.parseLocalTime('18:30'),
        const TimeOfDay(hour: 18, minute: 30),
      );
      expect(
        DateFormatting.toLocalTime(const TimeOfDay(hour: 8, minute: 5)),
        '08:05',
      );
      expect(DateFormatting.localTimeLabel('08:00'), '8:00 AM');
      expect(DateFormatting.localTimeLabel('18:00'), '6:00 PM');
    });

    test('rejects malformed or out-of-range times', () {
      expect(() => DateFormatting.parseLocalTime('8'), throwsFormatException);
      expect(
        () => DateFormatting.parseLocalTime('25:00'),
        throwsFormatException,
      );
      expect(
        () => DateFormatting.parseLocalTime('08:60'),
        throwsFormatException,
      );
      expect(
        () => DateFormatting.parseLocalTime('ab:cd'),
        throwsFormatException,
      );
    });

    test('combine, startOfDay and isSameDay', () {
      final combined = DateFormatting.combine(
        DateTime(2026, 8, 25, 23, 59),
        const TimeOfDay(hour: 6, minute: 30),
      );
      expect(combined, DateTime(2026, 8, 25, 6, 30));
      expect(DateFormatting.startOfDay(now), DateTime(2026, 8, 25));
      expect(DateFormatting.isSameDay(now, DateTime(2026, 8, 25, 1)), isTrue);
      expect(DateFormatting.isSameDay(now, DateTime(2026, 8, 26)), isFalse);
    });
  });

  group('plain-language durations', () {
    test('describeDuration', () {
      expect(
        DateFormatting.describeDuration(const Duration(minutes: 20)),
        '20 minutes',
      );
      expect(
        DateFormatting.describeDuration(
          const Duration(minutes: 20),
          abbreviated: true,
        ),
        '20 min',
      );
      expect(
        DateFormatting.describeDuration(const Duration(minutes: 1)),
        '1 minute',
      );
      expect(
        DateFormatting.describeDuration(const Duration(minutes: 60)),
        '1 hour',
      );
      expect(
        DateFormatting.describeDuration(const Duration(minutes: 150)),
        '2 hours',
      );
      expect(
        DateFormatting.describeDuration(const Duration(hours: 24)),
        '1 day',
      );
      expect(
        DateFormatting.describeDuration(const Duration(hours: 50)),
        '2 days',
      );
      expect(
        DateFormatting.describeDuration(const Duration(seconds: 20)),
        'under a minute',
      );
      expect(
        DateFormatting.describeDuration(
          const Duration(seconds: 20),
          abbreviated: true,
        ),
        'under a min',
      );
      expect(
        DateFormatting.describeDuration(const Duration(minutes: -45)),
        '45 minutes',
      );
    });

    test('dueLabel: soon, later today, overdue', () {
      expect(
        DateFormatting.dueLabel(DateTime(2026, 8, 25, 14, 34), now),
        'Due in 20 min',
      );
      expect(
        DateFormatting.dueLabel(DateTime(2026, 8, 25, 15, 14), now),
        'Due in 1 hour',
      );
      expect(
        DateFormatting.dueLabel(DateTime(2026, 8, 25, 18), now),
        'Due at 6:00 PM',
      );
      expect(
        DateFormatting.dueLabel(DateTime(2026, 8, 25, 13, 29), now),
        'Overdue — 45 min late',
      );
      expect(
        DateFormatting.dueLabel(DateTime(2026, 8, 25, 12, 14), now),
        'Overdue — 2 hours late',
      );
    });

    test('nextSentence for the orientation bar', () {
      expect(
        DateFormatting.nextSentence(
          'Metformin',
          DateTime(2026, 8, 25, 14, 34),
          now,
        ),
        'Next: Metformin in 20 minutes',
      );
      expect(
        DateFormatting.nextSentence(
          'Lisinopril',
          DateTime(2026, 8, 25, 18),
          now,
        ),
        'Next: Lisinopril at 6:00 PM',
      );
      expect(
        DateFormatting.nextSentence(
          'Atorvastatin',
          DateTime(2026, 8, 25, 13, 29),
          now,
        ),
        'Next: Atorvastatin — 45 minutes overdue',
      );
    });
  });
}
