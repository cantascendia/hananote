# Setup 屏 v1 现状 Design Critique

> **审视范围**: `lib/features/auth/presentation/pages/setup_page.dart`（198 行单文件）
> **对照基准**: DESIGN.md（v2 编辑级东亚） + tokens.md + principles.md（5 原则 + 严禁清单）+ ux-copy-v2/copy-revisions.md
> **权重提示**: Setup 是用户**首次设置 PIN** 的屏（也是忘记 PIN / 重置后的入口）——文案敏感性 **权重 ×3**（涉及"保护内容"叙事，跨性别敏感词易触雷）
> **生成时间**: 2026-04-29

---

## 概述

Setup 屏出现在三个时刻：① 首次启动 app 完成 onboarding 后（实际流程：onboarding → setup → today，setup 在中间）；② 用户在 lock screen 点"忘记 PIN" 触发 wipe 后；③ 错误次数达 max 触发 wipe 后。**它是用户与 HanaNote 建立"信任契约"的瞬间**——他/她在这一秒决定要不要把 1-2 年的 HRT 进展交给这个 app。

v1 实现采用经典"卡片 + 表单"模式：一张 r=28px 圆角卡居中 + 顶部标题 + 描述 + 两个 obscureText TextField（密码 / 确认密码）+ SwitchListTile 生物识别 + 一个 ElevatedButton "保存"。卡片有黛蓝阴影 alpha=20 模拟悬浮。整体观感是 **Material 3 标准注册页**——和任何银行 app / 钱包 app 设置 PIN 流程视觉无差异。

这意味着两件事：① 视觉 / 节奏完全是 v1 信纸感语法（与 lock screen 同病——但更严重，因为 setup 屏内容更多）；② **更危险的是文案**——v1 zh `setupSecurePassword` "创建安全密码" + `setupPinDescription` "设置 6 位 PIN 以保护你的私密健康数据" 暗藏"保护你的秘密"叙事，**这正是 HRT 用户在跨性别敏感性维度最不希望听到的措辞**。它把 PIN 从"内容拥有权"降级为"防御机制"——隐含"你有秘密 / 你需要躲藏"。

整屏共扫出 **15 处 v2 严禁项 + 5 处跨性别敏感性盲点 + 4 处可用性 / 工程问题**。

---

## 第一印象 5 秒原则

新用户走完 onboarding 5 屏后到达 setup 屏。他/她已经被 onboarding 的杂志感语法（"内刊。" / display-xl 宋体 / 不对称留白）"调教"过——突然进入 setup 屏，看到的是：

- **视觉切换**（L86-97）：一张 28px 圆角卡片 + alpha=20 黛蓝阴影 + 居中——视觉语法 180 度回到 Material 3。**这是节奏断裂**。Onboarding 留下的"杂志阅读"心境瞬间崩塌。
- **标题**（L104-110）：`setupSecurePassword` "创建安全密码" 28px w700 黑墨——字体重量 w700 极重（v2 Display 用 SemiBold = w600，且依赖宋体撇捺而非粗体），且**未指定字体**（系统默认 sans）——onboarding 用宋体，setup 用 sans，**视觉系统割裂**。
- **副描述**（L112-117）：`setupPinDescription` "设置 6 位 PIN 以保护你的私密健康数据。" — 文案触雷词：① "私密"暗示"应该躲藏"；② "健康数据"明确暴露医疗属性（即使是用户自己看，也是不必要的提醒）；③ "保护"是防御叙事。
- **PIN 输入**（L120-139）：两个 TextField + obscureText + maxLength 6 + filteringTextInputFormatter。**视觉是 Material 信纸感**：filled background + underline + lock_outline_rounded 前缀图标 + label "密码"。**setup 屏无视觉化 PIN 圆点反馈**——用户在打字时只看到 ●●●● 系统默认 obscure 字符，不是 lock screen 那种圆点显示。这导致 setup 和 lock screen 在 PIN 输入交互上**视觉语法不一致**，新用户接下来到 lock screen 会有"为什么变了？"的认知摩擦。
- **生物识别开关**（L164-170）：`SwitchListTile.adaptive` + label "启用生物识别"——单行 toggle，**没有解释为什么 / 如何 / 数据存在哪里**。HRT 用户面对"生物识别"会有合理疑问："指纹会传到云吗？" "Face ID 能扫出我的性别吗？"v1 零回应。
- **保存按钮**（L172-184）：`ElevatedButton + backgroundColor: primary` 全宽，文案 "保存"——v2 ux-copy 已改 "收存"（save → keep），但这里仍是工具感"保存"。

