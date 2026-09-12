# Today 屏幕 v1 现状 critique

> Generated 2026-04-28 by AI design review against DESIGN.md v2
> 屏幕：lib/features/medication/presentation/pages/today_page.dart
> 用户场景：早晨打开 → 看今日药 → 标记已服 → 庆祝
> 重设计阶段：Phase 3.1 Pilot Wave critique-v1

## 1. 当前实现概要

today_page.dart 用 `CustomScrollView` 串起一个 sliver 列表。视觉骨架自上而下：
（a）`SliverAppBar` — `BackdropFilter blur(12)` 玻璃感栏，左侧 `auto_awesome` 星形 icon + appTitle，右侧日历 IconButton（59-103）；
（b）问候段 — `display`-级"早安，{name}" + HRT 第 N 天 + 56px 圆形头像，spaceBetween 左右排布（104-170）；
（c）`CountdownCard` — 渐变 + blur 圆 + 旋转药片 icon + 大数字倒计时（287-307）；
（d）「已服 / 未服」两段，每段一行节标题 + 一个圆点指示色，下挂 `MedicationStatusCard` / `UpcomingDoseCard` 列表（321-450）；
（e）底部 `QuoteCard` 居中斜体引言（452-461）；
（f）`PetalCelebration.show(context)` 在 completedCount 增加时叠 10 片粉樱花瓣作为庆祝（42-54、petal_celebration.dart）。

## 2. 违规点逐项（按 v2 5 原则）

### 原则 1：一抹强色（黛蓝 ≤ 3 处/屏）

- 现状：通屏使用 `HanaColors.primary`（v1 樱色 `#864E5A` 系），不是 v2 黛蓝。强色出现在：appTitle icon + 文字（today_page.dart:78,88）、日历 icon（97）、问候大标题（124）、头像描边（151）、空态 icon + CTA（235,250）、CountdownCard 整张实色 + 渐变（countdown_card.dart:96 `HanaGradients.countdownOf`）、UpcomingDoseCard tertiary 渐变按钮（upcoming_dose_card.dart:162）、MedicationStatusCard 圆形 icon 容器（medication_status_card.dart:49,55）、QuoteCard 引号 icon（quote_card.dart:30）。
- 违规：① 整套色板就错——v1 樱色 ≠ v2 黛蓝，色 token 必须从 `HanaColors` 切到 `HanaTokens`；② 强色出现远 > 3 处（粗算 9 处+），完全失去"句号"语感；③ CountdownCard 大块面积（>30% 屏宽）日常出现，违反硬规则"大块强色仅限 Onboarding 第 5 屏 / 庆祝时刻"。
- 优先级：P0
- 改动建议：CountdownCard 改为单色 surfaceContainerLowest 段落、问候大标题改墨色 `ink`、整屏只留「记一次」CTA + 未服项左侧 4px 黛蓝竖线 + 底栏 active tab 下划线 = 3 处。

### 原则 2：调和层次胜过投影

- 现状：① SliverAppBar 用 `BackdropFilter blur(12,12)`（today_page.dart:67-72）；② CountdownCard 内部一个 128px blur 圆（countdown_card.dart:121-128）+ `boxShadow blurRadius:32`（98-103）+ 1px white/20% border（97）；③ UpcomingDoseCard 也写了 `BackdropFilter blur(24,24)`（upcoming_dose_card.dart:65）+ `boxShadow blurRadius:16`（164-173）+ 2px tertiary border（43-46）；④ MedicationStatusCard / UpcomingDoseCard 全部 `BorderRadius.circular(16)`，QuoteCard radius 16。
- 违规：v2 严禁 BackdropFilter blur（principles.md §2 硬规则）+ 严禁 elevation > 0 默认 + 严禁 border 当分隔。三处 blur + 两处 boxShadow + 反复出现的 16px 圆角全数违反。
- 优先级：P0
- 改动建议：删除所有 BackdropFilter / BoxShadow / border，AppBar 换 `surfaceContainerHigh` 实底 + 滚动时 1px outline @ 30% 细线，卡片圆角统一收到 4px。

