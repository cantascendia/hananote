# 候选方向 B：科技隐私（Tech-Privacy）

> 设计师立场：Linear / Signal / ProtonMail / Arc Browser 学派。我相信——隐私不是开关，是审美；本地存储不是合规话术，是可被 SEEN 的设计语言。

---

## 1. 北极星（一句话定位）

**"你的数据从未离开这台设备" —— 让这句承诺以像素的形式被 SEEN，而不是被声明。**

HanaNote v1 的花笺方向把"私密空间"写成了温柔散文，但散文是别人在讲；v2 方向 B 要把它写成产品本身的视觉句法——深邃的暗色、克制的等宽数字、像素级精确的对齐、隐约的离线发光，每一帧都在无声地告诉用户："这里没有云，没有上报，没有第三方眼睛。"

---

## 2. 心智 Mood Keywords

深邃 · 加密感 · 私密 · 等宽字体重音 · 暗色优先 · 终端美学 · 高对比 · 像素级精确 · 数据可视化 · 信号/噪音 · 隐写术 · 离线发光 · 几何 · 磷光绿瞬态 · 安静的克制

---

## 3. 色彩系统

### Light Mode（"开着灯的私密空间"）
方向 B 是 dark-first，但 light mode 不能背叛灵魂。它不是给阳光下使用的"亮模式"，而是"我把屋顶灯打开了，但屋子还是我的"。整体调子接近 Linear / Arc Browser 的 light：冷灰带极淡紫底，**绝不米白**。

| Token | Hex | 命名 | 用途 |
|-------|-----|------|------|
| `bg.canvas` | `#ECEAE7` | Paper Mist 灰白 | 全局背景，比花笺奶油白冷一档、低一档明度 |
| `bg.surface.0` | `#F2EFEA` | Surface Lift 0 | 卡片底层 |
| `bg.surface.1` | `#E8E5E0` | Surface Lift 1 | 嵌套卡片 |
| `bg.surface.2` | `#DFDCD7` | Surface Lift 2 | 输入区/容器 |
| `bg.surface.3` | `#D5D2CD` | Surface Lift 3 | 按下态/激活态 |
| `ink.primary` | `#0F0F11` | Carbon Ink | 主文本，暖深而非纯黑 |
| `ink.secondary` | `#3A3A3F` | Carbon Ink 70 | 次文本 |
| `ink.tertiary` | `#6B6B72` | Carbon Ink 45 | label/timestamp |
| `accent.signal` | `#5E6AD2` | Signal Violet | 主交互色（Linear 同款紫，磷光感） |
| `accent.signal.dim` | `#3F4799` | Signal Violet Dim | 按下态 |
| `accent.phosphor` | `#3FB950` | Phosphor Green | success / 已加密 / 离线确认 |
| `accent.terminal` | `#F85149` | Terminal Red | error / 销毁数据 / 高敏操作 |
| `accent.amber` | `#D29922` | Sodium Amber | warning / 库存偏低 |

> **取名说明**：Signal Violet 致敬 Linear，Phosphor Green 致敬老式 CRT 终端的磷光绿（"离线 / 本地"的视觉胎记），Sodium Amber 致敬钠灯——夜里仍亮的那种工业光。

### Dark Mode（B 的主战场）

| Token | Hex | 命名 | 用途 |
|-------|-----|------|------|
| `bg.canvas` | `#0E0B14` | Encrypted Indigo | 全局背景，**暖紫黑**而非冷蓝黑或纯黑 |
| `bg.surface.0` | `#15121C` | Surface Vault 0 | 第一层卡片，仅 +6% 明度 |
| `bg.surface.1` | `#1B1825` | Surface Vault 1 | 嵌套层 |
| `bg.surface.2` | `#211E2D` | Surface Vault 2 | 输入区 |
| `bg.surface.3` | `#272436` | Surface Vault 3 | 激活态 |
| `ink.primary` | `#E8E5E0` | Bone White | 主文本，**米白而非纯白** `#FFFFFF`（避免视觉刺眼） |
| `ink.secondary` | `#A8A5A0` | Bone White 65 | 次文本 |
| `ink.tertiary` | `#6B6864` | Bone White 40 | label/timestamp/等宽数字注释 |
| `accent.signal` | `#7B85E8` | Signal Violet (lifted) | dark 下提亮一档保对比度 |
| `accent.phosphor` | `#56D364` | Phosphor Green (lifted) | "已加密""本地保存"等微小指示器 |
| `accent.terminal` | `#FF7B72` | Terminal Red (lifted) | error / wipe |
| `accent.amber` | `#E3B341` | Sodium Amber (lifted) | warning |

