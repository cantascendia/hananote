# HanaListItem

> Generated 2026-04-29 from screen specs (profile / drug list / inventory)
> Lib path (Phase 5 实施): `lib/core/widgets/hana_list_item.dart`

## 一句话定位
v2 列表项：**`surfaceContainerLowest` 实色 + 24/20 padding + 4px radius + 无边框 + 无投影 + press scale 0.98**——统一替换 v1 散落 14+ 处 `_SettingsCard` / `_ListTileItem` / `_ButtonRowItem` 复制实现。

## Anatomy
```
   ┌─────────────────────────────────────────────────────────┐
   │  [leading?]   Title · body · ink                        │
   │   20×20         subtitle? · body-sm · inkSecondary  ↗   │  ← trailing
   │   inkSecondary                                          │
   └─────────────────────────────────────────────────────────┘
   ↑ surfaceContainerLowest 实色
   ↑ 4px radius / 高度 ≥ 48dp / padding 横 24 / 纵 20
   ↑ 无 separator 横线（分组靠 surface 阶差或 spacing.sm 留白）
   ↑ press scale 0.98 / motion-quick 150ms（onTap != null 时）
```

## Variants
- **default**: title 单行
- **withSubtitle**: title + subtitle 上下两行
- **destructive**: title / leading / trailing 全部 `error` 朱砂色（"清除所有数据"）
- *(switch / chevron / trailingText 不作为 enum，而是通过 `trailing` slot 任意组合)*

## Props（Flutter API）
```dart
class HanaListItem extends StatelessWidget {
  const HanaListItem({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.semanticLabel,
  });
  final Widget title;            // 通常是 Text
  final Widget? leading;         // 仅允许 outlined icon @ 20dp，禁止圆形容器
  final Widget? subtitle;
  final Widget? trailing;        // 任意 widget — chevron / Switch / mono 时间戳
  final VoidCallback? onTap;
  final bool isDestructive;      // true → title / leading 改 error 色
  final String? semanticLabel;
}
```

## States
- **default**: surfaceContainerLowest 实底
- **pressed**: scale 0.98 / 150ms easeOut（仅 `onTap != null`）
- **disabled**: opacity 0.38 + 不响应 tap（由调用方传 `onTap: null` 实现）

## Tokens 引用
- background: `HanaTokens.surfaceContainerLowest(context)`
- title color: `HanaTokens.ink(context)` (default) / `HanaTokens.error(context)` (destructive)
- subtitle color: `HanaTokens.inkSecondary(context)`
- leading icon color: `HanaTokens.inkSecondary(context)` size 20
- radius: `HanaTokens.radius.card` (4)
- horizontal padding: 24（不是 `spacing.md` 16，profile spec §5 明确）
- vertical padding: 20
- min height: 48
- gap leading → title: 12
- press scale: 0.98 / `HanaTokens.motion.quick`

## Do's and Don'ts
- ✅ leading 仅允许 `Icons.xxx_outlined` size 20 + inkSecondary 紧贴 title 左 12px
- ✅ trailing 任意组合（mono `Text` / `Icon(Icons.chevron_right)` / `HanaSwitch`）
- ✅ destructive 仅用于真正不可逆的破坏性操作（"清除所有数据" / "注销账号"）
- ❌ leading 外加 `Container(decoration: shape: circle, color: alpha 26)`（v1 模式 → 删除）
- ❌ 项之间加 `Divider`（用 spacing.sm 留白或 surface 阶差替代）
- ❌ title bold w800（v1 模式）— 默认 body Regular

## i18n / a11y 注意
- `Semantics(button: onTap != null, label: semanticLabel ?? title text, hint: subtitle text)`
- 触控目标 ≥ 48dp（min height + padding 已保障）
- destructive 自动加 `Semantics(value: 'destructive')` 提示破坏性

## v1 替换映射
- `profile_page.dart` 14+ 处 `_SquareCard` / `_ListTileItem` / `_ButtonRowItem` 全部替换
- `settings_detail_page.dart` 14+ 处复制
- `drug_list.dart` 列表项
- `inventory.dart` 列表项
- **迁移**: `Container(decoration: _bentoDecoration()) > InkWell > Padding > Row(...)` → `HanaListItem(leading: ..., title: Text(...), trailing: ..., onTap: ...)`

## Flutter 实现提示
- 用 `Material(type: canvas, color: surfaceContainerLowest, borderRadius: 4)` 而非 `ListTile`（避免 M3 主题污染 padding）
- onTap != null 时外层包 `HanaPressScale`，不用 `InkWell`（v2 禁止 ripple）
- 用 `IntrinsicHeight` 让 leading / trailing 与文本垂直居中（minHeight 48 + 内容 20 line-height 自然居中）
- subtitle 行高 / 颜色都来自 `bodySm`，不接受外部 style 覆盖
