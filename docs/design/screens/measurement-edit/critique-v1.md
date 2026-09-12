# Measurement Edit 屏 v1 现状 Design Critique

> **审视范围**: `lib/features/measurement/presentation/pages/measurement_edit_page.dart`（304 行）+ `widgets/measurement_type_icon.dart`
> **对照基准**: DESIGN.md（v2 编辑级东亚） + tokens.md + principles.md + add-drug/spec.md（v2 表单 pattern）
> **生成时间**: 2026-04-29

---

## 概述

v1 measurement_edit 是一个 `ListView + Card + ExpansionTile + TextField + OutlineInputBorder + FilledButton` 的 Material 表单。日期选择走 `showDatePicker`（Material 标准弹层），9 项数值用 `keyboardType.numberWithOptions(decimal: true)` + 每个字段一个 `MeasurementTypeIcon` prefixIcon——而 prefixIcon 是带「装饰图标」的字段标签，违反原则 5（内容即装饰）。

「核心 5 项」与「扩展 4 项」用 `ExpansionTile` 折叠 / 展开切换——这是 Android 设置页语法，不是杂志表单语法。

整屏共扫出 **8 处 v2 严禁项 + 2 处表单可用性盲点**。

---

## v2 五原则违规点

### 原则 1：一抹强色（黛蓝 ≤ 3 处 / 屏）

| # | 违规 | 位置 | 修复 |
|---|------|------|------|
| 1 | `FilledButton` 默认 primary 实色 + 全宽 + 14 padding | L122-138 | `HanaButton.primary` 「保存。」非全宽 + 6px 圆角，左对齐 32px |
| 2 | `MeasurementTypeIcon` prefix 都是 primary tint 装饰图标（9 处 × 一屏可见 ~6 处 = 6 处黛蓝）| L297（widget 内） | **删除整个 widget**：表单字段不需要图标，文字 label 已足够 |

### 原则 2：调和层次胜过投影

| # | 违规 | 位置 | 修复 |
|---|------|------|------|
| 3 | `Card(color: surfaceContainerLowest)` 默认 elevation；ExpansionTile 用 RoundedRectangleBorder + radius 12 | L94-110, L221, L249 | 全删 Card 容器；分段靠 `HanaSectionHeader` 标题 + spacing.lg=32 跨级 |
| 4 | `OutlineInputBorder()` 全包围 9 个字段 + 备注 | L118, L299 | `HanaInput.numeric` / `HanaInput.multiline` 仅底部 1px outline / focus 2px primary |
| 5 | `ExpansionTile` 折叠展开是 Material chevron + ripple + alpha 容器 | L91-111 | 删除 ExpansionTile，全部 9 项一次展开（杂志表单不收纳） |

### 原则 3：编辑级不对称

| # | 违规 | 位置 | 修复 |
|---|------|------|------|
| 6 | AppBar `title` 默认居中 | L73-75 | `HanaTopBar.defaultBar` 标题左对齐 32px |
| 7 | 没有 hero 段——直接进入「核心测量」section | 整屏 | 顶部 64px 留白 + display 32 黑墨宋体「记一次。」+ 4px 黛蓝竖线 + body-sm 副文 |
| 8 | 「日期 picker」用 ListTile + leading `Icons.calendar_month` + trailing chevron——三件套居中 / 双端对齐 | L210-232 | `HanaInput`-style 触发 `HanaBottomSheet.picker` 内嵌日期 picker，**禁** `showDatePicker`（与 add-drug spec §2.3 起止日同 pattern） |

### 原则 4：慢节奏与留白

| # | 违规 | 位置 | 修复 |
|---|------|------|------|
| 9 | ListView padding 16 + SizedBox(height 16/12/24) 散落 + 字段间硬编码 12 | L77-122 | 全 token 化：水平 padding 32 / 章节间 lg=32 / 字段间 md=16 / Hero ↔ 首章节 xl=64 |

### 原则 5：内容即装饰

| # | 违规 | 位置 | 修复 |
|---|------|------|------|
| 10 | `MeasurementTypeIcon` 9 个测量项各自一个装饰图标（人体部位象形 icon）作为 prefixIcon | widget + L297 | **删除整个 widget**——文字 label「胸围 (cm)」已足够，单位也不需要 icon 暗示 |
| 11 | `keyboardType: TextInputType.numberWithOptions(decimal: true)` 输入数字时仍用系统默认 sans 字体显示——不是 mono | L295 | `HanaInput.numeric` 内置 JetBrains Mono Light 字体 |
| 12 | 标题文案 `coreMeasurements` 「核心测量」/ `extendedIndicators`「扩展指标」是 dashboard 语法 | L86, L92 | 改杂志体例：单一「数据。」章节标记 + 9 项一次性展开（无核心 / 扩展之分）|

---

## 表单可用性 / 跨性别敏感性盲点

| # | 盲点 | v1 | v2 处理 |
|---|------|----|---------|
| A | enum displayName 中文硬编码在 domain | `measurement_type.dart` | 同 measurement 主屏 critique #A：迁 `enum_l10n.dart`，DEC-042/043 合规 |
| B | 「核心 / 扩展」二分预设了「胸 / 腰 / 臀 / 大腿 / 上臂 = 重要」「下胸围 / 肩宽 / 颈围 / 体重 = 次要」——是体型监控 dashboard 假设 | L29-43 (entity) + L86-110 (UI) | 删除分类，9 项一次性展开；用户自己决定填哪些 |
| C | 「胸围」措辞中性 ✓（不用「乳围」），但 prefixIcon 用 `human_male_outline` 之类是否触发性别误读？ | `measurement_type_icon.dart` | 删除整个 widget，规避图标性别表达问题 |
| D | 没有任何字段必填校验——9 项全空 + 备注全空也能保存 | L161-189 | 保存按钮 disable 直到至少 1 项数值非空（避免空记录污染历史） |
| E | 数值字段无单位 affordance——用户输入「88」不知道是 cm 还是 kg | L298 | label 内嵌单位「胸围 (cm)」+ 字段右侧 mono suffix 显示单位 |

---

## 修复优先级

- **P0**（block）：违规 #1 #2 #3 #5 #7 #10——FilledButton 实色 / TypeIcon 装饰 / Card elevation / ExpansionTile 折叠 / 无 hero / icon prefix
- **P1**（强烈）：#4 #6 #8 #9 #11——OutlineInputBorder / AppBar 居中 / showDatePicker / spacing token / 数值非 mono
- **P2**：#12 + A/B/C/D/E——文案 / 跨性别敏感性 / 必填校验 / 单位 affordance

— 完 —
