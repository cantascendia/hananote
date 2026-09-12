# Auth Wrapper 屏 v2 工程交付 Handoff

> Generated 2026-04-29
> 给实现工程师（Tech Lead 自交付）的"按图索骥"清单
> 上游：`spec.md` + `critique-v1.md`
> 修改文件：`lib/features/auth/presentation/pages/auth_wrapper_page.dart`（+ 可能 ARB）
> 预计 LOC 净增：~30 行 / 修改 ~10 行

---

## 1. 文件清单

| 文件 | 操作 | 说明 |
|-----|------|-----|
| `lib/features/auth/presentation/pages/auth_wrapper_page.dart` | 修改 | 新增 `_FrontPageView` / `_TurnPageView`；删除 `_LoadingPage` 和 `AuthUnlocked` 圆环占位 |
| `lib/core/l10n/arb/app_zh.arb` / `app_en.arb` / `app_ja.arb` | 新增 2 keys | `frontPagePhrase` / `turnPagePhrase`（见 spec §5） |
| `lib/core/l10n/arb/app_localizations.dart` 等生成文件 | 自动生成 | `flutter gen-l10n` 后产物 |

不需要新增组件 widget——`_FrontPageView` / `_TurnPageView` 是 wrapper 内私有 widget，不进 `lib/core/widgets/`。

---

## 2. 实现步骤

### 步骤 1：新增 ARB keys

`app_zh.arb`:
```json
"frontPagePhrase": "内刊。",
"@frontPagePhrase": {
  "description": "Auth wrapper front page phrase shown during cold-start splash."
},
"turnPagePhrase": "翻开。",
"@turnPagePhrase": {
  "description": "Auth wrapper transition phrase shown after unlock before routing."
}
```

`app_en.arb`:
```json
"frontPagePhrase": "Journal.",
"turnPagePhrase": "Opening."
```

`app_ja.arb`:
```json
"frontPagePhrase": "内誌。",
"turnPagePhrase": "開きます。"
```

执行 `flutter gen-l10n` 生成 `app_localizations*.dart`（不要手动编辑）。

### 步骤 2：替换 `_LoadingPage` 为 `_FrontPageView`

