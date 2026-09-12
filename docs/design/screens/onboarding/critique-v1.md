# Onboarding 屏 v1 现状 Design Critique

> **审视范围**: `lib/features/auth/presentation/pages/onboarding_page.dart`（641 行单文件，无关联 cubit / widget — onboarding 全部在该文件内 inline）
> **对照基准**: DESIGN.md（v2 编辑级东亚） + tokens.md + principles.md（5 原则 + 严禁清单）
> **权重提示**: Onboarding 是用户触达 HanaNote 的"第一秒"，文案 / 色彩 / 节奏违规 **权重 ×2**
> **生成时间**: 2026-04-29

---

## 概述

v1 onboarding 是一个三步 PageView wizard：① 欢迎 + 称呼输入 → ② HRT 起始日 → ③ 第一种药物。

整体观感属于**典型 Material 3 + Plus Jakarta Sans 信纸风**：粉调 primaryContainer 渐变背景 + 圆形 96px 图标徽章 + 24px 软糖圆角卡 + 居中对称布局 + Material 标准 datePicker。这套语法是 v1 花笺时代的产物，与 v2 五原则的 **每一条** 都正面冲突。更严重的是，本屏作为新用户首触，一个 16-35 岁 MTF 用户在前 5 秒看到的是「Material 3 demo」而不是「一本属于我的私人内刊」。

整屏共扫出 **17 处 v2 严禁项 + 6 处跨性别敏感性盲点 + 4 处节奏 / 表单可用性问题**，需要在 Pilot Wave 中整体重写。

---

## 第一印象 5 秒原则

新用户在前 5 秒会决定要不要继续。审视：

- **第一屏的 hero 视觉（现状 vs v2 期望）**: 现状（`onboarding_page.dart:264-276`）是一颗 96×96 圆形容器套 `Icons.local_florist`（一朵花，48px），居中对称漂浮在粉调渐变背景上。v2 期望是 **display-xl 宋体黑墨标题左对齐 32px + 右侧 96px+ 留白**（principles.md 原则 3 / DESIGN.md §4 不对称呼吸感），一屏一个视觉重心。**Icons.local_florist 本身就是 v1 花笺残留** — DESIGN.md §7 严禁清单第一条："粉色 / 樱色 / 樱花 / 二次元装饰" 全部出局，`local_florist` 是花就是树枝就是装饰，必须删除。
- **文案是否让人想"被听到"或"被推销"**: `onboardingWelcome = "欢迎来到 HanaNote"` + `onboardingWelcomeSub = "你的私密 HRT 健康记录空间"`（app_zh.arb:510-511）属于"产品介绍 + 功能描述"，是推销语。v2 调性要求第三人称编辑视角 + 句号收尾（DESIGN.md §6）。建议改为 **「翻开第一页。」** 或 **「今日，你来了。」** — 黄历体三五字。
- **是否有性别预设**: 中文使用「你」（非「您」）方向正确（亲近不疏远），但欢迎页**没有任何称呼方式说明**——也就是说既没说"你"也没说"她"，这反而留出了安全空间。**风险点在副文案 `onboardingNameHint = "可以是昵称或别名"`（app_zh.arb:513）**——「别名」是一个 MTF 用户敏感词（暗示"真名 vs 别名"二分），应改为 **「这是给自己看的名字」** 这种去身份化措辞。`Icons.local_florist` 花朵图标对 v2 目标人群（22-35 岁成熟用户）是隐形的"少女风"信号，离场。
- **进度感是否清晰**: 三个圆点指示器（`onboarding_page.dart:138-156`）做了 active=24×8 / inactive=8×8 的 stadium 长条动画——这是 v1 风格。**没有"第 X 步 / 共 3 步"的文字进度**，没有跳过整个 onboarding 的总开关。Step 2/3 提供了"稍后设置"/"稍后添加"逐步跳过，但 Step 1（输入名字）**没有跳过选项**——首屏即强制输入是"被推销"的最强信号。

---

## v2 五原则违规点（带 file:line）

