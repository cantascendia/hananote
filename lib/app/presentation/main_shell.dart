// Release prep note: Main shell keeps file-level lint suppressions because the
// internal app scaffold API is not user-facing and some route literals are
// intentionally kept unwrapped for readability.
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_bottom_nav.dart';
import 'package:hananote/core/widgets/web_download_banner.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: HanaColors.backgroundOf(context),
      body: Column(
        children: [
          if (kIsWeb) const WebDownloadBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: HoyoBottomNav(
          activeIndex: navigationShell.currentIndex,
          onChanged: _onTap,
          // Per design README: "Material Symbols Outlined for every
          // icon. Filled variant only when active/selected." We pass
          // ONE Symbols icon per item; HoyoBottomNav flips the
          // `fill` axis 0→1 on active.
          items: [
            HoyoBottomNavItem(
              icon: Symbols.auto_awesome,
              label: l10n.tabToday,
            ),
            HoyoBottomNavItem(
              icon: Symbols.edit_note,
              label: l10n.tabRecord,
            ),
            HoyoBottomNavItem(
              icon: Symbols.timeline,
              label: l10n.tabTimeline,
            ),
            HoyoBottomNavItem(
              icon: Symbols.analytics,
              label: l10n.tabData,
            ),
            HoyoBottomNavItem(
              icon: Symbols.person,
              label: l10n.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}
