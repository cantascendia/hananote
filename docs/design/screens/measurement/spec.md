# Measurement 主屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/
> 屏幕：`lib/features/measurement/presentation/pages/measurement_page.dart`
> Pilot Wave: 阶段 3.4.b（新稿）+ 3.4.c（自我 critique-v2）
> 配对 handoff：`docs/design/handoff/measurement.md`
> 上游 pattern：timeline/spec.md（按日期分组）+ data/spec.md（mono 数值）+ add-drug/spec.md（表单 / picker 节奏）

---

## 1. 设计意图

Measurement 主屏要从 v1「History List 仪表盘」转向 **「身体的旁注页」**——杂志「读者随访」专栏体例：左对齐宋体小标题 + 单色 mono 数值表 + 一行节制趋势注脚。打开 Measurement，看到的不是健康数据 dashboard，而是「这是一份按月装订的体型笔记」。

v1 把「胸 88　腰 64　臀 90」做成日期标题 + 单行摘要的 Material Card 列表，缺三件事：① 月份章节断点 ② 数值与文字的字体分级 ③ 趋势方向暗示。v2 全部补上：按月切章节（`HanaSectionHeader 2026 · 4 月`） + mono Light 数值 + 紧跟数值右侧的「↑ 0.5cm」inkSecondary 注脚——不染色，不上箭头颜色编码（红绿正负是医疗 dashboard 语法，不是阅读笔记语法）。

调性沿用 v2：第三人称 + 句号收尾 + 零 emoji。Hero「身体记录。」/ 章节「2026 · 4 月」/ 空态「未记录身体数据。」/ 趋势注脚「↑ 0.5cm」(无句号——它是数值附注，不是陈述)。

跨性别敏感性：「胸围 / 下胸围 / 腰围 / 臀围 / 大腿围 / 上臂围 / 肩宽 / 颈围 / 体重」九个术语已经是医学中性表达；保持中性，不改写「乳围」此类敏感词，亦不引入「瘦了 / 胖了」等评判性副词。

---

## 2. 屏幕骨架

### 2.1 默认态（有记录 + 多月份）

```
┌──────────────────────────────────────────┐
│ HanaTopBar.defaultBar · surfaceContainerHigh│  ← 56dp 实色米灰，无 blur
│   "身体" (title 18 · ink 左对齐 16)        │     右侧 ghost +（24dp outlined）
├──────────────────────────────────────────┤
│   (顶部留白 spacing.xl = 64)              │
│                                            │
│   身体记录。                                │  ← display-xl 40·52·-0.5 宋体
│   (Spectral SemiBold / 宋体 Medium · ink)   │     左对齐 spacing.lg=32
│   共 12 期　近一次 4 月 28 日              │  ← body-sm · inkSecondary
│   (mono 数字 + CJK 全角空格)               │
│                                            │
│   (段落间 spacing.lg = 32)                │
│                                            │
│  ┃ 2026 · 4 月                              │  ← HanaSectionHeader（章节断点）
│  ┃ (label 12·+0.6 · inkSecondary)          │     左 4px 黛蓝竖线，覆盖首行 16px
│                                            │
│   (spacing.md = 16)                        │
│                                            │
│   ╭──────────────────────────────────╮     │  ← HanaListItem（含 onTap 跳详情）
│   │ 4 月 28 日　周二              ›   │     │     surfaceContainerLowest
│   │ (title 18 · ink)                  │     │     padding 横 24 / 纵 20
│   │                                   │     │
│   │ 胸围  88.5  cm  ↑ 0.5cm           │     │  ← mono Light 14 数值
│   │ 腰围  64    cm  ↓ 0.3cm           │     │     单位 label-sm Medium
│   │ 臀围  90    cm                    │     │     趋势 body-sm inkSecondary 紧贴
│   │ + 4 项                            │     │  ← body-sm inkSecondary 尾标
│   ╰──────────────────────────────────╯     │
│                                            │
│   (项间 spacing.sm = 8)                   │
│                                            │
│   ╭──────────────────────────────────╮     │
│   │ 4 月 14 日　周一              ›   │     │
│   │                                   │     │
│   │ 胸围  88    cm                    │     │  ← 第一次记录无趋势注脚
│   │ 腰围  64.3  cm                    │     │
│   │ 臀围  90.2  cm                    │     │
│   │ + 5 项                            │     │
│   ╰──────────────────────────────────╯     │
│                                            │
│   (章节间 spacing.xl = 64)                │
│                                            │
│  ┃ 2026 · 3 月                              │
│  ┃                                          │
│   (spacing.md = 16)                        │
│   [更多记录...]                              │
│                                            │
│   (底部 spacing.xl = 64)                   │
│                                            │
│  ┌──────────────────────────────────┐      │
│  │ [ 记一次 ]  HanaButton.primary    │      │  ← sticky bottom CTA
│  │ 6px 圆角 44dp 高 黛蓝实色          │      │     左对齐 32px，非全宽
│  └──────────────────────────────────┘      │
└──────────────────────────────────────────┘
```

