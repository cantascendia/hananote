# Setup 屏 v2 工程交付 Handoff

> Generated 2026-04-29
> 给实现工程师的"按图索骥"清单
> 上游：`spec.md` + `critique-v1.md`
> 修改文件：`lib/features/auth/presentation/pages/setup_page.dart`（重写）+ ARB（修笔误 + 新增 ~10 keys）+ 新增 widget
> 预计 LOC：v1 198 行 → v2 ~340 行（含 mode 区分 + 双组 PIN + 两个 BottomSheet 调用）

---

## 1. 文件清单

| 文件 | 操作 | 说明 |
|-----|------|-----|
| `lib/features/auth/presentation/pages/setup_page.dart` | 重写 | 双组 PIN + 自定义 keypad + Switch + mode 参数 |
| `lib/features/auth/presentation/widgets/dual_pin_dots.dart` | 新建 | 两组 PIN 圆点 + 焦点切换（复用 `pin_dots.dart` 单组组件） |
| `lib/features/auth/presentation/widgets/setup_confirm_sheet.dart` | 新建 | "记住这 6 位" BottomSheet |
| `lib/features/auth/presentation/widgets/biometric_explain_sheet.dart` | 新建 | 生物识别说明 BottomSheet |
| `lib/features/auth/presentation/bloc/auth_cubit.dart` | 微调 | `setupPin` 接收来自 setup 屏的 `setupComplete` callback；wipe 后必须 emit `AuthWiped`（已正确） |
| `lib/app/router/app_router.dart` | 调整 | wrapper 把 `AuthWiped` 映射为 `SetupPage(mode: afterWipe)`；`AuthNeedsSetup` 映射为 `SetupPage(mode: firstTime)` |
| `lib/core/l10n/arb/app_*.arb` | 修笔误 + 新增 ~10 keys | 见 spec §4 |
| 复用：`pin_keypad.dart` `pin_dots.dart` | 来自 lock-screen handoff | 不重复定义 |

---

## 2. 实现步骤

### 步骤 1：ARB 修笔误 + 新增 keys

**P0 立即修**: `app_zh.arb` 找到 `confirmPassword` key 现值 `"確認密码"`（繁简混用），改为 `"确认密码"`。

**新增 keys**: 详见 spec.md §4 列表（`biometricNote` / `setupConfirmTitle` / `setupConfirmDesc` / `setupConfirmAck` / `setupAfterWipeTitle` / `setupAfterWipeDesc` / `biometricSheetTitle` / `biometricSheetBody`）。三语全部添加。

执行 `flutter gen-l10n`。

### 步骤 2：DualPinDots widget

```dart
class DualPinDots extends StatelessWidget {
  const DualPinDots({
    super.key,
    required this.firstFilled,
    required this.secondFilled,
    required this.activeGroup, // 0 or 1
    required this.l10n,
  });

  final int firstFilled;
  final int secondFilled;
  final int activeGroup;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(text: l10n.password, active: activeGroup == 0),
        const SizedBox(height: 8),
        Center(child: PinDots(
          filled: firstFilled,
          length: 6,
          highlightCursor: activeGroup == 0,
        )),
        const SizedBox(height: 16),
        _Label(text: l10n.confirmPassword, active: activeGroup == 1),
        const SizedBox(height: 8),
        Center(child: PinDots(
          filled: secondFilled,
          length: 6,
          highlightCursor: activeGroup == 1,
        )),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text, required this.active});
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 150), // motion-quick
      style: TextStyle(
        fontSize: 12, height: 16/12, letterSpacing: 0.6,
        fontWeight: FontWeight.w500,
        color: active
          ? HanaTokens.ink(context)
          : HanaTokens.inkSecondary(context),
      ),
      child: Text(text),
    );
  }
}
```

### 步骤 3：重写 SetupPage

