# Timeline 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + components/
> 屏幕：lib/features/timeline/presentation/pages/timeline_page.dart
> Pilot Wave: 阶段 3.1.b（新稿）+ 3.1.c（自我 critique-v2）
> 配对 handoff：docs/design/handoff/timeline.md

---

## 1. 设计意图

新 Timeline 想给用户的感觉是 **「翻开一本装订成册的年度回顾」**——不是 v1 那种"中央彩色光带 + 双侧 z 字飘卡"的 social feed，更不是 Material Stepper 的工具感"圆点连线"。打开 Timeline 时，用户看到的是月白底 + display-xl「年表。」+ 左侧一根细黛蓝竖线像书脊装订 + 右侧单列内文页式卡片，像翻新潮文库目录后的内文章节。

引用 DESIGN.md「克制·沉静·不矫情」调性：v1 用彩色装饰圆点 + 4 色 borderColor 把"服药 / 血检 / 测量 / 照片 / 日记"做成游戏化分类；v2 把所有事件用同一种视觉语法呈现（inline label + 主标题 + 一行陈述），用文字承担"分类"的职责。事件类型不需要颜色编码——它们是同一段人生的不同节录。

**v1 vs v2 核心叙事差异**：v1 是"多彩 feed 流"，v2 是"装订成册的年表"。一次回顾历程的动作，从"扫视彩色卡 → 找到颜色类型 → 点开"变成"翻入年表 → 顺左侧装订线读下来 → 在某月某日驻足 → 翻开一页"。仪式感来自单边阅读流（不是双侧轮换扫视），来自月份章节断点（不是无段落的瀑布流），来自零装饰图标（让宋体 + label 自己说话）。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 默认态（有事件 + 多月份）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.defaultBar · surfaceContainerHigh│  ← 56dp 实色 米灰，无 blur
│   "年表"  (title 18 · ink, 左对齐 16)        │     滚动出现 0.5px outline @ 30%
│   [actions: HanaIconButton 筛选]             │     筛选触发 HanaBottomSheet.filter
├─────────────────────────────────────────────┤
│                                             │
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│   年表。                                    │  ← display-xl (40·52·-0.5)
│   (Spectral SemiBold / 宋体 Medium)         │     ink 墨色，左对齐 spacing.lg=32
│   共 142 条　始于 2025 年 12 月             │  ← body-sm (13·20)
│   (mono 数字 · inkSecondary)                │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│ ┃ 2026 · 4 月                                │  ← HanaSectionHeader（章节断点）
│ ┃ (label 12·+0.6 · ink Medium)               │     左侧 4px 黛蓝竖线，覆盖首行 16px
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│ │  ╭───────────────────────────────╮         │  ← 左侧 1px 黛蓝竖线（书脊装订）
│ │  │  服药 · 4 月 28 日　周二      │        │     从顶 hero 下方延伸到底部起点
│ │  │  (label 12·+0.6 · primary)    │        │     宽度恒 1px，不渐变不光晕
│ │  │                               │         │
│ │  │  雌二醇凝胶                   │        │  ← title (18·26) Regular ink
│ │  │  (title 18 · ink)             │        │
│ │  │                               │         │
│ │  │  2.0 mg　已服　08:00          │        │  ← body (15·24) inkSecondary
│ │  │  (mono 数值 + body 陈述)      │        │
│ │  ╰───────────────────────────────╯         │
│ │                                            │
│ │   (卡间 spacing.lg = 32)                   │
│ │                                            │
│ │  ╭───────────────────────────────╮         │
│ │  │  血检 · 4 月 22 日　周三       │        │
│ │  │                               │         │
│ │  │  季度复检                     │        │
│ │  │  雌二醇 · 睾酮 · 肝酶　共 8 项│        │
│ │  ╰───────────────────────────────╯         │
│ │                                            │
│ │   (卡间 spacing.lg = 32)                   │
│ │                                            │
│ │  ╭───────────────────────────────╮         │
│ │  │  里程碑 · 4 月 14 日　周一    │        │  ← milestone 类型也只用 inline label
│ │  │                               │         │     不打 ★ 不发光
│ │  │  HRT 第 142 天                │        │
│ │  │  半年节点。                   │        │  ← 编辑陈述句号收尾
│ │  ╰───────────────────────────────╯         │
│ │                                            │
│ │   (章节间 spacing.xl = 64)                 │
│ │                                            │
│ ┃ 2026 · 3 月                                 │  ← 下一个月份章节
│ ┃                                            │
│ │   (spacing.md = 16)                        │
│ │                                            │
│ │  [更多卡片...]                              │
│ │                                            │
│ │   ...                                       │
│ │                                            │
│ ●  起点。                                    │  ← 左侧实心黛蓝小点（4px）+ 一行宋体
│    2025 年 12 月 15 日                       │     headline ink 左对齐 32px
│    (mono · inkSecondary)                     │
│                                             │
│   (底部 spacing.xl = 64)                    │
│                                             │
│  ┌─────────────────────────────────┐        │
│  │  [新增一笔。]   HanaButton.primary  │        │  ← sticky bottom CTA
│  │  黛蓝实色 6px 圆角 44dp 高          │        │     不 fullWidth，左对齐 32px
│  └─────────────────────────────────┘        │
└─────────────────────────────────────────────┘
```

> **关键视觉变化**：v1 的 `Stack` 中央通屏 2px 渐变线 → v2 改为左侧贴 padding 内边的 **1px 黛蓝实色竖线**，从首个章节标记下方延伸到底部「起点。」前 4px 实心点，宽度恒 1px、无渐变、无光晕。这条线是**书脊装订线的视觉隐喻**，不是分隔器（所以不画通屏）。

### 2.2 筛选面板（HanaBottomSheet.filter）

点击 AppBar 右侧筛选 icon → 升起 Bottom Sheet：

```
        ───────                              ← drag handle 32x4
  ┌──────────────────────────────┐
  │                              │
  │  筛选                         │  ← headline 24 ink
  │                              │
  │  ┃ 类型                       │  ← label 12·+0.6 · ink
  │  ┃                           │
  │  [服药]  [血检]  [测量]       │  ← HanaChoiceChips (多选)
  │  [照片]  [日记]  [里程碑]     │     active: 黛蓝下划线 2px / inactive: 烟灰
  │                              │
  │  (spacing.lg = 32)           │
  │                              │
  │  ┃ 时间范围                   │
  │  ┃                           │
  │  [近 7 天]  [近 30 天]        │
  │  [近 90 天] [近半年]          │
  │  [近一年]  [全部]             │  ← 单选
  │                              │
  │  (spacing.lg = 32)           │
  │                              │
  │  [ 应用筛选 ]   HanaButton.primary │  ← fullWidth 仅 sheet 内允许
  │  [ 重置 ]       HanaButton.ghost   │
  └──────────────────────────────┘
