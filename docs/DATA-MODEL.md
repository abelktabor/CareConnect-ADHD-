# Data Model

**Source of truth:** [`packages/mock-data/src/types.ts`](../packages/mock-data/src/types.ts)
**Fixtures:** [`packages/mock-data/src/fixtures.ts`](../packages/mock-data/src/fixtures.ts)

> **Mock and local only this term.** No backend, no network persistence, no real
> protected health information (PHI). Fixtures are deliberately fictional:
> placeholder names, the reserved `example.test` email domain, and 555-01xx phone
> numbers reserved for fiction. CareConnect is a course prototype, not a medical
> device. Do not add data that could be mistaken for a real person's records.

Persistence is `localStorage` on web, with the same shapes reused by mobile and
desktop through this shared package.

---

## Entities

### Person → Patient | Caregiver

`Person` carries the fields both roles share. `role` discriminates the union.

| Field | Type | Notes |
| --- | --- | --- |
| `id` | `Uuid` | |
| `role` | `'patient' \| 'caregiver'` | Discriminant |
| `displayName` | `string` | Preferred name — what the orientation bar greets the user with |
| `email` | `string` | Fictional |

**Patient** adds `primaryCaregiverId` (backs the persistent "Call my caregiver"
action, Must-Have 4) and `timeZone` (all display times are local; time blindness
means an off-by-an-hour label is a real failure).

**Caregiver** adds `relationshipToPatient` — shown to the patient in plain
language ("your sister") rather than as a role label — plus `patientIds` and
`phone`.

### Medication *(Must-Have 2)*

| Field | Type | Why it exists |
| --- | --- | --- |
| `name` | `string` | As the patient recognizes it, not the clinical name |
| `doseDescription` | `string` | Plain language — "one white tablet", never "1 tab PO QD" |
| `imageUrl` / `imageAlt` | `string \| null` | Pill image supports recognition over recall; alt text satisfies SC 1.1.1 |
| `scheduleTimes` | `LocalTime[]` | Local times due each day |
| `instructions` | `string \| null` | Short note: "take with food" |
| `active` | `boolean` | Soft-delete, so history stays intact |

### DoseEvent *(Must-Have 2)*

One row per scheduled dose. Status is `due` → `taken` | `skipped` | `missed`.

`undoableUntil` is the load-bearing field: **every** state change offers a
10-second undo, so a mis-tap never becomes something the patient has to ask a
caregiver to fix. Undo is *additive* — nothing is forfeited when the window
closes, which keeps it clear of SC 2.2.1 (Timing Adjustable).

`recordedAt` is separate from `scheduledFor` so the caregiver timeline can show
"taken at 8:06, due 8:00" without arithmetic.

### Appointment *(Must-Have 3)*

`displayDate` is stored as a pre-formatted full-word string
("Tuesday, August 25") rather than derived at render time — the requirement is
that no screen ever shows "8/25", and storing the display form makes that
checkable rather than a convention someone might forget.

`accompaniedByCaregiverId` answers "who is taking me" directly on the card.

### Task and TaskStep *(Accessibility rows: Task Steps, Progress, Save and Resume)*

A `Task` holds an ordered `steps` array plus `currentStepIndex`. That index is the
save-and-resume mechanism: it persists, so leaving mid-task and returning lands on
the same step. `StepProgress` renders "Step 2 of 4" from `currentStepIndex` and
`steps.length`.

Each `TaskStep.instruction` is one action in short, direct language.

### ReminderPreference *(Must-Have 5)*

The accessibility requirements say users control reminders, frequency, and snooze.
This entity is that control surfaced as data:

| Field | Purpose |
| --- | --- |
| `enabled` | Off is always allowed |
| `leadTimeMinutes` | How far ahead to notify |
| `snoozeOptionsMinutes` | Offered snooze durations; empty disables snooze |
| `maxRepeats` | Hard cap so reminders never become nagging |

### ActivityEntry *(Should-Have 8)*

Append-only feed backing the caregiver's recent-activity timeline. `summary` is
pre-written plain language so the timeline needs no interpretation.

---

## Relationships

```
Caregiver 1 ──── * Patient          (Caregiver.patientIds / Patient.primaryCaregiverId)
Patient   1 ──── * Medication
Patient   1 ──── * Appointment
Patient   1 ──── * Task ──── * TaskStep
Patient   1 ──── * ReminderPreference
Patient   1 ──── * ActivityEntry
Medication 1 ─── * DoseEvent
```

---

## Conventions

- **Dates and times** are ISO-8601 strings, not `Date` objects — they cross the
  localStorage boundary unchanged and stay comparable as strings.
- **Nullable over optional.** `string | null` rather than `string?`, so "not set"
  is explicit at every call site under `strict`.
- **Soft delete** via `active` flags. Deleting a medication must not erase the
  adherence history a caregiver relies on.
- **No derived state stored**, with one deliberate exception:
  `Appointment.displayDate`, for the reason given above.
