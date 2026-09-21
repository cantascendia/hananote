# Android v1 startup stability

The v1.2.3+8 maintenance candidate starts Flutter binding initialization and
`runApp` inside one guarded zone. A startup exception completes initialization
and replaces the UI with the localized fallback page, so the app does not
remain on a blank splash screen.

Cloud configuration is optional for this release. When Supabase defines are
absent, startup does not read the persisted region override or initialize a
Supabase client. When the Sentry DSN is absent, startup does not read the
crash-reporting preference.

Notification setup remains optional. Its failure is recorded only as the
abstract operation `startup_notification_initialization_failed` in debug mode;
it cannot include exception text, health records, medication names, doses, or
keys.

The task-switcher privacy layer becomes fully opaque in its first lifecycle
frame. It also removes underlying content from the accessibility semantics tree
while it is visible.
