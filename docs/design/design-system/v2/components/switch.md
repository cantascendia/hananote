# HanaSwitch

> Generated 2026-04-29 from screen specs (profile / onboarding / schedule editor)
> Lib path (Phase 5 实施): `lib/core/widgets/hana_switch.dart`

## 一句话定位
v2 编辑级开关（替代 Material `Switch`）：**28dp × 16dp 长条 + 12dp 圆形滑块**——比 Material 默认更扁更安静，符合杂志栏目"小机关"语法，不喧宾夺主。

## Anatomy
```
   off:            on:
   ┌────────┐      ┌────────┐
   │ ●      │      │      ● │
   └────────┘      └────────┘
   ↑              ↑
   28×16 track    track 同尺寸
   outline @ 15%  primary 实填
   thumb 12 圆    thumb 12 圆
   onPrimary 月白 onPrimary 月白
   左偏 2px       右偏 2px
```

## Variants
- 仅一种：on / off。无 indeterminate / disabled-on 视觉变体（disabled 由 opacity 0.38 表达）。

## Props（Flutter API）
```dart
class HanaSwitch extends StatelessWidget {
  const HanaSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;  // null → disabled
  final String? semanticLabel;
}
```

## States
- **off**: track outline @ 15% / thumb 在左
- **on**: track primary 实填 / thumb 在右
- **toggling**: thumb 240ms easeInOut 平移 + track color crossfade
- **disabled**: 整体 opacity 0.38，不响应 tap

## Tokens 引用
- track off: `HanaTokens.outline(context).withValues(alpha: 0.15)`
- track on: `HanaTokens.primary(context)`
- thumb color: `HanaTokens.onPrimary(context)`（月白 #FBF8F2）
- track size: 28 × 16
- thumb size: 12
- thumb padding: 2（off → 左 2、on → 右 2）
- transition motion: `HanaTokens.motion.standard` (240ms easeInOut)

## Do's and Don'ts
- ✅ 替换 v1 全部 `Switch` / `SwitchListTile`（应用锁 / 生物识别 / 通知开关 / 提醒）
- ✅ 触控目标外层包到 ≥ 44×44（视觉 28×16，padding 拉到 44）
- ✅ disabled 仅在调用方逻辑禁用时使用（`onChanged: null`）
- ❌ 添加 active / inactive icon（v1 ✓ / × 装饰）
- ❌ 改变 thumb 形状（永远圆形 12dp）
- ❌ 用其他色（不允许 success / warning track）— 永远 outline / primary 二选一

## i18n / a11y 注意
- `Semantics(toggled: value, label: semanticLabel, onTap: enabled ? handler : null)`
- TalkBack 朗读 "已开启 / 已关闭"
- 触控外层 `GestureDetector(behavior: opaque)` 拉到 44×44 触控区
- 颜色对比：track on (primary #1F3A5F) vs thumb (#FBF8F2) 对比 11.4:1 (AAA)

## v1 替换映射
- `profile_page.dart` 「应用锁」 / 「生物识别」 Switch
- `notification_settings.dart` 各类提醒 Switch
- `schedule_editor.dart` 「启用提醒」Switch
- `onboarding/setup_page.dart` 「启用同步」可选 Switch
- **迁移**: `Switch(value: x, onChanged: ..., activeColor: HanaColors.primary)` → `HanaSwitch(value: x, onChanged: ...)`；`SwitchListTile` 拆为 `HanaListItem(trailing: HanaSwitch(...))`

## Flutter 实现提示
- 自实现，**不**继承 `Switch` 或 `CupertinoSwitch`（默认尺寸和形状不可控）
- 用 `AnimatedContainer` 处理 track 颜色 crossfade，`AnimatedAlign(alignment: value ? right : left)` 处理 thumb 平移
- 外层包 `GestureDetector(onTap: () => onChanged?.call(!value))` + `Semantics(toggled: value)`
- 不接受 trackColor / thumbColor 外部覆盖 — 颜色完全锁定
- 触控扩展用 `Padding(padding: EdgeInsets.all(14))` 包视觉 → 总 56×44 触控（满足 44dp 最低）