### 2.2 详情 / 删除 sheet（点击单条记录）

```
        ───────                           ← drag handle
  ┌──────────────────────────────┐
  │  4 月 28 日　周二             │   ← label 12·+0.6 primary
  │                               │
  │  身体记录                     │   ← headline 24 ink
  │                               │
  │  胸围   88.5  cm   ↑ 0.5cm   │   ← mono 14 + 单位 label + 趋势 body-sm
  │  下胸围 76    cm              │
  │  腰围   64    cm   ↓ 0.3cm   │
  │  臀围   90    cm              │
  │  大腿围 54    cm              │
  │  上臂围 27    cm              │
  │  肩宽   38    cm              │
  │  颈围   33    cm              │
  │  体重   55.2  kg   ↓ 0.4kg   │
  │                               │
  │  备注                         │
  │  早晨空腹。                   │  ← body-sm inkSecondary（若有备注）
  │                               │
  │  [ 编辑 ]    HanaButton.action │
  │  [ 删除 ]    HanaButton.ghost (error 朱砂) │
  └──────────────────────────────┘
```

### 2.3 空态（无任何记录）

```
│   身体记录。                               │  ← Hero 同默认
│   尚未记录                                 │  ← 副行换文案
│                                            │
│   (spacing.xl = 64)                       │
│                                            │
│   [HanaEmptyState · variant=page]          │
│   ⌥ Icon straighten_outlined 32dp          │     ink @ 60%，无圆形容器
│                                            │
│   (spacing.lg = 32)                       │
│                                            │
│   未记录身体数据。                          │  ← headline 24 · ink
│                                            │
│   (spacing.sm = 8)                        │
│                                            │
│   首次记录将开启趋势对比。                  │  ← body-sm · inkSecondary
│                                            │
│   (spacing.lg = 32)                       │
│                                            │
│   [ 记一次 ]  HanaButton.secondary         │  ← 月白底 + 黛蓝 1px 边框
```

### 2.4 错误 / 加载

- 错误 `HanaErrorState`：「载入失败。请下拉刷新。」+ ghost「重试」
- 加载 `HanaLoadingView.block`：单行宋体「读取中。」inkSecondary

---

## 3. 组件映射

