# Data 屏 v1 critique（针对 v2 编辑级东亚方向）

> 对象：`lib/features/blood_test/presentation/pages/data_page.dart`
> 视角：DESIGN.md v2 + principles.md（一抹强色 / 调和层次 / 编辑级不对称 / 慢节奏 / 内容即装饰）
> Pilot Wave: 阶段 3.3.a

Data 是 v1 里"功能密度"最大、也是"卡片堆叠思维"最严重的一屏。一打开就是 4 张荧光描边的 Hormone 大格子 + 2 张紫色渐变 Hero CTA + 1 张白边 + 软糖角的 fl_chart，再叠 N 张 history 卡——所有元素都在抢话，没有一个角落是"留白本身"。这与 v2 "一份你愿意每天翻一页的私人内刊" 北极星基本背道而驰。下面按 9 个 P0 + 4 个 P1 列。

## P0 — 必须 block 才能 merge

1. **整套色仍是 v1 樱色 token**：`HanaColors.primary / primaryContainer / secondaryContainer / statusGreen / tertiary / error` 直接散落在 `data_page.dart`（line 38/45/74/162-164/420-421 等），绝大多数 `withAlpha(255*0.x)` 是手动调色——未走 `HanaTokens.*(context)` 单轨 API，主题切换/深色模式天然失效。

2. **3 处 BackdropFilter blur**：AppBar 的 `BackdropFilter(blur 12)` (line 33-36) 是 audit §5 P0-2 列出的 13 处工程债之一；Hormone Card 内部、Hero Card 内部的 white@50 圆形 icon 容器虽未直接用 blur，但配合外层渐变形成"玻璃感"，同样违反 v2 「无 BackdropFilter / 实色 surfaceContainerHigh + 滚动 0.5px outline」。

3. **大块渐变 + 大块强色泛滥**：`_StitchSimulatorCard` (line 401) + `_StitchKnowledgeCard` (line 489) 两张 Hero Card 各占 ~80% 屏宽的 `LinearGradient(primaryContainer → secondaryContainer)`，违反 principles §1 「黛蓝 ≤ 3 处 / 大块面积只允许在 Onboarding 第 5 屏 + 庆祝时刻」。一屏两张紫渐变 = 黛蓝直接贬值成"普通底色"。

4. **BoxShadow 满屏**：`_StitchHormoneCard` (line 300) 状态色彩 shadow blurRadius:16；`_TrendChart` (line 640) primary@4% blurRadius:24；`_StitchHistoryCard` (line 888) primary@2% blurRadius:10；`_StitchSimulatorCard/_StitchKnowledgeCard` primaryContainer@30% blurRadius:16——**5 处投影**，全部违反 v2 「elev-0 默认 / 阴影 ≤ 6%」。

5. **状态色用 statusGreen `#34D399` + tertiary 金 + error 红来表达正常/偏离/异常**（line 160-164）。这与 v2 「90% 单色 + 10% 黛蓝」根本冲突——3 种荧光色 × 4 张卡 = 一开屏就被 12 个色块抢视线。**正常范围本来不应该用任何"色"表达**（v2 用 inkSecondary 即可），只有"超出"用一抹黛蓝点睛即可。注意：v2 红色 `#9B2A2A` 朱砂仅限 destructive（删除 / 警告确认），不用于"数值偏离"——「数值偏高」≠「正在删除」，语义不该混。

6. **fl_chart 默认 Material 风**（line 711-801）：曲线 `isCurved: true` 圆滑 / `belowBarData` 黛蓝 → 透明的渐变填充 / `dotPainter` 4dp + 1.5px 白边 + 50% alpha——这是 Material You 折线图的标配。v2 编辑级东亚需要"印刷品折线图"：直线段 / 单色实线 / 无填充 / 实心黑墨点 / 等宽数字 Y 轴。

7. **三处逐字复制 ScaleTransition + AnimationController(150ms) + Tween**：`_StitchHormoneCard` (line 257) / `_StitchHistoryCard` (line 847) / `record_page.dart:261` `_StitchRecordCard`——audit inventory §1 模式 10 已点名。三套独立 State 类维护一个相同动画，是工程债 + v2 应统一为 `HanaPressScale` mixin。

8. **圆角 14 / 16 / 24 / 9999 stadium 五种非法值**：line 295 (24)、line 351 (9999 stadium pill)、line 414 (24)、line 502 (24)、line 638 (24)、line 887 (24)——v2 全面收紧到 4px 主导。Hormone Card 24px + Knowledge Card 24px + History Card 24px = 三档软糖造型，杂志感全无。

9. **字体仍是 `'Plus Jakarta Sans'` 圆润 sans**（line 52/120/191/209/370/916）：贯穿 Hero / 卡内 / 数值。v2 必须改 Hero 用 Spectral SemiBold / 思源宋体 Medium / Noto Serif JP Medium；正文用 Inter / 思源黑体；**数值 (32 大字 `valueNumber`、剂量、HRT 第 N 天)** 必须 JetBrains Mono Light——这是 tokens.md §2.3 的强约束。

## P1 — 必须修，但可在主重写之外做

- **AppBar 装饰 icon `Icons.notifications_none` + `Icons.add_circle`**：左上 leading 用 notifications 跳 settings 是错路由（语义错位），右上 add 用 `add_circle` 实心圆图标喧宾夺主。v2 用 `HanaTopBar` 仅 title + 单个 ghost action「记一次」(`Icons.add` 24dp 线性)。

- **Hormone Card 背景 96px 大水滴/警告 icon 装饰**（line 311-318）：水滴/警告 icon 在卡片右下角占 96×96 + 10% alpha = 装饰承担情感重量，违反 principles §5 「内容即装饰」。删除 icon，让数值本身成为视觉主角。

- **`spaceBetween` + `crossAxisCount: 2` 等长 Hormone GridView**：4 张完全等大格子排列，是"Material 仪表盘思维"——v2 应改为 1 列「血检指标列表」+ 每行 mono 数值左对齐 + inkSecondary 范围注脚，杂志目录页式。

- **「最近半年」筛选 chip 是 9999 stadium pill**（line 681-707）：违反 v2 圆角策略，改为 4px tag + tracking +0.6 label + 黛蓝下划线表达 active 态。

## 关于"超出正常用什么色"的决议

讨论：v2 红色 `#9B2A2A` 朱砂仅限 destructive；statusGreen 已删；那 hormone 偏高/偏低用什么？

**结论**：用 **黛蓝 mono 数字 + inkSecondary 注脚 "high / low"**——把"偏离"做成排版差异（数字加粗 + 一行小注），不做成色块。理由：① 临床数据"偏离"不等于"危险"，色块语义会过度警示成熟用户；② 黛蓝是 v2 唯一一抹强色，用它替"超出范围"反而符合"句号"语法——一屏 4 个指标里只有 1 个超出，黛蓝在它身上一次，正好。

**仅 critical（distance/span > 0.5）允许配一行朱砂注脚** "建议复诊。"——但**不**给数字本身染朱砂，朱砂仅落在文字注脚上。这样朱砂的稀缺感保留。

## 与 critique-v1 衔接

P0 #1-9 在 spec.md / handoff.md 中逐项消除。P1 在主 PR 顺手清理。Hero Card 紫渐变 + Hormone GridView 是本屏改造的两个最大决策点，spec 中重点处理。

— 完 —
