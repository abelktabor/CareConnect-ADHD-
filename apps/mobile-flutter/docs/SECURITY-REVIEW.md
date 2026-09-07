# SSDF Code Review Report — CareConnect Mobile (Flutter)

| | |
| --- | --- |
| **Reviewed** | `apps/mobile-flutter` (`careconnect_mobile` 0.4.0+4) |
| **Language / Context** | Dart 3.12 / Flutter 3.47 — offline-first Android and iOS app, no backend |
| **Framework** | NIST SP 800-218, Secure Software Development Framework (SSDF) v1.1 |
| **Review Depth** | Standard (full source, build config, manifests, dependency set) |
| **Reviewer** | Shayne McPherson (Technical Lead), SWEN 661 Team E-Echo |
| **Date** | 2026-09-07 |
| **Controls Assessed** | PW.1.2, PW.4.1, PW.4.4, PW.5.1, PW.6.1, PW.7.1, PW.8.1, PW.8.2, PW.9.1, PS.1.1, PS.2.1, PS.3.1, RV.1.1 |

---

## Executive summary

The application has a small, well-contained attack surface: it makes no
network calls, embeds no credentials, has no server, and uses only four
direct third-party packages. The classic injection categories (SQL, command,
template, XPath) do not arise because the app performs no interpolation into
any interpreter, and all persistence is a single JSON document in app-private
storage.

The review found **one Medium** issue, now fixed — untrusted-shaped data from
local storage was deserialised without a guard, so a corrupt or tampered
preferences entry would throw inside a provider's `build()` and leave the app
permanently unable to start. Two **Low** hardening gaps in the Android
manifest (cloud backup of health-domain data, and unset transport defaults)
were also fixed. Three items are **accepted risks** appropriate to a course
prototype and are documented rather than silently carried: debug-key signing,
unencrypted local storage, and the necessarily exported deep-link activity.

Entry points reviewed: user form input, `careconnect://` deep links, and
locally persisted state. Sensitive assets in scope: none real — a test
asserts the sample data is fictional.

---

## Findings

### [MEDIUM] — Unvalidated deserialisation of local state could permanently break the app (Control: PW.5.1)

**Location:** `lib/state/session_provider.dart`, `settings_provider.dart`,
`notification_settings_provider.dart`, `care_data_provider.dart`,
`draft_providers.dart` — each `Notifier.build()`

**Issue:** `LocalStore.readJson` guarded only against *invalid JSON*. The
model constructors (`CareData.fromJson`, `Session.fromJson`, …) then cast
fields directly (`json['id'] as String`, `DateTime.parse(...)`). A stored
document that is syntactically valid JSON but structurally wrong — a
truncated write, a device-migration artefact, or an edited preferences file
on a rooted device — therefore threw a `TypeError` or `FormatException`
*inside a Riverpod provider's `build()`*. Because those providers are
constructed during the first frame, the exception is not recoverable from
inside the app: every subsequent launch re-reads the same bad value and
fails again. The result is a persistent denial of service against the user's
own device, and it is reachable by anyone who can write that file.

**SSDF requirement:** PW.5.1 requires source code to follow secure coding
practices, which includes validating input at trust boundaries and *failing
securely* — an error condition must not deny service or leave the software
in an unusable state.

**Resolution (applied):** added `LocalStore.readAs`, which rebuilds a
document through its `fromJson` inside a guard, discards any malformed
document, and returns a known-good fallback. Every notifier now reads
through it. A regression test seeds all six storage keys with malformed
values and asserts the app still starts with valid defaults.

```dart
T readAs<T>(String key, T Function(Map<String, dynamic>) fromJson,
    {required T Function() orElse}) {
  final json = readJson(key);
  if (json == null) return orElse();
  try {
    return fromJson(json);
  } on Object {
    unawaited(remove(key)); // discard, never partially trust
    return orElse();
  }
}
```

---

### [LOW] — Local care data was eligible for Android cloud backup (Control: PW.9.1, PS.1.1)

**Location:** `android/app/src/main/AndroidManifest.xml`

**Issue:** `android:allowBackup` was unset, so it defaulted to `true`. Android
Auto Backup would copy the app's `SharedPreferences` — medication names,
schedules, adherence history and appointment locations — to the user's Google
account, and Device-to-Device transfer would copy it to a new handset. For an
app whose *domain* is health information, silently exporting that state off
the device is the wrong default even while the data is fictional.

**SSDF requirement:** PW.9.1 requires software to be configured with secure
settings by default; PS.1.1 requires protecting data from unauthorised access.

**Resolution (applied):** set `allowBackup=false`, `fullBackupContent=false`,
and added `res/xml/data_extraction_rules.xml` excluding the `sharedpref`,
`database` and `file` domains from both cloud backup and device transfer.

---

### [LOW] — Transport security posture was implicit (Control: PW.9.1)

**Location:** `android/app/src/main/AndroidManifest.xml`

**Issue:** `usesCleartextTraffic` was unset. The app makes no network calls
today, so nothing was exposed, but the assignment roadmap adds reminders and
a possible sync layer. Leaving the default unstated means the first
network-capable feature silently inherits whatever the platform default is
at that API level.

**SSDF requirement:** PW.9.1 — secure settings by default, set explicitly
rather than inherited.

**Resolution (applied):** `android:usesCleartextTraffic="false"`, so any
future HTTP call fails loudly in development instead of shipping in the clear.

---

### [LOW — ACCEPTED] — Release APK is signed with the debug keystore (Control: PS.2.1, PS.3.1)

**Location:** `android/app/build.gradle.kts`, `buildTypes.release`

