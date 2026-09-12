import 'package:flutter/material.dart';

import 'hana_tokens.dart';

/// Atomic press-feedback wrapper.
///
/// Wraps any tappable region and animates child to `scale = 0.98` while the
/// pointer is down, returning to 1.0 on release. Duration is
/// `HanaTokens.motion.quick` (150ms) with `easeOut`.
///
/// This is the only allowed press-state visual in v2 — no color change, no
/// elevation lift, no ripple. Pure scale.
///
/// Example:
/// ```dart
/// HanaPressScale(
///   onTap: () => doThing(),
///   child: HanaCard(child: ...),
/// );
/// ```
class HanaPressScale extends StatefulWidget {
  const HanaPressScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.98,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
  });

  /// The widget being pressed.
  final Widget child;

  /// Tap callback. Press feedback runs even if null, but only fires when set.
  final VoidCallback? onTap;

  /// Optional long-press callback.
  final VoidCallback? onLongPress;

  /// Press-state scale factor. v2 spec: 0.98.
  final double scale;

  /// When false, the wrapper passes through with no animation.
  final bool enabled;

  /// Hit-test behavior — defaults to opaque so transparent regions still
  /// catch presses.
  final HitTestBehavior behavior;

  @override
  State<HanaPressScale> createState() => _HanaPressScaleState();
}

class _HanaPressScaleState extends State<HanaPressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: HanaTokens.motion.quick,
        curve: HanaTokens.motion.easeOut,
        child: widget.child,
      ),
    );
  }
}
