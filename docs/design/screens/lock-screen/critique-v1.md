# Lock Screen 屏 v1 现状 Design Critique

> **审视范围**: `lib/features/auth/presentation/pages/lock_screen_page.dart`（287 行单文件）
> **对照基准**: DESIGN.md（v2 编辑级东亚） + tokens.md + principles.md（5 原则 + 严禁清单）+ PRODUCT-VISION.md（隐私第一）
> **权重提示**: Lock Screen 是 HRT 用户**每次回访 app** 必经之屏——视觉 / 文案 / 节奏违规 **权重 ×3**（仅次于 Onboarding 首屏）
> **生成时间**: 2026-04-29

---

## 概述

Lock Screen 是 HanaNote 用户**最敏感的入口**——每次打开 app（设置 `autoLockMinutes` 后台超时也会触发），用户都要在这一屏停留 1-3 秒。它的意义远超"输入 PIN"：它是**用户从外部世界（家人 / 同事 / 公共场合）回到自己私人内刊的过渡仪式**。如果这一屏视觉冷漠 / 文案紧张 / 节奏催促，HRT 用户会感到"被审讯"——本应保护他们的安全机制，反成情感负担。

v1 的实现尝试做了温和——`Icons.shield_moon_rounded` + `welcomeBack` "欢迎回来" + 渐变背景 + 大圆角 keypad——它显然**有过设计意图**（不是粗暴的 PIN pad），但每一个具体选择都落在了 v1 信纸感语法里：圆形盾牌图标、双语 "Welcome back" 客套、stadium-radius 卡片按钮、居中对称布局、粉调渐变。这些都是 v2 严禁项。

整屏共扫出 **14 处 v2 严禁项 + 4 处跨性别敏感性盲点 + 3 处节奏 / 安全性问题**，需要 Pilot Wave 中重写。

---

## 第一印象 5 秒原则（回访视角）

新用户第一次到 lock screen 已经经过 setup（即至少接触过 v2 setup spec，假设设置屏也已重写）。**回访用户**在每次开 app 前 1.5 秒看到 lock screen，他的认知期待是：
- "我回到了自己的私人空间"
- "这一秒只属于我"
- "app 认得我"

v1 的实际呈现：
- **Hero 视觉**（L73-85）：92×92 圆角 30px 容器 + `Icons.shield_moon_rounded` 44px primary 色——一个发光的盾牌月亮 emoji。**问题**：① 圆角 30 ≥ 8 是 v2 严禁；② "shield" 暗示"防御 / 攻击"叙事，对未出柜用户是焦虑放大器（"app 在保护我抵御谁？"）；③ moon 图标是 v1 时代"夜晚 / 私密 / 仪式"的视觉符号，与新潮文库杂志感无关。
- **欢迎文案**（L88, key `welcomeBack`）：v1 zh "欢迎回来" / en "Welcome back" / ja "おかえりなさい"——三语温度不均衡，ja「おかえりなさい」过度温热（家人语气），en「Welcome back」客套，zh 中性。已有 ux-copy-v2 §1 改写为「你回来了。」/「You're back.」/「戻りました。」第三人称陈述。
- **PIN 圆点**（L31-44）：6 个 14×14 圆 (`borderRadius: 999`) — 全圆。色 `HanaColors.primary` 实填 / `outlineVariant` 未填。**问题**：圆点虽小但全屏 6 颗黛蓝点同时出现，黛蓝总数立即超 3 处上限。
- **错误反馈**（L108-118）：`AnimatedOpacity` 180ms 淡入红字 + `HapticFeedback.heavyImpact()`——节奏接近 v2 但**heavyImpact 在 HRT 长期焦虑用户身上是触发器**（重震动 ≈ 紧急通知 ≈ 心率加快）。
- **Keypad 容器**（L276-285）：`Material` + `surfaceContainerLowest` + `BorderRadius.circular(24)` — **v2 严禁圆角 ≥ 8**。
- **背景**（L54-62）：`LinearGradient(background → surfaceContainerLow)`——v2 严禁渐变（principles.md 严禁清单第 2 条）。

**第一印象判定**：v1 lock screen 在前 1.5 秒呈现「Material 3 demo + 信纸感」，**未达成「回到内刊」的仪式感**。

---

## v2 五原则违规点（带 file:line）

