/**
 * Plain-language date and time formatting.
 *
 * The requirement is that no screen ever shows a numeric date like "8/25":
 * people with time blindness parse "Tuesday, August 25" far more reliably.
 * Every string a user sees comes from one of these helpers so the rule is
 * enforced in one place and covered by `dateFormatting.test.ts`.
 *
 * Formatting is hand-rolled (no `Intl`/ICU dependency) so it behaves
 * identically under Hermes, Node/Jest and the web build.
 *
 * Port of lib/core/utils/date_formatting.dart.
 */

const WEEKDAYS = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

const MONTHS = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

export interface LocalTime {
  hour: number;
  minute: number;
}

/** "Tuesday, August 25" */
export function fullWordDate(date: Date): string {
  return `${WEEKDAYS[date.getDay()]}, ${MONTHS[date.getMonth()]} ${date.getDate()}`;
}

/** "2:14 PM" */
export function clockTime(date: Date): string {
  let hour = date.getHours();
  const minute = date.getMinutes();
  const period = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour === 0) hour = 12;
  return `${hour}:${String(minute).padStart(2, '0')} ${period}`;
}

/** "Tuesday, August 25 · 2:30 PM" */
export function dateAndTime(date: Date): string {
  return `${fullWordDate(date)} · ${clockTime(date)}`;
}

/** "TUESDAY, AUGUST 25" — timeline day headings. */
export function dayHeading(date: Date): string {
  return fullWordDate(date).toUpperCase();
}

/** Parses a 24-hour local time such as "08:00" into an { hour, minute }. */
export function parseLocalTime(hhmm: string): LocalTime {
  const parts = hhmm.split(':');
  if (parts.length !== 2) {
    throw new Error(`Expected HH:mm, got "${hhmm}"`);
  }
  const hour = Number.parseInt(parts[0], 10);
  const minute = Number.parseInt(parts[1], 10);
  if (
    Number.isNaN(hour) ||
    Number.isNaN(minute) ||
    hour < 0 ||
    hour > 23 ||
    minute < 0 ||
    minute > 59
  ) {
    throw new Error(`Time out of range: "${hhmm}"`);
  }
  return { hour, minute };
}

/** Formats a local time as the storage form "08:00". */
export function toLocalTime(time: LocalTime): string {
  const h = String(time.hour).padStart(2, '0');
  const m = String(time.minute).padStart(2, '0');
  return `${h}:${m}`;
}

/** "8:00 AM" from the storage form "08:00". */
export function localTimeLabel(hhmm: string): string {
  const t = parseLocalTime(hhmm);
  return clockTime(new Date(2000, 0, 1, t.hour, t.minute));
}

/** Combines a calendar day with a wall-clock time. */
export function combine(day: Date, time: LocalTime): Date {
  return new Date(day.getFullYear(), day.getMonth(), day.getDate(), time.hour, time.minute);
}

/** Midnight at the start of `date`'s day. */
export function startOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

export function isSameDay(a: Date, b: Date): boolean {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}

const MINUTE_MS = 60_000;
const HOUR_MS = 3_600_000;
const DAY_MS = 86_400_000;

/**
 * Plain-language duration: "20 minutes", "1 hour", "2 hours", "1 day".
 *
 * `abbreviated` gives the compact chip form: "20 min", "1 hour", "2 hours".
 * `deltaMs` may be negative; only the magnitude is described.
 */
export function describeDuration(deltaMs: number, abbreviated = false): string {
  const minutes = Math.trunc(Math.abs(deltaMs) / MINUTE_MS);
  if (minutes < 1) {
    return abbreviated ? 'under a min' : 'under a minute';
  }
  if (minutes < 60) {
    const unit = abbreviated ? 'min' : minutes === 1 ? 'minute' : 'minutes';
    return `${minutes} ${unit}`;
  }
  const hours = Math.trunc(Math.abs(deltaMs) / HOUR_MS);
  if (hours < 24) {
    return `${hours} ${hours === 1 ? 'hour' : 'hours'}`;
  }
  const days = Math.trunc(Math.abs(deltaMs) / DAY_MS);
  return `${days} ${days === 1 ? 'day' : 'days'}`;
}

/**
 * Status text for a dose that has not been logged yet.
 *
 * - Upcoming within three hours -> "Due in 20 min"
 * - Later today -> "Due at 6:00 PM"
 * - Past its time -> "Overdue — 45 min late"
 */
export function dueLabel(scheduledFor: Date, now: Date): string {
  const delta = scheduledFor.getTime() - now.getTime();
  if (delta < 0) {
    return `Overdue — ${describeDuration(delta, true)} late`;
  }
  if (delta > 3 * HOUR_MS) {
    return `Due at ${clockTime(scheduledFor)}`;
  }
  return `Due in ${describeDuration(delta, true)}`;
}

/** Orientation-bar sentence: "Next: Metformin in 20 minutes". */
export function nextSentence(name: string, scheduledFor: Date, now: Date): string {
  const delta = scheduledFor.getTime() - now.getTime();
  if (delta < 0) {
    return `Next: ${name} — ${describeDuration(delta)} overdue`;
  }
  if (delta > 3 * HOUR_MS) {
    return `Next: ${name} at ${clockTime(scheduledFor)}`;
  }
  return `Next: ${name} in ${describeDuration(delta)}`;
}
