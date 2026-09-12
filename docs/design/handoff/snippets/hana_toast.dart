import 'dart:async';

import 'package:flutter/material.dart';

import 'hana_tokens.dart';

/// HanaToastVariant — see `docs/design/design-system/v2/components/toast.md`.
enum HanaToastVariant {
  /// surfaceContainerHigh + ink 文字。
  info,

  /// primary 黛蓝 + onPrimary 文字。
  success,

  /// error 朱砂 + onPrimary 文字（自动延长到 5s）。
  error,

  /// warning 香灰 + onPrimary 文字。
  warning,
}

/// HanaToast — v2 短暂反馈（替代 SnackBar）。
///
/// 从底部升起的"便签条"，4px 圆角、无投影、3 秒自动消失、不阻塞操作。
/// 同屏只允许 1 个 toast — 新 toast 立即替换旧的（不堆叠）。
///
/// Spec: `docs/design/design-system/v2/components/toast.md`.
///
/// Widget test hint:
/// ```dart
/// testWidgets('HanaToast.show inserts a single overlay entry',
///   (tester) async { ... });
/// testWidgets('HanaToast error variant extends duration to 5s',
///   (tester) async { ... });
/// ```
class HanaToast {
  HanaToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  /// 显示 toast。新 toast 立即替换旧的。
  static void show(
    BuildContext context, {
    required String message,
    HanaToastVariant variant = HanaToastVariant.info,
    Duration? duration,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    String? semanticLabel,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _dismiss();

    final effectiveDuration = duration ??
        (variant == HanaToastVariant.error
            ? const Duration(seconds: 5)
            : const Duration(seconds: 3));

    final entry = OverlayEntry(
      builder: (ctx) => _HanaToastOverlay(
        message: message,
        variant: variant,
        icon: icon,
        actionLabel: actionLabel,
        onAction: () {
          onAction?.call();
          _dismiss();
        },
        semanticLabel: semanticLabel,
      ),
    );
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(effectiveDuration, _dismiss);
  }

  /// 立即关闭当前 toast（如有）。
  static void dismiss(BuildContext context) => _dismiss();

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _HanaToastOverlay extends StatefulWidget {
  const _HanaToastOverlay({
    required this.message,
    required this.variant,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.semanticLabel,
  });

  final String message;
  final HanaToastVariant variant;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? semanticLabel;

  @override
  State<_HanaToastOverlay> createState() => _HanaToastOverlayState();
}

class _HanaToastOverlayState extends State<_HanaToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: HanaTokens.motion.standard,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _bg(BuildContext c) {
    switch (widget.variant) {
      case HanaToastVariant.info:
        return HanaTokens.surfaceContainerHigh(c);
      case HanaToastVariant.success:
        return HanaTokens.primary(c);
      case HanaToastVariant.error:
        return HanaTokens.error(c);
      case HanaToastVariant.warning:
        return HanaTokens.warning(c);
    }
  }

  Color _fg(BuildContext c) {
    return widget.variant == HanaToastVariant.info
        ? HanaTokens.ink(c)
        : HanaTokens.onPrimary(c);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final fg = _fg(context);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: HanaTokens.motion.easeInOut,
    );

    return Positioned(
      left: HanaTokens.spacing.md,
      right: HanaTokens.spacing.md,
      bottom: mq.padding.bottom + HanaTokens.spacing.md,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: Semantics(
            liveRegion: true,
            label: widget.semanticLabel ?? widget.message,
            child: Material(
              type: MaterialType.canvas,
              color: _bg(context),
              borderRadius: HanaTokens.radius.card,
              elevation: 0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: HanaTokens.spacing.md,
                    vertical: HanaTokens.spacing.sm,
                  ),
                  child: Row(
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 16, color: fg),
                        SizedBox(width: HanaTokens.spacing.sm),
                      ],
                      Expanded(
                        child: Text(
                          widget.message,
                          style: HanaTokens.typography.bodySm
                              .copyWith(color: fg),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.actionLabel != null) ...[
                        SizedBox(width: HanaTokens.spacing.sm),
                        ConstrainedBox(
                          constraints:
                              const BoxConstraints(minHeight: 44, minWidth: 44),
                          child: TextButton(
                            onPressed: widget.onAction,
                            style: TextButton.styleFrom(
                              foregroundColor: fg,
                              padding: EdgeInsets.symmetric(
                                horizontal: HanaTokens.spacing.sm,
                              ),
                            ),
                            child: Text(
                              widget.actionLabel!,
                              style: HanaTokens.typography.label
                                  .copyWith(color: fg),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
