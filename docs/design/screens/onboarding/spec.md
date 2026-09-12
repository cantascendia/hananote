# Onboarding 屏 v2 视觉与流程规范

> Generated 2026-04-29
> 5 屏重构（v1 是 3 屏 PageView）
> 屏幕：`lib/features/auth/presentation/pages/onboarding_page.dart`
> Pilot Wave: 阶段 3.1.b（新稿）+ 3.1.c（自我 critique-v2 待跑）
> 上游基准：`docs/design/design-system/v2/{tokens.md,principles.md,components/*.md}` + `docs/design/screens/onboarding/critique-v1.md` + `docs/design/ux-copy-v2/copy-revisions.md`

---

## 1. 设计意图

Onboarding 是 16-35 岁 MTF 用户**第一次打开 HanaNote 的前 90 秒**——critique-v1 已经判定 v1 三屏方案（welcome+name 同屏 → HRT 起始日 → 第一种药物）在 v2 五原则上**每条都违规**，并且暗藏 6 处跨性别敏感性盲点（"别名"二分、HRT 起始日预设、estrogen 默认值、缺医疗免责、缺"我还没开始"分支、name 输入未提示可化名）。

v2 把节奏从 3 屏扩到 5 屏，是因为 v1 的"信息密度优先"和 v2 的"一屏一个视觉重心"在哲学上不兼容——硬要在 3 屏里塞下 hero / 称呼 / HRT 状态 / 药物 / 庆祝必然回到信纸感。**5 屏不是把内容稀释，是给"翻开一本内刊"这件事配置足够的留白**：屏 1 翻页前的扉页静默、屏 2 一字成章索取称呼、屏 3 三选项让"我还没开始"成为合法路径、屏 4 条件显示药物、屏 5 庆祝 + 法律免责形成"翻开"闭环。

更重要的，5 屏方案让 critique-v1 的 6 处跨性别敏感性盲点**第一次有了具体落点**——这不是"美学整改"，是产品立场的修正：v1 的每个默认值都暗中预设了一种"标准 MTF 路径"，v2 必须做到**零预设 + 每步退出口 + 第三人称陈述**。

---

## 2. 5 屏导览

### 屏 1：起手 hero「HanaNote。」

**视觉**: 月白 `background` 实色铺满，无渐变。屏幕上方 `xxl` (128) 起，**display-xl 黑墨宋体「HanaNote。」左对齐 32px**（左侧 4px 黛蓝竖线段落标记，长度仅覆盖标题首行）。下方 `lg` (32) 留白后一行 `body-sm` 淡墨副文「私人健康内刊。仅你可见。」。屏幕底部 SafeArea 上方 `xl` (64) 处一个 `HanaButton.primary fullWidth=false` "翻开。"，左对齐到 32px，**不**全宽——杂志按钮即印章。

**ASCII wireframe**:
```
┌──────────────────────────────────────┐
│                                      │  ← SafeArea
│                                      │  spacing.xxl (128)
│                                      │
│ │ HanaNote。                         │  ← display-xl 墨色宋体 + 4px 黛蓝竖线
│                                      │  spacing.lg (32)
│   私人健康内刊。仅你可见。           │  ← body-sm 淡墨
│                                      │
│                                      │  flex 占满
│                                      │
│ ╭──────╮                             │
│ │ 翻开 │                             │  ← HanaButton.primary (132×44, r-button=6)
│ ╰──────╯                             │     左对齐 32px，不全宽
│                                      │  spacing.xl (64) + SafeArea 底部
└──────────────────────────────────────┘
```

**用户场景**: 用户首次启动 app，进入 OnboardingPage 第一帧。前 1.2s display-xl 淡入（`motion-fade` linear），底部按钮 240ms 后跟着淡入。**0 装饰、0 emoji、0 图标**——`Icons.local_florist` 整文件下线。

**跨性别敏感性**: 无任何性别 / 身份 / 进度预设。"HanaNote。" + "私人健康内刊。" 把产品介绍从"功能描述"降级为"扉页落款"——用户在第一秒不被销售。

**关键 token**: `display-xl` (40/52/-0.5 SemiBold) · `HanaTokens.ink` · `HanaTokens.primary` (仅竖线) · `body-sm` · `r-button=6` · `motion-fade=1200ms`