整屏共 5 个明显的视觉 / 文案 / 节奏断裂——用户在 5 秒内会感到"前面 onboarding 那本内刊只是装饰，这才是真正的 app"。

---

## v2 五原则违规点（带 file:line）

### 原则 1: 一抹强色（黛蓝 ≤ 3 处 / 屏）

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 1 | 卡片 boxShadow 用 `HanaColors.primary.withAlpha(20)` 黛蓝阴影 | L92-95 | 删除卡片本身（hero 文字直接放 surface），无阴影 |
| 2 | TextField focusedBorder 用 `HanaColors.primary` 2px 黛蓝下划线 | L132-137, L155-160 | 保留——这是 v2 form focus 唯一允许的 outline 例外（principles.md 第 3 条第 5 项）；但只在 focus 状态出现，**且仅 1 个 TextField 会同时 focus**，所以仍是 1 处黛蓝 |
| 3 | TextField prefixIcon `Icons.lock_outline_rounded` / `Icons.verified_user_outlined` 默认色 = primary | L131, L153 | 删除 prefixIcon——v2 form 不依赖图标承担语义，label "密码 / 确认密码" 已经足够 |
| 4 | SwitchListTile.adaptive 在 iOS 用 system blue / Android 用 Material primary——颜色不可控 | L164 | 替换为 `HanaSwitch` v2 组件（28×16 长条 + 12 圆滑块 + primary 实填——黛蓝在此是合法的"开启状态指示" #2） |
| 5 | ElevatedButton `backgroundColor: HanaColors.primary` 全宽 | L177 | 改 `HanaButton.primary fullWidth=false` 左对齐 32px，**不全宽**（杂志按钮即印章） |

### 原则 2: 调和层次胜过投影

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 6 | 整个 SafeArea 内容嵌在 `DecoratedBox` 圆角 28 卡片 + boxShadow | L86-97 | **删除整个卡片容器**——v2 setup 屏不再用卡片，hero / 表单 / 按钮直接落在月白 background 上，靠间距分隔（与 onboarding spec.md 的整体语法对齐） |
| 7 | 背景 `LinearGradient(background → surfaceContainerLow)` | L70-78 | 改 `HanaTokens.background(context)` 实色 |
| 8 | TextField filled 状态用默认 fillColor（M3 surfaceVariant） | 隐式（默认） | v2 TextField "无外框 + 底部 1px outline / focus 时 2px primary"，无 filled |

### 原则 3: 编辑级不对称（居中是默认懒惰）

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 9 | 整屏 `Center` wrap + 卡片居中 + 卡片内 `crossAxisAlignment: CrossAxisAlignment.start` | L81-85, L100 | 删除 Center；hero / 表单 / 按钮全部左对齐 32px |
| 10 | 没有章节段落标记（标题左侧 4px 黛蓝竖线） | L104 | hero 标题左侧加 4px 黛蓝竖线（仅覆盖标题首行）——这是黛蓝在本屏的**第 3 处合法位置** |

