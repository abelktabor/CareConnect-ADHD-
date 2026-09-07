# @careconnect/mobile — not yet scaffolded

**Blocked on an open decision.** See
[ADR 0001](../../docs/decisions/0001-mobile-framework.md).

This directory is intentionally a placeholder. The mobile framework is not
settled, and scaffolding the wrong one costs more than waiting:

- **React Native + Expo** shares TypeScript, Jest, and ESLint tooling with
  `apps/web` and the `packages/*` workspaces, so it drops straight into this
  monorepo and the npm workspace graph.
- **Flutter** is a standalone Dart project. It would live here as its own
  toolchain, share nothing with the npm workspaces, and duplicate the domain
  types now held in `@careconnect/mock-data`.

⚠️ **The submitted Project Proposal names *both*** — Flutter for Assignments 3–4
and React Native for Assignments 5–6, as the course-wide toolchain. If that
stands, this is not an either/or: plan for `apps/mobile-flutter` **and**
`apps/mobile-react-native`, and only the React Native app joins the npm
workspaces.

Until the team confirms, `apps/mobile` is excluded from the root `workspaces`
array so `npm install` stays clean.
