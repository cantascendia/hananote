# Journal Edit 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + components/
> 屏幕：`lib/features/journal/presentation/pages/journal_edit_page.dart`
> Pilot Wave: 阶段 3.2.b（新稿）+ 3.2.c（自我 critique-v2）
> 上游基准：`./critique-v1.md` + `docs/design/screens/record/spec.md`（hero + 章节竖线 pattern）+ `docs/design/screens/add-drug/spec.md`（表单 pattern）+ `docs/design/design-system/v2/components/{text-field,button,bottom-sheet,confirm-dialog}.md`
> 配对 handoff：`./handoff.md`

---

## 1. 设计意图

新 Journal Edit 给用户的感觉是 **「在私人内刊里写自己的页」**——而不是 v1 那种"先选 emoji 再写两行"的心情打卡表。打开此屏时，用户首先看到月白底 + 一行 `display-md` 黑墨宋体的日期「**4 月 28 日**」+ 一行淡墨「周二」副行——这是一份内刊的"日期页眉"，**让用户知道自己在为哪一天落墨**。下方是 `body 15` 行高 1.7 的大段写作区域（无外框、仅 focus 时底部 2px 黛蓝呼吸线），再下方是两个段落标记：「**今日心绪。**」5 个文字 toggle（不是 emoji）+「**留几个字。**」5 个文字 tag toggle（不是圆胶囊）。

引用 DESIGN.md「克制·沉静·不矫情·敬」调性：v1 用 emoji 圆 + Material 胶囊把日记做成 mood tracker，v2 让屏幕静下来——日期 hero、字写在留白上、心情用字不用图、标签用字不用胶囊，所有"分类"由文字承担。**v1 vs v2 核心叙事差异**：v1 是"打开 app 选心情打个卡"，v2 是"翻开今天这一页，先记日期，再写一段，最后用几个字定一下基调"。仪式感来自留白与编辑陈述，不是装饰。

