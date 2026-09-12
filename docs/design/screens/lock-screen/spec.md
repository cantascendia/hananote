# Lock Screen 屏 v2 视觉与流程规范

> Generated 2026-04-29
> 单屏（hero + PIN 圆点 + keypad + 辅助操作），覆盖错误升级 / 生物识别 fallback / 忘记 PIN
> 屏幕：`lib/features/auth/presentation/pages/lock_screen_page.dart`
> 上游基准：`docs/design/design-system/v2/{tokens.md,principles.md,components/*.md}` + `docs/design/screens/lock-screen/critique-v1.md` + `docs/design/ux-copy-v2/copy-revisions.md` + `docs/ai-cto/PRODUCT-VISION.md`

---

## 1. 设计意图

Lock Screen 是 HanaNote 用户**每次回访 app** 必经的"过门"——critique-v1 已经判定 v1 在视觉、文案、节奏、跨性别敏感性、安全性五个维度上都未达标：盾牌图标暴露身份、欢迎语过热、错误反馈无升级、忘记 PIN 无入口、整屏 8 处黛蓝贬值稀缺色。

v2 把 lock screen 从"功能屏（输 PIN 解锁）"重定义为**"扉页之后的目录页"**——用户已经看过 wrapper 的扉页「内刊。」，现在他打开目录前需要"出示证件"。这一秒的视觉哲学是：**像一本任何普通笔记 app 的锁屏，没有"我有秘密"的视觉标记**——这是 HRT 用户在公共场合 / 家人面前打开 app 的最高保护。

更核心的，v2 在错误处理上引入**三阶升级**（≥3 警示 / ≥7 警告 BottomSheet / ≥10 终止确认 BottomSheet），并显式提供**忘记 PIN 入口**——这不是工程优化，是**对 HRT 用户长期焦虑 / 记忆波动 / 突发情境的产品同情**。v1 的"输错 N 次直接 wipe 不预警"是潜在数据灾难。

---

## 2. 屏幕规范

### 2.1 整屏布局（默认状态）

**视觉**: `HanaTokens.background(context)` 月白实色铺满，无渐变。SafeArea 顶部 `xl` (64) 留白，下方依次：

1. **Hero 标题区**（左对齐 32px）
   - `display-md (32/42/-0.3 SemiBold)` 黑墨宋体「HanaNote」
   - 标题左侧 4px 黛蓝竖线（仅覆盖标题首行 — **本屏第 1 处黛蓝**）
   - 下方 `sm` (8) 间距
   - `body-md (15/24)` 淡墨「PIN 解锁。」（句号收尾）

2. **PIN 圆点行**（居中——本屏唯一允许居中的内容，因 PIN 是视觉锚点）
   - 距 hero 区 `lg` (32)
   - 6 个圆点（`r-pill` 4dp 直径 = 8px 圆点 — 注意比 v1 14×14 更小，更克制）
   - **未填**: `HanaTokens.accentMuted` 实填（远黛 `#E5E9EE`，黛蓝 8% 等效）
   - **已填**: `HanaTokens.ink` 实填（墨色，**不用黛蓝**）
   - **当前光标位**: `HanaTokens.primary` 实填（**本屏第 2 处黛蓝**——最末输入位的焦点指示）
   - 圆点间距 `sm` (8)

3. **错误提示**（PIN 圆点下方 `sm` (8)）
   - 默认 `AnimatedOpacity = 0`（不占布局——`SizedBox(height: 20)` 占位）
   - 错误时淡入（`motion-instant=80ms`）：`body-sm (13/20)` 朱砂 `HanaTokens.error` "PIN 错误。" + `lightImpact()` haptic
   - 连续错误次数 ≥ 3：文字升级为 "PIN 错误。再试一次。"（同色，仍不锁屏）
   - 错误次数 ≥ 7 且距 `maxFailedAttempts` 仅剩 ≤ 3：触发 BottomSheet（见 §2.3）

