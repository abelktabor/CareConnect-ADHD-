# ADR 0001 — Mobile framework

**Status:** 🟡 **OPEN — not decided.** Do not resolve this without the team.
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

**Not yet made.** Confirm with the instructor whether both mobile frameworks are
required before committing to a structure.

## Consequences of deferring

Low. `apps/mobile/` is a placeholder README and is excluded from the root
`workspaces` array, so nothing in the current build depends on the outcome. The
shared packages are framework-neutral TypeScript, which Option A consumes
directly and Option B would need to mirror.

## Follow-up

- [ ] Confirm with the instructor whether Assignments 3–4 (Flutter) and 5–6
      (React Native) both require a delivered app
- [ ] If both: rename to `apps/mobile-flutter` and `apps/mobile-react-native`
- [ ] If one: scaffold it in `apps/mobile` and add to `workspaces` if it is Expo
- [ ] Update `docs/ARCHITECTURE.md` and the root README platform table either way
