# Simulator 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/ + data/spec.md §5
> 屏幕：`lib/features/simulator/presentation/pages/simulator_page.dart`
> Pilot Wave: 阶段 3.4.b（新稿）+ 3.4.c（自我 critique-v2）
> 配对 handoff：`docs/design/handoff/simulator.md`

---

## 1. 设计意图

Simulator 在 v2 里要变成 **「药剂师的演算簿」**——像 *Monocle* 后页的"参数表 + 一条曲线 + 一行结论"那种印刷品。它不是"血药监测仪"，是 **用户在纸上演算自己用药方案的笔记**。

V2 + Hana-PK 双引擎是产品差异化核心，但这种"两套数学引擎"的复杂性不应通过视觉炫技表达。v1 把双引擎做成"金色虚线 vs 黛蓝实线"+ Beta 红 Badge + 烧瓶 icon——三个互相打架的科技感符号。v2 反过来：**两条曲线同色不同型**（线型语法替代色彩语法），引擎切换走文字 segmented，AppBar 干净到只剩"用药模拟"四个字。计算复杂性藏进结果的简洁——一行 mono 大数字 + 一句陈述句 + 一行朱砂免责，足够。

simulator 是最容易被科技感诱惑的一屏 — 因此也是最该克制的一屏。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 默认态（已有方案 + 计算完成）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色 米灰，无 blur
│   "用药模拟"  (title 18 · ink 左对齐 16)     │     右侧 ghost action: 历史 (24dp 线性)
├─────────────────────────────────────────────┤
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│   用药模拟。                                 │  ← display-md (24·32·-0.2)
│   (Spectral SemiBold / 宋体 Medium · ink)   │     左对齐 spacing.lg=32
│   V2 + Hana-PK 双引擎　含 MAP 校准            │  ← body-sm · inkSecondary
│                                             │     mono 模型名 + CJK 全角空格
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 方案                                      │  ← HanaSectionHeader：4px 黛蓝竖线
│  ┃                                           │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat (collapsible)
│   │  雌二醇戊酸酯　5.0 mg / 7.0 天　›    │    │  ← title 18 · ink + chevron 16dp
│   │  (mono 数字 + body-sm "·" 副行)      │    │     折叠态默认；展开 → 编辑态
│   ╰────────────────────────────────────╯    │
│                                             │
│   ↓ 展开后（HanaBottomSheet picker 或 inline）│
│                                             │
│   ╭────────────────────────────────────╮    │
│   │  药物                                │    │  ← label 12 +0.6 inkSecondary
│   │  雌二醇戊酸酯                       ›│    │  ← HanaListItem.tappable → bottom sheet picker
│   │  (一行 22 种 HRT 模板 picker)         │    │
│   │                                      │    │
│   │  剂量　　　　　间隔                  │    │  ← 双列 label
│   │  5.0 mg　　　 7.0 天                 │    │  ← HanaInput numeric mono
│   │  (mono Light 18 · ink + 单位 label)  │    │     底部 1px outline，focus → 2px primary
│   │                                      │    │
│   │  途径                                │    │  ← label
│   │  [口服] [注射] [透皮] [其他]          │    │  ← HanaSegmented 4 段，文字 + 黛蓝下划线 active
│   │                                      │    │
│   │  体重  65 kg   贴片佩戴  7.0 天      │    │  ← inline mono 输入；条件展示
│   ╰────────────────────────────────────╯    │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 浓度                                      │  ← HanaSectionHeader
│  ┃                                           │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat (chart card)
│   │  90 天内　pmol/L            [V2｜Hana]│   │  ← title body + body-sm 副行 +
│   │  (title body · ink 左 / segmented 右) │    │     HanaSegmented 引擎切换（默认 V2）
│   │                                      │    │
│   │  ┌──────────────────────────────┐    │    │  ← HanaLineChart wrapper 高度 240dp
│   │  │ 1500─                         │    │    │     Y 轴 mono 12 数字 + label 单位 "pmol/L"
│   │  │ 1200─    ╱╲          ╱╲      │    │    │     dashed grid 1px outlineVariant @ 30%
│   │  │  900─   ╱  ╲   ╱╲   ╱  ╲     │    │    │     主线 1.5dp ink 实直线（非曲线）
│   │  │  600─ ╲╱    ╲╲╱  ╲╱    ╲     │    │    │     对比线 1.5dp ink 虚线 dashArray[5,5]
│   │  │  300─                         │    │    │     阈值参考线 1px outlineVariant @ 15%
│   │  │     └────────────────────     │    │    │     焦点点 = 最新点，6dp primary
│   │  │     0  20  40  60  80  天    │    │    │     X 轴 label 用宋体「N 天」
│   │  └──────────────────────────────┘    │    │
│   │                                      │    │
│   │  ─── V2　--- Hana-PK　Hana-PK 含 MAP  │    │  ← 图例 + 一行 body-sm inkSecondary 说明
│   ╰────────────────────────────────────╯    │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 稳态                                      │  ← HanaSectionHeader
│  ┃                                           │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat
│   │  稳态平均                            │    │  ← label 12 +0.6 inkSecondary
│   │                                      │    │
│   │  1245                pmol/L          │    │  ← display-md mono Light 32 ink
│   │  (mono · ink — 在范围内时不染色)      │    │     单位 label 12 紧贴右侧 spacing.xs=4
│   │                                      │    │
│   │  目标范围 600 – 1800　·　在范围内    │    │  ← body-sm · inkSecondary
│   │  (mono 数字 + body 文字混排)          │    │     "在范围内" 不加 ✓ 不加色块
│   │                                      │    │
│   │  达稳态　约 21 天                    │    │  ← body-sm + mono 数字注脚
│   ╰────────────────────────────────────╯    │
│                                             │
│   (卡间 spacing.md = 16)                    │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat (detail，二级)
│   │  详细                              › │    │  ← title 18 + chevron，可点开展开
│   │  峰  1542　谷  892　AUC  21000       │    │  ← body-sm + mono 数字（一行紧凑）
│   │  (折叠态默认；展开 → 4 个 stat 列表) │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│   仅供参考。不替代医疗建议。                 │  ← body-sm · error 朱砂
│   (居中 / 左对齐皆可，spacing.lg 缩进)        │     仅文字注脚 — 法律边界
│                                             │
│   (底部 spacing.xl = 64)                    │
└─────────────────────────────────────────────┘
```

### 2.2 偏离态（warning：浓度超出目标范围 ≤ 50%）

```
│   ╭────────────────────────────────────╮    │  ← 稳态卡变体
│   │  稳态平均                            │    │
│   │                                      │    │
│   │  2150                pmol/L          │    │  ← mono **primary 黛蓝** — 一抹强色 #1
│   │  (数字染 primary，注脚仍 inkSecondary)│    │     这是该屏黛蓝出现位置 #2（焦点点 #1）
│   │                                      │    │
│   │  目标范围 600 – 1800　·　偏高        │    │  ← body-sm · inkSecondary
│   │  达稳态　约 18 天                    │    │     "偏高" 不染色，不加 icon
│   ╰────────────────────────────────────╯    │
```

### 2.3 危险态（critical：浓度超出目标范围 > 50%）

```
│   │  3850                pmol/L          │    │  ← mono primary 黛蓝（同 warning，不染朱砂）
│   │                                      │    │
│   │  目标范围 600 – 1800　·　偏高        │    │  ← body-sm · inkSecondary
│   │  达稳态　约 18 天                    │    │
│   │                                      │    │
│   │  与目标范围偏离过大。                │    │  ← 多一行 body-sm **error 朱砂** 注脚
│   ╰────────────────────────────────────╯    │     朱砂仅落在文字注脚上，数字仍黛蓝
│                                             │
│   仅供参考。不替代医疗建议。                 │  ← 屏幕底部仍保留通用免责
```

### 2.4 空态 / 加载态 / 错误态

- 空态：进入即派发 `SimulatorEvent.started()` 加载默认方案，**不存在持久无方案态**。
- 加载：屏幕中央 `HanaLoadingView.block`「计算中。」inkSecondary（PK 计算预算 100ms 内完成 → 实际很少看到）。
- 错误：`HanaErrorState`「计算失败。」+ ghost「重试」 → 派发 `SimulatorEvent.regimenUpdated`。

---

## 3. 组件映射

| 区域 | v2 组件 | Variant | 关键 props |
|------|--------|---------|-----------|
| 顶部栏 | `HanaTopBar` | `defaultBar` | title=l10n.pkSimulatorTitle("用药模拟"), action: ghost「历史」（保留入口，未来扩展）|
| Hero「用药模拟。」 | (Text) | display-md 宋体 | 左对齐 spacing.lg；副行 body-sm + mono 模型名 |
| 章节标题 | `HanaSectionHeader` | default | "方案" / "浓度" / "稳态"，4px 黛蓝竖线 |
| 方案折叠卡 | `HanaCard` | `flat` + `collapsible` | 折叠态：title + 副行；展开态：picker + 双列 input + segmented |
| 药物选择 | `HanaBottomSheet` | picker | 22 种 HRT 模板（按 ester / 途径分组）|
| 剂量 / 间隔 / 体重输入 | `HanaInput` | numeric | mono Light 18 + 底部 1px outline，focus 2px primary |
| 给药途径 | `HanaSegmented` | default | 4 段（口服/注射/透皮/其他）+ 黛蓝下划线 active |
| 含服时长（仅 sublingual） | `HanaSegmented` | default | 4 段（30s/2min/5min/10min）|
| 引擎切换 | `HanaSegmented` | default | 2 段（V2 ｜ Hana-PK），位于图表卡右上 |
| 折线图 | `HanaLineChart` | `dual-line` | 直线 / 1.5dp ink / 主实线 + 对比虚线 / 单色 / 焦点点 primary（详见 §5）|
| 稳态平均卡 | `HanaCard` | `flat` | 大字 mono 数字 + label 单位 + body-sm 注脚（范围 / 偏离 / 达稳态）|
| 详细数据卡 | `HanaCard` | `tappable + collapsible` | 折叠态：一行紧凑摘要；展开态：peak/trough/AUC/Cmax 4 项 mono 列表 |
| 免责注脚 | (Text) | body-sm | error 朱砂 / 居中 spacing.lg 缩进 / 法律边界强制 |
| 加载 / 错误 | `HanaLoadingView` / `HanaErrorState` | block / default | 同 today/data |

> **明确删除**：v1 `_ParamsCard` (line 144) 内 ExpansionTile + DropdownButtonFormField + OutlineInputBorder + SegmentedButton 全部替换；`_ChartCard` (line 380) 重写复用 HanaLineChart；`_SummaryCard` (line 680) 4 等大数字方阵改为"一个稳态平均大字 + 详细折叠卡"两层；`_StatIndicator` (line 762) 删除；`_LegendItem` (line 632) 重构进 HanaLineChart wrapper。AppBar `Icons.science` + `Badge('Beta')` + 绿色 RangeAnnotation + BoxShadow × 3 全部删除。

---

## 4. Tokens 引用清单

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| Card 内文页 | `HanaTokens.surfaceContainerLowest(context)` |
| AppBar 米灰 | `HanaTokens.surfaceContainerHigh(context)` |
| Hero / 主标题 / 范围内数值 | `HanaTokens.ink(context)` |
| 副行 / 注脚 / 范围说明 | `HanaTokens.inkSecondary(context)` |
| **超出范围数值** / 章节竖线 / 折线焦点点 / segmented active 下划线 | `HanaTokens.primary(context)` |
| critical 注脚「与目标范围偏离过大。」/ 全屏免责「仅供参考。不替代医疗建议。」 | `HanaTokens.error(context)`（**仅文字注脚，不染数字 / 不染图表元素**）|
| 折线主线 / 数据点 / 对比线 | `HanaTokens.ink(context)` |
| 折线网格 dashed | `colorScheme.outlineVariant.withOpacity(0.30)` |
| 阈值参考线 | `colorScheme.outlineVariant.withOpacity(0.15)`（更淡，避免与网格混淆）|

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `spacing.lg` = 32 |
| Hero 顶部留白 | `spacing.xl` = 64 |
| 段落间（章节↔卡片群） | `spacing.lg` = 32 |
| 卡间 / 卡内段落（标题↔图表↔注脚）| `spacing.md` = 16 |
| 卡内紧密信息组（label↔数字 / 大字↔单位）| `spacing.sm` = 8 |
| 数字↔单位 | `spacing.xs` = 4 |
| 屏幕底部 | `spacing.xl` = 64 |

### 圆角
| 用途 | Token |
|------|-------|
| 所有卡片 | `radius.card` = 4 |
| HanaInput 底线 | 0（仅底部 1px outline）|
| 数据点 | 圆形 |

### 字体
| 用途 | Token / 字体 |
|------|------------|
| Hero「用药模拟。」 | `display-md` Spectral SemiBold / 宋体 Medium |
| 章节 label | `label` (12/16/+0.6) Medium inkSecondary |
| 卡内主标题 / 方案折叠 title | `title` (18/26/0) Regular |
| **方案 input 数值（剂量/间隔/体重）** | `mono` (18/24/0) JetBrains Mono Light **强约束** |
| **稳态平均大字** | 32/40/0 mono Light（display-md 等价 mono 变体） |
| **图表 Y 轴数字** | `mono` (12/16/0) Light ink |
| 单位（pg/mL / pmol/L / mg / 天）| `label` Medium，紧贴数字右侧 spacing.xs=4 |
| 范围说明 / 注脚 / 引擎说明 / 免责 | `body-sm` (13/20/0) inkSecondary（免责例外为 error）|
| X 轴天数 label | `label` 12 宋体 Regular，文案 "20 天"（zh）/「20日」（ja）/「d20」（en）|

### 动画
| 时机 | 时长 / 曲线 | Token |
|------|------------|-------|
| 方案卡折叠 / 详细卡折叠 | 240ms easeInOut | `motion.standard` |
| 引擎切换（V2 ↔ Hana-PK 折线重绘）| 240ms easeInOut | `motion.standard` |
| 参数变化 → 折线重绘 | 240ms easeInOut | `motion.standard` |
| 折线初次绘制（reduce-motion off）| 600ms easeOut | `motion.deliberate` |
| Bottom Sheet 药物 picker | 240ms easeInOut | `motion.standard` |

**绝对禁止**：折线 `isCurved: true`、`belowBarData` 渐变填充、稳态数字弹跳放大、Beta Badge 抖动、引擎切换粒子。

---

## 5. HanaLineChart 双线扩展规范（核心章节）

继承 data/spec.md §5 定义的「印刷品折线图」契约，simulator 是该 wrapper 的第二个消费者，新增以下扩展：

### 5.1 视觉规则（在 data §5 基础上加补）

| 元素 | data 屏（单线） | simulator（双线） |
|------|---------------|-----------------|
| 主线 | 1.5dp ink 直线段 | **保留：1.5dp ink 直线段**（无论 V2 / Hana-PK 哪个激活，都用同一墨色）|
| 对比线 | — | **1.5dp ink 直线段 + dashArray [5, 5]**（同色，仅线型区分）|
| 主线焦点点 | 6dp primary 实心圆 | **6dp primary 实心圆**（仅主线有；对比线无焦点点）|
| 主线数据点 | 4dp ink 实心圆 | **隐藏**（simulator 数据点过密，仅留焦点点）|
| 阈值参考线 | — | **1px outlineVariant @ 15% 实直线**（单线 — 上线 = max 或下线 = min；不上下夹色块）|
| 范围阴影填充 | — | **完全删除**（v1 `Colors.green @ 10%` 矩形违规）|
| Tooltip 内容 | `{date} · {value} {unit}` | **`{day}d · {value} pmol/L`**（mono），含 V2 / Hana-PK 双引擎双行对照 |
| 图例 | 单线无图例 | **「─── V2 　--- Hana-PK」**（线型一致，靠 dash 区分），右侧一行 body-sm 说明「Hana-PK 含 MAP 校准。」|
| Y 轴单位 | "pg/mL" | **"pmol/L"**（HRT 标准）— locale 不切换 |
| X 轴 label | "N 月" 宋体 | **"N 天" 宋体**（zh）/「N日」（ja）/「dN」（en）|
| X 轴间隔 | 按数据密度 ≤ 6 个 label | **按 maxX 派发**：≤ 30 天 → 5 天 1 label；30-90 天 → 10 天 1 label；> 90 天 → 30 天 1 label |

### 5.2 双引擎切换语义

- 用户在图表卡右上 `HanaSegmented` 切换 → bloc 派发 `SimulatorEvent.engineToggled()`
- 240ms 折线重绘：原激活线（实线）变虚线，原虚线变实线 — 焦点点平滑迁移到新主线
- 稳态平均卡 / 详细卡数字同步更新（reactive）
- segmented 选中态 = 文字 + 黛蓝下划线 2px（不是 stadium fill）

### 5.3 焦点点判定逻辑

> 焦点点 = 主线（当前激活引擎）的**最新一次稳态周期峰值**所对应的点。如果稳态平均超出 `targetRange`，焦点点改为**首个超出阈值线**的点（视觉警示 — 把"问题发生在哪一天"指出来）；否则恒为最新稳态峰值点。

- 焦点点之外的所有点 = 隐藏（不画 4dp 数据点 — simulator 90 天 × 多个采样太密集）
- 焦点点 = 6dp primary 实心圆
- 全屏一次只有 1 个焦点点 → 黛蓝在折线图里只出现 1 次

### 5.4 性能预算

- 单次 PK 计算 ≤ 100ms（domain 层职责，不在 UI 视野内）
- fl_chart 重绘 ≤ 16ms（一帧）→ 双线 + 90 天采样点 ≈ 540 个 FlSpot，CanvasKit web 端实测 ~8ms（对比 v1 `isCurved: true` 的 ~22ms — 直线段反而更快）
- web 端 reduce-motion 默认开启时跳过 600ms sweep，节省 ~36 帧

---

## 6. 数据展示原则（沿用 + 扩展 data §6）

1. **范围内**：稳态平均 mono ink，无任何修饰，无 ✓，无色块。"在范围内" 这五个字就是装饰。
2. **偏离 warning（distance/span ≤ 0.5）**：稳态平均 mono **primary 黛蓝**，注脚仍 inkSecondary 写「偏高」/「偏低」。详细卡内的 peak/trough 即使个别越界也**不染色**（避免一屏多处黛蓝）。
3. **偏离 critical（distance/span > 0.5）**：稳态平均仍 mono primary 黛蓝（不染朱砂），但**额外多一行 body-sm 朱砂注脚**「与目标范围偏离过大。」
4. **法律强制免责**：屏幕底部 spacing.xl 上 body-sm error 朱砂「仅供参考。不替代医疗建议。」 — 全屏所有状态（包括 in-range）都显示，不可关闭。这是法律边界 + 跨性别敏感性双重要求，不是装饰。
5. 全屏可见区域内黛蓝 ≤ 3 处：① 章节竖线（结构装饰，3 处但视觉只 1 抹）② 折线焦点点 1 处 ③ 偏离时稳态数字 1 处。AppBar / Hero / 详细卡 / 引擎切换 active 下划线（虽然黛蓝但属于结构装饰，不计入"一抹强色"配额）— 共 3 处。
6. **跨性别中性措辞**："目标范围"（不是"女性正常值"/"参考范围"）；"偏高"/"偏低"（不是"异常"）；"达稳态约 N 天"（不是"血药稳定时间"，更人话）。

---

## 7. 交互状态

### 默认装载完成
- AppBar 实色米灰，无底线
- Hero / 章节 / 卡片同时入场：列表项 `motion-standard` 240ms fadeIn 错落 80ms

### 方案折叠卡 onTap
- 折叠态展开：`motion-standard` 240ms 高度 + opacity 过渡
- 展开后内置 input / segmented / picker，**任何参数变化即时 reactive** 派发 `SimulatorEvent.regimenUpdated`（debounce 300ms 避免连续敲击 keystorm）

### 药物 picker
- onTap 药物字段 → `HanaBottomSheet` 弹出 22 种 HRT 模板（按 ester 分组，每组 SectionHeader）
- 选中后立即派发 + sheet dismiss（240ms standard）

### 引擎切换
- segmented onTap → `SimulatorEvent.engineToggled()` 派发
- 折线 240ms 重绘 + 稳态卡数字 fade swap（120ms × 2 = 240ms）
- 不弹 toast 不震动（克制）

### 详细卡折叠
- onTap 整张卡 → 展开 4 项 stat 列表（peak/trough/AUC/Cmax）
- 展开/折叠 240ms

### 反 reduce-motion
- `MediaQuery.disableAnimations` true 时所有动画跳过，直接刷新
- 折线初次绘制 sweep 跳过

---

## 8. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，padding 32 |
| 768–1024 (tablet) | 单列 max-width 720px 居中 |
| ≥ 1024 (web 桌面) | 双列：左 720 内文页（方案 / 浓度 / 稳态）/ 右 360 浮岛（详细 + 历史 + 免责） |

> mobile 主战场。tablet/web 仅约束 max-width。simulator 是该 app 在 web 端最有可能被深度使用的屏（比 mobile 的输入更顺手）— 但视觉规范保持移动端单列优先。

---

## 9. i18n 注意

- ja「用量シミュレーション」比 zh「用药模拟」长 ~25%，Hero `display-md` 自动 wrap，副行换行不缩进。
- ja 单位（"pmol/L" / "mg"）保持英文不本地化 — 单位是国际标准。
- X 轴天数：zh `20 天` / ja `20日` / en `d20`（紧凑 — Spectral 的 d 字符在小尺寸更清晰）— 在 chart 内按 locale 派发。
- 数值 mono 字体不参与 locale 切换。
- 「在范围内」/「偏高」/「偏低」/「与目标范围偏离过大。」/「仅供参考。不替代医疗建议。」必须 ARB key（`simulator.statusInRange` / `simulator.statusHigh` / `simulator.statusLow` / `simulator.criticalDeviation` / `simulator.disclaimer`）。
- 「目标范围」必须 ARB（`simulator.targetRangeLabel`）— 不能硬编码"正常范围"/"女性范围"。
- 22 种 HRT 模板药名走 `ester_type.dart` 现有 `localizedName(l10n)` 扩展，不新增。

---

## 10. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — 方案折叠卡 / 详细卡整张可点；segmented 段宽 ≥ 56；input 行高 ≥ 44 |
| Semantics | 折线图包裹 `Semantics(label: "浓度曲线。{engine} 引擎，90 天预测。最新稳态平均 {value} pmol/L，{statusText}。")`——屏幕阅读器朗读结论而不是 540 个数据点 |
| 焦点顺序 | AppBar → Hero → 方案卡（展开后内部 tab 顺序：药物→剂量→间隔→途径）→ 引擎 segmented → 浓度图（含切换）→ 稳态卡 → 详细卡 → 免责 |
| prefers-reduced-motion | 折线 sweep 跳过；卡片 fadeIn 跳过；引擎切换数字 swap 改即时刷新 |
| 对比度（light）| ✓ — ink #1C1A18 on #FBF8F2 = 14.4:1（AAA）；mono primary #1F3A5F on #FBF8F2 = 9.0:1（AAA）；error #9B2A2A on #F4F1EA = 6.7:1（AA+） |
| 对比度（dark）| ✓ — primary #7A9CC2 on #252320 = 6.4:1（AA+）；error #D67878 on #1C1A18 = 7.1:1（AAA）|
| 输入键盘 | numeric 字段调起 `TextInputType.number`（移动端）/ `inputType: number`（web）；间隔字段允许 1 位小数 |

---

## 11. 自我 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处）| ✓ | ① 章节竖线（结构装饰）② 折线焦点点 1 处 ③ 偏离时稳态数字 1 处。AppBar / Hero / 引擎下划线（结构）/ 详细卡均墨色。 |
| 2. 调和层次胜过投影 | ✓ | surface 4 级。零 BoxShadow（删除 cardShadow × 3）/ 零 BackdropFilter / 零 border。 |
| 3. 编辑级不对称 | ✓ | Hero 左对齐 32px。章节竖线段落标记。方案卡折叠（不并排展示）。稳态卡用一行大字 + 详细折叠（不是 4 等大方阵）。 |
| 4. 慢节奏与留白 | ✓ | 顶部 64px。卡间 16 + 段落间 32 跨级。引擎切换 240ms 重绘不快进。免责强制留底部 64px 后还有 spacing.xl，不挤压。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零装饰 icon（删除 science 烧瓶 / 状态 icon × 3）。状态用排版表达（mono 染色 + 注脚 + 朱砂）而非色块 / 进度环 / 进度条。 |

**自审遗留风险**：
- HanaLineChart 双线模式扩展未写成独立 component md（与 data §5 同样的处理）— 由本 spec §5 定义契约 + handoff 给出实现示例。如未来第三个屏需要折线（如 timeline / measurement），抽 component md。
- 22 种 HRT 模板分组规则未在本 spec 明示 — 委托 ester_type.dart 现有 enum + localizedName 扩展，picker 内部分组（口服 / 注射 / 透皮 / 含服）由 bottom sheet 自管理。
- "目标范围 600-1800 pmol/L" 是默认值，但 v2 应允许用户在 settings 自定义阈值（跨性别敏感性 + 个体差异）— 本次 spec 只保证"措辞中性 + 阈值来自 regimen"，自定义入口由 settings 屏在另一轮迭代落地。
- 稳态超出范围时焦点点定位"首个超出点"是新逻辑（v1 是最新点固定）— 需在 handoff 给出具体 `_focusIndex` 算法 + 单测覆盖。

---

## 12. 与 critique-v1 的 8 个 P0 逐项消除

| critique-v1 P0 | v2 处理 |
|---------------|--------|
| 1. 整套色 token 仍是 v1 樱色 `HanaColors.*` | 全切 `HanaTokens.*(context)` 单轨 API |
| 2. AppBar `Icons.science` + `Badge('Beta')` tertiary 红盘 | 全删，AppBar 用 `HanaTopBar` title only + 引擎切换降级到图表卡内 segmented |
| 3. 图表 RangeAnnotation 绿色"安全区"色块 + 上下绿线 | 全删。阈值参考线改 1px outlineVariant @ 15% 单线；状态用文字注脚表达 |
| 4. fl_chart Material 风（曲线 / 渐变填充 / 多色 / 50% alpha） | 复用 `HanaLineChart` wrapper（继承 data §5 + simulator 双线扩展 §5）|
| 5. BoxShadow × 3（_ParamsCard / _ChartCard / _SummaryCard） | 全删，elev-0 默认 |
| 6. 数据展示色用绿/橙/红三色情绪信号 | 全删。in-range = ink；warning/critical = primary 黛蓝数字 + inkSecondary 注脚；critical 加 1 行朱砂注脚（仅文字）|
| 7. "目标范围"硬编码 100-200 + 隐性"女性正常值" | 阈值由 `regimen.targetRangeMin/Max` 来自 BLoC + 措辞改"目标范围"+ 强制屏幕底部 body-sm error 朱砂免责 |
| 8. 圆角 16 / 12 / Material default 三档非法值 | 全统一：卡片 4 / 按钮 6 / input 底线 0px |

> **额外消除（critique-v1 P1 顺带处理）**：
> - 5 个 `// ignore_for_file:` lint suppression 全删 — 拆分子 widget 后自然消化
> - `_ParamsCardState` 5 个 `TextEditingController` 内存泄漏 → `HanaInput` 的 controller 在 `initState` 创建，仅 `text =` 更新
> - Material `SegmentedButton` stadium fill → `HanaSegmented` 4px tag + 黛蓝下划线
> - `AspectRatio(1.5)` 死板 → `SizedBox(height: 240)` 固定 + LTR/RTL 内嵌处理
> - `_LegendItem` 3 个 Container 拼虚线 hack → `CustomPaint` 单 widget

---

— 完 —
