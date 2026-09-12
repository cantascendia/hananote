# Setup 屏 v2 视觉与流程规范

> Generated 2026-04-29
> 单屏（hero + 两组 PIN 圆点 + 自定义 keypad + 生物识别开关 + 保存按钮 + 确认 BottomSheet）
> 屏幕：`lib/features/auth/presentation/pages/setup_page.dart`
> 上游基准：`docs/design/design-system/v2/{tokens.md,principles.md,components/*.md}` + `docs/design/screens/setup/critique-v1.md` + `docs/design/screens/lock-screen/spec.md` + `docs/design/ux-copy-v2/copy-revisions.md`

---

## 1. 设计意图

Setup 是用户与 HanaNote 建立信任契约的瞬间。critique-v1 已经判定 v1 在两个层面失败：① **视觉与 onboarding 节奏断裂**（卡片 + Material 信纸感）；② **文案在跨性别敏感性上触雷**（"保护私密健康数据"叙事）。

v2 把 setup 从"注册表单"重定义为**"目录页之前的扉页落款"**——用户在 onboarding 翻完最后一屏后到达此屏，他/她要做的不是"填资料"，而是**"在这本内刊上签下 6 位数字作为印章"**。这一重新定义带来三个设计选择：

1. **视觉语法与 lock screen 完全一致**——同一组 hero / PIN 圆点 / 自定义 keypad，让用户在 setup 屏熟练的输入手感**就是回访时 lock screen 的手感**——这是肌肉记忆的"信任建立"。
2. **文案去防御化**——采纳 ux-copy-v2 §1 的「设定密码。」+「6 位数字。仅本机可解。」，把 PIN 从"防御机制"重定义为"内容拥有权印章"。
3. **保存即仪式**——成功后不立即跳转，先弹 `HanaBottomSheet`「记住这 6 位。」让用户主动确认后再路由——这一秒的等待是仪式必需，不是工程延迟。

此外，v2 区分 `firstTime` / `afterWipe` 两种入口模式，分别用不同 hero 文案，让"忘记 PIN 后重置"的用户感受到系统的同情。

---

## 2. 屏幕规范

### 2.1 整屏布局（默认状态，`mode = firstTime`）

**视觉**: `HanaTokens.background(context)` 月白实色，无渐变、无卡片。SafeArea 顶部 `xl` (64) 留白，水平 padding 32，从上到下：

1. **Hero 标题区**（左对齐 32px）
   - `display-md (32/42/-0.3 SemiBold)` 黑墨宋体「设定密码」（`setupSecurePassword` 改写后无句号——hero 标题是名词性印章，不需句号；与 onboarding "进展。" 风格一致——可商榷采用句号）
   - 标题左侧 4px 黛蓝竖线（**本屏第 1 处黛蓝**）
   - 下方 `sm` (8)
   - `body-md (15/24)` 淡墨「6 位数字。仅本机可解。」(`setupPinDescription`)

2. **第一组 PIN 圆点 + label**（距 hero `lg` (32)）
   - `label (12/16, +0.6 tracking)` 淡墨「密码」
   - 下方 `sm` (8)
   - 6 个圆点（直径 8，居中**或左对齐**——v2 推荐**居中**保持 PIN 视觉语义；与 lock screen 一致）
   - 圆点状态同 lock screen：未填 accentMuted / 已填 ink / 当前焦点 primary（**本屏第 2 处黛蓝**——但仅在用户输入时短暂出现）

3. **第二组 PIN 圆点 + label**（距上 `md` (16)）
   - `label` "确认密码"（**注意：ARB 现有笔误 `確認密码` 必须修复**）
   - 6 个圆点同上结构（输入第 2 组时第 1 组的焦点黛蓝消失，所以**仍只 1 处黛蓝同时可见**）

4. **错误提示**（距上 `sm` (8)）
   - 默认占位 `SizedBox(height: 20)`
   - 错误时淡入：`body-sm` 朱砂「两次不一致。」(`pinMismatch` ux-copy 已改写)

5. **生物识别开关行**（距上 `lg` (32)）
   - `HanaSwitch` (28×16) + 文字「启用生物识别。」(`enableBiometric` ux-copy 已改写)
   - 下方 `xs` (4)
   - `body-sm` 淡墨 helperText「生物识别仅本机校验，不上传。」(**新增 ARB `biometricNote`**)
   - 点击开关首次启用 → 弹 `HanaBottomSheet` 详细解释（见 §2.4）
   - **注意**：开关 ON 状态 track 是 `HanaTokens.primary` 实填——这是**本屏第 3 处合法黛蓝**（仅当用户启用时出现，达到 3 处上限）