### 原则 3：编辑级不对称（左对齐 32px，避免居中）

- 现状：① 内容水平 padding 是 24px（today_page.dart:107,290,326,367,394,420,455），不是 v2 规定的 32px / token `lg`；② 问候段用 `MainAxisAlignment.spaceBetween` 把头像顶到右上（109）—— 头像与标题同级争重心，违反"一屏一个视觉重心、偏左 30%"；③ QuoteCard 内 `textAlign: TextAlign.center` + `crossAxisAlignment.stretch`（quote_card.dart:26,36）整体居中；④ 章节标题（"已服" / "未服"）后跟一个 6×6 圆点（today_page.dart:341-348,406-413）作为颜色标记，不是 v2 要求的"标题左侧 4px 黛蓝竖线"。
- 违规：水平 padding 错值；头像争重心；QuoteCard 居中；章节标题缺左竖线。
- 优先级：P0（padding + 章节竖线）/ P1（QuoteCard 居中、头像位置）
- 改动建议：水平 padding 全屏改 32px，头像下沉到 Settings 入口或缩到 32px 弱化，章节标题左侧加 4px 黛蓝竖线（仅覆盖首行高），QuoteCard 改左对齐 + 删除斜体。

### 原则 4：慢节奏与留白

- 现状：间距值密集出现 16 / 16（today_page.dart:107 vertical 16 + 172 SizedBox 16；306 SizedBox 32 后接 16 + 16）；卡片之间 `EdgeInsets.only(bottom: 12)`（373,425）—— 12 不在 v2 token 表内（`xs/sm/md/lg/xl/xxl = 4/8/16/32/64/128`，故意跳过 12 / 20）；CountdownCard 内 `SizedBox(height: 16)` 紧挨 `SizedBox(height: 20)`（countdown_card.dart:171,228）—— 20 也是禁用值；顶部从 SliverAppBar 到第一行内容只有 16px（today_page.dart:107），未达 v2 要求"Today 顶部留白 ≥ 64px / xl"。
- 违规：① 间距值非 token（12 / 20）；② 相邻间距未跨级（16 紧挨 16）；③ 顶部留白严重不足。
- 优先级：P1
- 改动建议：列表项间距 12 → 32（lg），顶部空 64px（xl）才出问候，所有非 token 间距按 4/8/16/32/64 替换。

### 原则 5：内容即装饰

- 现状：① `_PetalCelebrationOverlay` 撒 10 片粉/樱粒子（petal_celebration.dart:53、128 `HanaColors.primaryContainer`）—— v2 严禁清单 No.1；② CountdownCard 用 `HanaGradients.countdownOf` 渐变 + 旋转 12° 的 96px `Icons.medication` 装饰（countdown_card.dart:96,131-145）；③ UpcomingDoseCard 用 `HanaGradients.takeDoseOf` 渐变按钮 + 装饰圆（upcoming_dose_card.dart:54-69,162）；④ AppBar 左侧 `Icons.auto_awesome` 闪光 icon（today_page.dart:76）—— 装饰性图标承担情感；⑤ QuoteCard 顶部 `Icons.format_quote` icon + 文本 `fontStyle: italic`（quote_card.dart:29-41）—— 斜体引号 = 装饰；⑥ MedicationStatusCard 已服态用 ✓ 勾（medication_status_card.dart:93-98）—— v2 要求"褪色不打勾"。
- 违规：粒子动画、渐变背景、装饰 icon、斜体、勾选符号——把整套花笺装饰语法都触犯了。
- 优先级：P0（粒子 + 渐变 + 勾）/ P1（装饰 icon + 斜体）
- 改动建议：粒子换 HanaCelebration 一行宋体「今日已记。」；渐变全部删；CountdownCard 改纯文字段落；MedicationStatusCard 已服态改"淡墨竖线 + 淡墨文本"褪色态；删除 auto_awesome、format_quote、italic。

