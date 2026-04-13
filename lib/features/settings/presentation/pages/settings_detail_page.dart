import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/constants/app_urls.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/update/update_dialog.dart';
import 'package:hananote/core/update/update_service.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// The settings detail page.
class SettingsDetailPage extends StatelessWidget {
  /// Creates a [SettingsDetailPage].
  const SettingsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: HanaColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              backgroundColor:
                  HanaColors.background.withAlpha((255 * 0.8).round()),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: HanaColors.primary),
                onPressed: () => context.pop(),
              ),
              title: Text(
                l10n.settingsTitle,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: HanaColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = state.profile;
          final settings = state.settings;
          final localeName = Localizations.localeOf(context).toLanguageTag();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 24,
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                  left: 24,
                  right: 24,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Personal Info
                    _SectionTitle(title: l10n.personalInfo),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.person_outline,
                          title: l10n.editDisplayName,
                          trailing: Text(
                            profile.displayName,
                            style: const TextStyle(
                              color: HanaColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _showEditNameDialog(
                            context,
                            profile.displayName,
                            l10n,
                          ),
                        ),
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(left: 56),
                          color: HanaColors.primaryOf(context).withAlpha(13),
                        ),
                        _SettingsTile(
                          icon: Icons.cake_outlined,
                          title: l10n.editHrtStartDate,
                          trailing: Text(
                            DateFormat.yMMMd(localeName)
                                .format(profile.hrtStartDate),
                            style: const TextStyle(
                              color: HanaColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _selectHrtStartDate(
                            context,
                            profile.hrtStartDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Appearance
                    _SectionTitle(title: l10n.appearance),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.language,
                          title: l10n.languageSetting,
                          trailing: Text(
                            _languageLabel(settings.language, l10n),
                            style: const TextStyle(
                              color: HanaColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _showLanguagePicker(
                            context,
                            settings.language,
                          ),
                        ),
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(left: 56),
                          color: HanaColors.primaryOf(context).withAlpha(13),
                        ),
                        _SettingsTile(
                          icon: Icons.dark_mode_outlined,
                          title: l10n.darkMode,
                          trailing: Switch(
                            value: settings.darkModeEnabled,
                            onChanged: (val) =>
                                context.read<SettingsBloc>().add(
                                      SettingsEvent.toggleDarkMode(
                                        enabled: val,
                                      ),
                                    ),
                            activeTrackColor: HanaColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Privacy Security (moved some from profile)
                    _SectionTitle(title: l10n.privacySecurity),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.lock_outline,
                          title: l10n.appLock,
                          trailing: Switch(
                            value: settings.appLockEnabled,
                            onChanged: (val) => context
                                .read<SettingsBloc>()
                                .add(ToggleAppLock(enabled: val)),
                          ),
                        ),
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(left: 56),
                          color: HanaColors.primaryOf(context).withAlpha(13),
                        ),
                        _SettingsTile(
                          icon: Icons.visibility_off_outlined,
                          title: l10n.privacyMode,
                          subtitle: l10n.privacyModeEnabled,
                          trailing: Switch(
                            value: settings.privacyModeEnabled,
                            onChanged: (val) => context
                                .read<SettingsBloc>()
                                .add(TogglePrivacyMode(enabled: val)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Updates (hidden on web — no APK installation)
                    if (!kIsWeb) ...[
                    _SectionTitle(title: l10n.updateSectionTitle),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.system_update_rounded,
                          title: l10n.updateAutoCheck,
                          subtitle: l10n.updateAutoCheckDesc,
                          trailing: Switch(
                            value: settings.autoCheckUpdate,
                            onChanged: (val) =>
                                context.read<SettingsBloc>().add(
                                      ToggleAutoCheckUpdate(enabled: val),
                                    ),
                            activeTrackColor: HanaColors.primary,
                          ),
                        ),
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(left: 56),
                          color: HanaColors.primaryOf(context).withAlpha(13),
                        ),
                        _SettingsTile(
                          icon: Icons.refresh_rounded,
                          title: l10n.updateCheckNow,
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: HanaColors.outlineVariant,
                          ),
                          onTap: () => _checkForUpdates(context, l10n),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ], // end if (!kIsWeb)

                    // Download App (web only)
                    if (kIsWeb) ...[
                      _SectionTitle(title: l10n.downloadApp),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        children: [
                          _SettingsTile(
                            icon: Icons.android,
                            title: l10n.downloadAndroidApp,
                            subtitle: l10n.downloadAndroidAppDesc,
                            trailing: const Icon(
                              Icons.download_rounded,
                              color: HanaColors.primary,
                            ),
                            onTap: () => launchUrl(
                              Uri.parse(AppUrls.githubReleasesLatest),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // About
                    _SectionTitle(title: l10n.about),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.info_outline,
                          title: l10n.version,
                          trailing: Text(
                            'v${AppConstants.appVersion}',
                            style: const TextStyle(
                              color: HanaColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(left: 56),
                          color: HanaColors.primaryOf(context).withAlpha(13),
                        ),
                        _SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: l10n.privacyPolicy,
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: HanaColors.outlineVariant,
                          ),
                          onTap: () => context.push('/legal/privacy'),
                        ),
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(left: 56),
                          color: HanaColors.primaryOf(context).withAlpha(13),
                        ),
                        _SettingsTile(
                          icon: Icons.description_outlined,
                          title: l10n.termsOfUse,
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: HanaColors.outlineVariant,
                          ),
                          onTap: () => context.push('/legal/terms'),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _checkForUpdates(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    // Show loading indicator
    // ignore: unawaited_futures
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: HanaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: HanaColors.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.updateChecking,
                style: const TextStyle(
                  fontSize: 14,
                  color: HanaColors.onSurface,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final info = await UpdateService.checkForUpdate(
        AppConstants.appVersion,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      if (info != null) {
        await showUpdateDialog(context, info);
      } else {
        // Already up to date
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(l10n.updateAlreadyLatest),
              ],
            ),
            backgroundColor: HanaColors.statusGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(l10n.updateCheckFailed),
            ],
          ),
          backgroundColor: HanaColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  static String _languageLabel(String code, AppLocalizations l10n) {
    return switch (code) {
      'zh' => '中文',
      'en' => 'English',
      'ja' => '日本語',
      _ => l10n.languageSystem,
    };
  }

  static void _showLanguagePicker(BuildContext context, String current) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      ('', l10n.languageSystem),
      ('zh', '中文'),
      ('en', 'English'),
      ('ja', '日本語'),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: HanaColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: HanaColors.outlineVariant.withAlpha(128),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l10n.selectLanguage,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: HanaColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...options.map(
                  (option) => ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 24),
                    title: Text(
                      option.$2,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: current == option.$1
                        ? const Icon(
                            Icons.check_circle,
                            color: HanaColors.primary,
                          )
                        : null,
                    onTap: () {
                      context.read<SettingsBloc>().add(
                            SettingsEvent.changeLanguage(
                              languageCode: option.$1,
                            ),
                          );
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    String currentName,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController(text: currentName);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: HanaColors.surfaceContainerLowest,
          title: Text(l10n.editDisplayName),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  context.read<SettingsBloc>().add(
                        UpdateDisplayName(name: newName),
                      );
                }
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectHrtStartDate(
    BuildContext context,
    DateTime currentDate,
  ) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: HanaColors.primary,
              onSurface: HanaColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateHrtStartDate(date: selected));
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: HanaColors.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HanaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: HanaColors.primary.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: HanaColors.primaryContainer.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: HanaColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: HanaColors.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: HanaColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
