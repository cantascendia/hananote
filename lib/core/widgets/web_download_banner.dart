import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/constants/app_urls.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/widgets/web_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// A smart banner that prompts web users to download the Android app.
///
/// Only renders when [kIsWeb] is true and the user has not dismissed it.
class WebDownloadBanner extends StatefulWidget {
  /// Creates a [WebDownloadBanner].
  const WebDownloadBanner({super.key});

  @override
  State<WebDownloadBanner> createState() => _WebDownloadBannerState();
}

class _WebDownloadBannerState extends State<WebDownloadBanner> {
  bool _dismissed = false;
  String? _downloadUrl;
  String? _fileSize;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return;
    _dismissed = isBannerDismissed();
    if (!_dismissed) _fetchVersionInfo();
  }

  Future<void> _fetchVersionInfo() async {
    try {
      final response = await http.get(Uri.parse(AppUrls.versionJsonUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _downloadUrl = data['url'] as String?;
            final bytes = data['size'] as int?;
            if (bytes != null) {
              _fileSize = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
            }
          });
        }
      }
    } catch (_) {
      // Silently fail — banner still shows with GitHub fallback.
    }
  }

  void _dismiss() {
    setBannerDismissed();
    setState(() => _dismissed = true);
  }

  Future<void> _download() async {
    final url = _downloadUrl ?? AppUrls.githubReleasesLatest;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _dismissed) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: HanaColors.primaryContainer.withAlpha(230),
        border: Border(
          bottom: BorderSide(
            color: HanaColors.primary.withAlpha(26),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: HanaColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.android,
                color: HanaColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.webDownloadBannerTitle,
                    style: const TextStyle(
                      color: HanaColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _fileSize != null
                        ? '${l10n.webDownloadBannerSubtitle} · $_fileSize'
                        : l10n.webDownloadBannerSubtitle,
                    style: TextStyle(
                      color: HanaColors.primary.withAlpha(153),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 32,
              child: FilledButton(
                onPressed: _download,
                style: FilledButton.styleFrom(
                  backgroundColor: HanaColors.primary,
                  foregroundColor: HanaColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(l10n.webDownloadButton),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                onPressed: _dismiss,
                padding: EdgeInsets.zero,
                iconSize: 16,
                icon: Icon(
                  Icons.close,
                  color: HanaColors.primary.withAlpha(128),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