4. **Keypad**（距错误区 `lg` (32)，4 列 × 4 行——v2 强制 4×4 网格）
   - 每键 64×64dp，间距 `md` (16) 横竖
   - **数字键**：`mono 28pt JetBrains Mono Light`，色 `HanaTokens.ink`，背景 `HanaTokens.surfaceContainerHigh` (米灰 `#EAE6DD`) 实填，圆角 `r-card=4`，**无投影、无边框**
   - **生物识别键**（左下角，仅 `biometricAvailable=true`）: `Icons.fingerprint_rounded` 24px `HanaTokens.ink`（不是黛蓝），同样米灰底 `r-4`
   - **退格键**（右下角）: `Icons.backspace_outlined` 24px `HanaTokens.inkSecondary`，**透明底**（不与数字键同等视觉权重）
   - **0 键**居中底排
   - 按下反馈：`motion-quick=150ms` press scale 0.98，**无 ripple**（v2 keypad 是"印刷数字网格"不是 Material 按键）

5. **辅助操作行**（keypad 下方 `lg` (32)，左右两端 32px padding）
   - **左**：`HanaButton.ghost` "忘记 PIN" — 仅 zh 显示中文，en/ja 同步
   - **右**：（仅 web 端 `biometricAvailable=false` 时）`HanaButton.ghost` "用 PIN 解锁" — 占位与 keypad 视觉对称（实际无功能，因为已经在 PIN 屏；该按钮仅为视觉平衡，**P2 可省略**）

**ASCII wireframe**:
```
┌──────────────────────────────────────┐
│                                      │  spacing.xl (64) + SafeArea
│ │ HanaNote                           │  ← display-md 墨色 + 4px 黛蓝竖线（黛蓝 #1）
│   PIN 解锁。                         │  ← body-md 淡墨 (sm 间距)
│                                      │  spacing.lg (32)
│        ● ● ● ● ○ ○                   │  ← PIN 圆点居中（已填墨色 / 未填远黛 / 焦点黛蓝 #2）
│                                      │  spacing.sm (8)
│        PIN 错误。再试一次。            │  ← 错误时显示 (朱砂 body-sm，仅这一处暖色)
│                                      │  spacing.lg (32)
│   ┌────┐ ┌────┐ ┌────┐               │
│   │ 1  │ │ 2  │ │ 3  │               │  ← 4×4 keypad，每键 64×64 r-4
│   └────┘ └────┘ └────┘                │     mono JetBrains Mono Light 28pt
│   ┌────┐ ┌────┐ ┌────┐               │     spacing md (16) gap
│   │ 4  │ │ 5  │ │ 6  │               │
│   └────┘ └────┘ └────┘                │
│   ┌────┐ ┌────┐ ┌────┐               │
│   │ 7  │ │ 8  │ │ 9  │               │
│   └────┘ └────┘ └────┘                │
│   ┌────┐ ┌────┐ ┌────┐               │
│   │ ⌖  │ │ 0  │ │ ⌫  │               │  ← 左：fingerprint（仅 mobile）/右：backspace
│   └────┘ └────┘ └────┘                │     web 端无生物识别 → 左格透明
│                                      │  spacing.lg (32)
│  [忘记 PIN]                          │  ← HanaButton.text 左对齐 32px
│                                      │  SafeArea 底部
└──────────────────────────────────────┘
```

**用户场景**: 用户从外部（社交 app / 系统设置 / 主屏 swipe）回到 HanaNote → 看到 hero「HanaNote」+「PIN 解锁。」 + keypad → 输 6 位 PIN → 输完最后一位 80ms 视觉停顿（圆点全墨色）→ `AuthCubit.unlock(pin)` 异步校验 → 成功则 wrapper `_TurnPageView` 接管。

**跨性别敏感性**: 整屏视觉**无任何"健康 / 医疗 / 隐私 / 安全"暗示符号**（删除 v1 盾牌月亮 hero）。旁观者扫一眼只看到「HanaNote + PIN keypad」——和任何普通笔记 / 备忘录 app 锁屏完全相同的视觉特征。这是 HRT 用户在公共场合 / 家人面前的最高保护。

**关键 token**: `display-md` · `body-md` · `body-sm` · `mono` (JetBrains Mono Light 28) · `HanaTokens.background` · `HanaTokens.ink` · `HanaTokens.primary` (仅 hero 竖线 + PIN 焦点圆点 = 2 处) · `HanaTokens.error` (仅错误文字) · `HanaTokens.surfaceContainerHigh` (keypad 键底) · `HanaTokens.accentMuted` (PIN 未填圆点) · `r-card=4` · `motion-instant=80ms` · `motion-quick=150ms`

