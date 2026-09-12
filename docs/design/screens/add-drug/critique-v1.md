# Add Drug 屏 v1 现状 Design Critique

> **审视范围**: `lib/features/medication/presentation/pages/add_drug_page.dart`（428 行单文件 — 模板 picker + 手动表单 inline 一体）
> **对照基准**: DESIGN.md（v2 编辑级东亚） + tokens.md + principles.md（5 原则 + 严禁清单） + onboarding spec/critique
> **权重提示**: Add Drug 是「记录器」最深一级表单，文案 / 默认值 / 节奏违规权重 ×1.5（直接落库 + 影响通知文案）
> **生成时间**: 2026-04-29

---

## 概述

v1 add_drug 把"模板快选"和"手动表单"塞进同一个 `Scaffold`，靠 `_showManualForm` 布尔切换两套 body。整体形态属于**典型 Material 3 ListView + ChoiceChip + SegmentedButton** 信纸表单——`OutlineInputBorder` 全包围、`SegmentedButton` 三连分段、`ChoiceChip` 横排 stadium 圆药丸、最后一个 `FilledButton 16px` 兜底。除了 `_buildTemplateCard` 的 `withAlpha(26)` 染色还残留几分 v1 花笺基因外，剩下基本是 **Flutter cookbook 默认产物**——和 v2 五原则**正面冲突**。

更严重的是源码 line 33-34 硬编码 `_category = DrugCategory.estrogen` + `_route = AdministrationRoute.oral`——这与 onboarding critique-v1 盲点 #3 **完全同源**：v2 必须默认 null，让用户主动选择。这不是"美学整改"，是产品立场修正：默认值在暗中预设了一种"标准 MTF 路径"。

整屏共扫出 **14 处 v2 严禁项 + 3 处跨性别敏感性盲点 + 4 处节奏 / 表单可用性问题**。

---

## v2 五原则违规点

### 原则 1: 一抹强色（黛蓝 ≤ 3 处 / 屏）

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 1 | 4 个类别色硬编码 — `estrogen=primary` / `antiAndrogen=#4A90D9` / `progestogen=secondary` / `auxiliary=#2CBAA0` | `add_drug_page.dart:321-328` | v2 类别**不上色** — 章节竖线统一黛蓝 4px，副标题用 `inkSecondary`。`#4A90D9` / `#2CBAA0` 不在 token 内，直接非法 |
| 2 | 模板卡 emoji 容器染 `color.withAlpha(26)` 底 + 路径 badge `color.withAlpha(20)` 底 + `Icons.add_circle_outline` primary 色 | L213-273 | 删 emoji 染色（emoji 本身违反原则 5）；badge 改 `mono 14 inkSecondary` 文字；删 trailing add 图标（卡片整体可点即 affordance） |
| 3 | 模板列表一屏可见 5+ 张卡 × 3 处染色 = **黛蓝/类别色出现 ≥ 15 处**，黛蓝彻底贬值 | 整个模板 picker | 单色卡 + 章节左竖线（黛蓝仅章节标记，每屏 ≤ 4 处段落 = 4 个类别） |

**累计违规**: 黛蓝 + 类别杂色总出现位置 **≥ 15 处**——原则 1 硬上限是 3 处。

### 原则 2: 调和层次胜过投影

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 4 | 模板卡用 `Material + borderRadius 16` + `surfaceContainerLowest` — 16px 软糖角 | L201, L204 | r-card=4 |
| 5 | "手动添加"按钮用 `Border.all(outlineVariant, 1.5)` — v2 严禁实线边框 | L291-294 | 改 `HanaCard.tappable` 单色 + 章节文本「自定义。」段落标记 |
| 6 | 手动表单 `OutlineInputBorder()` 全包围 3 个 TextFormField | L343, L356, L412 | `HanaInput` 仅底部 1px outline / focus 2px primary 呼吸线 |

### 原则 3: 编辑级不对称

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 7 | AppBar 标题 `Text(l10n.addDrug)` 居中（Material 默认） + Title 22 px w700 居中（line 134-140 顶部 header） | L105, L132-148 | display 32 黑墨宋体左对齐 32px + 4px 黛蓝竖线段落标记，右侧 96px+ 留白 |
| 8 | 类别 / 路径 / 单位三组用 `SegmentedButton` + `Wrap(spacing: 8)` 横排居中 | L363-405 | 选择字段全部用 `HanaInput`-style 触发 `HanaBottomSheet.picker`，对齐 onboarding 屏 4 模式（spec.md §6） |
| 9 | "保存" `FilledButton` 全宽 + padding 16 + 文字居中 | L417-422 | `HanaButton.primary fullWidth=false` 左对齐到 32px，杂志按钮即印章 |