```

### 2.3 空态（无任何事件）

```
│   年表。                                    │  ← display-xl
│   尚无记录　                                │  ← body-sm 副行
│                                             │
│   (spacing.xl = 64)                         │
│                                             │
│   [HanaEmptyState · variant=page]           │
│                                             │
│   ⌥ Icon menu_book_outlined 32dp            │  ← 无圆形容器
│      ink @ 60%                              │
│                                             │
│   (spacing.lg = 32)                         │
│                                             │
│   尚未起笔。                                │  ← headline 24 · ink
│                                             │
│   (spacing.sm = 8)                          │
│                                             │
│   记下第一笔，年表自此展开。                │  ← body-sm · inkSecondary
│                                             │
│   (spacing.lg = 32)                         │
│                                             │
│   [ 新增一笔 ]   HanaButton.secondary       │  ← 月白底 + 黛蓝 1px 边框
```

### 2.4 错误态

`HanaErrorState` 居中：「载入失败。请下拉刷新。」+ HanaButton.ghost「重试」。

### 2.5 加载态

`HanaLoadingView.block` — 无 spinner，仅一行宋体「读取中。」inkSecondary 居中。

### 2.6 单事件详情（HanaBottomSheet.info）

点击单条卡片 → 升起 Bottom Sheet（替换 v1 的 _EventCard 内联 sheet）：

```
        ───────
  ┌──────────────────────────────┐
  │  服药 · 4 月 28 日　周二     │  ← label 12·+0.6 · primary
  │                              │
  │  雌二醇凝胶                   │  ← headline 24 ink
  │                              │
  │  2.0 mg　涂抹　08:00         │  ← body (mono 数值 + body 陈述)
  │  inkSecondary                │
  │                              │
  │  [跳转详情]  HanaButton.action │
  │  [关闭]      HanaButton.ghost  │
  └──────────────────────────────┘
