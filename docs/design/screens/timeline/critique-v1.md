# Timeline 屏幕 v1 现状 critique

> Generated 2026-04-29 by AI design review against DESIGN.md v2
> 屏幕：lib/features/timeline/presentation/pages/timeline_page.dart
> 用户场景：回顾 HRT 历程 → 翻看跨 feature 事件流（服药 / 血检 / 测量 / 照片 / 日记）→ 按时间范围筛选 → 点击单条进入详情
> 重设计阶段：Phase 3.1 Pilot Wave critique-v1（Timeline 屏）

## 1. 当前实现概要

timeline_page.dart 在 `Stack` 上层叠了一条**居中通屏垂直 2px 渐变线**（primaryContainer → secondaryContainer，timeline_page.dart:218-235）和一个 `CustomScrollView`，内容自上而下：
（a）`PreferredSize` + `BackdropFilter blur(12)` 玻璃 AppBar，左 settings IconButton + 中央居中标题"我的成长轨迹" + 右 calendar IconButton（30-72）；
（b）水平 Filter Pills，把 `TimelineRange` 枚举平铺为一组 `Chip`，选中态填 `primaryContainer`（284-336）；
（c）事件列表，每条 `_TimelineEventRow` 用左 / 中 / 右三栏 — **奇偶 index 决定卡片在左还是右**（255-269、349-396），中央一颗 16x16 白色圆点带 4px 描边 + 阴影，左右分别放 `_DateText` / `_EventCard`；
（d）卡片 `_EventCard` 4px 直边 + 4px 彩色侧边线 + Icons.stars + 类型 label，点击弹出 `showModalBottomSheet` 详情（419-621）；
（e）底部 `_TimelineStartPoint` — 灰圆 + Icons.psychology「旅程起点」+ 黛蓝小圆（665-706）；
（f）右下浮动 FAB 黛蓝→粉樱渐变圆按钮调出三选一 ListTile sheet（73-189）。

数据层：`TimelineEvent` 是聚合实体（domain/entities/timeline_event.dart），通过 `metadata` map 承载跨 feature 字段；`TimelineEventTypeX` 在 enums.dart 内**硬编码了 `Icons.medication_rounded` / `Icons.favorite_rounded` / `Icons.menu_book_rounded` / `Icons.star_rounded` 四个图标 + `Color(0xFF4CAF50)` 鲜绿 / `Color(0xFFE0A100)` 金 / 樱粉 / 黛蓝四种 borderColor**——domain 层直接写死装饰色违反 DEC-042/043。

## 2. 违规点逐项（按 v2 5 原则）

### 原则 1：一抹强色（黛蓝 ≤ 3 处/屏）

- 现状：通屏色锚点 9+ 处。AppBar settings + calendar icon（42、58）+ 居中标题（46）+ 中央渐变线（225-232，**通屏长度** 远超 30%）+ Filter Pill 选中态 primaryContainer 块面（320）+ 每张卡 4 色 borderColor 4px 侧边线（536-540，乘以可见卡数）+ 卡内 `Icons.stars`（562、587）+ 起点 psychology icon（682）+ 起点小圆点（698）+ FAB 黛蓝→粉樱渐变（87-95）。
- 违规：① 中央渐变线在屏幕长度方向上是**最大块强色**——日常浏览屏出现一条贯穿屏幕的彩色带，黛蓝立刻贬值；② enums.dart 把"血检 = 鲜绿 / 里程碑 = 金 / 日记 = 樱粉"四色固化进 domain 层 → v2"一抹强色"被 4 色彩虹替代；③ FAB 渐变 + 粉樱保留是 v1 花笺残留；④ Pill 选中态 primaryContainer 块面 ≥ 60×32 大于硬规则要求。
- 优先级：P0
- 改动建议：删除中央渐变线（用左侧 1px 黛蓝竖直时间轴替代）；enums 把四色 borderColor / iconColor / icon 全部移除（domain 零装饰）；事件类型用 inline label（`label · 12 · +0.6 tracking`）+ 一行墨色文字区分，不用色不用 icon；FAB 改单色黛蓝实色 6px 圆角按钮（不用渐变、不用浮岛圆）；Pill 选中态改下划线 2px 黛蓝（杂志目录页语法），不用块面填充。

### 原则 2：调和层次胜过投影

