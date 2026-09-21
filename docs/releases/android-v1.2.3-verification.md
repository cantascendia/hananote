# Android 1.2.3+8 verification

Date: 2026-09-22. Working branch: `feat/r52-hoyo-redesign`.

## Candidate scope

Local Android maintenance release. Cloud v2 is not enabled in this build.
The existing release signing identity must be retained for in-place upgrades.
No medical calculations, production accounts, or user records are used for
acceptance testing.

The maintenance work covers startup recovery, immediate background masking,
PIN protection of private routes, warm-session-only biometrics, camera-only
photo capture, Android backup exclusion, reminder scheduling, and independent
password-encrypted records backups. First-run onboarding now saves profile
fields before recording completion and enters the local app when cloud is
unconfigured.

The records vault includes medications, schedules, dose logs, inventory,
blood reports/readings, journals, and measurements. It excludes photos,
profile, and app settings; this boundary is disclosed in all three languages.
Restore validates the entire payload and writes all supported records in one
SQLCipher transaction. Conflicting unique fields belonging to another record
ID cause rollback. Legacy JSON is accepted only as an explicitly selected
JSON file, never as a fallback for a failed vault.

## Verification status

Final application checks passed after production changes were frozen:

- `flutter analyze --no-pub --no-fatal-infos`: exit 0, zero errors/warnings;
  293 informational style findings remain.
- `dart format --output=none --set-exit-if-changed lib test`: exit 0,
  439 files checked, zero changes required. Unrelated nested worktrees and
  documentation snippets are outside this application formatting check.
- `flutter test --no-pub --concurrency=1`: 399 passed, zero failures.
  See `artifacts/android-v1-stability/test-verified.log`.
- Emulator-only encrypted/legacy/conflicting synthetic backup fixture
  generation: one additional test passed.

Signed-build and emulator evidence are recorded below. All runtime records
are synthetic and belong only to the task-created `HanaNote_Stability` AVD,
serial `emulator-5556`, Android API 36.1 x86_64.

Baseline: Flutter 3.38.4, Dart 3.10.3; 324 tests passed. Analyze had no errors
or warnings, with pre-existing informational style findings. The first release
build exposed Sentry 8.14.2's Kotlin language-version mismatch; the fix is
scoped to that plugin's compile task.

During final widget testing, the backup password dialog exposed a disposed
controller: returning its Future without awaiting it executed cleanup before
the dialog mounted. The dialog now awaits completion and scrolls its content;
the existing password-confirmation/export event regression passes. One legacy
button finder was updated for the specified records-backup wording. Mock
configuration was updated for the new auth preflight methods; business
assertions were retained.

## Android runtime findings repaired

The Android document picker disabled `.vault` files because the platform has
no registered MIME type for this extension. It now permits selection and
strictly validates `.vault` / `.json` in the app. Selected files are streamed
with both declared-size and actual-byte limits before decoding, so changing
the picker filter does not allow arbitrary-size memory allocations.

An upgrade with no saved profile exposed a hardcoded nickname and HRT start
date. Missing profile data now stays unknown: nullable date, empty nickname,
no fabricated day count, timeline milestone, or anniversary poster. Existing
saved dates retain their values. Entity, repository, timeline, and bounded
stream regressions cover these fixes.

Screenshot review also found the custom toolbar behind the Android status
bar. `HoyoAppBar` now consumes the top safe inset while retaining a 56 logical
pixel content height. Its widget regression checks both title position and
that the body receives the inset only once.

## Android acceptance evidence

Evidence files below are under `artifacts/android-v1-stability/`.

| Scenario | Observed result | Evidence |
| --- | --- | --- |
| Signed 1.2.2 to 1.2.3 upgrade | `adb install -r` succeeded; existing PIN unlocked and original synthetic catalog drug remained | `upgraded-medications.xml`, `rollback-medications.xml` |
| Unknown profile | Generic nickname, no fabricated HRT day count | `final-home.xml`, `final-profile.xml` |
| Native vault export | Password dialog completed; system share sheet contained `.vault`; cancelling returned unlocked to Profile | `export-share.xml`, `export-return.xml` |
| Native vault import | `.vault` selectable and streamed; two synthetic records restored into Android SQLCipher | `vault-password-final.xml`, `vault-import-result.xml` |
| Unique-field conflict | Import failed; attempted drug insert rolled back; original drug, restored drug and journal remained | `conflict-result.xml`, `rollback-medications.xml`, `rollback-timeline.xml` |
| Plain JSON disguised as vault | Import failed, active drug count stayed two; no legacy fallback | `fake-vault-rejected.xml` |
| Main navigation | Today, Record, Timeline, Data and Profile rendered | `final-home.xml`, `final-record.xml`, `rollback-timeline.xml`, `final-data.xml`, `final-profile.xml` |
| Background return | After observing Android launcher, resuming required PIN and hid prior page | `outside-app.xml`, `background-lock-verified.xml` |
| Cold process restart | PIN required; restored journal remained after unlock | `cold-start-lock.xml`, `cold-persisted-journal.xml` |
| Fresh app data | PIN setup, nickname, deferred date and optional medication completed into local Today | `clean-first-launch.xml`, `clean-onboarding-complete.xml` |
| Notification denied | System denial did not prevent fresh setup or ordinary use | `clean-first-launch.xml`, `clean-welcome.xml` |
| Crash buffer | No Android crash-buffer entries during this acceptance session | `android-crash-buffer.log` |
| Final toolbar build | Final signed APK installed in-place; existing PIN and synthetic nickname retained; title top moved from 22px to 85px below the 63px status inset | `released-pin.xml`, `released-home.xml`, `released-home.png` |