**关键文案 key**:
- `onboardingWelcome` → "HanaNote。" / "HanaNote." / "HanaNote。"
- `onboardingWelcomeSub` → "私人健康内刊。仅你可见。" / "A private health journal. Only you." / "私的な健康内誌。あなただけに。"
- `onboardingNext` → "翻页" / "Turn page" / "次の頁"（屏 1 按钮例外用 `onboardingDone` "翻开" 起手）

---

### 屏 2：称呼

**视觉**: 顶部 `xl` (64) 留白后 **display 32px 黑墨宋体**「想被怎么称呼。」左对齐 32px + 左侧 4px 黛蓝竖线（一处黛蓝）。下方 `lg` (32) 一个 `HanaInput.singleLine`，label="称呼"（tracking +0.6），placeholder="叫我……"。input 下方 `xs` (4) 间距挂 helperText "这是给自己看的，可化名。"（`body-sm` 淡墨）。底部按钮区两个并列 ghost / primary：「跳过」`HanaButton.ghost` + 「翻页」`HanaButton.primary`。

**ASCII wireframe**:
```
┌──────────────────────────────────────┐
│  01 / 05                             │  ← mono 14 左下页码（淡墨）右上角
│                                      │  spacing.xl (64)
│ │ 想被怎么称呼。                     │  ← display 32 + 黛蓝竖线
│                                      │  spacing.lg (32)
│   称呼                               │  ← label tracking +0.6
│   ─────────────                      │  ← HanaInput 底线 1px
│   叫我……                            │
│   这是给自己看的，可化名。           │  ← helperText body-sm 淡墨
│                                      │
│                                      │  flex
│                                      │
│   [跳过]            [翻页]           │  ← ghost + primary，左右各 32px
└──────────────────────────────────────┘
```

**用户场景**: 第一次主动索取数据。「跳过」直接进入屏 3，displayName 留空（SettingsBloc 不发 UpdateDisplayName）。

**跨性别敏感性**: 解决 critique-v1 盲点 #1 + #6。v1 hint "可以是昵称或别名" 移除——「别名」对未出柜 / 法律名 ≠ 自我认同名的用户是触发词；helperText "这是给自己看的，可化名。" 把"叫什么"从身份问题降级为"私人内刊扉页签名"。**`onboardingNameHint` ARB 不再使用**（HanaInput 不依赖 placeholder 当 label，placeholder 仅 "叫我……"），同时 `onboardingNameNote` 改 helperText 调用。

**关键 token**: `display` (32/42/-0.3) · `HanaInput` (idle outline 1px / focus 2px primary) · `HanaButton.ghost` + `HanaButton.primary`

