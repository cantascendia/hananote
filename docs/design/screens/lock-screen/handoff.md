# Lock Screen 屏 v2 工程交付 Handoff

> Generated 2026-04-29
> 给实现工程师的"按图索骥"清单
> 上游：`spec.md` + `critique-v1.md`
> 修改文件：`lib/features/auth/presentation/pages/lock_screen_page.dart`（重写）+ `lib/features/auth/presentation/bloc/auth_cubit.dart`（错误升级）+ ARB
> 预计 LOC：v1 287 行 → v2 ~380 行（新增警告 BottomSheet + 忘记 PIN flow）

---

## 1. 文件清单

| 文件 | 操作 | 说明 |
|-----|------|-----|
| `lib/features/auth/presentation/pages/lock_screen_page.dart` | 重写 | 新 hero / 圆点 / keypad / 辅助 |
| `lib/features/auth/presentation/bloc/auth_cubit.dart` | 修改 | 暴露 `_failedAttempts` 给 UI（增 `failedAttempts` getter）+ 在第 7 次错误时 emit 新 state `AuthLockedWarning` 触发 BottomSheet |
| `lib/features/auth/presentation/bloc/auth_state.dart` | 新增 state | `AuthLockedWarning(remaining: int, biometricAvailable: bool)` |
| `lib/features/auth/presentation/widgets/forgot_pin_sheet.dart` | 新建 | 忘记 PIN HanaBottomSheet 内容 widget |
| `lib/features/auth/presentation/widgets/lock_warning_sheet.dart` | 新建 | 错误升级警告 BottomSheet 内容 widget |
| `lib/features/auth/presentation/widgets/pin_dots.dart` | 新建 | PIN 圆点行（独立 widget 便于测试） |
| `lib/features/auth/presentation/widgets/pin_keypad.dart` | 新建 | 4×4 keypad（从原 lock_screen_page 内的 _PinKeypad 提取） |
| `lib/core/l10n/arb/app_*.arb` | 新增 ~15 keys | 见 spec §4 |

注：`HanaButton` / `HanaBottomSheet` 视为 v2 已实现的核心组件——若 Phase 5 尚未落地，先用 placeholder Material 等价实现，加 `// TODO(v2-phase5)` 注释。

---

## 2. 实现步骤

### 步骤 1：ARB 新增 keys（合并到一个 PR）

详见 `spec.md §4` 列表。`flutter gen-l10n` 后获得自动生成的 `AppLocalizations.of(context).pinError` 等。

### 步骤 2：扩展 AuthState

`auth_state.dart`:
```dart
@freezed
sealed class AuthState with _$AuthState {
  // ... 既有 ...

  /// 错误次数接近 max（>= max - 3），触发 BottomSheet 警告
  const factory AuthState.lockedWarning({
    required int remaining,
    required bool biometricAvailable,
  }) = AuthLockedWarning;

  /// 错误次数 == max，触发终止确认 BottomSheet
  const factory AuthState.lockedFinal({
    required bool biometricAvailable,
  }) = AuthLockedFinal;
}
```

`auth_cubit.dart` 调整 `unlock()`：
```dart
Future<void> unlock(String pin) async {
  emit(const AuthState.unlocking());
  final result = await _unlockApp(pin);
  await result.fold(
    (failure) async => _emitErrorWithFallback(...),
    (isUnlocked) async {
      if (isUnlocked) {
        _failedAttempts = 0;
        emit(const AuthState.unlocked());
        return;
      }

      _failedAttempts++;
      final maxAttempts = _settings?.maxFailedAttempts ?? 0;

      if (maxAttempts > 0 && _failedAttempts >= maxAttempts) {
        emit(AuthState.lockedFinal(
          biometricAvailable: _settings?.biometricEnabled ?? false,
        ));
        return;
      }

      // 警告区间：最后 3 次试错
      if (maxAttempts > 0 && _failedAttempts >= maxAttempts - 3) {
        emit(AuthState.lockedWarning(
          remaining: maxAttempts - _failedAttempts,
          biometricAvailable: _settings?.biometricEnabled ?? false,
        ));
        return;
      }

      _emitErrorWithFallback(
        AppLocalizations.tr('pinError'), // 或在 listener 内做 i18n
        await _buildLockedState(),
      );
    },
  );
}

int get failedAttempts => _failedAttempts; // 暴露给 UI
```