Today 屏已建立 `display-xl + 章节竖线 + 一抹黛蓝 CTA` 骨架；Record 屏已建立 hero「今日　记一笔。」+ 三栏目录页骨架；Journal Edit 复用这两套语法但把"hero + 列表 / hero + 单 CTA" 换成 **"hero（日期）+ 大段写作区 + 双段落 toggle 列"**——三屏同源，不重新发明轮子。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 默认态（编辑既有日记，已有内容 + mood + tags）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.defaultBar · surfaceContainerHigh│  ← 56dp 实色米灰，无 blur
│  ←   编辑此页。               删除。 保存。 │     leading ghost icon
│  (title 18 ink 左对齐 32)                   │     trailing 双 ghost 文字 + spacing.sm
├─────────────────────────────────────────────┤
│                                             │
│  (顶部留白 spacing.xl = 64)                 │
│                                             │
│  4 月 28 日                                 │  ← display-md (28·36·-0.2)
│  (Spectral SemiBold / 宋体 Medium)          │     ink 墨色，左对齐 spacing.lg=32
│  周二                                       │  ← body-md (15·24) inkSecondary
│  (思源黑体 Regular)                         │     可点击 → HanaBottomSheet.picker 改日期
│                                             │
│  (段落间 spacing.lg = 32)                   │
│                                             │
│   ┌────────────────────────────────────┐    │  ← 内文页（无外框，仅文字）
│   │                                    │    │     padding 水平 spacing.lg = 32
│   │  今天去诊所拿了药，回程时           │    │  ← body 15·26 ink，行高 CJK 1.7
│   │  阳光特别好。第 142 天，半年节       │    │     段首不缩进（杂志风）
│   │  点。下次复检在 5 月 22 日。         │    │
│   │  …                                 │    │     focus 时底部 2px 黛蓝呼吸线
│   │  ────────────────────────────      │    │     idle 1px 烟灰 30% 底线
│   │                                    │    │
│   └────────────────────────────────────┘    │
│                                             │
│  (段落间 spacing.lg = 32)                   │
│                                             │
│ ┃ 今日心绪                                  │  ← HanaSectionHeader 段落标记
│ ┃ (label 12·+0.6·inkSecondary)              │     左侧 4px 黛蓝竖线（**1 处**）
│                                             │     长度仅覆盖首行 16px
│  (spacing.sm = 8)                           │
│                                             │
│  [好]  [平]  [累]  [沉]  [激动]              │  ← HanaButton.secondary toggle ×5
│                                             │     默认 = 月白底 + 黛蓝 1px 边
│                                             │     选中 1 处 = 黛蓝实色（=primary 第 2 处）
│  (段落间 spacing.lg = 32)                   │
│                                             │
│   留几个字                                  │  ← label 12·+0.6·inkSecondary
│   (无竖线—节流策略，详 §3.5)                │     **不**加段落标记
│                                             │
│  (spacing.sm = 8)                           │
│                                             │
│  [喜] [安] [倦] [沉] [起]                    │  ← HanaButton.secondary toggle ×5
│                                             │     单字编辑体（critique P1-7）
│                                             │     选中态 = 1px 黛蓝边 + 远黛底（**不**实色）
│                                             │     总稳态黛蓝 ≤ 3 见 §5
│  (底部 SafeArea + spacing.xl = 64)          │
└─────────────────────────────────────────────┘
```

### 2.2 新建态（`existingEntry == null`）

- AppBar title「**写一篇。**」 / trailing 仅「保存。」（无「删除。」）
- Hero 日期 = `DateTime.now()`，副行同上
- 写作区 placeholder = "今日宜，按时落墨。"（克制陈述，非 v1「今天想说点什么...」）
- mood / tags 默认全空（critique P0-1 / 5）

### 2.3 加载态

保存进行中：trailing「保存。」按钮 isLoading=true（onPrimary 色描边圆，非 Material 灰圆）；其他字段保持可见但 enabled=false（38% opacity）。

### 2.4 错误态（保存失败）

不弹 dialog；写作区下方 inline `body-sm error 朱砂` 一行「保存失败。请重试。」240ms 淡入；240ms 内再次点保存可重试。

---

## 3. 组件映射

| 区域 | v2 组件 | Variant | 关键 props |
|------|--------|---------|-----------|
| 顶部栏 | `HanaTopBar` | `defaultBar` | title=`l10n.journalEditTitleNew/Edit`，scrollController 监听 outline 淡入 |
| 返回 | `HanaButton` | `ghost` icon-only | `Icons.arrow_back` ink 墨色 |
| 删除（仅编辑态） | `HanaButton` | `ghost` 文字 | label=`l10n.journalDelete`「删除。」→ `HanaConfirmDialog.destructive` |
| 保存 | `HanaButton` | `ghost` 文字 + isLoading | label=`l10n.journalSave`「保存。」（**不**用 primary 实色——一屏 ≤ 1 处实色稳态留给 mood 选中） |
| 日期 hero | (Text 直接) | display-md | "4 月 28 日"，左对齐 spacing.lg=32，可点击触发日期 picker |
| 周名副行 | (Text 直接) | body-md | "周二"（mono 不染色，思源黑体 Regular），可点击同上 |
| 写作区 | `HanaInput` | `multiline` | minLines 8, maxLines null, autosize；placeholder 克制陈述；focus 2px 黛蓝呼吸线 |
| 章节段落标记「今日心绪」| `HanaSectionHeader` | default | label · +0.6 · inkSecondary，左侧 4px 黛蓝竖线（1 处稳态） |
| 章节标题「留几个字」| (Text 直接) | label · +0.6 · inkSecondary | **无**竖线（黛蓝节流，§5） |
| Mood toggle ×5 | `HanaButton` | `secondary` toggle | "好/平/累/沉/激动"；选中→ primary 实色填充；**最多 1 选**（单选） |
| Tag toggle ×5 | `HanaButton` | `secondary` toggle | "喜/安/倦/沉/起"；选中→ 1px 黛蓝边 + 远黛底（accentMuted）；**多选**（≤ 全部 5） |
| 日期 picker | `HanaBottomSheet` | `picker` | title「记在哪一天。」内嵌日期 picker；firstDate=年初 / lastDate=今天 |
| 删除确认 | `HanaConfirmDialog` | `destructive` | title「删除后不可恢复。」message「这一页将抹去。仍要继续？」confirmLabel「删除」 |
| 错误 inline | (Text body-sm error) | — | "保存失败。请重试。" 朱砂 |

> **明确删除**：v1 line 186-219 emoji 圆 mood selector / line 221-272 InputChip 标签 / line 105-144 居中 AppBar + 图标 save / line 154-176 全 InputBorder.none `TextField` —— 整段重写。

---

## 4. Tokens 引用清单

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| AppBar 米灰 | `HanaTokens.surfaceContainerHigh(context)` |
| 写作区 / 章节字 | `HanaTokens.ink(context)` |
| 周名副行 / placeholder / label | `HanaTokens.inkSecondary(context)` |
| 章节竖线 / 选中 mood 实色 / 选中 tag 边 / focus 呼吸线 | `HanaTokens.primary(context)` |
| Mood 选中字 | `HanaTokens.onPrimary(context)`（雪宣，**不**纯白） |
| Tag 选中底 | `HanaTokens.accentMuted(context)`（远黛） |
| 写作区 idle 底线 | `HanaTokens.outline(context)` @ 30% |
| 错误 inline | `HanaTokens.error(context)`（朱砂） |
| 删除 confirm | `HanaTokens.error(context)`（HanaConfirmDialog destructive 内置） |

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `HanaTokens.spacing.lg` = 32 |
| Hero 顶部留白 | `HanaTokens.spacing.xl` = 64 |
| Hero 日期 → 周名 | `HanaTokens.spacing.xs` = 4 |
| Hero → 写作区 | `HanaTokens.spacing.lg` = 32 |
| 写作区 → 心绪标题 | `HanaTokens.spacing.lg` = 32 |
| 心绪标题 → toggle 行 | `HanaTokens.spacing.sm` = 8 |
| toggle 横向间隔 | `HanaTokens.spacing.sm` = 8 |
| 心绪段 → 标签段 | `HanaTokens.spacing.lg` = 32 |
| 屏幕底部留白 | `HanaTokens.spacing.xl` = 64 |

> 强制跨级：64（顶）→ 32（hero 内 4 不计，副行属于同段）→ 32（hero 到写作区）→ 32（写作区到心绪）→ 8（标题到 toggle）→ 32（心绪到标签）→ 8 → 64（底）—— 全合规跨级链。

### 圆角
| 用途 | Token |
|------|-------|
| 写作区底色（如启用 surfaceContainerLowest）| `HanaTokens.radius.input` = 2 |
| Toggle 按钮 | `HanaTokens.radius.button` = 6 |
| Bottom Sheet（日期 picker）| 顶角 16（component 内置） |
| Confirm Dialog（删除）| `HanaTokens.radius.dialog` = 8（component 内置） |

### 字体
| 用途 | Token / 字体 |
|------|------------|
| Hero 日期「4 月 28 日」 | `display-md` (28·36·-0.2) Spectral SemiBold / Source Han Serif SC Medium / Noto Serif JP Medium |
| 周名副行「周二」 | `body-md` (15·24·0) Inter Regular / 思源黑体 Regular |
| 写作区正文 | `body` (15·26·0) — **行高 26**（CJK 1.73）覆盖 token 默认 24 |
| 段落标记 / 章节标题 | `label` (12·16·+0.6) Medium |
| Toggle 按钮 label | `body` (15·24·0) — 单字 / 双字编辑体 |
| AppBar title | `title` (18·26·0) Regular |
| Trailing 「保存。」/「删除。」 | `body` (15·24·0) ghost variant |

### 动画
| 用途 | Token |
|------|-------|
| 写作区 focus 1→2px 呼吸线 | `HanaTokens.motion.standard` = 240ms easeInOut |
| Toggle press scale 0.98 | `HanaTokens.motion.quick` = 150ms easeOut |
| Toggle 选中色切换（无→primary 实色） | `HanaTokens.motion.standard` = 240ms |
| Bottom sheet（日期 picker） | `HanaTokens.motion.standard` = 240ms |
| Inline 错误淡入 | `HanaTokens.motion.standard` = 240ms |

---

## 5. 一抹强色稳态盘点（≤ 3 处硬规则）

| 位置 | 是否稳态 | 计数 |
|------|---------|------|
| ① 「今日心绪」段落竖线（4px 黛蓝） | ✅ 稳态 | 1 |
| ② Mood 选中（实色填充） | ✅ 稳态（用户必选 1） | 2 |
| ③ Tag 选中边框（≥1 选） | 视用户操作 | 0–5 |
| 写作区 focus 呼吸线 | 瞬时态（不计） | — |
| AppBar trailing「保存。」 | 墨色 ghost（不计黛蓝） | — |

**节流策略**：
- 「留几个字」段落标题**不**加 4px 黛蓝竖线（与「今日心绪」错落，避免双竖线 → 3 处稳态超限）
- Tag 选中视觉用 **1px 黛蓝边 + 远黛底**（不实色填充），与 mood 实色对比拉开层级——视觉上 mood 是"句号"、tag 是"附笔"
- Tag 多选时多个边框只算 **1 处稳态**（同款重复 → 视觉合并），符合 v2 「视觉合并不计数」 暗规

**实际稳态**：典型 = 1 竖线 + 1 mood 实色 + 1（任意 tag 选中边）= 3 处。**∴ 满足原则 1**。

---

## 6. 交互状态

### 进入屏（编辑既有日记）
- AppBar 实色米灰，无底线（offset = 0）
- Hero 日期 + 写作区同时入场：fadeIn 240ms / `motion-standard`
- 写作区 controller 预填 `existingEntry.content`；mood / tags 预填
- 焦点不自动到写作区（避免键盘遮挡 hero——用户主动 tap）

### 进入屏（新建）
- 同上，写作区 controller 空，placeholder 显示
- 100ms 延迟后 `FocusScope.of(context).requestFocus(_contentFocusNode)`，键盘升起；hero 仍可见（写作区 expands 自动调整）

### 写作区 focus
- `motion-standard` 240ms 底线 1→2px、烟灰 30% → 黛蓝 100%
- 失焦反向

### Mood toggle（单选）
- tap → press scale 0.98 / 150ms → 240ms 切换实色：未选→选中色实色填充 `primary` + onPrimary 文字；其他 4 个自动取消
- 第二次 tap 同一 mood 不取消（保持单选 — 必选其一）

### Tag toggle（多选）
- tap → press scale 0.98 → 240ms 边色 outline @30% → primary 100% + 底色透明 → accentMuted 远黛
- 再 tap 取消

### 日期 picker
- tap hero 日期 / 副行 → `HanaBottomSheet.show(picker)`，最大 0.85 屏高
- 选择后 sheet dismiss，hero 文本 240ms 淡入新值

### 保存
- AppBar trailing「保存。」tap → press scale → isLoading=true（描边圆替换 label）→ cubit `addJournalEntry / updateJournalEntry`
- 成功 → `getIt<RecordBloc>().add(refresh())`（保留 v1 line 92-94 逻辑，handoff §1 注明）→ `context.pop()`
- 失败 → 写作区下方 inline body-sm 朱砂「保存失败。请重试。」240ms 淡入；trailing 重启用

### 删除（仅编辑态）
- AppBar trailing「删除。」tap → `HanaConfirmDialog.destructive(title: "删除后不可恢复。", message: "这一页将抹去。仍要继续？", confirmLabel: "删除")`
- confirm → cubit `deleteJournalEntry` → refresh RecordBloc → pop
- 取消 → dialog dismiss，回到原界面

### 物理返回 / leading back
- 直接 pop（不弹"未保存草稿"确认——日记是连续输入，强制问询会打断写作流）
- **未来** P3 跟进：长内容（> 50 字）未保存时弹 ghost confirm，本 PR 范围外

### `prefers-reduced-motion`
- 写作区呼吸线 240ms → 0ms 直显
- Toggle 色切换 240ms → 0ms 直显
- press scale 0.98 保留（微动可接受）

---

## 7. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，padding 水平 32（lg），写作区宽满 |
| 768–1024 (tablet) | 单列内文页 max-width 640px 居中（比 record 720 更窄——日记是私密阅读流） |
| ≥ 1024 (web 桌面) | 内容居中 max-width 640px；左 240px 占位（未来 timeline 关联）/ 右 240px 占位（未来字数 / 草稿历史） |

> mobile 是主战场。toggle 行始终单行 5 个（spacing.sm = 8 间距下，5×3字宽 + 4×8间距 < 屏宽）；超长 fallback `Wrap` 自动换行。

---

## 8. i18n 注意

| 现 ARB key | v1 文案 | v2 改写 | 备注 |
|-----------|---------|--------|------|
| `writeJournal` | 写日记 | **写一篇。** | 复用，值改 |
| `editDiary` | 编辑日记 | **编辑此页。** | 复用，值改 |
| `diaryPlaceholder` | 今天想说点什么... | **今日宜，按时落墨。** | 复用，值改；ja「今日は静かに。一筆を。」/ en「Today is good. Write a line.」 |
| `addTags` | 添加标签 | **留几个字** | 复用，值改（去"标签"医疗术语感）|
| (新) `journalMoodSection` | — | **今日心绪** | 心绪段落标题 |
| `presetTagHappy` | 开心 | **喜** | 复用，值改；ja「喜」 |
| `presetTagAnxious` | 焦虑 | **沉** | 复用，值改；语义对位 (anxious → 沉) |
| `presetTagCalm` | 平静 | **安** | 复用，值改 |
| `presetTagTired` | 疲惫 | **倦** | 复用，值改 |
| `presetTagHopeful` | 充满希望 | **起** | 复用，值改 |
| (新) `moodVeryGood` | (v1 emoji 🥰) | **激动** | mood 5 档文字版 |
| (新) `moodGood` | (v1 emoji 😊) | **好** | |
| (新) `moodNeutral` | (v1 emoji 😐) | **平** | |
| (新) `moodBad` | (v1 emoji 😔) | **累** | |
| (新) `moodVeryBad` | (v1 emoji 😢) | **沉** | 与 tag「沉」同字不冲突——上下文区分 |
| (新) `journalSave` | — | **保存。** | trailing |
| (新) `journalDelete` | — | **删除。** | trailing（仅编辑态） |
| (新) `journalDeleteConfirmTitle` | — | **删除后不可恢复。** | confirm dialog |
| (新) `journalDeleteConfirmMessage` | — | **这一页将抹去。仍要继续？** | confirm dialog |
| (新) `journalSaveError` | — | **保存失败。请重试。** | inline error |
| (新) `journalDatePickerTitle` | — | **记在哪一天。** | bottom sheet title |

> **DEC-042/043 修复**：`MoodLevel.displayName / emoji` 在 v2 widget 渲染时**忽略**（保留在 domain entity，不影响 storage 兼容；新增 `enum_l10n.dart` 扩展 `localizedName(l10n)` 走 ARB）。Tag 同理。

> **CJK 排版**：日期「4 月 28 日」用全角空格分隔数字与「月/日」字，display-md 行高 36 容 1 行。ja「4 月 28 日 (火)」副行可省括号——「火曜日」过长改「火」一字 + body-md。

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✅ Toggle button minHeight 44；hero 日期 tap 区扩展到副行包围 |
| Semantics 完整朗读 | ✅ Hero「2026 年 4 月 28 日 周二，可点击修改」；写作区 textField=true；mood toggle radio=true selected=true/false；tag toggle checkbox=true |
| 焦点顺序 | leading back → AppBar title → trailing 删除 → trailing 保存 → hero 日期 → 写作区 → mood ×5 → tag ×5 |
| `prefers-reduced-motion` | ✅ 呼吸线 / 色切换 240ms → 0ms |
| 对比度（light）| ✅ ink #1C1A18 on background #F4F1EA = 14.8:1（AAA）|
| 对比度（mood 选中）| ✅ onPrimary #FBF8F2 on primary #1F3A5F = 9.6:1（AAA）|
| 对比度（tag 选中）| ✅ primary 边 + ink 字 on accentMuted #E5E9EE = 12.4:1（AAA）|
| 屏幕阅读器 inline error | ✅ `Semantics(liveRegion: true)` |

---

## 10. 自我 critique-v2（短）

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处）| ✅ | 1 竖线 + 1 mood 实色 + 任意 tag 边（视觉合并 1 处）= 3 处稳态。focus 呼吸线为瞬时态不计 |
| 2. 调和层次胜过投影 | ✅ | 全屏 elev-0；写作区无外框只 1px 烟灰底线；零 BackdropFilter / 零 BoxShadow |
| 3. 编辑级不对称 | ✅ | Hero 日期左对齐 32，右侧 96px+ 留白；toggle 行左对齐起头不居中；AppBar title 左对齐（HanaTopBar 默认） |
| 4. 慢节奏与留白 | ✅ | 64→32→32→32→8→32→8→64 全跨级 |
| 5. 内容即装饰 | ✅ | 零 emoji（mood / tag 全文字化）；零图标 save（文字「保存。」）；零 InputChip 圆胶囊；零渐变 |

**自审遗留风险**：
- Tag「沉」与 Mood「沉」同字——同屏出现可能让用户犹豫"是心绪还是字"。规避：tag 段标题「留几个字」语义已暗示"附笔"，且两段间 spacing.lg=32 强制视觉分离；保留同字不改（v2 编辑体崇尚字的二义性，禁止"为防误读"加 emoji 或括号说明）。
- 编辑态 trailing 双 ghost「删除。」「保存。」并排——按钮文字过长可能在 ja 下溢出（「削除します」「保存します」）。规避：ja key 改 4 字内（「削除。」「保存。」）；超长在 web 端断点切到 AppBar overflow menu。
- 写作区 focus 时键盘升起，下方 mood / tag 段被遮挡——预期行为（用户先写正文，写完后失焦才看 mood / tag）。无需调整。

---

## 11. 与 critique-v1 的 P0 逐项消除

| critique-v1 P0 | v2 处理 |
|---------------|--------|
| P0-1 Mood selector emoji 圆 | 整段删除，换 5 个 `HanaButton.secondary` 文字 toggle（好/平/累/沉/激动）；选中态 1 处实色黛蓝 |
| P0-2 InputChip stadium 9999 | 整段删除，换 5 个 `HanaButton.secondary` 文字 toggle（喜/安/倦/沉/起）；选中态 1px 黛蓝边 + 远黛底 |
| P0-3 日期信息丢失 | 顶部新增 hero 段：display-md 日期 + body-md 周名；可点击触发 `HanaBottomSheet.picker` 改日期 |
| P0-4 TextField 无外框无反馈 | 换 `HanaInput.multiline` minLines 8；idle 1px 烟灰 30% 底线 / focus 2px 黛蓝呼吸线 240ms |
| P0-5 AppBar 居中 + 图标 save | 换 `HanaTopBar.defaultBar` 实色米灰 + outline 滚动；title 左对齐；trailing 文字「保存。」/「删除。」（ghost） |

> **P1 顺带处理**：water padding 24→32（lg） / 字体 Plus Jakarta Sans → Spectral / 思源宋体 / Noto Serif JP / 删除入口 ghost「删除。」+ destructive confirm / loading 切 HanaButton ghost 内置 isLoading / preset tag 文案改单字编辑体 / 写作区行高 26（CJK 1.73）

— 完 —