### 原则 4: 慢节奏与留白

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 11 | 标题 → 描述 10 (L112) → 表单 24 (L119) → 表单内间 12 (L140) → 开关上下 8 (L163, 171) → 按钮 padding 14 (L181)，**多处不在 token spacing 内** | 整 build | 全部对齐 token：标题 → 描述 sm=8；描述 → 表单 lg=32；两 TextField 间 md=16；表单 → 开关 lg=32；开关 → 按钮 lg=32；按钮 vertical padding 由 HanaButton 控制 (sm=8) |
| 12 | 整屏 padding=24（L83）+ 卡片内 padding=24（L99）= 48px 总 padding——v2 应是 32 直落到 padding | L83, L99 | 整屏 horizontal padding=32（统一与 hero / lock-screen 一致） |
| 13 | PIN 输入完成无视觉反馈节奏（用户输完 6 位后等用户手动按"保存"） | 整流程 | v2 应支持"输完 6 位 + 6 位确认 → 自动校验"（与 lock screen 输完即提交一致），保存按钮变为 fallback；**或**保留显式"保存"但加视觉反馈（PIN 圆点显示） |

### 原则 5: 内容即装饰

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 14 | TextField prefixIcon `lock_outline_rounded` / `verified_user_outlined` 装饰承担语义 | L131, L153 | 删除——文字 label 已传达，图标多余 |
| 15 | 标题字体未指定 fontFamily—— 默认系统 sans | L107 | `display-md` 必须用 Spectral SemiBold（en）/ 思源宋体 Medium（zh）/ Noto Serif JP Medium（ja） + fontFamilyFallback；**w700 改 w600** |

---

## 跨性别敏感性盲点

Setup 屏文案是 HRT 用户与 HanaNote 建立"信任契约"的关键时刻——v1 在 5 处使用了"保护秘密"叙事，违反 PRODUCT-VISION 的"内容拥有权"（不是"防御机制"）原则。

### 盲点 #1：标题 "创建安全密码" → "保护你的秘密" 叙事

`setupSecurePassword` 现 zh "创建安全密码" / en "Create Secure Password" / ja "セキュアパスワードを作成"——"安全"一词在 PIN 设置语境下**默认指向"防御外部攻击"**，对未出柜用户是放大焦虑（"app 在告诉我'有人会想攻击我'"）。

**修复**: ux-copy-v2 §1 已改为「设定密码。」/「Set a passcode.」/「暗証番号を設定。」 — 去"安全"赘词，改为中性陈述。**采纳即可**。

### 盲点 #2：副描述 "保护你的私密健康数据" → 三重触雷

`setupPinDescription` 现 zh "设置 6 位 PIN 以保护你的私密健康数据。" 触三个雷：
- "私密"——隐含"应该躲藏"
- "健康数据"——明确暴露医疗属性（即使是给用户自己看，也是在他/她"还没准备好被定义"的时刻贴标签）
- "保护"——防御叙事

**修复**: ux-copy-v2 §1 已改为「6 位数字。仅本机可解。」/「Six digits. Local only.」/「6 桁。この端末のみ。」 — **从抽象承诺改为具体技术事实**。"仅本机可解"是用户能验证的（与 PRODUCT-VISION "本地优先"原则对齐），"私密 / 健康"等敏感词全部移除。**采纳即可**。

### 盲点 #3：生物识别开关无解释 + 默认含义模糊

`enableBiometric` 现 zh "启用后使用生物识别" — 单行开关无副描述。HRT 用户面对此开关会有合理担忧："指纹会传到云吗？" "iOS Face ID 能识别出我的性别 / 表情变化吗？" "如果我术后面容改变，Face ID 还认得我吗？"

v2 ux-copy 已把 label 改为「启用生物识别。」语义更主动，但**仍缺解释**。

**修复**: 开关下方加 helperText `body-sm` 淡墨："生物识别仅本机校验，不上传。" / "Biometric stays on this device. Never uploaded." / "生体認証はこの端末のみ。送信されず。"——给具体技术事实。**新增 ARB key `biometricNote`**。同时点击开关时弹 `HanaBottomSheet` 提供详细解释（首次启用时）：标题"生物识别说明。" + body 三行陈述："① 仅本机校验。\n② 指纹 / Face 数据不离开手机。\n③ 失败时可改用 PIN。" + 两个按钮"启用" + "暂不"。