| 区域 | v2 组件 | Variant | 关键 props |
|------|--------|---------|-----------|
| 顶部栏 | `HanaTopBar` | `defaultBar` | title=l10n.measurementTabTitle，action=ghost`+` 24dp 跳编辑 |
| Hero「身体记录。」 | (Text) | display-xl 宋体 | 左对齐 spacing.lg |
| 副行 | (Text + mono) | body-sm + mono 数字 | "共 12 期　近一次 4 月 28 日" |
| 月份章节 | `HanaSectionHeader` | default | "2026 · 4 月"，4px 黛蓝竖线 |
| 记录卡（每条 entry）| `HanaListItem` (扩展) | `withSubtitle + custom body` | title=日期+周几，body=top3 mono 数值表 + 趋势注脚，trailing chevron 16dp |
| 趋势注脚 | (Text) | body-sm inkSecondary | 「↑ 0.5cm」/「↓ 0.3cm」紧跟数值右侧 spacing.xs=4 |
| 详情 sheet | `HanaBottomSheet` | `info` | child=9 项 mono 表 + 备注，actions=[编辑 / 删除（朱砂 ghost）] |
| 删除确认 | `HanaConfirmDialog` | destructive | title="删除这次记录？" / primary=「删除」朱砂 / ghost=「保留」 |
| 创建 CTA（默认态）| `HanaButton.primary` | primary | label="记一次。"，sticky bottom，44dp 高，**不**全宽 |
| 创建 CTA（空态）| `HanaButton.secondary` | secondary | 月白底 + 黛蓝 1px 边框 |
| 空态 | `HanaEmptyState` | page | icon=straighten_outlined, title="未记录身体数据。", message="首次记录将开启趋势对比。" |
| 错误 | `HanaErrorState` | default | + ghost「重试」 |
| 加载 | `HanaLoadingView` | block | 「读取中。」 |

> **明确删除**：v1 `FloatingActionButton.extended` (L39-43)、AppBar `Icons.add` (L33-37)、`_MeasurementHistoryCard` Material `Card` 阴影 (L143)、卡内 `IconButton(Icons.delete_outline)` (L194-224)、`AlertDialog` 标准 Material 删除确认 (L198-216)、`_MeasurementEmptyState` 120dp 圆形容器 + 56dp icon (L100-112)。

---

## 4. Tokens 引用清单

### 颜色

| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| 记录卡 | `HanaTokens.surfaceContainerLowest(context)` |
| AppBar 米灰 | `HanaTokens.surfaceContainerHigh(context)` |
| Hero / 卡内日期 / mono 数值 | `HanaTokens.ink(context)` |
| 副行 / 趋势注脚 / "+ N 项" 尾标 | `HanaTokens.inkSecondary(context)` |
| 章节竖线 / sticky CTA 实色 | `HanaTokens.primary(context)` |
| CTA 文字 | `HanaTokens.onPrimary(context)` |
| 删除按钮（朱砂 ghost）| `HanaTokens.error(context)` |

> 黛蓝可见点：① 章节竖线（每月一处段落标记，**章节竖线被视为段落延伸算 1 处**）② sticky 「记一次。」CTA 实色 ③ 详情 sheet 内 label「4 月 28 日」inline label primary（仅 sheet 内可见，不与主屏同屏）。**主屏稳态 ≤ 2 处**，符合原则 1。
> 趋势注脚 `↑ / ↓ ` 一律 `inkSecondary` —— **不**走色编码（不染苔色 / 朱砂）；方向语义全靠箭头字符 + 单位附注。

### 间距

| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `spacing.lg` = 32 |
| Hero 顶部留白 | `spacing.xl` = 64 |
| Hero ↔ 首章节 | `spacing.lg` = 32 |
| 章节标记 ↔ 首张卡 | `spacing.md` = 16 |
| 卡间（同章节）| `spacing.sm` = 8（连续记录视觉密集，故用 sm；与 timeline 卡间 lg=32 区别——measurement 是「同月小幅日变化」，节奏更密）|
| 章节间（月份切换）| `spacing.xl` = 64 |
| 卡内 horizontal padding | 24（沿用 HanaListItem 规范）|
| 卡内 vertical padding | 20 |
| 日期 ↔ mono 数值表 | `spacing.sm` = 8 |
| mono 数值行内（项 ↔ 项）| 4（行高内自然分行）|
| 数值 ↔ 单位 | `spacing.xs` = 4 |
| 数值 ↔ 趋势注脚 | `spacing.sm` = 8 |
| 底部 sticky CTA 上下 | `spacing.lg` = 32 + SafeArea |

