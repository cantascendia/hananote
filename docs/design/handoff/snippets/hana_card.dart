import 'package:flutter/material.dart';

import 'hana_press_scale.dart';
import 'hana_tokens.dart';

/// HanaCardVariant — see `docs/design/design-system/v2/components/card.md`.
enum HanaCardVariant {
  /// 99% scenes — surfaceContainerLowest, no shadow, no border.
  flat,

  /// Inset on a surfaceContainerHigh background — uses High color so the
  /// step against parent reads as a recess. Rare.
  inset,

  /// Tappable — flat color, but adds press scale 0.98 + onTap handler.
  tappable,
}

/// HanaCard — the v2 "interior page" container.
///
/// Layout = `surfaceContainerLowest` body, 4px radius, NO shadow, NO border.
/// Layering is communicated by surface tonal differences alone.
///
/// One card carries one full information unit (heading + body + image) —
/// magazine-spread thinking, not a stack of small cards. Use
/// `HanaTokens.spacing.lg` (32) between cards instead of dividers.
///
/// Spec: `docs/design/design-system/v2/components/card.md`.
///
/// Widget test hint:
/// ```dart
/// testWidgets('HanaCard renders surfaceContainerLowest with 4px radius',
///   (tester) async { ... });
/// testWidgets('tappable variant scales to 0.98 on press',
///   (tester) async { ... });
/// ```
class HanaCard extends StatelessWidget {
  const HanaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.variant = HanaCardVariant.flat,
    this.semanticLabel,
  });

  /// The card's content. Compose vertically with `HanaTokens.spacing.md`
  /// between paragraphs internally.
  final Widget child;

  /// Inner padding. Default = 16 (`spacing.md`). Avoid changing — the
  /// magazine grid depends on consistent inset.
  final EdgeInsetsGeometry padding;

  /// Tap handler. Setting this implicitly upgrades to `tappable` behavior
  /// (press scale + Semantics button) regardless of variant.
  final VoidCallback? onTap;

  /// Visual variant. See [HanaCardVariant].
  final HanaCardVariant variant;

  /// Accessibility label. Required when `onTap != null`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bg = variant == HanaCardVariant.inset
        ? HanaTokens.surfaceContainerHigh(context)
        : HanaTokens.surfaceContainerLowest(context);

    final card = Material(
      type: MaterialType.canvas,
      color: bg,
      borderRadius: HanaTokens.radius.card,
      // Explicitly elev-0: v2 never uses shadow on cards.
      elevation: 0,
      child: Padding(padding: padding, child: child),
    );

    final tappable = onTap != null || variant == HanaCardVariant.tappable;
    if (!tappable) {
      return card;
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: HanaPressScale(
        onTap: onTap,
        child: card,
      ),
    );
  }
}
