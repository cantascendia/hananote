# Android v1 Backup Stability

Date: 2026-09-22

## Contract

Android v1 exports use the HanaNote `.vault` format. A vault is a JSON envelope
containing format metadata, bounded Argon2id parameters, a fresh salt, and an
AES-256-GCM ciphertext. The health payload is never written as the exported
backup file.

The backup password is separate from the app PIN and from local unlock keys.
Users must remember it; HanaNote cannot recover a vault without that password.

## Import Behavior

Import uses an explicit format selected by the UI. The `.vault` path requires
an encrypted envelope and backup password; it never falls back to JSON.
Legacy JSON requires a separate compatibility path and validated metadata.

The importer decrypts and parses the full payload before writing records. Wrong
passwords, modified vault bytes, unsupported algorithms, unsupported versions,
or unsafe KDF parameters fail the import and must not be reported as success.

## Test Focus

Regression coverage for this release includes:

- `.vault` round-trip decrypts to the original JSON payload.
- Wrong backup password fails.
- Ciphertext or envelope tampering fails.
- KDF parameters above the client safety ceiling fail before expensive work.
- Malformed import payloads fail before repository writes begin.

## Records scope and transaction boundary

The v1 records payload has `format = hananote.records.v1`, `version = 1.0`,
`exportDate`, and seven collections: drugs, schedules, medication logs,
inventory, blood tests with readings, journals, and measurements. Photo table
rows and encrypted media files are excluded. Profile and settings are not
restored because secure storage is outside the SQL transaction boundary.
Medication soft-delete tombstones and children referencing deleted medication
are excluded from the export snapshot so import cannot revive deleted records.

The importer validates the whole decrypted payload, required fields, dates,
enums, record IDs, and medication references before writing. Supported SQL
records are then written through one `SecureDatabase.runInTransaction` call.
An insert/update exception propagates out of the transaction callback so
SQLCipher rolls back all writes; import returns failure. Matching IDs update
in place, and medication rows become dirty for the opt-in sync queue. A journal
date or inventory drug conflict with a different local ID rejects the entire
transaction and preserves the existing local row.

Legacy JSON lacking the current payload header or complete supported
collections is rejected. This avoids silently dropping dose logs, inventory,
or an unknown schedule frequency. Passwords and decrypted data are never
logged. Argon2id key derivation runs in a worker isolate with the same KDF
parameters as the v1 vault envelope; file and password sizes are bounded.

The lightweight repository rollback test uses a recording transaction fake.
A final Android device check must verify real SQLCipher rollback and a fresh
export/import round trip before release acceptance.

