## What this changes

<!-- One or two sentences. What does this PR do, and why? -->

Closes #

## Type of change

- [ ] Feature
- [ ] Bug fix
- [ ] Accessibility remediation
- [ ] Documentation
- [ ] Tooling / chore
- [ ] Tests

## Accessibility checklist

> Per the team charter, WCAG 2.2 AA is a **merge requirement**, not a later cleanup pass.
> If this PR does not touch the UI, check the N/A box and skip the rest.

- [ ] N/A — this PR does not change the user interface

Otherwise, all of the following must be checked:

- [ ] **Keyboard:** every new control is reachable and operable by keyboard alone; focus order is logical; no keyboard traps
- [ ] **Focus visible:** focus indicators are visible against every background they appear on
- [ ] **Screen reader:** tested with VoiceOver (macOS, `Cmd+F5`) or NVDA (Windows); all content and state changes are announced
- [ ] **Contrast:** text meets 4.5:1 (3:1 for large text and UI components)
- [ ] **Not color alone:** meaning is never conveyed by color by itself
- [ ] **Target size:** interactive targets meet WCAG 2.2 SC 2.5.8 (24×24 CSS px minimum; team standard is 44×44)
- [ ] **Reflow:** no horizontal scrolling at a 320px viewport width
- [ ] **Motion:** honors `prefers-reduced-motion`
- [ ] **Labels:** every form input has a programmatically associated label; errors are announced and describe the fix
- [ ] **Automated:** axe DevTools reports zero violations on the changed screens

**How I tested accessibility:**

<!-- Be specific: which screens, which tools, which assistive technology. -->

## Testing

- [ ] Tests added or updated for the changed behavior
- [ ] All tests pass locally
- [ ] Manually verified in the running application

**How to verify this manually:**

<!-- Steps a reviewer can follow. -->

## Screenshots

<!-- Before/after for any visual change. Delete if not applicable. -->

## Reviewer notes

- [ ] I did **not** commit secrets, `.env` files, or build output
- [ ] I updated any documentation this change makes stale
- [ ] The branch name follows the charter convention: `<name>/<short-feature-description>` (e.g. `shayne/patient-medications`)

## Definition of Done

Per the team charter, this work is complete only when **all five** are true:

- [ ] **Merged** via a reviewed pull request
- [ ] **Tested**
- [ ] **Checked for accessibility** (WCAG 2.2 AA)
- [ ] **Documented**
- [ ] **Demoed** to the team

> Reviewers: at least one other team member must review before merge, checking
> functionality **and WCAG 2.2 AA compliance**. CI must be green. Squash-merge after
> approval. Prefix non-blocking comments with `nit:`.
