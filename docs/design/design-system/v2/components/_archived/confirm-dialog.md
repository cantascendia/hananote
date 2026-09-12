<!--
ARCHIVED 2026-04-29 (Phase 5 cleanup)

This v1-flavored stub has been superseded by the canonical v2 component:

  -> docs/design/design-system/v2/components/dialog.md   (HanaDialog)

The v2 dialog spec keeps `HanaConfirmDialog`-style anatomy (title 后果 / message 意愿 / 右下双按钮) but re-defines it as the **only** Dialog primitive in v2 — used exclusively for destructive 红线 (delete / wipe / sign-out). Any "neutral confirm" usage that was here moves to `HanaBottomSheet` action-sheet variant per principles.md §"BottomSheet 取代 AlertDialog 默认".

DO NOT IMPLEMENT FROM THIS FILE. It is preserved for diff archaeology only.
Original content below as-is.
-->

# HanaConfirmDialog

> Generated 2026-04-28 from candidate-A + widget-pattern-inventory.md
> Replaces: 8 处 inline `AlertDialog` 复制（measurement_page / photo_view / photo_page / drug_list / inventory / settings_detail / profile_page ×2，Top widget pattern #7）
> Lib path (Phase 5 待实施): `lib/core/widgets/hana_confirm_dialog.dart`

## Anatomy

```
HanaConfirmDialog (Dialog wrapper, barrier ink @ 50%)
└── Container (bg surfaceContainerLowest #FBF8F2, radius r-3 8px, max-width 360)
    └── Padding (s-lg 32 all)
        └── Column (crossAxisAlignment.start, gap = s-md 16)
            ├── Text title (headline 24/32 衬线 ink, "删除后不可恢复。")
            ├── Text? message (body 15/24 淡墨, "仍要继续？")
            ├── SizedBox(s-md)
            └── Row (mainAxisAlignment.end, gap = s-sm 8)
                ├── HanaButton (variant=text, label=cancel, "取消")
                └── HanaButton (variant=primary | destructive, label=confirm)
```

**视觉关键**：方向 A 的删除/确认对话不是 iOS 系统弹窗或 Material AlertDialog——那些 r-12 圆角和居中按钮太工具化。这是**杂志的"页脚问询"**：标题先陈述后果（"删除后不可恢复。"），message 才问意愿（"仍要继续？"），两个动作 bottom-aligned 靠右。**危险操作（删除）confirm button 用 destructive variant（朱砂填充）而非黛蓝**——黛蓝是"安全可继续"的语义，朱砂是"不可逆警告"。

## Variants

| Variant | 用途 | 视觉 |
|---------|------|------|
| neutral | 普通确认（如保存草稿） | confirm 用 primary 黛蓝 |
| destructive | 删除 / 不可逆 | confirm 用 destructive 朱砂 + icon 朱砂叹号 |
| info | 仅信息告知 | 仅 confirm "知道了"，无 cancel |

## States

| State | 视觉 | 触发 |
|-------|------|------|
| presenting | 渐入 + scale(0.96 → 1.0) 240ms | show() |
| confirming | confirm button.isLoading=true | onConfirm 异步 |
| dismissing | 渐出 200ms | tap barrier / cancel / pop |

## Sizes

| Size | Max-width | Padding | Notes |
|------|-----------|---------|-------|
| compact | 280 | s-md (16) | 仅短标题 + 双按钮 |
| md | 360 | s-lg (32) | 默认 |
| wide | 480 | s-lg (32) | 详细解释（仅 web 端） |

## API（Flutter）

```dart
class HanaConfirmDialog {
  HanaConfirmDialog._();

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? message,
    required String confirmLabel,
    String? cancelLabel,                  // null → 隐藏 cancel（info variant）
    HanaConfirmDialogVariant variant = HanaConfirmDialogVariant.neutral,
    HanaConfirmDialogSize size = HanaConfirmDialogSize.md,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: HanaTokens.ink.withAlpha(128),
      barrierDismissible: barrierDismissible,
      builder: (ctx) => _HanaConfirmDialogContent(
        title: title, message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        variant: variant, size: size,
      ),
    );
  }
}

enum HanaConfirmDialogVariant { neutral, destructive, info }
enum HanaConfirmDialogSize { compact, md, wide }
```

## Tokens 引用
- bg: `HanaTokens.surfaceContainerLowest` (#FBF8F2)
- radius: `HanaRadius.dialog` = 8 (r-3)
- barrier: `HanaTokens.ink` @ 50%
- title fg: `HanaTokens.ink`
- message fg: `HanaTokens.inkSecondary`
- title type: `HanaType.headline`
- message type: `HanaType.body`
- gap title↔message: `HanaSpacing.sm` (8)
- gap content↔buttons: `HanaSpacing.lg` (32)
- gap cancel↔confirm: `HanaSpacing.sm` (8)
- destructive confirm bg: `HanaTokens.error` (#9B2A2A 朱砂)

## Do's
- 标题先陈述后果，message 再问意愿（杂志逻辑）
- destructive variant confirm button 用朱砂，cancel 仍黛蓝 text
- 句末用全角句号（"删除后不可恢复。"），message 末用问号即可（"仍要继续？"）
- confirm button label 与动作一致（"删除" 而非 "确定"）

## Don'ts
- 不要圆角 ≥ 12px（保持 r-3 = 8px）
- 不要中央 stack 两按钮（必须 bottom-right horizontal）
- 不要"确定/取消"两个无意义词（要"删除/取消" / "替换/保留"）
- 不要在 dialog 内放图标背景圆环（v1 卡片堆叠语言）

## i18n 注意
- title / message / confirmLabel / cancelLabel 全部由调用方传 ARB
- 中文 confirm label 2 字（"删除" / "替换" / "继续"），日文 2-4 字（"削除" / "上書き"），英文 ≤10 字符
- ARB 命名建议：`confirmDialogDeleteTitle` / `confirmDialogDeleteMessage` / `confirmDelete`
- 长 message 自动换行 + maxLines: 4 + ellipsis（极少触发）

## a11y
- `Semantics(scopesRoute: true, namesRoute: true, label: title)` 让屏幕阅读器朗读 modal
- destructive confirm 配合 `Semantics(label: '$confirmLabel. Destructive action.')`
- 触控按钮 ≥44dp（HanaButton 已保证）
- 颜色 contrast：朱砂 `#9B2A2A` on 雪宣 `#FBF8F2` = 7.4:1 (AAA)
- focus 默认在 cancel 按钮（防误触确认 — 危险操作不可主动 focus confirm）

## 工程实现提示
- 用 `showDialog` + `Dialog(child: ...)` 而非 `AlertDialog`（后者结构固定不灵活）
- present 动画用 `ScaleTransition(0.96 → 1.0) + FadeTransition` 240ms
- destructive variant 内部传 `HanaButtonVariant.destructive` 给 HanaButton
- iOS 平台 `Cupertino` 风格弹窗一律不用（DESIGN.md 强制 — 见 widget-pattern-inventory §3 "Don'ts iOS 标准弹窗"）
- onConfirm 异步处理时返回 Future，confirm button isLoading 由父级控制；返回 true / false / null（dismiss）三态