### 步骤 3：重写 `LockScreenPage` 主结构

```dart
class LockScreenPage extends StatefulWidget {
  const LockScreenPage({required this.biometricAvailable, super.key});
  final bool biometricAvailable;
  // ...
}

class _LockScreenPageState extends State<LockScreenPage> {
  String _pin = '';
  String? _errorMessage;
  bool _verifying = false; // 校验中（unlocking）

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AuthCubit>();
    final attempts = cubit.failedAttempts;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              _showError(attempts >= 3 ? l10n.pinErrorRetry : l10n.pinError);
            } else if (state is AuthLockedWarning) {
              _showLockWarningSheet(state.remaining);
            } else if (state is AuthLockedFinal) {
              _showLockFinalSheet();
            } else if (state is AuthUnlocking) {
              setState(() => _verifying = true);
            } else {
              setState(() => _verifying = false);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: HanaTokens.background(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: HanaTokens.spacing.xl),
                _Hero(l10n: l10n),
                SizedBox(height: HanaTokens.spacing.lg),
                Center(child: PinDots(filled: _pin.length, length: 6,
                  highlightCursor: !_verifying)),
                SizedBox(height: HanaTokens.spacing.sm),
                _ErrorLine(message: _errorMessage),
                SizedBox(height: HanaTokens.spacing.lg),
                Opacity(
                  opacity: _verifying ? 0.4 : 1.0,
                  child: PinKeypad(
                    biometricAvailable: widget.biometricAvailable,
                    onNumberTap: _handleNumber,
                    onBackspace: _handleBackspace,
                    onBiometric: () => cubit.unlockBiometric(),
                  ),
                ),
                SizedBox(height: HanaTokens.spacing.lg),
                HanaButton.text(
                  label: l10n.forgotPin,
                  onPressed: _showForgotPinSheet,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // _Hero / _ErrorLine 见步骤 4
  // _handleNumber / _handleBackspace 沿用 v1，但 length 6 完成后 80ms delay 再 unlock
  // _showError / _showLockWarningSheet / _showLockFinalSheet / _showForgotPinSheet 见步骤 5/6
}
```

### 步骤 4：Hero + ErrorLine widgets

```dart
class _Hero extends StatelessWidget {
  const _Hero({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 42, // 仅覆盖 display-md 一行
          color: HanaTokens.primary(context), // 黛蓝竖线（黛蓝 #1）
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HanaNote',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: HanaTokens.ink(context),
                letterSpacing: -0.3,
              )),
            const SizedBox(height: 8), // sm
            Text(l10n.lockScreenSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: HanaTokens.inkSecondary(context),
              )),
          ],
        ),
      ],
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: AnimatedOpacity(
        opacity: message == null ? 0 : 1,
        duration: const Duration(milliseconds: 80), // motion-instant
        child: Center(
          child: Text(
            message ?? '',
            style: TextStyle(
              fontSize: 13, height: 20/13,
              color: HanaTokens.error(context),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 步骤 5：PinDots / PinKeypad widgets

`pin_dots.dart`:
```dart
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.filled, required this.length,
    this.highlightCursor = true});
  final int filled;
  final int length;
  final bool highlightCursor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(length * 2 - 1, (i) {
        if (i.isOdd) return const SizedBox(width: 8); // sm
        final idx = i ~/ 2;
        final isFilled = idx < filled;
        final isCursor = highlightCursor && idx == filled - 1 && filled > 0;
        return Container(
          width: 8, height: 8, // 比 v1 14×14 更小
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: !isFilled
              ? HanaTokens.accentMuted(context) // 远黛
              : (isCursor
                ? HanaTokens.primary(context)   // 黛蓝焦点 #2
                : HanaTokens.ink(context)),     // 墨色已填
          ),
        );
      }),
    );
  }
}
```

`pin_keypad.dart`:
```dart
class PinKeypad extends StatelessWidget {
  // 4 列 × 4 行 GridView
  // 每键 64×64，间距 md (16)
  // 左下：fingerprint（仅 mobile + biometric）/ 透明（其他）
  // 中下：0
  // 右下：backspace（透明底）
  // 上 9 键：1-9 数字键（米灰底 r-4 mono 字体）
  // 按下反馈：AnimatedScale 150ms 0.98
}

