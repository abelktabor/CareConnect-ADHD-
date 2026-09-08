# @careconnect/desktop

Electron shell for CareConnect. Loads the Vite dev server in development and the
built `apps/web/dist` bundle in production.

```bash
npm run build:web        # produce apps/web/dist first
npm run dev:desktop      # from the repo root
```

## Open decision

The desktop OS target is **unresolved** — Assignment 1 asks for one OS, the Team
Charter lists both Windows and macOS. Electron builds both from this one
codebase, so the shell is written to be OS-neutral and nothing here blocks on the
decision. See [ADR 0002](../../docs/decisions/0002-desktop-os-target.md).

Do not add macOS-only or Windows-only APIs without isolating them behind an
adapter and noting it in the ADR.
