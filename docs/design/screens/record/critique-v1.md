# Record 屏 v1 现状 critique

> Generated 2026-04-29 by AI design review against DESIGN.md v2
> 屏幕：`lib/features/journal/presentation/pages/record_page.dart`
> 用户场景：从 root tab 进入 → 选「拍照 / 测量 / 日记」三入口之一 → 跳详情
> 重设计阶段：Phase 3.2 Pilot Wave critique-v1（配对 spec.md / handoff.md）

## 1. 当前实现概要

`record_page.dart` (437 行) 是 5 个 root tab 之一。视觉骨架自上而下：
（a）`PreferredSize 64dp` AppBar 包 `BackdropFilter blur(12,12)`，居中堆叠 `recordTitle`「今日记录」+ tracking +2 的 `MMMd` 日期（70-115）；
（b）`SingleChildScrollView` 水平 padding 24，顶部用 `topPadding = MediaQuery + kToolbarHeight + 16` 撑开（116-121）；
（c）一段 `recordGreeting`「你好，\n今天想留下什么回忆？」`headlineLarge` 加粗 `PlusJakartaSans` 左对齐 8px 内缩（122-134）；
（d）三张 `_StitchRecordCard` 私有件依次：拍照 / 测量 / 日记，每张都是 24px padding + 16px 圆角 + `BoxShadow blurRadius:16` + `border` + 内嵌 `ImageFiltered blur(24)` 圆形装饰 + 旋转背景图标 + tag 圆胶囊 + 圆角 16 的 icon 容器（136-180、226-436）；
（e）footer 一个 64dp `Icons.spa` 莲花 + 12×12 红点装饰 + 大写 letterSpacing 2 的 `recordFooter`「每一次记录都是对未来的温柔期许」（182-216）；
（f）状态：`RecordInitial / RecordLoading` → `CircularProgressIndicator`；`RecordError` → 居中 Text；正常 → BlocBuilder 驱动 tag 文案动态化。

## 2. 违规点逐项（按 v2 5 原则）

### 原则 1：一抹强色（黛蓝 ≤ 3 处/屏）

- 现状：通屏使用 `HanaColors.primary`（v1 樱色 `#864E5A`）+ `HanaColors.primaryContainer` + `HanaColors.secondary` + `HanaColors.secondaryContainer` 四种强色。粗算强色出现位置：AppBar title 文字（93）、AppBar 日期文字 60% alpha（103）、Greeting 大标题（129）、拍照卡 accent + bg + tag bg + tag text（141-144）、测量卡 accent + bg + tag（156-159）、日记卡 accent（171）、footer Icons.spa 30% alpha（189）+ 红点 primaryContainer（198）+ footer 文字 60% alpha（211）。粗算 ≥ 12 处，且 3 张卡每张都自带一套强色独立配色——彻底失去"句号"语感。
- 违规：① 整套色板就错；② 强色出现 ≥ 12 处（v2 硬规则 ≤ 3）；③ 三张卡的 4 色拼盘是 v1 花笺"温柔多彩"语法，v2 必须 90% 单色 + 10% 黛蓝。
- 优先级：P0
- 改动建议：三入口卡片整体退到 `surfaceContainerLowest` 单色，强色仅留：① 章节标题左侧 4px 黛蓝竖线 ② 当日已记录入口右侧黛蓝小角标（可选）③ 底栏 active Tab 下划线（外部）—— 最多 2 处。

### 原则 2：调和层次胜过投影

