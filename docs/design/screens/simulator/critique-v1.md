# Simulator 屏 v1 critique（针对 v2 编辑级东亚方向）

> 对象：`lib/features/simulator/presentation/pages/simulator_page.dart`
> 视角：DESIGN.md v2 + principles.md（一抹强色 / 调和层次 / 编辑级不对称 / 慢节奏 / 内容即装饰） + data/spec.md §5 fl_chart 改造
> Pilot Wave: 阶段 3.4.a

Simulator 是 HanaNote 的明星功能 — V2 + Hana-PK 双引擎药代动力学模拟器，是产品差异化核心，也是数据密度最大、计算最复杂的一屏。v1 把它当"实验室仪器"做：science 烧瓶 icon + Beta 红 Badge + 4 个等大数字摘要 + 标 100/200 绿色"安全区"色块 + Material 圆滑曲线带渐变填充。一打开像血药监测仪，不像 *Monocle* 的"药物笔记"。下面按 8 个 P0 + 5 个 P1 列。

## P0 — 必须 block 才能 merge

1. **整套色仍是 v1 樱色 token**：`HanaColors.primary` (line 67/362/466)、`HanaColors.tertiary` (line 63 — Beta Badge 红盘)、`HanaColors.secondary` (line 419/467)、`HanaColors.outline` / `HanaColors.outlineVariant` 作为图表网格 (line 476)、`HanaColors.surfaceContainerLowest` (line 222/395/702) — 全部走 v1 静态常量 API 而非 `HanaTokens.*(context)`，dark mode + a11y 高对比模式天然失效。

2. **AppBar `Icons.science` + `Badge('Beta')` 实色 tertiary 红盘**（line 60-76）：science 烧瓶图标承担"切换引擎"语义 + 右上角 Beta 红 Badge 双重抢视线 = 该屏第一眼焦点是"实验室预警"而不是"用药笔记"。违反 principles §5「装饰存在于排版细节，不存在于额外元素」。v2 应改 `HanaTopBar` title only + 引擎切换走章节内 `HanaSegmented` 文字开关。

3. **图表 RangeAnnotation + HorizontalLine 大块绿色"安全区"**（line 527-555）：`Colors.green @ 10% alpha` 100-200 区间矩形填充 + 上下 0.3 alpha 绿线 = 视觉里两条绿色横带 + 一片绿色色块 — 既违反 principles §1「90% 单色 + 10% 黛蓝」（绿色不在 v2 palette 中），也越过临床边界（隐含 endorsement"在这条带内就是健康"）。v2 数据展示原则：阈值参考线用 `outlineVariant @ 15%` 1px 虚线，**单线**而不是色块；"在范围内 / 偏高 / 偏低"用文字注脚 + mono 数字 primary 染色表达，不用色块。同时回避"女性正常值"措辞，跨性别敏感性问题（详见 P0 #7）。

4. **fl_chart 默认 Material 风**（line 469-628）：`isCurved: true` 圆滑曲线 (line 596/610) + `belowBarData` 黛蓝→透明渐变填充 (line 615-625) + 折线 `barWidth: 2.5` (line 612) + 网格 dashArray `[4,4]` 直接画在内容区 (line 478) + tooltip 是 Material 黑底白字默认 (line 558-568) — 这正是 data/spec.md §5 已经判死的 v1 问题。v2 必须复用 `HanaLineChart` wrapper：直线段 / 1.5dp 单色 / 无 belowBar 填充 / 实心 ink 数据点 / 焦点点 6dp primary。simulator 是该 wrapper 的第二个消费者（首发 data 屏），不应重复定义。

5. **BoxShadow × 3**：`HanaShadows.cardShadow` 在 _ParamsCard (line 224)、_ChartCard (line 399)、_SummaryCard (line 704) 各刷一次 — 三层卡片堆叠 + 投影 = 仪表盘观感。违反 principles §2「elev-0 默认」。v2 全部走 surface 阶差（`background` → `surfaceContainerLowest`），零 BoxShadow。

6. **数据展示色用绿/橙/红三色情绪信号**（line 690-698）：`statusColor = HanaColors.error` (default 红) → `Colors.green` (in range) → `Colors.orange` (warning) — 既混用 token (`HanaColors.error`) 与裸 `Colors.*` 常量（dark mode 直接坏），也违反 principles §1。v2 决议（沿用 data/spec §6）：在范围内 = ink mono 数字无修饰；warning = primary 黛蓝 mono 数字 + inkSecondary 注脚；critical = mono primary 数字 + 加一行朱砂 body-sm 注脚「仅供参考。不替代医疗建议。」— 朱砂只染文字注脚不染数字。

7. **"目标范围"硬编码 100-200 pg/mL + 隐性"女性正常值"语义**：line 530/538/575/583/692 全部硬编码 100-200，line 561 tooltip "pg/mL" 硬编码单位 — 但跨性别 HRT 用户的"目标范围"因人而异（年龄/方案/服药相位），且 v2 i18n 决策要求文案中性。当前 `_SummaryCard` 在 avg 不在 100-200 时直接亮红色 `HanaColors.error` 报错 — 这等于在没有医生干预时给出"你不健康"信号。**法律边界 + 跨性别敏感性双重风险**。v2 必须：① 阈值由 `regimen.targetRangeMin/Max` 来自 BLoC（默认 100-200 但可覆盖）；② 范围措辞改"目标范围"（不是"正常范围"/"女性范围"）；③ 强制底部 body-sm 朱砂注脚「仅供参考。不替代医疗建议。」。