**关键文案 key**（出自 copy-revisions §1）:
- `onboardingSetName` → "想被怎么称呼。" / "What should we call you." / "呼び名を。"
- `onboardingNameHint` → 移除使用（input placeholder 改为不依赖 ARB 的 "叫我……" 局部字面量；ja/en 同样三语 `localFallback`）。**或保留 key 改值为 "叫我……" / "Call me…" / "呼んで……"**（推荐后者保 schema 稳定）
- `onboardingNameNote` → "这是给自己看的，可化名。" / "Just for yourself. A nickname is fine." / "自分のための名前です。" *(critique-v1 §跨敏 #2 改写，与 copy-revisions §1 调性一致；如 copy-revisions 已重写为 "设置内随时可改。" 则把跨敏修复挪到新 helperText，新增 ARB key `onboardingNameSafety`)*
- `onboardingNext` → "翻页"
- `onboardingSkipName` *（新增）* → "跳过" / "Skip" / "後で"

---

### 屏 3：HRT 状态三选

**视觉**: 顶部 `xl` (64) 留白 + display "进展。" + 4px 黛蓝竖线（一处黛蓝）。下方 `lg` (32) 三张 `HanaCard.tappable` 纵向堆叠，**卡之间 `spacing.lg` (32)**。每张卡 padding `md` (16)，内含 `title` 18 黑墨宋体 + 下方 `body-sm` 淡墨副描述。**当前选中卡**：左侧 4px 黛蓝竖线 + title 加粗为 SemiBold（不变色——黛蓝仅竖线，第二处稀缺资源）。底部「翻页」`HanaButton.primary`，禁用直到至少选中一项。

三选项：
- **「已经在 HRT。」** 副："会进入用药记录。"
- **「还没开始。」** 副："只是先走一遍内刊。"
- **「不想说。」** 副："会跳过相关问题。"

**ASCII wireframe**:
```
┌──────────────────────────────────────┐
│  02 / 05                             │
│                                      │  spacing.xl (64)
│ │ 进展。                             │  ← display 32
│                                      │  spacing.lg (32)
│ ┌──────────────────────────────────┐ │
│ │ 已经在 HRT。                     │ │  ← HanaCard.tappable
│ │ 会进入用药记录。                 │ │
│ └──────────────────────────────────┘ │
│                                      │  spacing.lg (32)
│ ┌──────────────────────────────────┐ │
│ │ │ 还没开始。              ✓     │ │  ← 选中态：黛蓝竖线
│ │   只是先走一遍内刊。             │ │
│ └──────────────────────────────────┘ │
│                                      │  spacing.lg (32)
│ ┌──────────────────────────────────┐ │
│ │ 不想说。                         │ │
│ │ 会跳过相关问题。                 │ │
│ └──────────────────────────────────┘ │
│                                      │  flex
│   [上一页]          [翻页]           │
└──────────────────────────────────────┘
```

**用户场景**: 这是 5 屏中**最关键的一屏**——它把 v1 的 "你的 HRT 起始日是？" 单线索取拆成三态分支。状态 enum（建议 `lib/features/auth/domain/entities/onboarding_hrt_status.dart`，新增）：

```dart
enum OnboardingHrtStatus { onHrt, notStarted, prefersNotToSay }
```

- `onHrt` → 进入屏 4（药物 + 起始日）
- `notStarted` / `prefersNotToSay` → 跳过屏 4，直接到屏 5；不调用 `UpdateHrtStartDate`

**跨性别敏感性**: 一次性解决 critique-v1 盲点 #2 + #5。v1 标题 `onboardingSetHrtDate = "你的 HRT 起始日是？"` 已被 copy-revisions 改写为 "从哪一天起，你不再是从前的自己。"——但这条文案只能在用户**已经选了 onHrt** 之后才出现（屏 4），不能作为屏 3 的入口问题。屏 3 的 "进展。" 是中性词，三个选项**没有任何一个被设计为默认 / 推荐**——这是真正零预设。

**关键 token**: `display` (32) · `HanaCard.tappable` (r-card=4) · 选中态左侧 4px primary 竖线 · `motion-quick=150ms` press scale 0.98

**关键文案 key**（新增三 key + 复用一 key）:
- `onboardingHrtStatusTitle` *（新增）* → "进展。" / "Progress." / "進み。"
- `onboardingHrtStatusOnHrt` *（新增）* → "已经在 HRT。" / "I'm on HRT." / "HRT 中。"
- `onboardingHrtStatusNotStarted` *（新增）* → "还没开始。" / "Not yet." / "まだ。"
- `onboardingHrtStatusPrefersNotToSay` *（新增）* → "不想说。" / "Rather not say." / "言いたくない。"
- 三组副描述同新增（`onboardingHrtStatus*Description`）

---

### 屏 4：药物（条件屏 — 仅 `onHrt` 路径显示）

**视觉**: 顶部 `xl` (64) 留白 + headline 24「记一种药。」+ 黛蓝竖线（一处）。下方 `lg` (32) 一个 `HanaCard.flat` 大卡，内部段落用 `spacing.md` (16) 分隔：

1. `HanaInput.singleLine` label="药名" placeholder="例如：补佳乐"
2. `spacing.md` 后一组 `HanaInput`-style "类别" 选择器：**点击打开 `HanaBottomSheet.picker`** 列出 `DrugCategory.values` 的 `localizedName(l10n)`（DEC-042/043 强制）；**默认值无选中**（"未选择" placeholder + helperText "可在记完后修改。"）
3. `spacing.md` 后同样模式的"给药途径"选择器（`AdministrationRoute.values`），默认无选中
4. `spacing.lg` 后一行小标题「起始日」+ `HanaCard.tappable`（display HRT 起始日 mono 14 数值 + 副"——"或已选 yyyy-mm-dd）；点击打开 `HanaBottomSheet.picker` 内嵌日期 picker（**禁 `showDatePicker`**），`firstDate=DateTime(1990)`（critique-v1 §可用性 #2 修），`lastDate=DateTime.now().add(Duration(days: 90))`（允许"预计开始"）

底部 ghost「上一页」+ ghost「跳过这步」+ primary「翻页」。**所有字段都允许留空**——_completeOnboarding 已经是 `if (drugName.isNotEmpty)` 防御逻辑（onboarding_page.dart:62），保持。

**ASCII wireframe**:
```
┌──────────────────────────────────────┐
│  03 / 05                             │
│                                      │
│ │ 记一种药。                         │  ← headline 24
│                                      │  spacing.lg (32)
│ ┌──────────────────────────────────┐ │
│ │ 药名                             │ │
│ │ ─────────────────                │ │
│ │ 例如：补佳乐                     │ │
│ │                                  │ │  spacing.md
│ │ 类别                             │ │
│ │ ─────────────────                │ │
│ │ 选择…                       ▾   │ │  ← 未选无默认
│ │                                  │ │  spacing.md
│ │ 给药途径                         │ │
│ │ ─────────────────                │ │
│ │ 选择…                       ▾   │ │
│ │                                  │ │  spacing.lg
│ │ 起始日                           │ │
│ │ ──                               │ │  ← mono 14 数值
│ │ (点击选择日期)                   │ │
│ └──────────────────────────────────┘ │
│                                      │  flex
│   [上一页] [跳过这步]      [翻页]    │
└──────────────────────────────────────┘
```

**用户场景**: 解决 critique-v1 盲点 #3。v1 在源码 line 30-31 硬编码 `DrugCategory.estrogen` + `AdministrationRoute.oral` 默认值——**v2 将默认值改为 nullable + null**（见 handoff §状态契约），让用户主动选择。Drug Category dropdown 也修复 DEC-042/043（v1 line 571 `cat.displayName` 直出 → 改 `cat.localizedName(l10n)`）。

**跨性别敏感性**: 三处修复——① 默认无选；② 三字段在同卡内但用 `spacing.md/lg` 跨级分隔（不再是 v1 的"挤压"）；③ 文案 "记一种药。" 比 "添加你的第一种药物" 弱化"必须"语义。

**关键 token**: `headline` (24/32/-0.2) · `HanaCard.flat` · `HanaInput` · `HanaBottomSheet.picker` · `mono` (JetBrains Mono Light) 用于日期数值

**关键文案 key**:
- `onboardingAddDrug` → "记一种药。"（copy-revisions §1 已改 "加入第一条用药。" — 屏 4 标题用 "记一种药。" 更克制，建议 key 拆分：`onboardingAddDrug` 留给设置页，新增 `onboardingDrugTitle` 给本屏）
- `onboardingDrugSkip` *（新增 / 替换 `onboardingDrugOptional`）* → "跳过这步" / "Skip this step" / "このステップを後で"
- `onboardingHrtStartDateTitle` → 复用 copy-revisions 改写版 "从哪一天起，你不再是从前的自己。" 作为 picker bottom-sheet 的 title

---

### 屏 5：庆祝 + 法律提示

**视觉**: 屏 4（或屏 3，若 `notStarted/prefersNotToSay`）翻页后**屏幕静默 0.4s**（黑屏 = 月白 background 全屏 + 0 内容）。然后：

1. `motion-deliberate` 1200ms easeOut 淡入屏幕上方 1/3 处 **display-md 28 黛蓝宋体「翻开。」** 左对齐 32px + 4px 黛蓝竖线（这是全 onboarding 唯一允许的"大块黛蓝时刻"，原则 1 例外）
2. 停留 600ms
3. 下方 `lg` (32) 处淡入 **`body` 15 墨色** 法律免责块（`HanaCard.flat` 容器）：「HanaNote 是私人记录工具，不替代医生的诊断。任何剂量调整请先咨询医师。」
4. 法律块下方 `xl` (64) 处一个 `HanaButton.primary fullWidth=false` "进入今日。"

总仪式时长约 2.6s（静默 400 + 淡入 1200 + 停留 600 + 法律淡入 400），**无声、无粒子、无震动**（震动可选）。

**ASCII wireframe**:
```
┌──────────────────────────────────────┐
│                                      │  ← 0.4s 静默
│                                      │
│ │ 翻开。                             │  ← display-md 黛蓝宋体（淡入 1.2s）
│                                      │  spacing.lg (32)
│ ┌──────────────────────────────────┐ │
│ │ HanaNote 是私人记录工具，不替代  │ │  ← body 15 墨色（晚 0.4s 淡入）
│ │ 医生的诊断。任何剂量调整请先     │ │
│ │ 咨询医师。                       │ │
│ └──────────────────────────────────┘ │
│                                      │  spacing.xl (64)
│ ╭──────────────╮                     │
│ │  进入今日。  │                     │  ← HanaButton.primary
│ ╰──────────────╯                     │
│                                      │
└──────────────────────────────────────┘
```

**用户场景**: 解决 critique-v1 盲点 #4（缺医疗免责）。点击「进入今日。」触发 `_completeOnboarding`（保持 v1 line 49-81 SettingsBloc 事件序列），`context.go('/today')`。

**跨性别敏感性**: 法律免责文案**第三人称陈述**——"HanaNote 是…不替代…"，没有 "请记得" / "我们提醒您" 等催赶或客套。这是 PRODUCT-VISION "不是远程医疗" 立场的具体落地。

**关键 token**: `display-md` (28) · `body` (15) · `HanaTokens.primary` (大块黛蓝唯一例外) · `motion-deliberate=1200ms` · `motion-fade=1200ms`

**关键文案 key**（出自 copy-revisions §1 "onboardingDone" + 新增 legal block）:
- `onboardingDone` → "翻开。" / "Open." / "開く。"（copy-revisions 已确认）
- `onboardingMedicalDisclaimer` *（新增 ARB key）* → "HanaNote 是私人记录工具，不替代医生的诊断。任何剂量调整请先咨询医师。" / "HanaNote is a private journal, not medical advice. Consult a clinician before changing your regimen." / "HanaNote は私的な記録です。診断の代わりにはなりません。方案調整は医師にご相談ください。"
- `onboardingEnterToday` *（新增）* → "进入今日。" / "Enter today." / "今日へ。"

---

## 3. 流程图（state machine）

```
                    Onboarding
┌──────┐    翻开    ┌──────┐    翻页    ┌──────┐
│ 屏 1 │ ─────────> │ 屏 2 │ ─────────> │ 屏 3 │
│ hero │            │ 称呼 │            │ 状态 │
└──────┘            └──────┘            └──┬───┘
                                           │
                       ┌───────────────────┼─────────────────┐
                       │ onHrt              │ notStarted      │ prefersNotToSay
                       ↓                    ↓                 ↓
                   ┌──────┐                 │                 │
                   │ 屏 4 │                 │                 │
                   │ 药物 │                 │                 │
                   └──┬───┘                 │                 │
                      └─────────┬───────────┴─────────────────┘
                                ↓
                            ┌──────┐    进入今日。
                            │ 屏 5 │ ─────────────> /today
                            │ 翻开 │
                            └──────┘
```

**状态契约**（`_OnboardingPageState` 字段重设计 — 见 handoff.md §3）:

```dart
String? _name;                           // 屏 2，留空跳过
OnboardingHrtStatus? _hrtStatus;         // 屏 3，必选才能离开
String? _drugName;                       // 屏 4 仅 onHrt 路径
DrugCategory? _drugCategory;             // null = 用户未选
AdministrationRoute? _drugRoute;         // null = 用户未选
DateTime? _hrtStartDate;                 // 屏 4 仅 onHrt 路径
```

---

## 4. 跨性别敏感性修复 vs critique-v1 6 盲点

| critique-v1 盲点 | v1 现状 | v2 处理 | 落点 |
|-----------------|--------|--------|------|
| #1 「别名」暗示二分 | `onboardingNameHint = "可以是昵称或别名"`（app_zh.arb:513） | 屏 2 helperText 改"这是给自己看的，可化名。"，placeholder 改 "叫我……" 中性词 | 屏 2 |
| #2 "你的 HRT 起始日" 预设已开始 | `onboardingSetHrtDate`（app_zh.arb:515） | 屏 3 三选作前置门，仅 `onHrt` 路径才进屏 4 触达 HRT 起始日 | 屏 3 + 屏 4 |
| #3 默认 estrogen + oral | onboarding_page.dart:30-31 | 屏 4 默认 null + bottom-sheet picker 强制用户主动选 | 屏 4 |
| #4 缺医疗免责 | 全程无 legal 文案 | 屏 5 `onboardingMedicalDisclaimer` body 块 + 第三人称陈述 | 屏 5 |
| #5 缺"我还没开始" | v1 仅"稍后设置" | 屏 3 三选项之一 `notStarted`，与 `onHrt` 同等地位（不是"跳过"语义） | 屏 3 |
| #6 name 输入未提示可化名 | 仅冷淡 hint | 屏 2 helperText "这是给自己看的，可化名。" 明确"私人内刊扉页签名"语义 | 屏 2 |

补充修复（critique-v1 §跨敏 #5 / #7 / #8）:
- 日期 `firstDate` 1990（不是 2000）+ `lastDate` 加 90 天 buffer（允许"预计开始"）
- 屏 5 法律免责落地
- 屏 1 副文 "私人健康内刊。仅你可见。" 隐含"这本子永远在这里"安全感（critique-v1 #8）

---

## 5. 视觉骨架（每屏 ASCII wireframe）

见各屏 §2 子节。

---

## 6. 组件映射

| 屏 / 元素 | v1 inline 实现 | v2 组件 | tokens |
|----------|---------------|--------|--------|
| 屏 1 / 背景 | `LinearGradient` (line 88-98) | `HanaTokens.background(context)` 实色 | `background` |
| 屏 1 / hero icon | `Icons.local_florist` 96×96 圆容器 | **删除**（无替代——内容即装饰） | — |
| 屏 1 / 标题 | `fontSize:28 + Plus Jakarta Sans + w800 + primary` | `display-xl` 墨色宋体 + 4px 黛蓝竖线 | `display-xl` · `ink` · `primary`(竖线) |
| 屏 1 / CTA | `FilledButton 52×∞ radius 16` | `HanaButton.primary` (44×fit, r-button=6) | `primary` · `r-button=6` |
| 屏 2 / 输入 | `TextField + OutlineInputBorder + filled` (line 319-330) | `HanaInput.singleLine` | `outline`(idle 1px) · `primary`(focus 2px) · `r-input=2` |
| 屏 2 / 卡容器 | `Container + r-24 + Border.all` (line 298-342) | **删除卡壳**——HanaInput 自带 anatomy | — |
| 屏 3 / 三选项卡 | (v1 无此屏) | 3× `HanaCard.tappable`，选中态左侧 4px primary 竖线 | `surfaceContainerLowest` · `primary`(竖线) · `motion-quick` |
| 屏 4 / 药物大卡 | `Container + r-24 + Border` (line 519-615) | `HanaCard.flat` | `surfaceContainerLowest` · `r-card=4` |
| 屏 4 / 类别选择 | `DropdownButtonFormField` (line 553) | `HanaInput`-style 触发 `HanaBottomSheet.picker` | `r-input=2` · `motion-standard` |
| 屏 4 / 路径选择 | `DropdownButtonFormField` (line 588) | 同上 | 同上 |
| 屏 4 / 日期 picker | `showDatePicker` (line 398) | `HanaBottomSheet.picker` 内嵌 | 严禁清单 #8 |
| 屏 5 / 庆祝 | (v1 无此屏) | 直接 inline `display-md` + body 法律块（**不**复用 `HanaCelebration.trigger`——后者是 OverlayEntry，本屏需占据整页 PageView 第 5 页） | `display-md` · `primary` · `motion-deliberate` |
| 屏 5 / 法律块 | (v1 无此屏) | `HanaCard.flat` 内 `body` 文本 | `body` · `ink` |
| 全屏 / 进度指示 | dot indicators (line 138-156) | mono 14「03 / 05」左下角 / 右上角对齐 | `mono` · `inkSecondary` |
| 全屏 / 按钮区 | `FilledButton + TextButton` 52 实色 | `HanaButton.primary` + `HanaButton.ghost` 并排 | `r-button=6` |

---

## 7. Tokens 引用清单

**Colors** (per surface):
- `background` 月白 #F4F1EA — 全 5 屏背景
- `surfaceContainerLowest` 雪宣 #FBF8F2 — 屏 3 三选项卡 / 屏 4 大卡 / 屏 5 法律块
- `ink` 墨色 #1C1A18 — 所有标题与正文
- `inkSecondary` 淡墨 #5E5A52 — 副描述 / helperText / 页码 mono
- `primary` 黛蓝 #1F3A5F — **每屏 ≤ 3 处**:
  - 屏 1: 标题竖线 + button 实色 = 2 处
  - 屏 2: 标题竖线 + button 实色 + input focus 线 = 3 处（focus 是瞬时态，不计稳态）
  - 屏 3: 标题竖线 + 选中卡左竖线 + button = 3 处
  - 屏 4: 标题竖线 + button = 2 处
  - 屏 5: display-md 文字 + 标题竖线 + button = 3 处（屏 5 例外允许 display 上色）
- `outline` 烟灰 #A39E92 — HanaInput idle 底线 1px

**Typography**:
- `display-xl` 40/52/-0.5 — 屏 1 hero
- `display` 32/42/-0.3 — 屏 2 / 屏 3 / 屏 4 标题
- `display-md` 28 — 屏 5 「翻开。」
- `headline` 24/32/-0.2 — 屏 4 子标题（如启用）
- `title` 18/26/0 — 屏 3 三选项主行
- `body` 15/24/0 — 屏 5 法律
- `body-sm` 13/20/0 — 屏 1 副文 + 屏 2 helperText + 屏 3 副描述
- `label` 12/16/+0.6 — HanaInput label
- `mono` 14/20/0 — 屏 4 日期数值 + 全屏页码

**Spacing**:
- `xxl` (128) — 屏 1 顶部
- `xl` (64) — 屏 2/3/4 顶部 / 屏 5 法律到按钮
- `lg` (32) — 标题到内容 / 选项卡之间
- `md` (16) — 卡内 padding / 段落内
- `sm` (8) — 紧密元素
- `xs` (4) — label 到 input

**Radius**: `r-card=4` · `r-input=2` · `r-button=6`

**Motion**:
- `motion-instant` (80ms) — input focus 1→2px
- `motion-quick` (150ms) — HanaCard.tappable press scale
- `motion-standard` (240ms) — 屏间 PageView 切换
- `motion-deliberate` (1200ms) — 屏 5 「翻开。」淡入
- `motion-fade` (1200ms) — 屏 1 hero 淡入

---

## 8. 交互状态

- **屏切换**: PageView `physics: NeverScrollableScrollPhysics()`（v1 已用，保留），按钮触发 `_pageController.animateToPage(duration: 240ms, curve: easeInOut)`（v1 是 350ms easeInOut，**改 240ms 对齐 motion-standard**）
- **HanaInput focus**: 80ms 1→2px primary 呼吸线
- **HanaCard.tappable press**: 150ms scale 0.98（press down → release）
- **屏 3 选中**: 选中卡左侧 0→4px primary 竖线 240ms 拉伸；同时 title 字重 Regular→SemiBold 瞬时
- **屏 5 庆祝**:
  - 0–400ms: 静默，整屏只有 background 月白
  - 400–1600ms: display-md 「翻开。」+ 4px 竖线 + opacity 0→1（easeOut deliberate）
  - 1600–2200ms: 停留
  - 2200ms: 法律块 + button 同步 fade-in 400ms
- **「上一页」按钮**: 仅屏 2/3/4 显示，屏 1 + 屏 5 不允许回退（屏 5 已写入数据，回退无意义）
- **物理返回键**: 屏 1 退出 app；屏 2/3/4 等价「上一页」；屏 5 拦截无操作

---

## 9. 断点行为

| 断点 | 行为 |
|------|------|
| **mobile** (< 600dp) | 单屏全宽，水平 padding 32px（左对齐基线） |
| **tablet** (600-1024dp) | 内容居中宽度 480px，左右大留白（背景仍月白 background 实色，**不**画分栏装饰） |
| **web ≥ 1024dp** | 内容居中宽度 720px（Notion 文档限宽，与 today 屏一致），左右各 ≥ 152px 留白 |

**杂志感保留**：tablet/web 居中是"内文页居中"，不是"标题居中"——内容块内部仍左对齐 32px。

---

## 10. i18n 注意

- 5 屏文案全部用 `copy-revisions.md` §1 重写版（`onboardingWelcome` / `onboardingSetName` / `onboardingNameHint` / `onboardingNameNote` / `onboardingSetHrtDate` / `onboardingNext` / `onboardingDone`）
- **新增 ARB keys**（约 8 个）:
  - `onboardingHrtStatusTitle` / `onboardingHrtStatusOnHrt` / `onboardingHrtStatusNotStarted` / `onboardingHrtStatusPrefersNotToSay`
  - `onboardingHrtStatusOnHrtDescription` / `onboardingHrtStatusNotStartedDescription` / `onboardingHrtStatusPrefersNotToSayDescription`
  - `onboardingDrugTitle` / `onboardingDrugSkip` / `onboardingMedicalDisclaimer` / `onboardingEnterToday` / `onboardingNameSafety` / `onboardingPagination` (mono "{current} / {total}")
- 三语对齐：屏 3 三选项中文 "已经在 HRT。/ 还没开始。/ 不想说。"、英文 "I'm on HRT. / Not yet. / Rather not say."、日文 "HRT 中。/ まだ。/ 言いたくない。"——三语都中性，**无任何语态暗示"应该"开始**
- ja 字号风险：屏 1 hero "HanaNote。" 在三语都是同长，但屏 5 "翻开。" / "Open." / "開く。" — display-md 28 在 ja "開く。" 单字符级 OK；如长文 fallback 缩为 display 24
- DEC-042/043 修复：屏 4 类别 / 路径选择必须用 `cat.localizedName(l10n)` / `route.localizedName(l10n)`，**不**用 v1 line 571/606 的 `displayName` 直出

---

## 11. a11y 检查

- **触控目标**: 每屏至少 ≥ 44dp 的「下一步」按钮 + 屏 2/3/4 多 1 个「上一页」/「跳过」按钮
- **焦点顺序**: 屏 1 标题 → 翻开按钮；屏 2 标题 → input → helperText → 跳过 → 翻页；屏 3 标题 → 卡 1 → 卡 2 → 卡 3 → 上一页 → 翻页；屏 4 标题 → 药名 → 类别 → 路径 → 起始日 → 上一页 → 跳过 → 翻页；屏 5 「翻开。」(liveRegion) → 法律 → 进入今日
- **PageView 焦点 trap**: 物理返回键 + tab 在每屏内循环；切屏后焦点回到当前屏第一个交互元素
- **`prefers-reduced-motion`**: 屏切换 240ms → 0ms（瞬时切）；屏 5 庆祝 1200ms 淡入 → 0ms 直显；press scale 0.98 → 仍保留（150ms 微动可接受）
- **Screen reader**: 屏 5 `Semantics(liveRegion: true, label: l10n.onboardingDone + l10n.onboardingMedicalDisclaimer)` 读完整句
- **对比度**: ink #1C1A18 on background #F4F1EA = 14.8:1 (AAA) — 全屏 base text 通过

---

## 12. 自我 critique-v2

| 原则 | 自审结果 | 落点 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处） | ✅ 屏 1=2 / 屏 2=2(focus 不计) / 屏 3=3 / 屏 4=2 / 屏 5=3 (例外屏，原则 1 明示允许大块黛蓝) | §7 |
| 2. 调和层次胜过投影 | ✅ 全屏 elev-0；surfaceContainerLowest 卡 on background 6 个明度差；零 BackdropFilter；零 LinearGradient | §6 |
| 3. 编辑级不对称 | ✅ 全屏标题左对齐 32px + 4px 黛蓝竖线段落标记；按钮非全宽；右侧 ≥ 96px 留白 | §2 各屏 |
| 4. 慢节奏与留白 | ✅ 屏 1 顶部 xxl=128；屏间 spacing.lg=32；庆祝静默 0.4s；间距全部跨级（无 16 紧挨 16） | §7 |
| 5. 内容即装饰 | ✅ 零 emoji；零图标 hero；零渐变；零粒子；按钮文案句号收尾；第三人称陈述 | §10 |

**残留风险**:
- 屏 4 在同一 `HanaCard.flat` 内放 4 个字段（药名 + 类别 + 路径 + 起始日）违反 "一屏一个视觉重心"——但 5 屏方案已经在节奏上让 onHrt 路径变长，再拆成 2 屏会让 5 屏变 6 屏，留白过度。决策：保留单卡 4 字段，但靠 spacing.lg 跨级分隔强制留白节奏。
- 屏 3 三选项卡视觉等重，"还没开始。" 默认无 visual prominence——如果用户路径分析显示 70%+ 选 onHrt 而 notStarted 隐形，需要在 v3 把 notStarted 提到第一位（按钮顺序而非选中默认）

---

## 13. 节奏与停顿

候选 A §10 与 candidate-A §10 已规定 0.4s 静默原则。本屏落点：

- **屏 1 进入**: hero `motion-fade` 1200ms linear 淡入 display-xl，**前 200ms 屏幕完全空白**（避免 v1 即刻显示的工具感）
- **屏 5 进入**: 屏 4「翻页」按下后，先 `motion-standard` 240ms PageView 滑到屏 5，**屏 5 静默 0.4s**（kHanaCelebrationSilence = 400ms 借用），再 `motion-deliberate` 1200ms 淡入「翻开。」
- **屏间过场**: 240ms easeInOut（不是 v1 的 350ms easeInOut）—— 240ms 是 motion-standard token，350ms 不在 token 内
- **按钮 press**: 150ms scale 0.98（motion-quick），松手反弹 80ms（motion-instant）
- **屏 5 离开**: 点击「进入今日。」后**不**再播庆祝，因为屏 5 本身就是庆祝；直接 `context.go('/today')` 由 today 屏自己处理首次进入的视觉

总 onboarding 时长（用户主动按节奏走）约 30-90s，其中屏 5 仪式占 2.6s——这是从 v1 "三步快速过场" 到 v2 "翻开一本内刊" 的核心节奏切换。

---

— 完 —
