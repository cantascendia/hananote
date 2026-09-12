# Add Drug 屏 v2 视觉与流程规范

> Generated 2026-04-29
> 单页表单（不再 `_showManualForm` 双态切换）
> 屏幕：`lib/features/medication/presentation/pages/add_drug_page.dart`
> Pilot Wave: 阶段 3.1.b（新稿）
> 上游基准：`docs/design/design-system/v2/{tokens.md,principles.md,components/*.md}` + `docs/design/screens/add-drug/critique-v1.md` + `docs/design/screens/onboarding/spec.md` 屏 4 pattern

---

## 1. 设计意图

Add Drug 是用户**第二次主动索取**的表单（第一次是 onboarding 屏 4）。v1 的双态切换（模板 picker ↔ 手动表单）把"翻药册"和"自己写"做成了两条并行路径，强迫用户在不掌握信息时二选一——而真实场景里，用户**几乎总是先在模板里找一找，没找到再改**。v2 把它合并成**单一表单页 + 顶部「翻药册。」action**：默认空表单，点击 action 在 `HanaBottomSheet.picker` 里按类别分组列出 22 个 HRT 模板，选中后预填进当前表单的所有字段，用户仍可逐字段微调——这是杂志的「目录页 → 内文页」节奏，不是 wizard 的「分支取舍」。

更重要的是修 critique-v1 盲点 #1：v1 默认 `DrugCategory.estrogen + Route.oral` 暗中预设"标准 MTF 路径"。v2 默认全部 null，picker placeholder "选择…" + helperText "可在记完后修改。"——零预设，每步退出口。

文案调性沿用 onboarding 立场：**第三人称编辑视角 + 句号收尾 + 零 emoji**。AppBar 标题 "记一种药。" / 翻药册 action "翻药册。" / 章节标题 "类别。" / "给药途径。" / "剂量。" / "起止日。" / "备注。"——七个段落，七个段落标记（4px 黛蓝竖线）。

---

## 2. 单屏结构（顶到底）

### 2.1 ASCII wireframe

```
┌──────────────────────────────────────┐
│ ←                          翻药册。  │  ← AppBar: ghost back + ghost action
│                                      │  spacing.lg (32)
│                                      │
│ │ 记一种药。                         │  ← display 32 + 4px 黛蓝竖线
│   每种药都是一段时间的注脚。         │  ← body-sm 淡墨副文
│                                      │  spacing.xl (64)
│                                      │
│ │ 名字。                             │  ← title 18 + 4px 竖线（章节段落标记）
│   药名                               │  ← HanaInput label tracking +0.6
│   ─────────────                      │
│   例如：补佳乐                       │
│                                      │  spacing.md (16)
│   别名                               │
│   ─────────────                      │
│   通用名 / 商品名（可空）            │  ← helperText 淡墨
│                                      │  spacing.lg (32)
│                                      │
│ │ 类别。                             │
│   类别                               │
│   ─────────────                      │
│   选择…                       ▾     │  ← 未选无默认（critique-v1 #1）
│   可在记完后修改。                   │  ← helperText 淡墨
│                                      │  spacing.md (16)
│   给药途径                           │
│   ─────────────                      │
│   选择…                       ▾     │
│                                      │  spacing.md (16)
│   剂量                               │
│   ─────────────                      │
│   2.0      mg                        │  ← numeric: JetBrains Mono Light + 单位 chip
│                                      │  spacing.lg (32)
│                                      │
│ │ 起止日。                           │
│   起始日                             │
│   ──                                 │
│   2026 / 04 / 29                     │  ← mono 14 数值（点击触发 picker）
│                                      │  spacing.md (16)
│   结束日（可空）                     │
│   ──                                 │
│   ——                                 │
│                                      │  spacing.lg (32)
│                                      │
│ │ 备注。                             │
│   ─────────────                      │
│   ┌──────────────────────────────┐   │  ← multiline (3 行起)
│   │                              │   │
│   │                              │   │
│   └──────────────────────────────┘   │
│                                      │  spacing.xl (64)
│                                      │
│   [取消]                  [保存]     │  ← ghost + primary 左右对齐 32px
│                                      │  SafeArea
└──────────────────────────────────────┘
```

### 2.2 顶部区

