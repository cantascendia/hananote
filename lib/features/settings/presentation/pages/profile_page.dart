// ignore_for_file: lines_longer_than_80_chars
// Release prep note: This internal page exposes app-only widgets, so full
// dartdoc coverage is deferred to the documentation pass.
// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';
import 'package:hananote/core/backup/read_backup_stream.dart';
import 'package:hananote/core/constants/app_urls.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/privacy/native_interaction.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_app_bar.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Triple-tap confirmation dialog for the local emergency wipe.
  /// Per CONSTITUTION §1 + R52 plan: tertiary (coral) chassis instead
  /// of error red; gold "不可恢复" warning eyebrow; user must tap the
  /// destructive action 3 times before the wipe fires.
  Future<bool> _showEmergencyWipeDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        var taps = 0;
        return StatefulBuilder(
          builder: (sCtx, setS) {
            final tertiary = HanaColors.tertiaryOf(dialogContext);
            return AlertDialog(
              backgroundColor:
                  HanaColors.surfaceContainerLowestOf(dialogContext),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: tertiary.withValues(alpha: 0.4),
                ),
              ),
              title: Row(
                children: [
                  Icon(Symbols.warning_amber, size: 24, color: tertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.wipeAllDataTitle,
                      style: HanaTypography.titleLg.copyWith(
                        color: tertiary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gold "irreversible" warning eyebrow
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: HanaColorsV2.champagneSoft,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: HanaColorsV2.goldLight.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Text(
                      'IRREVERSIBLE · 不可恢复',
                      style: HanaTypography.labelSm.copyWith(
                        color: HanaColorsV2.goldDeep,
                        letterSpacing: 1.32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.wipeAllDataMessage,
                    style: HanaTypography.bodyMd.copyWith(
                      color: HanaColors.onSurfaceOf(dialogContext),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '请连续点击「确认删除」3 次以确认 · $taps / 3',
                    style: HanaTypography.labelMd.copyWith(
                      color: tertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(
                      color: HanaColors.onSurfaceVariantOf(dialogContext),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setS(() => taps++);
                    if (taps >= 3) {
                      Navigator.of(dialogContext).pop(true);
                    }
                  },
                  child: Text(
                    '${l10n.delete} (${3 - taps})',
                    style: TextStyle(
                      color: tertiary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    return result ?? false;
  }

  Future<void> _handleGeneratePdf(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: HanaColors.surfaceContainerLowestOf(dialogContext),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(l10n.pdfPlaintextConfirmTitle),
        content: Text(l10n.pdfPlaintextConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.pdfPlaintextConfirmAction,
              style: TextStyle(
                color: HanaColors.primaryOf(dialogContext),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) == false || !context.mounted) return;

    context.read<SettingsBloc>().add(
          SettingsEvent.generatePdfReport(
            pdfTitle: l10n.pdfTitle,
            medSection: l10n.pdfMedSection,
            bloodSection: l10n.pdfBloodSection,
            measureSection: l10n.pdfMeasureSection,
            journalSection: l10n.pdfJournalSection,
            noData: l10n.pdfNoData,
          ),
        );
  }

  Future<void> _handleExportBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final password = await _showBackupPasswordDialog(
      context: context,
      l10n: l10n,
      requireConfirm: true,
    );
    if (password == null || !context.mounted) return;
    context.read<SettingsBloc>().add(
          SettingsEvent.exportData(password: password),
        );
  }

  Future<void> _handleImportBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<SettingsBloc>();

    FilePickerResult? result;
    try {
      result = await NativeInteraction.run(
        () => FilePicker.platform.pickFiles(
          // Android's MIME registry does not recognize .vault; custom filters
          // otherwise disable valid vault files. Validate the extension below.
          type: FileType.any,
          withData: false,
          withReadStream: true,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed)));
      return;
    }

    if (result == null || result.files.isEmpty) return;
    if (!context.mounted) return;
    final fileName = result.files.first.name.toLowerCase();
    if (!fileName.endsWith('.vault') && !fileName.endsWith('.json')) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed)));
      return;
    }
    late final Uint8List bytes;
    try {
      final file = result.files.first;
      final stream = file.readStream;
      if (stream == null) throw const FormatException('Backup stream missing.');
      bytes = await readBackupStream(stream: stream, declaredSize: file.size);
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed)));
      return;
    }
    if (!context.mounted) return;
    final password = fileName.endsWith('.vault')
        ? await _showBackupPasswordDialog(
            context: context,
            l10n: l10n,
            requireConfirm: false,
          )
        : '';
    if (password == null) return;

    if (!context.mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: HanaColors.surfaceContainerLowestOf(dialogContext),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(l10n.importConfirmTitle),
        content: Text(l10n.importConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.importConfirmAction,
              style: TextStyle(
                color: HanaColors.primaryOf(dialogContext),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      bloc.add(
        SettingsEvent.importBackup(
          backupBytes: bytes,
          password: password,
          legacyJson: fileName.endsWith('.json'),
        ),
      );
    }
  }

  Future<String?> _showBackupPasswordDialog({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool requireConfirm,
  }) async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;

    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor:
                    HanaColors.surfaceContainerLowestOf(dialogContext),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Text(
                  requireConfirm
                      ? l10n.backupPasswordTitle
                      : l10n.backupPasswordUnlockTitle,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.backupPasswordRememberWarning,
                        style: HanaTypography.bodyMd.copyWith(
                          color: HanaColors.onSurfaceVariantOf(dialogContext),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: l10n.backupPasswordLabel,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (requireConfirm) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: confirmController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.backupPasswordConfirmLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorText!,
                          style: HanaTypography.labelMd.copyWith(
                            color: HanaColors.tertiaryOf(dialogContext),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      final password = passwordController.text;
                      final confirm = confirmController.text;
                      if (password.length < 8) {
                        setState(() {
                          errorText = l10n.backupPasswordTooShort;
                        });
                        return;
                      }
                      if (requireConfirm && password != confirm) {
                        setState(() {
                          errorText = l10n.backupPasswordMismatch;
                        });
                        return;
                      }
                      Navigator.of(dialogContext).pop(password);
                    },
                    child: Text(
                      requireConfirm
                          ? l10n.backupPasswordCreateAction
                          : l10n.backupPasswordUnlockAction,
                      style: TextStyle(
                        color: HanaColors.primaryOf(dialogContext),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      passwordController.dispose();
      confirmController.dispose();
    }
  }

  BoxDecoration _bentoDecoration() {
    return BoxDecoration(
      color: HanaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: HanaColors.primaryContainer.withAlpha(77),
      ), // 30% border
      boxShadow: [
        BoxShadow(
          color: HanaColors.primary.withAlpha(10), // 4% shadow
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _bentoSeparator() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: HanaColors.primary.withAlpha(13), // 5% band, not a hard line
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsWiped) {
          context.go('/');
        } else if (state is SettingsError) {
          _showSnackBar(context, state.message);
        } else if (state is SettingsActionResult) {
          final l10n = AppLocalizations.of(context)!;
          final key = state.actionKey;
          if (key == 'export_in_progress') {
            _showSnackBar(context, l10n.exportInProgress);
          } else if (key == 'export_success') {
            _showSnackBar(context, l10n.exportSuccess);
          } else if (key == 'export_failed') {
            _showSnackBar(context, l10n.exportFailed);
          } else if (key == 'pdf_in_progress') {
            _showSnackBar(context, l10n.pdfGenerating);
          } else if (key == 'pdf_success') {
            _showSnackBar(context, l10n.pdfSuccess);
          } else if (key == 'pdf_failed') {
            _showSnackBar(context, l10n.pdfFailed);
          } else if (key == 'import_in_progress') {
            _showSnackBar(context, l10n.importInProgress);
          } else if (key.startsWith('import_success:')) {
            final count = int.tryParse(key.split(':').last) ?? 0;
            _showSnackBar(context, l10n.importSuccess(count));
          } else if (key == 'import_failed') {
            _showSnackBar(context, l10n.importFailed);
          }
        }
      },
      builder: (context, rootState) {
        final l10n = AppLocalizations.of(context)!;
        final state = rootState is SettingsActionResult
            ? rootState.previousState
            : rootState;

        if (state is SettingsError) {
          return Scaffold(
            backgroundColor: HanaColors.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<SettingsBloc>()
                            .add(const LoadSettingsDashboard());
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is! SettingsLoaded) {
          return const Scaffold(
            backgroundColor: HanaColors.background,
            body: Center(
              child: CircularProgressIndicator(color: HanaColors.primary),
            ),
          );
        }

        final theme = Theme.of(context);
        final localeName = Localizations.localeOf(context).toLanguageTag();
        final inventoryText = state.inventoryDaysRemaining != null
            ? l10n.inventoryDaysRemaining(state.inventoryDaysRemaining!)
            : l10n.inventoryDataUnavailable;
        final topPadding =
            MediaQuery.of(context).padding.top + kToolbarHeight + 16;
        final lastBackupText = state.settings.lastBackupDate != null
            ? DateFormat.yMMMd(localeName)
                .format(state.settings.lastBackupDate!)
            : l10n.noUpdatesYet;

        return Scaffold(
          backgroundColor: HanaColors.backgroundOf(context),
          extendBodyBehindAppBar: true,
          appBar: HoyoAppBar(
            title: l10n.profile,
            leading: IconButton(
              icon: Icon(
                Symbols.settings,
                size: 18,
                color: HanaColors.primaryOf(context),
              ),
              onPressed: () => context.push('/settings'),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Symbols.notifications,
                  size: 18,
                  color: HanaColors.primaryOf(context),
                ),
                onPressed: () => context.push('/notification_settings'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, topPadding, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: HanaColors.primaryContainer,
                        child: Icon(
                          Symbols.person,
                          size: 48,
                          color: HanaColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.profile.displayName.isEmpty
                            ? l10n.defaultUserName
                            : state.profile.displayName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: HanaColors.primary,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      if (state.profile.hrtStartDate != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: HanaColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            l10n.hrtDay(state.profile.hrtDayCount),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: HanaColors.onSurfaceVariant
                                  .withAlpha((255 * 0.8).round()),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    l10n.medications,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: HanaColors.primary,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.push('/drugs'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _bentoDecoration(),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: HanaColors.primaryContainer,
                            ),
                            child: const Icon(
                              Symbols.medication,
                              color: HanaColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.myMedications,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: HanaColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.drugCount(state.activeDrugCount),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: HanaColors.onSurfaceVariant
                                        .withAlpha(204),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Symbols.chevron_right,
                            color: HanaColors.outlineVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SquareCard(
                          icon: Symbols.inventory_2,
                          iconColor: HanaColors.secondary,
                          iconBgColor: HanaColors.secondaryContainer
                              .withAlpha(128), // 50%
                          title: l10n.inventory,
                          subtitle: inventoryText,
                          subtitleColor: HanaColors.secondary,
                          bentoDecoration: _bentoDecoration(),
                          onTap: () => context.push('/inventory'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SquareCard(
                          icon: Symbols.view_quilt,
                          iconColor: HanaColors.primary,
                          iconBgColor:
                              HanaColors.primaryContainer.withAlpha(128), // 50%
                          title: l10n.medicationPlan,
                          subtitle: l10n.manageEditSchedules,
                          subtitleColor: HanaColors.onSurfaceVariant,
                          bentoDecoration: _bentoDecoration(),
                          onTap: () => context.push('/drugs'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    l10n.privacySecurity,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: HanaColors.primary,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: _bentoDecoration(),
                    child: Column(
                      children: [
                        _ListTileItem(
                          icon: Symbols.lock,
                          iconColor: HanaColors.primary,
                          title: l10n.appLock,
                          trailing: Switch(
                            value: state.settings.appLockEnabled,
                            activeThumbColor: HanaColors.primary,
                            activeTrackColor: HanaColors.primaryContainer,
                            onChanged: (enabled) {
                              context
                                  .read<SettingsBloc>()
                                  .add(ToggleAppLock(enabled: enabled));
                            },
                          ),
                        ),
                        _bentoSeparator(),
                        _ListTileItem(
                          icon: Symbols.visibility_off,
                          iconColor: HanaColors.primary,
                          title: l10n.privacyMode,
                          subtitle: state.settings.privacyModeEnabled
                              ? l10n.privacyModeEnabled
                              : l10n.privacyModeDisabled,
                          isChevron: true,
                          onTap: () {
                            context.read<SettingsBloc>().add(
                                  TogglePrivacyMode(
                                    enabled: !state.settings.privacyModeEnabled,
                                  ),
                                );
                          },
                        ),
                        _bentoSeparator(),
                        _ListTileItem(
                          icon: Symbols.warning,
                          iconColor: HanaColors.tertiaryOf(context),
                          title: l10n.wipeAllData,
                          titleColor: HanaColors.tertiaryOf(context),
                          isChevron: true,
                          chevronColor: HanaColors.tertiaryOf(context),
                          onTap: () async {
                            final confirmed =
                                await _showEmergencyWipeDialog(context, l10n);
                            if (confirmed && context.mounted) {
                              context
                                  .read<SettingsBloc>()
                                  .add(const WipeSettingsData());
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    l10n.dataBackup,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: HanaColors.primary,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ButtonRowItem(
                    icon: Symbols.cloud_upload,
                    title: l10n.exportBackup,
                    trailingText: lastBackupText,
                    decoration: _bentoDecoration(),
                    onTap: () => _handleExportBackup(context),
                  ),
                  const SizedBox(height: 12),
                  _ButtonRowItem(
                    icon: Symbols.cloud_download,
                    title: l10n.importBackup,
                    isChevron: true,
                    decoration: _bentoDecoration(),
                    onTap: () => _handleImportBackup(context),
                  ),
                  const SizedBox(height: 12),
                  _ButtonRowItem(
                    icon: Symbols.description,
                    title: l10n.generatePdf,
                    isChevron: true,
                    decoration: _bentoDecoration(),
                    onTap: () => _handleGeneratePdf(context),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    l10n.about,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: HanaColors.primary,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: _bentoDecoration(),
                    child: Column(
                      children: [
                        _ListTileItem(
                          title: l10n.version,
                          trailingText: 'v${AppConstants.appVersion}',
                        ),
                        _bentoSeparator(),
                        _ListTileItem(
                          title: l10n.privacyPolicy,
                          isChevron: true,
                          onTap: () => context.push('/legal/privacy'),
                        ),
                        _bentoSeparator(),
                        _ListTileItem(
                          title: l10n.termsOfUse,
                          isChevron: true,
                          onTap: () => context.push('/legal/terms'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SquareCard extends StatelessWidget {
  const _SquareCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.bentoDecoration,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final BoxDecoration bentoDecoration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: bentoDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Plus Jakarta Sans',
                        color: HanaColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListTileItem extends StatelessWidget {
  const _ListTileItem({
    required this.title,
    this.icon,
    this.iconColor,
    this.titleColor,
    this.subtitle,
    this.isChevron = false,
    this.trailing,
    this.trailingText,
    this.chevronColor,
    this.onTap,
  });

  final IconData? icon;
  final Color? iconColor;
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final bool isChevron;
  final Widget? trailing;
  final String? trailingText;
  final Color? chevronColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? HanaColors.primary).withAlpha(26), // 10%
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? HanaColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: titleColor ?? HanaColors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: HanaColors.onSurfaceVariant.withAlpha(179),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailingText != null)
              Text(
                trailingText!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: HanaColors.onSurfaceVariant,
                    ),
              ),
            if (isChevron)
              Icon(
                Symbols.chevron_right,
                size: 20,
                color: chevronColor ?? HanaColors.outlineVariant,
              ),
          ],
        ),
      ),
    );
  }
}

class _ButtonRowItem extends StatelessWidget {
  const _ButtonRowItem({
    required this.icon,
    required this.title,
    required this.decoration,
    this.trailingText,
    this.isChevron = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final bool isChevron;
  final BoxDecoration decoration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: decoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HanaColors.primaryContainer.withAlpha(77), // 30%
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: HanaColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: HanaColors.onSurface,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: HanaColors.onSurfaceVariant.withAlpha(204),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (isChevron)
                const Icon(
                  Symbols.chevron_right,
                  size: 20,
                  color: HanaColors.outlineVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
