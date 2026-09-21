# Android v1 Backup Security Review

Date: 2026-09-22
Reviewer: GPT-5.5 independent review
Scope: backup vault, import/export validation, backup restore repository, SQL transaction boundary, and the auth startup blocker found during adjacent release review.

I reviewed the current source against `AGENTS.md`, `docs/ai-cto/CONSTITUTION.md`, and the backup/auth contract appended to `docs/ai-cto/SPEC.md`. I did not run build, test, format, generation, or Android runtime commands during this final pass.

## Current Release-Blocker Status

No open backup P0/P1 remains from this source review. The original backup findings below are marked resolved in the current source.

The adjacent auth/startup P0 is implemented in the current source and should receive the requested independent review before release. The fix is intentionally limited to `KeyManager`, `AuthLocalDataSource`, `AuthRepository`, `SetupApp`, the auth repository/use-case tests, and the SPEC contract.

Android real SQLCipher/device validation remains pending; this document is a source-level security and data-integrity review.

## Resolved Backup Findings

### P0 - Restore can delete existing records whose IDs do not match the backup

Status: Resolved in current source.

Current review:
- `SqlBackupRestoreRepository.restore()` no longer pre-deletes `journal_entries` by `date` or `drug_inventory` by `drug_id` before import.
- ID-matching rows are updated in place; inserts use abort semantics so unique-key conflicts fail the transaction instead of replacing unrelated records.
- Reading inserts now use abort semantics, so duplicate reading IDs cannot overwrite readings attached to another report.
- Blood-test restore still removes readings only for a matching imported `report_id`, which is inside the disclosed matching-ID replacement boundary.

Minimum expected regression coverage:
- Existing journal or inventory rows with different IDs but the same unique field must remain intact after a rejected restore.
- Duplicate reading IDs across reports must reject and roll back the whole restore.

### P0 - Vault import can silently fall back to plaintext JSON

Status: Resolved in current source.

Current review:
- `ImportData.call()` now requires an explicit `ImportBackupFormat`.
- The `.vault` path enforces `looksLikeVault()` and decrypts through `BackupVaultService`; malformed or non-vault bytes do not fall back to UTF-8 JSON.
- Legacy plaintext JSON is reachable only through the explicit legacy format path.

Minimum expected regression coverage:
- Plain JSON sent through the vault path must fail.
- A vault envelope with tampered magic/version/AAD must fail authentication or validation and must not restore data.

### P1 - Self-export size limit is inconsistent with import size limit

Status: Resolved in current source.

Current review:
- `BackupVaultService` uses separate plaintext and vault-envelope ceilings: plaintext export is capped below the final vault-envelope limit.
- Vault input is bounded before decode/decrypt/KDF work.

Minimum expected regression coverage:
- The largest accepted export should round-trip through decrypt/import.
- Oversized vault input should reject before expensive processing.

### P1 - Numeric/boolean validation still allows corrupt values

Status: Resolved in current source.

Current review:
- Import validation now treats boolean integer columns such as `is_active`, `dirty`, and `is_deleted` as exactly `0` or `1`.
- Hormone reading values must be finite and non-negative.
- Row schemas are whitelisted per collection before restore.

Minimum expected regression coverage:
- Boolean values such as `2` or `999` must reject.
- Negative or non-finite reading values must reject before SQL writes.

## Additional Backup Re-review Notes

The latest tombstone/export change addresses a data-integrity release blocker:
- `exportRecords()` filters soft-deleted drugs, schedules, and medication logs.
- It also filters child records that reference hidden drugs/schedules and filters inventory for hidden drugs.
- This prevents self-export from preserving soft-delete tombstones as active restored records.

The restore path still relies on the SQL transaction boundary for rollback. Source review shows writes are routed through the transaction callback; conflict aborts should roll back all prior inserts/updates in that import operation.

## Checks That Look Correct

- Backup encryption derives a key from the supplied backup password, separate from the app PIN/session key.
- The backup salt is generated independently per export and stored only as KDF envelope metadata.
- Native `hashlib` Argon2 construction records and validates `argon2id` parameters; AAD binds magic, version, KDF parameters, and salt.
- AES-GCM authentication covers the envelope parameters needed to prevent parameter substitution without detection.
- KDF memory, iteration, parallelism, salt length, cipher algorithm, plaintext size, and vault size are bounded before high-cost or sensitive work.
- Import validates the full decrypted structured payload before calling restore.
- Raw SQL injection risk is low in this path because table names are fixed, columns are whitelisted, and values go through sqflite argument binding.
- Structured coverage includes the seven supported SQL collections, including medication logs, drug inventory, and nested blood-test readings.

