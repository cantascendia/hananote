# Measurement 主屏 v1 现状 Design Critique

> **审视范围**: `lib/features/measurement/presentation/pages/measurement_page.dart`（271 行）
> **对照基准**: DESIGN.md（v2 编辑级东亚）+ tokens.md + principles.md（5 原则 + 严禁清单）
> **生成时间**: 2026-04-29

---

## 概述

v1 measurement_page 是一个典型的 Material 3「History List」：`AppBar(centerTitle 默认) + FloatingActionButton.extended + ListView.separated 卡片堆叠`。每个 `_MeasurementHistoryCard` 是 `Card(surfaceContainerLowest)` + 标题日期 (titleMedium bold) + 一行 `key: value · key: value` 的 inkSecondary 摘要 + 末尾 `Icons.delete_outline` IconButton。空态用 120dp 圆形 secondaryContainer alpha=90 容器 + 56dp `Icons.straighten` + 标题 + 副文。

**与 v2 的核心冲突**：
1. **没有按日期分组**——一周连续 7 条记录全平铺为 7 张独立卡片，没有杂志章节断点（与 timeline 屏 v1 同病）。
2. **没有趋势示意**——9 项数据每张卡只显示头三项摘要，用户从「上次胸围 88，这次 88.5」这条信息里读不到「↑ 0.5cm」的方向。
3. **数字与文字混排无 mono**——`88.5cm` 和「胸围:」用同一个 bodyMedium font，数字失去工具书感。
4. **删除入口暴露在每张卡**——破坏阅读流；v2 应把删除藏到详情 sheet 或左滑手势。
5. **FAB 椭圆 stadium pill**——Material 3 痕迹，违反 `r-button=6` 与「不 stadium pill」严禁清单。
6. **空态 56dp icon + 120dp 圆形容器**——装饰图标承担情感重量，违反原则 5（内容即装饰）。

整屏共扫出 **9 处 v2 严禁项 + 3 处叙事缺陷**。

---

## v2 五原则违规点

### 原则 1：一抹强色（黛蓝 ≤ 3 处 / 屏）

| # | 违规 | 位置 | 修复 |
|---|------|------|------|
| 1 | FAB extended `Icons.add + label` 用主题 primary 实色填充 + stadium 圆角 | L39-43 | 删除 FAB；改 sticky bottom `HanaButton.primary` 「记一次」（左对齐 32px、6px 圆角、非全宽） |
| 2 | AppBar 右侧 IconButton add 也是 primary 默认 tint | L33-37 | 删除（CTA 与 FAB 重复，一屏只一个新增入口） |
| 3 | 空态 secondaryContainer alpha=90 + secondary tint 大色块（120×120 圆 + 56dp icon） | L100-112 | 改 `HanaEmptyState.page`：`Icons.straighten_outlined` 32dp ink @ 60% + 单行宋体「未记录身体数据。」 |

### 原则 2：调和层次胜过投影

| # | 违规 | 位置 | 修复 |
|---|------|------|------|
| 4 | `Card` 默认 elevation 不为 0；与 `surfaceContainerLowest` 叠加在 `HanaColors.background` 上未刻意压平 | L143-144 | 改 `HanaCard.flat` 实色 surfaceContainerLowest + `radius.card=4`，elev-0 |
| 5 | AppBar 用 `HanaColors.surface` 与 background 对比度不足；M3 默认 `surfaceTint` 在滚动时引入半透明遮罩 | L31 | 改 `HanaTopBar.defaultBar` surfaceContainerHigh 实底 + 滚动 0.5px outline |

### 原则 3：编辑级不对称

| # | 违规 | 位置 | 修复 |
|---|------|------|------|
| 6 | AppBar `Text(title)` 默认居中 | L30 | 标题左对齐 spacing.lg=32（`HanaTopBar` 内嵌） |
| 7 | 没有 hero 段——直接进卡列表 | 整屏 | 顶部 64px 留白 + display-xl 宋体「身体记录。」+ body-sm 副行「共 N 期　近一次 4 月 28 日」 |
| 8 | 卡内 Row + Expanded + IconButton 双端对齐布局；删除按钮抢右端视觉重心 | L160-225 | 删除按钮移除主屏；卡片整张 `tappable` 跳详情 sheet（含删除 / 编辑） |

