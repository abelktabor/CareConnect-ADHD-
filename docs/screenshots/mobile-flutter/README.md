# Flutter mobile screenshots — Assignment 4

Captured on **2026-09-07** from the release APK
(`flutter build apk --release`) running on the team's **Pixel 8 AVD**
(Android 16, API 36, 1080×2400 @ 420 dpi), with the app's **demo clock**
switched on so every screen reproduces the Week 3 Figma state
(*Tuesday, August 25 · 2:14 PM*).

| File | Figma frame | What it shows |
| --- | --- | --- |
| `coverage.png` | — | LCOV report: **99.6 % line coverage**, 2 702 of 2 714 lines (the assignment's floor is 60 %) |
| `01-signin.png` | 01 | Sign In / Role Selection — passkey first, email second, "I am a…" |
| `02-today.png` | 02 | Today — orientation bar, one dominant Metformin card, "Later today" |
| `03-medications.png` | 03 | Medications — four statuses, each icon **and** text |
| `04-appointments.png` | 04 | Appointments — full-word dates and "who is taking me" |
| `05-caregiver-access.png` | 05 | My Caregiver Access — the closed list of what Renee can see |
| `06-caregiver-dashboard.png` | 06 | Caregiver Dashboard — violet, "Needs attention today", overdue alert |
| `07-medication-form-step1.png` | 07 | Add Medication — Step 1 of 3 with the fractional progress bar |
| `08-appointment-form-step1.png` | 08 | Edit Appointment — step indicator, autosave |
| `09-notifications.png` | 09 | Notifications — digest, always-on overdue alerts, lead-time chips |
| `10-activity-timeline.png` | 10 | Activity Timeline — grouped by day, newest first, filter |
| `11-settings.png` | 11 | Settings — three plain rows |
| `12-undo-snackbar.png` | — | "Metformin logged at 2:14 PM · Undo" — undo over confirm, in action |
| `13-caregiver-manage.png` | — | Caregiver Manage tab — medications and appointments |
| `14-landscape-caregiver.png` | Landscape L-06 | **Wide two-column layout** (914 dp) with the same reading order |
| `16-dark-mode.png` | — | Dark mode with the contrast-verified dark token set |

## A note on the tablet frames

The wide (≥ 600 dp) layout is evidenced two ways:

1. **`14-landscape-caregiver.png`** — a real device capture at 914 dp wide,
   showing the two-column layout from the Figma "Landscape" page.
2. **Widget tests** — `test/widget/*_test.dart` pump every screen at
   `kTablet` (834 × 1194) and assert the columns sit side by side.

A portrait *tablet* capture is deliberately **not** included: forcing a
tablet geometry on this phone AVD (`adb shell wm size` / `wm density`) makes
the emulator's `screencap` composite a stale navigation-bar layer over the
app bar. The `uiautomator` accessibility dump confirms the app itself renders
correctly in that configuration — one app bar, one navigation bar
(`Dashboard/Manage/Activity/Settings`, "Tab 1 of 4"…) — so the ghost row is a
capture artifact, not a defect. Rather than ship a misleading image, the
layout is shown in landscape and asserted in tests.