- 现状：① AppBar `BackdropFilter blur(12,12)`（76）；② 每张 `_StitchRecordCard` 内嵌 `ImageFiltered blur(24,24)` 装饰圆（333-348），共 3 处；③ 每张卡 `BoxShadow blurRadius:16, offset (0,4)` + `Border.all(bgShapeColor)`（313-319）；④ 三张卡 `BorderRadius.circular(16)`（311）；⑤ 日记卡 icon 容器 `BorderRadius.circular(16)`（360）。
- 违规：v2 严禁 BackdropFilter blur、严禁 elevation > 0、严禁 border 当分隔、严禁圆角 ≥ 8px。一屏踩中 4 项硬规则。
- 优先级：P0
- 改动建议：删除所有 BackdropFilter / BoxShadow / border / 装饰 blur 圆，AppBar 换 `HanaTopBar` 实色 `surfaceContainerHigh` + 滚动时 1px outline @ 30% 细线，卡片圆角全部收到 4px。

### 原则 3：编辑级不对称

- 现状：① AppBar `centerTitle: true`（83）—— 居中题图；② 内容水平 padding 24（117），不是 v2 规定的 32（lg）；③ Greeting 段被 `EdgeInsets.symmetric(horizontal: 8)` 内缩，整段在屏幕中部偏左但**没有**章节竖线段落标记；④ footer 用 `Center` + `Stack alignment.topRight` 把 `Icons.spa` 强行居中（182-205）—— 居中是 v2 默认懒惰；⑤ 三张卡之间间距 24，不在 v2 token 序列；⑥ 三张卡内每张都用 `Row` 把 icon / text / 64dp 旋转 bg 图标三段排布，**结构对称**——v2 要求杂志式不对称呼吸感。
- 违规：AppBar 居中 / 水平 padding 错值 / footer 居中 / 间距非 token / 缺章节段落标记 / 卡内左右对称构图。
- 优先级：P0（padding + 章节标记 + AppBar 居中）/ P1（footer 居中、卡内构图）
- 改动建议：AppBar 标题左对齐 32px，水平 padding 24 → 32（lg），三入口前加左侧 4px 黛蓝竖线 +「今日 · {date}」段落标记，footer 删除 spa + 红点装饰整段，卡内构图改为左对齐宋体标题 + 副行 + 极少装饰。

### 原则 4：慢节奏与留白

- 现状：① 顶部 padding 由 `MediaQuery + kToolbarHeight + 16` 算出（≈ 84），但下方 Greeting → 第一卡只 32px（135），不达 v2 要求"章节起始 ≥ 32px"且与"顶部留白 64+xl"的呼吸节奏脱节；② 三张卡之间 24px 紧挨 24px（150,165）—— 24 不在 token 序列（4/8/16/32/64/128）且相邻间距未跨级；③ Greeting `Text` 内部用 `\n` 换行硬插一行，没有段落呼吸；④ footer 段 `Stack` 内 spa 与红点零间距堆叠，再下 16 紧挨 24（206,216）。
- 违规：① 三个非 token 间距值（16 内缩 / 24 卡间 / 8 内 padding）；② 相邻间距未跨级；③ 顶部 hero 区域留白节奏散乱。
- 优先级：P1
- 改动建议：水平 padding 32（lg）；hero → 第一段 64（xl）；三入口卡之间 32（lg）；卡内 padding 16（md）。

### 原则 5：内容即装饰

- 现状：① 三张卡每张右侧一个 64dp 旋转 6°/12°/-12° 的装饰图标（`Icons.photo_library` / `Icons.monitor_weight_outlined` / `Icons.auto_stories`）外加 `AnimatedRotation` hover 复位（415-426）—— 装饰图标 + 旋转动画承担情感；② 每张卡内嵌 `ImageFiltered blur(24)` 圆形 bg shape（128–192px）作为"装饰光晕"（333-347）；③ 每张卡左上 48dp 圆角 16 的 `Icons.camera_alt / straighten / menu_book` 容器图标 —— icon 容器化语法；④ 每张卡都有 tag 圆胶囊 stadium pill `BorderRadius.circular(9999)`（401）；⑤ footer 一个 64dp `Icons.spa` 莲花 + 12×12 圆点装饰承担情感（185-205）；⑥ 文案 `recordGreeting`「你好，\n今天想留下什么回忆？」第二人称疑问体（v2 严禁清单第 10 条："你做到了！"哄孩子调性）；⑦ 文案 `recordFooter`「每一次记录都是对未来的温柔期许」抒情体——v2 要求第三人称陈述 + 句号收尾。
- 违规：装饰图标承担情感 / 装饰光晕 / 旋转动画 / stadium pill 圆角 / 第二人称疑问体 / 抒情 footer。
- 优先级：P0（装饰图标 + 装饰光晕 + 莲花 + 抒情文案）/ P1（icon 容器化 + stadium pill）
- 改动建议：删除 6 个装饰图标 / 莲花 / 红点 / 装饰光晕 / 旋转动画；左上 icon 容器化删除，改用纯文字标题 + 一行编辑陈述；tag 改为 `body-sm · inkSecondary` 一行陈述（无胶囊）；文案换 v2 编辑体（"今日　记一笔。" / "三道入口。" / 句号收尾）。