8. **圆角 16 / Material default 三档非法值**：`_ParamsCard` (line 223 = 16)、`_ChartCard` (line 396 = 16 with copyWith hack)、`_SummaryCard` (line 703 = 16)、`ElevatedButton` (line 366 = 12)、Material `OutlineInputBorder()` 默认 4 — v2 全部收紧到 4px (`r-card`) / 6px (`r-button`)。

## P1 — 必须修，但可在主重写之外做

- **逐字 5 个 `// ignore_for_file:` lint suppression**（line 3-10）：注释里写 "Release prep note: SimulatorPage is a dense experimental screen, so a small set of file-level lint suppressions remains until the post-release refactor" — 这正是该 refactor。v2 重写后这些 ignore 应全删（auto trailing commas / public API doc 通过子 widget 拆分自然消化）。

- **`_ParamsCardState` 内 5 个 `TextEditingController` 在 `_initFromRegimen` 里全部裸 `TextEditingController(...)` 重建**（line 175-185），却又在 `dispose` 中只 dispose 一份（line 188-194）。`didUpdateWidget` 切换 ester 时漏 dispose 旧 controller = 内存泄漏。v2 应改 `HanaInput` controller 在 `initState` 一次性创建，仅 `text =` 更新。

- **`SegmentedButton` 来自 Material 默认**（line 334-356）：椭圆 stadium 视觉 + selected primary fill — 违反 v2 严禁清单「Stadium / pill button (默认场景)」。v2 用 `HanaSegmented`（4px tag + 黛蓝下划线 active）。

- **`AspectRatio(1.5)` 死板 16:10**（line 436-439）：移动端纵向滑动时图表过扁，触摸命中数据点困难。v2 改为 `SizedBox(height: 240)` 固定高 + 内嵌 wrapper 处理 LTR/RTL。

- **图例 `_LegendItem` dashed 用 3 个 Container 拼接模拟虚线**（line 651-664）：fl_chart 自身支持 dashArray，但图例视觉用 3 段 Container 是 hack；改用 `CustomPaint` 单 widget 画 1.5dp 虚线（与曲线视觉同源）。

## 关于"V2 vs Hana-PK 双引擎对比"的视觉决议

讨论：双引擎是该屏差异化核心，v1 用「实线主色 + 虚线 secondary 50% alpha」表达 — 思路对，但执行错（用了 `HanaColors.secondary` 的金黄色，引入第二个强色 = 违反一抹强色硬规则）。

**结论**：双引擎都用同一墨色（`HanaTokens.ink`），仅靠**线型**区分：
- 当前激活引擎 = **1.5dp ink 实线**（焦点点 6dp primary）
- 对比引擎 = **1.5dp ink 虚线 dashArray [5,5]**（无焦点点）

理由：① 折线图最多 1 个黛蓝焦点点 = principles §1 黛蓝 1 处出现位置；② 双线同色不同型 = 杂志数据图标准（《纽约时报》图表标准 — Tufte 风），不依赖颜色编码；③ 对比引擎切换为激活时，焦点点平滑迁移 — 240ms `motion-standard` 重绘。

引擎切换控件改为图表卡内文字 `HanaSegmented`「V2 ｜ Hana-PK」+ 一行 body-sm「Hana-PK 含 MAP 校准。」副行说明，删除 AppBar 烧瓶 icon。

## 关于"数据密度最大屏"的克制立场

simulator 是最容易被科技感诱惑的一屏 — Beta Badge / 烧瓶 icon / 绿色安全区 / 多色摘要数字 / 渐变填充曲线 — 都是 v1 在炫"我会算 PK"。v2 立场：**计算复杂性应当被结果的简洁所掩盖**。一屏只展示：① 一个剂量参数表单（折叠态默认）；② 一条曲线（双线同色不同型）；③ 一行最大数字（稳态平均，mono 24dp）；④ 一行注脚（在 / 偏高 / 偏低 + 朱砂免责）。所有"AUC / Cmax / Cmin / 达稳天数"都在 detail 段二级展开 — 不在主视野争夺第一眼。

## 与 data/spec.md §5 复用关系

simulator 是 `HanaLineChart` wrapper 的第二个消费者：
- 完全复用：直线段 / 1.5dp / 单色 ink / 实心数据点 / mono Y 轴 / 「N 月」改为「N 天」X 轴 / 网格 outlineVariant @ 30% / Tooltip 卡片
- simulator 特有扩展：① 双线模式（`primaryLine` + `compareLine`，后者 dashArray）；② 阈值参考线 1px outlineVariant @ 15%（单线，不上下夹色块）；③ X 轴单位"天"而非"月"。

由此推动 `HanaLineChart` 抽象：从 data 屏的"hormone 趋势单线"演化为通用「印刷品折线图」组件 — 这次 simulator 重写是把 wrapper 落地为正式 component spec 的契机（详见 spec §5 + handoff §3）。

## 与 critique-v1 衔接

P0 #1-8 在 spec.md / handoff.md 中逐项消除。P1 在主 PR 顺手清理。AppBar science icon + 绿色安全区色块 + 双引擎金色虚线是本屏改造的三个最大决策点，spec 中重点处理。

— 完 —