- **AppBar**: `surfaceContainerHigh` 实色 + 滚动时下方 1px outline @ 30%（无 BackdropFilter）。Leading `HanaButton.ghost` icon-only 返回；Trailing `HanaButton.ghost` 文字 "翻药册。" — 这是页面**唯一**的入口去打开模板 picker。
- **Hero 段**: 顶部 `lg` (32) 留白 + display 32 黑墨宋体 "记一种药。" 左对齐 32px + 4px 黛蓝竖线（一处黛蓝）。下方 `xs` (4) 副文 "每种药都是一段时间的注脚。"（body-sm 淡墨）。**右侧 96px+ 留白**（不对称呼吸感）。

### 2.3 表单段落（7 章节）

每章节左侧 4px 黛蓝竖线 + title 18 黑墨宋体段落标记（"名字。" / "类别。" / "起止日。" / "备注。"）——竖线长度仅覆盖标题首行（不是分隔符，是段落标记）。章节内字段用 `spacing.md` (16)，章节间 `spacing.lg` (32)，强制跨级。

| 章节 | 字段 | Variant | 默认 |
|------|-----|---------|-----|
| 名字。 | 药名（必填） | `HanaInput.singleLine` | 空 |
|  | 别名 | `HanaInput.singleLine` | 空 |
| 类别。 | 类别 | `HanaInput`-style 触发 `HanaBottomSheet.picker` | **null**（critique-v1 #1）|
|  | 给药途径 | 同上 | **null** |
|  | 剂量 | `HanaInput.numeric` (JetBrains Mono Light) + 单位 chip 内嵌 suffix | 空 / 单位由 route 决定首项 |
| 起止日。 | 起始日 | tap row 触发 `HanaBottomSheet.picker` 内嵌日期 | 空 |
|  | 结束日 | 同上，可空 | 空（"——" 占位） |
| 备注。 | 备注 | `HanaInput.multiline` minLines 3 | 空 |

### 2.4 底部按钮区

- 距上 `xl` (64) + SafeArea bottom
- 左 `HanaButton.text` (ghost variant) "取消"
- 右 `HanaButton.primary` "保存。"（一屏唯一 primary，黛蓝实色 + 6px 圆角）
- 两按钮各左右对齐 32px，**不**全宽

---

## 3. 模板快选（HanaBottomSheet.picker）

### 3.1 触发

AppBar 右上角 ghost action "翻药册。" → `HanaBottomSheet.show(context, sheet: HanaBottomSheet(title: l10n.drugTemplateTitle, child: ..., maxHeightFraction: 0.85))`

### 3.2 Sheet 结构

```
        ───────                            ← drag handle
   翻药册。                                ← title headline 24
   一份 22 种 HRT 常用药速记。             ← subtitle body-sm 淡墨

  │ 雌激素。                               ← 类别段落标记（黛蓝竖线 4px）
   ────────────────────────────────────
   补佳乐                          口服   ← title 18 + 路径 mono 14 inkSecondary
   戊酸雌二醇片                            ← body-sm 淡墨（通用名）
   ────────────────────────────────────
   诺坤复（舌下）                  舌下
   微粒化雌二醇片
   ...

  │ 抗雄激素。
   ...

  │ 孕激素。
   ...

  │ 5α-还原酶抑制剂。
   ...
```

- **背景**: `HanaTokens.surfaceContainerLowest` 雪宣
- **分组**: 按 `HrtDrugTemplates.byCategory` 顺序，类别段落标记 + 该类下模板列表
- **每条模板**: `Material(InkWell + 单色，无 emoji，无 trailing icon)`，行内 padding `md` (16)，行间 `spacing.sm` (8) + 章节间 `spacing.lg` (32)
- **路径标签**: 行右侧 `mono 14 inkSecondary` 文字（"口服" / "舌下" / "贴片" / "注射"），不带底色 chip，不染类别色
- **点击行为**: `setState(() { 全部 7 个字段从 template 预填; }); Navigator.pop()`——回到表单页用户仍可微调

### 3.3 关键改动 vs v1

- **零 emoji** — `DrugTemplate.emoji` 字段在 v2 widget 渲染时**忽略**（保留在 domain entity 不影响 storage 兼容；DEC-042/043 域层不变）
- **零类别染色** — 所有类别用同一墨色 + 黛蓝段落标记区分
- **零 trailing add 图标** — 整行可点即 affordance（IconButton add_circle_outline 删除）
- **零 16px 软糖角** — 行没有独立卡边界，靠 `spacing.sm` 行距 + 单色背景区分

---

## 4. 跨性别敏感性修复 vs critique-v1 3 盲点

