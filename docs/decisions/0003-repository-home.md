# ADR 0003 — Repository home and branch model

**Status:** ✅ **Accepted** — 2026-09-05 (team meeting), implemented 2026-09-06
**Deciders:** Team E-Echo (Shayne McPherson, Abel Tabor, Quinton Coleman)

---

## Context

Two repositories existed:

- `abelktabor/CareConnect-ADHD-` — created by Abel at project start, all three
  members invited (Abel admin, Shayne and Quinton write). Held a README stub
  and an empty accessibility file.
- `shaynemcp/careconnect-swen661-reference` — Shayne's fork of the
  instructor's reference implementation, where Assignment 1 was built out:
  monorepo layout, documentation set, CI, design tokens, mock data.

Being a fork had side effects (Issues disabled by default, PRs defaulting to
the instructor's upstream, no organisation ownership) and the team needed one
shared home before implementation week.

## Decision

1. **`abelktabor/CareConnect-ADHD-` is the team repository.** The full
   history of the fork was merged in (`--allow-unrelated-histories`) so every
   document, CI workflow and package survives with its history. The fork is
   kept as an archive remote (`fork`).
2. **Shayne's README stays.** Abel asked for it because it was the more
   complete one; Abel's stub README and the one-word `Accessibility.md` were
   superseded by it and by `docs/ACCESSIBILITY.md`.
3. **Branch model:** `main` holds submitted milestones; **`dev`** is the
   integration branch; feature branches follow the charter convention
   `<name>/<short-feature-description>` and open pull requests **into `dev`**.
   Squash-merge after one teammate's review, as in the charter.
4. **Never open a PR against `aliminagar/careconnect-swen661`** (the
   instructor's upstream). The new repository is not a fork, which removes the
   accidental-upstream-PR risk entirely.

## Consequences

- Repository governance items from Assignment 1 (branch protection on `main`,
  required checks, project board) must be re-applied here by Abel as admin.
  Until then `dev` relies on the PR-review norm rather than an enforced rule.
- Existing open PRs on the fork (security hardening, persona reseed, ADR 0003
  draft) are superseded; anything still wanted is re-opened against `dev`.
- CI runs on both `main` and `dev` (`ci.yml`, `flutter.yml`).
