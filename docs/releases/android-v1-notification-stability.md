# Android v1.x notification stability

## Scope and acceptance

- A scheduled medication notification must not disclose a drug name, dose, or unit by default. The default title is `HanaNote` and the default body is a generic reminder.
- For a requested local wall-clock time, the first scheduled instant must match that time on the device, even when the timezone package's `local` location remains UTC.
- Android devices without exact alarm access must still receive an inexact reminder; scheduling must not fail solely because exact access is unavailable.
- Existing callers of `scheduleMedicationReminder` remain source compatible. Any explicit body supplied by a caller must itself satisfy the notification privacy rule.

## Implementation plan

1. Remove medication detail parameters from the call site; retain them as optional compatibility parameters at the service boundary for now.
2. Compute the next local `DateTime` and convert that absolute instant to `TZDateTime` for the notification plugin.
3. Query Android's exact alarm capability and use `inexactAllowWhileIdle` when unavailable. Keep exact scheduling when capability is confirmed.
4. Add tests for generic content, local-time conversion, and denied exact access. Correct the existing assertion that expected sensitive notification content; it conflicts with `.agents/rules/privacy-security.md`.

## Verification boundary

Targeted Dart tests establish service arguments and branching. Device testing is still required for recurring reminders across daylight-saving changes, reboot delivery, and Android alarm permission states.

## Source-review status (2026-09-22)

- Confirmed: reminder text is generic at the current synchronization call
  site; saved language selects localized generic text; the Android timezone
  channel returns `TimeZone.getDefault().id`; exact-alarm denial selects the
  inexact mode; and the planner handles daily, weekly, finite/end-dated,
  every-N-days, and custom interval frequencies.
- Resolved P1: `NotificationSettingsPage` already observed successful global
  and per-drug preference writes. It now awaits the resulting
  `SyncMedicationReminders` call and shows its failure through a snackbar.
  Toggle changes therefore start synchronization immediately and do not
  silently discard a platform scheduling failure.
- Resolved P1: replacement stages all candidate reminders under unused
  high-range ids before cancelling any older pending ids. A schedule failure
  cleans only successfully staged candidates and preserves the old set. A
  singleton queue serializes concurrent replacements. Stale-id cancellation
  attempts every id before returning the first error, so global disable is
  best-effort rather than stopping after one failed cancel.

Targeted unit-test additions cover staged-before-delete ordering, schedule
failure preservation, all-id cancellation attempts, and overlapping
replacement serialization. Final Flutter execution remains subject to the
root verification pass because the local Windows compiler previously exited
with an `ACCESS_VIOLATION`; this source-review status is not device
verification.

## Frequency rules

- Daily schedules repeat at each configured local time, beginning no earlier than `startDate`.
- Weekly schedules repeat on `dayOfWeek` at each configured local time, beginning no earlier than `startDate`.
- Every-N-days schedules use calendar-day distance from `startDate`, not elapsed 24-hour blocks. Because the plugin has no N-day repeating option, queue one-shot occurrences for a rolling 90-day horizon and refresh when the Today page loads.
- Custom schedules queue one-shot occurrences only when `intervalDays` is positive. A free-form description alone does not define a computable interval, so it creates no automatic reminder.
- An `endDate` bounds queued reminders. For daily or weekly schedules with an end date, use the same finite one-shot horizon rather than an unbounded repeating alarm.
- The Android plugin recomputes repeated alarms in the named timezone passed by `TZDateTime`. A native timezone ID lookup is required for recurring daily and weekly alarms to remain at the intended wall-clock time across daylight-saving changes.
- Synchronization first reads settings and every active schedule, then builds an in-memory plan with unique sequential IDs. Repository failures leave existing alarms untouched. Global notifications disabled produces an empty plan and cancels old alarms.