**暗色四级 surface 的工程要诀**：层与层之间只用 **6%–8% 明度差**，不靠阴影，不靠边框。这是 Arc Browser / Linear 都在用的"几乎看不见的层次"——**眼睛感受到深度，但说不出来差在哪**——这种"说不出来"恰恰是私密性的视觉同义词。

---

## 4. 字体系统

| 角色 | 西文 | 中文 | 日文 | 用法 |
|------|------|------|------|------|
| Sans 主字体 | **Inter** w400/500/600 | 思源黑体 / 苹方-简 w400/500 | 思源黑体 JP | 所有 Body / Heading |
| **Mono 等宽**（B 的标志性元素） | **JetBrains Mono** w400/500 | （回退到等宽中文：Sarasa Mono） | 同左 | 数字 / 剂量 / 时间戳 / 加密签名 / HRT 第 N 天 |
| Display | Inter w700（紧 tracking -1%） | 思源黑体 w700 | 思源黑体 JP w700 | 大数字 hero 区 |

**Type Ramp**（紧凑、技术感、行高克制——拒绝 editorial 的呼吸）：

| Slot | Size / Line / Tracking | 用途 |
|------|------------------------|------|
| `display` | 32 / 36 / -1.5% | 大数字 hero（如 "Day 287"） |
| `heading.lg` | 22 / 26 / -1% | 屏标题 |
| `heading.md` | 17 / 22 / -0.5% | 卡片标题 |
| `body.lg` | 15 / 22 / 0 | 正文 |
| `body.md` | 13 / 18 / 0 | 副文 / 描述 |
| `mono.md` | 14 / 18 / 0 | **数字 / 剂量 / HRT 第 N 天 / 时间戳 / hash** |
| `mono.sm` | 12 / 16 / +1% | 时间戳 / metadata |
| `label` | 11 / 14 / +5% (uppercase) | section label，**全大写、tracking 放宽**——SECTION HEADERS 像 IDE 的标题 |

**关键**：所有数据位（剂量 mg、HRT 第 287 天、血药浓度 pg/mL、PK 模拟器的峰谷值）**强制等宽 mono**。这是方向 B 的视觉胎记——把"数字 = 信号、文本 = 噪音"的等级关系明示给眼睛。花笺方向用 Plus Jakarta Sans 处理数字是反例：圆润亲切 ≠ 精确可信。

---

## 5. Layering 哲学

**"看不见的层次"是 B 的工程信条。** 不是没层次——而是层次以**最小可感知的明度差**实现。

- **暗色下层间明度差 6%–8%**：用户感受到"这张卡浮在背景上"，但盯着看不出边在哪
- **拒绝 box-shadow** —— 阴影是"漏出去的光"，不符合"密室无漏光"的隐喻
- **像素级 alignment** —— 网格 4px，所有元素 snap to 4px。Inter / JetBrains Mono 的 baseline 与 4px 网格对齐
- **可选的扫描线（scanline）细节**：在 hero 卡片背景，**1px / 4px 间隔的水平线，明度差仅 2%**——只在某些区域出现（如 PK 模拟图表底层、PIN 输入界面），告诉用户"这里在做计算"
- **几何边界 vs 纸感边界**：用 `1px solid {ink.tertiary @ 8%}` 替代花笺的"无线条"——不是没有线，是把线**压到几乎看不见**。但需要时（比如分隔加密内容与公开内容），它会冷峻地出现

