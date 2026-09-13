import {
  clockTime,
  combine,
  dateAndTime,
  dayHeading,
  describeDuration,
  dueLabel,
  fullWordDate,
  isSameDay,
  localTimeLabel,
  nextSentence,
  parseLocalTime,
  startOfDay,
  toLocalTime,
} from './dateFormatting';

describe('fullWordDate', () => {
  it('formats as weekday, month day', () => {
    expect(fullWordDate(new Date(2026, 7, 25))).toBe('Tuesday, August 25');
  });
});

describe('clockTime', () => {
  it('formats afternoon time', () => {
    expect(clockTime(new Date(2026, 7, 25, 14, 14))).toBe('2:14 PM');
  });

  it('formats midnight as 12 AM', () => {
    expect(clockTime(new Date(2026, 7, 25, 0, 5))).toBe('12:05 AM');
  });

  it('formats noon as 12 PM', () => {
    expect(clockTime(new Date(2026, 7, 25, 12, 0))).toBe('12:00 PM');
  });

  it('pads single-digit minutes', () => {
    expect(clockTime(new Date(2026, 7, 25, 8, 4))).toBe('8:04 AM');
  });
});

describe('dateAndTime / dayHeading', () => {
  it('combines full word date and clock time', () => {
    expect(dateAndTime(new Date(2026, 7, 25, 14, 30))).toBe('Tuesday, August 25 · 2:30 PM');
  });

  it('upper-cases the day heading', () => {
    expect(dayHeading(new Date(2026, 7, 25))).toBe('TUESDAY, AUGUST 25');
  });
});

describe('parseLocalTime / toLocalTime / localTimeLabel', () => {
  it('parses a valid HH:mm', () => {
    expect(parseLocalTime('08:00')).toEqual({ hour: 8, minute: 0 });
  });

  it('throws on malformed input', () => {
    expect(() => parseLocalTime('8am')).toThrow();
    expect(() => parseLocalTime('25:00')).toThrow();
    expect(() => parseLocalTime('08:70')).toThrow();
  });

  it('round-trips through toLocalTime', () => {
    expect(toLocalTime({ hour: 8, minute: 0 })).toBe('08:00');
    expect(toLocalTime({ hour: 18, minute: 5 })).toBe('18:05');
  });

  it('renders a clock label from storage form', () => {
    expect(localTimeLabel('08:00')).toBe('8:00 AM');
    expect(localTimeLabel('18:00')).toBe('6:00 PM');
  });
});

describe('combine / startOfDay / isSameDay', () => {
  it('combines a day with a time', () => {
    const day = new Date(2026, 7, 25);
    const combined = combine(day, { hour: 14, minute: 30 });
    expect(combined).toEqual(new Date(2026, 7, 25, 14, 30));
  });

  it('finds the start of the day', () => {
    expect(startOfDay(new Date(2026, 7, 25, 23, 59))).toEqual(new Date(2026, 7, 25));
  });

  it('compares calendar days regardless of time', () => {
    expect(isSameDay(new Date(2026, 7, 25, 1), new Date(2026, 7, 25, 23))).toBe(true);
    expect(isSameDay(new Date(2026, 7, 25), new Date(2026, 7, 26))).toBe(false);
  });
});

describe('describeDuration', () => {
  it('describes under a minute', () => {
    expect(describeDuration(30_000)).toBe('under a minute');
    expect(describeDuration(30_000, true)).toBe('under a min');
  });

  it('describes minutes, singular and plural', () => {
    expect(describeDuration(60_000)).toBe('1 minute');
    expect(describeDuration(20 * 60_000)).toBe('20 minutes');
    expect(describeDuration(20 * 60_000, true)).toBe('20 min');
  });

  it('describes hours', () => {
    expect(describeDuration(60 * 60_000)).toBe('1 hour');
    expect(describeDuration(2 * 60 * 60_000)).toBe('2 hours');
  });

  it('describes days', () => {
    expect(describeDuration(24 * 60 * 60_000)).toBe('1 day');
    expect(describeDuration(2 * 24 * 60 * 60_000)).toBe('2 days');
  });

  it('takes the magnitude of a negative duration', () => {
    expect(describeDuration(-45 * 60_000, true)).toBe('45 min');
  });
});

describe('dueLabel', () => {
  const now = new Date(2026, 7, 25, 14, 14);

  it('shows overdue with how late', () => {
    const scheduled = new Date(2026, 7, 25, 13, 29);
    expect(dueLabel(scheduled, now)).toBe('Overdue — 45 min late');
  });

  it('shows "due in" within three hours', () => {
    const scheduled = new Date(2026, 7, 25, 14, 34);
    expect(dueLabel(scheduled, now)).toBe('Due in 20 min');
  });

  it('shows "due at" beyond three hours', () => {
    const scheduled = new Date(2026, 7, 25, 18, 0);
    expect(dueLabel(scheduled, now)).toBe('Due at 6:00 PM');
  });
});

describe('nextSentence', () => {
  const now = new Date(2026, 7, 25, 14, 14);

  it('describes an overdue next dose', () => {
    expect(nextSentence('Atorvastatin', new Date(2026, 7, 25, 13, 29), now)).toBe(
      'Next: Atorvastatin — 45 minutes overdue',
    );
  });

  it('describes a soon dose', () => {
    expect(nextSentence('Metformin', new Date(2026, 7, 25, 14, 34), now)).toBe(
      'Next: Metformin in 20 minutes',
    );
  });

  it('describes a later dose by clock time', () => {
    expect(nextSentence('Lisinopril', new Date(2026, 7, 25, 18, 0), now)).toBe(
      'Next: Lisinopril at 6:00 PM',
    );
  });
});
