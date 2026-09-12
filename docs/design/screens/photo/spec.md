# Photo 屏（网格）v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/
> 屏幕：lib/features/photo/presentation/pages/photo_page.dart
> Pilot Wave: 阶段 3.1.b（新稿）+ 3.1.c（自我 critique-v2）
> 配对 handoff：docs/design/handoff/photo.md
> 上游基准：critique-v1.md（P0 13 条）+ timeline/spec.md（章节分组 pattern）+ lock-screen/spec.md（隐私仪式 pattern）

---

## 1. 设计意图

身体照片是 HanaNote 用户**最敏感的内容**。Photo 屏不是"相册 app"——它是**装订成册的身体年表**。HRT 用户在公共场合（咖啡店 / 通勤路上 / 家人在场）打开 app 时，旁观者扫一眼这一屏不应识别出"这是身体记录工具"——这是跨性别用户安全的最高保护。

v1 用 `Icons.lock_person_outlined` 空态锁形 hero icon **直接把屏幕烙印成"我有秘密"**——这是 critique-v1 P0 红线。v2 把整屏视觉**降回普通笔记 app 的图册感**：月白底 + display-xl「图册。」+ 网格 + 月份章节标记 + 底部一行 mono "图像本地加密 · N 张" inkSubdued —— **含蓄确认加密保护**，但视觉上不暴露身份。

v2 主要的叙事变化：v1 是"social 相册（拍照 → 发布）"，v2 是"按月归档的身体年表（记录 → 章节 → 对比）"。仪式感来自月份章节断点（每张缩略图属于某月某周的故事）+ 底部"记一张"句号收尾的编辑陈述（不是"+"号渐变 FAB）+ 隐私状态栏含蓄而精确的事实陈述（让用户每一次打开都安心）。

跨性别敏感性是本屏最高优先级——视觉无锁形 / 盾形 / 月亮 / 心跳 / 任何"私密 / 健康 / 医疗"暗示符号；文案不说"私密相册"只说"图册"；CTA 不说"添加身体照片"只说"记一张"。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 默认态（有照片 + 多月份）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.defaultBar · surfaceContainerHigh│  ← 56dp 米灰，无 blur
│   "图册"  (title 18 · ink, 左对齐 16)        │     滚动出现 0.5px outline @ 30%
│   [actions: HanaIconButton 筛选]             │     筛选 → HanaBottomSheet.filter
├─────────────────────────────────────────────┤
│                                             │
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│   图册。                                    │  ← display-xl (40·52·-0.5)
│   (Spectral SemiBold / 宋体 Medium)         │     ink 墨色，左对齐 spacing.lg=32
│   42 张　始于 2025 年 12 月                 │  ← body-sm (13·20)
│   (mono 数字 · inkSecondary)                │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│ ┃ 2026 · 4 月                                │  ← HanaSectionHeader（章节断点）
│ ┃ (label 12·+0.6 · ink Medium)               │     左侧 4px 黛蓝竖线，覆盖首行 16px
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│  ┌────┐ ┌────┐ ┌────┐                       │  ← 网格 mobile 3 列 / tablet 4 / web 5
│  │ ▒▒ │ │ ▒▒ │ │ ▒▒ │                       │     每格 1:1 正方，4px radius
│  │ ▒▒ │ │ ▒▒ │ │ ▒▒ │                       │     surfaceContainerLowest 底
│  └────┘ └────┘ └────┘                       │     无 boxShadow 无渐变
│  ┌────┐ ┌────┐ ┌────┐                       │
│  │ ▒▒ │ │ ▒▒ │ │ ▒▒ │                       │     缩略图 BoxFit.cover
│  │ ▒▒ │ │ ▒▒ │ │ ▒▒ │                       │     无右下角黑色日期 pill
│  └────┘ └────┘ └────┘                       │
│                                             │
│   (章节间 spacing.xl = 64)                  │
│                                             │
│ ┃ 2026 · 3 月                                │  ← 下一章节
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│  [更多缩略图...]                            │
│                                             │
│   (spacing.xl = 64)                         │
│                                             │
│  ┌─────────────────────────────────┐        │
│  │  [记一张。]   HanaButton.primary  │        │  ← sticky bottom CTA
│  │  黛蓝实色 6px 圆角 44dp 高          │        │     不 fullWidth，左对齐 32px
│  └─────────────────────────────────┘        │
│                                             │
│  图像本地加密 · 42 张                       │  ← 底部隐私状态栏
│  (mono · inkSubdued · 居中 · 仅一行 12px)   │     spacing.md=16 与 CTA 间距
└─────────────────────────────────────────────┘
```

> **关键视觉变化（vs v1）**：
> - 删除 `Icons.lock_person_outlined` 空态大锁（跨性别敏感性 P0）
> - 网格 2 列 → 3/4/5 响应式
> - 卡片圆角 20 → 4（r-card）
> - 删除 boxShadow + 黑色日期 pill + 渐变 placeholder
> - AppBar 右上 add_a_photo IconButton → 底部 sticky CTA「记一张。」
> - 加月份章节断点 + hero「图册。」+ 底部隐私状态栏

### 2.2 拍摄/导入选择器（HanaBottomSheet.actionSheet）

点击底部 sticky CTA「记一张」→ 升起 Bottom Sheet：

```
        ───────                              ← drag handle 32x4
  ┌──────────────────────────────┐
  │                              │
  │  记一张。                    │  ← headline 24 ink
  │                              │
  │  ┃ 拍摄                      │  ← HanaListItem variant=action
  │  │ 用相机记录此刻             │     leading 无 icon（或极简文字标记）
  │                              │     body-sm inkSecondary 副行
  │  ┃ 从图库选择                │
  │  │ 导入已有图片               │
  │                              │
  │  (spacing.lg = 32)           │
  │                              │
  │  [关闭]   HanaButton.ghost   │  ← 取消按钮（不用"取消"用"关闭"）
  └──────────────────────────────┘
