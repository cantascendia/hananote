# Auth Wrapper 屏 v2 视觉与流程规范

> Generated 2026-04-29
> 路由壳 + 启动 / 解锁过渡仪式
> 屏幕：`lib/features/auth/presentation/pages/auth_wrapper_page.dart`
> 上游基准：`docs/design/design-system/v2/{tokens.md,principles.md}` + `docs/design/screens/auth-wrapper/critique-v1.md` + `docs/design/ux-copy-v2/copy-revisions.md`

---

## 1. 设计意图

`AuthWrapperPage` 是一个**路由壳**——它本身不承担"内容"，但它承担**两次过渡**：① 冷启动到解锁屏的扉页前页；② 解锁成功到 `/today` 或 `/onboarding` 的"翻开瞬间"。critique-v1 已经判定 v1 在这两次过渡上**完全失语**——默认 `CircularProgressIndicator` 把"翻开内刊"的仪式感降级为"普通 Flutter app 在 loading"。

v2 修复的核心是**把 0.4 秒的过渡时间从"loading"重定义为"扉页"**——这不是工程优化（实际加载耗时不变），而是**叙事重构**：用户在冷启动看到的不再是工具的初始化，而是"这本内刊正在被翻开前的一秒"。同样，解锁成功的瞬间也是"翻开"——而不是"切换路由"。

这一屏的代码改动极小（净增约 7 行），但它修复的是 v2 整套语法的**入口质量**。如果用户在第一秒看到的是 SDK 默认圆环，后续 onboarding / today 屏再精致也已经失了第一印象。

---

## 2. 状态机映射

`AuthCubit.state` 在 wrapper 内的渲染映射（v2 修正）：

| State | v1 渲染 | v2 渲染 | 备注 |
|-------|---------|---------|-----|
| `AuthInitial` | `_LoadingPage`（圆环） | **`_FrontPageView`**（扉页：0.4s 静默 + 0.6s display-md 淡入「内刊。」） | 冷启动第一帧，用户期待品牌 |
| `AuthUnlocking` | `_LoadingPage`（圆环） | **不渲染整屏 wrapper**——交给 `LockScreenPage` / `SetupPage` 自己显示行内 loading 态 | 输 PIN 校验中，保持上下文 |
| `AuthNeedsSetup` / `AuthWiped` | `SetupPage` | `SetupPage` | 不变 |
| `AuthLocked` | `LockScreenPage` | `LockScreenPage` | 不变 |
| `AuthUnlocked` | `Scaffold(Center(CircularProgressIndicator))` | **`_TurnPageView`**（翻开：0.4s 静默 + 0.6s display-md 淡入「翻开。」+ 0.4s 停留 → 路由） | 解锁成功的扉页过渡 |
| `AuthError` | `_LoadingPage` | **`_FrontPageView`** + 顶部 SnackBar（沿用 v1） | 异常 fallback，保持扉页视觉 |

> **关键**：`AuthUnlocking` 在 v2 不再触发 wrapper 切屏——`LockScreenPage` 的 PIN 圆点全填后用 `motion-quick=150ms` 进入"等待校验"态（圆点维持但 keypad opacity 0.4），错误 / 成功后再退出。这避免冷冰冰的"输完 PIN → 整屏圆环 → 跳转"工具节奏。

---

## 3. 屏幕规范

### 3.1 `_FrontPageView`（启动扉页）

**视觉**: 月白 `HanaTokens.background(context)` 实色铺满，无渐变、无图标、无 indicator。屏幕静默 0.4s（纯背景）后，居中**display-md (32/42/-0.3 SemiBold) 黑墨宋体「内刊。」** 用 `motion-deliberate=600ms easeOut` AnimatedOpacity 0→1 淡入。

文字之所以**居中**（而非 v2 默认"左对齐 32px"）的特例理由：扉页前页是"封面前的扉页副本"——杂志装幀里这一页（俗称"半扉页"）传统上居中单字。它不是正文，所以不遵循正文不对称规则。这是 principles.md 原则 3 的一个允许例外，仅限 `_FrontPageView` 和 `_TurnPageView`。

**ASCII wireframe**:
```
┌──────────────────────────────────────┐
│                                      │  ← SafeArea + 月白纯色
│                                      │
│                                      │
│                                      │
│                                      │
│                                      │
│              内刊。                   │  ← display-md 黑墨宋体居中
│                                      │     (静默 0.4s 后淡入 0.6s)
│                                      │
│                                      │
│                                      │
│                                      │
│                                      │
│                                      │
└──────────────────────────────────────┘
```

**用户场景**: 用户点 app icon → app 启动 → `AuthCubit.checkAuthStatus()` 异步检查 secure storage → 此过程典型 200-600ms。在这段时间用户看到「内刊。」黑墨宋体淡入。检查完成后 state 切换到 `AuthLocked` / `AuthNeedsSetup`，wrapper 切屏（`motion-standard=240ms` cross-fade）。

**跨性别敏感性**: 「内刊。」是中性词——它不暴露 HRT / 医疗 / 健康任何信息。在他人窥屏的瞬间，用户的身份完全不被泄露。en/ja 等价文案同样去身份化。

