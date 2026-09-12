# HanaInput

> Generated 2026-04-28 from DESIGN.md v2 + widget-pattern-inventory.md
> Lib path (Phase 5 实施): `lib/core/widgets/hana_input.dart`

## 一句话定位
v2 文本输入：**无外框、底部 1px 烟灰线 / focus 时 2px 黛蓝呼吸线**、月白底色、2px 圆角——保留 v1 仅有值得保留的细节，去掉所有 Material `OutlineInputBorder` 噪声。

## Anatomy
```
  Label · label / +0.6 tracking            ← 在输入区上方 spacing.xs (4)
  ──────────────────────────────────────
  Placeholder / value · body · ink        ← 输入区，padding 垂直 sm (8)
  ──────────────────────────────────────
  ↑ 底部 1px outline #A39E92（idle）
    focus 时 2px primary #1F3A5F 呼吸 80→0ms easeOut（保留 v1）
  Helper / error · body-sm · inkSecondary / error
```

## Variants
- **single-line** (默认): 单行
- **multiline**: 多行 textarea，`minLines: 3, maxLines: null`
- **password**: 末尾眼睛切换可见性
- **numeric**: 数字键盘 + JetBrains Mono 字体（剂量 / 数值场景）

## Props（Flutter API）
```dart
class HanaInput extends StatelessWidget {
  const HanaInput({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.variant = HanaInputVariant.singleLine,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
  });
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final HanaInputVariant variant;
  final Widget? prefixIcon;
  final Widget? suffix;
  // ...
}

enum HanaInputVariant { singleLine, multiline, password, numeric }
```

## States
- **default**: 1px outline (`HanaTokens.outline`)
- **focus**: 2px primary 呼吸线，由 1→2px 渐变 80ms（保留 v1）
- **filled** (idle 已有值): 维持 1px outline，文本 ink 实色
- **disabled**: outline 38% 不透明、文本 inkSecondary、不可点击
- **error**: 底部线变 error 色 (#9B2A2A)、errorText 显示在底部

## Tokens 引用
- background: `HanaTokens.background(context)` (月白，**不**用 surfaceContainerLowest——避免与卡内嵌套撞色)
- text: `HanaTokens.ink(context)`
- placeholder: `HanaTokens.inkSecondary(context)`
- border idle: `HanaTokens.outline(context)` 1px
- border focus: `HanaTokens.primary(context)` 2px
- border error: `HanaTokens.error(context)` 2px
- label: `body-sm` + tracking +0.6 + `inkSecondary`
- radius: `HanaTokens.radius.input` (2)
- focus 呼吸 motion: `HanaTokens.motion.instant` (80ms)
- numeric variant font: `JetBrains Mono Light`

## Do's and Don'ts
- ✅ 永远显式给 `label`（"姓名"），不依赖 placeholder 当 label
- ✅ error 出现时 helper 文本被替换，**不**两条同时显示
- ✅ 多行输入用 `multiline` variant，最小 3 行，避免视觉跳动
- ❌ `OutlineInputBorder` / 全包围 1px 边框（→ Material 痕迹）
- ❌ `filled: true` + `fillColor` 形成"灰底胶囊"
- ❌ prefix 用 emoji 或装饰图标（仅允许语义图标如搜索 / 锁）

## i18n / a11y 注意
- `Semantics(textField: true, label: label, hint: placeholder)` 必填
- 触控目标 ≥ 44dp（含 padding，外层最小高 48）
- ja 输入法 IME 高度变化时不抖动——内部用 `IntrinsicHeight` 适配
- error 文本由调用方传 `l10n.xxx`，组件层不内置任何文案

## v1 替换映射
- inventory #6「Card-style TextField」9 处：`blood_test_edit:307/331` · `measurement_edit:113/293` · `journal_edit:154` · `schedule_editor:123` · `setup:120/141` · `onboarding:319/531`
- 散落 8 处直接 `TextFormField` 用法（profile / settings / search 等）
- **迁移**: `Container(decoration: ...) > TextField(border: InputBorder.none, prefixIcon: ...)` → `HanaInput(prefixIcon: ..., variant: ...)`；`TextFormField(decoration: InputDecoration(...))` → 同上

## Flutter 实现提示
- 基于 `TextField`（不是 `TextFormField`），form 校验由调用方 Bloc/Cubit 处理后通过 `errorText` 传入（对齐 DEC-043 — i18n 在 UI 层完成）
- 底部 1/2px 线用 `Container(height: ...)` + 自身 `AnimatedContainer` 切换 1↔2，**不**用 `UnderlineInputBorder`（Material 默认 padding 太宽）
- focus 监听用 `FocusNode` + `addListener`
- numeric variant 自动注入 `keyboardType: TextInputType.numberWithOptions(decimal: true)` + `style: TextStyle(fontFamily: 'JetBrains Mono')`
