// Release prep note: Main shell keeps file-level lint suppressions because the
// internal app scaffold API is not user-facing and some route literals are
// intentionally kept unwrapped for readability.
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/widgets/web_download_banner.dart';

/// Navigation bar content height, excluding the bottom safe area inset.
const double kNavBarContentHeight = 72;

class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (kIsWeb) const WebDownloadBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: _StitchNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _StitchNavigationBar extends StatelessWidget {
  const _StitchNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: HanaColors.background.withAlpha((255 * 0.85).round()),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: HanaColors.primaryContainer.withAlpha(26),
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.auto_awesome,
                    label: l10n.tabToday,
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.edit_note,
                    label: l10n.tabRecord,
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavItem(
                    icon: Icons.timeline,
                    label: l10n.tabTimeline,
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    icon: Icons.analytics,
                    label: l10n.tabData,
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                  _NavItem(
                    icon: Icons.person,
                    label: l10n.tabProfile,
                    isSelected: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Normal style: text-[#864E5A]/50 (0.5 opacity = 128 alpha)
    // Active style: #864E5A on #FFB7C5/20 for normal active, OR the gradient one!
    // The design states the Active tab gets gradient-to-br from #FFB7C5 to #FCD3FB

    const activeGradient = LinearGradient(
      colors: [
        HanaColors.primaryContainer,
        HanaColors.secondaryContainer,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0, // scale-110 for active
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: isSelected
              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  gradient: activeGradient,
                  borderRadius: BorderRadius.circular(9999),
                )
              : const BoxDecoration(
                  color: Colors.transparent,
                ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? HanaColors.primary
                    : HanaColors.primary.withAlpha(
                        102,
                      ), // 40% opacity = 102 alpha as per HTML text-[#864E5A]/40
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: isSelected ? 0.5 : 0.2, // tracking-wide
                  color: isSelected
                      ? HanaColors.primary
                      : HanaColors.primary.withAlpha(102),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
