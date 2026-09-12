import 'package:flutter/material.dart';

import 'hana_press_scale.dart';
import 'hana_tokens.dart';

/// HanaListItem — v2 列表项。
///
/// `surfaceContainerLowest` 实色 + 24/20 padding + 4px radius + 无边框 +
/// 无投影 + press scale 0.98。统一替换 v1 散落 14+ 处 `_SettingsCard` /
/// `_ListTileItem` / `_ButtonRowItem` 复制实现。
///
/// Spec: `docs/design/design-system/v2/components/list-item.md`.
///
/// 用法：
/// ```dart
/// HanaListItem(
///   leading: const Icon(Icons.lock_outline),
///   title: Text(l10n.appLock),
///   subtitle: Text(l10n.appLockEnabled),
///   trailing: HanaSwitch(value: true, onChanged: (v) => ...),
///   onTap: () => router.go('/lock'),
/// );
/// ```
///
/// Widget test hint:
/// ```dart
/// testWidgets('HanaListItem renders surfaceContainerLowest with 4px radius',
///   (tester) async { ... });
/// testWidgets('HanaListItem destructive paints title in error color',
///   (tester) async { ... });
/// ```
class HanaListItem extends StatelessWidget {
  const HanaListItem({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.semanticLabel,
  });

  /// 主标题（通常是 `Text`）。
  final Widget title;

  /// 可选 leading — 仅允许 outlined icon 20dp，禁止圆形容器。
  final Widget? leading;

  /// 可选 subtitle（body-sm inkSecondary）。
  final Widget? subtitle;

  /// 可选 trailing — chevron / mono 时间戳 / `HanaSwitch` 等。
  final Widget? trailing;

  /// 点击回调。`null` → item 非交互（无 press feedback）。
  final VoidCallback? onTap;

  /// true → title / leading / trailing 全部 error 朱砂色。
  final bool isDestructive;

  /// 屏幕阅读器标签覆盖。
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ink = HanaTokens.ink(context);
    final inkSec = HanaTokens.inkSecondary(context);
    final error = HanaTokens.error(context);

    final titleColor = isDestructive ? error : ink;
    final iconColor = isDestructive ? error : inkSec;

    final titleStyle = HanaTokens.typography.body.copyWith(color: titleColor);
    final subtitleStyle =
        HanaTokens.typography.bodySm.copyWith(color: inkSec);

    final body = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(size: 20, color: iconColor),
                child: leading!,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle.merge(style: titleStyle, child: title),
                  if (subtitle != null) ...[
                    SizedBox(height: HanaTokens.spacing.xs),
                    DefaultTextStyle.merge(
                      style: subtitleStyle,
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: HanaTokens.spacing.md),
              IconTheme(
                data: IconThemeData(size: 20, color: iconColor),
                child: DefaultTextStyle.merge(
                  style: HanaTokens.typography.bodySm.copyWith(color: inkSec),
                  child: trailing!,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final card = Material(
      type: MaterialType.canvas,
      color: HanaTokens.surfaceContainerLowest(context),
      borderRadius: HanaTokens.radius.card,
      elevation: 0,
      child: body,
    );

    if (onTap == null) {
      return Semantics(label: semanticLabel, child: card);
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: HanaPressScale(onTap: onTap, child: card),
    );
  }
}
