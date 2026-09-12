<!--
ARCHIVED 2026-04-29 (Phase 5 cleanup)

This v1-flavored stub has been superseded by the canonical v2 component:

  -> docs/design/design-system/v2/components/input.md   (HanaInput)

Both files specced essentially the same anatomy (label-md ink-secondary +
底部 1px 烟灰 / 2px 黛蓝 focus 呼吸线 + 2px radius + body-sm helper/error),
but the canonical v2 doc is `input.md` (`HanaInput`). All v2 屏 spec
(today / record / onboarding / schedule-editor / inventory restock /
add-drug / data add-report / journal-edit) reference `HanaInput` and its
`singleLine / multiline / numeric` variants. The `numberDecimal large`
variant called out in schedule-editor/handoff.md §2 lives on `HanaInput`,
not `HanaTextField`.

DO NOT IMPLEMENT FROM THIS FILE. It is preserved for diff archaeology only.
Original content below as-is.
-->

# HanaTextField

> Generated 2026-04-28 from candidate-A + widget-pattern-inventory.md
> Replaces: 9 处自定义 `_CardWrapper` 包 TextField（blood_test_edit / measurement_edit / journal_edit / schedule_editor / setup / onboarding 等，Top widget pattern #6）
> Lib path (Phase 5 待实施): `lib/core/widgets/hana_text_field.dart`

## Anatomy

```
HanaTextField
├── Text (label, label-md ink-secondary, tracking +0.6, 浮起到顶部 240ms 当 focus or hasValue)
├── Stack
│   ├── Container (bg surfaceContainerLowest #FBF8F2, radius r-1 2px, padding 16/12)
│   │   └── Row
│   │       ├── Icon? (prefix, 1.5px stroke, ink-secondary)
│   │       ├── EditableText (body, ink #1C1A18, caret 黛蓝 #1F3A5F)
│   │       └── Icon? (suffix, optional)
│   └── Positioned bottom 0
│       └── Container 2px line (default outline #A39E92 @ 30%, focus 黛蓝 #1F3A5F 100%, error 朱砂 #9B2A2A 100%)
└── Text? (helper / errorText, body-sm 淡墨 / 朱砂)
```

**视觉关键**：方向 A 拒绝 Material `OutlineInputBorder`——那是矩形包裹感太强。改用**底层色块（surfaceContainerLowest）+ 底部 1px 烟灰呼吸线**。focus 时底线变 2px 黛蓝并伴随 240ms 渐变（"呼吸"动效）。label 平时显示在输入框上方，无浮起；这是杂志表单语言。

## Variants

| Variant | 用途 | 视觉 |
|---------|------|------|
| singleLine | 默认 | 单行 + 底层色块 + 底部呼吸线 |
| multiline | 日记 / 备注 | min 4 行 + 自动撑高 + 同样底色 |
| numeric | 剂量 / 数值 | 单行 + JetBrains Mono Light 等宽数字 + 单位 suffix |
| password | PIN / 密码 | obscureText + suffix 眼睛切换 |

## States

| State | 视觉 | 触发 |
|-------|------|------|
| default | 底色 + 1px 烟灰 30% 底线 | — |
| focus | 底线 2px 黛蓝 100% + 240ms ease-out | onFocus |
| filled | 同 default + ink 100% 文字 | hasValue |
| error | 底线 2px 朱砂 + helperText 朱砂 | errorText 非空 |
| disabled | opacity(0.4) + 底色 surfaceContainerHigh | enabled=false |
| readonly | 同 default 但无 caret + tap 不弹键盘 | readOnly=true（如日期触发器） |

## Sizes

| Size | Height (single) | Padding | Type |
|------|-----------------|---------|------|
| sm | 40 | 12/8 | body-sm |
| md | 48 | 16/12 | body |
| lg | 56 | 20/16 | body-lg |

## API（Flutter）

```dart
class HanaTextField extends StatelessWidget {
  const HanaTextField({
    super.key,
    required this.controller,
    this.label,
    this.helperText,
    this.errorText,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.variant = HanaTextFieldVariant.singleLine,
    this.size = HanaTextFieldSize.md,
  });

  final TextEditingController controller;
  final String? label;
  final String? helperText;
  final String? errorText;
  final String? placeholder;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final HanaTextFieldVariant variant;
  final HanaTextFieldSize size;
}

enum HanaTextFieldVariant { singleLine, multiline, numeric, password }
enum HanaTextFieldSize { sm, md, lg }
```

## Tokens 引用
- bg: `HanaTokens.surfaceContainerLowest` (#FBF8F2)
- text fg: `HanaTokens.ink` (#1C1A18)
- placeholder fg: `HanaTokens.inkSecondary` (#5E5A52)
- caret: `HanaTokens.accent` (#1F3A5F)
- line default: `HanaTokens.outline` (#A39E92) @ 30%
- line focus: `HanaTokens.accent` 2px
- line error: `HanaTokens.error` (#9B2A2A)
- radius: `HanaRadius.input` = 2 (r-1)
- type: `HanaType.body` for input / `HanaType.labelMd` for label / `HanaType.bodySm` for helper
- numeric type: `HanaType.mono` (JetBrains Mono Light)
- motion: `HanaMotion.quick` = 240ms ease-out for line transition

## Do's
- placeholder 文字短促克制（"随便写。" / "数值。"）
- numeric variant 配合 `keyboardType: TextInputType.numberWithOptions(decimal: true)`
- multiline 配合 `textInputAction: TextInputAction.newline`，禁止回车提交
- errorText 句末加全角句号（"格式不对。"）

## Don'ts
- 不要圆角 ≥ 4px（与 r-1 = 2px 冲突，破坏纸感）
- 不要给输入框加四边边框（破坏底层色块美学）
- 不要在 placeholder 里写"请输入..."（v1 调性）
- 不要让 label 浮动到输入框内（Material floating label 不用）

## i18n 注意
- label / placeholder / helperText / errorText 全部由调用方传 ARB
- 中文输入推荐 `keyboardType: TextInputType.multiline` 防止顿号被吞
- numeric variant 在中日文环境下保持半角阿拉伯数字（mono 字体已保证）
- maxLength 警告（如 256 字日记）配合 `helperText: l10n.charactersRemaining(remaining)`

## a11y
- `Semantics(textField: true, label: label, hint: placeholder, value: controller.text)` 自动
- focus 时底线 2px 黛蓝同时通知屏幕阅读器（liveRegion 不需，TextField 自动）
- 触控目标 ≥ 44dp（size=sm 时高 40px，外层 padding 自动补足）
- 颜色 contrast：ink #1C1A18 on bg #FBF8F2 = 14.6:1 (AAA)；底线 黛蓝 vs 月白 = 7.8:1 (AAA)
- error 时配合 `Semantics(liveRegion: true)` 让屏幕阅读器朗读 errorText

## 工程实现提示
- 不用 Material 的 `TextField` 默认装饰，但底层仍可用 `TextField` widget + `InputDecoration(border: InputBorder.none, isDense: true)`
- 底部呼吸线用 `AnimatedContainer(duration: 240ms, height: focused ? 2 : 1, color: ...)` 或 `AnimatedAlign + AnimatedContainer`
- focus 监听用 `FocusNode` + `addListener`
- multiline 自动撑高用 `maxLines: null` + `minLines: 4`
- numeric variant 内部用 `inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]`
