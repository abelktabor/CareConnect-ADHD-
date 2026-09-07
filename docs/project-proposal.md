# Project Proposal — CareConnect

**Course:** SWEN 661 9040 — User Interface Implementation (2268)
**Assignment:** 1, Part 3
**Team:** Team E-Echo — Shayne McPherson, Abel Tabor, Quinton Coleman
**Status:** Pending instructor approval before Week 2

> **Canonical source:** the authoritative, team-completed version of this document is the
> Word file on UMGC SharePoint — **[Project Proposal (SharePoint)](https://umuc365-my.sharepoint.com/:w:/g/personal/atabor7_student_umgc_edu/IQA0e50yYJ06RYo_y6m78DNxAWzCyQRVhGF4g59x_GOybRk?e=99dHSb)**.
> Accessible to anyone signed in with a UMGC organization account.
> This Markdown copy is the in-repo mirror; when the two differ, the SharePoint
> document wins. Update this file whenever the Word document changes.

---

## 1. Project overview

**Application name:** CareConnect

**Description.** CareConnect is a cross-platform (mobile, web, and desktop)
care-coordination app built for patients with ADHD and the caregivers who support them. It
turns medications, appointments, and multi-step daily tasks into short, plain-language
steps with visible progress and time-aware reminders, so the patient doesn't have to rely
on memory or executive-function effort to stay on track, while caregivers get a clear,
low-noise view of what's been done and what needs their attention. Built to WCAG 2.2 Level
AA with an explicit ADHD-friendly, cognitive-load-reduction design lean.

**Target audience.** Patients with ADHD, and their caregivers (family members or other
support people who help manage medications, appointments, and daily tasks).

**Primary problem this app solves.** ADHD commonly involves difficulty with time
perception ("time blindness"), task initiation, working memory, and follow-through — which
shows up as missed medications, missed or late appointments, and half-finished multi-step
tasks. Caregivers, in turn, struggle to know what's actually been done versus forgotten
without constant check-ins. CareConnect reduces that load by breaking tasks into short
visible steps, handling the remembering, and giving caregivers visibility without requiring
the patient to self-report constantly.

---

## 2. Assigned constraints

**1. User group:** patients with ADHD, and their caregivers.

**2. Platform coverage:** web, mobile (Android and iOS), and desktop (Windows and macOS).

**3. Accessibility:** WCAG 2.2 Level AA, plus the team's ADHD-friendly /
cognitive-load-reduction design lean from the SWEN 661 kickoff meeting — simple uncluttered
screens, no unnecessary animation or time limits, tasks broken into short numbered steps
with visible progress, plain-language instructions, no reliance on remembering information
from a previous screen, save-and-resume, large labeled buttons, clear error messages, full
keyboard and screen-reader support, no color-only signaling, adequate contrast.

**4. Technical stack:** the course-wide toolchain — Flutter and React Native for mobile,
Electron for desktop, React + Vite for web.

---

## 3. Key features

> **Sync note.** This list mirrors the team's agreed feature backlog — **12 features**,
> within the 8–12 that Assignment 1 Part 3 requires. Acceptance criteria are included
> because the rubric's *Highly Proficient* band asks for "detailed feature descriptions
> with acceptance criteria." **Verify this section also exists in the SharePoint
> document**, which is the graded artifact.

Prioritized **Must-Have** (required for a passing product), **Should-Have** (planned;
first to be descoped under schedule pressure), and **Nice-to-Have** (built only if
ahead of schedule).

### Must-Have

**1. Today Home Screen**
A persistent orientation bar (who you are, the day and time, where you are in the app)
above a single prominent "Next thing to do" card.
*Acceptance:* exactly one primary action per screen; remaining items are visually
subordinate; when nothing is due, a calm confirmed-empty state appears rather than a
blank region; the orientation bar appears on every patient screen and is exposed as a
landmark.

**2. Medications Screen**
Pill images, plain-language dose descriptions, always-visible status, and a 10-second
undo on every action.
*Acceptance:* status (taken / due / overdue) and time taken are visible in the list
without opening a detail view; status is carried by text and icon, never color alone;
changes announce through an ARIA live region; every dose action offers a 10-second undo
that is keyboard reachable and announced.

**3. Appointments Screen**
Chronological appointments with full-word dates, location, and who is accompanying the
patient.
*Acceptance:* no bare numeric dates such as "8/25" anywhere; dates render as "Tuesday,
August 25"; ordering is strictly chronological; each entry states its location and who,
if anyone, is taking the patient.

**4. Persistent "Call My Caregiver" Action**
A help action in the same relative position on every screen.
*Acceptance:* reachable within one interaction from every patient screen; consistent
location across all screens, satisfying **SC 3.2.6 Consistent Help**; target at least
44×44px.

**5. Reminders**
Medication and appointment notifications with user control over frequency and snooze.
*Acceptance:* reminders can be disabled entirely; lead time configurable; snooze options
offered and configurable; a hard cap on repeats prevents nagging; no reminder forfeits
an action when it expires.

**6. Installable PWA with Offline Access**
*Acceptance:* passes installability checks; the current day's medications and
appointments render with the network disconnected; the UI states plainly when data was
last synced.

**7. Accessibility Engineered Into Every Screen**
WCAG 2.2 Level AA as a build requirement, not a later audit.
*Acceptance:* 4.5:1 minimum text contrast (3:1 for large text and UI components);
complete keyboard operability with no traps; focus visible against every background;
ARIA live regions for status changes; 44×44px targets, exceeding the 24×24px of
**SC 2.5.8**; 320px reflow with no horizontal scrolling; `prefers-reduced-motion`
honored; color never the sole carrier of meaning; zero critical/serious axe violations;
Lighthouse accessibility ≥ 95.

### Should-Have

**8. Caregiver Dashboard**
Adherence summary, an alerts region for missed or overdue items, and a recent-activity
timeline.
*Acceptance:* alerts announce through an ARIA alert region; distinguishes completed,
missed, and upcoming without requiring the patient to self-report; the patient can see
exactly what the caregiver can see.

**9. Manage Medications (Caregiver)**
*Acceptance:* every input has a programmatically associated visible label; errors
identify the field, state what is wrong, and state how to fix it; incomplete work saves
and resumes; deletion requires explicit confirmation; edits propagate to patient screens.

**10. Manage Appointments (Caregiver)**
*Acceptance:* identical form, validation, save-and-resume, and delete-confirmation
behavior as feature 9 — consistency between the two screens is itself a requirement.

**11. Role Chooser with Low-Cognitive-Load Sign-In**
A post-sign-in choice between Care Recipient and Caregiver, persisted for later sessions.
*Acceptance:* the role choice persists and is not asked again; sign-in imposes no
cognitive function test such as a memory puzzle, satisfying **SC 3.3.8 Accessible
Authentication**; no already-provided information is requested twice in the same
process, satisfying **SC 3.3.7 Redundant Entry**.

### Nice-to-Have

**12. Shared Accessible Component Library and Design-Token System**
A single component library and token set backing the web, mobile, and desktop builds.
*Acceptance:* colors defined once as tokens with recorded contrast ratios, verified
automatically (`npm run check:contrast`); components ship keyboard- and
screen-reader-ready so accessibility work is done once rather than per platform;
behavior and styling stay consistent across all three platforms.

---

## 4. Platform deployment plan

| Platform | Technology | Target | Course phase |
| --- | --- | --- | --- |
| **Mobile** | Flutter | Android and iOS | Assignments 3–4 |
| **Mobile** | React Native | Android and iOS | Assignments 5–6 |
| **Desktop** | Electron | **Windows and macOS** | Assignments 7–9 |
| **Web** | React + Vite | Responsive web application | Assignment 10 |

**Desktop OS note.** Assignment 1's instructions ask teams to choose **one** desktop OS
(Windows, macOS, *or* Linux). This team's assigned platform-coverage constraint specifies
**both Windows and macOS**, so the proposal targets both, and the team accepts the larger
build and QA surface that follows (recorded as a risk in §6). The team's OS mix supports
this directly: two members develop on Windows and one on macOS, so both targets can be
built and accessibility-tested natively. **Confirm this deviation with the instructor when
the proposal is approved** — if a single OS is required, drop to macOS or Windows and move
the other to a future iteration.

**Linux** is not in scope and remains a possible future iteration.

---

## 5. Success criteria

**How success is defined.** A working build that implements every Must-Have feature across
all three platforms with WCAG 2.2 AA conformance verified via axe, WAVE, and Lighthouse
(accessibility score 95+), passes manual keyboard-only and screen-reader
(NVDA / VoiceOver / TalkBack) testing, and is validated with mock user sessions that include
at least one participant simulating the ADHD patient persona. Automated test coverage of
60–75%. Instructor approves the proposal by end of Week 1 with no major rework requested at
the Week 2 refinement checkpoint.

**Metrics and user feedback.**

| Type | Measure |
| --- | --- |
| Automated | Jest / React Testing Library coverage percentage (target 60–75%) |
| Automated | Lighthouse accessibility score (target 95+) |
| Automated | axe DevTools violation count (target zero) |
| Manual | Full keyboard-only walkthrough on every screen |
| Manual | NVDA / VoiceOver / TalkBack screen-reader pass on every screen |
| Manual | Usability feedback from mock user sessions role-playing the ADHD patient and caregiver personas |

---

## 6. Initial risks

**Challenges.**

| # | Risk | Mitigation |
| --- | --- | --- |
| R1 | **Dual desktop OS target (Windows + macOS)** roughly doubles the desktop build and QA surface compared to a single-OS team within the same timeline. | Team OS mix covers both natively (two Windows, one macOS). Isolate platform-specific code behind a thin adapter. Confirm the dual target with the instructor at approval. |
| R2 | **Simultaneous ramp-up on Flutter, React Native, and Electron** risks environment-setup delays. | Close the toolchain gaps in Weeks 1–2 rather than at the assignment that needs them — see [environment-setup.md](environment-setup.md). Freeze the design before Assignment 3 so the second mobile build is a port, not a redesign. |
| R3 | **Designing around an ADHD user group risks oversimplifying real needs** if not grounded in real input. | Base decisions on established guidance (WCAG 2.2 AA and the team's ADHD-friendly design lean) and validate directly with mock user sessions using a persona that reflects real ADHD experience, not assumptions. |

---

## 7. Instructor approval

| Field | Value |
| --- | --- |
| Submitted | *(date)* |
| Instructor decision | ☐ Approved ☐ Approved with changes ☐ Revise and resubmit |
| Dual desktop OS target (Windows + macOS) confirmed? | ☐ Yes ☐ No — single OS required |
| Notes | |
