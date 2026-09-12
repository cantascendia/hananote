# HanaCelebration

> Generated 2026-04-28 from DESIGN.md v2 + widget-pattern-inventory.md
> Lib path (Phase 5 实施): `lib/core/widgets/hana_celebration.dart`
> 替代 v1: `lib/core/widgets/petal_celebration.dart`（**整文件删除**）

## 一句话定位
v2 仪式反馈：**屏幕静默 0.4s → 上方淡入一行宋体「今日已记。」→ 停留 0.6s → 淡出 1.2s**——总时长约 3.4s，无粒子、无渐变、无声音、不挡操作。仪式感来自"等待"，不是"爆发"。

## Anatomy
```
  ┌────────────────────────────────────┐
  │                                    │  ← 顶部留白 spacing.xl (64) + SafeArea
  │     今日已記。                     │  ← display-md (28-30) 宋体 SemiBold
  │     (黛蓝 #1F3A5F · CJK 宋体 Medium)  textAlign: left, padding-left spacing.lg (32)
  │                                    │
  ├────────────────────────────────────┤
  │                                    │
  │      [屏幕原内容仍可见、可操作]    │  ← 月白背景 95% 不透明覆盖（不阻塞）
  │                                    │     IgnorePointer: true (装饰层穿透)
  │                                    │
  └────────────────────────────────────┘
```

文字位置：屏幕上方 1/3 处，左对齐到 `spacing.lg` (32) — **不居中**（编辑级不对称）。

