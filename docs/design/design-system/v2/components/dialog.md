# HanaDialog

> Generated 2026-04-28 from DESIGN.md v2 + widget-pattern-inventory.md
> Lib path (Phase 5 实施): `lib/core/widgets/hana_dialog.dart`

## 一句话定位
v2 极少使用的居中拦截弹窗：**仅限 destructive 高敏操作**（删除日记 / 重置数据 / 注销账号）。所有非破坏性确认都走 HanaBottomSheet——dialog 是"红线"，不是日常。

## Anatomy
```
        scrim (ink @ 32%)
   ┌────────────────────────────┐
   │                            │
   │  Title · headline · ink    │   padding lg (32) 全围
   │                            │
   │  Body · body · inkSecondary│
   │  「删除后不可恢复。\n      │
   │   仍要继续？」             │
   │                            │
   │   [Cancel ghost] [Confirm  │   actions 右对齐
   │                destructive]│   spacing.md (16) 间隔
   │                            │
   └────────────────────────────┘
   ↑ 4px radius / surfaceContainerLowest
   ↑ 宽度 max(min(屏宽 - 64, 360), 280)
```

## Variants
- **destructive** (默认且唯一): 红线确认。Confirm 按钮用 `HanaButton(variant: destructive)` + 朱砂文字。
- *(不提供 info / success variant —— 这些用 HanaBottomSheet 或 HanaToast)*

## Props（Flutter API）
```dart
class HanaDialog extends StatelessWidget {
  const HanaDialog._({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
  });
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// 唯一暴露的入口，强制走 destructive 语义。
  static Future<bool> confirmDestructive(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
  });
}
```

## States
- **entering**: `motion-standard` 240ms 中心 fade + scale 0.96→1.0
- **default**: 静置，scrim 拦截背景点击
- **submitting**: confirm 按钮显示 `isLoading`，cancel 仍可点
- **dismissing**: 240ms fade out

## Tokens 引用
- background: `HanaTokens.surfaceContainerLowest(context)`
- title: `HanaTokens.ink(context)` headline (24)
- body: `HanaTokens.inkSecondary(context)` body (15)
- confirm: `HanaButton(variant: destructive)` → `HanaTokens.error(context)` 文字
- cancel: `HanaButton(variant: ghost)` → `HanaTokens.ink(context)` 文字
- scrim: `ink @ 32%`
- radius: `HanaTokens.radius.card` (4)
- padding: `spacing.lg` (32) 全围
- shadow: **none**（dialog 居中、scrim 已建立层级，不需阴影）

## Do's and Don'ts
- ✅ 文案：第三人称陈述 + 句号收尾。「删除后不可恢复。\n仍要继续？」
- ✅ Confirm 在右、Cancel 在左（西文阅读顺序；ja/zh 也一致 — RTL 不在范围）
- ✅ 默认聚焦 Cancel（防止误触摧毁数据）
- ❌ 用 dialog 显示成功 / 信息（→ HanaToast）
- ❌ 用 dialog 收集表单输入（→ HanaBottomSheet variant: form）
- ❌ "确定 / 取消"——改成动词具体化："删除 / 不删除"

## i18n / a11y 注意
- `AlertDialog` 默认语义保留：`Semantics(scopesRoute: true, namesRoute: true)` 屏幕阅读器进入朗读 title
- 触控目标 ≥ 44dp，按钮间隔 ≥ `spacing.md` 防止误触
- ja 文案常更长（"削除すると元に戻せません"）→ 不限制 message 行数，dialog 高度自适应
- 焦点陷阱：tab 仅在 cancel / confirm 间循环

## v1 替换映射
- inventory #7「Confirm Dialog」**仅 destructive 子集** 保留在 dialog.md，其余迁 HanaBottomSheet
  - 真 destructive：`measurement_page:198` (删除测量) · `photo_page:154` (删除照片) · `photo_view:242` (删除照片) · `inventory:171` (删除药品) · `profile_page:64` (注销账号) · `profile_page:448` (重置)
  - 非 destructive 改 HanaBottomSheet：`drug_list:129` · `settings_detail:488`
- **迁移**: `showDialog(builder: (_) => AlertDialog(...))` (destructive only) → `await HanaDialog.confirmDestructive(context, title: ..., message: ..., confirmLabel: l10n.delete, cancelLabel: l10n.cancel)`

## Flutter 实现提示
- 基于 `showDialog` + 自定义 `Dialog(child: Container(...))` 而非 `AlertDialog`（避免 M3 主题污染圆角和 padding）
- `barrierColor: HanaTokens.ink(context).withOpacity(0.32)`
- enter scale + fade 用 `transitionBuilder`：`ScaleTransition(scale: Tween(0.96, 1.0), child: FadeTransition(...))`
- 强制 `barrierDismissible: false`（destructive 不可点 scrim 关闭，必须显式选择）
- 静态方法 `confirmDestructive` 返回 `Future<bool>`，**永远 resolve**（false on cancel/back，true on confirm）—— 调用方不需 null-check
