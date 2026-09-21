// HoYo · Glass app bar (sticky, 56px) with floral brand wordmark.
// Mirrors hoyo.css `.hoyo-appbar`.
// ignore_for_file: public_member_api_docs

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

class HoyoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HoyoAppBar({
    super.key,
    this.title = '花笺',
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.dark = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool dark;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final bg = dark
        ? HanaColorsV2.nightSakura.withValues(alpha: 0.7)
        : const Color(0xFFFFF8F1).withValues(alpha: 0.78);
    final borderColor = dark
        ? HanaColorsV2.goldLight.withValues(alpha: 0.18)
        : HanaColorsV2.goldLight.withValues(alpha: 0.18);

    return SafeArea(
      bottom: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: bg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                // Leading: explicit 38px box for the default _IconBtn,
                // but caller-provided widgets size themselves.
                if (leading != null)
                  leading!
                else
                  _IconBtn(icon: Icons.menu, dark: dark, onTap: () {}),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_florist,
                            size: 16,
                            color: dark
                                ? HanaColorsV2.goldLight
                                : HanaColors.primaryOf(context),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: HanaTypography.titleMd.copyWith(
                                color: dark
                                    ? HanaColorsV2.champagneSoft
                                    : HanaColors.primaryOf(context),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.32,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: HanaTypography.labelSm.copyWith(
                              color: dark
                                  ? HanaColorsV2.pearl.withValues(alpha: 0.6)
                                  : HanaColors.onSurfaceVariantOf(context),
                              letterSpacing: 1.32,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Trailing: actions size themselves; default icon when empty.
                if (actions.isEmpty)
                  _IconBtn(
                    icon: Icons.notifications_outlined,
                    dark: dark,
                    onTap: () {},
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: actions,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.dark, required this.onTap});

  final IconData icon;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dark
              ? HanaColorsV2.pearl.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.6),
          border: Border.all(
            color: HanaColorsV2.goldLight.withValues(alpha: dark ? 0.3 : 0.3),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: dark ? HanaColorsV2.pearl : HanaColors.primaryOf(context),
        ),
      ),
    );
  }
}
