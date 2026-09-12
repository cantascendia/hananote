# HanaEmptyState

> Generated 2026-04-28 from DESIGN.md v2 + widget-pattern-inventory.md
> Lib path (Phase 5 实施): `lib/core/widgets/hana_empty_state.dart`

## 一句话定位
v2 空数据态：**一行宋体陈述 + 大量留白 + 可选 CTA**，没有大圆图标背景圆，没有"快去添加吧 →"的鼓励文案——杂志的"本期空白。"语法。

## Anatomy
```
                 (顶部 spacing.xl 64 留白)

                 ┌  Icon 32dp          ← 单色线性图标，墨色 @ 60%
                 │                       图标外**无**圆形背景容器
                 ├──────── spacing.lg (32) ──────────
                 │
                 │  Title · headline (24) · ink
                 │  「本期空白。」
                 │
                 ├──────── spacing.sm (8) ───────────
                 │
                 │  Message? · body-sm · inkSecondary
                 │  （可选，一行为限，不要长说明）
                 │
                 ├──────── spacing.lg (32) ──────────
                 │
                 │  [HanaButton.action?] (可选)
                 │
                 └  (底部 spacing.xl 64 留白)
```

水平：左对齐到 `spacing.lg` (32) 而非居中——编辑级不对称原则；窄屏（<360）允许居中。

## Variants
- **list**: 嵌入列表 / 卡片内的空态，紧凑 — Title `title` (18) + 无 message
- **page**: 整页空态 — Title `headline` (24) + 可选 message + 可选 action
- **inline**: 卡片内极简空态 — 仅一行 `body-sm` 文案（"本期空白。"），无图标无 CTA

## Props（Flutter API）
```dart
class HanaEmptyState extends StatelessWidget {
  const HanaEmptyState({
    super.key,
    required this.title,
    this.icon,
    this.message,
    this.action,
    this.variant = HanaEmptyStateVariant.page,
    this.semanticLabel,
  });
  final String title;
  final IconData? icon;     // 可选 — variant.inline 时忽略
  final String? message;
  final Widget? action;     // 通常是 HanaButton
  final HanaEmptyStateVariant variant;
  final String? semanticLabel;
}

enum HanaEmptyStateVariant { list, page, inline }
```

## States
- 单一状态（静态），无动画 — empty 不需仪式感

## Tokens 引用
- background: 透明（继承父级 surface）
- icon color: `HanaTokens.ink(context)` @ 60% 不透明度
- icon size: 32dp（**不**是 v1 的 56/64）
- title: `HanaTokens.ink(context)` headline (page) / title (list) / body-sm (inline)
- message: `HanaTokens.inkSecondary(context)` body-sm
- spacing: 上下 `spacing.xl` (64)、icon→title `spacing.lg` (32)、title→message `spacing.sm` (8)、message→action `spacing.lg` (32)

## Do's and Don'ts
- ✅ 文案第三人称 + 句号收尾："本期空白。" / "今日宜，按时。" / "尚无记录。"
- ✅ icon 用单色线性图标（`Icons.xxx_outlined`），**不**填充
- ✅ inline variant 一行解决，不放图标不放按钮
- ❌ icon 外加圆形 / 圆角矩形背景容器（v1 _MeasurementEmptyState 模式）
- ❌ 图标尺寸 ≥ 48（v1 用 56/64 → 太抢眼）
- ❌ 鼓励文案 / 第二人称："快来添加你的第一条记录！" → 全部出局
- ❌ emoji（🌸✨📝）

## i18n / a11y 注意
- `Semantics(label: semanticLabel ?? title, hint: message)` 必填
- title 来自 ARB（强制），组件层不内置文案
- ja「本記なし。」/ zh「本期空白。」/ en「Empty.」长度差异大 — 不限制 title 行数
- action 自身 a11y 由 HanaButton 处理

## v1 替换映射
- inventory #2「Empty State」**8 处** + 4 处 inline 全部统一：
  - `measurement_page.dart:89` `_MeasurementEmptyState`（圆容器 + Icon 56 + 标题 + 副标题）
  - `photo_page.dart:210` `_PhotoEmptyState`（同结构 + lock icon）
  - `today_page.dart:228` inline（icon 64 + Title + FilledButton.icon CTA）
  - `data_page.dart:960` `_EmptyHistoryCard`（灰边 + 居中 Text，无图标）
  - `timeline_page.dart:206` 仅 `Center(Text(emptyLabel))`
  - `record_page.dart` 三处 mood/photo/measure inline
- **迁移**:
  - 三处私有 `_MeasurementEmptyState` / `_PhotoEmptyState` / `_EmptyHistoryCard` 删除
  - `Center(Column([Container(圆背景, Icon 56), Title, Subtitle]))` → `HanaEmptyState(icon: ..., title: ..., message: ..., variant: page)`
  - `Center(Text(emptyLabel))` → `HanaEmptyState(title: ..., variant: inline)`

## Flutter 实现提示
- 基于 `Padding > Column(crossAxisAlignment: start)`（page / list）/ `Padding > Text`（inline）
- 不用任何 `Container(decoration: BoxDecoration(shape: circle, color: ...))` 包裹 icon — 直接 `Icon(icon, size: 32, color: ink @ 60%)`
- list variant 整体外层包 `Padding(vertical: spacing.lg)` 即可，不需占满整屏
- page variant 整体外层 `Center(child: ConstrainedBox(maxWidth: 360, ...))`；窄屏自动收窄
