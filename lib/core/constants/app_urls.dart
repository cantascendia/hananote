class AppUrls {
  static const privacyPolicy = 'https://hananote.app/privacy';
  static const termsOfService = 'https://hananote.app/terms';

  /// Cloudflare R2 CDN base for APK distribution.
  static const cdnBase = 'https://cdn.hrtyaku.com/hananote';

  /// Version metadata JSON for update checks and download links.
  static const versionJsonUrl = '$cdnBase/version.json';

  /// Fallback: latest GitHub Release page.
  static const githubReleasesLatest =
      'https://github.com/cantascendia/hananote/releases/latest';
}

/// Application-level constants.
abstract final class AppConstants {
  /// Matches the `version` field in pubspec.yaml.
  static const appVersion = '1.2.2';
}
