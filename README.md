# CareConnect

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![React](https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-build-646CFF?logo=vite&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-strict-3178C6?logo=typescript&logoColor=white)
![WCAG 2.2 AA](https://img.shields.io/badge/WCAG-2.2%20AA-success)
![PWA](https://img.shields.io/badge/PWA-installable-5A0FC8)

**A cross-platform companion app for adults with ADHD — and the people who support them.**

CareConnect targets the gap between *knowing* what you need to do and *actually starting
it*. Instead of another backlog that assumes intact executive function, it surfaces one
next action at a time, keeps medication and appointment status permanently visible rather
than requiring recall, makes every action reversible so a mis-tap carries no anxiety, and
gives an optional support person visibility without turning them into a supervisor. Every
screen is engineered to **WCAG 2.2 Level AA**, with cognitive accessibility treated as a
first-class requirement alongside the sensory and motor criteria.

> Built for **SWEN 661 — User Interface Implementation (2268)** at UMGC, across four
> platforms: web (React + Vite), mobile (Flutter *and* React Native), and desktop
> (Electron, Windows and macOS).

---

## Team

**Team E-Echo**

| Member | Email | GitHub | OS | Role (Weeks 1–2) |
| --- | --- | --- | --- | --- |
| Shayne McPherson | shaynemcp@icloud.com | [@shaynemcp](https://github.com/shaynemcp) | macOS | Technical Lead |
| Abel Tabor | abelktabor@yahoo.com | [@abelktabor](https://github.com/abelktabor) | Windows 10 | Documentation Lead |
| Quinton Coleman | colemaninternational80@gmail.com | [@colemaninternational80-cmyk](https://github.com/colemaninternational80-cmyk) | Windows | QA / Testing Lead |

Roles rotate every two weeks — see the full rotation schedule in the team charter.

📄 **[Team Charter](docs/team-charter.md)** — roles, communication plan, git workflow,
decision making, and conflict resolution.

---

## Documentation

| Document | What it covers |
| --- | --- |
| **[Build Plan](docs/build-plan.md)** | How this repository grows across Assignments 1–10, the deferred `apps/` monorepo migration, and engineering conventions |
| **[Project Proposal](docs/project-proposal.md)** | Product overview, constraints, 13 prioritized features with acceptance criteria, platform plan, success criteria, risks |
| **[Team Charter](docs/team-charter.md)** | Team information, communication, role rotation, git workflow, work distribution, conflict resolution |
| **[Environment Setup](docs/environment-setup.md)** | Verified toolchain status on the development machine, gaps, and remediation commands |
| **[Repository Governance](docs/repo-governance.md)** | Collaborators, branch protection, project board, labels, security hygiene |
| **[Accessibility](docs/ACCESSIBILITY.md)** | Conformance mapping across 21 success criteria — inherited from the reference app at **WCAG 2.1**; migration to the team's 2.2 standard is tracked in the build plan |
| **[Architecture](docs/ARCHITECTURE.md)** | Monorepo shape, dependency direction, accessibility as architecture |
| **[Setup](docs/SETUP.md)** | Install, run, scripts, Windows notes |
| **[Testing](docs/TESTING.md)** | Test layers, gates, and the manual accessibility pass |
| **[Data Model](docs/DATA-MODEL.md)** | Mock schema for patients, caregivers, medications, appointments, tasks |
| **[Decisions (ADRs)](docs/decisions/)** | 0001 mobile framework · 0002 desktop OS — both open |
| **[Contributing](CONTRIBUTING.md)** | Branch naming, PR flow, team norms |
| **[Reference App README](docs/reference-app-readme.md)** | Archived upstream README with the screen-by-screen walkthrough |

### Canonical source documents

The team-completed Word originals of the two graded Assignment 1 documents live on UMGC
SharePoint. **Anyone signed in with a UMGC organization account can open them.**

| Document | Source of truth |
| --- | --- |
| Team Charter | [Open in SharePoint](https://umuc365-my.sharepoint.com/:w:/g/personal/atabor7_student_umgc_edu/IQBqLgOJkCH2TI2Zoz7p973WASfeTrcvr2I8naF3z8AHxvs?e=Bd2ogj) |
| Project Proposal | [Open in SharePoint](https://umuc365-my.sharepoint.com/:w:/g/personal/atabor7_student_umgc_edu/IQA0e50yYJ06RYo_y6m78DNxAWzCyQRVhGF4g59x_GOybRk?e=99dHSb) |

The Markdown files under `docs/` mirror these for in-repo review and diffing. **When the
two disagree, the SharePoint document is authoritative** — it is what gets submitted.
Anyone editing the Word document should update the matching Markdown file in the same
pull request so the repository does not drift from the submission.

---

## Current state

The repository currently holds **one application**: the responsive React + Vite web app
at the root. It began as an accessibility reference implementation (see
[Attribution](#attribution)) built around care recipients with short-term memory loss,
and the team is adapting it to the ADHD user group described above. Many of its core
patterns — single next action, always-visible status, universal undo, plain-language
dates — carry over directly, because they address overlapping executive-function needs.

The Flutter, React Native, and Electron applications arrive in Assignments 3–8. The
repository stays flat until then; the `apps/` split is planned and specified in the
[build plan](docs/build-plan.md#5-deferred-the-apps-monorepo-migration).

### Platform plan

| Platform | Technology | Target | Assignments |
| --- | --- | --- | --- |
| Web | React 18 + Vite + TypeScript | Responsive, installable PWA | 1, 10 |
| Mobile | Flutter | Android + iOS | 3, 4 |
| Mobile | React Native + Expo | Android + iOS | 5, 6 |
| Desktop | Electron | **Windows and macOS** | 7, 8, 9 |

**The desktop target is both Windows and macOS**, per the team's assigned
platform-coverage constraint. The team OS mix supports this directly — two members develop
on Windows and one on macOS — so both targets can be built and accessibility-tested
natively (NVDA on Windows, VoiceOver on macOS) without virtual machines. Assignment 1's
instructions ask for a single desktop OS, so this deviation is flagged for instructor
confirmation in the [proposal](docs/project-proposal.md#4-platform-deployment-plan).

**Linux is not in scope** and remains a possible future iteration.

---

## Getting started

### Prerequisites

- **Node.js 18+** and npm — verified working: Node `v22.14.0`, npm `11.19.0`
- A modern browser
- *(Optional)* An Anthropic API key for the landing-page assistant

The full toolchain audit, including what is **not** yet installed, is in
[docs/environment-setup.md](docs/environment-setup.md).

### Clone and run

```bash
git clone https://github.com/shaynemcp/careconnect-swen661-reference.git careconnect-adhd
```

```bash
cd careconnect-adhd && nvm use && npm install && cp .env.example .env && npm run dev:web
```

The dev server starts at **http://localhost:5173**. One install at the repo root
covers every workspace. Full detail in [docs/SETUP.md](docs/SETUP.md).

> The app runs entirely on mock `localStorage` data — **no backend keys are required**.
> If `ANTHROPIC_API_KEY` is absent, the landing-page assistant falls back to a scripted
> guided helper.

### Environment variables

Copy `.env.example` to `.env` and fill in only what you need:

| Variable | Required? | Notes |
| --- | --- | --- |
| `VITE_SUPABASE_URL` | No | Only for the assistant edge function |
| `VITE_SUPABASE_ANON_KEY` | No | Public anon key, protected by Row-Level Security |
| `ANTHROPIC_API_KEY` | No | **Server-side only.** Never prefix with `VITE_` — that would bundle it into the client and leak the key to the browser. |

`.env` is gitignored. Never commit real secrets.

### Available scripts

| Script | What it does |
| --- | --- |
| `npm run dev:web` | Vite dev server on port 5173 |
| `npm run dev:desktop` | Electron shell (build the web app first) |
| `npm run build` | Build every workspace |
| `npm run lint` | ESLint across workspaces |
| `npm run typecheck` | `tsc --noEmit` (strict) across workspaces |
| `npm test` | Tests across workspaces |
| `npm run check:contrast -w @careconnect/design-tokens` | Verify every color pair against WCAG 2.2 AA |

> **Note:** Jest and Playwright are **not yet configured**, so `npm test` is currently a
> no-op and the CI coverage gate is inactive. See [docs/TESTING.md](docs/TESTING.md).

---

## Project structure

npm workspaces monorepo. Full rationale in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

```
careconnect/
├── .github/
│   ├── workflows/               # CI, nightly E2E
│   ├── ISSUE_TEMPLATE/          # Bug, feature/task, accessibility issue
│   ├── PULL_REQUEST_TEMPLATE.md # Includes the mandatory accessibility checklist
│   ├── CODEOWNERS
│   └── dependabot.yml
├── apps/
│   ├── web/                     # React 18 + Vite + TS (strict) + Tailwind, PWA
│   ├── mobile/                  # ⚠️ placeholder — framework undecided (ADR 0001)
│   └── desktop/                 # Electron shell over the web build (ADR 0002)
├── packages/
│   ├── ui/                      # Shared accessible components
│   ├── design-tokens/           # Colors/spacing/type — contrast-verified
│   └── mock-data/               # Domain types + fictional fixtures
├── docs/
│   ├── ARCHITECTURE.md
│   ├── ACCESSIBILITY.md         # Instructor's requirements table, tracked per row
│   ├── SETUP.md
│   ├── TESTING.md
│   ├── DATA-MODEL.md
│   ├── decisions/               # ADRs — 0001 mobile framework, 0002 desktop OS
│   └── demos/                   # Dated log of weekly walkthrough videos
├── .nvmrc                       # Node 22.14.0
├── .editorconfig                # LF endings across macOS + Windows machines
├── .env.example
├── package.json                 # Workspace root
└── CONTRIBUTING.md
```

## Contributing

`main` is protected — all work arrives through pull requests.

1. Branch from `main` using the charter convention:
   **`<name>/<short-feature-description>`** — e.g. `shayne/patient-medications`
2. Commit **at least once per work session** — no single giant end-of-week commits
3. Open a PR into `main` and complete the template, **including the accessibility checklist**
4. Get at least one review from another team member; CI must be green
5. **Squash-merge** after approval

### Definition of Done

Work is complete only when it is **merged** via a reviewed PR, **tested**, **checked for
accessibility** (WCAG 2.2 AA), **documented**, and **demoed** to the team.

Full process detail is in the [team charter](docs/team-charter.md#4-git-workflow).

---

## Attribution

This project builds on the **CareConnect accessibility reference implementation** by
**[Alireza Minagar](https://github.com/aliminagar)** — AI/ML Software Engineer, Founder
& CTO of Perfect Strokes LLC, and Adjunct Professor at UMGC — used under the MIT License
with the original copyright notice retained in [`License`](License).

The original README, including the full screen-by-screen walkthrough, is preserved at
[docs/reference-app-readme.md](docs/reference-app-readme.md).

SWEN 661 team contributions are listed under [Team](#team) above.

---

## License

Distributed under the MIT License. See [`License`](License) for the full text.

```
Copyright (c) 2026 Alireza Minagar / Perfect Strokes LLC
```

---

## Acknowledgments

- University of Maryland Global Campus — SWEN 661 (User Interface Implementation)
- The WCAG 2.2 guidelines and the WAI-ARIA Authoring Practices
- Original scaffolding accelerated with Bolt.new; completed and hardened locally

---

## Disclaimer

CareConnect is an **educational prototype** built as a course artifact. It is not a
medical device, provides no medical, dosage, or clinical advice, and must not be used
for real patient care or to manage actual medications. It uses mock data only and is not
intended to store real protected health information (PHI). For any real health decision,
consult a licensed clinician.
