# Setup

## Prerequisites

| Tool | Version | Check |
| --- | --- | --- |
| Node.js | 22.14.0 (see `.nvmrc`) | `node --version` |
| npm | 10+ | `npm --version` |
| Git | any recent | `git --version` |

```bash
nvm use     # picks up .nvmrc
```

Per-machine toolchain status, including current gaps, is tracked in
[environment-setup.md](environment-setup.md).

## Install

One install at the repo root covers every workspace.

```bash
git clone https://github.com/shaynemcp/careconnect-swen661-reference.git && cd careconnect-swen661-reference && npm install
```

```bash
cp .env.example .env
```

No keys are required. The app runs entirely on mock local data; `.env` holds a
placeholder for a future AI-assistant key that nothing reads today.

## Run

```bash
npm run dev:web
```

Serves at **http://localhost:5173**.

```bash
npm run build:web && npm run dev:desktop
```

The Electron shell loads the dev server in development and `apps/web/dist` when
packaged, so the web build must exist first.

**Mobile** is not runnable yet — the framework is an open decision
([ADR 0001](decisions/0001-mobile-framework.md)). `apps/mobile` is a placeholder
and is excluded from the npm workspaces.

## Scripts

Run from the repo root.

| Script | What it does |
| --- | --- |
| `npm run dev:web` | Vite dev server |
| `npm run dev:desktop` | Electron shell |
| `npm run build` | Build every workspace that defines a build |
| `npm run lint` | ESLint across workspaces |
| `npm run typecheck` | `tsc --noEmit` across workspaces |
| `npm test` | Tests across workspaces |
| `npm run check:contrast -w @careconnect/design-tokens` | Verify every documented color pair against WCAG 2.2 AA |

## Editor

Open the repo root, not an individual app — workspace resolution depends on it.
`.vscode/extensions.json` recommends ESLint, Prettier, Tailwind IntelliSense,
EditorConfig, axe Linter, and Playwright. `.editorconfig` keeps line endings LF
across the team's mixed macOS and Windows machines.

## Windows notes

Two of three team members develop on Windows.

- Line endings are LF, enforced by `.editorconfig`. If Git rewrites them, set
  `git config core.autocrlf input`.
- NVDA is the screen reader of record on Windows — install from
  https://www.nvaccess.org/download/
