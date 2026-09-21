# Android v1.x stability specification

Date: 2026-09-22. Base: `feat/r52-hoyo-redesign`, `fa019ce`.

## 1. Scope and release contract

Deliver an installable, signed Android 1.2.3+8 maintenance candidate from the
current checkout. Preserve existing user edits and existing encrypted data.
No backend deployment, store publication, or changes to medical algorithms.
Unconfigured cloud services must not prevent local use. The v1 candidate is
built without Supabase or telemetry credentials; cloud v2 is not an accepted
or advertised part of this release.

## 2. Privacy and startup

- Android must opt out of platform backup and device transfer of app data.
- Background protection must cover content immediately, including before
  settings load. Errors and release logs must not contain health data or keys.
- Startup failures must terminate initialization with a localized fallback,
  not a hanging Future or blank splash. Optional notification initialization
  failure must not block local use.
- PIN/biometric protection must cover every private route, including resume.
- Release builds must never silently fall back to debug signing.

## 3. Reminders

Notifications use generic localized text without drug names or doses. The next
trigger represents the user's device-local time. Lack of exact-alarm permission
must fall back to a supported inexact alarm without failing synchronization.
See `docs/releases/android-v1-notification-stability.md` for implementation.

## 4. Data integrity

No edits may weaken encryption, discard failed imports, mark incomplete writes
successful, or expose records while locked. Repairs to protected paths follow
this specification and receive an independent second-model review. Test
assertions remain authoritative; new regression cases are `test:` additions.
Any demonstrably stale test requires a documented `bug-fix:` or `spec-change:`.

## 5. Acceptance

- Dependency resolution and generated code are consistent with Flutter 3.38.4.
- Analyze, full tests, and format checks run with recorded results; pre-existing
  style debt and unrelated nested worktrees are identified separately.
- Signed release APK builds, signature/version are inspected, and SHA-256 is
  provided. No signing secrets or machine-local config enter deliverables.
- Android emulator exercises clean setup, cold start, PIN unlock/relock,
  core navigation, record persistence, and denied notification permission.
- Privacy/reminder/data regression tests pass and an independent model reviews
  the final security-sensitive changes.
- Report explicitly separates emulator acceptance from physical-device,
  store-policy, and production-backend validation.

## 6. Plan and tasks

1. Record baseline analyze/test/build and independently audit platform/data.
2. Fix demonstrated release blockers, adding focused regressions.
3. Re-run affected checks, full tests, analyze, format, generated-code check.
4. Build and inspect signed release; run Android smoke tests with synthetic data.
5. Review final diffs and publish local APK plus verification report.

Owners: root (startup/platform/build/runtime), Sol (reminders), GPT-5.5
(independent data review). Additional bounded work assigned only as needed.

## 7. Local authentication maintenance contract

- A backgrounded unlocked session locks immediately when app lock is enabled;
  every non-root route redirects to the PIN gate while unauthenticated.
- Biometrics unlock only a warm session with a cached decryption key. Cold
  process starts require the PIN; biometric success alone cannot recover a key.
- The unused ChangePin API fails closed without changing credentials in v1.2.3.
  It is not exposed in the UI. Safely rotating both database and encrypted-photo
  keys requires a separate migration; changing the hash alone destroys access.
- Missing or unreadable `auth_settings` is first-run only when no credential
  material and no encrypted database file exist. If key material, a legacy key,
  or a database file remains, startup must fail closed to the lock gate and
  setup must not overwrite the existing credential verifier. A failed clean
  first-run setup may remove only the material it just created so the user can
  retry without orphaning pre-existing records.
- A fresh install defaults to manual update checks, preserving offline mode.
- Android uses the fragment activity and AppCompat theme required by local_auth.
- New tests verify gate/resume behavior and that unavailable PIN rotation leaves
  the old credential untouched. No production health data is used in tests.

## 8. Backup vault maintenance contract

- New Android v1 exports must produce `.vault` files only. The file contains a
  small JSON envelope (`magic`, `version`, KDF params, cipher metadata) and an
  AES-256-GCM ciphertext payload. Plain JSON export is not allowed for new
  backups.
