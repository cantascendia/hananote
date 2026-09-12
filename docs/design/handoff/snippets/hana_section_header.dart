import 'package:flutter/material.dart';

import 'hana_tokens.dart';

/// HanaSectionHeader — v2 章节横幅。
///
/// 4px 黛蓝竖线（高度 = 标题首行 line-height）+ label-md inkSecondary +0.6
/// 横幅。是杂志页"段落标记"语法，不是分隔符。每屏 ≤ 3 处出现，是黛蓝稀缺
/// 资源的合规消耗位之一。
///
/// Spec: `docs/design/design-system/v2/components/section-header.md`.
///
/// 用例：Today 「当前 / 之后」/ Profile 5 节标题 / Record 三栏目 / Data
/// 章节 / Timeline sticky 月份。
///
/// Widget test hint:
/// ```dart
/// testWidgets('HanaSectionHeader renders 4px primary bar at line-height 16',
///   (tester) async { ... });
/// testWidgets('HanaSectionHeader divider renders 1px outline @ 8% when true',
///   (tester) async { ... });
/// ```
class HanaSectionHeader extends StatelessWidget {
  const HanaSectionHeader({
    super.key,
    required this.label,
    this.trailing,
    this.divider = false,
    this.semanticLabel,
  });

  /// 标题文案 — 必须来自 ARB（"数据" / "隐私" / "当前" / "之后"）。
  final String label;

  /// 可选 trailing widget（mono 时间戳 / chevron / 操作按钮）。
  final Widget? trailing;

  /// 是否在下方加 1px outline @ 8% 分割线。仅 sticky 场景使用。
  final bool divider;

  /// 屏幕阅读器标签覆盖。
  final String? semanticLabel;

  // 标题首行 line-height — 与 typography.label 的 16/12 line-height 对齐。
  static const double _barHeight = 16;
  static const double _barWidth = 4;

  @override
  Widget build(BuildContext context) {
    final labelStyle = HanaTokens.typography.label.copyWith(
      color: HanaTokens.inkSecondary(context),
    );

    return Semantics(
      header: true,
      label: semanticLabel ?? label,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          HanaTokens.spacing.lg,
          HanaTokens.spacing.sm,
          HanaTokens.spacing.md,
          HanaTokens.spacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: _barWidth,
                  height: _barHeight,
                  color: HanaTokens.primary(context),
                ),
                SizedBox(width: HanaTokens.spacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: labelStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (divider) ...[
              SizedBox(height: HanaTokens.spacing.sm),
              Container(
                height: 1,
                color: HanaTokens.outline(context).withValues(alpha: 0.08),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