---

## 6. 形状与节奏

| Token | 值 | 备注 |
|-------|-----|------|
| `radius.sharp` | 4px | 输入框 / 小按钮 / pill |
| `radius.card` | 6px | 卡片标准——**远小于花笺的 16px** |
| `radius.modal` | 8px | bottom sheet / dialog |
| `radius.full` | 9999px | 仅头像、状态点 |
| `space.0` | 4px | mono 字符级 |
| `space.1` | 8px | 元素间 |
| `space.2` | 12px | 紧凑组件内 |
| `space.3` | 16px | 卡片 padding |
| `space.4` | 24px | section 间 |
| `space.5` | 32px | 屏幕级 |
| 网格 | 4px | 所有间距是 4 的倍数 |

**形状哲学**：
- **纯几何**——直角、圆角、圆。**禁止有机曲线 / 不规则花瓣形 / 手绘感**
- **圆角 6px 是精确的克制**，不是软的可爱。它像 Linear 的卡片、像 macOS Sonoma 的窗口——"我们知道直角太硬了，但我们也不想假装柔软"
- **允许的"加密图案"**：mono 字符的背景 dot grid（间隔 8px、明度差 4%）、PIN 输入态的 ASCII 装饰、空状态的 ASCII art

---

## 7. 私密性作为视觉语言（Privacy-as-Aesthetic）

**这是方向 B 的灵魂章节，也是它唯一不能与 A、C 共享的差异化资产。** 竞品分析里"Privacy-as-Aesthetic"机会缺口（第 3 节第 3 条）正是这里要兑现的。当下市场上：TRACE / Hormone Helper 默认云同步且把"隐私"埋在 5 层菜单深处；estrannaise 私密但拒绝设计；HanaNote v1 花笺给了温柔但没给"被看见的安全感"。**方向 B 要做的是：让用户在打开 app 的第一秒，眼睛就告诉大脑——这里是我的密室。**

### 7.1 三重视觉层级
按"敏感度递进"分配视觉重量：

**Level 1 · 日常状态（ambient privacy）**
- 顶栏永久驻留一颗 **6px 的 phosphor green dot**，旁边 mono 文字 `LOCAL` —— 不闪烁、不动、不解释。**它就是在那。**
- 这取代了花笺的"温柔守护者"叙事——后者要用大量文案告诉你"你的数据安全"，B 直接把"安全"做成永驻的视觉物体
- 灵感来自 Signal 顶部的安全数字、Linear 同步状态点、Arc 的小 indicator

**Level 2 · 解锁瞬间（authentication ritual）**
- PIN 输入界面是 B 的标志性场景：
  - 全屏 `bg.canvas` 暗色，中心 6 个 mono 字符位 `_ _ _ _ _ _`（**不是圆点，是下划线**——"等待输入"的终端语义）
  - 输入字符立即变 `*`，**字符位之间用 mono spacing**——不像 iOS 的 PIN 圆点等距居中漂浮，而是像在终端里打字
  - 解锁成功的反馈：phosphor green 一道 1px 的线**从下方扫到上方**（200ms ease-out），**不是动画爆炸，是"信号通过"**
  - 数字键盘：4px 圆角方块，按下 `bg.surface.3`，无 elevation，无 ripple——像机械键盘
- ASCII 装饰可选：在键盘上方放一行 `// session unlocked at 14:23`

**Level 3 · 数据导出 / 删除（high-stakes ceremony）**
- 这些操作要在视觉上**拉满严肃感**——不是吓唬，是郑重
- "清除全部数据"按钮：`accent.terminal` red 边框 + 透明背景 + mono 字体 + 全大写 `WIPE ALL DATA`
- 确认对话框背景叠加扫描线，文案变 mono：
  ```
  > This will permanently delete:
  >   • 287 medication logs
  >   • 12 blood test reports
  >   • 47 encrypted photos
  >
  > Type WIPE to confirm.
  ```
  用户必须**输入** `WIPE` 而不是按按钮——这是 GitHub 删仓库的仪式，是让用户慢下来想一秒的视觉摩擦