## 3. 7 评审维度

### 可用性
三个核心入口（拍照 / 测量 / 日记）都用整张大卡 GestureDetector 命中（291-300），点击区域充足；scale 0.98 反馈也存在。问题在**视觉权重均等**：3 张卡每张都用全套强色 + 装饰 icon + 旋转动画 + tag——用户看不出哪个是"今天最该记的"。v2 应让最近未记录的入口承担一抹强色（如 24h 内未拍照 → 拍照入口右侧一个黛蓝小角标），其余两入口褪色。

### 层次
v2 要求 4 级 surface。当前实现：背景 `HanaColors.background`、卡 `HanaColors.surfaceContainerLowest`、AppBar 半透明 80% 实色 + blur ——只用 2 级 surface，且层次靠 BoxShadow + border + blur + 圆角光晕伪造，完全没实现 v2 纸阶差语法。

### 一致性
与 DESIGN.md 偏差：① 字体仍 `'Plus Jakarta Sans'`（90,100,127）——v2 要求 Spectral / 思源宋体 / Noto Serif JP；② 颜色 token 仍 `HanaColors.*`（v1 樱色），未迁 `HanaTokens`；③ 圆角 16 / 9999 stadium 出现，v2 token 表只有 0/2/4/6；④ 状态文案 `recordTitle`「今日记录」/ `recordGreeting`「你好，今天想留下什么回忆？」/ `recordFooter`「每一次记录都是对未来的温柔期许」均为 v1 信纸调性，v2 要求杂志陈述句。⑤ Loading 仍用 `CircularProgressIndicator`（32），v2 要求 `HanaLoadingView.block`「读取中。」一行宋体。

### 情感色彩
v2 调性："克制·沉静·不矫情·敬"。当前 record_page 是"温柔哄"——3 张多彩卡 + 旋转药片装饰 + 莲花红点 + 第二人称疑问 + 抒情 footer = v1 花笺典型。需整体退到月白底 + 三段宋体陈述 + 一抹黛蓝。

### 暗色模式
当前 `HanaColors.primary / primaryContainer / secondary / secondaryContainer / surfaceContainerHigh / onSurfaceVariant` 共 9 处使用了非 context-aware 静态常量（93,103,141-144,156-159,171-175,189,198,211 等）—— dark mode 下永远 light 值，闪白严重。v2 tokens.md §8.2 已明列 ban 项。

### i18n
日文 `recordPhotoSub`「写真は暗号化保存」/ `recordMeasurementSub`「身体の変化を記録」比中文长 ~30%，但当前 subtitle `bodySmall` 行高未约束，三卡布局 `Row + Expanded` 在长文下能 wrap 但与右侧 64dp 装饰图标抢宽度，会出现"标题 1 行 + 副标 2 行 + tag 1 行"导致卡片高度抖动。tag 圆胶囊单行无截断，长 streak 文案（`recordStreak` "已连续记录 365 天" / ja "365 日連続記録" ）会撑爆。

