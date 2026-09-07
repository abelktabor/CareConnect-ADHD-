import { space, typography, color } from '@careconnect/design-tokens';

export interface StepProgressProps {
  /** 1-based index of the current step. */
  current: number;
  /** Total number of steps. */
  total: number;
  /** Optional label for the current step. */
  stepLabel?: string;
}

/**
 * "Step 2 of 4" progress indicator.
 *
 * Accessibility requirements met:
 * - Progress — shows position explicitly rather than implying it (Progress row)
 * - Task Steps — supports breaking long tasks into short numbered steps
 * - Attention Recovery — states where the user is and what to do next
 * - Screen Readers — exposed as a labeled progressbar with text alternative
 * - Color — position is carried by text, never by color or a bar alone
 */
export function StepProgress({ current, total, stepLabel }: StepProgressProps) {
  const text = `Step ${current} of ${total}`;

  return (
    <div
      role="progressbar"
      aria-valuenow={current}
      aria-valuemin={1}
      aria-valuemax={total}
      aria-valuetext={stepLabel ? `${text}: ${stepLabel}` : text}
      style={{
        display: 'flex',
        flexDirection: 'column',
        gap: space.xs,
        fontSize: typography.size.body,
        color: color.text.primary,
      }}
    >
      {/* Text first: the count is readable without interpreting the bar. */}
      <span style={{ fontWeight: typography.weight.bold }}>{text}</span>
      {stepLabel ? <span style={{ color: color.text.secondary }}>{stepLabel}</span> : null}
      <span
        aria-hidden="true"
        style={{
          display: 'block',
          height: '0.5rem',
          borderRadius: '9999px',
          background: color.surface.subtle,
          border: `1px solid ${color.border.default}`,
          overflow: 'hidden',
        }}
      >
        <span
          style={{
            display: 'block',
            height: '100%',
            width: `${Math.round((current / total) * 100)}%`,
            background: color.primary.default,
          }}
        />
      </span>
    </div>
  );
}