### 7.2 离线发光（Offline Glow）
- 当 app 检测到无网络（实际上 HanaNote 99% 的功能都不需要网络），背景边缘出现一道**极弱**的紫色 inner glow（`accent.signal @ 4% opacity`，blur 80px）
- 不是 error 提示——是**自豪的视觉语言**。"无网络 = 你的数据现在 100% 本地"
- 文案锚点：`updateAlreadyLatest` "已是最新版本" → B 调性是 `// you're current. no fetch needed.`

### 7.3 加密图标语法
- "已加密"指示统一用 mono 字符 `[E2E]` 或 `[AES-256]` 而非锁图标
- 照片网格右下角永久叠 mono `enc` 三字符（10px、`accent.phosphor @ 60%`）——这是 B 比花笺优越的地方：花笺没法表达"加密性"，B 直接把它印在每张缩略图上
- 数据导出按钮带后缀 mono `.json.aes`（"你导出的也是加密文件"）

### 7.4 微文案：本地存储的 affordance
导出 / 备份界面顶部一行 mono label：
```
> data destination: ~/HanaNote/local
> cloud sync: disabled
> third-party access: none
```
这是技术品味的最高级——**用文件系统路径告诉用户"你的数据物理上在哪"**。它比"我们承诺保护你的隐私"有效一万倍。

> ARB 锚点对照（zh）：
> - `photoEmptyDescription` "你的照片经过端到端加密，只有你能看到。" → B 调性："// AES-256-GCM, on-device only."
> - `wipeAllDataMessage` "此操作会永久删除应用中的所有加密数据，且无法恢复。" → B 调性："// IRREVERSIBLE. type WIPE to confirm."

---

## 8. 文案调性（Tone of Voice）

| 场景 | v1 当前（花笺） | v2 科技隐私 |
|------|----------------|------------|
| 服药 CTA（`takeDose`） | "服药" | `LOG DOSE` (mono 全大写) |
| 时间线空态（`noTimelineEvents`） | "暂无时间线事件" | `// no events yet. add your first record.` |
| 删除确认（`confirmDeleteDrug`） | "确定删除这种药物吗？此操作不可撤销。" | "PERMANENT. removes all 23 logs of this drug. type DELETE to confirm." |

**调性原则**：
- 第一人称叙述（"my data" "my machine"）替代第二人称鼓励（"You did it!"）
- mono `>` 前缀代替 emoji
- 数字精确到位（"23 logs""287 days""4.2 KB"）—— **不模糊**
- 拒绝 `dailyQuote` 系列的诗意短句。B 的 hero copy 是 mono：`day 287. medication 5/5. all local.`

---

## 9. 参考产品（5 个深入分析）

### 1. Signal
- **学到的**：privacy 不是开关，是产品。Signal 的"safety number"显示是 monospace 80 位 hex；UI 把"加密性"做成可被验证的视觉物体
- **HanaNote 借鉴**：永驻的 `LOCAL` 状态点 + 加密签名作为可见元素
- **不学的**：Signal 的纯白蓝调过于"通讯软件感"，HanaNote 不需要"消息气泡"

### 2. Linear
- **学到的**：极小明度差的层叠（surface 0/1/2/3 各只差 6%）、磷光紫 `#5E6AD2` accent、IDE 风格的 mono label、键盘优先的快捷操作美学
- **HanaNote 借鉴**：色板（Signal Violet）、Type Ramp、暗色 surface 工程
- **不学的**：Linear 完全工程化、零情感曲线，HanaNote 仍是健康产品需要保留极少量"被在乎"的感受（用 Phosphor Green dot 来承载）

