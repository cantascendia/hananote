import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hana_tokens.dart';

/// Pre-fade silence — the "screen pauses" beat before the message appears.
const Duration kHanaCelebrationSilence = Duration(milliseconds: 400);

/// HanaCelebration — v2 "今日已记。" ritual feedback.
///
/// Replaces v1 `PetalCelebration`. The user feels the silence first, then a
/// single line of 黛蓝 serif text fades in, holds, fades out. No particles,
/// no gradient, no sound, no blocking.
///
/// Total duration ≈ 3.4s:
///   silence 400ms → fade-in 1200ms → hold 600ms → fade-out 1200ms
///
/// Singleton: a second `show` cancels the previous overlay so triggers never
/// stack. The decoration is wrapped in `IgnorePointer` so the user can keep
/// interacting with content underneath.
///
/// Spec: `docs/design/design-system/v2/components/celebration.md`.
class HanaCelebration {
  HanaCelebration._();

  static OverlayEntry? _entry;
  static _HanaCelebrationOverlayState? _activeState;

  /// Trigger the ritual. The caller supplies the localized [message]
  /// (typically `AppLocalizations.of(context)!.celebrationRecorded`).
  ///
  /// When [haptic] is true (default), `HapticFeedback.lightImpact()` fires
  /// at t=0. Pass `false` to honor a user setting.
  static void show(
    BuildContext context, {
    String message = '今日已记。',
    bool haptic = true,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // Drop any in-flight celebration.
    _dispose();

    if (haptic) {
      HapticFeedback.lightImpact();
    }

    final entry = OverlayEntry(
      builder: (_) => _HanaCelebrationOverlay(
        message: message,
        onMounted: (state) => _activeState = state,
        onComplete: _dispose,
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  static void _dispose() {
    _activeState?.cancel();
    _activeState = null;
    _entry?.remove();
    _entry = null;
  }
}

class _HanaCelebrationOverlay extends StatefulWidget {
  const _HanaCelebrationOverlay({
    required this.message,
    required this.onMounted,
    required this.onComplete,
  });

  final String message;
  final ValueChanged<_HanaCelebrationOverlayState> onMounted;
  final VoidCallback onComplete;

  @override
  State<_HanaCelebrationOverlay> createState() =>
      _HanaCelebrationOverlayState();
}

class _HanaCelebrationOverlayState extends State<_HanaCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  // Total = 400 (silence) + 1200 (in) + 600 (hold) + 1200 (out) = 3400ms.
  static const Duration _total = Duration(milliseconds: 3400);

  late final AnimationController _controller;
  late final Animation<double> _opacity;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    widget.onMounted(this);
    _controller = AnimationController(vsync: this, duration: _total);

    // Fractions of the total timeline.
    const silence = 400 / 3400; // 0.1176
    const fadeInEnd = (400 + 1200) / 3400; // 0.4706
    const holdEnd = (400 + 1200 + 600) / 3400; // 0.6471

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: silence * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: (fadeInEnd - silence) * 100,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: (holdEnd - fadeInEnd) * 100,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.linear)),
        weight: (1.0 - holdEnd) * 100,
      ),
    ]).animate(_controller);

    _controller.forward().whenComplete(() {
      if (!_cancelled && mounted) widget.onComplete();
    });
  }

  void cancel() {
    _cancelled = true;
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top + HanaTokens.spacing.xl;

    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, _) {
          final o = _opacity.value;
          return Stack(
            children: [
              // 95% paper-tinted backdrop (does NOT block taps).
              Positioned.fill(
                child: Container(
                  color: HanaTokens.background(context)
                      .withValues(alpha: 0.95 * o),
                ),
              ),
              Positioned(
                top: topPad,
                left: HanaTokens.spacing.lg,
                right: HanaTokens.spacing.lg,
                child: Opacity(
                  opacity: o,
                  child: Semantics(
                    liveRegion: true,
                    label: widget.message,
                    child: Text(
                      widget.message,
                      style: HanaTokens.typography.displayMd.copyWith(
                        color: HanaTokens.primary(context),
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