> 强制跨级：sm(8) → md(16) → lg(32) → xl(64) 四档。卡间 sm + 章节间 xl 拉开节奏对比。

### 圆角

| 用途 | Token |
|------|-------|
| 记录卡 | `radius.card` = 4 |
| 按钮 | `radius.button` = 6 |
| Bottom Sheet 顶角 | 16（硬常量） |

### 字体

| 用途 | Token / 字体 |
|------|------------|
| Hero「身体记录。」 | `display-xl` Spectral SemiBold / 宋体 Medium |
| 章节标记「2026 · 4 月」 | `label` 12·+0.6 Medium 思源黑体 |
| 卡内日期「4 月 28 日　周二」 | `title` 18 Regular |
| 测量项名（胸围 / 腰围 / ...） | `body` 15 Regular Inter / 思源黑体 |
| **mono 数值** | `mono` 14 JetBrains Mono Light **强约束** |
| 单位（cm / kg）| `label` 12 Medium，紧贴数值右 spacing.xs=4 |
| 趋势注脚（↑ 0.5cm）| `body-sm` 13 inkSecondary，紧贴单位右 spacing.sm=8 |
| 「+ N 项」尾标 | `body-sm` inkSecondary |
| 备注 | `body-sm` inkSecondary（详情 sheet 内）|
| sticky CTA | `body` Medium |

### 动画

| 时机 | 时长 / 曲线 | Token |
|------|------------|-------|
| 卡片 press scale 0.98 | 150ms easeOut | `motion.quick` |
| 首屏卡片 fadeIn 错落 | 240ms × N，错落 60ms | `motion.standard` |
| AppBar 滚动底线淡入 | 80ms easeOut | `motion.instant` |
| BottomSheet 升起 / 关闭 | 240ms easeInOut | `motion.standard` |
| 月份 sticky 章节切换 | 240ms easeInOut | `motion.standard` |
| 删除确认 dialog 升起 | 240ms easeInOut | `motion.standard` |

**绝对禁止**：粒子动画、scale > 1 弹跳、卡片从底部 slide up、趋势数字 count-up 数字滚动效果（杂志注脚不动）。

---

## 5. 趋势注脚算法

> 关键设计决策：方向暗示 ≠ 颜色编码

每张记录卡只在 **top 3 显示项**右侧显示趋势注脚，并满足下列约束：

1. **方向计算**：取该测量项**上一次有值**的记录（不必是上一条记录——可能是 3 月 14 日），计算 `delta = current - previous`。
2. **阈值过滤**：`|delta| < 0.1`（cm/kg）→ **不显示**注脚（噪声级波动）；`|delta| < 0.2` → 显示「持平」（body-sm inkSecondary，无箭头）；其他 → 显示「↑ {|delta|}{unit}」或「↓ {|delta|}{unit}」（保留 1 位小数）。
3. **首次记录**：无 `previous` → **不显示**注脚（不放「初次」此类提示，留白即说明）。
4. **颜色规则**：永远 `inkSecondary`——**不染苔色 / 朱砂**。原因：
   - 「腰围 ↓」对一些用户是好事，对另一些用户是坏事——measurement 不能预设方向意义。
   - 颜色编码是 dashboard 语法；v2 是阅读笔记，留给用户自己解释。
5. **箭头字符**：使用 Unicode `↑ U+2191` / `↓ U+2193`（不用 emoji ⬆⬇，避免原则 5 违规）。
6. **i18n**：注脚文本「↑ 0.5cm」/「↓ 0.3kg」/「持平」 → ARB key `measurement.trendUp` / `measurement.trendDown` / `measurement.trendFlat`，with placeholder `{value}` `{unit}`。

> **「+ N 项」尾标**：卡片只显示用户实际填写的前 3 项 + trend；剩余项数显示「+ {n} 项」，inkSecondary，紧贴最后一项数值下方 spacing.xs=4。点击整张卡进 detail sheet 看完整 9 项。

---

## 6. 交互状态