### 原则 1: 一抹强色（黛蓝 ≤ 3 处 / 屏）

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 1 | 整屏背景是 `LinearGradient(primaryContainer → background)` 渐变 | `onboarding_page.dart:88-98` | 删除渐变，改为 `HanaTokens.background(context)` 月白纯色 |
| 2 | 大标题文字色是 `HanaColors.primaryOf(context)`（黛蓝） | L284, L391, L514（三屏的标题全部上色） | v2 标题用墨色 `HanaTokens.ink`，黛蓝是稀缺资源，标题不上色 |
| 3 | Hero 圆形容器中的 Icon 用 primary 色 | L274, L382, L504 | 删除 hero 图标本身（违反原则 5），无需讨论上色 |
| 4 | Step 2 的 `Icons.touch_app` 提示图标半透明 primary | L423 | 删除"轻触此处"图标 — 卡片本身的可点击性应该靠 affordance 表达（cursor / press scale），不靠图标喊话 |
| 5 | Step 2 的"HRT 第 N 天" pill 用 primaryContainer 底 + primary 字 | L446-457 | 这是 v2 唯一允许的"黛蓝点睛"位置，但 pill 形（999px）违反 r-pill 仅限头像规则；改为 `HanaTokens.accentMuted` 底 + `mono` 字体（数值用 JetBrains Mono Light） + r-card 4px |

**累计违规**: 单屏黛蓝出现位置 **≥ 5 处**（背景渐变 + 标题 + 图标 + 卡边框 + pill），原则 1 硬上限是 3 处。**黛蓝在本屏已贬值为普通装饰色，等于没有强色**。

### 原则 2: 调和层次胜过投影

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 6 | 渐变背景（`LinearGradient`）就是 v2 严禁的"Gen-Z 渐变" | L88-98 | 实色 `background` |
| 7 | 三个内容卡都用了 `Border.all(color: primaryContainer.withAlpha(77))`——1px 实线边框 | L302-306, L413-417, L524-527 | v2 仅 form focus 允许 1px outline，其它场景用 surface 阶差替代（`surfaceContainerLowest #FBF8F2` on `background #F4F1EA`，6 个明度单位差） |

### 原则 3: 编辑级不对称（居中是默认懒惰）

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 8 | 整屏所有内容居中（PageView 内 `Column`，hero 圆形居中、标题 `TextAlign.center`、卡片居中、按钮居中） | L286, L393, L516 全部 `TextAlign.center` | 标题左对齐 32px，右侧 96px+ 留白；视觉重心偏左 30%（principles.md 原则 3） |
| 9 | 没有章节段落标记（标题左侧 4px 黛蓝竖线） | 所有 step | Step 编号 + 段落标记，例如「**01 / 称呼**」左侧 4px 黛蓝竖线，仅覆盖标题首行 |
| 10 | 进度指示居中 stadium 长条 | L139 `MainAxisAlignment.center` | v2 杂志感应使用 **「01 / 03」mono 数字** 左下角对齐，或干脆删除（杂志翻页不需要"页码当前在哪"） |

### 原则 4: 慢节奏与留白

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 11 | 首屏 hero 顶部仅 `SafeArea + 40px`（L274），未达 v2 onboarding xxl=128px 要求 | L274, L380, L513 | 屏幕首屏到第一个内容块 ≥ 128px（tokens.md §3 xxl） |
| 12 | hero 圆 → 标题 32px → 副标题 8px → 卡片 48px：**8 紧挨 32**，违反"相邻间距必须跨级，不允许 16 紧挨 16"（推论：8 紧挨 32 也算跨级 OK，但 32 紧挨 48 并不跨级—— md=16 / lg=32 / xl=64，48 不在 token 内） | L277, L288, L297 | 全部用 token spacing；副标题与标题间用 sm=8，副标题与卡片用 lg=32 或 xl=64 |
| 13 | 三步 PageView 用 `NeverScrollableScrollPhysics`（L105）只能按按钮前进，且 `_goToPage` 动画 350ms `Curves.easeInOut` | L42-46 | v2 motion-standard = 240ms（tokens.md §6）；按钮前进语义本身没问题，但 350ms 偏慢且不在 token 内 |