**关键文案 key**:
- `welcomeBack` → "你回来了。" / "You're back." / "戻りました。"（**zh 在 v2 改用 hero "HanaNote" + 副文 "PIN 解锁。"，welcomeBack 此屏不再使用**——or 移到 hero 副文位置作为隐私选项 P2）
- `lockScreenSubtitle` *（新增 ARB）* → "PIN 解锁。" / "PIN to open." / "PIN で開く。"
- `pinError` *（新增 ARB）* → "PIN 错误。" / "PIN incorrect." / "PIN が違います。"
- `pinErrorRetry` *（新增 ARB，错误次数 ≥3）* → "PIN 错误。再试一次。" / "PIN incorrect. Try again." / "PIN が違います。もう一度。"
- `forgotPin` *（新增 ARB）* → "忘记 PIN" / "Forgot PIN" / "PIN を忘れた"
- `enterFullPin` （沿用，但调性对齐）→ "PIN 未输完。" / "PIN incomplete." / "PIN 未入力。"

### 2.2 PIN 输入行为

- **输入**: 每按一位数字 → `motion-quick=150ms` press scale 0.98 反馈 → 圆点对应位从 accentMuted (远黛) 切换为 primary (黛蓝光标焦点) → 上一位光标退化为 ink (墨色已填)。
- **第 6 位输入完成**: 圆点全部 ink 墨色 → 80ms 视觉停顿（让用户感到"输完了"）→ `AuthCubit.unlock(pin)` 异步校验。
- **校验中（state = `AuthUnlocking`）**: `AuthWrapperPage.buildWhen` 拦截不切屏，lock-screen 自己处理：keypad opacity 0.4，PIN 圆点保持全墨色（不闪不动）。视觉传达"系统正在校验，请等待"。
- **校验成功**: wrapper 切换到 `_TurnPageView`（见 auth-wrapper spec.md）。
- **校验失败**: `AuthError` 由 wrapper listener 转发回此屏 → `_failedAttempts++` → 显示对应错误文案 → `lightImpact()` → 圆点全部清零回 accentMuted → keypad 恢复 opacity 1.0。

### 2.3 错误升级三阶

| 错误次数 | 视觉反馈 | 用户操作 | 备注 |
|---------|---------|---------|-----|
| 1-2 | `pinError` "PIN 错误。" body-sm 朱砂 + lightImpact | 继续输入 | 不预警次数 |
| 3-6 | `pinErrorRetry` "PIN 错误。再试一次。" + lightImpact | 继续输入 | 文字升级，仍不锁屏 |
| 7 ~ (max-3) | 立即弹 `HanaBottomSheet` 警告（详见下） | 必须主动选择 | 阻断式 |
| max（默认 10）| 立即弹 `HanaBottomSheet` 终止确认（详见下） | 必须确认 | 阻断式，最后机会 |

**HanaBottomSheet 警告（错误次数 7-9）**:
```
─────                        ← drag handle
  接近最大尝试次数。
                             ← spacing.lg
  剩 N 次后清除全部数据。
                             ← spacing.lg
  ┌──────────────┐
  │ 我记起来了    │             ← HanaButton.primary (默认 dismiss)
  └──────────────┘
  ┌──────────────┐
  │ 立即重置 — 清除数据 │       ← HanaButton.text destructive 朱砂文字
  └──────────────┘
```
- key `lockWarningTitle` → "接近最大尝试次数。"
- key `lockWarningDesc` → "剩 {n} 次后清除全部数据。"
- key `lockWarningRemember` → "我记起来了"
- key `lockWarningReset` → "立即重置 — 清除数据"

**HanaBottomSheet 终止确认（错误次数 = max）**:
- 不再让用户输 PIN，必须选
- key `lockFinalTitle` → "已达最大尝试次数。"
- key `lockFinalDesc` → "继续将清除全部数据。无法恢复。"
- key `lockFinalRetry` → "再试 1 次"（追加 1 次试错机会，每次 BottomSheet 出现都给一次——避免误触清空）
- key `lockFinalReset` → "确认清除"（`HanaButton.destructive` 朱砂）

### 2.4 生物识别 fallback

