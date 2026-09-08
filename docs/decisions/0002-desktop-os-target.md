# ADR 0002 — Desktop OS target

**Status:** 🟡 **OPEN — not decided.** Do not resolve this without the team.
**Date raised:** August 18, 2026
**Deciders:** Team E-Echo (Shayne McPherson, Abel Tabor, Quinton Coleman)

---

## Context

Two course artifacts disagree:

| Source | Says |
| --- | --- |
| **Assignment 1 instructions** | "Desktop: Which OS will you target? (Windows, macOS, or Linux — choose **ONE**)" |
| **Team Charter / Project Proposal** | Platform coverage constraint specifies **both Windows and macOS** |

The team's machines cover both natively — Abel (Windows 10) and Quinton
(Windows) develop on Windows, Shayne on macOS — so each target can be built and
accessibility-tested without virtual machines (NVDA on Windows, VoiceOver on
macOS).

## Why this does not block scaffolding

Electron produces both targets from a single codebase and a single
`electron-builder` configuration. `apps/desktop` is written OS-neutrally, so the
decision changes packaging configuration and the QA matrix — not application
code.

## Options

**A — Both Windows and macOS.** Matches the charter and proposal. Roughly doubles
desktop build and QA surface within the same timeline (proposal risk R1). Needs
instructor confirmation that deviating from "choose ONE" is acceptable.

**B — macOS only.** Matches the assignment instructions literally. VoiceOver is
available for the Assignment 9 accessibility audit. Leaves the two Windows
developers unable to run the desktop build natively.

**C — Windows only.** Matches the assignment instructions literally, and matches
the majority of the team's machines. NVDA is the screen reader of record.

## Decision

**Not yet made.** Raise at proposal approval.

## Consequences of deferring

Low, with one constraint: **do not introduce OS-specific APIs** into
`apps/desktop` while this is open. If one becomes necessary, isolate it behind a
thin adapter rather than scattering platform checks through the UI, and note it
here.

## Follow-up

- [ ] Ask the instructor whether the dual Windows + macOS target is acceptable
      given the assigned platform-coverage constraint
- [ ] Record the answer here and update `README.md`, `docs/build-plan.md`,
      `docs/project-proposal.md`, and `docs/ARCHITECTURE.md`
- [ ] Add the confirmed `electron-builder` targets to `apps/desktop/package.json`