```dart
enum SetupMode { firstTime, afterWipe }

class SetupPage extends StatefulWidget {
  const SetupPage({this.mode = SetupMode.firstTime, super.key});
  final SetupMode mode;

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  String _pin = '';
  String _confirmPin = '';
  int _activeGroup = 0;
  bool _biometricEnabled = false;
  String? _errorText;
  bool _saving = false;

  bool get _bothComplete =>
    _pin.length == 6 && _confirmPin.length == 6;

  bool get _matched => _bothComplete && _pin == _confirmPin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isAfterWipe = widget.mode == SetupMode.afterWipe;
    final heroTitle = isAfterWipe ? l10n.setupAfterWipeTitle : l10n.setupSecurePassword;
    final heroDesc = isAfterWipe ? l10n.setupAfterWipeDesc : l10n.setupPinDescription;

    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthStateChange,
      child: Scaffold(
        backgroundColor: HanaTokens.background(context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: HanaTokens.spacing.xl),
                _Hero(title: heroTitle, desc: heroDesc),
                SizedBox(height: HanaTokens.spacing.lg),
                DualPinDots(
                  firstFilled: _pin.length,
                  secondFilled: _confirmPin.length,
                  activeGroup: _activeGroup,
                  l10n: l10n,
                ),
                SizedBox(height: HanaTokens.spacing.sm),
                _ErrorLine(message: _errorText),
                SizedBox(height: HanaTokens.spacing.lg),
                _BiometricRow(
                  enabled: _biometricEnabled,
                  onChanged: _onBiometricToggle,
                  l10n: l10n,
                ),
                SizedBox(height: HanaTokens.spacing.lg),
                Opacity(
                  opacity: _saving ? 0.4 : 1.0,
                  child: PinKeypad(
                    biometricAvailable: false, // setup 不显示生物 fallback
                    onNumberTap: _handleNumber,
                    onBackspace: _handleBackspace,
                  ),
                ),
                SizedBox(height: HanaTokens.spacing.lg),
                HanaButton.primary(
                  label: l10n.save,
                  onPressed: _matched && !_saving ? _submit : null,
                ),
                SizedBox(height: HanaTokens.spacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNumber(String digit) {
    if (_saving) return;
    HapticFeedback.selectionClick();

    if (_activeGroup == 0) {
      if (_pin.length >= 6) return;
      setState(() {
        _pin += digit;
        _errorText = null;
      });
      if (_pin.length == 6) {
        Future.delayed(const Duration(milliseconds: 80), () {
          if (mounted) setState(() => _activeGroup = 1);
        });
      }
    } else {
      if (_confirmPin.length >= 6) return;
      setState(() {
        _confirmPin += digit;
        _errorText = null;
      });
      if (_confirmPin.length == 6) {
        // 自动校验
        Future.delayed(const Duration(milliseconds: 80), () {
          if (!mounted) return;
          if (_pin != _confirmPin) {
            HapticFeedback.lightImpact();
            setState(() {
              _errorText = AppLocalizations.of(context)!.pinMismatch;
              _confirmPin = '';
            });
          }
        });
      }
    }
  }

  void _handleBackspace() {
    if (_saving) return;
    setState(() => _errorText = null);

    if (_activeGroup == 1 && _confirmPin.isEmpty) {
      // 越界回退到第 1 组最后一位
      setState(() {
        _activeGroup = 0;
        _pin = _pin.isEmpty ? _pin : _pin.substring(0, _pin.length - 1);
      });
    } else if (_activeGroup == 1) {
      setState(() => _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1));
    } else if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _onBiometricToggle(bool value) async {
    if (value) {
      // 首次启用 → 弹说明 sheet
      final accepted = await showBiometricExplainSheet(context);
      if (accepted == true) {
        setState(() => _biometricEnabled = true);
      }
    } else {
      setState(() => _biometricEnabled = false);
    }
  }

  void _submit() {
    setState(() => _saving = true);
    context.read<AuthCubit>().setupPin(
      _pin,
      _confirmPin,
      biometricEnabled: _biometricEnabled,
    );
  }

  Future<void> _onAuthStateChange(BuildContext ctx, AuthState state) async {
    if (state is AuthError) {
      setState(() {
        _saving = false;
        _errorText = state.message;
      });
    } else if (state is AuthUnlocked) {
      // 拦截：先弹"记住这 6 位"
      await showSetupConfirmSheet(ctx);
      if (mounted) {
        // 由 wrapper 的 SettingsLoaded listener 走 onboarding/today 路由
        // 此处不直接 context.go——保持 AuthCubit + SettingsBloc 协同的既有架构
      }
    }
  }
}
```

### 步骤 4：BottomSheets

`setup_confirm_sheet.dart`:
```dart
Future<void> showSetupConfirmSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      return PopScope(
        canPop: false,
        child: HanaBottomSheet(
          title: l10n.setupConfirmTitle,
          body: Text(l10n.setupConfirmDesc),
          actions: [
            HanaButton.primary(
              label: l10n.setupConfirmAck,
              fullWidth: true,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    },
  );
}
```

