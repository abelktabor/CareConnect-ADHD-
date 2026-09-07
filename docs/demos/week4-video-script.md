# Week 4 demo video — run of show (10–15 minutes)

Assignment 4 asks for a 10–15 minute video showing: (1) building and testing
from the repository, (2) the software meeting the required features, (3) the
testing objectives and reports, and (4) a documentation review. This script
hits all four in order. Record at 1080p with the emulator and a terminal side
by side.

## 0. Setup before recording (not on camera)

- `flutter emulators --launch careconnect_pixel8` and wait for the home screen
- `cd apps/mobile-flutter && flutter pub get`
- In the app: Settings → App Settings → *Demo clock* → Turn on (screens match the Figma)
- Open `coverage/html/index.html` and `docs/TEST-PLAN.md` in browser tabs
- Terminal font ≥ 16 pt

## 1. Build and test from the repository (≈ 3 min)

1. Show `git remote -v` and `git log --oneline -5` on the `dev` branch.
2. `flutter analyze` → "No issues found".
3. `flutter test --coverage` → watch the counter; call out the totals.
4. `genhtml coverage/lcov.info -o coverage/html` → refresh the coverage tab; read the line percentage aloud.
5. `flutter build apk --release` → show the APK path (pre-built is fine if slow; say so).
6. `flutter run -d emulator-5554` → app launches.

## 2. Features against the Week 3 design (≈ 6 min)

Keep the Figma PDF open on the second half of the screen and switch frame by frame.

| Step | Show | Say |
| --- | --- | --- |
| Sign in | Passkey button, email path with a bad address, role cards | No password, plain-language error, one question |
| Today | Orientation bar, Metformin card, **Mark as Taken → Undo** | One dominant action; 10-second undo instead of a dialog |
| Later today → Lisinopril | Tap the row → detail | Nothing to remember; the row already says the time |
| Medications | Four statuses, icon + text | Status never colour alone |
| Add Medication | Step 1 error → fill → Saving/Saved → Step 2 add time → Step 3 → Save | Step x of 3 with fractional bar, autosave, restore after leaving |
| Appointments | Rows with full-word dates and "Renee is taking me" | No "8/25" anywhere |
| Settings → Notifications | Digest toggle, always-on overdue alerts, lead-time chips | User controls reminders |
| My Caregiver Access | Closed list, sharing pause | Exactly what is shared |
| Rotate the emulator | Today in landscape | Two-column layout, same reading order |
| Sign out → Caregiver | Dashboard in violet, overdue alert → Log now → Activity | Role colour cue; needs-attention only; history opt-in |
| Deep link | `adb shell am start -d careconnect://app/patient/medications/med-metformin` | Navigator 2.0 deep linking with a back stack |
| Accessibility | TalkBack on: swipe through Today | Names, roles, live-region announcements |

## 3. Testing objectives and reports (≈ 3 min)

- Open `docs/TEST-PLAN.md`: strategy table, the case catalogue IDs, manual pass.
- Show one unit test (undo window), one widget test (form steps), the
  accessibility guideline test, and the integration test file.
- Coverage HTML: overall percentage, then drill into `state/` and
  `features/` to show hot spots.
- CI: `.github/workflows/flutter.yml` — analyze, test, 60 % gate, APK artifact.

## 4. Documentation review (≈ 2 min)

- Root `README.md`: platform table, Assignment 4 section, contributions, AI usage.
- `apps/mobile-flutter/README.md`: architecture, run, test, known issues.
- `docs/decisions/0003-repository-home.md`: the repo move and `dev` branch.
- Close on the PR into `dev` and the Definition of Done checklist.