6. **自定义 Keypad**（距上 `lg` (32)，与 lock screen 同款）
   - 4 列 × 4 行，每键 64×64dp，间距 md (16)
   - 数字键 mono JetBrains Mono Light 28pt，米灰底 r-4
   - 左下角空（**setup 屏不显示生物识别按钮**——还没设置 PIN，没有可解锁的 PIN 给生物 fallback）
   - 右下角退格（同 lock screen）
   - 当前焦点（哪一组 PIN 在接收输入）由"边框"而非颜色指示——**仅在两组之间切换的瞬间用 `motion-quick=150ms` 平滑过渡焦点框**（薄 1px outline 在 active label 下方延伸）

7. **保存按钮**（距 keypad `lg` (32)）
   - `HanaButton.primary` "收存" (`save` ux-copy 改写)
   - **fullWidth=false**，左对齐 32px
   - 启用条件：两组 PIN 各 6 位 + 完全一致（自动校验）
   - 未达条件时按钮置 disabled (opacity 0.4)，但**仍可点**——点击后显示错误提示（避免 disabled 按钮的"看起来坏了"困惑）

8. **底部 footer 区**（距按钮 `lg` (32)，仅 `mode = afterWipe` 模式显示）
   - `HanaButton.text` "取消" → 返回 lock screen（不可——afterWipe 后没有可返回的 lock，所以此按钮在 firstTime 也隐藏，仅 onboarding 错走过来时显示——**P2 可省略**）

**ASCII wireframe**:
```
┌──────────────────────────────────────┐
│                                      │  spacing.xl (64) + SafeArea
│ │ 设定密码                            │  ← display-md 墨色 + 黛蓝竖线（黛蓝 #1）
│   6 位数字。仅本机可解。              │  ← body-md 淡墨
│                                      │  spacing.lg (32)
│   密码                                │  ← label tracking +0.6 淡墨
│        ● ● ● ○ ○ ○                   │  ← PIN 圆点居中（第 1 组）
│                                      │  spacing.md (16)
│   确认密码                            │  ← label
│        ○ ○ ○ ○ ○ ○                   │  ← PIN 圆点（第 2 组）
│                                      │  spacing.sm (8)
│        两次不一致。                   │  ← 错误时朱砂
│                                      │  spacing.lg (32)
│   ⊟ 启用生物识别。                    │  ← HanaSwitch + 文字（开启时黛蓝 #3）
│   生物识别仅本机校验，不上传。         │  ← body-sm 淡墨 helperText
│                                      │  spacing.lg (32)
│   ┌────┐ ┌────┐ ┌────┐               │
│   │ 1  │ │ 2  │ │ 3  │               │  ← 4×4 keypad（左下空，0 居中，右下退格）
│   └────┘ └────┘ └────┘                │     与 lock screen 完全一致
│   ┌────┐ ┌────┐ ┌────┐               │
│   │ 4  │ │ 5  │ │ 6  │               │
│   └────┘ └────┘ └────┘                │
│   ┌────┐ ┌────┐ ┌────┐               │
│   │ 7  │ │ 8  │ │ 9  │               │
│   └────┘ └────┘ └────┘                │
│   ┌────┐ ┌────┐ ┌────┐               │
│   │    │ │ 0  │ │ ⌫  │               │  ← 左下空（无生物识别）
│   └────┘ └────┘ └────┘                │
│                                      │  spacing.lg (32)
│   ╭──────╮                           │
│   │ 收存 │                           │  ← HanaButton.primary 左对齐 32，不全宽
│   ╰──────╯                           │
│                                      │  SafeArea 底部
└──────────────────────────────────────┘
```

**用户场景**: 用户走完 onboarding → 到此屏 → 看到 hero「设定密码」+「6 位数字。仅本机可解。」 → 输 6 位密码 → keypad 焦点自动跳到第二组 → 输 6 位确认 → 两组完成且一致时按钮启用 → 点"收存" → `AuthCubit.setupPin()` → 弹 `HanaBottomSheet`「记住这 6 位。」 → 用户确认 → wrapper `_TurnPageView` 接管。

**跨性别敏感性**: 文案完全采纳 ux-copy-v2 §1 改写——零"私密"、零"健康数据"、零"保护"。视觉与 lock screen 一致，无任何"防御 / 安全"暗示符号。生物识别有具体技术陈述消除担忧。

**关键 token**: 同 lock-screen spec.md §4 + `label` (12/16/+0.6) · `HanaSwitch`

