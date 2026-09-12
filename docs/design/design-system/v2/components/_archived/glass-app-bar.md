<!--
ARCHIVED 2026-04-29 (Phase 5 cleanup)

This v1-flavored stub has been superseded by the canonical v2 component:

  -> docs/design/design-system/v2/components/top-bar.md   (HanaTopBar)

The "Glass" name is misleading for v2 — the v2 design language **explicitly
abandons BackdropFilter blur** (a 13-file 工程债 cleared by v2). The new
`HanaTopBar` is solid `surfaceContainerHigh` + a 0.5px outline on scroll;
there is no glass / no blur / no opacity 0.8 layer. The old guidance to "keep
the name to ease migration" is no longer needed because all 13 v1 call sites
will be touched anyway during the v2 屏 rewrites — they migrate to
`HanaTopBar` directly.

DO NOT IMPLEMENT FROM THIS FILE. It is preserved for diff archaeology only.
Original content below as-is.
-->

# HanaGlassAppBar

> Generated 2026-04-28 from candidate-A + widget-pattern-inventory.md
> Replaces: 6+ 处逐字复制 `PreferredSize > ClipRRect > BackdropFilter(blur 12) > AppBar(opacity 0.8)`（timeline / settings_detail / data_page / record_page / notification / profile / legal / knowledge_webview，Top widget pattern #5）
> Lib path (Phase 5 待实施): `lib/core/widgets/hana_glass_app_bar.dart`

## Anatomy

```
HanaGlassAppBar (PreferredSize, height: 56 + safeAreaTop)
└── AnimatedContainer (bg, border-bottom transitions on scroll)
    └── SafeArea (top only)
        └── Padding (s-md 16 horizontal)
            └── Row (crossAxisAlignment.center, height 56)
                ├── leading? (HanaButton iconOnly, default 后退)
                ├── SizedBox(s-md)
                ├── Expanded
                │   └── Text title (title 18/26 衬线 ink, alignment-start)
                └── actions? (Row of HanaButton iconOnly, gap s-sm)
└── ScrollNotification listener
    └── Container 1px (visible when scrolled > 8px, color outline #A39E92 @ 15%)
```

**⚠️ 关键说明 — 名称保留但语义反转**：方向 A **告别玻璃感**——v1 的 BackdropFilter blur 12px 是 13 处工程债 + 与编辑级东亚气质冲突。组件名 `HanaGlassAppBar` **保留是为了平滑迁移**（旧代码 6 处复制可一次性 sed 替换）；v2 内部实现是**实色月白 AppBar (`surfaceContainerHigh` `#EAE6DD`) + 滚动时显示 1px outline-variant 细线**。从"玻璃感"切换到"印刷感"，去掉 13 个文件的工程债。Phase 5 工程师注意：**不要再加 BackdropFilter**。

## Variants

| Variant | 用途 | 视觉 |
|---------|------|------|
| solid | 默认（v2 标准） | surfaceContainerHigh 实色 + 滚动时 1px 线 |
| transparent | Hero 顶部（如 today_page）| 透明 + 滚动时渐变到 solid |
| inverse | 全屏照片预览页 | ink 实色 + 雪宣文字 |

## States

| State | 视觉 | 触发 |
|-------|------|------|
| top (scroll=0) | bg 透明 (transparent variant) / surfaceContainerHigh (solid) | 默认 |
| scrolled | bg surfaceContainerHigh + bottom 1px outline @ 15% | scrollOffset > 8 |
| transitioning | 240ms ease-out 切换 | scrollOffset cross 阈值 |

## Sizes

| Size | Height | Title type | Notes |
|------|--------|------------|-------|
| sm | 48 | label-md | 二级 page (settings detail) |
| md | 56 | title 18 | 默认 |
| lg | 72 | headline 24 | 主入口 page (timeline / today) |

## API（Flutter）

```dart
class HanaGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HanaGlassAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.variant = HanaGlassAppBarVariant.solid,
    this.size = HanaGlassAppBarSize.md,
    this.scrollController,            // 监听滚动来切换 bg
    this.centerTitle = false,         // v2 默认左对齐（杂志风）
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final HanaGlassAppBarVariant variant;
  final HanaGlassAppBarSize size;
  final ScrollController? scrollController;
  final bool centerTitle;

  @override
  Size get preferredSize => Size.fromHeight(_resolveHeight(size));
}

enum HanaGlassAppBarVariant { solid, transparent, inverse }
enum HanaGlassAppBarSize { sm, md, lg }
```

## Tokens 引用
- bg solid: `HanaTokens.surfaceContainerHigh` (#EAE6DD)
- bg transparent: `Colors.transparent`
- bg inverse: `HanaTokens.ink` (#1C1A18)
- border-bottom on scroll: `HanaTokens.outlineVariant` (#A39E92) @ 15%
- title fg: `HanaTokens.ink` / inverse: `HanaTokens.onAccent` (#FBF8F2)
- title type: `HanaType.title` (Spectral / 思源宋体 Regular 18)
- height: `HanaSizing.appBar` = 56
- motion: `HanaMotion.quick` = 240ms ease-out

## Do's
- 标题左对齐 16px（杂志风），不居中（centerTitle=false 是默认）
- 滚动 8px 后才显示底部细线（避免在静止顶部加分隔）
- 一屏只有一个 AppBar，不嵌套
- actions 最多 2 个 iconOnly button（克制原则）

## Don'ts
- **不要再加 BackdropFilter blur**（v1 工程债已结清）
- 不要中央标题（除非 modal / dialog 风格 page）
- 不要 r-1 / r-2 圆角（AppBar 是页面顶边，无圆角）
- 不要给 transparent variant 加渐变（保持纯透明）

## i18n 注意
- title 由调用方传 ARB
- 中文 title 4-10 字（"血液检测" / "通知设置"），日文 4-12 字符（"血液検査"），英文 ≤24 字符
- 长 title 用 `maxLines: 1 + ellipsis`，但 ARB 应控制在合理长度
- inverse variant 在 dark mode 下自动反转色（不是单独 dark theme）

## a11y
- 整体 `Semantics(header: true, container: true)` 标记为页面顶部
- title `Semantics(headingLevel: 1)` 让屏幕阅读器知道这是 H1
- leading button 默认是返回，`Semantics(label: l10n.back, button: true)`
- 触控按钮（leading / actions）≥44dp（HanaButton iconOnly 已保证）
- 颜色 contrast：ink #1C1A18 on surfaceContainerHigh #EAE6DD = 12.4:1 (AAA)

## 工程实现提示
- 不再用 BackdropFilter / ImageFilter.blur（移除 13 个文件的硬编码 blur）
- bg 切换用 `AnimatedContainer(duration: 240ms, color: ...)`
- bottom 1px line 用 `AnimatedOpacity(opacity: scrolled ? 1 : 0)` 包 `Container(height: 1, color: outlineVariant @ 15%)`
- scrollController 监听用 `addListener` + `setState`；如果父级是 `NestedScrollView` / `CustomScrollView` 自动注入
- 迁移策略：sed 替换 6 处 `BackdropFilter > AppBar(...)` 块为 `HanaGlassAppBar(title: ..., actions: ...)`，保留 title / actions 即可
- transparent variant 在 today_page 顶部 hero 区使用，配合 `MediaQuery.padding.top` 留 safeArea