### 默认装载完成
- AppBar 实色米灰，offset=0 时无底线
- Hero / 章节 / 卡片同时入场：fadeIn 240ms 错落 60ms
- sticky CTA 始终可见

### 卡片按下
- `HanaListItem` 启用 `HanaPressScale` → 0.98 / motion-quick
- onTap → `HanaBottomSheet.info` 详情面板（参见 §2.2）

### 详情 sheet
- 点击「编辑」→ sheet 关闭 + `context.push('/measurement/edit', extra: entry)`
- 点击「删除」→ sheet 关闭 + `HanaConfirmDialog`「删除这次记录？」→ 确认 → bloc.delete

### sticky CTA「记一次。」
- 始终 fixed 在 SafeArea 上方 spacing.lg
- onTap → `context.push('/measurement/edit')`（无 extra = 新建）

### 月份章节 sticky 切换
- 用 `SliverPersistentHeader` 让月份 label 在视窗顶吸附
- 滚动到下一月时上一月标签上滑离场，新月滑入（240ms easeInOut）
- sticky 高度 = 24dp（label line-height 16 + padding sm 上下各 4）

### 下拉刷新
- 沿用 `HanaPullRefresh`（如未实施则保留系统默认 + indicator 颜色锁定 primary）

### 错误重试
- `HanaErrorState` 中 ghost 按钮触发 `bloc.add(LoadHistory())`

---

## 7. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，水平 padding 32 |
| 768–1024 (tablet) | 单列 max-width 720，居中 |
| ≥ 1024 (web 桌面) | 双列：左 720 主时间序列 / 右 320 「全部 9 项变化曲线」浮岛（mini line chart × 9，复用 data 屏 §5 印刷品折线图规范）|

> mobile 主战场。tablet/web 仅约束 max-width。Web 桌面浮岛可作为 R6 后置增强项。

---

## 8. i18n 注意

- 9 项测量术语必须 ARB key：`measurementType.bust` / `underbust` / `waist` / `hip` / `thigh` / `bicep` / `shoulder` / `neck` / `weight`——DEC-042/043 合规迁移（删除 enum 内中文 displayName）。
- ja「胸まわり」比 zh「胸围」长 ~50%——卡内 mono 数值表用 `Wrap` + 固定列宽 96px 容纳长 label。
- 月份章节：zh「2026 · 4 月」/ ja「2026 · 4月」/ en「Apr 2026」——格式器走 `DateFormat.yMMM(localeName)` + 自定义点分隔。
- 日期标题：`DateFormat.yMMMEEEEd(localeName)` 自动加周几。
- 趋势文案：`measurement.trendUp` "↑ {value}{unit}" / `trendDown` "↓ {value}{unit}" / `trendFlat` "持平"——单位不本地化（cm/kg 国际通用）。
- Hero 副行：「共 {n} 期　近一次 {date}」三语对齐（zh 全角空格 / ja 全角空格 / en 用 `,`）。

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — 卡片整张 ≥ 64dp（minHeight 48 + padding 20×2），sticky CTA 44dp，AppBar action 44dp |
| Semantics 语义单元 | ✓ — 每张卡 `Semantics(button: true, label: "{date} 周二　胸围 88.5 厘米　上升 0.5 厘米　腰围 64 厘米　下降 0.3 厘米　共 7 项")` |
| 月份章节 | `Semantics(header: true, headerLevel: 2, label: "2026 4 月")` |
| 趋势箭头 | screen reader 朗读"上升" / "下降"，不读 "↑" 字符（用 `Semantics(label: "上升")` 替代） |
| 焦点顺序 | AppBar action → Hero → 章节 → 该章节卡片 → 下一章节 → 起点 → sticky CTA |
| prefers-reduced-motion | ✓ — 卡片入场跳过 fadeIn；章节 sticky 走 instant；BottomSheet 直接 jump-cut |
| 对比度（light）| ✓ — ink 14.8:1 / inkSecondary 7.2:1（趋势注脚仍可读）|
| 对比度（dark）| ✓ — 12.6:1 |

