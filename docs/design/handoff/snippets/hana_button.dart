import 'package:flutter/material.dart';

import 'hana_press_scale.dart';
import 'hana_tokens.dart';

/// HanaButton variants — see `docs/design/design-system/v2/components/button.md`.
enum HanaButtonVariant {
  /// 黛蓝 solid fill + onPrimary text. Max ONE per screen.
  primary,

  /// Transparent fill + 1px primary border + primary text. The only allowed
  /// solid border in v2.
  secondary,

  /// Transparent fill + ink text — for AppBar actions / Bottom Sheet cancel.
  ghost,

  /// Transparent fill + error text — confirm dialogs only.
  destructive,
}

/// HanaButton — the v2 CTA "stamp".
///
/// 6px corner radius (NOT stadium, NOT 4, NOT 16), 44dp min height for a11y,
/// no shadow, no gradient, no elevation. Press feedback = scale 0.98 only.
///
/// Spec: `docs/design/design-system/v2/components/button.md`.
class HanaButton extends StatelessWidget {
  const HanaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = HanaButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.semanticLabel,
  });

  /// Visible label — verb-first, period-terminated ("记一次").
  final String label;

  /// Tap handler. `null` puts the button in the disabled state.
  final VoidCallback? onPressed;

  /// Visual variant.
  final HanaButtonVariant variant;

  /// Optional 16dp leading icon.
  final IconData? icon;

  /// When true, label is replaced with a 16dp inline progress indicator and
  /// the tap handler is suppressed.
  final bool isLoading;

  /// When true, the button stretches to its parent's width.
  final bool fullWidth;

  /// Accessibility label override. Defaults to [label].
  final String? semanticLabel;

  bool get _disabled => onPressed == null || isLoading;

  Color _bg(BuildContext c) {
    switch (variant) {
      case HanaButtonVariant.primary:
        return HanaTokens.primary(c);
      case HanaButtonVariant.secondary:
      case HanaButtonVariant.ghost:
      case HanaButtonVariant.destructive:
        return Colors.transparent;
    }
  }

  Color _fg(BuildContext c) {
    switch (variant) {
      case HanaButtonVariant.primary:
        return HanaTokens.onPrimary(c);
      case HanaButtonVariant.secondary:
        return HanaTokens.primary(c);
      case HanaButtonVariant.ghost:
        return HanaTokens.ink(c);
      case HanaButtonVariant.destructive:
        return HanaTokens.error(c);
    }
  }

  BoxBorder? _border(BuildContext c) {
    if (variant != HanaButtonVariant.secondary) return null;
    return Border.all(color: HanaTokens.primary(c), width: 1);
  }

  @override
  Widget build(BuildContext context) {
    final fg = _fg(context);
    final labelStyle = HanaTokens.typography.body
        .copyWith(color: fg, fontWeight: FontWeight.w500);

    final content = isLoading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                SizedBox(width: HanaTokens.spacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  style: labelStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    final box = Container(
      constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
      padding: EdgeInsets.symmetric(
        horizontal: HanaTokens.spacing.md,
        vertical: HanaTokens.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: _bg(context),
        borderRadius: HanaTokens.radius.button,
        border: _border(context),
      ),
      child: Center(child: content),
    );

    final wrapped = fullWidth
        ? SizedBox(width: double.infinity, child: box)
        : box;

    final opacity = _disabled ? 0.38 : 1.0;

    return Semantics(
      button: true,
      enabled: !_disabled,
      label: semanticLabel ?? label,
      child: Opacity(
        opacity: opacity,
        child: HanaPressScale(
          enabled: !_disabled,
          onTap: _disabled ? null : onPressed,
          child: wrapped,
        ),
      ),
    );
  }
}