### 响应式
完全未处理 ≥768 Web 端：内容直接 `EdgeInsets.symmetric(horizontal: 24)` 撑满（117），平板 / 桌面单列拉宽到 1200+ "巨字幅"，杂志感破坏。需 max-width 720 内文页宽。

## 4. P0 / P1 / P2 总清单

### P0（违规必改）
1. 整屏色 token 从 `HanaColors.*` 切到 `HanaTokens.*(context)` 单轨 API（共 12+ 处调用点）。
2. 删除 AppBar `BackdropFilter blur(12,12)`（76）；改 `HanaTopBar` 实色 `surfaceContainerHigh`。
3. 删除 3 张卡内 `ImageFiltered blur(24)` 装饰圆 + `BoxShadow blurRadius:16` + `Border.all`（313-348）。
4. 卡片圆角 16 → 4（`HanaTokens.radius.card`），tag stadium 9999 圆胶囊整体删除。
5. 删除 3 张卡右侧 64dp 装饰图标 + `AnimatedRotation`（415-426）—— 装饰承担情感。
6. 删除 footer `Icons.spa` + 红点装饰整段（182-205）。
7. 字体 `'Plus Jakarta Sans'`（90,100,127）切到 v2 ramp：display-xl 用 Spectral SemiBold / 思源宋体 / Noto Serif JP；body 用 Inter / 思源黑体。
8. 文案改 v2 编辑体：`recordTitle` / `recordGreeting` / `recordFooter` / 3 个 empty / sub 全部走 ARB 替换为第三人称 + 句号收尾（详见 spec.md §8）。
9. AppBar `centerTitle: true`（83）改左对齐 32px。

### P1（应当改）
1. 水平 padding 24 → 32（lg）。
2. 三入口前加 `HanaSectionHeader`「今日 · {date}」+ 4px 黛蓝竖线段落标记。
3. 间距 24（卡间） / 16（顶部偏移） / 8（hero 内缩）替换为 token：卡间 `lg`(32) + hero 顶部 `xl`(64)。
4. 三张卡内左上 48dp 圆角 16 icon 容器删除——改用纯文字 title。
5. tag 圆胶囊改为一行 `body-sm · inkSecondary` 编辑陈述（"上次　4 月 25 日。" / "尚无记录。"）。
6. Loading 态 `CircularProgressIndicator`（32）改 `HanaLoadingView.block`「读取中。」。
7. Error 态居中 Text（41-46）改 `HanaErrorState`「载入失败。请下拉刷新。」+ ghost 重试。

### P2（可改）
1. Web ≥768 加 max-width 720。
2. 24h 未记录入口加黛蓝小角标作为"今日宜记"提示，让一抹强色承担可用性引导。
3. 加 `HanaPullRefresh` 触发 `RefreshRecordSummary`（v1.1 待落 spec）。
4. `flutter analyze` lint 禁用 `BackdropFilter` / `BoxShadow` / `Plus Jakarta Sans` / `HanaColors.*` 静态常量，防回归。

## 5. 既有重复模式映射（widget-pattern-inventory）

- `HanaTopBar.default` → 替换玻璃 PreferredSize AppBar（70-115），删 BackdropFilter
- `HanaCard variant=tappable` → 替换私有 `_StitchRecordCard`（226-436）整文件下线，删除内联 `Container(decoration: BoxDecoration(color, radius, border, boxShadow))` + `ImageFiltered`
- `HanaSectionHeader`（左竖线版，v1.1 待落 spec）→ 在三入口前承载「今日 · {date}」段落标记
- `HanaEmptyState variant=inline` → 替换 3 个 tag 圆胶囊（394-411）的"还没有 X 记录"文案，改 inline 一行
- `HanaLoadingView.block` → 替换 `CircularProgressIndicator`（32）
- `HanaErrorState` → 替换 41-46 居中 Text
- `HanaPullRefresh`（v1.1 待落 spec）→ 包裹 `SingleChildScrollView` 触发 `RefreshRecordSummary`

— 完 —