### 原则 5: 内容即装饰

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 14 | 三屏全部使用 `Icons.local_florist` / `Icons.calendar_month` / `Icons.medication` 装饰图标作 hero | L272, L380, L502 | **全部删除**。v2 装饰存在于排版细节（宋体撇捺、tracking、行高），不存在于额外图标元素。文字本身就是装饰 |
| 15 | 字体硬编码 `fontFamily: 'Plus Jakarta Sans'` + `fontWeight: w800` | L283, L390, L513 | v2 Display 必须用 Spectral SemiBold（西文）/ Source Han Serif SC Medium（中文）/ Noto Serif JP Medium（日文），并显式声明 fontFamilyFallback。**w800 极重字重在 v2 完全不存在**——宋体的视觉重量来自衬线撇捺，不靠字重撑 |
| 16 | 圆角 24px 卡片 + 16px 按钮 + 12px 输入框 | L302, L181, L326 | v2 r-card=4 / r-button=6 / r-input=2（DESIGN.md §4 / tokens.md §4）。**严禁清单第 3 条：圆角 ≥ 8px（除 Bottom Sheet）** |
| 17 | 输入框使用 `OutlineInputBorder + BorderSide.none + filled fillColor` | L325-328, L336-339, L558-561 | v2 输入框是「无外框 + 底部 1px outline / focus 时 2px primary 呼吸线」（DESIGN.md §5 + principles.md 原则 3 第 5 条）；filled fillColor 是 Material 信纸感 |

---

## 三步 PageView 节奏分析

| Step | 文案 | 输入字段数 | 跳过 | 节奏问题 |
|------|-----|-----------|------|---------|
| 1 / 欢迎 + 称呼 | "欢迎来到 HanaNote / 你的私密 HRT 健康记录空间 / 你想被怎么称呼？" | 1（name） | **无** | 第一屏强制输入。新用户还没建立信任就被要求"交出名字"——应允许"暂不命名"（系统用「你」） |
| 2 / HRT 起始日 | "你的 HRT 起始日是？" | 1（date picker） | "稍后设置" | **预设用户已经在 HRT 中**——见下节"跨性别身份敏感性"。日期选择器是 Material 标准 `showDatePicker`（L398-407），违反 v2 "禁标准 iOS / Material 弹窗" → 应改用 Bottom Sheet 内嵌 picker |
| 3 / 第一种药物 | "添加你的第一种药物" + 名称 + 类别 + 给药途径 | 3（text + 2 dropdown） | "稍后添加" | **三个字段同屏出现违反"一屏一个视觉重心"**（principles.md 原则 3）。Drug Category dropdown 用 `cat.displayName`（L571）— 违反 DEC-042/043 i18n 强制（domain 层禁止 displayName 直出，必须经 `localizedName(l10n)`）|

**结构判断**: 三步 wizard 节奏 OK，但 **Step 1 应分裂为「2 屏」**——一屏 hero 欢迎（无输入），一屏称呼输入。当前 Step 1 把"建立印象"和"索取数据"挤在一屏，违反"一屏一个视觉重心"。

**Pilot Wave 建议节奏**（5 屏，参考 principles.md 原则 1 的"Onboarding 第 5 屏「翻开」按钮"伏笔）：
1. **首屏 hero**：display-xl「翻开第一页。」+ 黛蓝竖线段落标记 +「下一页」次按钮
2. **称呼**：「想被怎么称呼？」+ 输入 +「这是给自己看的名字。」+「跳过」
3. **HRT 状态**：先选「我已经在 HRT」/「我还没开始」/「不想说」三态，再决定是否进入日期选择
4. **第一种药物（可选）**
5. **「翻开」**：唯一允许的大块黛蓝主屏 + 庆祝静默 0.4s + 「内刊已开。」

---

## 表单可用性

- **Name 输入（L319-330）**: 没有 maxLength、没有 trim 提示、hint「可以是昵称或别名」字号 12px alpha 70%（L334-339）—— v2 label tracking 必须 +0.6（tokens.md §2.3），当前未声明 tracking
- **HRT 日期选择（L396-463）**: 整张大卡作为 GestureDetector tap 区域，但视觉是"卡片不是按钮"，缺少 affordance；`Icons.touch_app` 在 v2 不允许出现（图标承担情感重量违反原则 5）。**`firstDate: DateTime(2000)`（L401）** 对 22-35 岁用户来说预设了"最早 2000 年开始 HRT"——上限合理但下限在 v2 应放宽至 1990（部分早期开始 HRT 的用户）
- **Drug 输入（L531-612）**: 三字段堆叠在同卡内（name + category + route），与 Step 1 的"单字段一卡"节奏不一致；DropdownButtonFormField 在 v2 应改为 Bottom Sheet 选项（避免 Material 标准弹层）
- **「下一步 / 完成」按钮**（L171-247）: 全部 height=52 + radius=16 + primary 实色填充 — 高度 52 OK（≥ 44 a11y），但圆角 16 超 v2 r-button=6 上限三倍；按钮文案「下一步 / 开始使用 / 稍后添加」均为陈述短语，调性可接受但缺少句号收尾（v2 调性偏好「下一页。」「完成。」）

