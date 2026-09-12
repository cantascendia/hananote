# HanaCard

> Generated 2026-04-28 from DESIGN.md v2 + widget-pattern-inventory.md
> Lib path (Phase 5 实施): `lib/core/widgets/hana_card.dart`

## 一句话定位
v2 的"内文页"容器：靠 surface 阶差表达层次，**不投影、不边框、4px 圆角**，是"段落视觉单位"——一张卡放完一组完整信息，不再切碎成多张小卡。

## Anatomy
```
╭──────────────────────────────────╮  ← 4px radius
│                                  │
│   [child: title + body + image]  │   padding 16 (md)
│                                  │     ↳ 内部段落 spacing.md
│                                  │     ↳ 段落之间 spacing.lg (32)
╰──────────────────────────────────╯
   ↑ surfaceContainerLowest #FBF8F2
     placed on background #F4F1EA → 6 个明度差，肉眼可辨无须边线
```

## Variants
- **flat** (默认): surfaceContainerLowest 实色、无投影、无边框。**99% 场景用这个**。
- **inset**: 在 surfaceContainerHigh 上反向凹陷，用于 AppBar 区域内嵌信息块（极少）。
- **tappable**: 加 `onTap` 即变可按，press 时 Scale 0.98。

## Props（Flutter API）
```dart
class HanaCard extends StatelessWidget {
  const HanaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.variant = HanaCardVariant.flat,
    this.semanticLabel,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final HanaCardVariant variant;
  final String? semanticLabel;
}

enum HanaCardVariant { flat, inset, tappable }
```

## States
- **default**: 静态展示
- **pressed** (仅 tappable): Scale 0.98，`motion-quick` 150ms
- **disabled**: 不存在——卡片不可禁用，禁用通过内部内容表达

## Tokens 引用
- background (flat / tappable): `HanaTokens.surfaceContainerLowest(context)`
- background (inset): `HanaTokens.surfaceContainerHigh(context)`
- radius: `HanaTokens.radius.card` (4)
- padding: `HanaTokens.spacing.md` (16)
- shadow: **none** (`elev-0` 默认)
- press scale: `HanaTokens.motion.quick`

## Do's and Don'ts
- ✅ 一张大卡承载一组完整信息（标题 + 多段文字 + 图）——杂志版面思维
- ✅ 卡片之间用 `spacing.lg` (32) 分隔，**不用**分隔线
- ✅ 卡内段落用 `spacing.md` (16)；段落之间 `spacing.lg` (32)，相邻间距跨级
- ❌ 圆角 ≥ 8px（v1 的 16/24 全部出局）
- ❌ `BoxShadow` / `elevation > 0` / `BackdropFilter`
- ❌ 卡内再嵌套小卡（→ 改用 surface 阶差或留白分组）

## i18n / a11y 注意
- 当 `onTap != null` 时挂 `Semantics(button: true, label: semanticLabel)`
- 卡片不强制语义角色，由 child 决定（heading / list / article）
- 长文本（ja）允许卡内自然换行，**不**把 padding 改小挤压

## v1 替换映射
- inventory #4「Section Card / Surface Container」14+ 处复制
- 命中私有定义：`blood_test_edit_page.dart:512` `_CardWrapper` · `settings_detail_page.dart:575` `_SettingsCard` · `data_page.dart:847` `_StitchHistoryCard`
- inline `Container(decoration: BoxDecoration(...))`：`measurement_edit_page.dart:221/249` · `record_page.dart:309` · `inventory_page.dart:79` · `drug_card.dart:31` · `today_page.dart` 多处
- **迁移**: 所有 `_CardWrapper` / `_SettingsCard` / `_StitchHistoryCard` 删除；`Container(decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(16/24), boxShadow: [...]))` → `HanaCard(child: ...)`

## Flutter 实现提示
- 基于 `Material(type: MaterialType.canvas, color: ..., borderRadius: ..., child: InkWell(...))`，不用 `Card` widget（避免 M3 主题强行注入 elevation）
- `inset` variant 用 `surfaceContainerHigh` 的色阶差自然形成"凹陷"——**不要**写负向 shadow
- press scale 仅 `tappable` variant 启用，包裹 `AnimatedScale`
- 圆角用 `HanaTokens.radius.card`，**不**接受外部覆盖（保持系统统一）
