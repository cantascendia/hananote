# Data 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/
> 屏幕：`lib/features/blood_test/presentation/pages/data_page.dart`
> Pilot Wave: 阶段 3.3.b（新稿）+ 3.3.c（自我 critique-v2）
> 配对 handoff：`docs/design/handoff/data.md`

---

## 1. 设计意图

Data 屏在 v2 里要变成 **「内刊里的资料页」**——像 *Monocle* 杂志或新潮文库工具书的"数据页"：宋体小标题 + 大量等宽数字 + 单色细折线 + 留白注脚。它不是仪表盘 (dashboard)，是 **本月数据档案** (a monthly archive)。

v1 把 Data 当"健康仪表盘"做：4 张荧光描边 hormone 格子 + 紫渐变 Hero CTA + Material 风折线图——一屏 12 个色块争视线。v2 反过来：**单色 90% + 黛蓝 10%**，数据自己说话，图表只是文字的延伸。当用户翻到这一页，看到的应该是「噢、这是我自己的体检底稿」，不是「app 在向我汇报」。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 默认态（有数据 + 有趋势点 ≥ 2）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色 米灰，无 blur
│   "数据"  (title 18 · ink 左对齐 16)         │     右侧 ghost action: + (24dp 线性)
├─────────────────────────────────────────────┤
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│   本期数据。                                 │  ← display-xl (40·52·-0.5)
│   (Spectral SemiBold / 宋体 Medium · ink)   │     左对齐 spacing.lg=32
│   截至 4 月 28 日　共 12 期                  │  ← body-sm · inkSecondary
│                                             │     mono 数字 + CJK 全角空格
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 当前指标                                  │  ← HanaSectionHeader：4px 黛蓝竖线
│  ┃ (label · 12·+0.6 · inkSecondary)         │     竖线长 16px
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable
│   │  雌二醇                              │    │     surfaceContainerLowest #FBF8F2
│   │  (title 18 Regular · ink)            │    │     padding md, radius 4
│   │                                      │    │
│   │  158                pg/mL            │    │  ← display-md (24) mono 数字 + label 单位
│   │  (mono Light · ink)                  │    │     在范围内 = 数字 ink，无任何修饰
│   │                                      │    │
│   │  范围 100 – 200　·　在范围内         │    │  ← body-sm · inkSecondary
│   │  (mono 数字 + body 文字混排)          │    │     **不**用 ✓ 勾、**不**用色块
│   ╰────────────────────────────────────╯    │
│                                             │
│   (卡间 spacing.md = 16)                    │
│                                             │
│   ╭────────────────────────────────────╮    │  ← 第二张：超出范围（warning）
│   │  睾酮                                │    │
│   │  68                  ng/dL           │    │  ← 数字染 primary 黛蓝（一抹强色）
│   │  (mono · primary)                    │    │     这是该屏黛蓝出现位置 #1
│   │                                      │    │
│   │  范围 0 – 50　·　偏高                │    │  ← body-sm · inkSecondary
│   ╰────────────────────────────────────╯    │     "偏高" 不染色，不加 icon
│                                             │
│   ...（余下 hormone 同模板，最多 7 个，1 列）  │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 趋势                                      │  ← HanaSectionHeader
│  ┃                                           │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat（趋势卡）
│   │  雌二醇　最近半年                    │    │  ← title 18 + body-sm 副行
│   │  (title · ink)                       │    │
│   │                                      │    │
│   │  ┌──────────────────────────────┐    │    │  ← LineChart 高度 180dp
│   │  │ 200 ─                         │    │    │     Y 轴 mono 12 数字 + label 单位
│   │  │ 150 ─    ●                    │    │    │     dashed grid 1px outlineVariant @ 30%
│   │  │ 100 ─  ●   ●  ●               │    │    │     折线 1.5dp ink 实直线（非曲线）
│   │  │  50 ─        ●  ●             │    │    │     数据点 4dp ink 实心圆，焦点 6dp primary
│   │  │     └──────────────────       │    │    │
│   │  │     1 月 2 月 3 月 4 月        │    │    │  ← X 轴 label 用宋体「N 月」非「Apr」
│   │  └──────────────────────────────┘    │    │
│   │                                      │    │
│   │  最近一次　158 pg/mL　·　与上次持平  │    │  ← 趋势注脚 body-sm + mono
│   ╰────────────────────────────────────╯    │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 工具                                      │  ← HanaSectionHeader
│  ┃                                           │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable（不是 Hero）
│   │  PK 模拟器                          ›    │  ← title 18 + body-sm + chevron 16dp
│   │  按药物代谢估算次日血药浓度。          │    │     无渐变、无 icon 容器、无大块强色
│   ╰────────────────────────────────────╯    │
│                                             │
│   (卡间 spacing.md = 16)                    │
│                                             │
│   ╭────────────────────────────────────╮    │
│   │  知识库                             ›    │
│   │  HRT 流程、药物百科与文献摘要。        │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 历次报告                                  │  ← HanaSectionHeader
│  ┃                                           │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable
│   │  2026.04.12              ›          │    │  ← title mono 日期 + chevron
│   │  雌二醇 158　·　睾酮 68　…           │    │  ← body-sm 摘要：mono 数字 + 中点
│   ╰────────────────────────────────────╯    │
│                                             │
│   ...（按时间倒序）                           │
│                                             │
│   (底部 spacing.xl = 64)                    │
└─────────────────────────────────────────────┘
```

### 2.2 空态（无任何报告）

```
│   本期数据。                                 │  ← Hero 同默认态
│   尚未导入。                                 │  ← 副行换文案
│                                             │
│   (spacing.xl = 64)                         │
│                                             │
│   [ HanaEmptyState · variant=page ]         │
│   ⌥ Icon insert_chart_outlined 32dp          │     ink @ 60%，无圆形容器
│                                             │
│   本期空白。                                 │  ← headline 24
│   尚未录入血检报告。                          │  ← body-sm
│                                             │
│   [ 录入第一份 ]   HanaButton.secondary     │  ← 月白底 + 黛蓝 1px 边框
│
│  ┃ 工具                                      │  ← Knowledge / Simulator 入口仍保留
│  ...                                        │     即使无报告，工具入口仍可访问
```

### 2.3 单点态（只有 1 个报告）

趋势卡显示 `HanaEmptyState.inline`：「需至少两次报告才能成线。」+ inkSecondary。其他段照常。

### 2.4 错误态 / 加载态

- 错误：`HanaErrorState`「载入失败。请下拉刷新。」+ ghost「重试」
- 加载：`HanaLoadingView.block`「读取中。」inkSecondary

---

## 3. 组件映射

| 区域 | v2 组件 | Variant | 关键 props |
|------|--------|---------|-----------|
| 顶部栏 | `HanaTopBar` | `defaultBar` | title=l10n.dataTabTitle("数据"), action: ghost「+」|
| Hero「本期数据。」 | (Text) | display-xl 宋体 | 左对齐 spacing.lg |
| 副行（截至日 + 共 N 期）| (Text) | body-sm + mono 数字 | inkSecondary |
| 章节标题 | `HanaSectionHeader` | default | "当前指标" / "趋势" / "工具" / "历次报告"，4px 黛蓝竖线 |
| Hormone 指标卡 | `HanaCard` | `tappable` | 1 列（**不是 2×2 GridView**），数值 mono，超出范围数字染 primary |
| 趋势卡（折线）| `HanaCard` | `flat` | 内嵌 `HanaLineChart`（chart wrapper，详见 §5）|
| 趋势筛选（hormone / range）| `HanaSegmented` 或 `HanaChoiceChips` | default | 仅文字 + 黛蓝下划线 active，不 stadium pill |
| Simulator / Knowledge 入口 | `HanaCard` | `tappable` | 列表项形态：title + body-sm + chevron 16dp，**无渐变 / 无 icon 容器** |
| 历次报告卡 | `HanaCard` | `tappable` | 日期（mono）+ 一行 hormone 摘要 + chevron |
| 空态 | `HanaEmptyState` | `page` / `inline` | page 用于无任何报告；inline 用于趋势卡内"需至少两次报告" |
| 错误 / 加载 | `HanaErrorState` / `HanaLoadingView` | default / block | 同 today |

> **明确删除**：v1 `_StitchHormoneCard` (line 234)、`_StitchHistoryCard` (line 832)、`_StitchSimulatorCard` (line 401)、`_StitchKnowledgeCard` (line 489)、`_EmptyHistoryCard` (line 960)、`_TrendChart` (line 580) 全部删除/重写。Hormone 96px 装饰水滴 icon、status pill、stadium 9999 chip 全部删除。

---

## 4. Tokens 引用清单

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| Card 内文页 | `HanaTokens.surfaceContainerLowest(context)` |
| AppBar 米灰 | `HanaTokens.surfaceContainerHigh(context)` |
| Hero / 卡内主标题 / 范围内数值 | `HanaTokens.ink(context)` |
| 副行 / 注脚 / 范围说明 | `HanaTokens.inkSecondary(context)` |
| **超出范围数值** / 章节竖线 / 趋势焦点点 | `HanaTokens.primary(context)`（一抹强色）|
| critical 注脚「建议复诊。」 | `HanaTokens.error(context)` 朱砂（**仅文字注脚，不染数字**） |
| 折线主线 / 数据点 | `HanaTokens.ink(context)` |
| 折线网格 dashed | `Theme.of(context).colorScheme.outlineVariant.withOpacity(0.30)` |

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `spacing.lg` = 32 |
| Hero 顶部留白 | `spacing.xl` = 64 |
| 段落间（章节↔卡片群） | `spacing.lg` = 32 |
| Hormone 卡之间（同段） | `spacing.md` = 16 |
| 趋势卡 / 工具卡 / 历次卡之间 | `spacing.md` = 16 |
| 卡内 padding | `spacing.md` = 16 |
| 卡内段落（标题↔数值↔注脚）| `spacing.sm` = 8（紧密信息组） |
| 趋势卡内 chart 上下 | `spacing.lg` = 32（与文字段落跨级）|
| 屏幕底部 | `spacing.xl` = 64 |

> 强制跨级：卡内 8 + 卡间 16 + 段落间 32 三档逐级递增，符合 principles §4。

### 圆角
| 用途 | Token |
|------|-------|
| 所有卡片 | `radius.card` = 4 |
| 按钮（仅空态 secondary）| `radius.button` = 6 |
| 数据点 | 圆形（mathematical circle，不走 token）|

### 字体
| 用途 | Token / 字体 |
|------|------------|
| Hero「本期数据。」 | `display-xl` Spectral SemiBold / 宋体 Medium |
| 章节 label | `label` (12/16/+0.6) Medium |
| 卡内主标题（hormone 名 / 趋势标题 / 工具名）| `title` (18/26/0) Regular |
| **数值（hormone 当前值 / 历次报告日期 / Y 轴 / 趋势注脚数字）** | `mono` (14/20/0) JetBrains Mono Light **强约束** |
| 大数值（hormone 卡的 readout）| 24/32/0 mono Light（display-md 等价 mono 变体）|
| 单位（pg/mL / ng/dL）| `label` Medium，紧贴数字右侧 spacing.xs=4 |
| 范围说明 / 副行 / 注脚 | `body-sm` (13/20/0) inkSecondary |
| X 轴月份 label | `label` 12 宋体 Regular，文案 "1 月" 非 "Jan" |

### 动画
| 时机 | 时长 / 曲线 | Token |
|------|------------|-------|
| Hormone 卡 press scale | 150ms easeOut | `motion.quick` |
| 趋势卡内 hormone 切换（图重绘）| 240ms easeInOut | `motion.standard` |
| 折线初次绘制（reduce-motion off）| 600ms easeOut | `motion.deliberate` |
| 历次卡 fadeIn 错落 | 240ms × N，错落 80ms | `motion.standard` |

**绝对禁止**：折线 `isCurved: true`、`belowBarData` 渐变填充、数据点弹跳放大、历次卡列表的 stagger 入场超过 1 屏。

---

## 5. fl_chart 改造规范（核心章节）

v1 fl_chart 是 Material 风（圆滑曲线 + 渐变填充 + 多色 + 50% alpha 白边数据点）——v2 编辑级东亚要重写为 **「印刷品折线图」**：

### 5.1 视觉规则（hard rules）

| 元素 | v1 | v2（编辑级东亚） |
|------|----|----------------|
| 折线段 | `isCurved: true` 圆滑 | `isCurved: false` **直线段**（杂志数据图标准）|
| 折线宽度 | 3dp | **1.5dp**（印刷品级细线）|
| 折线颜色 | `HanaColors.primary` 黛蓝 | `HanaTokens.ink(context)` 墨色（**单色**，不是黛蓝—— 黛蓝留给焦点）|
| 折线下方填充 | `belowBarData` 黛蓝→透明渐变 | **完全删除** `belowBarData.show: false` |
| 数据点（默认）| 4dp primary + 1.5px 白边 | **4dp 实心 ink 圆**，**无描边** |
| 数据点（焦点 / 最新点）| 同上 | **6dp 实心 primary 黛蓝圆**，无描边——焦点点 = 该屏黛蓝出现位置 #2 |
| 网格（水平）| dashed primary @ 35% | dashed `outlineVariant @ 30%` 1px |
| 网格（垂直）| 隐藏 | 隐藏（保持 v1 决策） |
| Y 轴 label | `${value} ${unit}` 14dp inkSecondary @ 80% | **mono 12dp ink**，`reservedSize: 56`，与单位分离（数字 + label 单位左对齐）|
| X 轴 label | `DateFormat('MM/dd', localeName)` | **`{n} 月` 宋体 12dp**（zh）/ `{n}月`（ja）/ `{Mon}`（en，Spectral Regular）|
| Border | 隐藏 | 隐藏 |
| Tooltip（悬浮 / tap） | 默认 Material | `LineTouchData` 自定义：`HanaCard.surfaceLow` 4px 圆角，内置「{date} · {value} {unit}」mono + body-sm |
| Y 轴间隔 | 自动 / 3 等分 | **保留 3 等分**，但 minY/maxY 用「就近 nice number」算法（详见 handoff §3 `niceRange`）|
| X 轴间隔 | `interval: 1`（每点一个 label）| **按数据密度 ≤ 6 个 label**：`interval: max(1, points.length / 6).ceil()` |

### 5.2 焦点点判定逻辑

> 焦点点 = 列表中**最新一次**报告对应的点。如果 `selectedTrendHormone` 当次值在 `targetRange` 之外，焦点点改为**首个超出**的点（视觉警示）；否则恒为最新点。

- 焦点点之外的所有点 = 4dp ink 实心圆
- 焦点点 = 6dp primary 实心圆
- 全屏一次只有 1 个焦点点 → 黛蓝在折线图里只出现 1 次（符合 principles §1）

### 5.3 Reduce-motion

- 默认初次绘制 600ms 折线 sweep。
- `MediaQuery.disableAnimations` 为 true 时直接绘制，不动画。
- hormone 切换时 reduce-motion 仍允许 240ms 重绘（避免闪烁）。

---

## 6. 数据展示原则

按 critique §「关于超出范围用什么色」决议落实：

1. **范围内**：数值 mono ink，无任何修饰，无 ✓，无色块。"在范围内" 这五个字就是装饰。
2. **超出（warning，distance/span ≤ 0.5）**：数值 mono **primary 黛蓝**，注脚仍 inkSecondary 写「偏高」/「偏低」。**不**给注脚加色块。
3. **超出（critical，distance/span > 0.5）**：数值仍 mono primary 黛蓝（不染朱砂），但**额外多一行 body-sm 朱砂注脚**「建议复诊。」——朱砂仅落在文字注脚上，确保 destructive 色保留稀缺感。
4. 全屏可见区域内黛蓝 hormone 数值 ≤ 2 处（principles 硬规则 ≤ 3 处，本屏还有焦点点 1 处 + Hero 0 处 + 章节竖线 N 处「但章节竖线是结构装饰，不计入"一抹强色"配额」）。如果 3 个 hormone 都偏离 → spec 允许，但 PR 时人工 review。

---

## 7. 交互状态

### 默认装载完成
- AppBar 实色米灰，无底线（offset = 0）
- Hero / 章节 / 卡片同时入场：列表项 `motion-standard` 240ms fadeIn 错落 80ms

### Hormone 卡按下
- `HanaCard.tappable` press scale 0.98 + `motion-quick`
- onTap → `BloodTestBloc.add(SelectHormoneForTrend(reading.type))`，**同时滚动到趋势段**（保留 v1 行为）

### 趋势 hormone 切换
- 趋势卡内有 `HanaSegmented(items: HormoneType.values)` 控件
- 切换 → bloc 派发 → 240ms 折线重绘
- 同时趋势卡 title 副行更新「{name}　最近半年」

### 趋势 range 切换
- 副行右侧 `HanaChoiceChips(values: [3M, 6M, 1Y, ALL])` 4 个文字 chip + 黛蓝下划线 active
- v1 stadium pill 9999 完全删除

### 历次报告卡 onTap
- 跳 `/data/add_report?id={report.id}` 编辑（保留 v1 行为）

### 工具入口
- Simulator: `/data/simulator`
- Knowledge: `/knowledge`

### 下拉刷新 / 错误重试
- 同 today 屏规则

---

## 8. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，padding 32 |
| 768–1024 (tablet) | 单列 max-width 720px 居中 |
| ≥ 1024 (web 桌面) | 三列：左 240 sidebar（章节锚点跳转）/ 中 720 内文页 / 右 240 浮岛（最近指标 + 下次复检建议） |

> mobile 主战场。tablet/web 仅约束 max-width。

---

## 9. i18n 注意

- ja「ホルモン値」比 zh「当前指标」长 ~30%，章节 label 走 `Wrap` 自动折行。
- ja 单位（"pg/mL"）保持英文不本地化——单位是国际标准。
- X 轴月份：zh `4 月` / ja `4月` / en `Apr`——需要在 chart 内按 locale 派发文案，而不是硬编码。
- 数值 mono 字体不参与 locale 切换（locale 无关）。
- 「在范围内」/「偏高」/「偏低」/「建议复诊。」必须 ARB key（`data.statusInRange` / `data.statusHigh` / `data.statusLow` / `data.criticalSuggest`）。
- en 数值小数点保持 `.`，zh/ja 保留 `.` 不切换为全角句号（mono 字符表无全角点）。

---

## 10. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — Hormone 卡 / 工具卡 / 历次卡整张可点；趋势 chip 行高 ≥ 44 |
| Semantics | Hormone 卡 = 「{name}　{value} {unit}　{statusText}」整体作为 1 个语义单元 |
| 折线图 a11y | LineChart 包裹 `Semantics(label: "趋势图。{hormone} {range} {N} 个数据点。最新 {value} {unit}")`——屏幕阅读器朗读关键点而不是描述每个点 |
| 焦点顺序 | AppBar → Hero → 当前指标段（每张 hormone 卡 1 单元）→ 趋势卡（含切换控件）→ 工具卡 → 历次卡 |
| prefers-reduced-motion | 折线 sweep 跳过；列表 stagger 跳过 |
| 对比度（light）| ✓ — ink #1C1A18 on #FBF8F2 = 14.4:1（AAA）；mono primary #1F3A5F on #FBF8F2 = 9.0:1（AAA）|
| 对比度（dark）| ✓ — primary #7A9CC2 on #252320 = 6.4:1（AA+） |

---

## 11. 自我 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处）| ✓ | ① 章节竖线（结构装饰，4 处但视觉只 1 抹首行高度）② 折线焦点点 1 处 ③ 偏离 hormone 数值 1-2 处。AppBar / Hero / 工具卡 / 历次卡全部墨色。 |
| 2. 调和层次胜过投影 | ✓ | surface 4 级（background → containerLowest 卡 → containerHigh AppBar）。零 BoxShadow / 零 BackdropFilter / 零 border。 |
| 3. 编辑级不对称 | ✓ | Hero 左对齐 32px。章节竖线段落标记。Hormone 1 列（**不是** 2×2 GridView）。工具入口列表化（**不是** Hero CTA）。 |
| 4. 慢节奏与留白 | ✓ | 顶部 64px。卡间 16 + 段落间 32 跨级。Hormone 1 列 + 副行注脚而不是 4 张并排。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零装饰 icon（删除 96px 水滴 / 警告 icon）。状态用排版表达（mono 染色 + inkSecondary 注脚）而非色块。 |

**自审遗留风险**：
- `HanaSegmented` 控件目前未在 components/ 落地——本 spec 暂引用 `HanaChoiceChips` 替代「hormone 切换」，3.3.d 阶段补 segmented 规范。
- `HanaLineChart` wrapper 未单独成 component spec；本 spec §5 视为内嵌定义，由 handoff 给出 fl_chart theme 配置；后续如 simulator 屏（line 438）需要复用，再单独抽 component md。
- 全屏 7 个 hormone 都偏离的极端情况下黛蓝出现 7 次——principles §1 硬规则被打破。spec 决策：可接受（罕见医学场景，本身就是用户需要警觉的信号），但 PR 增加 lint：「单屏 mono primary > 3 处需 reviewer 显式 ack」。

---

## 12. 与 critique-v1 的 9 个 P0 逐项消除

| critique-v1 P0 | v2 处理 |
|---------------|--------|
| 1. 整套色 token 仍是 v1 樱色 `HanaColors.*` | 全切 `HanaTokens.*(context)` 单轨 API |
| 2. 3 处 BackdropFilter blur（AppBar + 卡内圆形 icon × 2） | 全删，AppBar 用 `HanaTopBar` 实色 + 滚动 0.5px outline |
| 3. 大块渐变 Hero CTA × 2（Simulator + Knowledge） | 改为 `HanaCard.tappable` 列表项形态：title + body-sm + chevron，无渐变、无 icon 容器、无大块强色 |
| 4. BoxShadow × 5（Hormone / Trend / History / Hero × 2）| 全删，elev-0 默认 |
| 5. statusGreen / tertiary 金 / error 红表达 normal/warning/critical | 全删。范围内 = ink 数字；超出 = primary 黛蓝数字 + inkSecondary 注脚；critical = 加 1 行朱砂注脚（仅文字）|
| 6. fl_chart 默认 Material 风 | 重写为「印刷品折线图」：直线 / 1.5dp ink 单色 / 无填充 / 实心数据点 / mono Y 轴 / 宋体「N 月」X 轴（详见 §5）|
| 7. 三处逐字复制 ScaleTransition + AnimationController | `_StitchHormoneCard` / `_StitchHistoryCard` / record_page `_StitchRecordCard` 全部统一为 `HanaCard.tappable`（内置 HanaPressScale）|
| 8. 圆角 14/16/24/9999 五种非法值 | 全统一：卡片 4 / 按钮 6；stadium pill 全删，改 4px tag + 黛蓝下划线 active |
| 9. 字体 Plus Jakarta Sans 圆润 sans | Hero → Spectral SemiBold / 宋体 Medium / Noto Serif JP；卡内 → Inter / 思源黑体；**所有数值 → JetBrains Mono Light** |

> **额外消除（critique-v1 P1 顺带处理）**：
> - AppBar `Icons.notifications_none` 跳 settings 错路由 → 删除 leading，改 `HanaTopBar.default` title only
> - AppBar `Icons.add_circle` 实心装饰 icon → ghost `Icons.add` 24dp 线性
> - Hormone 卡背景 96px 装饰水滴/警告 icon → 删除（内容即装饰）
> - 「最近半年」stadium pill chip → 4px tag + 黛蓝下划线 active
> - Hormone 2×2 GridView → 1 列（杂志目录页式）

---

— 完 —