## 3. 7 个评审维度（来自重设计指挥手册模板 B）

### 可用性
核心动作「记一次」（today_page.dart:432-441）位于卡片底部右下 stadium pill 按钮，需先滚到对应未服条目并精准点 32×12 padding 的右对齐按钮。手指流：扫一眼 → 找未服段 → 滚动 → 命中按钮 — 步数合理但热区偏小且偏右下，单手左拇指拉伸不友好。建议改为整张卡片可点 + 卡尾左下「记一次」（左侧动线）。

### 层次
v2 要求 4 级 surface（Lowest / Low / High / Highest）。当前实现：CountdownCard 用渐变 + blur 制造层次（错），状态卡片全部 `surfaceContainerLowestOf(context)`（medication_status_card.dart:37、upcoming_dose_card.dart:41），背景用 `HanaColors.background`（today_page.dart:41）—— 等于只用了 2 级 surface，且层次靠"圆角 + 边框 + 阴影"伪造，不靠纸阶差。完全没实现 v2 层次语法。

### 一致性
与 DESIGN.md 偏差点：① 字体仍用 `'PlusJakartaSans'` 圆润 sans（today_page.dart:85,123、countdown_card.dart:177,191,212）—— v2 要求宋体 Display + Inter Body + JetBrains Mono 数值；② 数值（倒计时小时分钟）未用 mono 字体；③ 圆角 16 / 24 / 999 stadium 全屏出现，v2 token 表只有 0/2/4/6/16(BottomSheet)；④ 颜色 token 仍用 `HanaColors.*Of(context)`（旧 API），未迁到 `HanaTokens`；⑤ 文案 `l10n.takeDose`（"服药"/"服 +"）需迁到 v2 编辑体「记一次」。

### 情感色彩
v2 调性："克制·沉静·不矫情"。当前 today_page 是"温柔守护者"——粉樱主色 + 渐变光晕 + 花瓣粒子 + 闪光 icon + 斜体格言 = v1 花笺典型。`_PetalCelebrationOverlay`（粉色 `primaryContainer` + 樱色 `secondaryContainer` + 1.2s 雨落动画）必须替换为 HanaCelebration「今日已记。」（黑墨宋体 + 0.4s 静默 → 0.6s 淡入 → 0.4s 停留 → 1.2s 淡出，无声）。`HanaColors` 调色板必须整体切到 `HanaTokens`（黛蓝 #1F3A5F / 月白 #F4F1EA / 墨 #1C1A18）。

### 暗色模式
当前 `HanaColors.*Of(context)` 走 Theme brightness 分支，但 `HanaColors.primary`、`HanaColors.background`、`HanaColors.error`、`HanaColors.onSurfaceVariant` 等 6 处使用了非 context-aware 静态常量（today_page.dart:41,62,78,88,97,124,134,210,235,346,411）—— dark mode 下永远是 light 值，会闪白。v2 tokens.md §8.2 明确这是 ban 项。

### i18n
日文 `薬を追加` / `薬を記録` 较中文长 30%-50%。问候段 "$greeting，$displayName"（today_page.dart:117）用 `maxLines: 1 + ellipsis`，姓名稍长（如「ふじわら　あい」）会被吞；CountdownCard 单元 `widget.hourUnitLabel` 后只跟 `SizedBox(width: 12)` 接数字（countdown_card.dart:206-216），日文「時間」"分" 较中文「时」"分" 多一字，宽度容易溢出 Row 触发越界。

### 响应式
完全未处理 ≥768px Web 端布局：内容直接用 `EdgeInsets.symmetric(horizontal: 24)` 撑满宽度（today_page.dart:107,290,326,367,394,420,455），平板 / 桌面会出现单列拉宽到 1200px+ 的"巨字幅"，杂志感反而被破坏。需要 max-width 约束（建议 720px 内文页宽）。

## 4. P0 / P1 / P2 总清单

