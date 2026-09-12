# HanaSectionHeader

> Generated 2026-04-29 from screen specs (today / profile / record / data / timeline)
> Lib path (Phase 5 实施): `lib/core/widgets/hana_section_header.dart`

## 一句话定位
v2 章节横幅：**4px 黛蓝竖线 + label-md inkSecondary +0.6 横幅**——杂志页"段落标记"，不是分隔符。每屏 ≤ 3 处出现，是黛蓝稀缺资源的合规消耗位之一。

## Anatomy
```
   ┃ 数据                                       [trailing?]
   ↑ ↑                                            ↑
   │ label · 12 · +0.6 tracking · inkSecondary    可选（mono 时间戳 / chevron）
   │ 左对齐到 spacing.lg (32)
   │
   4px wide × line-height (16px) tall · primary 黛蓝
   竖线高度 = 标题首行 line-height（不是横向分隔符）
   ──────────────────────────────────────────  ← 可选 1px outline @ 8% 分割线
                                                  (divider: true 时)
```

## Variants
- **default**: 仅 4px 竖线 + label
- **withTrailing**: label 右侧 trailing widget（mono 时间戳 / chevron / 操作按钮）
- **withDivider**: 在 label 下方加 1px outline @ 8% 横向细线（极少用，仅在 sticky 章节头需要"压住"内容时）

## Props（Flutter API）
```dart
class HanaSectionHeader extends StatelessWidget {
  const HanaSectionHeader({
    super.key,
    required this.label,
    this.trailing,
    this.divider = false,
    this.semanticLabel,
  });
  final String label;          // 来自 ARB（"数据" / "隐私" / "当前" / "之后"）
  final Widget? trailing;      // 可选 trailing
  final bool divider;          // 是否在下方加 1px outline @ 8% 分割线
  final String? semanticLabel; // 屏幕阅读器 label 覆盖
}
```

## States
- 单一静态状态。可在 `SliverPersistentHeader` 中 sticky 使用，无入场动画。

## Tokens 引用
- bar color: `HanaTokens.primary(context)` 4px wide
- label style: `HanaTokens.typography.label`（12 / +0.6 tracking）
- label color: `HanaTokens.inkSecondary(context)`
- 左对齐基线: `HanaTokens.spacing.lg` (32)
- gap 竖线 → label: `HanaTokens.spacing.sm` (8)
- divider color: `HanaTokens.outline(context)` @ 8% 不透明度
- vertical padding: `spacing.sm` (8) 上下

## Do's and Don'ts
- ✅ 文案来自 ARB，零 emoji（"数据" 而非 "📊 数据"）
- ✅ 一屏 ≤ 3 处 — 黛蓝合规位
- ✅ 竖线高度 = 标题首行（不是整个组件高度，更不是横向延伸）
- ❌ 把竖线扩展为整段左侧线（→ 黛蓝立刻贬值）
- ❌ 标题居中（违反编辑级不对称原则）
- ❌ 使用 `divider: true` 替代 surface 阶差分组（仅 sticky 场景例外）

## i18n / a11y 注意
- `Semantics(header: true, label: semanticLabel ?? label)` — TalkBack 朗读为 "标题"
- ja「データ」/ zh「数据」/ en「Data」长度差异最多 4 字符，单行足够
- trailing 自身 a11y 由 trailing widget 承担

## v1 替换映射
- `today_page.dart:325-362, 395-414` 「已服 / 未服」标题 Row
- `profile_page.dart` 5 节标题（"数据" / "隐私" / "通知" / "关于" / "危险区"）
- `record_page.dart` 「三道入口」/「最近记录」标签
- `data_page.dart` "当前指标" / "趋势" / "工具" / "历次报告"
- `timeline_page.dart` sticky 月份章节
- **迁移**: `Padding > Row(Container 6×6 dot, Text)` / `Container(border: Border(left: ...))` → `HanaSectionHeader(label: ..., trailing: ...)`

## Flutter 实现提示
- 用 `Row(crossAxisAlignment: stretch)` + `IntrinsicHeight` 让 4px `Container` 自动等高于 label 首行
- 但 `IntrinsicHeight` 在 sliver 中开销大 → 实战可固定 `bar height = 16`（label `line-height`）+ `Row(crossAxisAlignment: center)`
- divider 用 `Container(height: 1, color: outline @ 8%)` 而非 `Divider`（避免 Material 默认 indent / endIndent）
- 不接受外部覆盖 bar 颜色 — 永远 `primary`，否则 v2 语法被破坏
