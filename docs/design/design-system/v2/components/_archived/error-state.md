<!--
ARCHIVED 2026-04-29 (Phase 5 cleanup)

This v1-flavored stub has been folded into two canonical v2 component specs:

  -> docs/design/design-system/v2/components/empty-state.md   (HanaEmptyState — page / inline 空态)
  -> docs/design/design-system/v2/components/toast.md         (HanaToast — error variant for transient feedback)

The v2 model splits "error" by duration & weight: long-lived blocking errors
become an `HanaEmptyState` variant ("载入失败。请下拉刷新。" + ghost retry,
朱砂 only on the icon stroke); short-lived transient errors (save / export /
PIN mismatch) flash through `HanaToast.error`. There is no longer a standalone
`HanaErrorState` widget — the editorial / inline / banner variants enumerated
below were collapsed during the v2 design language pass.

DO NOT IMPLEMENT FROM THIS FILE. It is preserved for diff archaeology only.
Original content below as-is.
-->

# HanaErrorState

> Generated 2026-04-28 from candidate-A + widget-pattern-inventory.md
> Replaces: 6 处 error inline 实现（`_PhotoErrorState` / today_page inline / profile_page inline / timeline text-only 等，Top widget pattern #3）
> Lib path (Phase 5 待实施): `lib/core/widgets/hana_error_state.dart`

## Anatomy

```
HanaErrorState (Padding s-xl 64 horizontal, Center)
└── Column (crossAxisAlignment.start, gap = s-lg 32)
    ├── Icon (line, 32px, 1.5px stroke, error #9B2A2A 朱砂)
    ├── Text title (display 32/42 衬线 ink #1C1A18, "出了点状况。")
    ├── Text message (body 15/24 淡墨 #5E5A52, 解释 + 句号)
    └── HanaButton (variant=secondary, label="再试一次")
```

**视觉关键**：方向 A 的核心冷暖唯一对峙——朱砂 `#9B2A2A` 是整个设计系统中唯一允许的暖色，仅用于错误图标的描边。其余文字仍墨色 + 淡墨，**不要让整页变红**——这是杂志而非警报中心。重试按钮用 secondary（黛蓝边框）而非 primary，因为重试不是核心 CTA，是恢复路径。

## Variants

| Variant | 用途 | 视觉 |
|---------|------|------|
| editorial | 整页错误（默认） | 左对齐 + 朱砂图标 + 标题 + 解释 + secondary 按钮 |
| inline | 表单提交失败 | 单行 body-sm 朱砂文字 + 句号 |
| banner | 顶部条带（极少用） | surfaceContainerHigh 背景 + 朱砂 1.5px 左竖线 + 一行说明 |

## States

| State | 视觉 | 触发 |
|-------|------|------|
| static | 见上 | 默认 |
| retrying | button.isLoading=true | onRetry 触发后异步等待 |

## Sizes

| Size | Icon | Title type | Padding-x |
|------|------|------------|-----------|
| sm | 24 | headline 24 | s-md (16) |
| md | 32 | display 32 | s-xl (64) |
| lg | 40 | display-xl 40 | s-xl (64) |

## API（Flutter）

```dart
class HanaErrorState extends StatelessWidget {
  const HanaErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,             // 调用方传 l10n.retry
    this.icon = Icons.error_outline,
    this.variant = HanaErrorStateVariant.editorial,
    this.size = HanaErrorStateSize.md,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData icon;
  final HanaErrorStateVariant variant;
  final HanaErrorStateSize size;
}

enum HanaErrorStateVariant { editorial, inline, banner }
enum HanaErrorStateSize { sm, md, lg }
```

## Tokens 引用
- title fg: `HanaTokens.ink` (#1C1A18)
- message fg: `HanaTokens.inkSecondary` (#5E5A52)
- icon color: `HanaTokens.error` (#9B2A2A 朱砂 / dark #D67878)
- title type: `HanaType.display`
- gap: `HanaSpacing.lg` (32)
- padding-x: `HanaSpacing.xl` (64)
- button: `HanaButton(variant: secondary)` —— 黛蓝边框

## Do's
- 标题陈述发生了什么（"出了点状况。"），message 解释为什么 + 下一步
- 仅图标用朱砂，文字仍墨色（避免视觉警报感）
- 重试 button 用 secondary，不要用 error 色按钮（那是删除按钮的视觉，不是恢复）

## Don'ts
- 不要标题用 emoji（"❌ 出错了"——拒绝）
- 不要整页背景变红或变粉（破坏月白基底）
- 不要"网络错误，请检查网络"之类技术暴露——message 必须人话

## i18n 注意
- title / message / retryLabel 全部由调用方传 ARB
- ARB 推荐 key：`errorStateTitle` / `errorStateMessageNetwork` / `errorStateMessageGeneric` / `retry`
- 中文标题 4-8 字（"出了点状况。"），日文 6-10 字（"問題が起きました。"），英文 ≤24 字符
- 不要在文案里嵌入 stack trace 或 error code（debug 走 logger）

## a11y
- `Semantics(label: '${title}. ${message}. ', liveRegion: true)` 错误出现时通知屏幕阅读器
- icon `ExcludeSemantics`（装饰性）
- 朱砂 `#9B2A2A` on 月白 `#F4F1EA` 对比度 7.2:1（AAA 文本对比度），即使图标也 ≥3:1
- retry button 触控 ≥44dp

## 工程实现提示
- 与 HanaEmptyState 共享 layout 骨架（可考虑抽 `_EditorialMessage` 内部 widget）
- inline variant 直接返回 `Text(message, style: bodySm.copyWith(color: error))`
- banner variant 用于 top-level 网络断开提示，配合 `MaterialBanner` 或自建滑入动画
- onRetry 异步处理时父级控制 isLoading；组件本身无状态