### 原则 4：慢节奏与留白

| # | 违规 | 位置 | 修复 |
|---|------|------|------|
| 9 | `padding: EdgeInsets.all(16)` + `separator: SizedBox(height: 12)`——12 不在 token（v2 跳过 12 / 20） | L58, L63 | 屏幕水平 padding spacing.lg=32；卡间 spacing.md=16；段落间 spacing.lg=32（按月份分组） |
| 10 | 7 张卡无月份章节断点，垂直无限堆叠 | L57-65 | 按 `DateFormat.yMMMd` 截月份分组，章节用 `HanaSectionHeader` 「2026 · 4 月」（4px 黛蓝竖线） |

### 原则 5：内容即装饰

| # | 违规 | 位置 | 修复 |
|---|------|------|------|
| 11 | `Icons.straighten` + `Icons.add` + `Icons.delete_outline` 三处装饰图标承担类别 / 入口 / 操作语义 | L36, L41, L107, L195 | 入口走文字 CTA「记一次」；空态走宋体陈述；删除藏 detail sheet |
| 12 | 摘要 `key: value · key: value` 混排，数值与单位用同一 bodyMedium，无 mono | L240-243 | 数值 mono Light + 单位 label-sm；趋势示意「↑ 0.5cm」inkSecondary 紧跟数值右侧 |
| 13 | 文案「记录在案。」未启用——v1 用 `measurementRecorded` 兜底 fallback；调性散乱 | L262 | 全屏文案统一句号收尾：「身体记录。」/「未记录身体数据。」/「记一次」/「与上次持平。」/「↑ 0.5cm」 |

---

## 跨性别敏感性盲点

| # | 盲点 | v1 | v2 处理 |
|---|------|----|---------|
| A | enum `bust='胸围'` / `underbust='下胸围'` 中文硬编码在 domain，DEC-042/043 违规 | `measurement_type.dart:6-15` | enum 仅保留 ASCII key，文案迁 `enum_l10n.dart` `localizedName(l10n)` |
| B | 「胸围 / 下胸围」措辞中性 ✓——但「上臂围」可改「臂围」更口语 | enum 9 项 | 保留中性术语，零体型评判副词（避免「腰瘦了」此类引导）|
| C | 摘要 fallback `measurementRecorded` 在没有任何字段时落到「记录在案。」——v2 改为「未填数值。」陈述事实 | L262 | 文案换中性陈述 |

---

## 节奏 / 表单可用性

| # | 问题 | 位置 | 修复 |
|---|------|------|------|
| D | 摘要默认 `MeasurementTypes.summary` 三项 (bust/waist/hip)，对未填这三项的用户回退到首三个非空项——逻辑分散 | L237-261 | 摘要恒按用户**实际填写顺序**取前 3 项 + 趋势箭头；剩余项数显示「+ N 项」尾标 |
| E | 删除确认 dialog 默认 Material AlertDialog 居中实色按钮 | L198-216 | 替换 `HanaConfirmDialog` 实底 + 编辑文案「删除这次记录？」+ 「删除」朱砂 ghost / 「保留」墨色 ghost |
| F | 没有空态导引——首次进入仅显示 icon + 副文，缺 CTA「记一次」按钮 | L92-132 | EmptyState 内嵌 `HanaButton.secondary`「记一次。」 |

---

## 修复优先级

- **P0**（block）：违规 #1 #4 #7 #11——FAB 渐变实色 / `Card` elevation / 无 hero 段 / 装饰图标承担入口语义
- **P1**（强烈）：#2 #5 #6 #9 #10 #12——AppBar 修正 / spacing token 化 / 月份分组 / 数值 mono
- **P2**（顺手）：#3 #8 #13 + A/B/C/D/E/F——空态精修 / 删除迁移 / 文案统一 / 跨性别敏感性 + 节奏

— 完 —
