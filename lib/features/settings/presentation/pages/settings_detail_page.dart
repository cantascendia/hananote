import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:hananote/core/constants/app_urls.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

/// The settings detail page.
class SettingsDetailPage extends StatelessWidget {
  /// Creates a [SettingsDetailPage].
  const SettingsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: HanaColors.backgroundOf(context),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              backgroundColor:
                  HanaColors.backgroundOf(context).withAlpha((255 * 0.8).round()),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: HanaColors.primaryOf(context)),
                onPressed: () => context.pop(),
              ),
              title: Text(
                l10n.settingsTitle,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: HanaColors.primaryOf(context),
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
                            style: TextStyle(
                              color: HanaColors.onSurfaceVariantOf(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _showEditNameDialog(
                            context,
                            profile.displayName,
                            l10n,
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _SettingsTile(
                          icon: Icons.cake_outlined,
                          title: l10n.editHrtStartDate,
                          trailing: Text(
                            DateFormat.yMMMd(localeName)
                                .format(profile.hrtStartDate),
                            style: TextStyle(
                              color: HanaColors.onSurfaceVariantOf(context),
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
                            'System', // Placeholder
                            style: TextStyle(
                              color: HanaColors.onSurfaceVariantOf(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            // TODO(user): Implement language switching logic.
                            // Currently using system locale.
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(content: Text(l10n.featureComingSoon)),
                              );
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        _SettingsTile(
                          icon: Icons.dark_mode_outlined,
                          title: l10n.darkMode,
                          trailing: Switch(
                            value: false,
                            onChanged: (val) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.darkModeComingSoon),
                                  ),
                                );
                            },
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
                        const Divider(height: 1, indent: 56),
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

                    // About
                    _SectionTitle(title: l10n.about),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.info_outline,
                          title: l10n.version,
                          trailing: Text(
                            '1.0.0', // Placeholder
                            style: TextStyle(
                              color: HanaColors.onSurfaceVariantOf(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: l10n.privacyPolicy,
                          trailing: Icon(Icons.chevron_right, color: HanaColors.outlineVariantOf(context)),
                          onTap: () => launchUrl(
                            Uri.parse(AppUrls.privacyPolicy),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _SettingsTile(
                          icon: Icons.description_outlined,
                          title: l10n.termsOfUse,
                          trailing: Icon(Icons.chevron_right, color: HanaColors.outlineVariantOf(context)),
                          onTap: () => launchUrl(
                            Uri.parse(AppUrls.termsOfService),
                            mode: LaunchMode.externalApplication,
                          ),
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
          backgroundColor: HanaColors.surfaceContainerLowestOf(context),
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
            colorScheme: ColorScheme.light(
              primary: HanaColors.primaryOf(context),
              onSurface: HanaColors.onSurfaceOf(context),
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
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: HanaColors.onSurfaceVariantOf(context),
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
        color: HanaColors.surfaceContainerLowestOf(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: HanaColors.primaryOf(context).withAlpha(8),
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
                  color: HanaColors.primaryContainerOf(context).withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: HanaColors.primaryOf(context), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: HanaColors.onSurfaceOf(context),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: HanaColors.onSurfaceVariantOf(context),
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
