/**
 * The fixed colour + icon pairing for each status. Colour is never the only
 * carrier of meaning (WCAG SC 1.4.1): every tone has an icon and a text
 * label (see `StatusChip.tsx`).
 *
 * Port of lib/core/widgets/dose_status.dart.
 */
import type { MaterialIcons } from '@expo/vector-icons';
import { clockTime, describeDuration, dueLabel } from '../utils/dateFormatting';
import type { CcColors } from '../theme/colors';
import type { DoseEvent } from '../../models/types';
import { doseIsOverdue } from '../../models/domain';

export type StatusTone = 'due' | 'taken' | 'overdue' | 'skipped' | 'missed' | 'info' | 'success';

type IconName = keyof typeof MaterialIcons.glyphMap;

const STATUS_ICONS: Record<StatusTone, IconName> = {
  due: 'schedule',
  taken: 'check-circle',
  overdue: 'warning',
  skipped: 'cancel',
  missed: 'warning',
  info: 'info',
  success: 'check-circle',
};

export function statusToneIcon(tone: StatusTone): IconName {
  return STATUS_ICONS[tone];
}

export function statusToneColor(tone: StatusTone, colors: CcColors): string {
  switch (tone) {
    case 'due':
      return colors.warning;
    case 'taken':
    case 'success':
      return colors.success;
    case 'overdue':
    case 'missed':
      return colors.error;
    case 'skipped':
      return colors.textSecondary;
    case 'info':
      return colors.info;
  }
}

/** How a dose reads on screen and to a screen reader. */
export interface DoseStatusPresentation {
  tone: StatusTone;
  /** "Due", "Taken", "Overdue", "Skipped" */
  label: string;
  /** "Due in 20 min", "Taken at 8:04 AM", "Overdue — 45 min late" */
  detail: string;
  /** Screen-reader phrasing with abbreviations expanded. */
  spoken: string;
}

/** Derives the presentation for `dose` at `now`. */
export function doseStatusPresentation(dose: DoseEvent, now: Date): DoseStatusPresentation {
  switch (dose.status) {
    case 'due': {
      if (doseIsOverdue(dose, now)) {
        const late = describeDuration(now.getTime() - dose.scheduledFor.getTime());
        return {
          tone: 'overdue',
          label: 'Overdue',
          detail: dueLabel(dose.scheduledFor, now),
          spoken: `Overdue, ${late} late`,
        };
      }
      const delta = dose.scheduledFor.getTime() - now.getTime();
      const spoken =
        delta > 3 * 3_600_000
          ? `Due at ${clockTime(dose.scheduledFor)}`
          : `Due in ${describeDuration(delta)}`;
      return {
        tone: 'due',
        label: 'Due',
        detail: dueLabel(dose.scheduledFor, now),
        spoken,
      };
    }
    case 'taken': {
      const at = clockTime(dose.recordedAt ?? dose.scheduledFor);
      return { tone: 'taken', label: 'Taken', detail: `Taken at ${at}`, spoken: `Taken at ${at}` };
    }
    case 'skipped': {
      const at = clockTime(dose.recordedAt ?? dose.scheduledFor);
      return {
        tone: 'skipped',
        label: 'Skipped',
        detail: `Skipped at ${at}`,
        spoken: `Skipped at ${at}`,
      };
    }
    case 'missed': {
      const at = clockTime(dose.scheduledFor);
      return { tone: 'missed', label: 'Missed', detail: `Missed at ${at}`, spoken: `Missed at ${at}` };
    }
  }
}

/** "Due · Due in 20 min" — the visual chip text from the Figma. */
export function doseStatusChipText(presentation: DoseStatusPresentation): string {
  return `${presentation.label} · ${presentation.detail}`;
}