- 现状：① AppBar `BackdropFilter blur(12)`（33-35）+ alpha 80% 半透明（37）；② 中央圆点 4px 描边 + `boxShadow(blurRadius: 4)`（374-380）；③ 卡片 `boxShadow(primary @ 4%, blurRadius: 20, offset: 0,4)`（541-547）；④ FAB `elevation: 8`（82）+ 渐变 + 圆形 clip；⑤ 卡片 12-16px 圆角混用（528、533）+ 4px 实色侧边线（534-540）当装饰边框。
- 违规：v2 严禁 BackdropFilter blur + 严禁默认 elevation > 0 + 严禁 border 装饰 + 严禁 boxShadow > 6%。本屏在 4 处违反、是 widget-pattern-inventory.md #5「Glass AppBar」六处之一。
- 优先级：P0
- 改动建议：AppBar 换 `HanaTopBar.defaultBar` 实色米灰 + 滚动 0.5px outline；删除全部圆点 / 卡片阴影；卡片 4px 圆角无侧边线；FAB 删除（见原则 5），CTA 改为屏幕底部 `HanaButton.primary` 单色按钮。

### 原则 3：编辑级不对称（左对齐 32px，避免居中）

- 现状：① 通屏中央 2px 渐变线把内容**强制对称分裂为左右两栏**（218-235、349-396）—— 是 v2 严禁的居中对称布局；② AppBar `centerTitle: true`（40）；③ 卡片靠 index 奇偶在左右轮换（255-258），节奏机械且双向耗费视觉注意力；④ 起点 `_TimelineStartPoint` 整段居中（672-705）；⑤ 内容水平 padding 24px（300、354、385），未达 v2 要求的 32 (lg)；⑥ Filter Pills 起始位置在屏幕水平中线下方，整段无段落标记竖线。
- 违规：通屏中央渐变线 + 双侧对称布局是**最严重的 v2 红线触犯**——杂志栅格永远不对称，日记年表更要单边阅读流。
- 优先级：P0
- 改动建议：彻底重构布局——左侧 32px 留白 + 1px 黛蓝竖直时间轴（不渐变、宽度 1px、纵向连续）+ 时间标签（"4 月 28 日 · 周二"）紧贴竖线右侧 + 卡片全部右侧单列对齐；AppBar `centerTitle: false`；起点改为左对齐淡墨一行「2025 年 12 月 15 日　起点。」；padding 24 → 32。

### 原则 4：慢节奏与留白

- 现状：① 卡片之间 `bottom: 24`（260-261）—— 24 不在 v2 token 表（4/8/16/32/64/128）；② Filter Pills 与首张卡片之间间距未明确（依赖 `topPadding = SafeArea.top + kToolbarHeight + 16`），16 紧挨可能的 16 padding 违反跨级；③ 卡内 `SizedBox(height: 4)`（594、604）+ 卡片本身 padding 16（530）—— 4 紧挨 16 不算违规但卡内首尾节奏机械；④ 一屏中通常密布 5-7 条卡片（百级 entry 总长更紧），无章节段落留白；⑤ AppBar 之下立即接 Pills 无 hero 留白。
- 违规：间距值非 token（24）；段落之间无 `spacing.lg` (32) 节奏；缺顶部 hero 留白让用户"翻入年表"。
- 优先级：P1
- 改动建议：所有 24 → 32（lg）；首屏顶部 64px 留白后再出大字 hero「年表。」+ 副行；按月份/年份做章节断点（"2026 · 春" 章节标记 + 上下 lg 留白）；一屏可见卡 ≤ 4 条，密度让位呼吸。

### 原则 5：内容即装饰

- 现状：① domain 层 enums.dart 给每个 type 配 `IconData icon`（30-35）+ 类型色（37-51）—— 装饰承担情感且违反 DEC-042/043；② 卡片内 `Icons.stars`（562、587）作为类型旁边的小装饰 icon，与 type label 重复；③ FAB 用线性渐变（87-95）+ 加号 icon——v1 花笺残留；④ 起点 `Icons.psychology` 大脑图标（682）—— 装饰承担"旅程开始"语义；⑤ 卡片左/右侧 4px 彩色实线（534-540）—— 装饰边框；⑥ AppBar 标题"我的成长轨迹"是第二人称鼓励文案。
- 违规：装饰 icon、装饰渐变、装饰边框、第二人称文案——把 v2 严禁清单触犯近半。
- 优先级：P0
- 改动建议：domain enums.dart 删除 icon / borderColor / iconColor 三个装饰 getter（domain 零外部依赖原则 + 装饰由 presentation 层接管，事件类型用 inline label `服药` / `血检` / `测量` / `照片` / `日记` / `里程碑` 区分）；删除 Icons.stars / Icons.psychology / Icons.add；FAB 改单色实色按钮 6px；标题"我的成长轨迹" → "年表。"（第三人称编辑陈述 + 句号）；起点改一行宋体「起点。」+ 日期 mono 副行。

## 3. 7 个评审维度

### 可用性
回顾型屏的核心动作是"翻"和"找"。当前布局把眼睛强制在中央两侧来回扫描——左 / 右 / 左 / 右——eye-tracking 上是反 F-pattern 的 zigzag，疲劳。Filter Pills 6 个范围（"7 天 / 30 天 / 90 天 / 半年 / 一年 / 全部"）需要水平滚动才看全；FAB 和返回手势冲突。建议改单列左对齐 + 顶部 sticky filter chip 行（HanaBottomSheet 出过滤器更佳，因聚合屏 filter 维度未来要扩到 type × time × tag）。