Fresh-start testing cleared **only** the task-created AVD's synthetic app
data after the upgrade/restore evidence was captured. No physical device or
user-owned app data was changed. No backup was sent to another person.

Wrong-password, tampered envelope, malicious KDF parameters, size limits,
auth partial-write cleanup and notification replacement failures are covered
by automated tests; these are not claimed as physical-device checks.

The final APK differs from the full runtime acceptance build only by the
toolbar safe-inset fix. It received the full 399-test suite, analysis, signed
build/alignment checks and Android reinstall/unlock/screenshot verification.
The final Android crash buffer is also empty
(`android-crash-buffer-final.log`). The task-owned emulator was shut down
after verification.

## Build-host observations

One Android build failed because the Windows JVM could not commit native
memory. One subsequent isolated widget-test compilation exited with a native
access violation; the same test passed on a serial retry (3/3). These are host
tool failures, not successful Android runtime checks. Builds, full tests, and
the emulator are therefore run serially.

The installed Emulator 36.4.9 also crashed its Windows host process with
`bad color buffer handle` / access violation during preliminary PIN tests.
Acceptance was restarted with an isolated official Emulator 37.1.11 and host
graphics with Vulkan disabled; the SDK's installed emulator was not replaced.
The archive SHA-1 was verified as
`54fa750822ff462d57e04fc8e98e60f08df2bb61`.
See the [official emulator release notes](https://developer.android.com/studio/releases/emulator).

A recursive deletion of the project's merged native build cache was rejected
by automatic approval review (`blocked by policy`); it was not executed or
retried. Regenerable build/cache files were compressed instead. Existing app
data and user work were retained.

## Final signed artifacts

Build: Flutter 3.38.4, `1.2.3+8`, release/minified, target SDK 36,
minimum SDK 24. Final `assembleRelease` completed in 79.0 seconds.

| APK | Android versionCode | SHA-256 |
| --- | --- | --- |
| `HanaNote-1.2.3-arm64.apk` | 2008 | `BE371180DA515DACD2C86F48C0B6F42824BC2273B7DA96D29B49997A3098F4BA` |
| `HanaNote-1.2.3-x86_64.apk` | 4008 | `AF70C11071568C00C923F8C33656BD94F89306E97B79826EA26AF8A1C28BE53A` |

Split-ABI versionCode offsets account for 2008/4008 while pubspec build
number is 8. Both APKs pass `apksigner verify` and `zipalign -c -P 16`.
All 14 packaged ELF libraries have LOAD alignment at least 16KB.
Signing certificate SHA-256 matches the original installed 1.2.2 release:
`f5499151034ac7b53ad7a5594d7bffd47023fc86464f71264048f89908cdf20d`.
`verify-apks.ps1`, signature/manifest/zipalign logs,
`apk-sha256.json` and `native-library-alignment.json` are kept beside the APKs.

## Remaining validation boundaries

Emulator acceptance does not establish physical-device reliability, OEM
battery-management behavior, biometric hardware behavior, or store approval.
No production backend or Play Store publication is part of this maintenance
task. Custom/interval reminders use a rolling 90-day schedule refreshed when
the Today workflow synchronizes reminders.

The unused PIN-change API remains unavailable until a separate migration can
rotate both database and photo encryption safely. Cold starts require the PIN.

## Review evidence

Work was distributed across Sol (backup/profile/UI implementation), Terra
(notification verification) and GPT-5.5 (independent auth/backup review), with
root integration and Android runtime acceptance. Reviewed P0/P1 findings
were resolved in source and validated at the applicable test/runtime layer.

- `android-v1-auth-review.md`
- `android-v1-backup-security-review.md`
- `android-v1-backup-stability.md`
- `android-v1-notification-stability.md`
- `android-v1-startup-stability.md`