**Issue:** `signingConfig = signingConfigs.getByName("debug")`. The debug key
is a well-known, shared credential, so the release artifact carries no
meaningful integrity or authorship guarantee: anyone can produce a build that
appears identically signed, and the APK can never be updated on Play by a
real key.

**SSDF requirement:** PS.2.1 requires a mechanism for verifying software
release integrity; PS.3.1 requires protecting each release.

**Decision:** **accepted for this course deliverable.** The APK is
side-loaded for grading and demonstration only and is never distributed
through a store. A real deployment needs a keystore held outside the
repository, injected via `key.properties` (already gitignored) or CI secrets.
Documented in the app README's Known issues so it cannot be mistaken for
release-ready.

---

### [LOW — ACCEPTED] — Local state is stored unencrypted (Control: PW.5.1, PS.1.1)

**Location:** `lib/data/local_store.dart`

**Issue:** `SharedPreferences` writes plaintext XML inside the app's private
data directory. It is protected by the OS sandbox and by full-disk
encryption, but it is readable on a rooted or jailbroken device and by anyone
with a physical forensic image.

**Decision:** **accepted while the data is fictional.** A build handling real
patient data would need `flutter_secure_storage` (Keystore / Keychain-backed)
or SQLCipher, plus a documented key-management approach. Recorded as a
prerequisite in the README's future work rather than deferred silently.

---

### [INFORMATIONAL] — Deep-link activity is exported by design (Control: PW.1.2, PW.5.1)

**Location:** `AndroidManifest.xml` (`android:exported="true"`, scheme
`careconnect://app`), `lib/router/app_router.dart`

**Issue:** any installed app can launch an arbitrary in-app route. This is
inherent to supporting deep links, which the assignment requires.

**Assessment — residual risk is low, and the trust boundary is enforced:**

1. The `redirect` guard in `lib/router/redirects.dart` runs on every
   navigation. A signed-out caller is sent to sign-in; a care recipient
   cannot be pushed onto caregiver routes and vice versa. The guard is a pure
   function with dedicated unit tests.
2. The only attacker-controlled data is the `:id` path parameter, which is
   used solely as a key for an in-memory lookup
   (`medicationById` / `appointmentById`). A miss renders a calm "no longer
   in your list" screen rather than throwing. It never reaches a query,
   a file path, or an interpreter.
3. No deep link performs a state change; every mutation still requires an
   explicit tap.

No change required. Re-verify this if a future route ever performs an action
directly from a link.

---

## Positive observations

- **No secrets anywhere.** A full-source scan for password / key / token /
  credential patterns returns only unrelated prose in comments. The app has
  no auth provider and makes no network requests, so there is nothing to leak.
- **Input validation is user-facing and complete.** Every form field is
  validated with a message that says what is wrong *and* how to fix it
  ("Enter the dose, like 25 mg"), satisfying both the security control and
  WCAG 2.2 SC 3.3.3.
- **No error leaks anything.** There is no stack-trace surface: failures are
  handled locally and rendered as plain-language states.
- **Strict static analysis is enforced, not advisory.** `analysis_options.yaml`
  enables strict casts, strict inference and strict raw types, and CI runs
  `flutter analyze --fatal-infos`. Current state: zero issues.
- **Dependencies are minimal and locked.** Four direct packages, all actively
  maintained; `pubspec.lock` is committed so builds are reproducible.
- **A guardrail test protects the data boundary.** `mock_data_test.dart`
  asserts the seed uses the reserved `example.test` domain and 555-01xx
  numbers, so real PHI cannot be introduced without a failing test.
- **Security-relevant negative testing exists**, which is unusual at this
  stage: malformed storage, corrupt JSON, out-of-range times, expired undo
  windows and unknown ids all have explicit cases.

---

## SSDF control coverage summary

| Control | Status | Notes |
| --- | --- | --- |
| PW.1.2 | ✅ Pass | Trust boundaries identified; deep-link input constrained and guarded |
| PW.4.1 | ✅ Pass | Four maintained dependencies; `pubspec.lock` committed |
| PW.4.4 | ✅ Pass | `dart pub outdated --show-all` (advisories) runs in CI |
| PW.5.1 | ✅ Pass *(after fix)* | Fail-secure deserialisation added; no injection surface; no secrets |
| PW.6.1 | ✅ Pass | Strict analyzer settings enforced in CI |
| PW.7.1 | ✅ Pass | Reviewed via this document and the PR review gate |
| PW.8.1 | ✅ Pass | 225 automated tests |
| PW.8.2 | ✅ Pass | Negative and boundary cases covered explicitly |
| PW.9.1 | ✅ Pass *(after fix)* | Backup disabled, extraction rules set, cleartext disabled |
| PS.1.1 | ⚠️ Accepted risk | Local storage unencrypted — fictional data only |
| PS.2.1 | ⚠️ Accepted risk | Release signed with the debug keystore; no SBOM yet |
| PS.3.1 | ✅ Pass | Releases tagged by version + build number (`0.4.0+4`) |
| RV.1.1 | ℹ️ N/A | No vulnerability-handling code in scope this term |

---

## Recommended next steps

1. **Before any real user data:** move local persistence to
   `flutter_secure_storage` or SQLCipher and document key management.
2. **Before any store distribution:** generate a release keystore, keep it
   out of the repository, and inject it through CI secrets.
3. **Assignment 5 onward:** add an SBOM step to CI (`dart pub deps --json`
   converted to CycloneDX) to close PS.2.1 properly.
4. **When the first network call lands:** add a network security config and
   certificate pinning, and re-run this review focusing on PW.1.2.
5. **Re-run this review** whenever a deep-linked route gains the ability to
   change state without an explicit user action.
