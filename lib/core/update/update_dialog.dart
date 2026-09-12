import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/constants/app_urls.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/update/apk_installer.dart';
import 'package:hananote/core/update/update_service.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';

/// Result of showing the update dialog.
enum UpdateDialogResult {
  /// User chose to install the update.
  installed,

  /// User chose to update later.
  later,

  /// User chose to skip this version.
  skipped,
}

/// Shows the production-grade update bottom sheet.
Future<UpdateDialogResult?> showUpdateDialog(
  BuildContext context,
  AppUpdateInfo info, {
  bool allowSkip = true,
}) {
  return showModalBottomSheet<UpdateDialogResult>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _UpdateSheet(
      info: info,
      parentContext: context,
      allowSkip: allowSkip,
    ),
  );
}

enum _UpdateState { initial, downloading, downloaded, error }

class _UpdateSheet extends StatefulWidget {
  const _UpdateSheet({
    required this.info,
    required this.parentContext,
    this.allowSkip = true,
  });
  final AppUpdateInfo info;
  final BuildContext parentContext;
  final bool allowSkip;

  @override
  State<_UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<_UpdateSheet>
    with SingleTickerProviderStateMixin {
  _UpdateState _state = _UpdateState.initial;
  DownloadProgress? _progress;
  String? _apkPath;
  late AnimationController _iconAnimController;
  late Animation<double> _iconBounce;

  @override
  void initState() {
    super.initState();
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _iconBounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _iconAnimController, curve: Curves.elasticOut),
    );
    _iconAnimController.forward();
  }

  @override
  void dispose() {
    _iconAnimController.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    final url = widget.info.downloadUrl;
    if (url == null || url.isEmpty) return;

    setState(() {
      _state = _UpdateState.downloading;
      _progress = null;
    });

    try {
      final path = await UpdateService.downloadApk(
        url,
        (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (mounted) {
        setState(() {
          _state = _UpdateState.downloaded;
          _apkPath = path;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _state = _UpdateState.error);
    }
  }

  void _skipVersion() {
    try {
      widget.parentContext.read<SettingsBloc>().add(
            SkipVersion(version: widget.info.latestVersion),
          );
    } catch (_) {
      // Settings bloc may not be available in some contexts
    }
    Navigator.of(context).pop(UpdateDialogResult.skipped);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: HanaColors.surfaceContainerLowestOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: HanaColors.outlineVariantOf(context).withAlpha(102),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              // Header icon with animation
              _buildHeader(l10n),
              const SizedBox(height: 20),
              // Version comparison
              _buildVersionComparison(l10n),
              // File size badge
              if (widget.info.fileSize != null) ...[
                const SizedBox(height: 8),
                _buildFileSizeBadge(),
              ],
              // Release notes
              if (widget.info.releaseNotes.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildReleaseNotes(l10n),
              ],
              const SizedBox(height: 24),
              // Actions area
              _buildActionsArea(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final isDownloading = _state == _UpdateState.downloading;
    final isDownloaded = _state == _UpdateState.downloaded;

    return AnimatedBuilder(
      animation: _iconBounce,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + (_iconBounce.value * 0.5),
          child: child,
        );
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDownloaded
                ? [
                    HanaColors.statusGreen.withAlpha(51),
                    HanaColors.statusGreen.withAlpha(26),
                  ]
                : [
                    HanaColors.primaryOf(context).withAlpha(51),
                    HanaColors.primaryContainerOf(context).withAlpha(77),
                  ],
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isDownloaded
              ? Icons.check_circle_outline_rounded
              : isDownloading
                  ? Icons.downloading_rounded
                  : Icons.system_update_rounded,
          size: 36,
          color: isDownloaded ? HanaColors.statusGreen : HanaColors.primaryOf(context),
        ),
      ),
    );
  }

  Widget _buildVersionComparison(AppLocalizations l10n) {
    final title = _state == _UpdateState.downloaded
        ? l10n.updateReadyToInstall
        : l10n.updateAvailable;

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: HanaColors.onSurfaceOf(context),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        // Version comparison row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: HanaColors.surfaceContainerLowOf(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _VersionBadge(
                label: l10n.updateCurrentVersion,
                version: 'v${AppConstants.appVersion}',
                isOld: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: HanaColors.primaryOf(context).withAlpha(179),
                ),
              ),
              _VersionBadge(
                label: l10n.updateNewVersion,
                version: 'v${widget.info.latestVersion}',
                isOld: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileSizeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: HanaColors.primaryContainerOf(context).withAlpha(77),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.info.fileSizeText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: HanaColors.primaryOf(context),
        ),
      ),
    );
  }

  Widget _buildReleaseNotes(AppLocalizations l10n) {
    // Parse release notes into bullet points for better readability
    final notes = widget.info.releaseNotes
        .replaceAll('\r\n', '\n')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 140),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HanaColors.surfaceContainerLowOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HanaColors.outlineVariantOf(context).withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: HanaColors.primaryOf(context).withAlpha(179),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.updateWhatsNew,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: HanaColors.primaryOf(context).withAlpha(179),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: notes
                    .map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          line.trim().startsWith('-') ||
                                  line.trim().startsWith('*')
                              ? line.trim()
                              : line.trim(),
                          style: TextStyle(
                            fontSize: 13,
                            color: HanaColors.onSurfaceVariantOf(context),
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsArea(AppLocalizations l10n) {
    return switch (_state) {
      _UpdateState.initial => _buildInitialActions(l10n),
      _UpdateState.downloading => _buildDownloadingState(l10n),
      _UpdateState.downloaded => _buildDownloadedActions(l10n),
      _UpdateState.error => _buildErrorActions(l10n),
    };
  }

  Widget _buildInitialActions(AppLocalizations l10n) {
    return Column(
      children: [
        // Primary action — Update Now
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: _startDownload,
            style: FilledButton.styleFrom(
              backgroundColor: HanaColors.primaryOf(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.updateNow,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Secondary actions row
        Row(
          children: [
            // Skip this version
            if (widget.allowSkip) ...[
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextButton(
                    onPressed: _skipVersion,
                    style: TextButton.styleFrom(
                      foregroundColor: HanaColors.onSurfaceVariantOf(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.updateSkipVersion,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Later
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(UpdateDialogResult.later),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HanaColors.onSurfaceVariantOf(context),
                    side: BorderSide(
                      color: HanaColors.outlineVariantOf(context).withAlpha(128),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.updateLater,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadingState(AppLocalizations l10n) {
    final p = _progress;
    final percent = p?.percent ?? 0;
    final fraction = p?.fraction ?? 0.0;

    return Column(
      children: [
        // Progress info row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              p != null
                  ? '${p.receivedMB} / ${p.totalMB} MB'
                  : l10n.downloadingUpdate,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: HanaColors.onSurfaceOf(context),
              ),
            ),
            if (p != null && p.speedText.isNotEmpty)
              Text(
                p.speedText,
                style: TextStyle(
                  fontSize: 12,
                  color: HanaColors.onSurfaceVariantOf(context),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // Progress bar
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: fraction > 0 ? fraction : null,
                minHeight: 10,
                backgroundColor: HanaColors.surfaceContainerHighOf(context),
                valueColor:
                    AlwaysStoppedAnimation<Color>(HanaColors.primaryOf(context)),
              ),
            ),
            if (fraction > 0)
              Positioned.fill(
                child: Center(
                  child: Text(
                    '$percent%',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Remaining time
        if (p != null && p.remainingText.isNotEmpty)
          Text(
            l10n.updateEstimatedTime(p.remainingText),
            style: TextStyle(
              fontSize: 12,
              color: HanaColors.onSurfaceVariantOf(context),
            ),
          ),
      ],
    );
  }

  Widget _buildDownloadedActions(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () {
              if (_apkPath != null) {
                ApkInstaller.install(_apkPath!);
                Navigator.of(context).pop(UpdateDialogResult.installed);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: HanaColors.statusGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.install_mobile_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.installUpdate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorActions(AppLocalizations l10n) {
    return Column(
      children: [
        // Error message
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: HanaColors.errorOf(context).withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: HanaColors.errorOf(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.downloadFailed,
                  style: TextStyle(
                    fontSize: 13,
                    color: HanaColors.errorOf(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Retry
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: _startDownload,
            style: FilledButton.styleFrom(
              backgroundColor: HanaColors.primaryOf(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.updateRetry,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () =>
                Navigator.of(context).pop(UpdateDialogResult.later),
            style: OutlinedButton.styleFrom(
              foregroundColor: HanaColors.onSurfaceVariantOf(context),
              side: BorderSide(
                color: HanaColors.outlineVariantOf(context).withAlpha(128),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.updateLater),
          ),
        ),
      ],
    );
  }
}

// -- Sub-widgets --

class _VersionBadge extends StatelessWidget {
  const _VersionBadge({
    required this.label,
    required this.version,
    required this.isOld,
  });

  final String label;
  final String version;
  final bool isOld;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isOld
                ? HanaColors.onSurfaceVariantOf(context)
                : HanaColors.primaryOf(context),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isOld
                ? HanaColors.surfaceContainerHighOf(context)
                : HanaColors.primaryContainerOf(context).withAlpha(128),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            version,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isOld
                  ? HanaColors.onSurfaceVariantOf(context)
                  : HanaColors.primaryOf(context),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      ],
    );
  }
}