class _NumberKey extends StatefulWidget {
  // pressed → AnimatedScale 0.98 / 150ms
  // 用 Container + InkWell（无 Material 包装，因为 v2 keypad 不要 ripple）
  // child: Text(digit, style: TextStyle(
  //   fontFamily: 'JetBrains Mono', fontWeight: FontWeight.w300,
  //   fontSize: 28, color: HanaTokens.ink(context),
  //   fontFamilyFallback: ['SF Mono', 'Consolas', 'monospace'],
  // ))
}
```

### 步骤 6：BottomSheets

`lock_warning_sheet.dart`:
```dart
Future<void> showLockWarningSheet(BuildContext context, int remaining) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => HanaBottomSheet(
      title: AppLocalizations.of(context)!.lockWarningTitle,
      body: Text(AppLocalizations.of(context)!.lockWarningDesc(remaining)),
      actions: [
        HanaButton.primary(
          label: AppLocalizations.of(context)!.lockWarningRemember,
          onPressed: () => Navigator.pop(context),
        ),
        HanaButton.text(
          label: AppLocalizations.of(context)!.lockWarningReset,
          destructive: true,
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthCubit>().wipeData();
          },
        ),
      ],
    ),
  );
}
```

`lock_final_sheet.dart` 类似——但 `isDismissible=false` 且不提供"我记起来了"，只有 "再试 1 次"（pop + reset attempts to max-1）和 "确认清除"。

`forgot_pin_sheet.dart`:
```dart
Future<void> showForgotPinSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => HanaBottomSheet(
      title: AppLocalizations.of(context)!.forgotPinTitle,
      body: Text(AppLocalizations.of(context)!.forgotPinBody),
      actions: [
        HanaButton.ghost(
          label: AppLocalizations.of(context)!.cancel,
          onPressed: () => Navigator.pop(context),
        ),
        HanaButton.text(
          label: AppLocalizations.of(context)!.forgotPinReset,
          destructive: true,
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthCubit>().wipeData();
          },
        ),
      ],
    ),
  );
}
```

### 步骤 7：触觉调整 + 80ms 视觉停顿

```dart
void _handleNumber(String digit) {
  if (_pin.length >= 6 || _verifying) return;
  HapticFeedback.selectionClick(); // 极轻
  // ...
  if (newPin.length == 6) {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) context.read<AuthCubit>().unlock(newPin);
    });
  }
}

