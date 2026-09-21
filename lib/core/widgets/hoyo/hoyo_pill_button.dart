// HoYo · Pill button — primary / gold / ghost / ghost-light variants.
// Mirrors hoyo.css `.btn-pill`.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_gradients_v2.dart';
import 'package:hananote/app/theme/hana_shadows_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

enum HoyoPillVariant { primary, gold, ghost, ghostLight }

class HoyoPillButton extends StatefulWidget {
  const HoyoPillButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.variant = HoyoPillVariant.primary,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final HoyoPillVariant variant;
  final bool expand;

  @override
  State<HoyoPillButton> createState() => _HoyoPillButtonState();
}

class _HoyoPillButtonState extends State<HoyoPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final (bg, fg, shadow, border) = _resolveStyle(context);

    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 16, color: fg),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.label,
              style: HanaTypography.labelLg.copyWith(
                color: fg,
                letterSpacing: 0.56,
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            gradient: bg is Gradient ? bg : null,
            color: bg is Color ? bg : null,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: shadow,
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }

  // (background, foreground, shadow, border)
  (Object bg, Color fg, List<BoxShadow>? shadow, Border? border) _resolveStyle(
      BuildContext c) {
    switch (widget.variant) {
      case HoyoPillVariant.primary:
        return (
          const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFB7C5), Color(0xFFC892B0)],
          ),
          Colors.white,
          HanaShadowsV2.fab,
          null,
        );
      case HoyoPillVariant.gold:
        return (
          HanaGradientsV2.gold,
          HanaColorsV2.plumDeep,
          HanaShadowsV2.glowGold,
          null,
        );
      case HoyoPillVariant.ghost:
        return (
          HanaColorsV2.pearl.withValues(alpha: 0.08),
          HanaColorsV2.pearl,
          null,
          Border.all(
            color: HanaColorsV2.goldLight.withValues(alpha: 0.4),
          ),
        );
      case HoyoPillVariant.ghostLight:
        return (
          HanaColors.surfaceContainerLowOf(c),
          HanaColors.onSurfaceOf(c),
          null,
          null,
        );
    }
  }
}