## Auth/Startup P0 Status

### P0 - Missing or false auth settings can lead to irreversible key overwrite

Status: Implemented in current source; independent review pending.

Original risk:
- Missing `auth_settings`, empty settings JSON, or `isSetup:false` could send startup into first-run setup even when credential material or an existing encrypted database remained.
- A new setup could overwrite the verifier and orphan the old SQLCipher database.
- A partial `KeyManager.initializeKey()` failure could leave salt/hash fragments that permanently block clean setup retry.

Current implementation notes:
- The SPEC now states that missing/unreadable auth settings are first-run only when no credential material and no encrypted DB file exist.
- `KeyManager.hasStoredCredentialMaterial()` detects hash/salt and legacy key material without exposing key bytes.
- `AuthLocalDataSource.hasSettings()` lets the repository distinguish missing settings from stored settings.
- `AuthRepository.getSettings()` fails closed when settings are missing or `isSetup:false` while protected data exists.
- `AuthRepository.setupPassword()` refuses to overwrite existing credential material or an existing DB, adds a simple in-process setup guard, and marks ownership only after the clean preflight passes.
- `discardIncompleteSetup()` is non-destructive without that ownership marker; it does not act as a public wipe.
- If `initializeKey()` fails after partially writing verifier material, the repository clears only the newly owned incomplete setup state.
- `SetupApp` still cleans owned incomplete setup when saving settings or opening the new DB fails, and does not call the public cleanup for `setupPassword()` failures.
- `openDatabase()` success clears the ownership marker.
- Repository error handling preserves explicit business machine codes, while DB open failures use `database_open_failed` and unexpected auth exceptions use `auth_operation_failed` instead of exposing raw SQLCipher/plugin details.

Minimum expected regression coverage:
- Key/salt present but `auth_settings` missing must fail closed and must not call `initializeKey()`.
- Key/salt present with stored `isSetup:false` settings must fail closed.
- Existing DB file with missing settings must fail closed, not show first-run setup.
- Direct `setupPassword()` must refuse to overwrite existing protected data.
- A partial `initializeKey()` failure in a clean first-run setup must clean newly created verifier fragments so setup can be retried.
- Public `discardIncompleteSetup()` without current setup ownership must not close/delete DB or delete keys.
- Correct PIN unlock for existing protected data should still work through the lock path.

## Not Verified

- I did not run `flutter analyze`, `flutter test`, `dart format`, build, generated-code checks, or Android runtime validation in this final pass.
- Earlier in this review thread, the auth-targeted tests were run once before the latest no-more-Flutter coordination update; after that update I did not start additional Flutter commands.
- Android SQLCipher behavior and file-picker routing still need the main release validation pass.

## Final File Picker Stream Re-review - 2026-09-22

Scope: `lib/core/backup/read_backup_stream.dart` and the backup import picker path in `lib/features/settings/presentation/pages/profile_page.dart` only. I did not modify production code and did not run Flutter commands; root owns the unified codegen/build/test pass.

Status: Cleared at source-review level. No new P0/P1 found in this bounded pass.

Reviewed behavior:
- The picker now uses `FileType.any` to avoid Android disabling `.vault` files, but keeps `withData: false` and `withReadStream: true` so arbitrary selected files are not eagerly loaded into memory.
- The selected filename is lowercased and extension-checked before stream reading; only `.vault` and `.json` continue.
- `readBackupStream()` rejects negative or over-limit declared metadata before reading, then enforces the same `BackupVaultService.maxVaultBytes` limit while accumulating stream chunks. A false metadata size cannot bypass the actual cumulative bound.
- Missing streams, picker failures, extension failures, and stream/size failures are mapped to the localized import failure UI rather than raw exception text.
- The strict dispatch remains intact: `.vault` prompts for a backup password and reaches `ImportBackupFormat.vault`; `.json` reaches only the explicit legacy JSON path.

Remaining validation owned by root:
- Root should run the unified generated-code/build/test sequence and Android picker smoke test. This review did not execute Flutter, code generation, or Android runtime validation.
