# Record 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + components/
> 屏幕：`lib/features/journal/presentation/pages/record_page.dart`
> Pilot Wave: 阶段 3.2.b（新稿）+ 3.2.c（自我 critique-v2）
> 配对 handoff：`docs/design/handoff/record.md`

---

## 1. 设计意图

新 Record 屏给用户的感觉是 **「翻开内刊的目录页」**——而不是 v1 那种"温柔多彩三选一"的拟人陪伴。从 root tab 进入时，屏幕给到的不是大字 + 旋转药片 + 莲花 footer 的"装饰过载"，而是月白底 + 一行墨色宋体「今日　记一笔。」+ 一段 4px 黛蓝竖线段落标记 + 三段杂志栏目式的入口（拍照 / 测量 / 日记），像翻新潮文库的章节扉页。

引用 DESIGN.md「克制·沉静·不矫情·敬」调性：v1 用三色多彩卡 + 旋转药片告诉用户"你来选一个吧 →"，v2 让屏幕静下来，用三段宋体陈述并列陈列——不引诱、不暗示、不评判用户该记哪一项。**v1 vs v2 核心叙事差异**：v1 是"app 三选一推销"，v2 是"目录页只摆栏目"。一个用户进入 Record 的动作，从"被三色多彩吸引 → 选一个 → 进详情"变成"翻一页目录 → 找到要记的栏目 → 进内文"。仪式感来自留白与编辑陈述，不是装饰。