## Variants
- **default**: 「今日已记。」("今日已記。" / "今日も記しました。" / "Recorded.")
- *(无其他 variant — 庆祝是稀缺动作，所有"记一次"完成共用同一仪式；不同事件不同文案就破坏了"日记的统一节拍"）*

文案由调用方从 ARB 传入（key 例: `celebration.recorded`），组件层不内置文案。

## Props（Flutter API）
```dart
class HanaCelebration extends StatefulWidget {
  const HanaCelebration._({
    super.key,
    required this.message,
  });
  final String message;

  /// 唯一入口：在当前 BuildContext 上覆盖 OverlayEntry，~3.4s 后自动移除。
  /// 不阻塞操作（IgnorePointer 保持 true，让用户继续操作底层）。
  static Future<void> trigger(
    BuildContext context, {
    required String message,
    bool haptic = true,
  });
}
```

## States
- **idle (0–400ms)**: OverlayEntry 已挂载，但内容 opacity = 0；屏幕静默
- **fading-in (400–1600ms)**: opacity 0 → 1，`motion-deliberate` (1200ms easeOut)
- **holding (1600–2200ms)**: opacity = 1，停留 600ms
- **fading-out (2200–3400ms)**: opacity 1 → 0，`motion-fade` (1200ms linear)
- **disposed**: OverlayEntry 自动 remove

总时长 ~3.4s（含静默 0.4s）。震动 `HapticFeedback.lightImpact()` 在 idle 0ms 触发（可选）。

## Tokens 引用
- text color: `HanaTokens.primary(context)` (黛蓝 #1F3A5F / dark #7A9CC2)
- text style: `display-md` 宋体 Medium（落点 28-30 / line 38）
  - 中文: `Source Han Serif SC Medium`
  - 日文: `Noto Serif JP Medium`
  - 西文: `Spectral SemiBold`
- background overlay: `HanaTokens.background(context)` @ **95%** 不透明度（不挡操作）
- text padding: 上 `spacing.xl` (64) + SafeArea，左 `spacing.lg` (32)
- silence motion: `Duration(milliseconds: 400)` (硬编码常量 `kHanaCelebrationSilence = 400ms`)
- fade-in motion: `HanaTokens.motion.deliberate` (1200ms easeOut)
- hold motion: 600ms
- fade-out motion: `HanaTokens.motion.fade` (1200ms linear)
- haptic: `HapticFeedback.lightImpact()` (可选)
- sound: **none**（v2 明确无声）

## Do's and Don'ts
- ✅ 一行四字宋体承担 v1 整套花瓣粒子的情感重量
- ✅ 95% 半透明背景让"屏幕静下来一秒"，但**不**阻塞用户继续操作
- ✅ 文案左对齐 + 句号收尾 — 编辑级语法
- ❌ 粒子 / 花瓣 / confetti / 心心 / 烟花（**v2 严禁清单第一条**）
- ❌ 渐变背景 / 光晕 / 闪烁
- ❌ 声音（"叮~"）
- ❌ emoji（✨🎉🌸 全部出局）
- ❌ 居中对齐
- ❌ 文字配 ✓ 图标 — 破坏宋体克制感

## i18n / a11y 注意
- `Semantics(liveRegion: true, label: message)` — 屏幕阅读器自动朗读
- 文案 ARB key 例：`celebration.recorded`（zh: "今日已记。" / ja: "今日も記しました。" / en: "Recorded."）
- ja 文案略长 → display-md 自动缩为 display-sm (24)，不换行
- 触控：overlay 不拦截操作（装饰层 `IgnorePointer(ignoring: true)`；操作层穿透）
- 用户可在设置中关闭震动（调用方传 `haptic: false`）

## v1 替换映射
- v1: `lib/core/widgets/petal_celebration.dart` 整文件
  - 用 `flutter_animate` + 自定义 `Particle` widget 撒花瓣 + 粉色渐变背景 + `playSound('petal_drop.mp3')`
  - 调用点: `today_page.dart:312` (服药完成) · `journal_edit_page.dart:218` (日记保存) · `measurement_edit_page.dart:189` (测量保存)
- **迁移**:
  - 删除 `petal_celebration.dart` 整文件
  - 删除 `assets/sounds/petal_drop.mp3`（如有）
  - 删除 `pubspec.yaml` 中的 `flutter_animate` 依赖（如仅 petal 用）
  - 调用点 `PetalCelebration.show(context)` → `HanaCelebration.trigger(context, message: AppLocalizations.of(context)!.celebrationRecorded)`

## v1 → v2 关键告别说明
v1 用粉色花瓣 + 音效 + 1.5s 粒子动画告诉用户"你做到了！"——这是哄孩子的语法，配合"樱色温柔守护者"叙事。v2 彻底切割：**屏幕静默 0.4s** 是核心 — 这 0.4s 的"无反馈"让用户的注意力从"我刚做了动作"转向"屏幕在准备说什么"，然后宋体「今日已记。」缓慢淡入。这 4 个字承担了所有情感重量，因为它们：① 是衬线宋体（仪式感字体）② 是黛蓝（一抹强色，每屏 ≤ 3 处的稀缺资源）③ 是句号收尾（陈述而非欢呼）。

## Flutter 实现提示
- 基于 `OverlayEntry` 直接挂在 `Overlay.of(context)`，不依赖任何 Scaffold 内部结构
- 动画用 `AnimationController(duration: Duration(milliseconds: 3400))` + 多段 `Interval`：
  - `Interval(0.0, 0.118)` (静默 400ms)
  - `Interval(0.118, 0.471, curve: Curves.easeOut)` (淡入 1200ms)
  - `Interval(0.471, 0.647)` (停留 600ms)
  - `Interval(0.647, 1.0, curve: Curves.linear)` (淡出 1200ms)
- 文字层包裹 `IgnorePointer(ignoring: true)` — 装饰不拦截
- 背景 95% 不透明 `Container(color: HanaTokens.background(context).withOpacity(0.95))` 同样 `IgnorePointer`，让用户能继续点击底层
- 自动 dispose：动画完成 → `controller.dispose()` + `entry.remove()`
- 支持快速连续触发：新 trigger 立即 dispose 上一个 entry（不堆叠）
- **绝不**引入 `confetti` / `flutter_animate` / 任何粒子库
