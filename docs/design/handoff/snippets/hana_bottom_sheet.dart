import 'package:flutter/material.dart';

import 'hana_tokens.dart';

/// 顶部圆角硬编码常量。v2 中**唯一**保留的 16px 大圆角例外（手账握持感）。
const double kHanaBottomSheetRadius = 16;

/// HanaBottomSheet — v2 默认弹层语法（替代 iOS / AlertDialog）。
///
/// 从底部升起的"小册子"，顶部 16px 圆角、底角直角、`surfaceContainerLowest`
/// 背景、`elev-high` 浅阴影、`ink @ 32%` scrim。
///
/// Spec: `docs/design/design-system/v2/components/bottom-sheet.md`.
///
/// 用法：
/// ```dart
/// final result = await HanaBottomSheet.show<String>(
///   context,
///   title: '选择操作',
///   child: ...,
/// );
/// ```
///
/// Widget test hint:
/// ```dart
/// testWidgets('HanaBottomSheet has 16px top radius and square bottom',
///   (tester) async { ... });
/// testWidgets('HanaBottomSheet exposes scopesRoute semantics',
///   (tester) async { ... });
/// ```
class HanaBottomSheet extends StatelessWidget {
  const HanaBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showHandle = true,
    this.maxHeightFraction = 0.85,
  });

  /// 顶部标题（headline 24）。
  final String title;

  /// 主内容。允许内部 `SingleChildScrollView` —— 外层不滚动。
  final Widget child;

  /// 底部操作区（通常是若干 `HanaButton`），可选。
  final List<Widget>? actions;

  /// 是否显示顶部 32×4 drag handle。
  final bool showHandle;

  /// 屏高占比上限。默认 0.85。
  final double maxHeightFraction;

  /// 静态入口 — 强制走自定义 shape + scrim，避免 M3 主题污染。
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    List<Widget>? actions,
    bool showHandle = true,
    bool isDismissible = true,
    double maxHeightFraction = 0.85,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: HanaTokens.ink(context).withValues(alpha: 0.32),
      transitionAnimationController: null,
      builder: (ctx) => HanaBottomSheet(
        title: title,
        actions: actions,
        showHandle: showHandle,
        maxHeightFraction: maxHeightFraction,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxH = mq.size.height * maxHeightFraction;

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: title,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Material(
          type: MaterialType.canvas,
          color: HanaTokens.surfaceContainerLowest(context),
          elevation: 0,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(kHanaBottomSheetRadius),
          ),
          // v2 唯一允许 shadow 的场景。opacity ≤ 6%，ink 采样。
          shadowColor: HanaTokens.ink(context).withValues(alpha: 0.06),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showHandle)
                  Padding(
                    padding: EdgeInsets.only(top: HanaTokens.spacing.sm),
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: HanaTokens.outline(context)
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    HanaTokens.spacing.md,
                    HanaTokens.spacing.lg,
                    HanaTokens.spacing.md,
                    HanaTokens.spacing.md,
                  ),
                  child: Text(
                    title,
                    style: HanaTokens.typography.headline.copyWith(
                      color: HanaTokens.ink(context),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: HanaTokens.spacing.md,
                    ),
                    child: SingleChildScrollView(child: child),
                  ),
                ),
                if (actions != null && actions!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      HanaTokens.spacing.md,
                      HanaTokens.spacing.lg,
                      HanaTokens.spacing.md,
                      HanaTokens.spacing.lg,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (var i = 0; i < actions!.length; i++) ...[
                          if (i > 0) SizedBox(width: HanaTokens.spacing.md),
                          actions![i],
                        ],
                      ],
                    ),
                  )
                else
                  SizedBox(height: HanaTokens.spacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