```dart
class _FrontPageView extends StatefulWidget {
  const _FrontPageView();

  @override
  State<_FrontPageView> createState() => _FrontPageViewState();
}

class _FrontPageViewState extends State<_FrontPageView> {
  bool _phraseVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _phraseVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: HanaTokens.background(context),
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: _phraseVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600), // motion-deliberate
            curve: Curves.easeOut,
            child: Text(
              l10n.frontPagePhrase,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600, // SemiBold
                color: HanaTokens.ink(context),
                height: 42 / 32,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 步骤 3：新增 `_TurnPageView`（解锁后过渡）

```dart
class _TurnPageView extends StatefulWidget {
  const _TurnPageView({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_TurnPageView> createState() => _TurnPageViewState();
}

class _TurnPageViewState extends State<_TurnPageView> {
  bool _phraseVisible = false;

  @override
  void initState() {
    super.initState();
    // 0.4s silence → 0.6s fade-in → 0.4s hold → onComplete
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _phraseVisible = true);
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: HanaTokens.background(context),
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: _phraseVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            child: Text(
              l10n.turnPagePhrase,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: HanaTokens.ink(context),
                height: 42 / 32,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 步骤 4：调整 `BlocBuilder` widget tree

将原 `BlocBuilder` body 改为：

```dart
BlocBuilder<AuthCubit, AuthState>(
  buildWhen: (prev, curr) => curr is! AuthUnlocking, // 关键：unlocking 不切屏
  builder: (context, state) {
    return AnimatedSwitcher(
      duration: HanaTokens.motion.standard,
      child: switch (state) {
        AuthInitial() || AuthError() => const _FrontPageView(),
        AuthNeedsSetup() || AuthWiped() => const SetupPage(),
        AuthLocked(:final biometricAvailable) =>
          LockScreenPage(biometricAvailable: biometricAvailable),
        AuthUnlocked() => _TurnPageView(
            key: const ValueKey('turn'),
            onComplete: () {
              // 路由由现有 SettingsBloc listener 处理
              // 此处仅触发 settings load（已在 AuthCubit listener 内）
            },
          ),
        AuthUnlocking() => const SizedBox.shrink(), // 不会触发（buildWhen 拦截）
      },
    );
  },
)
```

`buildWhen: (prev, curr) => curr is! AuthUnlocking` 让 `AuthUnlocking` 状态**保持上一帧**——即 `LockScreenPage` 不消失，由它自己处理校验中视觉（见 lock-screen handoff §3）。

### 步骤 5：调整 `SettingsBloc` listener 时序

`SettingsBloc listener` 在 `AuthUnlocked` 后触发 `LoadSettingsDashboard`，等 `SettingsLoaded` 到达后 `context.go(...)`。原 v1 立即跳转，v2 需等 `_TurnPageView.onComplete`：

**方案 A（推荐）**：在 `_TurnPageView` 的 `onComplete` 里调用 `context.go('/today')` / `'/onboarding'`，listener 仅用于 settings load 触发（不再做导航）。

**方案 B**：保持 listener 导航逻辑，但加一个 `_minDuration = 1.4s` Future race，确保最小停留时间。

推荐 A——逻辑更清晰，turn page 视图自己负责"翻开"。

---

## 3. 验收清单

- [ ] 冷启动 0.4s 内屏幕仅有月白纯色，无任何旋转 / 进度指示
- [ ] 0.4s 后「内刊。」display-md 黑墨宋体居中淡入（duration 600ms）
- [ ] 文字字体在 zh locale 下渲染思源宋体（fontFamilyFallback 生效）；en 下 Spectral SemiBold；ja 下 Noto Serif JP
- [ ] 用户输完 PIN → `LockScreenPage` 保持可见 → 校验通过后 wrapper 切到 `_TurnPageView`
- [ ] `_TurnPageView` 0.4s 静默 → 0.6s「翻开。」淡入 → 0.4s 停留 → 路由 `/today` 或 `/onboarding`
- [ ] 错误状态（`AuthError`）回退到 `_FrontPageView`，SnackBar 仍能显示在其上
- [ ] 暗模式下背景为 `#1C1A18`，文字为 `#E8E4DB`
- [ ] **不渲染** `CircularProgressIndicator`（grep 项目可确认）
- [ ] `AuthUnlocking` 状态下 LockScreen 视图保持，不切屏

---

## 4. 测试要点

`test/features/auth/presentation/pages/auth_wrapper_page_test.dart`:

```dart
testWidgets('shows front page phrase after 400ms silence', (tester) async {
  await tester.pumpWidget(/* wrapper with AuthInitial */);
  expect(find.text('内刊。'), findsOneWidget); // widget 已 build
  // opacity 仍为 0
  expect(tester.widget<AnimatedOpacity>(...).opacity, 0.0);
  await tester.pump(const Duration(milliseconds: 401));
  expect(tester.widget<AnimatedOpacity>(...).opacity, 1.0);
});

testWidgets('turn page routes after 1.4s', (tester) async {
  // emit AuthUnlocked
  // pump 1400ms
  // verify GoRouter destination changed
});

testWidgets('AuthUnlocking does not rebuild', (tester) async {
  // emit AuthLocked → AuthUnlocking
  // verify LockScreenPage still visible
});
```

---

## 5. 已知风险与边界

- **风险 1：扉页停留过长**——若 `AuthCubit.checkAuthStatus()` 在 < 400ms 内完成，用户会看到月白闪一下立即跳走（state 切换发生在文字尚未淡入时）。`AnimatedSwitcher` 240ms cross-fade 缓解，但仍可能有轻微闪烁。**对策**：保留 0.4s 静默不变（这是仪式必需），AnimatedSwitcher 的淡出会让最后一帧月白平滑过渡到 LockScreen 月白底，肉眼不可见。
- **风险 2：连续解锁/锁定测试**——若用户在 `_TurnPageView` 1.4s 期间快速触发返回 / 后台切换，`onComplete` 可能在 widget 已 dispose 后触发。`if (mounted)` 保护已加。
- **风险 3：文案 key 与 onboarding 重叠**——如果 ux-copy 维护者后续合并 `frontPagePhrase` 与 `onboardingWelcome` 简版，需同步更新此屏。**留 TODO 注释**：`// TODO(ux-copy): consider merging with onboardingWelcome simplified form`。

— 完 —
