# HanaPullRefresh

> Generated 2026-04-29 from screen specs (today / record / timeline)
> Lib path (Phase 5 实施): `lib/core/widgets/hana_pull_refresh.dart`

## 一句话定位
v2 下拉刷新：**顶部 1px 黛蓝细进度线 + 一行 mono "刷新中。"**——彻底替代 Material 圆环 `RefreshIndicator`。圆环是 Material 痕迹，进度线是杂志报刊感。

## Anatomy
```
   ────────────────────────────  ← 1px 黛蓝细线（pull 时按拉动距离填充进度，
                                    refresh 时 indeterminate 走灯）
   refreshing 时下方一行：
   "刷新中。" · mono 14 · inkSubdued
   ──────────────────────────────────────  ← 内容滚动区原样
```

## Variants
- 仅一种：顶部细线 + 文本。无装饰图标、无圆环、无水滴变形。

## Props（Flutter API）
```dart
class HanaPullRefresh extends StatefulWidget {
  const HanaPullRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.triggerDistance = 80,
    this.refreshingLabel = '刷新中。',
    this.semanticLabel,
  });
  final Future<void> Function() onRefresh;
  final Widget child;                    // 通常是 ListView / CustomScrollView
  final double triggerDistance;          // 触发距离（默认 80dp）
  final String refreshingLabel;          // ARB 来源（"刷新中。" / "Refreshing."）
  final String? semanticLabel;
}
```

## States
- **idle**: 不可见，0 高度
- **pulling**: 顶部 1px 线按拉动比例填充（0% → 100%），高度 1px 始终
- **armed**: 拉到 triggerDistance，进度线满，mono 文本 fade in
- **refreshing**: 进度线 indeterminate（左→右循环 1.2s linear）+ "刷新中。" 显示
- **completing**: `onRefresh` future 完成 → 进度线和文本 fade out 240ms

## Tokens 引用
- 进度线 color: `HanaTokens.primary(context)`
- 进度线 height: 1px（idle 时 0）
- "刷新中。" style: `HanaTokens.typography.mono.copyWith(color: inkSecondary)`
- 进度线 → 文本 padding: `spacing.xs` (4)
- refreshing indeterminate cycle: 1200ms linear（`motion.fade`）
- enter / exit fade: `motion.standard` 240ms

## Do's and Don'ts
- ✅ 替换所有 `RefreshIndicator` 调用（Today / Record / Timeline 等）
- ✅ `onRefresh` 必须返回 `Future<void>` — 完成后 indicator 自动消失
- ✅ `semanticLabel` 可选；默认朗读 "刷新中。"
- ❌ 添加圆环 fallback（"如未实施则保留 Material 圆环但锁色" 是过渡 spec，正式实现禁止）
- ❌ 在嵌套滚动视图（NestedScrollView 内层）使用 — 只包外层 scrollable
- ❌ 任何水滴 / 樱花粒子装饰

## i18n / a11y 注意
- `Semantics(label: semanticLabel ?? refreshingLabel, liveRegion: true)`
- refreshingLabel 必须来自 ARB
- 触控：拉动手势由 `RawGestureDetector` 处理，与 child scrollable 不冲突

## v1 替换映射
- `today_page.dart` `RefreshIndicator(color: HanaColors.primary)` → `HanaPullRefresh`
- `record_page.dart` 待加（v1 未实现下拉刷新）
- `timeline_page.dart` 同 today
- **迁移**: `RefreshIndicator(onRefresh: ..., color: ..., child: ListView(...))` → `HanaPullRefresh(onRefresh: ..., child: ListView(...))`

## Flutter 实现提示
- 基于 `NotificationListener<ScrollNotification>` 监听 `OverscrollNotification` / `ScrollUpdateNotification`，**不**继承 `RefreshIndicator`
- 进度线用 `Stack` + `Positioned(top: 0, left: 0, width: progress * w, height: 1)` 表示进度
- refreshing 状态切到 `LinearProgressIndicator(minHeight: 1, ...)`（M3 默认 4px → 强制 1px）
- "刷新中。" 用 `AnimatedOpacity` 与状态切换 fade
- `child` 必须是可滚动的 widget（内部不再额外 wrap `Scrollable`）
- 完成后调用 `onRefresh()` 的 `Future` `.whenComplete(() => setState(...))` 切回 idle
