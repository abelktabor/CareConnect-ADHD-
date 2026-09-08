# ADR 0001 — Mobile framework

**Status:** ✅ **Accepted — 2026-09-05.** Flutter for Assignments 3–4 at `apps/mobile-flutter`; React Native + Expo for Assignments 5–6 at `apps/mobile-react-native`. The course sequence requires both, so this is "how to hold both", not either/or.
**Date raised:** August 18, 2026
**Deciders:** Team E-Echo (Shayne McPherson, Abel Tabor, Quinton Coleman)

---

## Context

CareConnect must ship on mobile. Two candidates are in play, and the repository
structure depends on which one wins.

### Option A — React Native + Expo

- Shares TypeScript, Jest, and ESLint tooling with `apps/web`
- Joins the npm workspace graph directly, so `@careconnect/ui`,
  `@careconnect/design-tokens`, and `@careconnect/mock-data` are consumed as
  ordinary workspace dependencies with no duplication
- One language across web, mobile, and desktop — relevant for a three-person team
  ramping up on several stacks at once (proposal risk R2)
- Accessibility APIs map closely to the web ARIA model the team already targets

### Option B — Flutter

- Standalone Dart project; does not participate in npm workspaces
- Domain types in `@careconnect/mock-data` would need a hand-maintained Dart
  twin, and design tokens a second source of truth
- Different accessibility API surface (`Semantics` widgets) — a separate learning
  curve from the web work
- Requires `lcov`/`genhtml` for coverage, which is a separate toolchain install

## ⚠️ Complication — this may not be an either/or

The **submitted Project Proposal** names the course-wide toolchain as
"**Flutter and React Native** for mobile" — and the course assignment sequence
appears to require both: Flutter for Assignments 3–4, React Native for
Assignments 5–6.

If that reading is correct, this ADR is not choosing between the two. It is
deciding **how to hold both**, and the structure becomes:

```
apps/
├── mobile-flutter/          # standalone Dart project, outside npm workspaces
└── mobile-react-native/     # Expo project, inside npm workspaces
```

The proposal's risk R2 already flags simultaneous ramp-up on Flutter, React
Native, and Electron as a scheduling risk, which is consistent with both being
required.

## Decision

**Both.** The team meeting of 2026-09-05 confirmed Week 4 implements the Week 3
design in Flutter. The Flutter app lives at `apps/mobile-flutter` as a
standalone Dart project outside the npm workspaces (ADR 0003 covers the
repository move). The domain types are mirrored by hand in
`apps/mobile-flutter/lib/models` and the design tokens in
`lib/core/theme/app_colors.dart`, each with a test that re-verifies contrast so
the two sources of truth cannot drift silently. React Native follows in
Assignment 5 and joins the workspaces.

## Consequences of deferring

Low. `apps/mobile/` is a placeholder README and is excluded from the root
`workspaces` array, so nothing in the current build depends on the outcome. The
shared packages are framework-neutral TypeScript, which Option A consumes
directly and Option B would need to mirror.

## Follow-up

- [x] Assignments 3–4 (Flutter) and 5–6 (React Native) both deliver an app
- [x] `apps/mobile-flutter` scaffolded (Assignment 4); `apps/mobile` placeholder removed
- [ ] `apps/mobile-react-native` (Expo) — Assignment 5, add to `workspaces`
- [x] Root README platform table updated; `docs/ARCHITECTURE.md` to follow with the RN app
