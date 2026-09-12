# HanaBottomSheet

> Generated 2026-04-28 from DESIGN.md v2 + widget-pattern-inventory.md
> Lib path (Phase 5 实施): `lib/core/widgets/hana_bottom_sheet.dart`

## 一句话定位
v2 默认弹层语法（替代标准 iOS / AlertDialog）：从底部升起的"小册子"，**16px 圆角是全系统唯一保留的大圆角例外**——符合手账握持感。

## Anatomy
```
        ───────                      ← drag handle 32x4 / r-pill
                                       margin-top spacing.sm (8)
  ┌──────────────────────────────┐
  │                              │
  │  Title · headline (24)       │  spacing.lg (32) 顶部
  │                              │
  │  [content]                   │  padding 水平 md (16)
  │                              │
  │  [actions: HanaButton...]    │
  │                              │
  └──────────────────────────────┘
   ↑ 16px radius (顶角)，底角直角到屏底
   ↑ surfaceContainerLowest 背景
   ↑ scrim ink @ 32% 覆盖背景
```

## Variants
- **action-sheet**: 标题 + 一组操作 ListTile（替代 iOS Action Sheet）
- **form**: 标题 + 一组表单输入 + 底部确认按钮
- **info**: 标题 + 段落正文 + 单一关闭按钮（替代标准 AlertDialog 信息态）
- **picker**: 标题 + 选择列表（日期 / 单选）

## Props（Flutter API）
```dart
class HanaBottomSheet extends StatelessWidget {
  const HanaBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showHandle = true,
    this.isDismissible = true,
    this.maxHeightFraction = 0.85,
  });
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showHandle;
  final bool isDismissible;
  final double maxHeightFraction; // 屏高占比上限

  static Future<T?> show<T>(BuildContext context, {required HanaBottomSheet sheet});
}
```

## States
- **entering**: `motion-standard` 240ms easeInOut 上移 + scrim 淡入
- **default**: 静置
- **dragging**: 跟随手指；松手回弹或关闭（速度阈值）
- **dismissing**: 240ms 下移 + scrim 淡出

## Tokens 引用
- background: `HanaTokens.surfaceContainerLowest(context)`
- handle: `HanaTokens.outline(context)` @ 50% (32×4 px, r-pill)
- title: `HanaTokens.ink(context)` headline
- scrim: `ink @ 32%` (M3 `scrim` slot)
- radius: 顶部 16 (硬编码常量 `kHanaBottomSheetRadius = 16`，**不**走 `radius.card` 4)
- shadow: `elev-high` (`0 4px 16px rgba(28,26,24,0.06)`) — v2 唯一允许阴影场景
- enter motion: `HanaTokens.motion.standard`
- padding: 水平 `spacing.md` (16)，顶部 `spacing.lg` (32)，底部 SafeArea + `spacing.lg`

## Do's and Don'ts
- ✅ 取代 v2 中**所有** `AlertDialog` / `showCupertinoDialog` 用法（destructive 操作除外，见 dialog.md）
- ✅ drag handle 视觉提示可关闭（除非 `isDismissible: false`）
- ✅ 内容超长滚动，外层不滚动——sheet 高度 ≤ 85% 屏高
- ❌ 底角加圆角（只顶角 16，底角直角）
- ❌ scrim 用纯黑（用 ink 色 32%）
- ❌ 内嵌另一个 BottomSheet（→ 重新设计流程）

## i18n / a11y 注意
- `Semantics(scopesRoute: true, namesRoute: true, label: title)` — 屏幕阅读器进入时朗读 title
- ESC / 物理返回键关闭（除非 `isDismissible: false`）
- 触控目标：handle 不计入操作目标，但 sheet 内按钮 ≥ 44dp
- 长 ja 标题允许换行，sheet 高度自动撑开

## v1 替换映射
- inventory #7「Confirm Dialog」**8 处** 全部迁出（替换为 HanaBottomSheet `info` 或 dialog.md）：`measurement_page:198` · `photo_view:242` · `photo_page:154` · `drug_list:129` · `inventory:171` · `settings_detail:488` · `profile_page:64/448`
- inventory #8「Bottom Sheet (Action Picker)」4 处统一壳：`timeline_page:121` · `photo_page:181` · `dose_action_sheet` · `settings_detail:413`
- **迁移**: `showModalBottomSheet(builder: (_) => Container(...))` → `HanaBottomSheet.show(context, sheet: HanaBottomSheet(title: ..., child: ...))`

## Flutter 实现提示
- 基于 `showModalBottomSheet` + 自定义 `shape: RoundedRectangleBorder(top: 16)` + `useSafeArea: true`
- handle 用 `Container(width: 32, height: 4, decoration: ...)`，绝不用 Material 默认 grabber
- scrim 颜色覆盖 `barrierColor: HanaTokens.ink(context).withOpacity(0.32)`
- enter motion 走 `transitionAnimationController` + `Curves.easeInOut`
- `maxHeightFraction` 用 `constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * fraction)`
- **不要**继承 `BottomSheet`（M3 默认 16px 角 + Material 风格 padding 都不对，全部 hand-roll）