### 盲点 #4：忘记 PIN 重置后无任何提示进入

当用户从 lock screen "忘记 PIN" 触发 wipe 后，wrapper 切到 `setupPage`——**和首次设置完全一致的视觉**。但用户的心境完全不同——他/她刚刚"清除了 1 年的 HRT 记录"。v1 不区分这两种入口，文案完全一致是冷漠的。

**修复**: `SetupPage` 接受可选 `mode: SetupMode.firstTime | SetupMode.afterWipe` 参数。`afterWipe` 模式下：① hero 文案改「重新开始。」（en: "Begin again." / ja: "もう一度。"）；② 副文案改「数据已清除。继续即可。」（en: "Data cleared. Continue." / ja: "削除済み。続けて。"）；③ 视觉无装饰区别（不加"安慰图标"），仅文案承担情感重量。**新增 ARB keys `setupAfterWipeTitle` / `setupAfterWipeDesc`**。

### 盲点 #5：保存后无确认仪式

`AuthCubit.setupPin()` 成功后立即 emit `AuthUnlocked` → wrapper 立即跳转。**用户刚设完 PIN 没有任何"确认"反馈**——他/她可能在 5 秒后想"我刚才设的 PIN 是什么来着？"。这对 HRT 用户长期焦虑情境是双重打击。

**修复**: 保存成功后**先弹 `HanaBottomSheet`**「记住这 6 位。」/「Remember these six.」/「6 桁を覚えて。」 + body "丢了无法找回。" + 按钮"我记住了"——用户主动确认后才路由。**新增 ARB keys `setupConfirmTitle` / `setupConfirmDesc` / `setupConfirmAck`**。

---

## 可用性 / 工程盲点

### 盲点 A：两次 PIN 一致校验时机

v1 `_validatePin()` 仅在用户按"保存"按钮时触发（L49-50）。如果用户先输完密码 6 位，再输确认密码错了 1 位，按"保存"后才看到错误——节奏不顺。**修复**：当两次都输完 6 位时立即校验，错误立即显示（同 lock screen 节奏）。

### 盲点 B：obscureText 体验差

v1 用系统默认 obscure 字符（•）。用户没法回看自己输了几位。**修复**：参考 lock screen，setup 也用 PIN 圆点显示——但因为有"密码"和"确认密码"两栏，可设计为：① 仍用 TextField + obscureText（标准、可访问性好）+ ② 在 TextField 上方各显示一行 6 个圆点跟随输入（视觉化反馈）。或更激进：完全替换为两组 PIN 圆点 + 共用 keypad（与 lock screen 视觉语法完全一致）。**spec 推荐后者**——一致性收益大于实现成本。

### 盲点 C：键盘抢占

v1 用 `keyboardType: TextInputType.number` 系统数字键盘——但 setup 屏整屏内容已经较多（标题 + 描述 + 两个 input + 开关 + 按钮），系统键盘弹出后内容被遮挡，用户必须 scroll。**修复**：用 lock screen 同款自定义 keypad，无系统键盘，整屏可见——这也修复 #B 的视觉一致性问题。

### 盲点 D：ARB 笔误

ux-copy-v2 §11 已识别 `app_zh.arb:374` 附近 `"確認密码"`（繁简混用）→ `"确认密码"`，**立即修**。

---

## 优先级建议

- **P0（spec 必含 + 工程必修）**: 违规 #1/#5/#6/#9/#15 + 跨敏 #1/#2（文案采纳 ux-copy）/#5（保存确认 BottomSheet）+ 工程 D（ARB 笔误）
- **P1（spec 强烈推荐）**: 违规 #2-4/#7-8/#10-13/#14 + 跨敏 #3（生物识别说明）/#4（afterWipe 模式）+ 工程 B/C（PIN 圆点 + 自定义 keypad）
- **P2（可优化）**: 违规 #2 outlineFocus 边界细化 + 工程 A（双输完成即校验）

— 完 —
