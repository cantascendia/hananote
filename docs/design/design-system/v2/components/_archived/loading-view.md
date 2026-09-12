<!--
ARCHIVED 2026-04-29 (Phase 5 cleanup)

This v1-flavored stub has been superseded by the canonical v2 component:

  -> docs/design/design-system/v2/components/loading.md   (HanaLoadingView)

Two competing specs evolved in parallel during candidate exploration:
  - loading-view.md (this file): "三点宋体省略号 / DotPulse" 1.6s 循环
  - loading.md (canonical):       "细线圆环 + 可选一行陈述"

The v2 design language picked the **细线圆环 + 文字态 (`HanaLoadingView.block` "读取中。")**
variant from `loading.md` because it composes better with the editorial
hero-only screens (today / record / data / timeline / inventory all spec the
block variant with text-only "读取中。" / "Loading."). The DotPulse animation
spec has not been adopted by any v2 spec; preserved here for diff archaeology
only.

DO NOT IMPLEMENT FROM THIS FILE. It is preserved for diff archaeology only.
Original content below as-is.
-->

# HanaLoadingView

> Generated 2026-04-28 from candidate-A + widget-pattern-inventory.md
> Replaces: 18 处散落的 `Center(child: CircularProgressIndicator(...))` — 跨全部 11 个 feature module（Top widget pattern #1，最高频）
> Lib path (Phase 5 待实施): `lib/core/widgets/hana_loading_view.dart`

## Anatomy

```
HanaLoadingView (Center / SliverFillRemaining)
└── Column (mainAxisSize.min, gap = s-md (16))
    ├── DotPulse  ← 三点宋体省略号「…」ink-muted (#5E5A52) 渐进透明度循环
    └── Text? (label, body-sm 淡墨, optional)
```

**视觉关键**：编辑级东亚气质拒绝 Material 旋转 `CircularProgressIndicator`——那是工具语言。改用三个全角中文省略号点 `…` 或三个 ink-muted 圆点的 1.6s 循环序列淡入淡出（顺序 1→2→3→1，每个点 alpha 在 0.2/0.6/1.0 之间循环）。无旋转、无填充弧线，只有"等待"的呼吸感。

## Variants

| Variant | 用途 | 视觉 |
|---------|------|------|
| inline | 按钮内 / 表单旁 | 仅 dots，size sm，无 label |
| centered | 整页加载 | dots + 可选 label，垂直居中 |
| sliver | CustomScrollView 内 | 包 SliverFillRemaining 实现 |

## States

| State | 视觉 | 触发 |
|-------|------|------|
| visible | dots 循环 1.6s | 默认 |
| reduced-motion | 静态三点 alpha 0.6 + 不动 | `MediaQuery.disableAnimations` 为 true |

## Sizes

| Size | Dot diameter | Gap between dots | Label type |
|------|--------------|------------------|------------|
| sm | 4px | s-xs (4) | label-sm |
| md | 6px | s-sm (8) | body-sm |
| lg | 8px | s-md (16) | body |

## API（Flutter）

```dart
class HanaLoadingView extends StatelessWidget {
  const HanaLoadingView({
    super.key,
    this.label,
    this.size = HanaLoadingSize.md,
    this.useSliverFill = false,
  });

  final String? label;            // 可选，调用方传 ARB 解析后的字符串
  final HanaLoadingSize size;
  final bool useSliverFill;        // CustomScrollView 内用 SliverFillRemaining
}

enum HanaLoadingSize { sm, md, lg }
```

## Tokens 引用
- color: `HanaTokens.inkSecondary` (#5E5A52 / dark #A39E92)
- gap: `HanaSpacing.md` (16)
- motion: `HanaMotion.loop` = 1600ms linear infinite
- type: `HanaType.bodySm` for label

## Do's
- 一屏最多一个 centered loading；列表项内用 inline (sm)
- label 短句，句末加全角句号（"读取中。"）
- 配合 `AnimatedSwitcher` 让 loading → content 渐变 240ms

## Don'ts
- 不要保留 `CircularProgressIndicator`（与编辑级东亚气质冲突）
- 不要 spinner 配合彩色圆环或渐变
- 不要长 label（"正在为您加载数据，请稍候..."），保持 4-6 字内

## i18n 注意
- label 由调用方传 `l10n.loadingLabel`，组件零依赖 AppLocalizations
- 中文 4 字「读取中。」/ 日文「読み込み中。」/ 英文 "Loading." 都需弹性宽度
- 三点省略号字符使用 `…` (U+2026) 而非三个 `.`，CJK 字体下视觉更整齐

## a11y
- 整体 `Semantics(label: label ?? 'Loading', liveRegion: true)` 通知屏幕阅读器
- 触控目标无要求（不可交互）
- prefers-reduced-motion → 静态显示，不循环

## 工程实现提示
- 用 `AnimationController(duration: 1600ms)` + 3 个 `Tween<double>` (intervals 0–0.33 / 0.33–0.66 / 0.66–1.0)
- 用 `Container(decoration: BoxDecoration(shape: BoxShape.circle, color: ink @ alpha))` 而非 Text 字符（保证视觉精确）
- `useSliverFill=true` 时返回 `SliverFillRemaining(hasScrollBody: false, child: ...)`