### 3. ProtonMail / Proton Drive
- **学到的**：把"瑞士本地"做成产品定位，用色板的暗紫做品牌资产
- **HanaNote 借鉴**：暗紫黑 `#0E0B14`、加密 metadata 的展示位置
- **不学的**：Proton 还是传统邮箱布局，B 不学其表层

### 4. Arc Browser
- **学到的**：暗色优先但仍有"温度"——靠极弱的色相（不是冷蓝而是暖紫）、靠极小的高光、靠"几乎不存在的边界"
- **HanaNote 借鉴**：`bg.canvas` 选 `#0E0B14` 暖紫黑而非工业冷黑
- **不学的**：Arc 的渐变彩色 sidebar 太"创意"，B 要更克制

### 5. Obsidian
- **学到的**：把"你的笔记是 markdown 文件，存在你的硬盘上"做成核心卖点；mono 字体 `[[wiki-link]]` 美学；社区围绕"本地优先"
- **HanaNote 借鉴**：导出文件路径展示（"~/HanaNote/local"）、`// comment` 风格 metadata
- **不学的**：Obsidian 默认主题过于程序员，HanaNote 不能完全弃疗温度

> **没选 1Password 的原因**：1Password 设计偏蓝色"商务"，与 HanaNote 用户气质不符。
> **没选 Cron / Raycast 的原因**：它们是工具型产品，HanaNote 是健康记录工具，需要的是更"长期陪伴"调性而非"完成即关"。

---

## 10. 应用到 Today 屏幕（描述性）

**默认入场即 dark mode**。打开 app 的第一秒：

- **顶栏**：`bg.canvas` `#0E0B14`，左上 mono 极小 logo `hn`（不是樱花），右上**永驻 phosphor green dot + mono `LOCAL`**——这一帧告诉用户"你回到了你的密室"
- **Hero 区**：mono display 字体一行 `day 287` —— **没有 "你好 hanna 早安"**，没有日期问候，没有 daily quote。**冷静的事实陈述本身就是温柔**。下方 `body.md` 灰字 `// estradiol therapy started 2025-07-15`
- **今日清单**：4 个 surface.0 卡片（圆角 6px），每张卡片：
  ```
  ┌─────────────────────────────────┐
  │ 08:00  estradiol valerate       │
  │ ────────────────────────         │
  │ 4.0 mg · IM · left thigh        │  ← mono
  │                                  │
  │              [LOG DOSE] →        │  ← signal violet button
  └─────────────────────────────────┘
  ```
  时间用 mono、剂量用 mono、按钮文字 mono 全大写。**不再是花笺的"该吃药啦 💊"**
- **服药状态**：完成的剂量左侧贴一颗 phosphor green dot 加 mono ✓ 标记 + 时间戳 `08:02`，**不消失，留在原地**——"我看到你做了，记录在案"
- **庆祝反馈（替代花瓣）**：用户点 `LOG DOSE` 后：
  - **不是粒子爆炸**
  - 按钮先变 `bg.surface.3` 暗一档（200ms），然后 phosphor green 文字从右侧 fade-in `[OK] logged at 08:02`
  - 整张卡片左侧 1px phosphor green 竖线点亮 400ms 然后变成 4% 持续状态
  - **像 git commit 成功**——冷静、确认、不打扰
- **"已加密"指示**：清单底部 mono `// 4 doses · all encrypted · synced to: nowhere` —— 最后一个词 nowhere 是 B 的灵魂双关：既是 "No-where"（无处）也是 "Now-here"（此处）

---

## 11. 应用到 Onboarding 屏幕

四步极简，无插画：

**Step 1 · Welcome**
- 全屏 `bg.canvas` 暗
- 中心 mono display 一行 `hn` logo
- 下方 `body.lg`：`HanaNote — your HRT log, on your device.`
- **没有插画、没有渐变 hero、没有"欢迎来到温柔的空间"**
- CTA: signal violet 按钮 `[BEGIN] →`（mono）

