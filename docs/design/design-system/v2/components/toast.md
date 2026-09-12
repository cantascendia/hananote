# HanaToast

> Generated 2026-04-28 from DESIGN.md v2 + widget-pattern-inventory.md
> Lib path (Phase 5 实施): `lib/core/widgets/hana_toast.dart`

## 一句话定位
v2 短暂反馈（替代 SnackBar）：从底部升起的"便签条"，**4px 圆角、无投影、3 秒自动消失、不阻塞操作**——一行陈述句，不打扰阅读。

## Anatomy
```
  ┌──────────────────────────────────────┐
  │  [icon?]  Message · body-sm · onAccent │   高 48 + SafeArea bottom
  └──────────────────────────────────────┘
   ↑ surfaceContainerHigh 实色（info）
   ↑ primary 实色（success / 主反馈）
   ↑ error 实色（error）
   ↑ 4px radius、padding 水平 md (16) / 垂直 sm (8)
   ↑ 距底部 SafeArea + spacing.md (16)
   ↑ 距左右 spacing.md
```

## Variants
- **info** (默认): surfaceContainerHigh 背景 + ink 文字 — 通知类信息（"已保存。"）
- **success**: primary 黛蓝背景 + onPrimary 文字 — 操作成功 ≠ 庆祝（庆祝走 HanaCelebration）
- **error**: error 朱砂背景 + onPrimary 文字 — 操作失败 / 网络错误
- **warning**: warning 香灰背景 + onPrimary 文字 — 极少用，达到边界提示

## Props（Flutter API）
```dart
class HanaToast {
  HanaToast._();

  static void show(
    BuildContext context, {
    required String message,
    HanaToastVariant variant = HanaToastVariant.info,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    String? semanticLabel,
  });

  static void dismiss(BuildContext context);
}

enum HanaToastVariant { info, success, error, warning }
```

## States
- **entering**: `motion-standard` 240ms 从底向上滑入 + fade
- **default**: 静置 ≤ duration（默认 3s）
- **action-pressed**: 立即 dismiss
- **dismissing**: 240ms 向下滑出 + fade

只允许同屏 1 个 toast — 新 toast 立即替换旧的（不堆叠）。

## Tokens 引用
- background (info): `HanaTokens.surfaceContainerHigh(context)`
- background (success): `HanaTokens.primary(context)`
- background (error): `HanaTokens.error(context)`
- background (warning): `HanaTokens.warning(context)`
- foreground (info): `HanaTokens.ink(context)`
- foreground (success/error/warning): `HanaTokens.onPrimary(context)` (#FBF8F2，不是纯白)
- text style: `body-sm` (13/20/0)
- icon size: 16dp
- radius: `HanaTokens.radius.card` (4)
- padding: 水平 `spacing.md` (16) / 垂直 `spacing.sm` (8)
- offset: 距底 SafeArea + `spacing.md`，左右各 `spacing.md`
- shadow: **none**（v2 唯一允许 shadow 的是 BottomSheet）
- enter / exit motion: `HanaTokens.motion.standard`

## Do's and Don'ts
- ✅ 文案一行，句号收尾："已保存。" / "网络异常。" / "导入完成。"
- ✅ success variant 不喧宾夺主 — 不是庆祝（庆祝走 HanaCelebration）
- ✅ error 提供 retry action 时用 `actionLabel: l10n.retry`
- ❌ 多行文本（→ 改用 HanaBottomSheet info）
- ❌ `floatingActionButtonLocation` 上方堆叠多个 SnackBar
- ❌ emoji / 装饰图标
- ❌ duration > 5s（信息长就不该是 toast）

## i18n / a11y 注意
- `Semantics(liveRegion: true, label: semanticLabel ?? message)` — 屏幕阅读器自动朗读
- 触控目标：action 按钮 ≥ 44dp（即使视觉只 32 高，padding 拉到 44）
- ja 文案常更长 → 单行 ellipsis，超长建议改 BottomSheet
- error variant 自动延长 duration 到 5s（让用户看清）

## v1 替换映射
- inventory #19「Snackbar Helper」**18 处**散落使用：
  - `profile_page.dart:23` `_showSnackBar` (自定义 helper)
  - `measurement_page` / `blood_test_edit` / `settings_detail_page` (含 floating) / `photo_page` / `auth_wrapper` / `schedule_editor`
  - 一半 default / 一半 floating，行为不一
- **迁移**:
  - `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))` → `HanaToast.show(context, message: ..., variant: ...)`
  - `_showSnackBar('xxx')` helper 删除，统一走 `HanaToast.show`
  - 错误反馈 `SnackBar(backgroundColor: Colors.red)` → `HanaToast.show(context, variant: error)`

## Flutter 实现提示
- 基于 `OverlayEntry` 而非 `ScaffoldMessenger.showSnackBar`（避免 M3 主题注入 elevation / 边距）
- 单例管理：内部维护 `_currentEntry`，新 toast 调用先 dismiss 旧的再 insert
- enter motion: `SlideTransition(position: Tween(Offset(0, 1), Offset.zero))` + `FadeTransition`
- 自动 dismiss: `Timer(duration, () => dismiss(context))`，action 点击立即取消 timer
- a11y: 用 `Semantics(liveRegion: true)` 让 TalkBack / VoiceOver 立刻读出
- 不接受外部覆盖 background — 颜色完全由 variant 决定（保持系统统一）