**关键文案 key**:
- `setupSecurePassword` → "设定密码" / "Set a passcode" / "暗証番号を設定"（ux-copy 改写，**注意 hero 标题去句号**——可在 spec review 时争议，推荐保留句号统一调性："设定密码。"）
- `setupPinDescription` → "6 位数字。仅本机可解。" / "Six digits. Local only." / "6 桁。この端末のみ。"
- `password` → "密码" / "Passcode" / "暗証番号"（hero label）
- `confirmPassword` → "确认密码" / "Confirm passcode" / "確認暗証番号"（**ARB 笔误必修：app_zh.arb:374 附近 `確認密码` → `确认密码`**）
- `pinMismatch` → "两次不一致。" / "The two don't match." / "二度が一致せず。"
- `enableBiometric` → "启用生物识别。" / "Enable biometric unlock." / "生体認証を有効化。"
- `biometricNote` *（新增 ARB）* → "生物识别仅本机校验，不上传。" / "Biometric stays on this device. Never uploaded." / "生体認証はこの端末のみ。送信されず。"
- `save` → "收存" / "Keep" / "収める"
- `setupConfirmTitle` *（新增 ARB）* → "记住这 6 位。" / "Remember these six." / "6 桁を覚えて。"
- `setupConfirmDesc` *（新增 ARB）* → "丢了无法找回。" / "Cannot be recovered." / "失えば戻せず。"
- `setupConfirmAck` *（新增 ARB）* → "我记住了" / "Got it" / "覚えた"
- `setupAfterWipeTitle` *（新增 ARB）* → "重新开始。" / "Begin again." / "もう一度。"
- `setupAfterWipeDesc` *（新增 ARB）* → "数据已清除。继续即可。" / "Data cleared. Continue." / "削除済み。続けて。"
- `biometricSheetTitle` *（新增 ARB）* → "生物识别说明。" / "About biometric unlock." / "生体認証について。"
- `biometricSheetBody` *（新增 ARB）* → "① 仅本机校验。\n② 指纹 / Face 数据不离开手机。\n③ 失败时可改用 PIN。"

### 2.2 PIN 输入行为（双组）

- **初始焦点**：第一组（"密码"）。Label 颜色 `HanaTokens.ink`，第二组 label 颜色 `HanaTokens.inkSecondary`（淡墨——表示未激活）。
- **第一组输入**：keypad 输入 → 圆点对应位填充（同 lock screen 配色）。
- **第一组完成 6 位**：80ms 视觉停顿（圆点全墨色） → 自动切换焦点到第二组。第二组 label 变 ink，第一组 label 变 inkSecondary。`motion-quick=150ms` 平滑过渡。
- **第二组输入**：焦点圆点黛蓝 #2（短暂出现）。
- **第二组完成 6 位**：80ms 停顿 → 自动校验 `pin == confirmPin`：
  - 一致 → 保存按钮启用（颜色从 disabled opacity 0.4 → 1.0），`motion-instant=80ms`
  - 不一致 → 错误提示「两次不一致。」朱砂淡入 + `lightImpact()` + 第二组圆点清空（让用户重输第二组，第一组保留——若用户也想重输第一组，可用退格越界回退到第一组）
- **退格**：当前焦点组退一位；若已退到 0 位且按退格，焦点回到上一组的最后一位（仅当上一组已完成）。

### 2.3 保存流程

- 用户点「收存」按钮 → `AuthCubit.setupPin(pin, confirmPin, biometricEnabled)` → state = `AuthUnlocking`：
  - keypad opacity 0.4，按钮 opacity 0.4，文字「收存」改 spinner？— **不要 spinner**。改为按钮文字静态保持「收存」+ 整屏轻微 inert 状态。
- 成功（state → `AuthUnlocked`）：
  - 拦截 wrapper 的 `_TurnPageView`——setup 屏自己**先弹 `HanaBottomSheet`「记住这 6 位。」**（见 §2.4），用户确认后再让 wrapper 路由
  - 实现：在 setup 屏内 listener 监听 `AuthUnlocked`，先 push BottomSheet，BottomSheet dismiss 后再 emit 一个 trigger 让 wrapper 切到 `_TurnPageView`——**或**直接在 BottomSheet dismiss 后 `context.go('/today')`（绕过 wrapper turn page，因为 setup 后的 turn page 仪式由 BottomSheet 替代）
- 失败（state → `AuthError`）：
  - SnackBar 显示 failure message
  - 状态回到 `AuthNeedsSetup`，用户可重试