### P0（违规必改 — 阻塞 v2 落地）
1. 整屏色 token 从 `HanaColors`（v1 樱色）切到 `HanaTokens`（黛蓝 #1F3A5F + 月白 #F4F1EA + 墨 #1C1A18），删除非 context-aware 静态常量调用（today_page.dart:41,62,78,88,97,124,134,210,235,346,411）。
2. 删除所有 BackdropFilter blur（today_page.dart:67-72、countdown_card.dart:121-128、upcoming_dose_card.dart:65-69、countdown_card.dart:243）共 4 处。
3. 删除所有 BoxShadow / border 视觉（countdown_card.dart:97-103、upcoming_dose_card.dart:43-46、164-173），改用 surface 阶差。
4. 删除所有 LinearGradient（CountdownCard 整张渐变、UpcomingDoseCard 按钮渐变 — `HanaGradients.countdownOf` / `takeDoseOf`），改单色。
5. `PetalCelebration.show()`（today_page.dart:53）替换为 `HanaCelebration.show()`「今日已记。」黑墨宋体淡入淡出。
6. MedicationStatusCard 已服态去 ✓ 勾（medication_status_card.dart:83-100），改"淡墨竖线 + 淡墨文本"褪色态。
7. 圆角全部统一到 v2 token：卡片 4 / 按钮 6 / 头像圆形（删除现存 14、15、16、24、999 stadium 五个非法值）。
8. 字体迁到 v2 ramp：标题 Spectral SemiBold / 思源宋体 Medium，body Inter / 思源黑体，数值 JetBrains Mono Light（删除 `'PlusJakartaSans'`：today_page.dart:85,123、countdown_card.dart:177,191,212）。
9. AppBar 装饰 icon `Icons.auto_awesome`（today_page.dart:76）删除——v2 严禁装饰承担情感。

### P1（应当改 — 显著影响 v2 视感）
1. 水平 padding 24 → 32（lg token），全屏 7 处。
2. 章节标题"已服" / "未服"右侧圆点（today_page.dart:341-348,406-413）改为左侧 4px 黛蓝竖线（仅覆盖标题首行高度）。
3. 间距值改为 token：删除 12（today_page.dart:373,425）、20（countdown_card.dart:228）、14（upcoming_dose_card.dart:50）等非 token 值。
4. 相邻间距强制跨级：16 紧挨 16 的位置改为 16 + 32 / 8 + 16。
5. QuoteCard 改左对齐 + 删除 `fontStyle: italic`（quote_card.dart:41）+ 删除 `Icons.format_quote`（29）。
6. 头像位置：从问候段右上角下沉到 Settings 入口，让顶部成为单一视觉重心。
7. 文案"服药"系列迁到 v2 编辑体（"记一次" / "今日宜，按时。" / "本期空白。"）。
8. 顶部留白从 16 → 64（xl token），让 Today 顶部呼吸。

### P2（可改 — 优化项）
1. Web 端 ≥768 加 max-width 720px 内文页宽约束。
2. 「记一次」热区改为整张卡可点 + 文字按钮左下放置，左拇指动线友好。
3. CountdownCard 倒计时数字与单位改 mono 字体（JetBrains Mono Light），与正文 Spectral 区分。
4. error 态 `ElevatedButton`（today_page.dart:212）迁到 `FilledButton` + v2 6px 圆角统一按钮。
5. `flutter analyze` 加 lint 规则禁用 `BackdropFilter` / `BoxShadow` / `LinearGradient` / `HanaColors.*` 静态常量，防回归。

## 5. 既有重复模式映射（来自 widget-pattern-inventory）