| 盲点 | v1 现状 | v2 处理 | 落点 |
|-----|--------|--------|------|
| #1 默认 estrogen + oral | `add_drug_page.dart:33-34` | 字段类型改 `DrugCategory? + AdministrationRoute?`，初值 null；picker placeholder "选择…" + helperText "可在记完后修改。" | §2.3 类别 + §6 状态 |
| #2 "通用名"是医疗术语 | label 直翻 `genericName` | label "别名"，helperText "如：通用名 / 商品名。" 把医学术语下沉 | §2.3 名字 |
| #3 模板硬编码中文医保名 ja fallback 模糊 | drug_templates.dart | sheet 行渲染优先 `template.localizedName(l10n)`（未来扩展）；当前 fallback 显示拉丁 generic + helperText 标注 | §3.2 |

---

## 5. 视觉骨架（每段 ASCII）

见 §2.1 整屏 wireframe；模板 sheet wireframe 见 §3.2。

---

## 6. 组件映射

| 元素 | v1 inline 实现 | v2 组件 | tokens |
|------|---------------|--------|--------|
| AppBar back / action | `IconButton + Icons.check` (line 111-115) | `HanaButton.ghost` icon-only / 文字 | `r-button=6` · `ghost variant` |
| 模板 picker 入口 | 整屏 ListView header (line 132-148) | AppBar trailing ghost "翻药册。" | — |
| Hero 标题 | (v1 仅 AppBar 标题 `addDrug`) | `display` (32) 墨色宋体 + 4px 黛蓝竖线 | `display` · `ink` · `primary`(竖线) |
| 章节段落标记 | (v1 无) | `title` (18) 墨色宋体 + 4px 黛蓝竖线 | `title` · `primary`(竖线) |
| 文本输入 | `TextFormField + OutlineInputBorder` (line 339-350, 353-359, 408-415) | `HanaInput.singleLine / multiline` | `outline`(idle 1px) / `primary`(focus 2px) · `r-input=2` |
| 类别 / 路径选择 | `SegmentedButton` (line 363-374) / `Wrap+ChoiceChip` (line 378-389) | `HanaInput`-style 触发 `HanaBottomSheet.picker` | `r-input=2` · `motion-standard` |
| 单位选择 | `Wrap+ChoiceChip` (line 394-405) | 嵌入 `HanaInput.numeric` 的 suffix chip（route 改变时更新可选集） | `mono` · `inkSecondary` |
| 剂量数值 | (v1 无字段) | `HanaInput.numeric` (JetBrains Mono Light) | `mono` · `r-input=2` |
| 起 / 止日 picker | (v1 无字段) | `HanaBottomSheet.picker` 内嵌日期（**禁** `showDatePicker`） | `mono` 显数值 · 严禁清单 #8 |
| 模板列表行 | `Material + r-16 + Border + alpha 染色` (line 199-280) | 单色行 `InkWell`，无独立卡 | `surfaceContainerLowest` · `spacing.sm` 行距 |
| 模板行 emoji 容器 | 44×44 染色容器 (line 211-223) | **删除**（零 emoji 原则 5） | — |
| 模板行路径 badge | 染色 chip (line 250-267) | `mono 14 inkSecondary` 文字 | `mono` · `inkSecondary` |
| 模板行 trailing | `Icons.add_circle_outline` primary (line 269-273) | **删除**（整行可点即 affordance） | — |
| "手动添加" 按钮 | `Border.all` 1.5px outlineVariant 卡 (line 283-318) | **删除整个二态切换**（v2 单页表单） | — |
| 保存按钮 | `FilledButton` 全宽 r-16 (line 417-423) | `HanaButton.primary` 非全宽 + "保存。" | `primary` · `r-button=6` |
| 取消按钮 | (v1 无 — 仅系统返回) | `HanaButton.text` (ghost) | `ghost variant` |
| Validation error | `validator: return l10n.required` 红色 | `HanaInput.errorText` body-sm `inkSubdued` 文字（**不**用红色） | `body-sm` · `inkSecondary` |

---

## 7. Tokens 引用清单

**Colors** (per surface):
- `background` 月白 #F4F1EA — 全屏 Scaffold
- `surfaceContainerLowest` 雪宣 #FBF8F2 — bottom sheet 背景
- `surfaceContainerHigh` 米灰 #EAE6DD — AppBar 实底
- `ink` 墨色 #1C1A18 — 标题 + 输入文本
- `inkSecondary` 淡墨 #5E5A52 — 副文 + helperText + label + 路径标签 + validation error
- `primary` 黛蓝 #1F3A5F — **每屏 ≤ 3 处稳态**:
  - 7 个段落竖线（hero 1 + 章节 4：名字/类别/起止日/备注 = 5 处稳态）→ **超出原则 1 上限**，需取舍：保留 hero + 章节"类别。" + button = 3 处；其他章节标记改用 title 18 黑墨宋体**不带竖线**，靠字号 + spacing.lg 跨级分隔
  - 修正后：hero 竖线 + button 实色 + input focus 线（瞬时态不计）= **2 处稳态** ✅