`biometric_explain_sheet.dart`:
```dart
Future<bool?> showBiometricExplainSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      return HanaBottomSheet(
        title: l10n.biometricSheetTitle,
        body: Text(l10n.biometricSheetBody),
        actions: [
          HanaButton.primary(
            label: l10n.enableBiometric, // "启用生物识别。"
            onPressed: () => Navigator.pop(ctx, true),
          ),
          HanaButton.ghost(
            label: l10n.cancel, // "不了"
            onPressed: () => Navigator.pop(ctx, false),
          ),
        ],
      );
    },
  );
}
```

### 步骤 5：Hero / ErrorLine / BiometricRow widgets

`_Hero` 与 lock-screen handoff 步骤 4 的 `_Hero` 几乎一致——区别仅参数化 title/desc：

```dart
class _Hero extends StatelessWidget {
  const _Hero({required this.title, required this.desc});
  final String title;
  final String desc;
  // ... 同 lock-screen _Hero，仅文案换
}
```

`_BiometricRow`:
```dart
class _BiometricRow extends StatelessWidget {
  const _BiometricRow({
    required this.enabled,
    required this.onChanged,
    required this.l10n,
  });
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            HanaSwitch(value: enabled, onChanged: onChanged),
            const SizedBox(width: 12),
            Text(l10n.enableBiometric,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: HanaTokens.ink(context),
              )),
          ],
        ),
        const SizedBox(height: 4),
        Text(l10n.biometricNote,
          style: TextStyle(
            fontSize: 13, height: 20/13,
            color: HanaTokens.inkSecondary(context),
          )),
      ],
    );
  }
}
```

### 步骤 6：Router 调整

`app_router.dart` 或 wrapper 的 state 映射：
```dart
AuthState.needsSetup() => const SetupPage(mode: SetupMode.firstTime),
AuthState.wiped() => const SetupPage(mode: SetupMode.afterWipe),
```

### 步骤 7：删除 v1 死代码

- 删除原 `_pinController` / `_confirmController` TextEditingController（不再用 TextField）
- 删除原 `TextField + obscureText` block
- 删除原 `SwitchListTile.adaptive`（替换为 HanaSwitch）
- 删除原 `DecoratedBox` 卡片容器 + boxShadow
- 删除原 `ElevatedButton`（替换为 HanaButton）
- 删除 prefixIcon 引用 `Icons.lock_outline_rounded` `Icons.verified_user_outlined`

---

## 3. 验收清单

- [ ] 整屏背景为月白纯色，无渐变、无卡片、无阴影
- [ ] Hero「设定密码」display-md 黑墨宋体左对齐 32px + 4px 黛蓝竖线
- [ ] Hero 副文「6 位数字。仅本机可解。」（**无"私密 / 健康 / 保护"等敏感词** — grep 项目可确认）
- [ ] 双组 PIN 圆点直径 8px，居中
- [ ] active label `HanaTokens.ink`，inactive `HanaTokens.inkSecondary`，切换有 150ms 动画
- [ ] 第一组 6 位输完后 80ms 自动切到第二组
- [ ] 第二组 6 位输完且不一致时朱砂错误提示「两次不一致。」+ lightImpact + 第二组清空
- [ ] HanaSwitch（不是 SwitchListTile）
- [ ] Switch 开启时弹 BiometricSheet 三条说明，必须主动确认
- [ ] Switch ON 状态 track 是 `HanaTokens.primary` 黛蓝
- [ ] 副 helperText "生物识别仅本机校验，不上传。" body-sm 淡墨
- [ ] 自定义 keypad 4×4，左下角空（无生物识别按钮）
- [ ] 保存按钮 HanaButton.primary 左对齐 32，**不全宽**
- [ ] 保存按钮在两组 PIN 一致前 disabled (opacity 0.4)
- [ ] 保存成功后弹 SetupConfirmSheet「记住这 6 位。/ 丢了无法找回。」
- [ ] SetupConfirmSheet `isDismissible: false` `enableDrag: false`，PopScope 拦截系统返回
- [ ] `mode = afterWipe` 时 hero 文案为「重新开始。/ 数据已清除。继续即可。」
- [ ] ARB 笔误 `確認密码` 已修复为 `确认密码`
- [ ] 暗模式颜色按 tokens 切换

---

## 4. 测试要点