---

## 跨性别身份敏感性审视

> v2 设计要尤其关注 **16-35 岁 MTF 跨性别用户**（PRODUCT-VISION.md §1）。任何"预设身份 / 默认正常 / 暗示进度"的措辞都是 block reason。

| # | 现状 | 问题 | v2 修复建议 |
|---|-----|------|-----------|
| 1 | **没有头像 / 性别选择 UI** | OK，这一点是 v1 唯一做对的地方——不索取性别 | 维持。Pilot Wave 中也不要加性别字段 |
| 2 | `onboardingNameHint = "可以是昵称或别名"`（app_zh.arb:513） | **「别名」一词暗示存在「真名 vs 别名」二元结构**，对未出柜或法律名 ≠ 自我认同名的 MTF 用户是触发点 | 改为「这是给自己看的名字」/「写下你想被叫的样子。」 |
| 3 | `onboardingNameNote = "随时可以在设置中修改"`（app_zh.arb:514） | 措辞冷静、可接受 | 可微调为「随时可改。」（句号收尾） |
| 4 | `onboardingSetHrtDate = "你的 HRT 起始日是？"`（app_zh.arb:515） | **预设用户已在 HRT**——对正在考虑 HRT、还未开始的用户排他 | 增加前置三选：「我已经在 HRT 中」/「我还没开始」/「不想说」。仅第一选项进入日期选择；后两者跳过本步 |
| 5 | datePicker `firstDate: DateTime(2000), lastDate: DateTime.now()`（L401-402） | `lastDate: now` 暗示「HRT 起始日 ≤ 今天」——OK，但缺少「未来计划开始」选项 | 加未来 90 天 buffer，并允许"预计开始日" |
| 6 | DrugCategory 默认 `estrogen`（L36）+ AdministrationRoute 默认 `oral`（L37） | **预设 estrogen 暗示用户是 MTF 而非 FTM**。虽然 PRODUCT-VISION 明确目标是 MTF，但 onboarding 默认值仍应"无预设"，由用户主动选择 | dropdown 改为 placeholder「选择类别」；不预填 |
| 7 | 法律免责文案 (legal.* keys) **未在 onboarding 出现** | 用户首次设置药物时**没有任何医疗免责提示**，与 PRODUCT-VISION「不是远程医疗」立场冲突 | Step 4 / Step 5 加冷静句「HanaNote 是记录工具，不替代医生。」（句号收尾，黑墨宋体，不上色）|
| 8 | 没有"我可以稍后再来"的安全感文案 | 全程"下一步 / 完成"催赶 | 加一句「这本子永远在这里。」（每屏底部 inkSecondary body-sm） |

**核心立场**: v1 onboarding 在身份敏感性上是「**未犯错但也未做对**」——它没有显式 misgendering，但每一个默认值（estrogen / 已在 HRT / "别名"）都暗中预设了一种"标准 MTF 路径"。v2 应做到 **零预设 + 每一步给出退出口 + 文案永远第三人称陈述**。

---

## 与 v1.1.0 commit message 缺口的关联

PRODUCT-VISION.md §引导流程 明确：「v1.1.0 承诺但未交付，R52 候选」，完成度标记 **0%**。

