# HanaLoadingView

> Generated 2026-04-28 from DESIGN.md v2 + widget-pattern-inventory.md
> Lib path (Phase 5 实施): `lib/core/widgets/hana_loading_view.dart`

## 一句话定位
v2 加载态：**一个细线圆环 + 可选一行陈述**，居中或填充，墨色或黛蓝——18 处散落 spinner 的统一收口；不用 shimmer，不用骨架屏。

## Anatomy
```
                ╭──╮
                │  │     ← 圆环 size 24 / 32 / 48 (按 variant)
                ╰──╯       strokeWidth 2 (size≤32) / 2.5 (size 48)
                            色：ink @ 70% (默认) 或 primary
              spacing.md (16)
              Message? · body-sm · inkSecondary  ← 可选一行
                            "载入中。" / "Loading."
```

## Variants
- **inline**: size 24，padding 0，嵌入按钮 / 行内文本之间
- **block** (默认): size 32，居中 + 上下 `spacing.lg` (32) padding，用于卡片内 / 列表区域加载
- **page**: size 48，居中 + 占满父容器（`Expanded` / `SliverFillRemaining`），用于整页加载
- **overlay**: page + scrim ink @ 16%，用于覆盖式异步操作（如保存中、上传中）

## Props（Flutter API）
```dart
class HanaLoadingView extends StatelessWidget {
  const HanaLoadingView({
    super.key,
    this.variant = HanaLoadingVariant.block,
    this.message,
    this.useAccent = false,
    this.useSliverFill = false,
    this.semanticLabel,
  });
  final HanaLoadingVariant variant;
  final String? message;       // 可选，由调用方传 ARB 文本
  final bool useAccent;         // true: primary 黛蓝；false: ink @ 70%
  final bool useSliverFill;     // CustomScrollView 内自动包 SliverFillRemaining
  final String? semanticLabel;
}

enum HanaLoadingVariant { inline, block, page, overlay }
```

## States
- 单一动画状态：圆环匀速旋转，`motion-standard` curve 无视觉跳动
- 不提供 progress 百分比 variant — 不确定时用 indeterminate；确定进度用专门的 `HanaProgressBar`（未来组件）

## Tokens 引用
- spinner color (default): `HanaTokens.ink(context)` @ 70% 不透明度
- spinner color (useAccent): `HanaTokens.primary(context)`
- strokeWidth: 2.0 (inline / block) / 2.5 (page / overlay)
- size: 24 / 32 / 48 / 48（按 variant）
- message text: `body-sm` + `HanaTokens.inkSecondary(context)`
- spacing icon→message: `HanaTokens.spacing.md` (16)
- overlay scrim: `ink @ 16%`（比 dialog scrim 更浅，因为不拦截操作语义）
- vertical padding (block): `HanaTokens.spacing.lg` (32)

## Do's and Don'ts
- ✅ 一屏只一个 loading（不在卡片内 + 顶部 + 列表三处同时显示 spinner）
- ✅ message 仅在加载预期 > 1s 时显示，否则只显示 spinner
- ✅ useAccent 仅在"主操作进行中"（保存、提交）时使用 — 黛蓝是稀缺资源
- ❌ shimmer / 骨架屏 / placeholder 灰块（v2 不需要这种"假数据"语法）
- ❌ 多个 spinner 嵌套（→ 只在最外层加载边界放一个）
- ❌ 自定义 spinner 颜色 — 颜色完全由 `useAccent` 二选一

## i18n / a11y 注意
- `Semantics(label: semanticLabel ?? 'Loading', liveRegion: true)` — 让屏幕阅读器朗读"加载中"
- message 必须从 ARB 取（"载入中。" / "読み込み中。" / "Loading."）
- 触控：loading 期间应禁用周边按钮（调用方负责，组件不管）
- overlay variant scrim 不拦截 a11y 焦点 — 加载完会自然 dismiss

## v1 替换映射
- inventory #1「Loading State」**18 处**散落，覆盖全部 11 个 feature module：
  - 默认 `CircularProgressIndicator()`（无颜色）：`photo_page:61` · `simulator:81-82` · `auth_wrapper:83` · `drug_list:39` · `inventory:42` · `schedule_editor:59` · `measurement_page:48/52` · `blood_test_edit:256`
  - 带主色：`timeline:103` · `profile:193` · `record_page:32` · `knowledge_webview:70/133` · `notification_settings:64` · `data_page:74`
  - 细化 strokeWidth: `photo_view:78` · `measurement_edit:133` · `blood_test_edit:240` · `journal_edit:131` · `photo_page:405`
  - 反向色: `photo_view_page:209`
- **迁移**:
  - `Center(child: CircularProgressIndicator())` → `HanaLoadingView(variant: page)`
  - `Center(child: CircularProgressIndicator(color: HanaColors.primary))` → `HanaLoadingView(variant: page, useAccent: true)`
  - `CircularProgressIndicator(strokeWidth: 2)` (按钮内) → `HanaLoadingView(variant: inline)`
  - `SliverFillRemaining(child: Center(child: CircularProgressIndicator()))` → `HanaLoadingView(variant: page, useSliverFill: true)`

## Flutter 实现提示
- 基于 `CircularProgressIndicator(strokeWidth: 2.0/2.5, valueColor: AlwaysStoppedAnimation(color))`
- size 控制用外层 `SizedBox(width: x, height: x)`，不依赖 `CircularProgressIndicator` 默认 36
- `useSliverFill: true` 时返回 `SliverFillRemaining(hasScrollBody: false, child: ...)`，否则普通 `Center(...)`
- overlay variant: `Stack` + 全屏 `Container(color: ink @ 16%)` + 居中 spinner + message
- 旋转匀速 — 不要用 `motion-bouncy` 或 elastic curves
- **不要**用 Material `LinearProgressIndicator` — v2 仅圆环（线性进度等 progress bar 组件单独设计）