**Step 2 · Set name**
- 标题 mono：`> what should i call you?`
- 输入框 4px 圆角，下边线在 focus 时变 phosphor green
- 副标题 `body.md` 灰字：`// stays local. never sent.`
- ARB 锚点 `onboardingNameNote` "随时可以在设置中修改" → B 调性：`// editable in /settings later`

**Step 3 · HRT start date**
- mono 标题 `> hrt journey started on?`
- 一个 mono 风格 date picker（数字步进式，不是花笺的圆角日历卡）

**Step 4 · Set PIN**
- 这一步是 B 最戏剧化的一帧（参考 §7.2）
- 全屏暗，6 个 `_` 等待，mono 数字键盘
- 完成时 phosphor green 1px 线扫过屏幕：`[OK] vault secured.`

---

## 12. 与 v1 花笺的对比表

| 维度 | v1 花笺 | v2 科技隐私 (B) |
|------|---------|-----------------|
| 第一印象 | "她在我身边温柔陪伴" | "这是我的密室" |
| 主色 | 樱色 #864E5A + 薰衣草 | Signal Violet `#5E6AD2` + Phosphor Green `#3FB950` |
| 背景 | 奶油白 `#FFF8F1` (light) / 暖棕黑 `#1A1512` (dark) | Paper Mist `#ECEAE7` (light) / Encrypted Indigo `#0E0B14` (dark) |
| 字体 | Plus Jakarta Sans + Be Vietnam Pro，圆润 | Inter + **JetBrains Mono**，技术 |
| 圆角 | 16px / 24px 软 | 6px 精确 |
| 数字字体 | 同正文 | **强制等宽 mono** |
| 庆祝反馈 | 樱花花瓣粒子 1.2s | git-commit 风格 phosphor green 确认 200ms |
| 隐私表达 | 文案承诺（"端到端加密，只有你能看到"） | 视觉常驻 + 加密元素印在每张卡上 |
| 文案调性 | 第二人称鼓励（"你今天也做得很好"） | 第一人称事实（"day 287 · 5/5 · all local"） |
| 默认主题 | Light first | **Dark first** |
| Hero 模式 | 圆形大头照 + 问候 | mono 数字 + 元数据注释 |
| 边界处理 | 无线条（surface 明度差） | 几乎看不见的 1px 线（明度差 + tertiary @ 8%）|
| 阴影 | 弥散 24px blur 4-8% | **零阴影**，纯调和层次 |
| 装饰可能 | 樱花 / 月相 / 花瓣 | 扫描线 / dot grid / ASCII art |

---

## 13. 风险与权衡

### 风险 1：可能与 16-35 岁女性化用户群对"温柔陪伴"的期待背离
- **论点**：HanaNote 用户是 MTF 跨性别群体，许多人在身份过渡中渴望"被温柔对待"。dark / mono / "WIPE to confirm" 可能读作冷漠或工程化
- **缓解**：
  - **Phosphor green 是 B 的情感锚点**——它是温柔的，但温柔以"确认你做到了"的形式表达，不以"夸你做得真棒"
  - 保留极少量"被在乎"的微交互：成功 log dose 时 phosphor green 持续在卡片左侧 4% 亮线（"我看着你"）
  - **重新定义"温柔"**：花笺的温柔是"我帮你装饰你的痛苦"；B 的温柔是"我让你看到你被严密保护着"。后者对于"身份不安全感"群体可能反而更有效——**Signal 的用户不是男性极客，是在乎隐私的所有人**
  - 接受筛选：B 不适合所有 MTF 用户，但适合**对"被监控""被泄露""被识别"高度警觉的子集**——这恰恰是中国 / 东亚 MTF 用户的核心焦虑（家人翻手机、医保数据上传、社会身份暴露）