- **当前 onboarding_page.dart 状态**: **完整可用但语言陈旧**——三步流程都能跑通（保存 displayName / hrtStartDate / 第一种 drug 到 SettingsBloc + MedicationRepository），不是"未交付"，而是"已交付但 PRODUCT-VISION 表里没勾"。这是文档与代码不同步问题，而非功能缺失。
- **worktree 草稿（exciting-borg）**: 检查后该 worktree 中 `onboarding_page.dart`（641 行）与主分支版本**几乎逐行一致**，唯一差异是主分支已迁移到 `*Of(context)` 暗色支持 API（如 `HanaColors.primaryContainerOf(context)`），worktree 仍是静态 `HanaColors.primaryContainer`——也就是说 worktree 是 v1 dark mode 改造**之前**的快照，没有任何"草稿增强"内容可借鉴。它是历史副本，不是未完成的新版本。
- **重设计建议**:
  1. **PRODUCT-VISION.md 表更正**: 把「引导流程 0%」改为「85%（功能可用，v2 视觉重写中）」——避免后续 Release Notes 再次踩坑
  2. **Pilot Wave 第二屏**（onboarding）应当作为 v2 视觉语言的**首块试金石**而非"补缺口"——重写 5 屏结构（见上节节奏建议），把 v2 的「翻开」隐喻 + 黛蓝稀缺感 + 杂志衬线节奏一次性立住
  3. **保留逻辑层**: `_completeOnboarding`（L49-81）的 SettingsBloc 事件序列（UpdateDisplayName + UpdateHrtStartDate + 创建 Drug + MarkOnboardingComplete）逻辑正确，重写时**只换 UI 不动 BLoC**

---

## 应替换为的 v2 组件（Pilot Wave 待建）

| 当前 inline 实现 | v2 组件 | 备注 |
|----------------|---------|-----|
| L319 `TextField + OutlineInputBorder` | **HanaInput**（widget-pattern-inventory 模式 6） | 无外框 + 底部 1px outline + 月白底；圆角 2 |
| L176, L195, L225 `FilledButton 52×∞ radius 16` | **HanaButton.primary**（模式 11） | 黛蓝实色 + 6px 圆角 + onPrimary 雪宣色 |
| L207, L237 `TextButton`（跳过 / 稍后） | **HanaButton.text**（模式 11 v2） | 单纯墨色文字 + 句号收尾文案 |
| L264-276, L371-383, L494-506 圆形 hero icon | **删除**，由 display-xl 宋体标题 + 4px 黛蓝段落标记替代（principles.md 原则 5） |
| L298-342 / L408-463 / L519-615 大圆角卡 | **HanaCard.flat**（模式 4）+ 段落式排版 | r-card=4，无边框，靠 surface 阶差 |
| L138-156 dot indicators | **mono 字号 14 「01 / 03」** 左下对齐 | 杂志页码语法 |
| L398 `showDatePicker` | **HanaBottomSheet** 内嵌日期 picker | 严禁清单第 8 条：禁 Material 标准弹窗 |
| L553, L588 `DropdownButtonFormField` | **HanaBottomSheet** ChoiceChip 选项 | 同上；同时修复 DEC-042/043（drug.displayName 改 localizedName(l10n)） |
| 首屏 `Icons.local_florist` | **删除** | 严禁清单第 1 条：粉色 / 樱色 / 樱花 / 二次元装饰 |
| `LinearGradient(primaryContainer → background)` | **HanaTokens.background(context) 实色** | 严禁清单 / 原则 2：禁 Gen-Z 渐变 |

---

## 总评

**v2 五原则违规计数**: 17（每条原则均有违规，非个别失误）
**严禁清单触发**: 5 条（粉色装饰 / Gen-Z 渐变 / 圆角 ≥ 8px / Material 标准弹窗 / 第二人称鼓励隐式）
**跨性别敏感性盲点**: 6 处（最重要：「别名」措辞 + HRT 起始日预设 + estrogen 默认值）
**节奏问题**: 3 屏挤压、首屏强制输入、缺总跳过、缺安全感托底
**重设计权重**: ★★★★★（首触屏，Pilot Wave 必须重写，不可增量修补）

**一句话设计总监评语**:
*v1 onboarding 是「Material 3 demo + 花笺残影」——它欢迎你来用一个 app，v2 onboarding 应当邀请你来翻开一本属于自己的内刊。前者向你介绍功能，后者向你致敬一次身份。Pilot Wave 必须从背景渐变到 hero 图标到字体到圆角到默认值到文案全部重写，不存在「保留 80% 改 20%」的中间路线。*

— 完 —
