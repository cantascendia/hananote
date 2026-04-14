import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hananote/core/update/apk_downloader.dart';
import 'package:http/http.dart' as http;

/// Information about an available app update.
class AppUpdateInfo {
  /// Creates an [AppUpdateInfo].
  const AppUpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.htmlUrl,
    this.fileSize,
  });

  /// The latest version tag (e.g. "1.1.0").
  final String latestVersion;

  /// Direct download URL of the APK asset.
  final String? downloadUrl;

  /// Markdown release notes body.
  final String releaseNotes;

  /// GitHub release page URL (fallback).
  final String htmlUrl;

  /// APK file size in bytes (if available).
  final int? fileSize;

  /// Human-readable file size string.
  String get fileSizeText {
    if (fileSize == null) return '';
    final mb = fileSize! / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}

/// Progress details for download tracking.
class DownloadProgress {
  /// Creates a [DownloadProgress].
  const DownloadProgress({
    required this.received,
    required this.total,
    required this.speed,
  });

  /// Bytes received so far.
  final int received;

  /// Total bytes expected (-1 if unknown).
  final int total;

  /// Current download speed in bytes/second.
  final double speed;

  /// Progress fraction (0.0 to 1.0).
  double get fraction => total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;

  /// Percentage (0 to 100).
  int get percent => (fraction * 100).round();

  /// Received in MB.
  String get receivedMB => (received / (1024 * 1024)).toStringAsFixed(1);

  /// Total in MB.
  String get totalMB =>
      total > 0 ? (total / (1024 * 1024)).toStringAsFixed(1) : '?';

  /// Speed in human-readable format.
  String get speedText {
    if (speed <= 0) return '';
    if (speed > 1024 * 1024) {
      return '${(speed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
    return '${(speed / 1024).toStringAsFixed(0)} KB/s';
  }

  /// Estimated remaining time.
  String get remainingText {
    if (speed <= 0 || total <= 0) return '';
    final remaining = (total - received) / speed;
    if (remaining < 60) return '${remaining.round()}s';
    return '${(remaining / 60).round()}min';
  }
}

/// Checks for app updates and downloads APK files.
///
/// Tries Cloudflare R2 CDN first (fast in China), then falls back to
/// GitHub Releases API.
class UpdateService {
  /// GitHub owner/repo.
  static const _owner = 'cantascendia';
  static const _repo = 'hananote';

  /// Cloudflare R2 CDN base URL.
  static const _cdnBase = 'https://cdn.hrtyaku.com/hananote';

  /// Checks whether a newer version is available.
  ///
  /// Returns [AppUpdateInfo] if an update exists, `null` otherwise.
  static Future<AppUpdateInfo?> checkForUpdate(String currentVersion) async {
    // Try CDN first (fast in China).
    final cdnResult = await _checkCdn(currentVersion);
    if (cdnResult != null) return cdnResult;
    // Fallback to GitHub.
    return _checkGitHub(currentVersion);
  }

  static Future<AppUpdateInfo?> _checkCdn(String currentVersion) async {
    try {
      final response = await http
          .get(Uri.parse('$_cdnBase/version.json'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final version = (data['version'] as String? ?? '').replaceAll('v', '');
      if (!_isNewer(version, currentVersion)) return null;

      return AppUpdateInfo(
        latestVersion: version,
        downloadUrl: data['url'] as String?,
        releaseNotes: data['notes'] as String? ?? '',
        htmlUrl: data['github_url'] as String? ?? '',
        fileSize: data['size'] as int?,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<AppUpdateInfo?> _checkGitHub(String currentVersion) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://api.github.com/repos/$_owner/$_repo/releases/latest',
            ),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = (data['tag_name'] as String? ?? '').replaceAll('v', '');
      if (!_isNewer(tagName, currentVersion)) return null;

      String? apkUrl;
      int? apkSize;
      final assets = data['assets'] as List<dynamic>? ?? [];
      for (final dynamic asset in assets) {
        final assetMap = asset as Map<String, dynamic>;
        final name = assetMap['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          apkUrl = assetMap['browser_download_url'] as String?;
          apkSize = assetMap['size'] as int?;
          break;
        }
      }

      return AppUpdateInfo(
        latestVersion: tagName,
        downloadUrl: apkUrl,
        releaseNotes: data['body'] as String? ?? '',
        htmlUrl: data['html_url'] as String? ?? '',
        fileSize: apkSize,
      );
    } catch (e) {
      debugPrint('[UpdateService] GitHub check failed: $e');
      return null;
    }
  }

  /// Downloads APK to cache directory, reporting detailed progress.
  ///
  /// Returns the local file path of the downloaded APK.
  /// Throws [UnsupportedError] on web platforms.
  static Future<String> downloadApk(
    String url,
    void Function(DownloadProgress progress) onProgress,
  ) {
    return downloadApkFile(url, onProgress);
  }

  /// Returns `true` if [remote] is a newer semver than [local].
  static bool _isNewer(String remote, String local) {
    final remoteParts = remote.split('.').map(int.tryParse).toList();
    final localParts = local.split('.').map(int.tryParse).toList();

    for (var i = 0; i < 3; i++) {
      final r = i < remoteParts.length ? (remoteParts[i] ?? 0) : 0;
      final l = i < localParts.length ? (localParts[i] ?? 0) : 0;
      if (r > l) return true;
      if (r < l) return false;
    }
    return false;
  }
}