- `outline` 烟灰 #A39E92 — HanaInput idle 底线 1px

**Typography**:
- `display` 32/42/-0.3 — hero "记一种药。"
- `title` 18/26/0 — 章节段落标记（黑墨宋体）
- `body` 15/24/0 — 备注 textarea
- `body-sm` 13/20/0 — 副文 / helperText / validation error
- `label` 12/16/+0.6 — HanaInput label
- `mono` 14/20/0 — 剂量数值 + 路径标签 + 日期数值

**Spacing**:
- `xl` (64) — hero 到第一章节 / 末段到按钮
- `lg` (32) — 章节间 / 章节标题到首字段
- `md` (16) — 章节内字段间 / 卡内 padding
- `sm` (8) — 模板 sheet 行间
- `xs` (4) — label 到 input

**Radius**: `r-card=4` · `r-input=2` · `r-button=6` · `r-bottom-sheet=16`(顶角)

**Motion**:
- `motion-instant` (80ms) — input focus 1→2px
- `motion-quick` (150ms) — HanaButton press scale 0.98
- `motion-standard` (240ms) — bottom sheet 升起 / 模板预填后表单字段值更新

---

## 8. 交互状态

- **HanaInput focus**: 80ms 1→2px primary 呼吸线
- **类别 picker**: tap 行 → `HanaBottomSheet.picker(items: DrugCategory.values.map(.localizedName(l10n)))` → 选中后 `setState`
- **路径 picker**: 同上；变更后单位字段 `_unit = _route.supportedUnits.first`（保留 v1 line 67-74 逻辑）
- **剂量 numeric**: 仅接受数字 + 小数点；suffix chip 显示当前 unit 名（不可点击改单位——必须经路径 picker 重选）
- **起始日 / 结束日**: tap 行 → bottom sheet 内嵌日期 picker；`firstDate=DateTime(1990)` / `lastDate=DateTime.now().add(Duration(days: 365))`（允许预计开始）
- **模板 sheet**: tap 行 → 7 字段一次性预填 + sheet dismiss + 表单页字段值更新动画（`motion-standard` 240ms 各 input 文本淡入替换）
- **保存按钮**: 仅 `药名 + 类别 + 路径 + 单位` 全部非空时启用；其他字段允许空。验证失败时 `HanaInput.errorText` inline 显示"请选择类别。" / "请填写药名。"（body-sm inkSubdued，不用红色）
- **取消按钮**: 直接 `Navigator.pop()` 不弹确认 dialog（用户改动可忽略——HRT 添加是低破坏性操作）
- **物理返回键**: 等价取消

---

## 9. 断点行为

| 断点 | 行为 |
|------|------|
| **mobile** (< 600dp) | 单屏全宽，水平 padding 32px |
| **tablet** (600-1024dp) | 内容居中宽度 480px，左右大留白 |
| **web ≥ 1024dp** | 内容居中宽度 720px，左右各 ≥ 152px 留白 |

---

## 10. i18n 注意

- 现有 ARB key 复用：`drugName` / `genericName` / `category` / `route` / `unit` / `notes` / `save` / `required` / `drugTemplateTitle` / `drugTemplateSubtitle` / `drugCustomAdd`
- **改写**: `drugTemplateTitle` "选择药品" → "翻药册。"；`drugTemplateSubtitle` "点击常用 HRT 药品快速添加，或自定义" → "一份 22 种 HRT 常用药速记。"；`drugCustomAdd` 整 key **删除**（v2 无独立"自定义"按钮）
- **新增 ARB key**:
  - `addDrugHeroTitle` → "记一种药。" / "Record a drug." / "薬を記す。"
  - `addDrugHeroSubtitle` → "每种药都是一段时间的注脚。" / "Each drug a footnote on a chapter." / "それぞれの薬がひとつの脚注。"
  - `addDrugSectionName` / `addDrugSectionCategory` / `addDrugSectionDates` / `addDrugSectionNotes` → "名字。" / "类别。" / "起止日。" / "备注。"（三语对齐）
  - `addDrugAlias` → "别名" / "Alias" / "別名"
  - `addDrugAliasHelper` → "如：通用名 / 商品名。" / "e.g. generic or brand name." / "例：一般名 / 商品名。"
  - `addDrugCategoryHelper` → "可在记完后修改。" / "You can change this later." / "あとで変更できます。"
  - `addDrugStartDate` / `addDrugEndDate` / `addDrugDosage`
  - `addDrugCancel` → "取消" / "Cancel" / "やめる"
  - `addDrugSave` → "保存。"（覆盖现有 `save` 在本屏的用法，加句号）
  - `addDrugErrorMissingName` / `addDrugErrorMissingCategory` / `addDrugErrorMissingRoute`（validation 文案，body-sm inkSubdued）
