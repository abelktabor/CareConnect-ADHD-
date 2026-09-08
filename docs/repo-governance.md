# Repository Governance

**Course:** SWEN 661 9040 — User Interface Implementation (2268)
**Assignment:** 1, Part 4 (Repository Setup)

This document covers the repository configuration that lives in **GitHub settings**
rather than in files. The Assignment 1 rubric's *Highly Proficient* band asks for
branch protection rules, issue templates, and a project board; issue and PR templates
are in `.github/`, and the settings-side work is recorded here.

> These steps require repository admin access and cannot be applied from a local clone.
> Each has a checkbox — check it off once applied on GitHub.

---

## 1. Collaborators

Assignment 1, Part 4 requires all team members to be collaborators.

- [x] Add **Abel Tabor** — [`@abelktabor`](https://github.com/abelktabor) — with **Write** access ✅ *invite sent 2026-08-18*
- [x] Add **Quinton Coleman** — [`@colemaninternational80-cmyk`](https://github.com/colemaninternational80-cmyk) — with **Write** access ✅ *added 2026-08-18*
- [ ] Add the instructor as a collaborator (or make the repository public) so it is
      accessible for grading — the rubric's *Beginning* band is "repository not
      accessible to team/instructor"

**Settings → Collaborators and teams → Add people**, or:

```bash
gh api -X PUT repos/shaynemcp/careconnect-swen661-reference/collaborators/abelktabor -f permission=push && gh api -X PUT repos/shaynemcp/careconnect-swen661-reference/collaborators/colemaninternational80-cmyk -f permission=push
```

---

## 2. Branch protection on `main`

The team charter states `main` is protected and every change arrives through a pull
request. Configure under **Settings → Branches → Add branch protection rule**, pattern
`main`:

- [ ] **Require a pull request before merging**
  - [ ] Require approvals: **1**
  - [ ] Dismiss stale pull request approvals when new commits are pushed
  - [ ] Require review from Code Owners *(uses `.github/CODEOWNERS`)*
- [ ] **Require status checks to pass before merging**
  - [ ] Require branches to be up to date before merging
  - [ ] Required check: `Web (React + Vite)` *(from `.github/workflows/ci.yml`)*
- [ ] **Require conversation resolution before merging**
- [ ] **Do not allow bypassing the above settings**
- [ ] Block force pushes
- [ ] Block deletions

Equivalent via the CLI:

```bash
gh api -X PUT repos/shaynemcp/careconnect-swen661-reference/branches/main/protection --input .github/branch-protection.json
```

A ready-to-use payload is stored at `.github/branch-protection.json`.

**Repository defaults** — **Settings → General → Pull Requests**:

- [ ] Allow **squash merging** only (disable merge commits and rebase merging) — the
      charter's merge policy is squash-and-merge
- [ ] Automatically delete head branches after merge

---

## 3. Project board

- [ ] Create a **Projects (v2) board** named `CareConnect — Semester Plan`
- [ ] Columns: `Backlog` → `Ready` → `In Progress` → `In Review` → `Done`
- [ ] Add custom fields:
  - `Assignment` (single select: A1 … A10)
  - `Platform` (single select: Web, Flutter, React Native, Electron, Docs)
  - `Priority` (single select: Must-Have, Should-Have, Nice-to-Have)
- [ ] Enable the built-in workflows: auto-add new issues to `Backlog`, move to `Done`
      when closed, move to `In Review` when a linked PR opens
- [ ] Seed the board from `docs/project-proposal.md` §3 — one issue per feature F1–F13,
      created with the **Feature / requirement** template

```bash
gh project create --owner shaynemcp --title "CareConnect — Semester Plan"
```

---

## 4. Labels

Beyond GitHub's defaults, create:

| Label | Color | Use |
| --- | --- | --- |
| `accessibility` | `#0E8A16` | WCAG conformance work — triaged ahead of features |
| `must-have` | `#B60205` | Required for a passing product |
| `should-have` | `#FBCA04` | Planned; first to descope under schedule pressure |
| `nice-to-have` | `#C5DEF5` | Built only if ahead of schedule |
| `platform:web` | `#1D76DB` | React + Vite |
| `platform:flutter` | `#5319E7` | Flutter / Dart |
| `platform:react-native` | `#006B75` | React Native / Expo |
| `platform:electron` | `#D93F0B` | Electron (macOS) |
| `needs-triage` | `#EDEDED` | Awaiting QA Lead triage |
| `blocked` | `#000000` | Cannot proceed; note the blocker in the issue |

```bash
gh label create accessibility --color 0E8A16 --description "WCAG conformance work"
```

---

## 5. Security hygiene

- [ ] Confirm `.env` is ignored and has never been committed:
      `git log --all --full-history -- .env` should return nothing
- [ ] Enable **Dependabot alerts** and **secret scanning** under
      **Settings → Code security**
- [ ] Confirm no API key is committed: `ANTHROPIC_API_KEY` must remain server-side and
      must never carry a `VITE_` prefix, which would bundle it into the client

---

## 6. Verification checklist for Assignment 1 submission

| Requirement | Where | Done |
| --- | --- | --- |
| Repository exists on GitHub | `shaynemcp/careconnect-swen661-reference` | ✅ |
| All team members are collaborators | §1 above — Abel and Quinton added 2026-08-18 | ✅ |
| Instructor can access the repository | §1 above | ☐ |
| README with project name and description | `README.md` | ✅ |
| README lists team member names | `README.md` — Team E-Echo, all three members | ✅ |
| README links to the team charter | `README.md` → `docs/team-charter.md` | ✅ |
| README has setup instructions | `README.md` | ✅ |
| `.gitignore` for Flutter, React Native, Electron, React | `.gitignore` — four labeled sections | ✅ |
| Basic project structure initialized | `src/`, `docs/`, `.github/`, `public/`, `scripts/` | ✅ |
| Branch protection rules | §2 above | ☐ |
| Issue templates | `.github/ISSUE_TEMPLATE/` | ✅ |
| Project board | §3 above | ☐ |
| CI configured | `.github/workflows/ci.yml` | ✅ |
