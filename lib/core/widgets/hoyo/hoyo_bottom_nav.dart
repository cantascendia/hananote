// HoYo · Glass bottom nav with 5 items + gold underline on active.
// Mirrors hoyo.css `.hoyo-bottomnav`. Per design README:
// "Material Symbols Outlined for every icon. Filled variant only when
// active/selected." We use `material_symbols_icons.Symbols.*` and
// flip the rendering `fill` axis from 0→1 on active.
// ignore_for_file: public_member_api_docs

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

class HoyoBottomNavItem {
  const HoyoBottomNavItem({
    required this.icon,
    required this.label,
    this.iconActive,
  });

  final IconData icon;

  /// Optional override icon for the active state. When null (the
  /// recommended path), the same `icon` is rendered with the
  /// Material-Symbols `fill: 1.0` axis flipped on. Pass a separate
  /// `iconActive` only when you need to switch to a structurally
  /// different glyph (e.g. Icons.person → Icons.person_outline).
  final IconData? iconActive;

  final String label;
}

class HoyoBottomNav extends StatelessWidget {
  const HoyoBottomNav({
    required this.items,
    required this.activeIndex,
    required this.onChanged,
    super.key,
  });

  final List<HoyoBottomNavItem> items;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFFF8F1).withValues(alpha: 0.72),
                const Color(0xFFFFF8F1).withValues(alpha: 0.92),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: HanaColorsV2.goldLight.withValues(alpha: 0.25),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final it = items[i];
              final active = i == activeIndex;
              return Expanded(
                child: _NavItem(
                  item: it,
                  active: active,
                  onTap: () => onChanged(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final HoyoBottomNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? HanaColors.primaryOf(context)
        : HanaColors.primaryOf(context).withValues(alpha: 0.5);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        transform: active
            ? (Matrix4.identity()..translateByDouble(0, -2, 0, 1))
            : Matrix4.identity(),
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Active glow halo behind active item.
            if (active)
              Positioned(
                bottom: -4,
                child: Container(
                  width: 60,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.bottomCenter,
                      radius: 0.8,
                      colors: [
                        const Color(0xFFFFB7C5).withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  // If iconActive is provided, switch glyph entirely;
                  // else keep the same icon and let `fill` axis carry
                  // the active visual (Material Symbols path).
                  active ? (item.iconActive ?? item.icon) : item.icon,
                  size: 22,
                  color: color,
                  fill: active ? 1.0 : 0.0,
                  weight: active ? 600 : 400,
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  style: HanaTypography.labelSm.copyWith(
                    color: color,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: 0.44,
                  ),
                ),
                if (active) ...[
                  const SizedBox(height: 2),
                  Container(
                    width: 16,
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          HanaColorsV2.goldLight,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