### 风险 2：dark-first 在阳光下的 Web/Android 户外使用会更难
- **论点**：HanaNote 主战场 Android + Web，东南亚 / 中国 MTF 用户大量在户外、地铁、强光环境使用
- **缓解**：
  - Light mode **不是降级**而是平行设计——Paper Mist 灰白比花笺奶油白对比度更高（`#ECEAE7` vs `ink.primary #0F0F11` ≈ WCAG AAA）
  - 系统级 prefers-color-scheme 自动切换 + 设置内可强制 light
  - 关键 CTA 在 light mode 用 Signal Violet 实色填充，对比度仍达标
  - 接受现实：B 用户中将有 30-40% 偏好 light，但**他们打开过一次 dark 之后回不去**——这是 B 的转化曲线

### 风险 3：技术感强的产品可能被读为"男性向"——这与目标用户产生张力
- **论点**：终端美学 / mono 字体 / `[WIPE]` 大写按钮是过去 30 年男性程序员审美的代表，可能让目标用户感到"这不是为我做的"
- **缓解**：
  - **重写"技术感"的性别属性**：Signal Violet `#5E6AD2` 与 Phosphor Green `#3FB950` 都不是经典"男性向"工程蓝（#1E40AF 那种）。这套色板更接近 Linear / Arc，已经是 2024-2026 年的"中性新工程美学"，被大量女性 / 跨性别设计师采纳
  - 取消所有刻板男性向元素：**没有黑红配色、没有锯齿状图标、没有 cyberpunk 紫红霓虹、没有"hacker"语言**（如 root / pwn / 0day）
  - HanaNote 的目标用户中**有相当一部分是技术行业的 MTF**（程序员 / UX / 开发者）——她们恰恰是"温柔粉色 HRT 工具"的反面观众。B 是为这部分用户提供选择
  - 与方向 A（编辑级东亚）形成互补：A 服务"想要被温柔对待的我"，B 服务"想要被严密保护的我"

---

## 14. 适合 / 不适合

### ✅ 适合
- **对隐私 / 信息安全高度警觉的用户**——担心家人翻手机、伴侣偷看、医保数据上传、求职背调（中国 / 东亚 MTF 的主流焦虑）
- **科技 / 互联网行业的 MTF 用户**——日常用 Linear / Notion / VS Code，对 mono 字体和暗色 IDE 美学有审美训练
- **理性派 / 数据驱动型用户**——关心 PK 模拟器、血药浓度、剂量精确性，看到 mono 数字会本能信任
- **重度夜间使用者**——HRT 用药提醒晚上 22:00 / 早上 8:00 是高频时段，dark-first 在卧室极佳
- **拒绝"医疗温情"叙事的用户**——过往被医院粉色 / 卡通图打过擦边球，反感

### ❌ 不适合
- **追求"治愈感""陪伴感"的低龄用户**（16-22 岁初次接触 HRT）——这群用户更需要 A 或 C 的情感支撑
- **不熟悉 mono 字体 / 终端美学的用户**——会觉得"这是给程序员做的"
- **二次元 / 萌系审美的用户**——B 的克制是这群用户的反义词
- **强光户外为主的使用场景**——light mode 虽达标但仍非 B 的主场
- **HRT 启蒙阶段需要鼓励的用户**——B 的事实型文案可能不够"推一把"

---

## 15. 决策推荐力度

**8 / 10**

**一句话理由**：在"Privacy-as-Aesthetic"这个竞品空白市场，B 是 HanaNote 唯一能形成结构性差异化的方向——A 是更精致的存量竞争（vs 花笺迭代），C 是更温暖的存量竞争（vs TRACE / Clue），只有 B 把"数据本地"从合规话术变成可被 SEEN 的设计语言。扣 2 分留给"用户群可能偏窄"的真实风险——B 不会取悦所有 MTF 用户，但它会**深刻**取悦其中关心隐私的那一部分，并让 HanaNote 在中文 HRT 工具的视觉空白市场中竖起一面**无人复刻**的旗。

---

> **最终一句**：花笺让你想起樱花树下被守护的午后；B 让你确认门已锁、灯已熄、数据已加密、世界已被关在外面。**前者是诗，后者是契约**。在这个时代，跨性别用户更需要的不是诗——是契约。
