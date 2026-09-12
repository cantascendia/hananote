# Today 屏 v2 视觉规范

> Generated 2026-04-28 from DESIGN.md v2 + tokens.md + components/
> 屏幕：lib/features/medication/presentation/pages/today_page.dart
> Pilot Wave: 阶段 3.1.b（新稿）+ 3.1.c（自我 critique-v2）
> 配对 handoff：docs/design/handoff/today.md

---

## 1. 设计意图

新 Today 想给用户的感觉是 **「翻开一本属于自己的、安静的私人内刊」**——而不是 v1 那种"温柔守护者"的拟人陪伴。早晨打开时，屏幕给到的不是大字 + 闪光 icon + 渐变倒计时卡的"温度爆表"，而是月白底 + 一行墨色宋体「早。」+ 大量留白 + 一张内文页式的卡片，像翻新潮文库第 3 页。

引用 DESIGN.md「克制·沉静·不矫情」调性：v1 用花瓣告诉用户"你做到了！"，v2 让屏幕静下来一秒，再用一行黑墨宋体写「今日已记。」——后者更有重量。

**v1 vs v2 核心叙事差异**：v1 是"app 哄你"，v2 是"屏幕敬你"。一个早晨的服药动作，从"打开 → 找按钮 → 庆祝撒花"变成"打开 → 翻一页 → 轻按 → 静默 → 一行墨字落下"。仪式感来自留白，不是装饰。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 默认态（有未服项 + 已服项）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色 米灰，无 blur
│   "今日"  (title 18 · ink, 左对齐 16)       │     滚动出现 0.5px outline @ 30%
├─────────────────────────────────────────────┤
│                                             │
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│   早。                                       │  ← display-xl (40·52·-0.5)
│   (Spectral SemiBold / 宋体 Medium)         │     ink 墨色，左对齐 spacing.lg=32
│   4 月 28 日　周二                          │  ← body-sm (13·20)
│   (mono · inkSecondary)                     │     第 142 天　HRT
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 当前                                      │  ← 4px 黛蓝竖线 + label·12·+0.6
│  ┃ (HanaSectionHeader)                       │     竖线长度仅覆盖首行高 16px
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable
│   │                                    │    │     surfaceContainerLowest #FBF8F2
│   │   雌二醇凝胶                       │    │     padding md=16, radius 4
│   │   (title 18 · ink)                 │    │
│   │                                    │    │
│   │   2.0 mg　·　涂抹                   │    │  ← mono 14 数值 + body 中点
│   │   (mono · inkSecondary)            │    │
│   │                                    │    │
│   │   (spacing.md = 16)                │    │
│   │                                    │    │
│   │   08:00 到时间了。                 │    │  ← body 15·24，编辑陈述
│   │                                    │    │
│   │   (spacing.lg = 32)                │    │
│   │                                    │    │
│   │   [ 记一次 ]    (HanaButton.primary │    │  ← 黛蓝实色 + 6px + onPrimary
│   │                  fullWidth=false   │    │     左对齐，**不**铺满
│   │                  44dp 高)          │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (卡片间 spacing.lg = 32)                  │
│                                             │
│   ╭────────────────────────────────────╮    │  ← 第二张当前卡，结构同上
│   │   补佳乐                           │    │     若有第二个未服项
│   │   1.0 mg　·　口服                   │    │
│   │   12:00                            │    │
│   │   [ 记一次 ]                        │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 之后                                      │  ← HanaSectionHeader
│  ┃ (label · inkSecondary +0.6)              │     已服项区
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat（褪色态）
│   │   ⏐ 螺内酯　25 mg　·　07:30        │    │  ← 1px 淡墨竖线 + inkSecondary
│   │   (title · inkSecondary 全文淡墨)   │    │     **无勾、无 icon**——褪色 = 已服
│   ╰────────────────────────────────────╯    │
│                                             │
│   (卡片间 spacing.md = 16，褪色态紧凑)       │
│                                             │
│   ╭────────────────────────────────────╮    │
│   │   ⏐ 维 D3　1000 IU　·　07:30        │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (底部 spacing.xl = 64)                    │
└─────────────────────────────────────────────┘
```

### 2.2 全部已服态

```
│   今日完毕。                                │  ← display-xl 取代「早。」
│   (Spectral SemiBold · ink)                 │     无 emoji 无装饰
│   4 月 28 日　共 3 次。                      │  ← body-sm 副行
│                                             │
│   (spacing.xl = 64)                         │
│                                             │
│  ┃ 之后                                      │  ← 全部褪色态卡片
│  ╭────────────────────────────────────╮     │
│  │ ⏐ 雌二醇凝胶　2.0 mg　·　08:00     │     │
│  ╰────────────────────────────────────╯     │
│  ...                                        │
```

### 2.3 空态（无任何用药计划）

```
│   早。                                       │
│   4 月 28 日　周二                          │
│                                             │
│   (spacing.xl = 64)                         │
│                                             │
│   [HanaEmptyState · variant=page]           │
│                                             │
│   ⌥ Icon medication_outlined 32dp           │  ← 无圆形容器
│      ink @ 60%                              │
│                                             │
│   (spacing.lg = 32)                         │
│                                             │
│   本期空白。                                │  ← headline 24 · ink
│                                             │
│   (spacing.sm = 8)                          │
│                                             │
│   尚未设置每日用药。                        │  ← body-sm · inkSecondary
│                                             │
│   (spacing.lg = 32)                         │
│                                             │
│   [ 添加第一项 ]   HanaButton.secondary     │  ← 月白底 + 黛蓝 1px 边框
│                                             │
```

### 2.4 错误态

`HanaErrorState` 居中：「载入失败。请下拉刷新。」+ HanaButton.ghost「重试」。

### 2.5 加载态

`HanaLoadingView.block` — 无 spinner，仅一行宋体「读取中。」inkSecondary 居中。

---

## 3. 组件映射（每元素 → v2 组件）

| 区域 | v2 组件 | Variant | 关键 props |
|------|--------|---------|-----------|
| 顶部栏 | `HanaTopBar` | `defaultBar` | title="今日"（仅屏幕阅读器，视觉用 hero）, scrollController 监听 |
| Hero 问候 | (Text 直接) | display-xl 宋体 | "早。" / "今日完毕。" 左对齐 spacing.lg=32 |
| 副行（日期 + HRT 第 N 天）| (Text + mono) | body-sm | "4 月 28 日　周二" + mono "第 142 天　HRT" |
| 章节标题 | `HanaSectionHeader` | default | title="当前" / "之后", **左侧 4px 黛蓝竖线**只覆盖首行高 |
| 当前服药卡 | `HanaCard` | `tappable` | surfaceContainerLowest, 4px radius, padding md, onTap → 跳详情 |
| CTA「记一次」 | `HanaButton` | `primary` | 黛蓝实色, 6px, 44dp 高, **不** fullWidth |
| 已服褪色卡 | `HanaCard` | `flat` | 同 surface 但内容全 inkSecondary，左侧 1px 淡墨竖线 |
| 庆祝反馈 | `HanaCelebration` | default | `trigger(context, message: l10n.celebrationRecorded)` |
| 空态 | `HanaEmptyState` | `page` | icon=medication_outlined, title="本期空白。", action=HanaButton.secondary |
| 错误态 | `HanaErrorState` | default | "载入失败。请下拉刷新。" + ghost 重试 |
| 加载态 | `HanaLoadingView` | `block` | "读取中。" 文字态，无 spinner |

> **明确删除**：v1 的 `CountdownCard`（大块渐变倒计时）、`QuoteCard`（斜体引言 + 引号 icon）、`PetalCelebration`（粉樱粒子）、AppBar 的 `Icons.auto_awesome`、问候段右侧 56px 头像（移到 Settings 入口）、状态卡的 ✓ 勾。

---

## 4. Tokens 引用清单

所有色 / 间距 / 圆角 / 字号 / 时长**严禁**直接 hex / 数字字面量。一律走 `HanaTokens.xxx(context)`。

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` (#F4F1EA / dark #1C1A18) |
| Card 内文页 | `HanaTokens.surfaceContainerLowest(context)` (#FBF8F2 / dark #252320) |
| AppBar 米灰 | `HanaTokens.surfaceContainerHigh(context)` (#EAE6DD / dark #2D2A26) |
| Hero / 卡内主标题 | `HanaTokens.ink(context)` (#1C1A18 / dark #E8E4DB) |
| 副行 / 已服褪色 | `HanaTokens.inkSecondary(context)` (#5E5A52 / dark #A39E92) |
| 章节竖线 / CTA 实色 | `HanaTokens.primary(context)` (#1F3A5F / dark #7A9CC2) |
| CTA 文字 | `HanaTokens.onPrimary(context)` (#FBF8F2) |
| 错误文字 | `HanaTokens.error(context)` (#9B2A2A) |

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `HanaTokens.spacing.lg` = 32 |
| Hero 顶部留白 | `HanaTokens.spacing.xl` = 64 |
| 段落间（章节↔卡片群） | `HanaTokens.spacing.lg` = 32 |
| 卡片之间（当前态） | `HanaTokens.spacing.lg` = 32 |
| 卡片之间（褪色态紧凑）| `HanaTokens.spacing.md` = 16 |
| 卡内 padding | `HanaTokens.spacing.md` = 16 |
| 卡内段落 | `HanaTokens.spacing.md` = 16；卡内段落组之间 `lg` = 32 |
| 副行行间 | `HanaTokens.spacing.xs` = 4 |
| 章节标题 → 卡片 | `HanaTokens.spacing.md` = 16 |
| 屏幕底部留白 | `HanaTokens.spacing.xl` = 64 |

> 强制跨级：相邻间距禁止 16 紧挨 16；卡内 16 + 卡间 32 是合规组合。

### 圆角
| 用途 | Token |
|------|-------|
| 卡片 | `HanaTokens.radius.card` = 4 |
| 按钮 | `HanaTokens.radius.button` = 6 |
| 头像 / 必要圆形 | `HanaTokens.radius.pill` = 999（仅 Settings 入口头像） |

### 字体
| 用途 | Token / 字体 |
|------|------------|
| Hero「早。」/「今日完毕。」 | `display-xl` (40/52/-0.5) Spectral SemiBold / Source Han Serif SC Medium / Noto Serif JP Medium |
| 卡内主标题（药名） | `title` (18/26/0) Regular |
| 卡内 body / 时间陈述 | `body` (15/24/0) Inter / Source Han Sans SC / Noto Sans JP Regular |
| 章节 label「当前」「之后」 | `label` (12/16/+0.6) Medium |
| 数值（剂量 / HRT 第 N 天 / 时间）| `mono` (14/20/0) JetBrains Mono Light |
| 副行日期 | `body-sm` (13/20/0) |
| CTA 文字 | `body` (15/24/0) Medium |

### 动画
| 用途 | Token |
|------|-------|
| 卡片 press scale | `HanaTokens.motion.quick` = 150ms easeOut |
| 入场列表项 fadeIn | `HanaTokens.motion.standard` = 240ms easeInOut，错落 80ms |
| 庆祝淡入 | `HanaTokens.motion.deliberate` = 600ms（spec 内 1200ms 由 HanaCelebration 内置）|
| 庆祝淡出 | `HanaTokens.motion.fade` = 1200ms linear |
| reorder 已服置底 | `HanaTokens.motion.deliberate` = 600ms |

---

## 5. 交互状态

### 默认（首屏装载完成）
- AppBar 实色米灰，无底线（offset = 0）
- Hero 与卡片同时入场：列表项依次 `motion-standard` 240ms fadeIn + 错落 80ms

### 卡片按下（onTap 跳详情）
- HanaCard.tappable 启用 HanaPressScale → 0.98 / `motion-quick` 150ms

### 「记一次」按下
1. HanaButton press scale 0.98
2. Cubit 派发 `LogDoseTodaySchedule(...)`，刚刚那张当前卡 **立即** 视觉变化：
   - label 章节归属从「当前」迁移到「之后」组
   - 卡片重新渲染为 `HanaCard.flat`（褪色态：所有文字 → inkSecondary，左侧加 1px 淡墨竖线）
   - **不** 显示 ✓ 勾
   - 列表 reorder 动画 `motion-deliberate` 600ms
3. 同步触发 `HanaCelebration.trigger(context, message: l10n.celebrationRecorded)`
   - 0.4s 静默 → 1.2s fadeIn 黛蓝宋体「今日已记。」→ 0.6s 停留 → 1.2s fadeOut（总 ~3.4s）
   - 不阻塞操作（`IgnorePointer: true`）
   - 可选 `HapticFeedback.lightImpact()`

### 全部已服
- Hero 文字切换为「今日完毕。」+ 副行「4 月 28 日　共 N 次。」
- 当前段消失，仅剩「之后」段全部褪色卡

### 空态（无任何用药）
- 显示 `HanaEmptyState.page`：icon 32dp + headline「本期空白。」+ message + secondary 按钮「添加第一项」

### 错误态
- 整屏 `HanaErrorState`：「载入失败。请下拉刷新。」+ HanaButton.ghost「重试」
- ARB key: `today.errorRetry`

### 加载态
- 整屏 `HanaLoadingView.block`：一行宋体「读取中。」inkSecondary，无 CircularProgressIndicator

### 下拉刷新
- 系统 RefreshIndicator 在 v2 不允许（Material 圆环违反纸感），改用 `HanaPullRefresh`（如未实施则保留 system 默认但 indicator 颜色锁定 `HanaTokens.primary`）

---

## 6. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，padding 水平 32（spacing.lg），卡片占满 |
| 768–1024 (tablet) | 单列内文页 max-width 720px 居中（呼吸更宽，但保持杂志页宽节奏）|
| ≥ 1024 (web 桌面) | 三列编辑式：左 240px sidebar（时间线 / 章节导航占位）/ 中 720px 内文页 / 右 240px 浮岛（HRT 第 N 天 + 下次提醒小卡）|

> mobile 是主战场。tablet / web 仅约束 max-width 避免巨字幅。

---

## 7. 动画规范

| 时机 | 时长 | 曲线 | Token |
|------|------|------|-------|
| 首屏入场（列表项 fadeIn）| 240ms × N，错落 80ms | easeInOut | `motion-standard` |
| 卡片 press scale 0.98 | 150ms | easeOut | `motion-quick` |
| AppBar 底线淡入（滚动）| 80ms | easeOut | `motion-instant` |
| 标记后已服 reorder 置底 | 600ms | easeOut | `motion-deliberate` |
| 庆祝静默 | 400ms | — | 硬常量 `kHanaCelebrationSilence` |
| 庆祝淡入 | 1200ms | easeOut | `motion-deliberate` (extended) |
| 庆祝停留 | 600ms | — | 硬常量 |
| 庆祝淡出 | 1200ms | linear | `motion-fade` |

**绝对禁止**：粒子动画、scale > 1（弹跳放大）、translate 大位移、spring 曲线（Curves.elasticOut 等）。

---

## 8. i18n 注意

- ja「薬を追加します」比 zh「添加第一项」长 ~30%。空态 secondary 按钮预留 `Wrap` 弹性宽度，允许换 1 行。
- ja 庆祝「今日も記しました。」比 zh「今日已记。」长 1.5 倍。HanaCelebration 内置规则：display-md 自动缩为 display-sm (24)，**不**换行。
- zh 简繁差异：默认 `今日已记。` / 預設 `今日已記。`，靠 ARB locale 切换。
- en「Recorded.」短 → 同样左对齐 32px，不强制居中。
- 副行 mono 数字 + CJK 全角空格：`第 142 天　HRT`（zh）/ `142 days　HRT`（en）。

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — AppBar action / 卡片整张 / CTA 全部 44dp+ |
| Semantics 完整朗读 | ✓ — 卡片 label「当前　雌二醇凝胶　2 毫克　上午 8 点　待服」 |
| 焦点顺序 | AppBar → Hero → 副行 → 当前章节 → 当前卡（每张展开为 1 个语义单元）→ 之后章节 → 已服卡 |
| prefers-reduced-motion | ✓ — HanaCelebration 退化为静态显示 1.5s 后直接消失，无淡入淡出；列表入场跳过 fadeIn |
| 对比度（light）| ✓ — ink #1C1A18 on background #F4F1EA = 14.8:1（AAA） |
| 对比度（黛蓝 CTA）| ✓ — onPrimary #FBF8F2 on primary #1F3A5F = 9.4:1（AAA） |
| 对比度（dark）| ✓ — ink #E8E4DB on background #1C1A18 = 12.6:1（AAA） |
| 屏幕阅读器庆祝 | `Semantics(liveRegion: true)` 自动播报 |

---

## 10. 自我 critique-v2（短）

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处）| ✓ | ① CTA「记一次」②「当前」章节竖线 ③ 庆祝文字 — 共 3 处。AppBar / Hero / 副行 / 卡内全部墨色。 |
| 2. 调和层次胜过投影 | ✓ | surface 4 级（background → containerLowest → containerHigh AppBar → ink 文字）。零 BoxShadow / 零 BackdropFilter / 零 border（除 AppBar 滚动 0.5px outline 唯一例外）。 |
| 3. 编辑级不对称 | ✓ | Hero 左对齐 32px，右侧 70% 留白。章节竖线段落标记。**无**居中。「记一次」CTA 不 fullWidth，左对齐放置。 |
| 4. 慢节奏与留白 | ✓ | 顶部留白 64px。卡间 32px。相邻间距跨级（16 + 32）。庆祝 0.4s 静默。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零粒子 / 零装饰 icon。已服褪色 = 日记语言（淡墨竖线 + 淡墨文字）取代工具语言（✓ 勾）。 |

**自审遗留风险**：
- HanaPullRefresh 尚未在 components/ 落地，目前 spec 暂用「保留 system 默认 + 锁定颜色」过渡——3.1.d 阶段补一个 v2 版下拉态。
- 章节标题「当前」竖线高度规则尚未在 components/ 中明确（HanaSectionHeader spec 未读到），需补：竖线高度 = 首行 line-height = 16px，宽度 4px，色 `primary`。

---

## 11. 与 critique-v1 的 9 个 P0 逐项消除

| critique-v1 P0 | v2 处理 |
|---------------|--------|
| 1. 整套色 token 仍是 v1 樱色 `HanaColors.*` | 全切 `HanaTokens.*(context)` 单轨 API（黛蓝 + 月白 + 墨色） |
| 2. 4 处 BackdropFilter blur（AppBar + CountdownCard 内圆 + UpcomingDoseCard 圆 + CountdownCard 文字底）| 全删，AppBar 用 `HanaTopBar` 实色 surfaceContainerHigh + 滚动 0.5px outline 替代 |
| 3. BoxShadow（CountdownCard blurRadius:32 / UpcomingDoseCard blurRadius:16）+ border 视觉 | 全删，仅靠 surface 阶差（lowest #FBF8F2 vs background #F4F1EA）形成层次 |
| 4. CountdownCard 整张渐变（HanaGradients.countdownOf）+ 旋转药片装饰 icon + 大块强色 | **整个 `CountdownCard` 组件删除**——v2 不需要倒计时强调；时间陈述「08:00 到时间了。」内嵌 HanaCard 一行 body 解决 |
| 5. `PetalCelebration.show()` 撒 10 片粉樱花瓣 | 替换为 `HanaCelebration.trigger(context, message: l10n.celebrationRecorded)`「今日已记。」黛蓝宋体淡入淡出 |
| 6. MedicationStatusCard 已服态用 ✓ 勾 | 已服态改为 `HanaCard.flat` 褪色 = 全文 inkSecondary + 左侧 1px 淡墨竖线，**无勾、无 icon** |
| 7. 圆角 14 / 15 / 16 / 24 / 999 stadium 五种非法值 | 全统一：卡片 4 / 按钮 6 / 头像圆形（pill 999 仅 Settings 入口头像）|
| 8. 字体 PlusJakartaSans 圆润 sans | 全切 v2 ramp：Hero 用 Spectral SemiBold / 思源宋体 / Noto Serif JP；正文 Inter / 思源黑体；数值 JetBrains Mono Light |
| 9. AppBar 装饰 `Icons.auto_awesome` 闪光 icon + 装饰承担情感 | 删除 — `HanaTopBar` 仅 title + 可选 actions，无装饰 icon |

> **额外消除（critique-v1 P1 顺带处理）**：
> - 水平 padding 24 → 32（spacing.lg）
> - 章节标题右侧 6×6 圆点 → 左侧 4px 黛蓝竖线（HanaSectionHeader）
> - 12 / 20 非 token 间距全部清除
> - 头像从 hero 右上下沉到 Settings 入口
> - QuoteCard 整个组件删除（一屏只允许一个视觉重心，引言喧宾夺主）

---

— 完 —