`test/features/auth/presentation/pages/setup_page_test.dart`:

```dart
testWidgets('first 6 digits switches active group to confirm',
  (tester) async {
    await tester.pumpWidget(/* SetupPage */);
    for (var d in ['1','2','3','4','5','6']) {
      await tester.tap(find.text(d));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 81));
    // verify: confirmPassword label is now active (ink color)
});

testWidgets('mismatch shows pinMismatch error and clears confirm',
  (tester) async {
    // input "123456" then "654321"
    await tester.pump(const Duration(milliseconds: 81));
    expect(find.text('两次不一致。'), findsOneWidget);
    // verify confirmPin cleared (second row of dots all empty)
});

testWidgets('AfterWipe mode shows different hero', (tester) async {
  await tester.pumpWidget(/* SetupPage(mode: SetupMode.afterWipe) */);
  expect(find.text('重新开始。'), findsOneWidget);
  expect(find.text('数据已清除。继续即可。'), findsOneWidget);
});

testWidgets('save success shows setupConfirmSheet', (tester) async {
  // emit AuthUnlocked from cubit
  await tester.pumpAndSettle();
  expect(find.text('记住这 6 位。'), findsOneWidget);
  expect(find.text('丢了无法找回。'), findsOneWidget);
});

testWidgets('biometric toggle shows explain sheet on enable',
  (tester) async {
    await tester.tap(find.byType(HanaSwitch));
    await tester.pumpAndSettle();
    expect(find.text('生物识别说明。'), findsOneWidget);
});

testWidgets('uses lightImpact on mismatch', (tester) async {
  // mock haptic, input mismatched pins, verify lightImpact called
});
```

---

## 5. 已知风险与边界

- **风险 1：HanaButton / HanaSwitch / HanaBottomSheet 未实现**——同 lock-screen handoff 风险 1。Phase 5 落地前用 Material 等价 + TODO 注释。setup 是黛蓝 #3 处的位置（Switch ON），若用 Material Switch 颜色不可控，需手动 `activeColor: HanaTokens.primary(context)`。
- **风险 2：mode 参数与现有 router 集成**——v1 wrapper 通过 `AuthState.needsSetup()` 和 `AuthState.wiped()` 都映射到 `SetupPage()`（见 auth_wrapper_page.dart L79），无 mode 区分。需在 wrapper switch 改为：
  ```dart
  AuthNeedsSetup() => const SetupPage(mode: SetupMode.firstTime),
  AuthWiped() => const SetupPage(mode: SetupMode.afterWipe),
  ```
- **风险 3：双组 PIN keypad 焦点**——keypad 共享，但用户视觉焦点要清楚在哪一组。若用户已输 6 位密码，焦点跳到第二组，但第一组仍可见（圆点全墨色）——用户可能误以为 keypad 是给第一组的。**对策**：第一组 6 位填满后**圆点保持墨色但不再有"焦点黛蓝"**——焦点黛蓝只出现在 active 组的当前光标位。这一对比足以传达"焦点在第二组"。
- **风险 4：SetupConfirmSheet 路由时序**——保存成功后 setup 屏弹 BottomSheet，BottomSheet 用户点"我记住了"后 pop。**此时 wrapper 已经监听 `AuthUnlocked` + `SettingsLoaded`**，会自动 `context.go(...)`。可能出现 BottomSheet 还没 pop 完路由就发生——导致 BottomSheet 残留在新页面之上。**对策**：在 setup 屏 listener 里**先 pop 当前所有 modal**再 emit 一个内部 trigger，或在 wrapper listener 加 `WidgetsBinding.instance.addPostFrameCallback` 延后路由。推荐前者：`Navigator.popUntil(ctx, (r) => !r.willHandlePopInternally)` 在 BottomSheet dismiss 后调用。
- **风险 5：keyboard 系统弹出冲突**——v1 用 TextField，v2 替换为自定义 keypad，**TextField 必须删除**（不仅 visually 隐藏），否则系统软键盘可能在某些设备弹出。grep `TextField` 在新文件应为 0。
- **风险 6：i18n labels w/ tracking**——zh `label` 字距 +0.4（tokens.md §2.3 表注），en/ja +0.6。`AnimatedDefaultTextStyle.letterSpacing` 在不同 locale 下取值不同，需 `Localizations.localeOf(context).languageCode == 'zh' ? 0.4 : 0.6`。

— 完 —