### 层次
v2 要求 4 级 surface。当前实现：背景 `background`、AppBar 半透明 alpha、卡片 `surfaceContainerLowest`、Pill 选中 `primaryContainer` —— 实际只用 2 级 + 半透明，且层次靠"圆点 + 渐变线 + 阴影 + 边框"伪造。零 surface 阶差使用，完全没实现 v2 层次语法。

### 一致性
与 DESIGN.md 偏差：① 字体 `'Plus Jakarta Sans'`（48）+ `'Be Vietnam Pro'`（412）—— v2 要求 Spectral / 思源宋体 / Inter / JetBrains Mono；② 圆角 12 / 16 / 32 / 9999 stadium 多种值；③ 颜色全走 `HanaColors.*`（v1 樱色），未迁 `HanaTokens`；④ 文案"我的成长轨迹" / "尚无事件" 待迁入 v2 编辑体；⑤ Bottom Sheet 内 ListTile + Icon 为标准 Material 风（替代为 HanaBottomSheet `action-sheet`）。

### 情感色彩
v2 调性"克制、敬"。当前 timeline 是"social feed × 卡片游戏"——彩色圆点指示色 + 中央光带 + 4 类彩色装饰 + ★ 装饰 + 渐变 FAB —— 极易让用户误认为 Twitter / Facebook / Strava timeline。隐私年表语义（"这是你的私人内刊章节目录"）被淹没。v2 应改成"翻看一本装订好的年度回顾册"——左侧细黛蓝竖线像书脊装订线，右侧单列卡片像内文页节录。

### 暗色模式
`HanaColors.primary / .background / .secondary / .outlineVariant` 在多处使用静态常量（37、46、52、87-92、139、698）—— dark mode 下永远是 light 值。中央渐变线在暗色下几乎不可见；enums 硬编码 `Color(0xFF4CAF50) / Color(0xFFE0A100)` 鲜绿金在暗色背景下饱和度爆灯——典型 v1 工程债。

### i18n
日文"血液検査記録" / "服薬記録"较中文长 30-50%。当前卡片宽度被中央线砍半——左右各 ~46% 屏宽 - 16 padding ≈ 140-150px，日文 title 极易换行 3+ 行；`_DateText` 用 `DateFormat('yyyy.MM.dd')` 写死西文格式（408），不走 locale。

### 响应式
完全未处理 ≥1024 web 端布局。Web 桌面下中央竖线把屏幕劈成两条 ~600px 长条，每条卡内文字 ~480px 宽——巨字幅。timeline 是聚合屏，理应 ≥1024 启用"双列：左侧 timeline 主轴 + 右侧 detail panel 当前选中事件预览"，是 timeline 在 desktop 上最有"年度回顾册"质感的方向。

## 4. P0 / P1 / P2 总清单

### P0（必改）
1. **删除中央通屏渐变线**（218-235）—— v2 最严重红线，改左侧 1px 黛蓝竖直时间轴，宽度 1px、长度跟随内容、单边对齐
2. AppBar `BackdropFilter blur` + `withAlpha`（33-37）→ `HanaTopBar.defaultBar` 实色米灰 + 滚动 0.5px outline；`centerTitle: false`
3. domain `enums.dart` 删除 `IconData icon` / `Color borderColor` / `Color iconColor` 三个装饰 getter（30-51）—— 移到 presentation 层 `enum_l10n.dart` 风格的 `localizedTypeLabel(l10n)`，domain 仅保留 type 枚举
4. 卡片删除 4 色彩边线（534-540）+ Icons.stars（562、587）+ boxShadow（541-547）+ 圆点描边（364-381）
5. 整屏 `HanaColors.*` → `HanaTokens.*(context)` 单轨 API
6. FAB 渐变（87-95）删除，改为底部 `HanaButton.primary` 单色按钮 6px 圆角；CTA 文案 "记一次" / "新增记录"
7. 起点 `_TimelineStartPoint` 删除大脑 icon + 灰圆 + 小黛蓝点（674-703），改一行宋体「起点。」+ mono 日期副行，左对齐
8. 字体迁 v2 ramp：删除 `'Plus Jakarta Sans'`（48）+ `'Be Vietnam Pro'`（412）
9. Filter Pills 从块面填充改为下划线 2px 黛蓝（杂志目录语法，与底栏 active tab 同规则）
10. 文案"我的成长轨迹" → "年表。"；"尚无事件" → "尚未起笔。"

