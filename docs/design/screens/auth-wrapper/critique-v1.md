# Auth Wrapper 屏 v1 现状 Design Critique

> **审视范围**: `lib/features/auth/presentation/pages/auth_wrapper_page.dart`（103 行）
> **对照基准**: DESIGN.md（v2 编辑级东亚） + tokens.md + principles.md（5 原则 + 严禁清单）
> **权重提示**: Auth Wrapper 是用户**每次冷启动 app** 第一帧看到的屏幕——视觉权重 ×2，但内容极少（路由壳）
> **生成时间**: 2026-04-29

---

## 概述

`AuthWrapperPage` 严格说不是"一屏"，是一个**路由壳 + 多 Bloc Listener 协调器**。它根据 `AuthCubit.state` 在 setup / lock / 加载占位之间切换，并在 `AuthUnlocked` 后监听 `SettingsBloc` 决定走 `/onboarding` 还是 `/today`。整个文件只有一个真正可见的 UI 组件：`_LoadingPage`，它是一个 `Scaffold + Center(CircularProgressIndicator)`——共 4 行代码。

正因为它是壳，v1 的违规面积反而**集中且严重**：用户冷启动 app 看到的第一帧（约 0.4-1.2 秒）是 Material 标准 `CircularProgressIndicator`——一个不停旋转的紫色圆环，背景是 Material 默认 surface（白色 / Sakura 主题下的浅粉）。整个 v2「翻开一本内刊」的扉页隐喻在这一帧崩塌——用户看到的不是品牌，是**一个普通的 Flutter app 在 loading**。

整屏共扫出 **5 处 v2 严禁项 + 2 处节奏盲点**，但因为内容极少，修复成本也极小（约 20 行代码）。

---

## 第一印象 5 秒原则

`AuthWrapperPage` 在两个时刻可见：
1. **冷启动**：app icon 启动后 → `checkAuthStatus()` 异步检查 → 此时 state = `AuthInitial` 或 `AuthUnlocking`，渲染 `_LoadingPage`。典型耗时 200-600ms（取决于设备 + secure storage 速度）。
2. **解锁后**：用户在 `LockScreenPage` 输入正确 PIN → state = `AuthUnlocked` → 文件 L82-84 渲染 `Scaffold(body: Center(child: CircularProgressIndicator()))`，等待 `SettingsBloc` 加载完成（典型 100-300ms）。

两次都是 ≤ 1s 的过渡帧，**但都是用户认知中的"app 第一秒"**。v1 在这一秒呈现：
- **视觉**：Material 默认 indeterminate 圆环旋转动画，配色由 Theme.colorScheme.primary 派生，Sakura 主题下是粉色。
- **文案**：零文案——纯进度指示。
- **节奏**：indicator 立即出现（无淡入），随 state 切换瞬间消失（无淡出）。
- **品牌存在感**：零。用户看到的是 Flutter SDK 默认 widget，不是 HanaNote。

v2 的期望（从 onboarding spec.md §1 + DESIGN.md §6 庆祝节奏推导）：**冷启动应有 0.4s 的静默 + display-md「内刊。」或「HanaNote。」黑墨宋体淡入 0.6s**，作为扉页前的呼吸。这是一种**仪式感的"翻开前"**——不是 loading，是用户从外部世界回到这本内刊的过渡。

---

## v2 五原则违规点（带 file:line）

### 原则 1: 一抹强色（黛蓝 ≤ 3 处 / 屏）

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 1 | `CircularProgressIndicator` 默认色取自 `theme.colorScheme.primary`，在 Sakura 主题下是粉色，在 v2 主题下会变成黛蓝旋转——但**整屏只一个 indicator，黛蓝在动**等于把"稀缺色"做成"屏保动画" | L83, L99 | 删除 indicator。改为静默 0.4s 后 display-md「内刊。」（或「HanaNote。」）墨色宋体淡入。零旋转、零黛蓝 |

### 原则 2: 调和层次胜过投影

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 2 | 默认 `Scaffold` 背景取自 `theme.scaffoldBackgroundColor`（v1 Material 标准），在 v2 应是月白 `#F4F1EA` 实色——**v1 没显式声明，依赖 Theme 派生**，主题切换时可能闪不同底色 | L98-100 | 显式 `backgroundColor: HanaTokens.background(context)`，避免 Theme 依赖 |

### 原则 3: 编辑级不对称（居中是默认懒惰）

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 3 | indicator 居中 `Center(child: ...)` | L83, L99 | v2 即使是壳屏，hero 文字也应**左对齐 32px**——但 wrapper 仅 0.4s 静默 + 0.6s 淡入，居中**仅在此特例可接受**（属于扉页前的"前页"，不算正文页面），仍建议左对齐保持系统一致性 |