### 原则 1: 一抹强色（黛蓝 ≤ 3 处 / 屏）

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 1 | Hero 盾牌图标 `Icons.shield_moon_rounded` 是 primary 色（黛蓝） | L83 | **删除整个 hero 圆形容器**（违反原则 5），不需要讨论上色 |
| 2 | PIN 圆点 6 个全用 `HanaColors.primary` 实填（输入态） | L40 | 单点 14×14 黛蓝圆点 ×6 = 黛蓝面积 ≈ 1176px²，按"位置数"计 6 处。修复：圆点输入态改 `HanaTokens.ink` 实色（墨色不算黛蓝）；未填态改 surface 阶差（`accentMuted` @ 30%），不画轮廓；**最多 1 处保留黛蓝**（最末输入位的"光标焦点"指示） |
| 3 | Keypad 生物识别按钮 icon `Icons.fingerprint_rounded` 是 primary 色 | L235 | 黛蓝在 keypad 内不能再出现（已经被 PIN 焦点圆点占用）；改 `HanaTokens.ink` |
| 4 | 错误文字色 `HanaColors.error` （朱砂） + 加粗 w600 | L114-115 | 朱砂是冷暖对峙的唯一暖色——必须保留这一处，但**只限错误文字本身**，不再扩展（不要加图标 / 边框 / 背景） |

**累计违规**: 单屏黛蓝出现位置 **≥ 8 处**（hero icon + 6 圆点 + 生物识别 icon），原则 1 硬上限是 3 处。**黛蓝在本屏严重贬值**。

### 原则 2: 调和层次胜过投影

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 5 | 整屏背景是 `LinearGradient(background → surfaceContainerLow)` | L55-62 | 删除渐变，改 `HanaTokens.background(context)` 实色 |
| 6 | Hero 圆形容器 `surfaceContainerLowest` + 圆角 30 — 模仿浮起卡片但无投影，本质是**伪 elev** | L74-81 | 删除整个容器（hero 应是 display-md 文字本身） |
| 7 | Keypad button 容器 `Material` + `surfaceContainerLowest` + `r=24` | L277-285 | r-card=4，且不需要单独 Material 容器——直接 `InkWell` 在 background 上 + 文字即可（v2 keypad 是"印刷数字网格"不是"实体按键") |

### 原则 3: 编辑级不对称

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 8 | 整屏 `mainAxisAlignment: MainAxisAlignment.center` + Center wrap + `MainAxisAlignment.center` 行内 | L65-71, L101 | hero 文字「HanaNote」+ 副文字「PIN 解锁」**左对齐 32px**；PIN 圆点行可保持居中（**视觉重心 = PIN 显示**，居中是其语义必需，例外接受）；keypad 居中（同理） |
| 9 | 没有章节段落标记（标题左侧 4px 黛蓝竖线） | 整屏 | 「HanaNote」标题左侧加 4px 黛蓝竖线，仅覆盖标题首行——这是黛蓝在本屏的**第一处合法位置** |

### 原则 4: 慢节奏与留白

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 10 | 顶部 hero 圆 → 标题间 28px (L86) → PIN 圆点间 12px (L99) → 错误间 14px (L107) → keypad 间 28px (L119)，**多处不在 token spacing 内**（28 / 14 / 12 都不是 4/8/16/32/64） | 多处 | 全部对齐 token：标题→PIN 用 lg=32，PIN→错误用 sm=8，错误→keypad 用 lg=32 |
| 11 | 输完 6 位 PIN 即 `Future.microtask(_handleConfirm)` 立即提交（L156）——节奏紧促 | L156 | 保留即时提交语义（用户期待无需手动确认），但加 80ms `motion-instant` 圆点全填的视觉停顿，让用户感到"我刚输完了"——避免输完瞬间屏幕跳走 |
| 12 | 错误反馈 `HapticFeedback.heavyImpact()` 太重 | L141 | 改 `lightImpact()`——HRT 用户长期焦虑情境下，重震动 = 心率冲击；轻震动 = 信号传达即止 |

### 原则 5: 内容即装饰

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 13 | Hero 图标 `Icons.shield_moon_rounded` 装饰承担情感重量 | L82 | 删除——文字「HanaNote」display-md 黑墨宋体本身就是装饰；副文字「PIN 解锁」body-md 淡墨补充 |
| 14 | Keypad 字体未指定 mono——使用 default sans 28 w600（L253-257） | L253 | 数字必须用 `JetBrains Mono Light`（tokens.md §2 mono channel）——v2 keypad 是"印刷数字网格"，mono 字体是核心装饰语 |

---

## 跨性别敏感性盲点

Lock screen 是 HRT 用户最易"被看见"的瞬间——他们可能在公共场合 / 家人面前 / 工位旁打开 app。v1 在以下 4 处未达 PRODUCT-VISION 隐私第一的要求：

### 盲点 #1：Hero 图标暴露身份

`Icons.shield_moon_rounded` 92×92 居中——**任何人扫一眼都能识别是某种"私密 / 安全"app**。组合"盾牌 + 月亮 + PIN keypad"的视觉特征会让旁观者立即理解"用户在打开一个有秘密的 app"。这违反"零暴露"原则——理想的锁屏应该看起来**像任何普通的笔记 / 日记 app 锁屏**，没有"我有秘密"的视觉标记。

**修复**: 删除 hero 图标。屏幕只有「HanaNote」文字（用户已经接受品牌名称是"花笺"语义但中性）+ 「PIN 解锁」副文 + keypad。视觉上无法区分这是健康 / 日记 / 备忘录 app。