### 2.4 BottomSheets

**`setupConfirmSheet`（保存成功后）**:
```
─────                        ← drag handle
  记住这 6 位。
                             ← spacing.lg
  丢了无法找回。
                             ← spacing.lg
  ┌──────────────┐
  │ 我记住了      │             ← HanaButton.primary fullWidth=true
  └──────────────┘
```
- `isDismissible: false` `enableDrag: false` — 必须主动确认
- 用户点「我记住了」 → pop → `context.go('/onboarding')` 或 `'/today'`（取决于是否已 onboarded）

**`biometricSheet`（首次启用生物识别开关时）**:
```
─────                        ← drag handle
  生物识别说明。
                             ← spacing.lg
  ① 仅本机校验。
  ② 指纹 / Face 数据不离开手机。
  ③ 失败时可改用 PIN。
                             ← spacing.lg
  ┌──────────────┐
  │ 启用          │             ← HanaButton.primary
  └──────────────┘
  ┌──────────────┐
  │ 暂不          │             ← HanaButton.ghost
  └──────────────┘
```
- 用户启用 → `_biometricEnabled = true`（开关保持 ON）
- 暂不 → 开关回 OFF（visual rollback）

### 2.5 模式区分（firstTime vs afterWipe）

```dart
enum SetupMode { firstTime, afterWipe }

class SetupPage extends StatefulWidget {
  final SetupMode mode;
  // ...
}
```

`afterWipe` 模式下：
- Hero 标题改用 `setupAfterWipeTitle` "重新开始。"
- Hero 副文改用 `setupAfterWipeDesc` "数据已清除。继续即可。"
- 其他元素（PIN 圆点 / keypad / 开关 / 按钮 / BottomSheet）完全相同

判定：`AuthState.wiped()` 触发后 wrapper 渲染 `SetupPage(mode: SetupMode.afterWipe)`；`AuthState.needsSetup()` 触发渲染 `SetupPage(mode: SetupMode.firstTime)`。

---

## 3. 跨性别敏感性总览

| 层面 | v1 现状 | v2 修复 |
|-----|--------|--------|
| 标题"安全密码"防御叙事 | "创建安全密码" | "设定密码" — 中性陈述 |
| 副文"私密健康数据" | "设置 6 位 PIN 以保护你的私密健康数据。" | "6 位数字。仅本机可解。" — 具体技术事实 |
| 生物识别无解释 | 单行 toggle 无副描述 | 副描述 + BottomSheet 三条具体陈述 |
| afterWipe 文案冷漠 | 与 firstTime 完全相同 | 独立文案"重新开始。/ 数据已清除。继续即可。" |
| 保存无确认仪式 | 立即跳转 | 弹"记住这 6 位。"BottomSheet 主动确认 |

---

## 4. 关键 token 与文案 key 汇总

| 类别 | Token / Key | 值 / 用途 |
|------|-----------|----------|
| Color | `HanaTokens.background` | 月白 / 暖深 |
| Color | `HanaTokens.ink` | 墨色 — hero 标题 / 已填 PIN / 数字 |
| Color | `HanaTokens.primary` | 黛蓝 — hero 4px 竖线 + PIN 焦点 + Switch ON track（本屏 ≤ 3 处） |
| Color | `HanaTokens.surfaceContainerHigh` | 米灰 — keypad 键底 |
| Color | `HanaTokens.accentMuted` | 远黛 — PIN 未填 |
| Color | `HanaTokens.error` | 朱砂 — 两次不一致 |
| Color | `HanaTokens.inkSecondary` | 淡墨 — 副文 / 未激活 label / helperText |
| Type | `display-md` `body-md` `body-sm` `label` `mono` | 同前 |
| Radius | `r-card=4` `r-pill` | keypad / PIN 圆点 |
| Motion | `motion-instant=80ms` `motion-quick=150ms` | 圆点切换 / 焦点过渡 / 按钮启用 |
| Copy keys (新增) | `biometricNote` `setupConfirmTitle` `setupConfirmDesc` `setupConfirmAck` `setupAfterWipeTitle` `setupAfterWipeDesc` `biometricSheetTitle` `biometricSheetBody` | 详见 §2 各小节 |
| Copy keys (改写) | `setupSecurePassword` `setupPinDescription` `pinMismatch` `enableBiometric` `save` | 采纳 ux-copy-v2 §1/§2 |
| Copy keys (修笔误) | `confirmPassword` (zh `app_zh.arb:374` `確認密码` → `确认密码`) | ux-copy-v2 §11 |

— 完 —
