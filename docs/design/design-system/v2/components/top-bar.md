# HanaTopBar

> Generated 2026-04-28 from DESIGN.md v2 + widget-pattern-inventory.md
> Lib path (Phase 5 实施): `lib/core/widgets/hana_top_bar.dart`

## 一句话定位
v2 顶部栏：**实色 surfaceContainerHigh + 滚动时下方 0.5px outline @ 30% 细线**——彻底告别 v1 的 `BackdropFilter blur(12)` 雾面玻璃工程债（13 文件清算对象之一）。

## Anatomy
```
  ┌────────────────────────────────────────┐
  │  [leading]   Title · title (18)   [actions] │   高 56 + SafeArea top
  └────────────────────────────────────────┘
  ─────────────────────────────────────────── ← 0.5px outline @ 30%（仅滚动时出现）
   ↑ surfaceContainerHigh #EAE6DD 实色（不透明）
```

- 高度: 56dp + SafeArea top inset
- 内边距: 水平 `spacing.md` (16)
- 标题左对齐到 `spacing.md`（**不**居中）— 编辑级不对称原则
- 滚动 detector: `NotificationListener<ScrollNotification>` 检测 offset > 0 时显示底线

## Variants
- **default**: 标题左对齐 + 可选 leading + 可选 actions
- **large**: hero 屏顶部使用，标题升级为 `display-xl` (40)，高度 96，配 96px+ 右侧留白
- **transparent**: 用于 onboarding / lock screen 全屏背景；无背景色、无底线

## Props（Flutter API）
```dart
class HanaTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HanaTopBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.variant = HanaTopBarVariant.defaultBar,
    this.scrollController,
    this.semanticLabel,
  });
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final HanaTopBarVariant variant;
  final ScrollController? scrollController; // 监听滚动出现底线
  final String? semanticLabel;

  @override
  Size get preferredSize; // 56 (default) / 96 (large)
}

enum HanaTopBarVariant { defaultBar, large, transparent }
```

## States
- **at-top** (offset ≤ 0): 无底线，仅 surface 实色
- **scrolled** (offset > 0): 底部出现 0.5px outline @ 30% 细线，`motion-instant` 80ms 淡入
- **disabled** / **loading**: 不存在 — TopBar 永远可见，状态由 actions 表达

## Tokens 引用
- background (default / large): `HanaTokens.surfaceContainerHigh(context)` 实色
- background (transparent): `Colors.transparent`
- title: `HanaTokens.ink(context)` title (18) — large variant 用 `display-xl` (40)
- icon (leading / actions): `HanaTokens.ink(context)` 24dp
- scrolled border: `HanaTokens.outline(context)` @ 30% **0.5px**（不是 1px — 更克制）
- shadow: **none**（永远 elev-0）
- backdrop blur: **forbidden**（v2 明确告别）
- motion (border fade): `HanaTokens.motion.instant` (80ms)

## Do's and Don'ts
- ✅ 标题左对齐到 `spacing.md`（v1 居中 → v2 偏左）
- ✅ 滚动底线仅在 offset > 0 时出现，至顶时消失
- ✅ large variant 右侧留白 ≥ 96px（不要把 actions 顶到标题旁边）
- ❌ `BackdropFilter` / `ImageFilter.blur` —— **任何形式都禁止**
- ❌ `withAlpha((255 * 0.8).round())` 半透明背景（v1 痕迹）
- ❌ `elevation > 0` 或底部 shadow 替代 outline
- ❌ 标题居中（除 transparent variant 全屏背景特殊场景）

## i18n / a11y 注意
- `Semantics(header: true, label: semanticLabel ?? title)` 必填
- ja 标题更长 → 自动 ellipsis；large variant 允许换 1 行
- 触控目标：leading / 每个 action ≥ 44dp，水平间距 ≥ `spacing.sm` (8)
- 屏幕阅读器顺序：leading → title → actions

## v1 替换映射
- inventory #5「Glass / Blur AppBar」**6 处全部清算**（v1 工程债清单 #1）：
  - `timeline_page.dart:35`
  - `settings_detail_page.dart:33`
  - `blood_test/data_page.dart:36`
  - `journal/record_page.dart:77`
  - `notification_settings_page.dart:31`
  - `profile_page.dart:218`
  - 附加：`legal_page.dart:54` · `knowledge_webview_page.dart:90`（合计 8 处实际命中）
- 旧片段：
  ```dart
  PreferredSize(...
    child: ClipRRect(child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: AppBar(backgroundColor: HanaColors.background.withAlpha(204)))))
  ```
- **迁移**: 上述整段 → `HanaTopBar(title: ..., actions: ..., scrollController: _ctrl)`

## v1 → v2 关键告别说明
v1 用 `BackdropFilter blur(12)` 制造"毛玻璃"——这是 iOS 14+ Material 通用语法，但与"杂志感"完全相斥（杂志是印刷品，无玻璃质感）。v2 改用**实色 surfaceContainerHigh**（米灰）—— 与 background 月白形成 6 个明度差，眼睛能识别"这是顶栏"，但不靠模糊背景内容。底部 0.5px outline @ 30% 仅在滚动时出现，是杂志目录页"翻页边线"的隐喻。

## Flutter 实现提示
- 实现 `PreferredSizeWidget`，`preferredSize` 按 variant 返回不同高度
- 滚动监听：内部包裹 `NotificationListener<ScrollNotification>` 而非依赖外部传 `ScrollController`（fallback 到 `PrimaryScrollController.of(context)`）
- 底线用 `AnimatedOpacity(opacity: _scrolled ? 1 : 0, duration: motion.instant, child: Container(height: 0.5, color: outline.withOpacity(0.3)))`
- **绝不**继承 `AppBar` —— 直接 `Material(color: ...) > SafeArea > Row` hand-roll，避免 M3 主题注入 elevation tint / blur surface
- transparent variant 直接返回 `SizedBox(height: kToolbarHeight + safeAreaTop)` 占位
