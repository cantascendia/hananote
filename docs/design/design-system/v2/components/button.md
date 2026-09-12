# HanaButton

> Generated 2026-04-28 from DESIGN.md v2 + widget-pattern-inventory.md
> Lib path (Phase 5 实施): `lib/core/widgets/hana_button.dart`

## 一句话定位
v2 唯一的可点击 CTA 容器：黛蓝实色 + 6px 直角、不再 stadium、不投影、不渐变——按钮是"印章"，不是"糖果"。

## Anatomy
```
┌─────────────────────────────────┐
│   [icon?]  Label (body·15)      │   高 44dp / 6px radius
└─────────────────────────────────┘
   ↑ HanaTokens.primary(context) 实色 + onPrimary 文字
```
- 内容区：可选 leading icon (16) + label
- 内边距：水平 md (16) / 垂直 sm (8)，最小高度 44dp（a11y 触控）
- 圆角：r-button = 6px（非 stadium、非 4、非 16）

## Variants
- **primary**: 黛蓝实色填充 + onPrimary 文字。**一屏 ≤ 1 个**（"一抹强色"原则）。
- **secondary**: 月白底 + 黛蓝 1px 边框 + 黛蓝文字。这是 v2 唯一允许的实线边框例外。
- **ghost**: 透明底 + 墨色文字，仅用于 AppBar action / Bottom Sheet 取消位。
- **destructive**: 朱砂 (`error`) 文字 + 透明底，仅 confirm dialog 内。

## Props（Flutter API）
```dart
class HanaButton extends StatelessWidget {
  const HanaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = HanaButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.semanticLabel,
  });
  final String label;
  final VoidCallback? onPressed;
  final HanaButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final String? semanticLabel;
}

enum HanaButtonVariant { primary, secondary, ghost, destructive }
```

## States
- **default**: 实色 / 边框 / 透明（按 variant）
- **pressed**: `motion-quick` (150ms) Scale 0.98，**不**改色
- **disabled**: 整体 38% 不透明度，`onPressed = null`
- **loading**: label 替换为 16dp `CircularProgressIndicator(strokeWidth: 2)`，颜色 = onPrimary / primary

## Tokens 引用
- background (primary): `HanaTokens.primary(context)`
- background (secondary/ghost): `Colors.transparent`
- foreground (primary): `HanaTokens.onPrimary(context)`
- foreground (secondary): `HanaTokens.primary(context)`
- foreground (ghost): `HanaTokens.ink(context)`
- foreground (destructive): `HanaTokens.error(context)`
- border (secondary): `HanaTokens.primary(context)` 1px
- radius: `HanaTokens.radius.button` (6)
- padding: 水平 `HanaTokens.spacing.md`、垂直 `HanaTokens.spacing.sm`
- press scale: `HanaTokens.motion.quick` curve `easeOut`

## Do's and Don'ts
- ✅ 一屏只一个 primary（黛蓝是"句号"）
- ✅ secondary 与 primary 不并排同高度（避免削弱主 CTA）
- ✅ label 用动词短句、句号收尾（"记一次"，不是"立即记录 →"）
- ❌ 圆角 ≥ 8px、stadium full、`shape: StadiumBorder()`
- ❌ 渐变背景、投影、`elevation > 0`
- ❌ emoji（💊✅）或装饰图标承担情感重量

## i18n / a11y 注意
- `Semantics(button: true, label: semanticLabel ?? label)` 必填
- 触控目标 ≥ 44dp（即使视觉高度 40，padding 拉到 44）
- 长文本（ja「保存しました」/ zh「保存成功」）允许换行 1 次，超出 ellipsis
- label tracking：CJK +0.4 / Latin +0（继承 body token）

## v1 替换映射
- inventory #11「Primary CTA Button (52px / 圆角 16)」5 处：`onboarding_page.dart:176/195/225` · `setup_page.dart:174` · `today_page.dart:212` · `measurement_edit_page.dart:125`
- 散落 13 处 `ElevatedButton`/`TextButton`/`FilledButton`（auth_wrapper / settings_detail / profile / journal_edit 等）
- **迁移**: `FilledButton.styleFrom(shape: RoundedRectangleBorder(radius: 16))` → `HanaButton(variant: primary)`；`TextButton(...)` → `HanaButton(variant: ghost)`

## "4px radius vs v1 stadium" 对比说明
v1 用 `borderRadius: 16` 甚至 `StadiumBorder` 营造糖果按钮——这是 Material You + 移动端 SaaS 通用语法，**不是杂志语法**。v2 收紧到 **6px**：足够柔，避免硬塑料感；又足够直，让按钮像"盖章的印章"而非"药丸"。这是 v2 与 v1 最直观的告别——一眼能认出"这不是普通 app"的视觉信号。

## Flutter 实现提示
- 基于 `Material(InkWell(...))` 而非 `FilledButton`/`TextButton`，避免被 M3 主题覆盖圆角
- 不用 `ButtonStyle`，颜色 / radius 全部 hard-roll 自 `HanaTokens`
- press scale 用 `AnimatedScale` 包裹，监听 `WidgetStatesController`
- primary variant **绝不**接受外部传入的 `backgroundColor`——黛蓝是 token 锁定的稀缺资源