- **mobile + biometric enabled**: keypad 左下角是 `fingerprint` 图标键，点击 → `AuthCubit.unlockBiometric()` → 系统对话框 → 成功则同 PIN 成功路径 / 失败则回 lock screen 继续输 PIN
- **web 端（DEC-051）/ biometric disabled**: 该位置透明占位，**不**显示任何"web 不支持"提示（避免暴露平台限制 / 制造焦虑）。用户只能用 PIN。
- **生物识别 OS 弹窗文案**: 系统接管，HanaNote 不控制——但 `LocalAuthentication.authenticate(options: ..., reason: ...)` 的 reason 参数应中性："解锁 HanaNote。"（不是"解锁你的健康记录"——避免暴露内容）

### 2.5 忘记 PIN 流程

- 点 "忘记 PIN" `HanaButton.ghost` → 弹 `HanaBottomSheet`：
  - title: "忘记 PIN？"
  - body: "无法找回。重置将清除本机全部数据。\n已导出的备份不受影响。"（双行，注意第二句给希望）
  - actions: 「不了」`HanaButton.ghost` + 「重置 — 清除数据」`HanaButton.destructive` 朱砂
- 用户确认 → `AuthCubit.wipeData()` → state = `AuthWiped` → wrapper 切到 `SetupPage` 重新设置

**关键文案 key**:
- `forgotPinTitle` → "忘记 PIN？" / "Forgot PIN?" / "PIN を忘れた？"
- `forgotPinBody` → "无法找回。重置将清除本机全部数据。\n已导出的备份不受影响。"
- `forgotPinCancel` → 复用 `cancel` "不了" / "Not now" / "やめる"
- `forgotPinReset` → "重置 — 清除数据" / "Reset — wipe data" / "リセット — 削除"

---

## 3. 跨性别敏感性总览

| 层面 | v1 现状 | v2 修复 |
|-----|--------|--------|
| 视觉暴露身份 | shield_moon hero 图标可让旁观者识别为"私密 app" | 删除 hero 图标，整屏视觉与普通笔记 app 锁屏无异 |
| 文案过度热情 | ja「おかえりなさい」家人语气 | 改「戻りました。」第三人称陈述 |
| 错误处理粗暴 | 输错 N 次无预警直接 wipe | 三阶升级（警示 / BottomSheet 警告 / 终止确认） |
| 无忘 PIN 路径 | 只能错 N 次触发 wipe | 显式 "忘记 PIN" 按钮 + 双行警示 BottomSheet |
| 触觉冲击 | heavyImpact 触发心率 | lightImpact 仅传达信号 |

---

## 4. 关键 token 与文案 key 汇总

| 类别 | Token / Key | 值 / 用途 |
|------|-----------|----------|
| Color | `HanaTokens.background` | 月白 / 暖深 |
| Color | `HanaTokens.ink` | 墨色 — hero 标题 / PIN 已填圆点 / keypad 数字 |
| Color | `HanaTokens.primary` | 黛蓝 — 仅 hero 4px 竖线 + PIN 焦点圆点（2 处） |
| Color | `HanaTokens.surfaceContainerHigh` | 米灰 — keypad 键底 |
| Color | `HanaTokens.accentMuted` | 远黛 — PIN 未填圆点 |
| Color | `HanaTokens.error` | 朱砂 — 错误文字（仅一处暖色） |
| Color | `HanaTokens.inkSecondary` | 淡墨 — 副文 / 退格图标 |
| Type | `display-md` | hero 标题 |
| Type | `body-md` | hero 副文 |
| Type | `body-sm` | 错误文字 |
| Type | `mono` | JetBrains Mono Light 28pt — keypad 数字 |
| Radius | `r-card=4` | keypad 键圆角 |
| Radius | `r-pill` | PIN 圆点（直径 8） |
| Motion | `motion-instant=80ms` | 圆点切换 / 错误淡入 |
| Motion | `motion-quick=150ms` | keypad press 反馈 |
| Copy key (新增) | `lockScreenSubtitle` `pinError` `pinErrorRetry` `forgotPin` `lockWarningTitle` `lockWarningDesc` `lockWarningRemember` `lockWarningReset` `lockFinalTitle` `lockFinalDesc` `lockFinalRetry` `lockFinalReset` `forgotPinTitle` `forgotPinBody` `forgotPinReset` | 详见 §2 各小节 |

— 完 —