**关键 token**: `display-md` (32/42/-0.3 SemiBold Spectral / 思源宋体 / Noto Serif JP) · `HanaTokens.background` · `HanaTokens.ink` · `motion-deliberate=600ms easeOut`

**关键文案 key**:
- 复用 `onboardingWelcomeSub` 简版 → "内刊。" / "Journal." / "内誌。"（**新增 key 候选 `frontPagePhrase`** — 若 ux-copy 维护者认为不应复用 onboarding 既有 key，则新增；推荐新增以解耦语义）

### 3.2 `_TurnPageView`（解锁后翻开过渡）

**视觉**: 视觉与 `_FrontPageView` **几乎相同**——月白纯色 + 居中 display-md 文字——但文字是「翻开。」（en: "Opening." / ja: "開きます。"），且节奏不同：

1. **0.0s**：纯月白（无文字）。`AuthCubit` 已 emit `AuthUnlocked`。
2. **0.0-0.4s**：静默期。等待 `SettingsBloc.LoadSettingsDashboard` 加载完成。
3. **0.4-1.0s**：「翻开。」淡入（`motion-deliberate=600ms easeOut`）。
4. **1.0-1.4s**：停留（让用户读到这两个字）。
5. **1.4s**：`context.go('/today')` 或 `'/onboarding'`，路由切换默认 `motion-standard=240ms`。

**节奏总长**: 1.4s。比 v1 的"输完 PIN → 立即圆环 → 跳转"慢约 800ms，但**这 800ms 是仪式而非延迟**——用户感受到的是"自己刚刚翻开了一本内刊"，不是"app 在加载"。

**ASCII wireframe**: 同 `_FrontPageView`，仅文字替换为「翻开。」

**用户场景**: 用户在 `LockScreenPage` 输入 6 位 PIN → `AuthCubit.unlock()` 校验通过 → emit `AuthUnlocked` → wrapper 切到 `_TurnPageView` → 1.4s 后路由。注意**第一次冷启动**用户不经过此屏（直接 needs-setup → setup → unlocked → turn），但**每次回访**都会经过。

**跨性别敏感性**: 「翻开。」继续保持中性。en/ja 同样。

**关键 token**: 同 `_FrontPageView`，但增加 `motion-standard=240ms` (路由切换)

**关键文案 key**: **新增 `turnPagePhrase`** → "翻开。" / "Opening." / "開きます。"（与 `onboardingDone` 「翻开。」/「Open.」/「開く。」语义对称但更状态性，建议独立 key 而非复用——`onboardingDone` 是按钮 label，`turnPagePhrase` 是状态文字）

### 3.3 状态切换 widget tree（Flutter 伪代码）

```dart
return BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    return AnimatedSwitcher(
      duration: HanaTokens.motion.standard, // 240ms
      switchInCurve: Curves.easeInOut,
      child: switch (state) {
        AuthInitial() || AuthError() => const _FrontPageView(),
        AuthUnlocking() => _passthroughPrev(), // 让 LockScreen / Setup 自管
        AuthNeedsSetup() || AuthWiped() => const SetupPage(),
        AuthLocked(:final biometricAvailable) =>
          LockScreenPage(biometricAvailable: biometricAvailable),
        AuthUnlocked() => const _TurnPageView(),
      },
    );
  },
);
```

`_passthroughPrev()` 实现：在 `AuthUnlocking` 时**不切屏**，让前一帧 widget（`LockScreenPage` 或 `SetupPage`）继续可见，由它们自己处理"校验中"视觉态。技术实现可在 wrapper 维护 `_lastNonUnlockingState` 缓存。

---

## 4. 跨性别敏感性总览

- **零身份暴露**：扉页 / 翻开过渡的所有文字都不含 "HRT / 健康 / 用药 / journal of …" 等可暴露医疗身份的词。
- **零问候个人化**：不显示 "你好 / Welcome back, {name}" 等带称呼的文字（这类放在 lock-screen 解锁后的 today 屏，且必须是用户主动选择的）。
- **可禁用扉页**（P2）：未来可在 settings 加 `frontPageEnabled` 开关，关闭后冷启动 → 0.4s 月白 → 直接路由（无文字），适合需要更高隐私级别的用户（如同家共住未出柜）。

---

## 5. 关键 token 与文案 key 汇总

| 类别 | Token / Key | 值 / 用途 |
|------|-----------|----------|
| Color | `HanaTokens.background` | 月白 `#F4F1EA` (light) / 暖深棕灰 `#1C1A18` (dark) |
| Color | `HanaTokens.ink` | 墨色 `#1C1A18` (light) / 月白 `#E8E4DB` (dark) |
| Type | `display-md` | 32/42/-0.3 SemiBold（Spectral / 思源宋体 / Noto Serif JP）|
| Motion | `motion-deliberate` | 600ms easeOut — 文字淡入 |
| Motion | `motion-standard` | 240ms easeInOut — 路由切换 |
| Copy key (新增) | `frontPagePhrase` | "内刊。" / "Journal." / "内誌。" |
| Copy key (新增) | `turnPagePhrase` | "翻开。" / "Opening." / "開きます。" |

— 完 —
