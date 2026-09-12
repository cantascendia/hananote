import 'package:flutter/material.dart';

import 'hana_tokens.dart';

/// HanaLoadingVariant — see `docs/design/design-system/v2/components/loading.md`.
enum HanaLoadingVariant {
  /// size 24，padding 0，嵌入按钮 / 行内文本之间。
  inline,

  /// size 32，居中 + 上下 spacing.lg padding（默认）。
  block,

  /// size 48，居中 + 占满父容器。
  page,

  /// page + scrim ink @ 16%（覆盖式异步操作）。
  overlay,
}

/// HanaLoadingView — v2 加载态。
///
/// 一个细线圆环 + 可选一行陈述。不用 shimmer，不用骨架屏。颜色二选一：
/// `ink @ 70%`（默认）或 `primary`（仅"主操作进行中"，黛蓝是稀缺资源）。
///
/// Spec: `docs/design/design-system/v2/components/loading.md`.
///
/// Widget test hint:
/// ```dart
/// testWidgets('HanaLoadingView block variant renders 32dp ring',
///   (tester) async { ... });
/// testWidgets('HanaLoadingView useSliverFill returns SliverFillRemaining',
///   (tester) async { ... });
/// ```
class HanaLoadingView extends StatelessWidget {
  const HanaLoadingView({
    super.key,
    this.variant = HanaLoadingVariant.block,
    this.message,
    this.useAccent = false,
    this.useSliverFill = false,
    this.semanticLabel,
  });

  /// 视觉变体。见 [HanaLoadingVariant]。
  final HanaLoadingVariant variant;

  /// 可选消息文本（来自 ARB）。仅在加载预期 > 1s 时使用。
  final String? message;

  /// true → 黛蓝色（仅"主操作进行中"）；false → ink @ 70%。
  final bool useAccent;

  /// true → 自动包 `SliverFillRemaining`（用于 `CustomScrollView` 内）。
  final bool useSliverFill;

  /// 屏幕阅读器标签覆盖。
  final String? semanticLabel;

  double get _size {
    switch (variant) {
      case HanaLoadingVariant.inline:
        return 24;
      case HanaLoadingVariant.block:
        return 32;
      case HanaLoadingVariant.page:
      case HanaLoadingVariant.overlay:
        return 48;
    }
  }

  double get _strokeWidth =>
      (variant == HanaLoadingVariant.page ||
              variant == HanaLoadingVariant.overlay)
          ? 2.5
          : 2.0;

  @override
  Widget build(BuildContext context) {
    final color = useAccent
        ? HanaTokens.primary(context)
        : HanaTokens.ink(context).withValues(alpha: 0.7);

    final ring = SizedBox(
      width: _size,
      height: _size,
      child: CircularProgressIndicator(
        strokeWidth: _strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );

    final inner = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ring,
        if (message != null) ...[
          SizedBox(height: HanaTokens.spacing.md),
          Text(
            message!,
            style: HanaTokens.typography.bodySm.copyWith(
              color: HanaTokens.inkSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    final semantic = Semantics(
      label: semanticLabel ?? message ?? 'Loading',
      liveRegion: true,
      child: inner,
    );

    switch (variant) {
      case HanaLoadingVariant.inline:
        return semantic;

      case HanaLoadingVariant.block:
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: HanaTokens.spacing.lg),
            child: semantic,
          ),
        );

      case HanaLoadingVariant.page:
        if (useSliverFill) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: semantic),
          );
        }
        return Center(child: semantic);

      case HanaLoadingVariant.overlay:
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: HanaTokens.ink(context).withValues(alpha: 0.16),
              ),
            ),
            Center(child: semantic),
          ],
        );
    }
  }
}