void _showError(String msg) {
  HapticFeedback.lightImpact(); // v1 是 heavyImpact，必须改
  setState(() {
    _errorMessage = msg;
    _pin = ''; // 清空 PIN 让用户重输
  });
}
```

---

## 3. 验收清单

- [ ] 整屏背景为月白纯色（`HanaTokens.background`），无渐变
- [ ] Hero「HanaNote」display-md 黑墨宋体左对齐 32px，左侧 4px 黛蓝竖线
- [ ] Hero 副文「PIN 解锁。」body-md 淡墨，与 hero sm (8) 间距
- [ ] PIN 圆点直径 8px（**比 v1 14×14 显著更小**），居中
- [ ] PIN 未填用 accentMuted（远黛），已填用 ink（墨色），当前光标位用 primary（黛蓝）
- [ ] 错误时朱砂 body-sm 文字，**仅 lightImpact**（grep `heavyImpact` 应为 0）
- [ ] 错误次数 ≥3 文字升级为「PIN 错误。再试一次。」
- [ ] 错误次数 = max - 3 ~ max - 1 弹警告 BottomSheet
- [ ] 错误次数 = max 弹终止确认 BottomSheet
- [ ] keypad 4 列 × 4 行（v1 是 3 列 × 4 行——必须改）
- [ ] keypad 数字字体为 `JetBrains Mono Light 28pt`（fontFamilyFallback 含 monospace）
- [ ] keypad 键圆角 `r-card=4`（v1 是 24，必须改）
- [ ] keypad 键底为 `surfaceContainerHigh` 米灰，无投影、无边框
- [ ] 校验中 keypad opacity 0.4，PIN 圆点保持
- [ ] 「忘记 PIN」HanaButton.text 在 keypad 下方左对齐 32px，可点击
- [ ] 忘记 PIN BottomSheet 文案双行：「无法找回。重置将清除本机全部数据。\n已导出的备份不受影响。」
- [ ] web 端 biometric 不可用时，左下角键透明占位，不显示任何提示
- [ ] 暗模式下颜色按 tokens.md §1.2 切换

---

## 4. 测试要点

`test/features/auth/presentation/pages/lock_screen_page_test.dart`:

```dart
testWidgets('shows lockWarningSheet when failedAttempts == max - 3',
  (tester) async {
    // setup cubit with maxFailedAttempts=10, _failedAttempts=7
    // emit AuthLockedWarning(remaining: 3)
    // expect: BottomSheet visible with "剩 3 次后清除全部数据。"
});

testWidgets('PIN dots use ink/primary/accentMuted correctly', (tester) async {
  // input "12345" (5 of 6 digits)
  // expect: dot[0..3] color == HanaTokens.ink
  // expect: dot[4] color == HanaTokens.primary (cursor)
  // expect: dot[5] color == HanaTokens.accentMuted (empty)
});

testWidgets('keypad uses JetBrains Mono', (tester) async {
  final textWidget = tester.widget<Text>(find.text('1'));
  expect(textWidget.style?.fontFamily, 'JetBrains Mono');
});

testWidgets('uses lightImpact not heavyImpact', (tester) async {
  // Mock HapticFeedback.lightImpact / heavyImpact channel
  // input wrong PIN
  // expect lightImpact called, heavyImpact NOT called
});

testWidgets('forgot PIN sheet wipes data on confirm', (tester) async {
  await tester.tap(find.text('忘记 PIN'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('重置 — 清除数据'));
  // verify: AuthCubit.wipeData called
});
```

---

## 5. 已知风险与边界

- **风险 1：HanaButton / HanaBottomSheet 未实现**——v2 Phase 5 落地节奏决定。若 setup 屏先于 lock-screen 实施，HanaButton 应已可用；否则用 Material 等价 + TODO 注释。
- **风险 2：`AuthLockedWarning` 状态新增**——可能影响 wrapper buildWhen 逻辑。需在 wrapper 内显式处理：`AuthLockedWarning` 的 `biometricAvailable` 与 `AuthLocked` 一致，让 wrapper 仍渲染 `LockScreenPage`，由 LockScreenPage 内 listener 弹 BottomSheet。
- **风险 3：80ms 视觉停顿**——若用户输 6 位极快，他可能在 80ms 内已经按下额外键。`if (_pin.length >= 6) return` 必须在 `_handleNumber` 入口，且 `_verifying = true` 也要拦截 keypad 输入。
- **风险 4：BottomSheet 在 isDismissible=false + enableDrag=false 下用户仍可按系统返回键** — Android 物理返回 / iOS 边缘 swipe。`WillPopScope` / `PopScope` 包装拦截，避免越过警告级。
- **风险 5：i18n 复数 plurals**——`lockWarningDesc` "剩 N 次后清除" 在 en/ja 需要复数处理 (`{remaining, plural, one{...} other{...}}` ICU 格式)。zh 不需要。

— 完 —