Today 已建立 hero「早。」+ 章节竖线 + 一抹黛蓝 CTA 的页面骨架；Record 复用这套语法但把"hero + 单一 CTA"换成"hero + 目录三栏"——两屏同源，**不**重新发明轮子。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 默认态（已加载，至少有一项历史记录）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色 米灰，无 blur
│   "记录" (title 18 · ink, 左对齐 32)        │     滚动出现 0.5px outline @ 30%
├─────────────────────────────────────────────┤
│                                             │
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│   今日　记一笔。                            │  ← display-xl (40·52·-0.5)
│   (Spectral SemiBold / 宋体 Medium)         │     ink 墨色，左对齐 spacing.lg=32
│   4 月 29 日　周三                          │  ← body-sm (13·20)
│   (mono 数字 + 思源黑体)                    │     inkSecondary 淡墨
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 三道入口                                 │  ← HanaSectionHeader（v1.1 待落 spec）
│  ┃ (label·12·+0.6 · inkSecondary)           │     左侧 4px 黛蓝竖线，长度仅覆盖首行 16px
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable
│   │                                    │    │     surfaceContainerLowest #FBF8F2
│   │   01　影像                         │    │  ← title 18 · ink，编号 mono
│   │                                    │     │     编号「01」是 spacing.lg 左留白序号
│   │   (spacing.sm = 8)                 │    │
│   │   加密相册。仅你可见。             │    │  ← body 15·24 · ink，编辑陈述
│   │                                    │    │
│   │   (spacing.md = 16)                │    │
│   │                                    │    │
│   │   上次　4 月 25 日。                │    │  ← body-sm · inkSecondary，无胶囊
│   │   (mono 日期 + 思源黑体)           │    │     最近 24h 内记录 → 切换为黛蓝陈述（见 §5）
│   ╰────────────────────────────────────╯    │
│                                             │
│   (卡片间 spacing.lg = 32)                  │
│                                             │
│   ╭────────────────────────────────────╮    │  ← 第二张卡，结构同上
│   │   02　体测                         │    │
│   │   尺寸与体重的轨迹。               │    │
│   │   B 87　W 62　H 90　·　4 月 27 日。│    │  ← measurementSummary，全 mono
│   ╰────────────────────────────────────╯    │
│                                             │
│   (卡片间 spacing.lg = 32)                  │
│                                             │
│   ╭────────────────────────────────────╮    │
│   │   03　日记                         │    │
│   │   一行也算今日。                   │    │
│   │   连续　12 天。                    │    │  ← streak 时改用此句；空时「尚无日记。」
│   ╰────────────────────────────────────╯    │
│                                             │
│   (底部 spacing.xl = 64)                    │
└─────────────────────────────────────────────┘
```

### 2.2 全空态（首次进入，三栏均无历史）

```
│   今日　记一笔。                            │
│   4 月 29 日　周三                          │
│                                             │
│  ┃ 三道入口                                 │
│                                             │
│   01　影像                                  │
│   加密相册。仅你可见。                      │
│   尚无影像。                                │  ← inline empty 一行陈述
│                                             │
│   02　体测                                  │
│   尺寸与体重的轨迹。                        │
│   尚无测量。                                │
│                                             │
│   03　日记                                  │
│   一行也算今日。                            │
│   尚无日记。                                │
```

### 2.3 加载态

`HanaLoadingView.block`：屏幕居中一行宋体「读取中。」`inkSecondary`，**无** `CircularProgressIndicator`。

### 2.4 错误态

`HanaErrorState`：「载入失败。请下拉刷新。」`ink` headline + `HanaButton.ghost`「重试」（dispatch `RefreshRecordSummary`）。

### 2.5 下拉刷新

`HanaPullRefresh`（v1.1 待落 spec）包裹 ListView，下拉触发 `RefreshRecordSummary`；indicator 颜色锁定 `HanaTokens.primary`，**不**用 Material 圆环。

---

## 3. 组件映射

| 区域 | v2 组件 | Variant | 关键 props |
|------|--------|---------|-----------|
| 顶部栏 | `HanaTopBar` | `defaultBar` | title=`l10n.recordTitle`（"记录"），scrollController 监听 outline 淡入 |
| Hero 标题 | (Text 直接) | display-xl 宋体 | "今日　记一笔。" 左对齐 spacing.lg=32 |
| 副行（日期）| (Text + mono) | body-sm | "4 月 29 日　周三" mono 数字 + CJK Sans |
| 章节标题 | `HanaSectionHeader`（v1.1 待落 spec）| default | title="三道入口"（label · +0.6 · inkSecondary），左侧 4px 黛蓝竖线只覆盖首行高 |
| 入口卡（×3）| `HanaCard` | `tappable` | surfaceContainerLowest, 4px radius, padding md, onTap → 跳详情 |
| 入口编号「01 / 02 / 03」 | (Text mono) | mono 14 inkSecondary | 左对齐，承担"目录序号"语义 |
| 入口标题 | (Text title 18) | title | ink，左对齐 |
| 入口副述 | (Text body 15) | body | ink，编辑陈述句 |
| 入口状态行（streak / 上次 / measurement summary）| (Text body-sm) | body-sm | inkSecondary（默认）/ primary（24h 内活跃，见 §5） |
| 空状态行 | `HanaEmptyState` | `inline` | 仅 title="尚无影像。"等一行陈述，无图标无 CTA |
| 错误态 | `HanaErrorState` | default | 整屏，"载入失败。请下拉刷新。" + ghost 重试 |
| 加载态 | `HanaLoadingView` | `block` | "读取中。" 文字态，无 spinner |
| 下拉刷新 | `HanaPullRefresh`（v1.1 待落）| default | onRefresh → `RefreshRecordSummary` |

> **明确删除**：私有 `_StitchRecordCard`（v1 226-436 整段下线）、左上 48dp 圆角 16 icon 容器、右侧 64dp 装饰图标、`AnimatedRotation`、`ImageFiltered blur(24)` 装饰圆、`BoxShadow`、`Border.all`、tag 圆胶囊 9999、AppBar `BackdropFilter blur(12)`、footer `Icons.spa` + 红点 + 抒情文案整段。

---

## 4. Tokens 引用清单

所有色 / 间距 / 圆角 / 字号 / 时长**严禁**直接 hex / 数字字面量。一律走 `HanaTokens.xxx(context)`。

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| Card 内文页 | `HanaTokens.surfaceContainerLowest(context)` |
| AppBar 米灰 | `HanaTokens.surfaceContainerHigh(context)` |
| Hero / 卡内主标题 | `HanaTokens.ink(context)` |
| 副行 / 入口副述 / 状态默认 | `HanaTokens.inkSecondary(context)` |
| 章节竖线 / 24h 内活跃陈述 | `HanaTokens.primary(context)` |
| 错误文字 | `HanaTokens.error(context)` |

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `HanaTokens.spacing.lg` = 32 |
| Hero 顶部留白 | `HanaTokens.spacing.xl` = 64 |
| Hero → 章节标题 | `HanaTokens.spacing.lg` = 32 |
| 章节标题 → 第一卡 | `HanaTokens.spacing.md` = 16 |
| 卡片之间 | `HanaTokens.spacing.lg` = 32 |
| 卡内 padding | `HanaTokens.spacing.md` = 16 |
| 卡内编号 → 标题 | `HanaTokens.spacing.sm` = 8 |
| 卡内标题 → 副述 | `HanaTokens.spacing.sm` = 8 |
| 卡内副述 → 状态 | `HanaTokens.spacing.md` = 16 |
| 屏幕底部留白 | `HanaTokens.spacing.xl` = 64 |

> 强制跨级：相邻间距禁止 16 紧挨 16；hero 64 + 段落 32 + 章节标题 16 + 卡内 16 + 段落组 8 是合规跨级链。

### 圆角
| 用途 | Token |
|------|-------|
| 卡片 | `HanaTokens.radius.card` = 4 |
| 按钮（错误态 ghost）| `HanaTokens.radius.button` = 6 |

### 字体
| 用途 | Token / 字体 |
|------|------------|
| Hero「今日　记一笔。」 | `display-xl` (40/52/-0.5) Spectral SemiBold / Source Han Serif SC Medium / Noto Serif JP Medium |
| 入口标题（影像 / 体测 / 日记）| `title` (18/26/0) Regular |
| 入口副述（编辑陈述）| `body` (15/24/0) Inter Regular / 思源黑体 Regular |
| 入口编号「01 / 02 / 03」 | `mono` (14/20/0) JetBrains Mono Light |
| 章节 label「三道入口」| `label` (12/16/+0.6) Medium |
| 副行日期 / 状态行日期 / measurement summary | `body-sm` (13/20/0) + 数字段 mono 混排 |
| 章节竖线 | n/a（4px width，长度 = 首行 line-height 16） |

### 动画
| 用途 | Token |
|------|-------|
| 卡片 press scale 0.98 | `HanaTokens.motion.quick` = 150ms easeOut |
| 入场列表项 fadeIn | `HanaTokens.motion.standard` = 240ms easeInOut，3 张卡错落 80ms |
| AppBar 底线淡入（滚动）| `HanaTokens.motion.instant` = 80ms easeOut |
| 24h 内活跃陈述色切换 | `HanaTokens.motion.standard` = 240ms easeInOut |

---

## 5. 交互状态

### 默认（首屏装载完成）
- AppBar 实色米灰，无底线（offset = 0）
- Hero 与卡片同时入场：3 张入口卡依次 `motion-standard` 240ms fadeIn + 错落 80ms

### 卡片按下
- `HanaCard.tappable` 启用 press scale 0.98 / `motion-quick` 150ms
- onTap 跳路由：影像 → `/photo`；体测 → `/measurement`；日记 → `/journal/edit`（保留 v1 行为）

### 24h 内活跃态（一抹强色的可用性引导）
- 当某入口的最近记录在 24h 内（依据 `RecordLoaded.lastPhotoDate / lastMeasurementDate / lastJournalDate`），其状态行从 `inkSecondary` 切到 `primary`，但**不**加图标 / 不加角标 —— 颜色本身承担"今日已记一道"的陈述。
- 全屏黛蓝出现位置最大值：① 章节竖线（1 处）② 状态行黛蓝（≤ 3 处，但用户不可能 3 道全部 24h 内活跃 → 实际典型 0~2 处）—— 满足"≤ 3 处"硬规则。

### 历史 streak / 摘要
- 日记入口当 `journalStreak > 0` → "连续　{days} 天。"（mono 数字 + 句号）
- 体测入口当有 `lastMeasurementSummary` → "B 87　W 62　H 90　·　{date}。"
- 影像入口当有 `lastPhotoDate` → "上次　{date}。"
- 全空 → 三栏分别 "尚无日记。" / "尚无测量。" / "尚无影像。"

### 加载态
- 整屏 `HanaLoadingView.block`：一行宋体「读取中。」inkSecondary，无 spinner

### 错误态
- 整屏 `HanaErrorState`：「载入失败。请下拉刷新。」+ HanaButton.ghost「重试」(dispatch `RefreshRecordSummary`)

### 下拉刷新
- `HanaPullRefresh`（v1.1 待落 spec）包裹滚动区，触发 `RefreshRecordSummary`；indicator 颜色锁 `HanaTokens.primary`

---

## 6. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，padding 水平 32（lg），3 张卡纵向铺满，间距 32 |
| 768–1024 (tablet) | 单列内文页 max-width 720px 居中 |
| ≥ 1024 (web 桌面) | 三列编辑式：左 240px sidebar（root tab 文字导航占位）/ 中 720px 内文页 / 右 240px 浮岛（最近 7 天小型时间线占位） |

> mobile 是主战场。3 张卡**始终单列**（不在 tablet 切两列双卡），保留杂志目录的纵向阅读节奏。

---

## 7. 动画规范

| 时机 | 时长 | 曲线 | Token |
|------|------|------|-------|
| 首屏入场（卡 fadeIn）| 240ms × 3，错落 80ms | easeInOut | `motion-standard` |
| 卡片 press scale 0.98 | 150ms | easeOut | `motion-quick` |
| AppBar 底线淡入（滚动）| 80ms | easeOut | `motion-instant` |
| 24h 活跃态色切换 | 240ms | easeInOut | `motion-standard` |
| 下拉刷新 | 由 HanaPullRefresh 内置 | — | — |

**绝对禁止**：粒子动画、scale > 1、translate 大位移、`AnimatedRotation`（v1 装饰图标 hover 复位整段下线）、spring 曲线。

---

## 8. i18n 注意

- 所有文案走 ARB；下表"文案 v2 改写"列出 spec 引用的目标文案，**不**直接落 ARB（实施时由 handoff 走 PR）。
- ja「記録します」"今日　一筆。" 比 zh「今日　记一笔。」长 ~10%。display-xl 行高已留 52，单行可容；超长 fallback 自动换行（hero 允许 2 行）。
- ja measurement summary 「B 87　W 62　H 90」全宽数字与中文一致，mono 字体不分 locale。
- 编号「01 / 02 / 03」locale 无关，永远 mono。

### 文案 v2 改写（需新增 ARB keys）
| 现 ARB key | v1 文案 | v2 改写 | 新 key |
|-----------|---------|--------|--------|
| `recordTitle` | 今日记录 | **记录** | 复用 `recordTitle`（值改）|
| `recordGreeting` | 你好，\n今天想留下什么回忆？ | **今日　记一笔。** | 复用 `recordGreeting`（值改）|
| (新) | — | 三道入口 | `recordSectionEntries` |
| `recordPhoto` | 拍照记录 | **影像** | 复用 `recordPhoto`（值改）|
| `recordPhotoSub` | 加密存储，只有你能看到 | **加密相册。仅你可见。** | 复用 `recordPhotoSub`（值改）|
| `recordMeasurement` | 身体测量 | **体测** | 复用 `recordMeasurement`（值改）|
| `recordMeasurementSub` | 记录身体的每一点变化 | **尺寸与体重的轨迹。** | 复用 `recordMeasurementSub`（值改）|
| `recordDiary` | 心情日记 | **日记** | 复用 `recordDiary`（值改）|
| `recordDiarySub` | 今天想说点什么 | **一行也算今日。** | 复用 `recordDiarySub`（值改）|
| `recordPhotoEmpty` | 还没有拍照记录 | **尚无影像。** | 复用（值改）|
| `recordMeasureEmpty` | 还没有测量记录 | **尚无测量。** | 复用（值改）|
| `recordDiaryEmpty` | 开始你的第一篇日记 | **尚无日记。** | 复用（值改）|
| `recordLastPhoto` | 上次：{date} | **上次　{date}。** | 复用（值改）|
| `recordStreak` | 已连续记录 {days} 天 | **连续　{days} 天。** | 复用（值改）|
| `recordFooter` | 每一次记录都是对未来的温柔期许 | **删除整段** | deprecate `recordFooter` |
| (新) | — | 读取中。 | `recordLoading` |
| (新) | — | 载入失败。请下拉刷新。 | `recordErrorTitle` |
| (新) | — | 重试 | 复用全局 `commonRetry`（如不存在则新增）|

> 编号「01 / 02 / 03」由 UI 层 `String.padLeft(2, '0')` 生成，不进 ARB。

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — 整张卡 GestureDetector，单卡高度 ≥ 100dp |
| Semantics 完整朗读 | ✓ — 卡片 label「影像。加密相册仅你可见。上次 4 月 25 日」 |
| 焦点顺序 | AppBar → Hero → 副行 → 章节标题 → 卡 1 → 卡 2 → 卡 3 |
| prefers-reduced-motion | ✓ — 入场 fadeIn 跳过；24h 活跃态色切换静态完成 |
| 对比度（light）| ✓ — ink #1C1A18 on background #F4F1EA = 14.8:1（AAA）|
| 对比度（dark）| ✓ — ink #E8E4DB on background #1C1A18 = 12.6:1（AAA）|
| 对比度（24h 黛蓝陈述）| ✓ — primary #1F3A5F on surfaceContainerLowest #FBF8F2 = 9.4:1（AAA）|
| 屏幕阅读器空态 | `HanaEmptyState.inline` 内置 Semantics |

---

## 10. 自我 critique-v2（短）

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处）| ✓ | ① 章节竖线 ② 24h 活跃状态行（典型 0~2 处） — 总计 ≤ 3。AppBar / Hero / 副行 / 卡内默认全墨色 |
| 2. 调和层次胜过投影 | ✓ | 4 级 surface（background → containerLowest → containerHigh AppBar）。零 BoxShadow / 零 BackdropFilter / 零 border / 零 ImageFiltered |
| 3. 编辑级不对称 | ✓ | Hero 左对齐 32px，AppBar title 左对齐 32px。三张卡左对齐起头，编号 mono「01」承担目录序号语义。**无**居中（footer 整段删除）|
| 4. 慢节奏与留白 | ✓ | 顶部 64 → 章节 32 → 标题→卡 16 → 卡内 16 → 段落组 8 → 卡间 32 → 底 64 — 全跨级 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零粒子 / 零旋转药片 / 零莲花 / 零 tag 圆胶囊。用编号 + 宋体陈述 + 句号承担"目录页"重量 |

**自审遗留风险**：
- `HanaSectionHeader` 与 `HanaPullRefresh` v1.1 待落 components/ spec —— 实施 PR 中先用临时 inline 实现（4px 黛蓝 Container + Padding）+ 系统 RefreshIndicator 颜色锁定，3.1.d 阶段补 component spec 后回填。
- 24h 内活跃态色切换若用户三栏全部 24h 内活跃（罕见但可能）→ 状态行 3 处 + 章节竖线 1 处 = 4 处黛蓝，恰好越线。规避：状态行黛蓝**仅**用于"最近一次"那一栏；其余两栏即便 24h 内也保持 inkSecondary。实施时由 BlocBuilder 计算"哪栏 lastDate 最新"标记。

---

## 11. 与 critique-v1 的 P0 逐项消除

| critique-v1 P0 | v2 处理 |
|---------------|--------|
| 1. 整屏色 token 仍 v1 樱色 `HanaColors.*`（12+ 处）| 全切 `HanaTokens.*(context)` 单轨 API |
| 2. AppBar `BackdropFilter blur(12,12)`（76）| 替换为 `HanaTopBar` 实色 surfaceContainerHigh + 滚动 0.5px outline |
| 3. 3 张卡 `ImageFiltered blur(24)` + `BoxShadow blurRadius:16` + `Border.all`（313-348）| 整段删除，`HanaCard.tappable` 仅靠 surface 阶差形成层次 |
| 4. 卡片圆角 16 + tag stadium 9999 | 卡 4（card token）+ tag 圆胶囊整段删除，改一行 body-sm 陈述 |
| 5. 3 张卡右侧 64dp 装饰图标 + `AnimatedRotation`（415-426）| 整段删除 — 装饰承担情感违反原则 5 |
| 6. footer `Icons.spa` + 红点装饰（182-205）| 整段删除 |
| 7. 字体 `'Plus Jakarta Sans'`（90,100,127）| 全切 v2 ramp：display-xl Spectral / 思源宋体 / Noto Serif JP；body Inter / 思源黑体；编号 JetBrains Mono Light |
| 8. 文案 v1 信纸调性（recordTitle / Greeting / Footer / sub / empty 9 处）| 全部改 v2 编辑体（详见 §8 表格），footer 整段 deprecate |
| 9. AppBar `centerTitle: true`（83）| 改左对齐 32px（HanaTopBar 默认即左对齐）|

> **额外消除（critique-v1 P1 顺带处理）**：
> - 水平 padding 24 → 32（lg）
> - 三入口前加 `HanaSectionHeader`「三道入口」+ 4px 黛蓝竖线段落标记
> - 间距值 24 / 16 / 8 全部改 token（lg=32 / md=16 / sm=8 / xl=64）
> - 卡内左上 48dp icon 容器删除 — 改用纯文字 title + 编号
> - tag 圆胶囊改为一行 body-sm 编辑陈述
> - Loading `CircularProgressIndicator` → `HanaLoadingView.block`「读取中。」
> - Error 居中 Text → `HanaErrorState`「载入失败。请下拉刷新。」+ ghost 重试

---

— 完 —