---

## 10. 自我 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处） | ✓ | 主屏稳态 2 处：① 章节竖线（段落延伸视为 1 处）② sticky CTA。详情 sheet 升起后另算。趋势注脚 inkSecondary 不计入。 |
| 2. 调和层次胜过投影 | ✓ | surface 3 级：background → containerLowest 卡 → containerHigh AppBar。零 BoxShadow / 零 BackdropFilter / 零 border。 |
| 3. 编辑级不对称 | ✓ | Hero 左对齐 32px。卡片 horizontal padding 24 偏向左侧权重。CTA 左对齐不全宽。月份章节左对齐。 |
| 4. 慢节奏与留白 | ✓ | 顶 64 + 章节间 64 + 卡内段 8 + 卡间 8 + 章节标 ↔ 首卡 16，跨级合规。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零装饰图标（删 straighten / add / delete icon）；趋势用 ↑↓ 字符 + 单色文字承担方向。删除藏 detail sheet 不抢主屏视觉。 |

**自审遗留风险**：
- 卡间用 `spacing.sm = 8` 偏紧密——v2 节奏原则更倾向 lg=32。决策：measurement 是「同月小幅波动连读」体例，密集 8px 是杂志「日记每日 stub」节奏；与 timeline 主体「跨类型事件流」用 lg=32 区分语义。如 PR review 认为破坏节奏，回退方案是改 `spacing.md=16`，以 sm 仅在「同周连续记录」时使用。
- 趋势注脚紧贴数值右侧——窄屏（< 360dp）可能折行。决策：允许折行（注脚自然落到下一行 inkSecondary 缩进 spacing.xs），不强行截断。
- 「+ N 项」尾标本质是 affordance 暗示，可能让用户以为「项数越多越值钱」。决策：保留，但在 ARB 文案换成中性陈述「+ N 项」（不是「+ N 项已记」），让用户保持中立解读。

---

## 11. 与 critique-v1 的 P0/P1 逐项消除

| critique-v1 项 | v2 处理 |
|---------------|--------|
| #1 FAB extended primary 实色 stadium | 删除 FAB，改 sticky `HanaButton.primary` 6px 圆角左对齐 32px |
| #2 AppBar 右侧 Icons.add | 删除（一屏一入口）|
| #3 空态 120dp 圆形 secondaryContainer + 56dp icon | 改 `HanaEmptyState.page` 32dp outlined ink @ 60% + 单行宋体 |
| #4 `Card` 默认 elevation | `HanaListItem` elev-0 + radius 4 |
| #5 AppBar `HanaColors.surface` | `HanaTopBar.defaultBar` surfaceContainerHigh 实底 + 滚动 0.5px outline |
| #6 AppBar 标题居中 | 左对齐 spacing.lg=32 |
| #7 无 hero 段 | display-xl「身体记录。」+ body-sm 副行 |
| #8 卡内 IconButton 删除按钮抢右端 | 删除按钮迁移到 detail sheet（含确认 dialog） |
| #9 padding 12 / separator 12 不在 token | 全改 token：水平 32 / 卡间 8 / 章节间 64 |
| #10 无月份分组 | `HanaSectionHeader` + sticky 月份切换 |
| #11 三处装饰图标 | 全删，文字承担入口语义 |
| #12 数值无 mono | 全改 JetBrains Mono Light + 单位 label-sm + 趋势 body-sm inkSecondary |
| #13 `measurementRecorded` 散乱 fallback | 文案统一句号收尾 + ARB 三语对齐 |
| A. enum 中文 displayName 在 domain | 迁 `enum_l10n.dart` `localizedName(l10n)` |
| D. 摘要 fallback 逻辑分散 | top 3 实际填写顺序 + trend +「+ N 项」尾标 |
| E. Material AlertDialog 删除确认 | `HanaConfirmDialog` 朱砂 destructive |
| F. 空态无 CTA | `HanaButton.secondary`「记一次」 |

— 完 —