### 原则 4: 慢节奏与留白

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 4 | `_LoadingPage` 立即显示 indicator（无静默 / 无淡入），路由切换瞬间替换（无淡出）——节奏是"工具感"而非"仪式感" | 整文件 | 引入 0.4s 静默（pure background） + 0.6s display-md 淡入（`motion-deliberate=600ms easeOut`）。`AuthUnlocked → SettingsLoaded` 路由前再 0.4s 静默，让用户感到「翻开了」 |

### 原则 5: 内容即装饰

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 5 | 零品牌呈现——用户在冷启动第一帧看不到 HanaNote 的任何痕迹（默认 indicator 是 SDK 装饰，不是 v2 装饰） | 整文件 | 用 display-md 黑墨宋体「内刊。」（或选择 hero 副文案 "私人健康内刊。仅你可见。"）作为"装饰"——文字本身就是 v2 的全部装饰 |

---

## 节奏 / 状态切换分析

`AuthWrapperPage` 通过 `BlocBuilder<AuthCubit, AuthState>` 在 5 种 state 间切换 widget tree（L77-87）：

| State | 当前渲染 | 频次 | 用户场景 |
|-------|---------|------|---------|
| `AuthInitial` / `AuthUnlocking` | `_LoadingPage`（圆环） | **每次冷启动** | 用户刚点 app icon |
| `AuthNeedsSetup` / `AuthWiped` | `SetupPage` | 首启 / 重置后 | 第一次设置 PIN / 忘记 PIN 后 |
| `AuthLocked` | `LockScreenPage` | **每次回访** | 用户输 PIN |
| `AuthUnlocked` | `Scaffold(Center(CircularProgressIndicator))` (L82-84) | 每次解锁 → 路由 | 解锁瞬间 |
| `AuthError` | `_LoadingPage` (L85) | 极少 | 异常 fallback |

**节奏盲点**:

- **盲点 A**：`AuthInitial` 和 `AuthUnlocking` 共用 `_LoadingPage`——**两者用户场景完全不同**。`AuthInitial` 是冷启动（用户期待看到品牌），`AuthUnlocking` 是用户刚点 PIN 数字（用户期待"在校验"反馈）。共用同一个圆环屏，把"启动仪式"和"输入校验"混为一谈。修复：`AuthUnlocking` 不应渲染整屏壳，应让 `LockScreenPage` 自己显示行内 loading 态（PIN 圆点淡化或顶部 1px 进度条），保持上下文不丢失。
- **盲点 B**：`AuthUnlocked` 状态下 L82-84 的 `Scaffold(Center(CircularProgressIndicator))` 是**第二处 loading 屏**——和 `_LoadingPage` 内容一样但代码不复用。这是工程债，但更严重的是**用户在解锁瞬间看到圆环**——他刚输完 PIN 期待"翻开"，结果先看到 loading。修复：解锁后保留 `LockScreenPage` 视觉（PIN 已全输入的圆点状态）+ 0.4s 静默 + display-md「内刊。」淡入，再路由——这就是 spec 要求的"扉页过渡"。

---

## 跨性别敏感性检查

Auth Wrapper 内**无文案**，无敏感性盲点——但**沉默本身**对未出柜 / 高隐私需求用户是一种保护：用户不希望在锁屏前听到任何"健康 / HRT / 医疗"提示词。v2 spec 选择「内刊。」而非「HanaNote 健康记录。」作为扉页字符，正是为了在他人窥屏的瞬间仍保持中性身份。

**保留盲点 #1**: 即使 v2 用「内刊。」，仍需考虑**完全静默选项**——用户在设置中可禁用扉页文字，仅显示 0.8s 月白纯色后直接路由。该选项放入 P2 优先级。

---

## v1 → v2 修复 size

| 项 | v1 行数 | v2 预期行数 | 备注 |
|---|--------|------------|------|
| `_LoadingPage` widget | 10 | ~25（加 AnimatedOpacity + Text） | 引入静默 + 淡入逻辑 |
| `AuthUnlocked` 占位 (L82-84) | 3 | 0 | 删除——交给 LockScreenPage / SetupPage 自己处理过渡 |
| 主 build | 75 | ~75（不变） | 仅 widget 切换逻辑保持 |
| 总计 | 103 | ~110 | 净增极小 |

修复成本极低——这是 9 个 auth 文件中最快产出的一个。

---

## 优先级建议

- **P0（spec 必含）**: 违规 #1（删 indicator）+ #5（加 display-md 文字） — 这两项是用户感知品牌的关键
- **P1（spec 强烈推荐）**: 违规 #4（节奏 0.4s 静默 + 0.6s 淡入）+ 盲点 B（解锁后扉页过渡）
- **P2（可选）**: 违规 #2（显式 background）+ 完全静默设置选项

— 完 —