### P1（应改）
1. 水平 padding 24 → 32（lg），全屏 5 处
2. 卡间 `bottom: 24` → `bottom: 32`（lg），相邻间距跨级
3. 顶部加 64px hero 留白 + display-xl「年表。」+ 副行（"共 142 条记录　始于 2025 年 12 月"）
4. 按月份做章节断点：每个月起点出"2026 · 4 月" 章节标记（左侧 4px 黛蓝竖线 + label +0.6 tracking）
5. Filter 改用 `HanaBottomSheet.show()` 出多维筛选面板（type 多选 + 时间范围），适应未来扩展
6. 卡片 z 字双侧布局改为单列右侧对齐（左侧 32px 留白让位时间轴竖线）
7. `_DateText` 用 `DateFormat.yMMMd(localeName)` 而非写死格式

### P2（可改）
1. ≥1024 web 端启用双列：左 timeline 主轴 720px / 右 detail panel 320px 浮动展示当前选中事件
2. 性能：百级 entry 滚动用 `SliverList.builder` + `addAutomaticKeepAlives: false` + 卡片内文本 `RepaintBoundary` 包裹
3. 月份章节用 `SliverPersistentHeader` 实现 sticky 月份标签（滚动到下个月时上一月标签上滑）
4. 已读 / 未读语义可加（首次看过的 milestone 用淡墨；未看的 milestone 用墨色）—— 但仅 milestone 类型适用，避免日常事件视觉干扰
5. 删除 enums.dart 对 `material.dart` 的依赖，符合 domain 零外部依赖原则

## 5. 既有重复模式映射

- HanaTopBar.defaultBar → 替换 30-72 行整段 BackdropFilter AppBar（widget-pattern-inventory #5 六处之一）
- HanaCard.tappable → 替换 _EventCard 容器壳（419-621 内 `Container(decoration: BoxDecoration)`），删除 4 色彩边线
- HanaBottomSheet.actionSheet → 替换 FAB 创建 sheet（121-189）+ 卡片点击详情 sheet（436-527）
- HanaEmptyState.page → 替换 207-212 行 `Center(Text(emptyLabel))`
- HanaErrorState → 替换 105 行 `Center(child: Text(message))`（widget-pattern-inventory #3 六处之一）
- HanaLoadingView.block → 替换 102-103 行 `CircularProgressIndicator`
- HanaSectionHeader → 月份章节断点（全新 — Today 同款 4px 竖线）
- HanaButton.primary → 替换 FAB（73-98）

## 6. 用户故事影响分析

- **第一眼**：v1 是中央彩色光带 + 双侧卡片排列 + 多色装饰圆点（像 Strava / Twitter feed）；v2 是月白底 + display-xl「年表。」+ 左侧 32px 黛蓝细线像书脊装订 + 右侧单列内文页式卡（像翻阅装订成册的年度回顾）。
- **筛选**：v1 顶部水平滚动 Pill 块面填充；v2 顶部 sticky 一行 inline label + 下划线 active 态（杂志目录页语法），筛选维度扩展走 HanaBottomSheet。
- **翻看单条**：v1 卡片彩边 + ★ icon + 类型 label 重复装饰；v2 卡片只有 inline label（"血检 · 4 月 28 日"）+ 主标题 + 一行陈述，零装饰边线。
- **新建**：v1 右下渐变 FAB；v2 底部 sticky `HanaButton.primary` 单色按钮 + 文案「新增一笔。」。

## 7. 阶段 3.1.b 下一步指示

1. **先修 domain enums.dart 的 DEC-042/043 违规**（IconData / Color 三个装饰 getter 移到 presentation 层 `timeline_event_type_l10n.dart` 之类的扩展），让 domain 层零 Flutter 依赖——这是 spec 之前必须做的清理
2. **画两版起步稿对比**：A 版完全单列右对齐（左侧仅 1px 时间轴）；B 版保留双列但改左 240 detail panel / 右 720 timeline（仅 ≥1024 启用）。让 CTO 在第一轮决定是否完全放弃双侧对称
3. **先封 4 个 P0 共享件复用**（HanaTopBar / HanaCard / HanaBottomSheet / HanaEmptyState）；timeline 是聚合屏，改动放大效应 ≥ Today，不能在 timeline_page.dart 内联画杂志感

## 8. 风险与注意

最大风险是"social feed 联想未根除"——只删彩色装饰但保留双列 z 字布局，依然像 Instagram timeline；只换字体不换"中央竖线 + 卡片飘左飘右"模式，依然像 Material Stepper。v2 timeline 的根命题是**单边阅读流 + 装订线视觉隐喻**——任何保留双侧对称的折中都失败。性能上百级 entry 是 timeline 区别于 today 的最大变量，必须在 spec 阶段就把 SliverList builder + RepaintBoundary 写进 handoff，不能等到 Phase 6 再打 perf 补丁。

—— 完 ——
