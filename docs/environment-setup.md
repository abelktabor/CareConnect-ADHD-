# Development Environment Setup

**Course:** SWEN 661 9040 — User Interface Implementation (2268)
**Assignment:** 1, Part 1 (40% of assignment grade)
**Machine audited:** macOS 26.3.1 (`darwin-arm64`, Apple Silicon)
**Audit date:** August 18, 2026
**Audited by:** Shayne McPherson (Team E-Echo)

> This document records the **actual, verified** state of the development machine.
> Tools that are not yet installed are listed as gaps with the exact remediation
> command, rather than being reported as complete. Each teammate maintains their own
> copy of §2 for their machine.

---

## 1. Summary

| Status | Count | Meaning |
| --- | --- | --- |
| ✅ Verified | 8 | Installed and confirmed by running the version command |
| ⚠️ Partial | 2 | Installed but misconfigured or incomplete |
| ❌ Missing | 6 | Not installed; blocks a later assignment |

**Bottom line:** the **web** toolchain is fully working today and the CareConnect web
application builds and runs. The **mobile** toolchain is half-installed — Flutter and
Dart work, but neither the Android SDK nor a complete Xcode is present, so no emulator
or simulator can run yet. These gaps block Assignment 3 and must close during Weeks 1–2.

---

## 2. Verified tool status

### 2.1 Node.js and package managers ✅

| Tool | Required | Found | Status |
| --- | --- | --- | --- |
| Node.js | LTS (18+) | `v22.14.0` | ✅ |
| npm | any | `11.19.0` | ✅ |
| Yarn | optional | not installed | ➖ Optional, not needed |

```bash
node --version && npm --version
```

### 2.2 Git and GitHub ✅

| Tool | Found | Status |
| --- | --- | --- |
| Git | `2.39.5 (Apple Git-154)` | ✅ |
| GitHub account | `shaynemcp` | ✅ |
| Test repository | `careconnect-swen661-reference` — cloned, built, and run | ✅ |

```bash
git --version && git config --get user.name && git config --get user.email
```

### 2.3 React + Vite ✅

| Item | Found | Status |
| --- | --- | --- |
| Vite | `5.4.8` | ✅ |
| React | `18.3.1` | ✅ |
| TypeScript | `5.5.3` (strict) | ✅ |
| Dev server | Started, ready in 226ms, served at `http://localhost:5173` | ✅ |

Verified end to end: the CareConnect application was cloned, dependencies installed,
dev server started, and the landing page rendered in the browser with **zero console
errors**.

```bash
cd ~/UMGC/Fall2026/careconnect-adhd && npm install && npm run dev
```

📸 `docs/screenshots/env-05-react-vite.png` — React app running in the browser

### 2.4 Flutter and Dart ⚠️

| Tool | Found | Status |
| --- | --- | --- |
| Flutter | `3.41.0` | ⚠️ Installed, non-standard channel |
| Dart | `3.11.0 (stable)` | ✅ |

`flutter doctor` reports Flutter is on an unknown channel (installed via Homebrew at
`/opt/homebrew/share/flutter`, channel `[user-branch]`, upstream `unknown source`).
This works for local development but diverges from the documented install and will make
version pinning across three machines unreliable.

**Remediation — reinstall from the official distribution:**

```bash
brew uninstall --cask flutter 2>/dev/null; brew uninstall flutter 2>/dev/null
```

Then install per https://docs.flutter.dev/get-started/install/macos and re-run
`flutter doctor`.

📸 `docs/screenshots/env-01-flutter-doctor.png` — `flutter doctor` output
📸 `docs/screenshots/env-02-flutter-hello-world.png` — Flutter app on an emulator/simulator

### 2.5 VS Code ✅ / extensions ⚠️

| Item | Found | Status |
| --- | --- | --- |
| VS Code | `1.133.0` | ✅ |
| Dart extension (`dart-code.dart-code`) | installed | ✅ |
| Flutter extension (`dart-code.flutter`) | installed | ✅ |
| ESLint (`dbaeumer.vscode-eslint`) | **not installed** | ❌ |
| Prettier (`esbenp.prettier-vscode`) | **not installed** | ❌ |
| React Native Tools (`msjsdiag.vscode-react-native`) | **not installed** | ❌ |

> Note: `inferrinizzard.prettier-sql-vscode` is present, but that is a SQL formatter —
> it is **not** the Prettier extension the assignment requires.

**Remediation:**

```bash
code --install-extension dbaeumer.vscode-eslint --install-extension esbenp.prettier-vscode --install-extension msjsdiag.vscode-react-native
```

### 2.6 Homebrew ✅

`Homebrew 6.0.17` — used for the toolchain installs below.

### 2.7 Chrome / web target ✅

`flutter doctor` reports `[✓] Chrome - develop for the web` and `[✓] Connected device
(2 available)`.

---

## 3. Gaps blocking later assignments

These are **not yet installed**. Each row lists what it blocks and how to close it.

### 3.1 Xcode ❌ — blocks iOS (Assignments 3–6)

Only the Command Line Tools are present; `xcodebuild` is unavailable and
`xcrun simctl` lists **zero** iPhone simulators.

```
xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer
directory '/Library/Developer/CommandLineTools' is a command line tools instance
```

