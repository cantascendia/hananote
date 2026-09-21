# Android v1 Auth Safety Review

Date: 2026-09-22  
Reviewer: independent source review (backup_finish agent)  
Scope: `AuthLocalDataSource`, `AuthRepositoryImpl`, `SetupApp`, `KeyManager`, and their targeted regression tests.

## Verdict

No remaining P0 source finding in the reviewed first-run credential path. The fixes fail closed when auth settings are missing or corrupted and protect an existing database or verifier from setup overwrite. This is a source review only; Android secure storage and SQLCipher behavior still require the release device check.

## Evidence

- `AuthRepositoryImpl.getSettings()` checks whether settings exist and whether any credential material or database exists. Missing settings with protected data, or `isSetup=false` with protected data, returns an auth failure. Secure-storage read and JSON parse exceptions also return failure through `_guard`; they do not become setup defaults.
- `SetupApp` checks protected data before setup, and `AuthRepositoryImpl.setupPassword()` repeats the check immediately before key creation. `_setupInProgress` rejects overlapping setup calls. Existing key material or a database prevents `initializeKey()`.
- `KeyManager.initializeKey()` derives the PIN key off the UI isolate with the original native Argon2id parameters. It writes salt and verifier separately. If a later write fails, `AuthRepositoryImpl.setupPassword()` catches the failure and calls its owned cleanup path, covering a partial salt/verifier write. The setup error is returned; no setup success is emitted.
- Cleanup is gated by `_ownsIncompleteSetup`, which is set only after the protected-data precheck passes. Calls without ownership fail before closing or deleting the database or credentials. Saving settings or opening the new database unsuccessfully invokes cleanup; successful open clears ownership.
- Targeted tests cover missing settings, `isSetup=false` with protected material, setup refusal with existing verifier, non-destructive unowned cleanup, partial-write cleanup, and the setup use-case failure paths. These test results were not rerun as part of this review.

## Remaining acceptance boundary

Ownership exists only in process memory. A process crash or power loss between writing the salt and completing first-run setup can leave partial credential material. On restart the app fails closed rather than offering setup; recovery needs a deliberate user-visible path after data-preserving diagnosis. Likewise, a cleanup failure returns the original setup error and may leave protected artifacts, which are blocked by the next startup check. Neither case permits overwriting an existing encrypted database through the reviewed setup flow.

The reviewed tests use mocks for protected storage and database state. Before Android v1 release, verify on a device that secure-storage read failures fail closed, a first-run setup failure cannot erase an existing SQLCipher database, and a completed PIN unlocks the newly created database after app restart.