### 盲点 #2：「欢迎回来」过度热情（en/ja 尤甚）

`welcomeBack` v1 ja "おかえりなさい" 是**家人迎接归家的温度**——对未出柜用户在家人面前打开 app 是危险情境（家人若瞥见"おかえりなさい" + 6 位 PIN，会问"这是什么？"）。

**修复**: 已经被 ux-copy-v2 §1 改写为「你回来了。/ You're back. / 戻りました。」第三人称陈述，温度等温且本身可隐含为任何 app 的回访问候，不暴露 HanaNote 的私密属性。

### 盲点 #3：错误次数无升级 UX，最大失败次数后直接 wipe

`AuthCubit.unlock()` 逻辑（cubit.dart L110-115）：失败次数 `_failedAttempts++` → 若 `>= maxFailedAttempts` (用户配置) → `wipeData()`。**v1 lock screen 完全不向用户预警**——它只在最末次"PIN 错误"消息后直接清空全部数据，没有"还剩 N 次 / 即将清除 / 先备份"等阶梯通知。

对 HRT 用户：他们的数据可能含 1-2 年的 HRT 进展、血检、日记——**意外被自己输错触发 wipe** 是灾难性的。同时这也是攻击面：陌生人拿到手机，连续猜 5 次（默认配置可能是 5）就能把所有数据擦掉。

**修复**: lock screen 文案分级：
- 错误次数 ≥ 3：错误文字下方加一行 `body-sm` 朱砂"PIN 错误。再试一次。"（**不锁住，但可见**——让用户感到"系统在跟踪"）
- 错误次数 ≥ 7（提前 maxFailedAttempts ~3 次）：弹出 `HanaBottomSheet` 警告"接近最大尝试次数。{N} 次后将清除全部数据。"提供"我记起来了"和"重置——清除数据"两个选项
- 错误次数 ≥ 10 / 触发 maxFailedAttempts：执行 wipe，但**先弹一个最终确认 BottomSheet**"将清除全部数据。是否继续？"——给用户最后一次"我记起来了，让我再试"机会

### 盲点 #4：「忘记 PIN」无入口

v1 lock screen **没有"忘记 PIN"链接**。用户唯一恢复方式是连续输错触发 wipe（且该 wipe 也不预警）——这等于**无显式恢复路径**。HRT 用户在长期焦虑 / 失眠 / 药物副作用下记忆波动是常态，"忘 PIN" 不是边缘场景，是**正常使用场景**。

**修复**: keypad 下方加一行 `HanaButton.text` "忘记 PIN"（单行文字按钮），点击弹 `HanaBottomSheet` 解释"忘记 PIN 将清除全部数据，无法恢复。已备份过的内刊不受影响。" + 两个按钮"取消" + "重置——清除数据"。

---

## 安全性 / 工程债盲点

### 盲点 A：PIN 长度硬编码 6 位但 setup 可能允许 4 位

v1 lock screen `_pin.length >= 6` 硬编码（L151, L155, L167）。如果 setup spec 允许用户选 4 / 6 位 PIN（v2 设计建议默认 6 位但提供 4 位选项），lock screen 必须读 `_settings.pinLength`。

### 盲点 B：背靠 web 端无生物识别

CLAUDE.md DEC-051: Web 端不支持生物识别。v1 lock screen `biometricAvailable` 由 cubit 决定（L17-18, cubit L174-176），但**布局假设 keypad 第 4 行第 1 列总有位置**——若 web 端 biometric 不可用，该位置 `SizedBox.shrink()`（L227），**留白处理 OK 但不优雅**——v2 应在 web 端把"忘记 PIN"按钮挪到该空位，避免视觉空洞。

### 盲点 C：解锁后无过渡

`AuthCubit.unlock()` 成功后 emit `AuthUnlocked` → wrapper 立即切到圆环占位 → SettingsLoaded 后 `context.go('/today')`。**用户在 lock screen 输完正确 PIN 看到的是：圆点全填 → 立即切屏 → 圆环 → today**——节奏催促。v2 spec 已修复（见 auth-wrapper spec.md `_TurnPageView`）。

---

## 优先级建议

- **P0（spec 必含 + 工程必修）**: 违规 #1/#2/#5/#13（hero / 圆点 / 渐变 / 装饰图标）+ 跨敏 #1/#3/#4（hero 暴露 / 错误升级 / 忘记 PIN）
- **P1（spec 强烈推荐）**: 违规 #7/#10/#14（keypad 圆角 / 间距 token / mono 字体）+ 跨敏 #2（已由 ux-copy 修复）+ 工程 A（PIN 长度可配置）
- **P2（可优化）**: 违规 #11/#12（80ms 停顿 / 轻震动）+ 工程 B（web 端布局优化）

— 完 —