**Remediation** — install Xcode from the App Store (~15GB, allow 1–2 hours), then:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer && sudo xcodebuild -runFirstLaunch
```

### 3.2 Android Studio and Android SDK ❌ — blocks Android (Assignments 3–6)

`flutter doctor` reports `[✗] Android toolchain — Unable to locate Android SDK`.
`adb` is not on the PATH and `/Applications/Android Studio.app` does not exist.

**Remediation:**

```bash
brew install --cask android-studio
```

Then launch Android Studio, complete the setup wizard to install the SDK, create an
emulator (AVD), and re-run `flutter doctor` until the Android row is green.

### 3.3 React Native + Expo CLI ❌ — blocks Assignment 5

No Expo CLI is available locally. Modern Expo is used through `npx`, so no global
install is strictly required, but the Hello World app must still be created and run.

**Remediation:**

```bash
npx create-expo-app@latest hello-rn && cd hello-rn && npx expo start
```

📸 `docs/screenshots/env-03-react-native-hello-world.png`

### 3.4 Electron ❌ — blocks Assignments 7–9

Not yet scaffolded.

**Remediation:**

```bash
npx create-electron-app@latest hello-electron && cd hello-electron && npm start
```

📸 `docs/screenshots/env-04-electron-hello-world.png`

### 3.5 lcov ❌ — blocks Flutter coverage reporting (Assignment 4)

Required by Assignment 1, Part 1, item 10.

```bash
brew install lcov
```

### 3.6 Accessibility tooling ⚠️ — needed from Assignment 6 onward

| Tool | Platform | Status |
| --- | --- | --- |
| VoiceOver | macOS / iOS | ✅ Built in — enable with `Cmd+F5` |
| WAVE browser extension | Browser | ❓ Install and verify |
| axe DevTools extension | Browser | ❓ Install and verify |
| TalkBack | Android | ⏸ Blocked until Android Studio + emulator exist |
| NVDA | Windows | ⏸ **Required** — Abel and Quinton develop on Windows and the desktop target includes Windows. Install from https://www.nvaccess.org/download/ |

Install WAVE from https://wave.webaim.org/extension/ and axe DevTools from
https://www.deque.com/axe/devtools/.

**On NVDA.** The desktop target is **both Windows and macOS**, so both NVDA (Windows)
and VoiceOver (macOS) are screen readers of record for Assignment 9. The team OS mix
covers this natively: Abel (Windows 10) and Quinton (Windows) own NVDA testing, Shayne
(macOS) owns VoiceOver. **Linux is not in scope** and remains a possible future
iteration, at which point Orca would be added.

**This document audits Shayne's macOS machine only.** Abel and Quinton each maintain
their own copy of §2 for their Windows machines — the Windows toolchain has different
gaps (no Xcode or iOS simulator at all, so iOS builds depend on the macOS machine).

### 3.7 Figma education account ⏸

Applied for at https://www.figma.com/education/apply using the `@umgc.edu` address.
Verification takes 1–3 business days.

| Field | Value |
| --- | --- |
| Applied on | *(date)* |
| Status | ☐ Pending ☐ Approved |

---

## 4. Remediation script

Everything installable from the command line, in one place. Xcode must still be
installed from the App Store separately.

```bash
brew install lcov && brew install --cask android-studio && code --install-extension dbaeumer.vscode-eslint --install-extension esbenp.prettier-vscode --install-extension msjsdiag.vscode-react-native
```

---

## 5. Screenshot checklist

Assignment 1 requires screenshot evidence of each Hello World application running.
Save each as `docs/screenshots/env-NN-*.png` and annotate it so the grader can see what
is being shown.

| # | Screenshot | File | Status |
| --- | --- | --- | --- |
| 1 | `flutter doctor` output, all green | `env-01-flutter-doctor.png` | ⏸ Blocked by §3.1, §3.2 |
| 2 | Flutter Hello World on emulator/simulator | `env-02-flutter-hello-world.png` | ⏸ Blocked by §3.1, §3.2 |
| 3 | React Native Hello World on emulator/simulator | `env-03-react-native-hello-world.png` | ⏸ Blocked by §3.3 |
| 4 | Electron Hello World on desktop | `env-04-electron-hello-world.png` | ⏸ Blocked by §3.4 |
| 5 | React + Vite app in browser | `env-05-react-vite.png` | ✅ Ready to capture — app runs |
| 6 | `node --version` / `npm --version` | `env-06-node-npm.png` | ✅ Ready to capture |
| 7 | VS Code with required extensions | `env-07-vscode-extensions.png` | ⏸ Blocked by §2.5 |
| 8 | Git configured + test repository on GitHub | `env-08-git-github.png` | ✅ Ready to capture |
| 9 | Android emulator running | `env-09-android-emulator.png` | ⏸ Blocked by §3.2 |
| 10 | iOS simulator running | `env-10-ios-simulator.png` | ⏸ Blocked by §3.1 |
| 11 | Accessibility extensions installed | `env-11-a11y-extensions.png` | ⏸ Blocked by §3.6 |
| 12 | Figma education account approved | `env-12-figma-edu.png` | ⏸ Blocked by §3.7 |

---

## 6. Verification commands

Re-run this block after remediation to confirm the environment is complete.

```bash
node --version; npm --version; git --version; flutter --version; dart --version; code --version; lcov --version; adb version; xcodebuild -version; xcrun simctl list devices available | grep iPhone | head -3
```