- HanaCard variant=summary → 替换 `MedicationStatusCard` / `UpcomingDoseCard` 容器壳（medication_status_card.dart:34-39 / upcoming_dose_card.dart:39-48），删除内联 `Container(decoration: BoxDecoration(color, radius, border))`
- HanaCelebration → 替换 `PetalCelebration.show()`（today_page.dart:53、core/widgets/petal_celebration.dart 整文件）
- HanaEmptyState → 替换今日无药 fallback（today_page.dart:223-256），现内联了 icon + title + FilledButton 三段式
- HanaErrorState → 替换错误态（today_page.dart:203-222），现内联 Text + ElevatedButton
- HanaLoadingView → 替换 initial / loading 态（today_page.dart:191-202）
- HanaTopBar（实色版）→ 替换玻璃 SliverAppBar（today_page.dart:60-103），删 BackdropFilter
- HanaSectionHeader（左竖线版）→ 替换「已服」/「未服」标题 Row（today_page.dart:325-362、395-414），承载 4px 黛蓝竖线语法
- HanaPrimaryButton（v2 6px 圆角）→ 替换 UpcomingDoseCard 内 stadium 按钮（upcoming_dose_card.dart:155-198）
- HanaQuote → 替换 QuoteCard（quote_card.dart 整文件），删除 italic + 引号 icon

## 6. 用户故事影响分析

- 早晨打开第一眼：v1 是粉樱大字 + 闪光 icon + 渐变倒计时卡 + 雨落感（情绪温度高、像偶像周边）；v2 是月白底 + 一行墨色宋体「早安，{name}」+ 大量留白 + 单色 surface 段落 + 黛蓝小竖线（情绪温度低、像翻开新潮文库）。
- 标记已服：v1 stadium 渐变按钮"服药 +"；v2 整张卡轻按 + scale to 0.98 触感反馈，文案改"记一次"句号收尾。
- 庆祝瞬间（变化最大）：v1 屏幕立即撒 10 片粉/樱花瓣随机 wobble 1.2s（卡通感）；v2 屏幕静默 0.4s → 淡入一行黑墨宋体「今日已记。」→ 停留 0.4s → 淡出 1.2s（仪式感来自等待，不是爆发）。
- 滚动浏览：v1 玻璃 AppBar blur 实时模糊背景 + 16-24px 软糖卡 + 12px 紧密间距；v2 实色 AppBar + 滚动时 1px outline 细线 + 4px 卡片直角 + 32px 段落留白（杂志翻页节奏）。

## 7. 阶段 3.1.b 的下一步指示

critique-v1 完成后下一步是出新视觉稿（Flutter widget skeleton 或 Figma frame）。三条具体起手指引：

1. **先建 `lib/app/theme/hana_tokens_v2.dart` + `HanaSemanticColors` ThemeExtension**（tokens.md §8.1 已给完整签名），让 Today 重设计可以直接 `HanaTokens.primary(context)` 单轨调色，避免在视觉稿阶段又写一遍硬编码 hex。
2. **先封 5 个 P0 共享件**（HanaCard / HanaTopBar / HanaSectionHeader / HanaCelebration / HanaPressScale），Today 是第一个吃这套组件的屏，新稿即组件库验证场——别在 today_page.dart 内联画杂志感，会再次形成"feature-local widget"重复债。
3. **画两版起步稿对比**：A 版完全去 CountdownCard（顶部仅"早安 + HRT 第 N 天 + 下一次 12:30 简文"），B 版保留 CountdownCard 但单色化（黛蓝大数字 + 月白底 + 4px 竖线段落标记）。让 CTO 在第一轮就裁掉一半设计空间，避免后续返工。

## 8. 风险与注意

最大风险是"半迁移"——只换色不删 BackdropFilter / 只删粒子不动渐变 / 只改文案不改字体。v2 是一套互锁系统：黛蓝稀缺需要 90% 单色基底支撑，宋体克制需要去掉装饰 icon 才显出，「今日已记。」的重量需要 0.4s 静默支撑。任何一项保留 v1 残留，整套调性会失败回 v1.5 缝合怪。建议 P0 九条作为单一 PR 一次性 merge，不允许拆细 PR 增量上线（增量阶段中间态比 v1 更难看）。i18n 日文长文本和 Web ≥768 响应式可以挪到 P2，但宋体 + JetBrains Mono 字体注入务必同步 Web 端 Google Fonts CDN，否则首屏闪烁会暴露 v2 排版骨架。
