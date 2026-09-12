import 'package:flutter/material.dart';

import 'hana_tokens.dart';

/// HanaSwitch — v2 编辑级开关（替代 Material `Switch`）。
///
/// 28dp × 16dp 长条 + 12dp 圆形滑块。比 Material 默认更扁更安静，符合杂志
/// 栏目"小机关"语法，不喧宾夺主。off → outline @ 15%；on → primary 实填。
///
/// Spec: `docs/design/design-system/v2/components/switch.md`.
///
/// 用法：
/// ```dart
/// HanaSwitch(
///   value: settings.appLockEnabled,
///   onChanged: (v) => bloc.add(ToggleAppLock(v)),
///   semanticLabel: l10n.appLock,
/// );
/// ```
///
/// Widget test hint:
/// ```dart
/// testWidgets('HanaSwitch off renders 15% outline track',
///   (tester) async { ... });
/// testWidgets('HanaSwitch tap toggles value via onChanged',
///   (tester) async { ... });
/// ```
class HanaSwitch extends StatelessWidget {
  const HanaSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  /// 当前开关状态。
  final bool value;

  /// 切换回调。`null` → disabled（opacity 0.38）。
  final ValueChanged<bool>? onChanged;

  /// 屏幕阅读器标签。
  final String? semanticLabel;

  // 视觉常量 — 永远固定，不接受外部覆盖。
  static const double _trackWidth = 28;
  static const double _trackHeight = 16;
  static const double _thumbSize = 12;
  static const double _thumbPadding = 2;
  // 触控扩展：使总命中区 ≥ 44×44（28+16=44 / 16+28=44）。
  static const double _hitPaddingHorz = 8;
  static const double _hitPaddingVert = 14;

  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final trackColor = value
        ? HanaTokens.primary(context)
        : HanaTokens.outline(context).withValues(alpha: 0.15);
    final thumbColor = HanaTokens.onPrimary(context);

    final visual = SizedBox(
      width: _trackWidth,
      height: _trackHeight,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: HanaTokens.motion.standard,
            curve: HanaTokens.motion.easeInOut,
            width: _trackWidth,
            height: _trackHeight,
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(_trackHeight / 2),
            ),
          ),
          AnimatedAlign(
            duration: HanaTokens.motion.standard,
            curve: HanaTokens.motion.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _thumbPadding),
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                decoration: BoxDecoration(
                  color: thumbColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      toggled: value,
      enabled: _enabled,
      label: semanticLabel,
      onTap: _enabled ? () => onChanged!(!value) : null,
      child: Opacity(
        opacity: _enabled ? 1.0 : 0.38,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? () => onChanged!(!value) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _hitPaddingHorz,
              vertical: _hitPaddingVert,
            ),
            child: visual,
          ),
        ),
      ),
    );
  }
}
