# Architecture

## Shape

A single npm-workspaces monorepo. One shared design system and domain model; three
platform shells consume them.

```
careconnect/
├── apps/
│   ├── web/        React 18 + Vite + TypeScript (strict) + Tailwind, PWA
│   ├── mobile/     ⚠️ placeholder — framework undecided (ADR 0001)
│   └── desktop/    Electron shell over the web build (ADR 0002)
└── packages/
    ├── design-tokens/   Colors, spacing, type, motion, focus ring
    ├── ui/              Shared accessible components
    └── mock-data/       Domain types + fictional fixtures
```

## Why a monorepo

The graded requirement is one product on three platforms, conforming to WCAG 2.2 AA
everywhere. Accessibility work that lives in a shared package is done once; the same
work copied across three repositories drifts, and drift is what fails an audit.

`packages/mock-data` holds the domain types, so a change to the `Medication` shape
is a compile error in every app that consumes it rather than a runtime surprise on
one platform.

## Dependency direction

```
apps/web ──┐
apps/desktop ──┼──> packages/ui ──> packages/design-tokens
apps/mobile ──┘                └──> packages/mock-data
```

Strictly one-directional. **No package may import from an app.** If an app needs
something from a sibling app, it belongs in a package.

`apps/desktop` is a thin Electron shell that loads the built web bundle — the
accessibility work done for web therefore carries to desktop, and the
Windows/macOS dual target stays cheap.

## Data and state

Mock and local this term. `localStorage` on web, keyed per entity, seeded from
`@careconnect/mock-data`. No backend, no network, no real PHI. `.env.example`
exists to hold a future AI-assistant key; nothing reads it today.

## Accessibility as architecture

These are structural decisions, not styling:

- **Design tokens carry contrast guarantees.** Every documented color pair is
  verified by `npm run check:contrast`, which exits non-zero on failure so CI can
  gate on it. Adding an unverified color is a build concern, not a review nicety.
- **44×44 minimum targets** live in `target.teamMinimum` — above the 24×24 that
  WCAG 2.2 SC 2.5.8 requires, because mis-taps cost more for this user group.
- **Motion tokens exist to be suppressed.** Every duration is used behind a
  `prefers-reduced-motion` guard.
- **Undo is additive, never a deadline.** The 10-second window adds a recovery
  path; nothing is lost when it closes, which keeps it clear of SC 2.2.1.
- **Shared components over per-app copies**, so "keep menus and buttons in
  consistent locations" holds by construction.

## Open decisions

| ADR | Decision | Status |
| --- | --- | --- |
| [0001](decisions/0001-mobile-framework.md) | Mobile framework — React Native, Flutter, or both | 🟡 Open |
| [0002](decisions/0002-desktop-os-target.md) | Desktop OS — Windows, macOS, or both | 🟡 Open |

Neither blocks current work. `apps/mobile` is excluded from `workspaces` until
0001 lands; `apps/desktop` avoids OS-specific APIs until 0002 lands.
