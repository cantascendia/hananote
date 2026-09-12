import 'package:flutter/material.dart';

import 'hana_tokens.dart';

/// HanaEmptyStateVariant — see `docs/design/design-system/v2/components/empty-state.md`.
enum HanaEmptyStateVariant {
  /// 嵌入列表 / 卡片内的空态，紧凑（title 18 + 无 message）。
  list,

  /// 整页空态（title 24 + 可选 message + 可选 action）。
  page,

  /// 卡片内极简空态 — 仅一行 body-sm 文案。
  inline,
}

/// HanaEmptyState — v2 空数据态。
///
/// 一行宋体陈述 + 大量留白 + 可选 CTA，没有大圆图标背景圆，没有"快去添加吧 →"
/// 的鼓励文案——杂志的「本期空白。」语法。
///
/// Spec: `docs/design/design-system/v2/components/empty-state.md`.
///
/// Widget test hint:
/// ```dart
/// testWidgets('HanaEmptyState page variant uses headline + 32dp icon',
///   (tester) async { ... });
/// testWidgets('HanaEmptyState inline variant renders only body-sm text',
///   (tester) async { ... });
/// ```
class HanaEmptyState extends StatelessWidget {
  const HanaEmptyState({
    super.key,
    required this.title,
    this.icon,
    this.message,
    this.action,
    this.variant = HanaEmptyStateVariant.page,
    this.semanticLabel,
  });

  /// 标题文案 — 必须来自 ARB（"本期空白。" / "尚无记录。"）。
  final String title;

  /// 可选的单色线性图标。`variant.inline` 时被忽略。
  final IconData? icon;

  /// 可选副文。仅 `variant.page` 显示。
  final String? message;

  /// 可选 action — 通常是一个 `HanaButton`。
  final Widget? action;

  /// 视觉变体。见 [HanaEmptyStateVariant]。
  final HanaEmptyStateVariant variant;

  /// 屏幕阅读器标签覆盖。默认使用 [title]。
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (variant == HanaEmptyStateVariant.inline) {
      return Semantics(
        label: semanticLabel ?? title,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: HanaTokens.spacing.md),
          child: Text(
            title,
            style: HanaTokens.typography.bodySm.copyWith(
              color: HanaTokens.inkSecondary(context),
            ),
          ),
        ),
      );
    }

    final isPage = variant == HanaEmptyStateVariant.page;
    final titleStyle = isPage
        ? HanaTokens.typography.headline
        : HanaTokens.typography.title;

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 32,
            color: HanaTokens.ink(context).withValues(alpha: 0.6),
          ),
          SizedBox(height: HanaTokens.spacing.lg),
        ],
        Text(
          title,
          style: titleStyle.copyWith(color: HanaTokens.ink(context)),
        ),
        if (isPage && message != null) ...[
          SizedBox(height: HanaTokens.spacing.sm),
          Text(
            message!,
            style: HanaTokens.typography.bodySm.copyWith(
              color: HanaTokens.inkSecondary(context),
            ),
          ),
        ],
        if (isPage && action != null) ...[
          SizedBox(height: HanaTokens.spacing.lg),
          action!,
        ],
      ],
    );

    final padded = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: HanaTokens.spacing.lg,
        vertical: isPage ? HanaTokens.spacing.xl : HanaTokens.spacing.lg,
      ),
      child: column,
    );

    return Semantics(
      label: semanticLabel ?? title,
      hint: message,
      child: isPage
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: padded,
              ),
            )
          : padded,
    );
  }
}