- Backup encryption uses an independent password, not the app PIN, not
  `KeyManager`, and not any device-bound app lock key. The UI must require the
  user to enter and confirm this password and warn that it cannot be recovered.
- The backup key is derived with Argon2id using a fresh random salt for every
  export. Import must reject unsupported versions, unsupported algorithms, and
  KDF parameters above the client-defined safety ceiling before deriving a key.
- Import accepts current `.vault` files and may accept legacy JSON explicitly
  for compatibility. `.vault` import must decrypt and parse the full payload
  before writing any records.
- Import must never report success after a format, password, authentication-tag,
  or validation failure. New regression tests cover round-trip, wrong password,
  tamper detection, and malicious KDF parameter rejection.
- Credential read failures must fail closed to the lock gate, never offer setup
  that could overwrite an existing key. Native PIN derivation runs off the UI
  isolate with unchanged cryptographic parameters; no key/hash diagnostics log.
- Explicit camera, document-picker and share-sheet round trips preserve their
  initiating session through `NativeInteraction.run`; background masking stays
  active. An ordinary background transition outside that bounded Future locks.

### Backup restore transaction and schema contract (Android v1.x stability addendum)

This addendum narrows the v1 backup contract so import failures cannot leave partially restored health records.

Inputs:
- New exports are HanaNote `.vault` files. A vault envelope must be JSON with `magic = "HNVLT"`, `version = 1`, `kdf.name = "argon2id"`, bounded KDF parameters, a fresh per-file salt, `cipher.algorithm = "AES-256-GCM"`, and ciphertext payload bytes. The backup password is independent from the app PIN and KeyManager key.
- Decrypted backup JSON must contain `format = "hananote.records.v1"`, `version = "1.0"`, a parseable `exportDate`, and only supported record collections. Legacy `.json` import is accepted only through the explicit JSON import path and must still satisfy version/date/collection validation; `{}` and arbitrary JSON objects are invalid.
- Supported v1 record collections are `drugs`, `schedules`, `medicationLogs`, `drugInventory`, `bloodTests`, `journals`, and `measurements`. `profile` in legacy backups is ignored during restore because profile storage is outside the SQL transaction boundary. `photos` are not part of v1 `.vault` record backup; photo binary/media backup requires a separate media package contract.

Restore transaction:
- Import first decrypts and parses the whole payload, validates every record shape, enum, required date, and intra-backup medication reference before opening a write transaction.
- All supported SQL records are written inside one SQLCipher transaction. Any insert/replace failure rolls back the entire restore. The app must never report import success after a mid-restore failure, and the database must not retain earlier writes from that failed restore.
- Matching IDs may be replaced as already disclosed by the import confirmation. Medication restore writes dirty sync metadata for medication tables so an opt-in sync queue can later observe local changes.
- Secure-storage profile/settings are not modified by this import path. If a future release restores them, it must add a two-phase or compensating rollback contract before implementation.

Export coverage:
- v1 `.vault` export includes structured medication catalog, schedules, dose logs, inventory, blood tests with readings, journals, and measurements.
- v1 `.vault` export excludes photo files and photo table rows to avoid restoring dangling encrypted file paths without the corresponding encrypted media blobs. UI copy must describe this as a records backup rather than a full device/media backup.

### No fabricated health history (Android v1.2.3 stability addendum)

- An absent profile has no known display name and no known HRT start date. Default profile construction must not insert a sample person, a historical date, or today's date as if supplied by the user.
- `UserProfile.hrtStartDate` may be null. When null, derived HRT day count is zero for storage compatibility, but the UI must show an unset state or hide the count; it must not present “HRT day 0/1” as an actual treatment history.
- Timeline milestones and commemorative HRT posters require a real HRT start date. Unknown dates must not produce milestones, a fabricated poster start date, or a shareable HRT day claim.
- Previously stored non-null dates remain readable and their day counts remain derived from those dates. Profile setup and editing may supply a real date later without changing existing records.