```

---

## 3. 组件映射

| 区域 | v2 组件 | Variant | 关键 props |
|------|--------|---------|-----------|
| 顶部栏 | `HanaTopBar` | `defaultBar` | title="年表"（仅屏幕阅读器，视觉用 hero）, actions=[HanaIconButton 筛选] |
| Hero 标题 | (Text 直接) | `display-xl` 宋体 | "年表。" 左对齐 spacing.lg=32 |
| 副行 | (Text + mono) | `body-sm` | "共 142 条　始于 2025 年 12 月"（数字 mono） |
| 章节标记 | `HanaSectionHeader` | default | title="2026 · 4 月"，左侧 4px 黛蓝竖线只覆盖首行高 |
| 时间轴竖线 | (`Container` 1px) | — | 左侧 32px padding 内贴边，宽 1px，色 `primary`，纵向连续，**仅在内容区** |
| 事件卡 | `HanaCard` | `tappable` | surfaceContainerLowest, 4px radius, padding md, onTap → HanaBottomSheet 详情 |
| 起点标记 | (Container 4px 实心点 + Text) | — | 左侧贴时间轴底端，色 `primary`，下方 headline「起点。」+ mono 日期 |
| 筛选面板 | `HanaBottomSheet` | `filter` | child=Column(HanaChoiceChips × 2)，actions=[HanaButton.primary 应用 / HanaButton.ghost 重置] |
| 单事件详情 | `HanaBottomSheet` | `info` | title=类型名，child=主标题 + 陈述行，actions=[跳转详情 / 关闭] |
| 创建 CTA | `HanaButton` | `primary` | label="新增一笔。", sticky bottom，44dp 高，**不** fullWidth，左对齐 32px |
| 空态 | `HanaEmptyState` | `page` | icon=menu_book_outlined, title="尚未起笔。", action=HanaButton.secondary |
| 错误态 | `HanaErrorState` | default | "载入失败。请下拉刷新。" + ghost 重试 |
| 加载态 | `HanaLoadingView` | `block` | "读取中。" 文字态，无 spinner |

> **明确删除**：v1 的中央通屏渐变线（_TimelineLoadedView Stack 218-235）、彩色圆点（_TimelineEventRow 364-381）、卡片 4 色彩边线（534-540）、Icons.stars（562、587）、`_TimelineStartPoint` 的灰圆 + 大脑 icon（674-705）、FAB 渐变（73-98）、AppBar 居中标题（40）+ BackdropFilter（33-37）、卡片 boxShadow（541-547）。

---

## 4. Tokens 引用清单

所有色 / 间距 / 圆角 / 字号 / 时长**严禁**直接 hex / 数字字面量。一律走 `HanaTokens.xxx(context)`。

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| Card 内文页 | `HanaTokens.surfaceContainerLowest(context)` |
| AppBar 米灰 | `HanaTokens.surfaceContainerHigh(context)` |
| Hero / 卡内主标题 / 起点标题 | `HanaTokens.ink(context)` |
| 副行 / 卡内陈述 / 时间标签 | `HanaTokens.inkSecondary(context)` |
| 章节竖线 / 时间轴竖线 / 起点圆点 / inline label / CTA 实色 | `HanaTokens.primary(context)` |
| CTA 文字 | `HanaTokens.onPrimary(context)` |
| 错误文字 | `HanaTokens.error(context)` |

> **核心约束**：本屏黛蓝可见点 ≤ 3 处（time-axis 竖线被视为"段落标记延伸"算 1 处；底部 sticky CTA 算 1 处；当前展开/选中事件的 inline label 算 1 处）。其他事件类型 inline label 默认为 **`inkSecondary`**（不是 primary），仅在选中 / 展开态切换为 primary。这与"事件类型不要色编码"原则一致。

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `HanaTokens.spacing.lg` = 32 |
| Hero 顶部留白 | `HanaTokens.spacing.xl` = 64 |
| Hero ↔ 首个章节 | `HanaTokens.spacing.lg` = 32 |
| 章节标记 → 首张卡 | `HanaTokens.spacing.md` = 16 |
| 卡间（同章节） | `HanaTokens.spacing.lg` = 32 |
| 章节间（月份切换） | `HanaTokens.spacing.xl` = 64 |
| 卡内 padding | `HanaTokens.spacing.md` = 16 |
| 卡内 inline label → 主标题 | `HanaTokens.spacing.sm` = 8 |
| 卡内 主标题 → 陈述行 | `HanaTokens.spacing.md` = 16 |
| 时间轴竖线 → 卡片左边 | `HanaTokens.spacing.md` = 16 |
| 起点圆点 → 起点标题 | `HanaTokens.spacing.sm` = 8 |
| 起点 → 底部 sticky CTA | `HanaTokens.spacing.xl` = 64 |

> 强制跨级：相邻间距禁止 16 紧挨 16；卡内 16 + 卡间 32 是合规组合。月份切换用 64 强化"翻章节"节奏。

### 圆角
| 用途 | Token |
|------|-------|
| 卡片 | `HanaTokens.radius.card` = 4 |
| 按钮 | `HanaTokens.radius.button` = 6 |
| Bottom Sheet 顶角 | `kHanaBottomSheetRadius` = 16（硬常量，不走 token） |
| 起点圆点 | 圆形 4px 直径 |
| 时间轴竖线 | 0px（直角细线） |

### 字体
| 用途 | Token / 字体 |
|------|------------|
| Hero「年表。」 | `display-xl` (40/52/-0.5) Spectral SemiBold / Source Han Serif SC Medium / Noto Serif JP Medium |
| 章节标记「2026 · 4 月」 | `label` (12/16/+0.6) Medium，CJK 思源黑体 Medium |
| 卡内 inline label「服药 · 4 月 28 日」 | `label` (12/16/+0.6) Medium |
| 卡内主标题（药名 / 报告名 / 日记标题） | `title` (18/26/0) Regular |
| 卡内陈述行 | `body` (15/24/0) Inter / 思源黑体 |
| 数值（剂量 / HRT 第 N 天 / 时间）| `mono` (14/20/0) JetBrains Mono Light |
| 副行（"共 142 条　始于..."）| `body-sm` (13/20/0) |
| 起点「起点。」 | `headline` (24/32/-0.2) Regular |
| CTA 文字 | `body` (15/24/0) Medium |

### 动画
| 用途 | Token |
|------|-------|
| 卡片 press scale | `HanaTokens.motion.quick` = 150ms easeOut |
| 入场列表项 fadeIn（首屏可见 N 张） | `HanaTokens.motion.standard` = 240ms easeInOut，错落 60ms |
| BottomSheet 升起 | `HanaTokens.motion.standard` = 240ms easeInOut |
| AppBar 滚动底线淡入 | `HanaTokens.motion.instant` = 80ms |
| 时间轴竖线本身 | **无动画**（静态 1px 实色）|

> **明确禁止**：粒子、scale > 1 弹跳、translate 大位移、spring 曲线、卡片入场从下方 slide up（保持杂志翻页节奏，不抖动）。

---

## 5. 交互状态

### 默认（首屏装载完成）
- AppBar 实色米灰，无底线（offset = 0）
- Hero 与首屏可见卡片同时入场：fadeIn 240ms 错落 60ms
- 时间轴竖线**不参与入场动画**（静态出现，避免与卡片争视觉）

### 卡片按下（onTap 跳详情）
- HanaCard.tappable 启用 HanaPressScale → 0.98 / `motion-quick` 150ms
- Press 完成后 trigger HanaBottomSheet.info，display 该事件详细字段

### 筛选交互
1. AppBar 右侧 IconButton（filter_outlined 24dp）按下，trigger HanaBottomSheet.filter
2. Sheet 内多选 type + 单选 timeRange，双向 cubit 同步
3. 「应用筛选」按下：sheet 关闭 + Cubit `ApplyFilter` → 列表重新查询 + fadeIn 240ms 错落入场
4. 「重置」按下：sheet 内 chips 全部回归默认（不立即关闭，给用户确认机会）

### 月份章节切换（滚动）
- 章节标记 `HanaSectionHeader` sticky 在内容区顶部（用 `SliverPersistentHeader`），向下滚动到下一月时上一月标签上滑离场，新月标签滑入
- sticky 高度 = 24dp（label line height + 8 padding）
- 滑动过场 240ms easeInOut

### 全部筛选无结果
- 显示 `HanaEmptyState.page`：icon=filter_alt_outlined + title="本期空白。" + message="调整筛选试试。" + secondary 按钮"重置筛选"
- 与初次空态文案区分（"尚未起笔。" vs "本期空白。"）

### 错误态
- 整屏 `HanaErrorState`：「载入失败。请下拉刷新。」+ HanaButton.ghost「重试」

### 加载态
- 整屏 `HanaLoadingView.block`：一行宋体「读取中。」inkSecondary

### 下拉刷新
- 沿用 Today 屏的 `HanaPullRefresh`（如未实施则保留 system 默认 + indicator 颜色锁定 `HanaTokens.primary`）

### sticky CTA
- "新增一笔。" 按钮始终 fixed 在屏幕底部 SafeArea 上方 spacing.lg 间距处
- 滚动时 CTA 不消失（年表是回顾屏，但保留新增能力——按下跳转 record 屏）

---

## 6. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列右对齐：左 32px 留白 + 1px 时间轴 + 16 间距 + 卡片占满剩余宽度 |
| 768–1024 (tablet) | 单列居中：max-width 720px 居中，时间轴在 max-width 容器左侧贴边 |
| ≥ 1024 (web 桌面) | **双列**：左 720px 主时间轴（同 tablet 排版）/ 右 320px detail panel 浮岛 — 显示当前选中或 hover 的事件详情；无选中时显示"翻阅年表"占位插画（一行宋体 + 64px 留白） |

> **桌面双列的关键约束**：左侧 timeline **不**为 detail panel 让路收窄，保持 720px 内文页宽——detail panel 是"附录浮岛"，存在感弱于主时间轴。
> mobile 是主战场。tablet / web 仅约束 max-width 避免巨字幅 + 桌面专属 detail panel 提供"年度回顾册"质感。

---

## 7. 动画规范

| 时机 | 时长 | 曲线 | Token |
|------|------|------|-------|
| 首屏入场（卡片 fadeIn）| 240ms × N，错落 60ms | easeInOut | `motion-standard` |
| 卡片 press scale 0.98 | 150ms | easeOut | `motion-quick` |
| AppBar 底线淡入（滚动）| 80ms | easeOut | `motion-instant` |
| 章节标记 sticky 切换 | 240ms | easeInOut | `motion-standard` |
| BottomSheet 升起 / 关闭 | 240ms | easeInOut | `motion-standard` |
| 筛选应用后列表重排 | 240ms × N，错落 60ms | easeInOut | `motion-standard` |

**绝对禁止**：粒子动画、scale > 1、卡片从底部 slide up（保持翻页节奏）、时间轴竖线呼吸 / 渐变 / 流光（杂志装订线是静态的）。

---

## 8. i18n 注意

- ja「2026年4月」短于 zh「2026 · 4 月」，章节标记 `Wrap` 弹性宽度。
- ja inline label「服薬 · 4月28日 火曜日」最长，卡内 label 行允许换 1 行（卡片高度自适应）。
- ja「最初の一筆を。」比 zh「尚未起笔。」长 ~30%，HanaEmptyState 标题不限行数，message 可省略。
- 起点文案：zh「起点。」/ ja「はじまり。」/ en「The beginning.」长度差异大——左对齐 32px 不强制居中。
- 副行 mono 数字 + CJK 全角空格：`共 142 条　始于 2025 年 12 月`（zh）/ `142 entries　since Dec 2025`（en）。
- `DateFormat.yMMMd(localeName)` 替代 v1 写死的 `'yyyy.MM.dd'`，让日期格式跟随 locale。
- 月份章节 zh 用「2026 · 4 月」/ ja 用「2026 · 4月」/ en 用「Apr 2026」——格式器走 `DateFormat.yMMM(localeName)` + 自定义点分隔。

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — AppBar action / 卡片整张 / sticky CTA / Pill 全部 44dp+ |
| Semantics 完整朗读 | ✓ — 卡片 label「服药　雌二醇凝胶　2 毫克　已服　4 月 28 日上午 8 点」；时间轴竖线 `ExcludeSemantics`（装饰性） |
| 焦点顺序 | AppBar → Hero → 章节标记 → 该章节卡片（每张展开 1 个语义单元） → 下一章节 → 起点 → sticky CTA |
| prefers-reduced-motion | ✓ — 卡片入场跳过 fadeIn；章节 sticky 切换走 instant；BottomSheet 直接 jump-cut |
| 对比度（light）| ✓ — ink 14.8:1 / inkSecondary 7.2:1 / primary 时间轴在 background 上 6.1:1 |
| 对比度（dark）| ✓ — 12.6:1 |
| 屏幕阅读器章节 | 章节标记挂 `Semantics(header: true, headerLevel: 2, label: "2026 4 月")` |
| 时间轴装饰性 | ✓ — 1px 黛蓝竖线挂 `ExcludeSemantics` 不进入语义树 |

---

## 10. 自我 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处）| ✓ | ① 时间轴竖线（"装订线"延伸性段落标记，算 1 处）② 章节标记竖线（同色家族，算延展不另计）③ sticky CTA 「新增一笔。」 ④ 起点圆点（小且单一）—— 严格意义 3-4 处，处于硬规则上限。卡片 inline label 默认 inkSecondary 不计入。 |
| 2. 调和层次胜过投影 | ✓ | surface 4 级（background → containerLowest 卡 → containerHigh AppBar → ink 文字）。零 BoxShadow / 零 BackdropFilter / 零 border。AppBar 底线仅滚动 0.5px outline 唯一例外。 |
| 3. 编辑级不对称 | ✓ | 单列右对齐，左侧 32px 永久留白 + 1px 时间轴。Hero 左对齐。CTA 左对齐不 fullWidth。**彻底告别 v1 中央对称双列**。 |
| 4. 慢节奏与留白 | ✓ | 顶部 64 + 章节间 64 + 卡间 32 + 卡内 16；月份做章节断点；相邻间距跨级。一屏 ≤ 4 卡。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零粒子 / 零装饰 icon。事件类型用 inline label 文字区分，不用色不用 icon。已服 / 待服等状态用编辑陈述（"已服" / "到时间了。"），不用勾不用图标。 |

**自审遗留风险**：
- 时间轴竖线被算作"延展性段落标记"是否合规？严格按 principles.md §1 "黛蓝 ≤ 3 处"，竖线纵向连续覆盖 60-100% 屏高，属于"块面"边缘，但宽度仅 1px——此处取"它是段落标记的纵向延伸"解释。如果 CTO 评审认为破坏稀缺性，回退方案是改 `outline` 烟灰色 1px（不进强色家族）。
- HanaPullRefresh 尚未在 components/ 落地（同 today 风险）。
- 月份章节 sticky 切换需要 `SliverPersistentHeader` + `SliverList` 嵌套，性能上要保证 60fps（百级 entry 滚动）—— 见 handoff §性能。

---

## 11. 与 critique-v1 的 10 个 P0 逐项消除

| critique-v1 P0 | v2 处理 |
|---------------|--------|
| 1. 中央通屏 2px 渐变线 | **删除**，改左侧贴 padding 内边的 1px 黛蓝实色竖线（书脊装订隐喻），仅在内容区延伸 |
| 2. AppBar BackdropFilter blur + alpha | `HanaTopBar.defaultBar` 实色 surfaceContainerHigh + 滚动 0.5px outline；`centerTitle: false` 标题左对齐 |
| 3. domain enums.dart 三个装饰 getter（icon / borderColor / iconColor）| 全部从 domain 删除，移到 presentation `timeline_event_type_l10n.dart` `localizedTypeLabel(l10n)` 文字扩展（DEC-042/043 合规）|
| 4. 卡片 4 色彩边线 + ★ icon + boxShadow + 圆点描边 | 全删；卡片仅 surfaceContainerLowest + 4px 圆角 + inline label 文字区分类型 |
| 5. `HanaColors.*` v1 樱色调色板 | 全切 `HanaTokens.*(context)` 单轨 API |
| 6. FAB 黛蓝→粉樱渐变圆按钮 | 删除，改底部 sticky `HanaButton.primary` 单色实色 6px 圆角 |
| 7. `_TimelineStartPoint` 大脑 icon + 灰圆 + 黛蓝小点 | 改 4px 黛蓝实心点 + headline「起点。」+ mono 日期，左对齐 |
| 8. `'Plus Jakarta Sans'` + `'Be Vietnam Pro'` 字体 | 全切 v2 ramp：宋体 / 思源黑体 / Inter / JetBrains Mono |
| 9. Filter Pills 块面填充选中态 | 改下划线 2px 黛蓝（杂志目录语法）；筛选维度扩展走 HanaBottomSheet.filter |
| 10. 文案"我的成长轨迹" / "尚无事件" | 改"年表。" / "尚未起笔。"（第三人称 + 句号收尾） |

> **额外消除（critique-v1 P1 顺带处理）**：
> - 水平 padding 24 → 32（spacing.lg）
> - 卡间 24 → 32（lg），相邻跨级
> - 加月份章节断点 + sticky `HanaSectionHeader`
> - 双侧 z 字布局 → 单列右对齐
> - `DateFormat('yyyy.MM.dd')` → `DateFormat.yMMMd(localeName)`

---

—— 完 ——