```

> 跨性别敏感性：选项文案不说"添加身体照片 / 拍摄记录"——只说"拍摄 / 从图库选择"。系统相机权限对话框由 OS 接管，HanaNote 的权限 reason 串走"拍摄一张图像加入图册。"（不说"身体记录"）。

### 2.3 长按手势（HanaBottomSheet.actionSheet）

长按某张缩略图 → 升起 Bottom Sheet（替换 v1 直接 delete dialog）：

```
        ───────
  ┌──────────────────────────────┐
  │  4 月 28 日　周二             │  ← label 12·+0.6 · primary
  │                              │
  │  ┃ 查看                      │
  │  ┃ 对比                      │  ← 进对比模式 P2
  │  ┃ 删除                      │  ← destructive 朱砂文字
  │                              │
  │  [关闭]   HanaButton.ghost   │
  └──────────────────────────────┘
```

### 2.4 空态（无任何照片）

```
│   图册。                                    │  ← display-xl
│   尚无图像                                  │  ← body-sm inkSecondary
│                                             │
│   (spacing.xl = 64)                         │
│                                             │
│   [HanaEmptyState · variant=page]           │
│                                             │
│   (无 icon 无圆形容器 无渐变)                │  ← 关键：删除 v1 lock_person 锁形 hero
│                                             │
│   图册空白。                                │  ← headline 24 · ink
│                                             │
│   (spacing.sm = 8)                          │
│                                             │
│   记下第一张，对比由此开始。                │  ← body-sm · inkSecondary
│                                             │
│   (spacing.lg = 32)                         │
│                                             │
│   [ 记一张 ]   HanaButton.secondary         │  ← 月白底 + 黛蓝 1px 边框
│                                             │
│   (spacing.xl = 64)                         │
│                                             │
│   图像本地加密                              │  ← 底部状态栏（无 N 张数）
```

### 2.5 错误态 / 加载态

- 错误：`HanaErrorState`「载入失败。请下拉刷新。」+ HanaButton.ghost「重试」
- 加载：`HanaLoadingView.block`「读取中。」inkSecondary 居中（不用 spinner）
- 单张缩略图未加载：网格中该位置 `surfaceContainerLow` 实色 + 极弱细线 progress（不用 v1 双色对角线渐变）

---

## 3. 组件映射

| 区域 | v2 组件 | Variant | 关键 props |
|------|--------|---------|-----------|
| 顶部栏 | `HanaTopBar` | `defaultBar` | title="图册"（仅屏幕阅读器，视觉用 hero）, actions=[HanaIconButton 筛选 P2] |
| Hero 标题 | (Text 直接) | `display-xl` 宋体 | "图册。" 左对齐 spacing.lg=32 |
| 副行 | (Text + mono) | `body-sm` | "{count} 张　始于 {date}"（数字 mono） |
| 章节标记 | `HanaSectionHeader` | default | title="2026 · 4 月"，左侧 4px 黛蓝竖线只覆盖首行高 |
| 网格容器 | `GridView.builder` + `SliverGrid` | — | crossAxisCount: mobile 3 / tablet 4 / web 5；间距 md=16 |
| 缩略图卡 | `HanaPhotoTile`（新组件）| — | surfaceContainerLowest, 4px radius, 1:1 比例, onTap → photo-view, onLongPress → HanaBottomSheet |
| 缩略图 placeholder | `HanaPhotoTile.placeholder` | — | surfaceContainerLow 实色 + 细线 progress（无渐变）|
| 选择器面板 | `HanaBottomSheet` | `actionSheet` | child=HanaListItem 拍摄 / 从图库选择，actions=[HanaButton.ghost 关闭] |
| 长按操作面板 | `HanaBottomSheet` | `actionSheet` | child=HanaListItem 查看 / 对比 / 删除（destructive 朱砂）|
| 创建 CTA | `HanaButton` | `primary` | label="记一张。", sticky bottom，44dp 高，**不** fullWidth，左对齐 32px |
| 隐私状态栏 | (Text 直接) | `mono 12` inkSubdued | "图像本地加密 · {count} 张" 居中底部 |
| 空态 | `HanaEmptyState` | `page` | **无 icon**, title="图册空白。", message="记下第一张，对比由此开始。", action=HanaButton.secondary |
| 错误态 | `HanaErrorState` | default | "载入失败。请下拉刷新。" + ghost 重试 |
| 加载态 | `HanaLoadingView` | `block` | "读取中。" 文字态，无 spinner |

> **明确删除**：v1 的 `Icons.lock_person_outlined` 空态锁形 hero（photo_page.dart:234-238）、120dp 黛蓝圆容器（227-239）、卡片 boxShadow（326-332）、卡片 20px 圆角（321/325/335）、placeholder 双色对角线 LinearGradient（392-399）、右下角黑色半透明日期 pill（350-374）、AppBar `Icons.add_a_photo_outlined` IconButton（51-55）、BottomSheet `Icons.camera_alt` / `Icons.photo_library` 装饰 icon（188、196）。

---

## 4. Tokens 引用清单

所有色 / 间距 / 圆角 / 字号 / 时长**严禁**直接 hex / 数字字面量。一律走 `HanaTokens.xxx(context)`。

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| 缩略图卡底 | `HanaTokens.surfaceContainerLowest(context)` |
| Placeholder 实色 | `HanaTokens.surfaceContainerLow(context)` |
| AppBar 米灰 | `HanaTokens.surfaceContainerHigh(context)` |
| Hero / 空态标题 | `HanaTokens.ink(context)` |
| 副行 / 隐私状态栏 / 空态描述 | `HanaTokens.inkSecondary(context)` |
| 章节竖线 / sticky CTA 实色 | `HanaTokens.primary(context)` |
| CTA 文字 | `HanaTokens.onPrimary(context)` |
| 长按"删除"文字 | `HanaTokens.error(context)` |

> **核心约束**：本屏黛蓝可见点 ≤ 3 处。① 章节标记 4px 竖线（每月一处，但视觉上属同一垂直阅读流，按章节首处计 1 处）② 底部 sticky CTA「记一张。」算 1 处 ③ AppBar 滚动 0.5px outline 不计入强色（烟灰，非黛蓝）。其他位置严禁出现黛蓝（缩略图 / 空态 / 隐私状态栏全墨色或淡墨）。

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `HanaTokens.spacing.lg` = 32 |
| Hero 顶部留白 | `HanaTokens.spacing.xl` = 64 |
| Hero ↔ 首个章节 | `HanaTokens.spacing.lg` = 32 |
| 章节标记 → 首行缩略图 | `HanaTokens.spacing.md` = 16 |
| 网格 crossAxisSpacing / mainAxisSpacing | `HanaTokens.spacing.md` = 16 |
| 章节间（月份切换） | `HanaTokens.spacing.xl` = 64 |
| 末行缩略图 → sticky CTA | `HanaTokens.spacing.xl` = 64 |
| sticky CTA → 隐私状态栏 | `HanaTokens.spacing.md` = 16 |

> 强制跨级：网格内 16 紧挨 16 是网格本身的栅格特性（v2 例外允许）；屏边 32 + 网格内 16 是合规组合。月份章节用 64 强化"翻章节"节奏。

### 圆角
| 用途 | Token |
|------|-------|
| 缩略图卡 | `HanaTokens.radius.card` = 4 |
| 按钮 | `HanaTokens.radius.button` = 6 |
| Bottom Sheet 顶角 | `kHanaBottomSheetRadius` = 16 |

### 字体
| 用途 | Token / 字体 |
|------|------------|
| Hero「图册。」 | `display-xl` (40/52/-0.5) Spectral SemiBold / 宋体 Medium |
| 章节标记「2026 · 4 月」 | `label` (12/16/+0.6) Medium |
| 副行（"42 张　始于..."）| `body-sm` (13/20/0) + mono 数字 |
| 空态标题「图册空白。」 | `headline` (24/32/-0.2) Regular |
| 空态描述 | `body-sm` (13/20/0) |
| 隐私状态栏「图像本地加密 · 42 张」 | `mono` (12/16/0) JetBrains Mono Light · inkSecondary |
| CTA 文字「记一张。」 | `body` (15/24/0) Medium |
| 长按 sheet「4 月 28 日　周二」label | `label` (12/16/+0.6) primary |

### 动画
| 用途 | Token |
|------|-------|
| 缩略图按下 press scale | `HanaTokens.motion.quick` = 150ms easeOut |
| 入场 fadeIn（首屏可见 N 张） | `HanaTokens.motion.standard` = 240ms easeInOut，错落 40ms |
| BottomSheet 升起 | `HanaTokens.motion.standard` = 240ms easeInOut |
| 章节标记 sticky 切换 | `HanaTokens.motion.standard` = 240ms easeInOut |
| Hero 与 photo-view 之间 | Hero 共享元素 240ms easeInOut |

> **明确禁止**：粒子、缩略图本身入场 scale > 1、缩略图渐变 placeholder、长按抖动反馈（仅 `motion-quick` press scale 0.98）。

---

## 5. 交互状态

### 默认（首屏装载完成）
- AppBar 实色米灰，无底线（offset = 0）
- Hero 与首屏可见缩略图同时入场：fadeIn 240ms 错落 40ms
- 章节标记**不参与入场动画**（静态出现）
- 底部隐私状态栏永远显示（首屏前 80ms 已渲染——快速建立"加密保护"安心感）

### 缩略图按下（onTap 跳 photo-view）
- HanaPhotoTile 启用 HanaPressScale → 0.98 / `motion-quick` 150ms
- Hero 共享元素动画 `tag: 'photo-${entry.id}'` —— 缩略图飞向全屏
- 跳转过程中 sticky CTA 与隐私状态栏淡出（80ms）

### 缩略图长按（onLongPress）
1. lightImpact() haptic（不是 heavyImpact）
2. trigger HanaBottomSheet.actionSheet 显示日期 label + 查看 / 对比 / 删除
3. 删除走二次确认 HanaDialog.confirmDestructive（朱砂"删除"按钮）

### 拍摄/导入流程
1. 底部 sticky CTA「记一张」按下 → BottomSheet 升起
2. 选 "拍摄"：bloc.add(`PhotoEvent.capturePhoto()`) → 系统相机 → 返回后 reload
3. 选 "从图库选择"：bloc.add(`PhotoEvent.pickFromGallery()`) → 系统 picker → reload
4. 加密保存中：状态栏短暂显示"加密中…"（mono inkSubdued）→ 完成后回到"图像本地加密 · N+1 张"

### 月份章节切换（滚动）
- `HanaSectionHeader` sticky 在内容区顶部（用 `SliverPersistentHeader`），向下滚动到下一月时上一月标签上滑离场
- sticky 高度 = 24dp（label line height + 8 padding）
- 滑动过场 240ms easeInOut

### 全部筛选无结果（P2）
- 显示 `HanaEmptyState.page`：title="本期空白。" + message="调整筛选试试。" + secondary "重置筛选"

### 错误态
- 整屏 `HanaErrorState`「载入失败。请下拉刷新。」+ HanaButton.ghost「重试」

### 加载态
- 整屏 `HanaLoadingView.block`：一行宋体「读取中。」inkSecondary

### 下拉刷新
- 沿用 Today 屏 `HanaPullRefresh`（indicator 颜色锁定 `HanaTokens.primary`）

### sticky CTA + 隐私状态栏
- "记一张。" 按钮 + 下方"图像本地加密 · N 张"始终 fixed 在屏幕底部 SafeArea 上方
- 滚动时不消失
- BottomSheet 升起时 sticky CTA 与状态栏淡出（避免 z-index 冲突）

---

## 6. 断点行为

| 宽度 | 网格列数 | 布局 |
|------|---------|------|
| < 768 (mobile) | 3 列 | 单屏左 32px 留白 + 网格占满，正方 1:1 缩略图 |
| 768–1024 (tablet) | 4 列 | max-width 720px 居中，网格在 max-width 容器内 |
| ≥ 1024 (web 桌面) | 5 列 | max-width 1080px 居中，章节标记紧贴左侧 |

> **关键约束**：缩略图永远 1:1 正方比例（不是 v1 的 0.78）—— 1:1 是身体对比的**最公平比例**（不竖向拉长、不横向压扁）；列数随宽度变化但单格 aspectRatio 恒定。
> mobile 是主战场。tablet / web 仅约束 max-width 避免巨缩略图。
> sticky CTA 和隐私状态栏在所有断点保持左对齐 32px / 居中底部，不随网格列数变。

---

## 7. 动画规范

| 时机 | 时长 | 曲线 | Token |
|------|------|------|-------|
| 首屏入场（缩略图 fadeIn）| 240ms × N，错落 40ms | easeInOut | `motion-standard` |
| 缩略图 press scale 0.98 | 150ms | easeOut | `motion-quick` |
| Hero 缩略图 → photo-view | 240ms | easeInOut | `motion-standard` |
| AppBar 底线淡入（滚动）| 80ms | easeOut | `motion-instant` |
| 章节标记 sticky 切换 | 240ms | easeInOut | `motion-standard` |
| BottomSheet 升起 / 关闭 | 240ms | easeInOut | `motion-standard` |
| 隐私状态栏数字 tween（N → N+1）| 240ms | easeInOut | `motion-standard` |

**绝对禁止**：粒子动画、缩略图本身 scale > 1、长按抖动 / 旋转、删除时缩略图爆炸 / 滑出、CTA 渐变 / 浮动光晕（保持杂志静态感）。

---

## 8. i18n 注意

- ja「画像庫。」短于 zh「图册。」短于 en「The Album.」—— hero `display-xl` 弹性宽度。
- ja「画像はローカルで暗号化 · 42 件」最长，隐私状态栏 mono 12 单行可能溢出 mobile 320 宽 —— 允许换 1 行（高度自适应）。
- ja「最初の一枚を。」比 zh「记下第一张。」长 ~30%，HanaEmptyState 标题不限行数。
- 月份章节 zh「2026 · 4 月」/ ja「2026 · 4月」/ en「Apr 2026」—— `DateFormat.yMMM(localeName)` + 自定义点分隔。
- 缩略图本身**不打日期**（v1 黑色 pill 已删）—— 日期完全由章节标记承担，避免 i18n 缩略图日期格式 hard-code。
- 隐私状态栏 zh「图像本地加密 · 42 张」/ ja「画像はローカルで暗号化 · 42 件」/ en「Locally encrypted · 42 entries」—— "本地加密"是含蓄确认（不说"私密"不说"安全"），让安全感来自精确事实陈述。

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — 缩略图 mobile 3 列时单格 ≈ 110×110 / tablet 4 列 ≈ 165×165 / web 5 列 ≈ 200×200，全部 ≥ 44dp。sticky CTA 44dp。AppBar action 44dp。 |
| Semantics 完整朗读 | ✓ — 缩略图 label "图像　4 月 28 日　周二"（从 entry.date 派生，不读"私密 / 身体"暗示）。章节标记 `Semantics(header: true, headerLevel: 2, label: "2026 4 月")`。隐私状态栏 `Semantics(label: "图像本地加密，共 42 张")`。 |
| 焦点顺序 | AppBar → Hero 标题 → 章节标记 → 该章节缩略图（每张一个语义单元）→ 下一章节 → sticky CTA → 隐私状态栏 |
| prefers-reduced-motion | ✓ — 缩略图入场跳过 fadeIn；章节 sticky 切换走 instant；BottomSheet 直接 jump-cut；Hero 共享元素禁用 → 直接跳屏 |
| 对比度（light）| ✓ — ink 14.8:1 / inkSecondary 7.2:1 / mono 隐私状态栏 inkSecondary 在 background 上 7.2:1 / sticky CTA 黛蓝 on 月白 6.1:1 |
| 对比度（dark）| ✓ — 12.6:1 |
| 屏幕阅读器章节 | 章节标记挂 `Semantics(header: true, headerLevel: 2)` |
| 跨性别敏感性 | ✓ — 视觉无锁 / 盾 / 月亮 / 心跳；Semantics label 不含"私密 / 身体 / 健康"；权限 OS 弹窗 reason 走中性"拍摄一张图像"。 |

---

## 10. 自我 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处）| ✓ | ① 章节标记 4px 竖线（垂直阅读流统一为 1 处）② sticky CTA「记一张。」 ③ AppBar 滚动 outline 是烟灰非强色不计入。严格 2-3 处，远低于 v1 的 ≥ 6 处。 |
| 2. 调和层次胜过投影 | ✓ | surface 4 级（background → containerLowest 缩略图卡 → containerLow placeholder → containerHigh AppBar）。零 BoxShadow / 零渐变 / 零 border。AppBar 滚动 0.5px outline 唯一例外。 |
| 3. 编辑级不对称 | ✓ | hero 左对齐 32px，sticky CTA 左对齐不 fullWidth。**网格本身是对称的，但章节标记 + hero + CTA 全部偏左 32px 锚定单边阅读流**。 |
| 4. 慢节奏与留白 | ✓ | 顶部 64 + 章节间 64 + 章节内网格 16 + 屏边 32；月份做章节断点；网格内 16 紧挨 16 是栅格例外允许。 |
| 5. 内容即装饰 | ✓ | 零装饰 icon（删除 lock_person、add_a_photo、camera_alt、photo_library）；空态零图标；缩略图本身就是内容（不打日期 pill 不加边框装饰）；隐私通过精确事实陈述传达不通过锁形 / 盾形符号。 |

**自审遗留风险**：
- 网格列数响应式（3/4/5）需要 `LayoutBuilder` + `MediaQuery` 测断点 —— 工程实现需细心避免抖动
- 1:1 强制比例可能导致少数横构图照片被裁切 —— v2 取舍：身体对比公平 > 构图保留
- Hero 共享元素动画在跨章节滚动后跳转可能出现位置错位 —— 需 `flightShuttleBuilder` 兜底
- 隐私状态栏字符串依赖 N（数量）实时同步 —— Bloc 派发 entry count 即可，无新机制
- 长按对比模式（P2）尚未实施 —— 当前 sheet 显示"对比"按钮但暂时 disabled 或跳转占位

---

## 11. 与 critique-v1 的 13 个 P0 逐项消除

| critique-v1 P0 | v2 处理 |
|---------------|--------|
| 1. `Icons.lock_person_outlined` 锁形 hero icon | **删除**，空态改纯文字态（headline + body-sm + secondary 按钮，无 icon） |
| 2. 卡片 boxShadow | 删除，缩略图仅 surfaceContainerLowest 实色 |
| 3. 卡片圆角 20 → 4 | 走 `HanaTokens.radius.card` |
| 4. Placeholder 双色对角线 LinearGradient | 改 `surfaceContainerLow` 实色 + 极弱细线 progress |
| 5. 右下角黑色日期 pill | 删除，日期由月份章节标记承担 |
| 6. 网格列数 mobile 2 → 3 + 响应式 | mobile 3 / tablet 4 / web 5，1:1 正方比例 |
| 7. 加月份章节断点 `HanaSectionHeader` | 按月分组，章节间 spacing.xl=64 |
| 8. Hero「图册。」+ 副行"{count} 张　始于 {date}" | display-xl + body-sm mono |
| 9. AppBar add_a_photo IconButton 删除 → 底部 sticky CTA | `HanaButton.primary`「记一张。」|
| 10. BottomSheet 走 `HanaBottomSheet.actionSheet` | 文字主导 HanaListItem，删除 camera_alt / photo_library 装饰 icon |
| 11. `HanaColors.*` → `HanaTokens.*(context)` | 全切单轨 API |
| 12. 文案改"图册。" / "图册空白。" / "记下第一张，对比由此开始。" | 第三人称编辑陈述 + 句号收尾 |
| 13. 加底部隐私状态栏"图像本地加密 · N 张" | mono inkSubdued 居中底部 —— 含蓄确认加密保护 |

> **额外消除（critique-v1 P1 顺带处理）**：
> - 屏边 padding 16 → 32（spacing.lg）
> - 卡间 12 → 16（md）
> - 首屏顶部 64（xl）留白
> - `DateFormat('yyyy.MM.dd')` → `DateFormat.yMMM(localeName)` 月份章节
> - AppBar 走 `HanaTopBar.defaultBar` `centerTitle: false`

—— 完 ——