- DEC-042/043 修复：picker 内文案必须用 `cat.localizedName(l10n)` / `route.localizedName(l10n)` / `unit.localizedName(l10n)`，**不**用 v1 line 76 的 `displayName` 直出

---

## 11. a11y 检查

- **触控目标**: 所有 picker 触发行 ≥ 44dp（HanaInput 最小高 48）；保存 / 取消按钮 ≥ 44dp
- **焦点顺序**: hero → 药名 → 别名 → 类别 → 路径 → 剂量 → 起始日 → 结束日 → 备注 → 取消 → 保存 → AppBar 翻药册 → AppBar 返回
- **Bottom sheet 焦点 trap**: 进入 sheet 焦点到 sheet 内首条；ESC / 物理返回关闭并回到表单字段
- **`prefers-reduced-motion`**: bottom sheet 240ms → 0ms 直显；input focus 1→2px 80ms 保留（微动可接受）
- **Screen reader**: validation error 用 `Semantics(liveRegion: true, label: errorText)` 在变更时朗读；剂量 numeric 字段 `Semantics(textField: true, label: l10n.dosage + l10n.unit)` 把单位拼进 label
- **对比度**: ink #1C1A18 on background #F4F1EA = 14.8:1 (AAA) — 通过

---

## 12. 自我 critique-v2

| 原则 | 自审结果 | 落点 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处） | ✅ hero 竖线 + 保存按钮实色 + input focus 瞬时（不计） = 2 处稳态；模板 sheet 内类别段落标记按打开顺序露出，不与表单同屏 | §7 |
| 2. 调和层次胜过投影 | ✅ 全屏 elev-0；bottom sheet `elev-high`（唯一允许）；零 BackdropFilter；零渐变；零类别色染色 | §6 |
| 3. 编辑级不对称 | ✅ hero 标题左对齐 32px；按钮非全宽；段落竖线仅覆盖 hero 首行；右侧 ≥ 96px 留白 | §2 |
| 4. 慢节奏与留白 | ✅ 章节间 lg=32 + 段落内 md=16 跨级；hero 到首章节 xl=64；保存到 SafeArea xl=64 | §7 |
| 5. 内容即装饰 | ✅ 模板 sheet 零 emoji（drug_templates.emoji 字段渲染时忽略）；零 trailing icon；按钮文案句号收尾；validation 用 inkSubdued 不用红色 | §3.3 |

**残留风险**:
- 7 章节段落标记如果**全部**加黛蓝竖线会破坏原则 1（黛蓝出现 5+ 处稳态）。决策：**仅 hero 竖线**保留，其他章节标记靠 title 18 黑墨宋体 + spacing.lg 跨级分隔，无竖线——这与 onboarding 屏 4 单卡 4 字段方案一致，是 v2 段落标记的"经济使用"。
- 模板预填后用户改动 1-2 字段再保存——是否提示"已改动，仍按模板保存？" v2 决策：**不提示**，保存按钮依赖最终字段值，模板只是预填快捷方式，不是"绑定"。
- 剂量字段在 v1 完全缺失（仅在 schedule editor 录入），v2 增此字段会与 schedule editor 形成"两处可改"歧义。决策：add_drug 的剂量字段**仅作模板默认值** (`Drug.defaultDosage` 新字段)，schedule editor 的 dosage 是单次安排剂量，二者语义独立；ARB / handoff 注明区别。

---

## 13. 节奏与停顿

- **进入屏**: 路由 `context.push('/drugs/add')` 后 `motion-standard` 240ms slideUp（go_router 默认）
- **打开模板 sheet**: AppBar tap → 240ms easeInOut 上移 + scrim 淡入（`motion-standard`）
- **预填表单**: sheet dismiss 后 7 个字段 `motion-instant` 80ms 文本切换（避免突兀替换）
- **保存**: tap → button press scale 0.98 (150ms) → cubit `addDrug` → `Navigator.pop()` 直接回上一屏；**不**触发 HanaCelebration（仪式感留给"记一次"服药动作，"加一种药"是工具操作不上仪式）

— 完 —
