/// Observability-related constants for HanaNote.
///
/// The DSN is intentionally left empty so crash reporting is disabled by
/// default.  Production DSN is injected via the build environment — see
/// release.yml for the `--dart-define=SENTRY_DSN=...` pattern.
abstract final class ObservabilityConstants {
  /// Sentry DSN.  Empty string means Sentry is disabled regardless of the
  /// user's crashReportingEnabled preference.
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
}