### 原则 4: 慢节奏与留白

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 10 | 模板卡之间 `EdgeInsets.only(bottom: 8)` — 仅 8px = sm，紧密；类别块间 16 紧挨 16 | L198, L154-158 | 卡间 24-32px（lg 跨级），类别章节间 lg=32 跨到 md 卡内 padding=16 |
| 11 | 手动表单各字段用 `SizedBox(height: 16/24/48)` 硬编码且 24 紧挨 16（违反跨级） | L352, L360, L375, L391, L407, L416 | 全部 token 化：label→input xs(4) / 段落内 md(16) / 段落间 lg(32) / 章节间 xl(64) |
| 12 | 日期字段 v1 **完全没有**（template 内置 + 手动表单缺起止日字段）—— 即使 schedule editor 提供，add_drug 本身缺此意图 | 整屏 | v2 增「起始日」字段，使用 `HanaBottomSheet.picker` 内嵌日期 picker，**禁** `showDatePicker` |

### 原则 5: 内容即装饰

| # | 违规 | 位置 | 修复 |
|---|-----|------|-----|
| 13 | 模板卡每条都带 emoji（💊🩹💉 等 23 个，drug_templates.dart 硬编码） + Material `Icons.edit_outlined` / `Icons.add_circle_outline` 装饰图标 | L218-222, L268-273, L300-304 | **零 emoji**（原则 5 硬规则）— 模板卡仅文字（药名 title 18 + 通用名 body-sm 淡墨 + 路径 mono 14）。装饰图标全部删除 |
| 14 | `addDrug` AppBar 标题 / `drugTemplateTitle` "选择药品" / `drugCustomAdd` "手动添加自定义药品" — 工具语调 + 无句号收尾 | L105, app_zh.arb:472-474 | "记一种药。" / "翻药册。" / "自定义。" — 句号收尾 + 编辑视角 |

---

## 跨性别敏感性盲点（与 onboarding critique 同源）

| # | 盲点 | v1 现状 | v2 修复 |
|---|-----|--------|--------|
| #1 | 默认 estrogen + oral 暗中预设"标准 MTF 路径" | `add_drug_page.dart:33-34` | 改 `DrugCategory? _category = null` / `AdministrationRoute? _route = null`；picker placeholder "选择…" + helperText "可在记完后修改。" |
| #2 | 手动表单缺"备注"以外的私人语义—— 「genericName」label 硬翻"通用名"是医疗术语，对未出柜用户冷漠 | L353-359 + app_zh.arb:15 | label 改 "别名"或 "另一个名字。"（编辑视角），helper "如：通用名 / 商品名。" 把医学术语下沉到 helper |
| #3 | 23 个内置模板硬编码中文医保名（"补佳乐" / "诺坤复"），en/ja locale 时 fallback 模糊 | drug_templates.dart 全文件 | 模板 picker 在 `HanaBottomSheet` 内分组，每条按 `localizedName(l10n)` 三语对齐；如某模板无 ja 翻译，fallback 显示拉丁名 + helperText 标注 |

---

## 节奏 / 表单可用性

- **首屏歧义**: `_showManualForm` 布尔切换让用户在「模板 picker」和「手动表单」之间二选一，**没有"先模板填充再微调"路径**。v2 应统一为单一表单页 + 顶部「翻药册。」action 触发 `HanaBottomSheet.picker` 把模板预填进当前表单（用户仍可改）。
- **校验时机**: v1 用 `Form.validate()` 在 submit 时一次性弹错，且仅 `drugName` 必填；其他字段 null 时直接 `return` 静默不提示（line 78）。v2 应在 `HanaInput.errorText` 用 `body-sm inkSubdued` inline 文字（**不**用红色——朱砂仅 destructive 用，validation error 不上色），按字段 onBlur 触发。
- **剂量字段缺失**: v1 add_drug **完全没有** dose amount 输入（仅选 unit），实际剂量录入推到 schedule editor——但用户心智上"加一种药"应一次性填完。v2 增「常用剂量」`HanaInput.numeric`（JetBrains Mono Light 等宽），可空。
- **取消路径**: v1 仅靠系统返回键 / AppBar 回退；v2 显式「取消」`HanaButton.text` ghost 与 「保存」`HanaButton.primary` 在底部并排，左 ghost 右 primary。

---

## 总体判断

v1 add_drug 的**信息架构**正确（模板快选 + 手动表单是 22 种 HRT 药册场景的对正解法），但**视觉语法 / 默认值 / 文案**整体属于 v1 花笺残骸。Pilot Wave 重写按 onboarding 屏 4 已建立的 pattern：单卡多字段 + bottom-sheet picker 触发器 + spacing.lg 跨级分隔 + 默认 null。

**优先级**: 默认值 null 修复（盲点 #1）权重最高——这是产品立场，不是美学；模板 picker 改 bottom-sheet（原则 5 emoji 清场 + 一屏一重心）次之；输入框 / 按钮 token 化随 Phase 5 widget 落地自然解决。

— 完 —
