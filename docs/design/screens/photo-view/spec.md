# Photo View 屏（全屏查看）v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/
> 屏幕：lib/features/photo/presentation/pages/photo_view_page.dart
> Pilot Wave: 阶段 3.1.b（新稿）+ 3.1.c（自我 critique-v2）
> 配对 handoff：docs/design/handoff/photo-view.md
> 上游基准：critique-v1.md（P0 13 条）+ photo/spec.md（章节分组 / 网格） + lock-screen/spec.md（隐私警告 BottomSheet pattern）

---

## 1. 设计意图

photo-view 是 HRT 用户**最私密的查看时刻**——全屏对比身体照片是与自我的独处。v1 用底部白色固定 panel 把屏幕切两半，破坏全屏沉浸感；缺失分享警告和对比入口；用文件大小（KB / MB）替代用户真正关心的"HRT 第 N 天"；用 Material 装饰 icon 承担情感。

v2 把整屏视觉**回归全屏黑底沉浸**：图像填满屏幕（`BoxFit.contain`）+ 顶部 `HanaTopBar transparent` 浮于黑底之上 + 底部一行 mono inkSubdued 元数据「4 月 28 日 · 周二 · HRT 第 245 天」浮在黑底（无背板）+ 右上三按钮工具栏（删除 / 分享 / 对比）—— **每个按钮都是有意识的隐私决策**。

最关键的 v2 增量：分享按钮**必须有阻断式警告 BottomSheet**——「图像将以未加密形式离开本机」让用户在按下"确认分享"前必须主动确认。这不是工程优化，是**对 HRT 用户长期焦虑 / 误触灾难 / 突发情境的产品同情**——v1 没有分享按钮也没分享警告，但工程师任何时候加分享按钮没警告就是灾难。v2 spec 把警告写进设计契约，避免此类无声实施。

**绝对拒绝「保存到相册」按钮**——身体照片不应允许导出到系统相册（会与 iCloud / Google Photos 自动同步泄露）。这是 P2 拒绝项，工程师在未来需求中必须拒绝该按钮的添加。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 默认态（图像加载完成）

```
┌─────────────────────────────────────────────┐  ← Colors.black 全屏黑底
│ HanaTopBar.transparent                      │
│  ←  4 月 28 日　周二                  ⌫ ⇪ ⇄│  ← 透明顶栏（黑底之上）
│     (title 18 onPrimaryDark)              ↑    左：返回箭头 雪宣
│                                           │    标题：日期 yMMMEEEEd locale
│                                          删除  右：3 按钮工具栏
│                                          分享     雪宣 onPrimaryDark
│                                          对比     无背板 无圆容器
│                                                spacing.sm=8 between buttons
├─────────────────────────────────────────────┤
│                                             │
│                                             │
│                                             │
│            ┌───────────────────┐            │  ← Hero 共享元素（tag: photo-${id}）
│            │                   │            │     InteractiveViewer maxScale: 4
│            │                   │            │     双指捏合缩放保留
│            │   [图像内容]      │            │     BoxFit.contain（不裁切）
│            │                   │            │     swipe-down 手势关闭
│            │                   │            │
│            └───────────────────┘            │
│                                             │
│                                             │
│                                             │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│   4 月 28 日 · 周二 · HRT 第 245 天          │  ← 底部元数据浮在黑底
│   (mono 12 inkSubdued · 左对齐 32px)        │     无背板 无圆容器
│                                             │     单行 ellipsis
│   (SafeArea 底部 24px)                      │
└─────────────────────────────────────────────┘
```

> **关键视觉变化（vs v1）**：
> - 删除底部白色固定 panel + boxShadow + 24px 圆角
> - 全屏黑底沉浸（图像 BoxFit.contain 居中显示，但元数据左对齐 32px）
> - AppBar 走 `HanaTopBar transparent` 浮于黑底
> - 右上工具栏新增分享 / 对比按钮（v1 仅删除）
> - 元数据从"文件大小 1.2 MB"改"HRT 第 245 天"——用户真正关心的对比锚点
> - 加载占位 / 错误态去装饰 icon 改文字态

### 2.2 加载态（图像解密中）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.transparent                      │
│  ←  4 月 28 日　周二                  ⌫ ⇪ ⇄│  ← 工具栏 disabled (opacity 0.4)
├─────────────────────────────────────────────┤
│                                             │
│           [thumbnail 占位]                  │  ← 沿用 initialThumbnail
│           （若无 → 全黑）                    │     BoxFit.contain
│                                             │     opacity 0.6（半透明传达"加载中"）
│                                             │
├─────────────────────────────────────────────┤
│   解密中。                                  │  ← mono 14 onPrimaryDark @ 70%
│   (左对齐 32px)                             │     无 spinner 无圆容器
│   ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁                       │  ← 屏底 1px 进度条
│   (primary 横向 indeterminate)              │     spacing.sm=8 与文字间距
└─────────────────────────────────────────────┘
```

### 2.3 错误态（解密失败）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.transparent                      │
│  ←  4 月 28 日　周二                       │  ← 仅返回，工具栏隐藏
├─────────────────────────────────────────────┤
│                                             │
│                                             │
│   无法读取。                                │  ← headline 24 onPrimaryDark
│   (左对齐 32px)                             │
│                                             │
│   (spacing.sm = 8)                          │
│                                             │
│   图像可能已损坏，或加密密钥丢失。          │  ← body-sm onPrimaryDark @ 70%
│                                             │
│   (spacing.lg = 32)                         │
│                                             │
│   [ 重试 ]   HanaButton.ghost (雪宣文字)    │  ← 透明底 雪宣文字
│                                             │
│                                             │
└─────────────────────────────────────────────┘
```

### 2.4 删除二次确认（HanaDialog.confirmDestructive）

```
        ┌──────────────────────────────┐
        │                              │
        │  删除这张。                  │  ← headline 24 ink (light dialog)
        │                              │
        │  删除后无法找回。            │  ← body-sm inkSecondary
        │                              │
        │  [取消]   HanaButton.ghost   │
        │  [删除]   HanaButton.destructive (朱砂) │
        │                              │
        └──────────────────────────────┘
```

> 注意：dialog 本身用 light 主题（月白底 + 墨色文字 + 朱砂"删除"按钮），与全屏黑底视觉对峙——这是有意的，让用户从沉浸黑暗中"被中断"，做出有意识的删除决策。

### 2.5 分享警告（HanaBottomSheet — 关键 P0 增量）

点击右上分享按钮 ⇪ → 升起 BottomSheet：

```
        ───────                              ← drag handle 32x4
  ┌──────────────────────────────┐
  │                              │
  │  分享前请确认。              │  ← headline 24 ink
  │                              │
  │  图像将以未加密形式离开本机。│  ← body inkSecondary
  │  接收方可以保存、转发、截屏。│  ← body inkSecondary（双行警告）
  │                              │
  │  (spacing.lg = 32)           │
  │                              │
  │  [ 确认分享 ]                │  ← HanaButton.primary 黛蓝
  │                              │
  │  (spacing.sm = 8)            │
  │                              │
  │  [ 取消 ]                    │  ← HanaButton.ghost
  │                              │
  └──────────────────────────────┘
```

> "确认分享"按下 → 调用 `Share.shareXFiles(...)` 系统分享单 → OS 接管。**不**有"不再提示"复选框（每次都要主动确认是 v2 隐私契约）。

### 2.6 对比模式选择器（HanaBottomSheet）

点击右上对比按钮 ⇄ → 升起 BottomSheet：

```
        ───────
  ┌──────────────────────────────┐
  │                              │
  │  与哪一张对比？              │  ← headline 24 ink
  │                              │
  │  ┃ 2026 · 4 月                │  ← HanaSectionHeader
  │                              │
  │  [缩略图 4·28]  [缩略图 4·15]│  ← 横向 ScrollView 缩略图列表
  │                              │     当前查看的标记 disabled
  │  ┃ 2026 · 3 月                │
  │                              │
  │  [缩略图 3·28]  [缩略图 3·15]│
  │                              │
  │  (spacing.lg = 32)           │
  │                              │
  │  [关闭]   HanaButton.ghost   │
  │                              │
  └──────────────────────────────┘
```

> 选择某张 → 进入"对比模式"双图屏（**P2 实施** —— 当前 spec 仅占位 BottomSheet 显示选择器，对比模式本身延后到 P2 单独 spec）。

---

## 3. 组件映射

| 区域 | v2 组件 | Variant | 关键 props |
|------|--------|---------|-----------|
| 顶部栏 | `HanaTopBar` | `transparent` | title=日期 yMMMEEEEd, foregroundColor=onPrimaryDark, leading=back arrow, actions=[删除, 分享, 对比] |
| 工具栏按钮 | `HanaIconButton` × 3 | `transparentDark` | icon: delete_outline / share_outlined / compare_arrows, color=onPrimaryDark, 无背板 |
| 图像区 | `InteractiveViewer` + `Hero` + `Image.memory` | — | maxScale: 4, BoxFit.contain, Hero tag='photo-${id}' |
| Swipe-down 关闭 | `Dismissible` 或 `GestureDetector(onVerticalDragEnd)` | — | 滑动 ≥ 100px 关闭 |
| 底部元数据 | (Text 直接) | `mono 12` onPrimaryDark @ 70% | "4 月 28 日 · 周二 · HRT 第 245 天" 左对齐 32px 无背板 |
| 加载状态 | (Text + LinearProgressIndicator) | `mono 14` + 1px progress | "解密中。" + 屏底 1px primary 横条 |
| 错误状态 | (Text + HanaButton.ghost) | `headline 24` + body-sm | "无法读取。" + "图像可能已损坏，或加密密钥丢失。" + ghost "重试" 雪宣文字 |
| 删除确认 | `HanaDialog` | `confirmDestructive` | title="删除这张。", body="删除后无法找回。", primary="删除"(朱砂), secondary="取消" |
| 分享警告 | `HanaBottomSheet` | `warning` | title="分享前请确认。", body="图像将以未加密形式离开本机。\n接收方可以保存、转发、截屏。", primary="确认分享"(黛蓝), ghost="取消" |
| 对比选择 | `HanaBottomSheet` | `info` | title="与哪一张对比？", child=分组缩略图横滚列表, ghost="关闭" |

> **明确删除**：v1 的 `Colors.white` 底部 panel + boxShadow + 24px 圆角（91-104）、`_buildImageArea` 占位 220×220 灰盒 + `Icons.photo_outlined` 72px 大图标（189-202）、中央 spinner 黑半透明圆容器（203-211）、`Icons.broken_image_outlined` 错误图标（160）、`_formatFileSize` 文件大小显示（123-129、286-294）、Material `showDialog<bool>` + `AlertDialog`（240-258）、`DateFormat('yyyy.MM.dd')` 写死西文格式（70）。

> **明确拒绝（P2 阻止项）**：「保存到系统相册」按钮 —— 身体照片不应导出到系统相册（与 iCloud / Google Photos 自动同步泄露）。工程师在未来需求中必须拒绝此按钮。

---

## 4. Tokens 引用清单

所有色 / 间距 / 圆角 / 字号 / 时长**严禁**直接 hex / 数字字面量。一律走 `HanaTokens.xxx(context)` 或 `HanaTokens.dark.xxx(context)`。

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `Colors.black` (硬常量例外，全屏沉浸需要纯黑) — 或 `HanaTokens.dark.background` 暖深棕灰 #1C1A18 |
| AppBar / 工具栏 / 元数据文字 | `HanaTokens.onPrimaryDark` 雪宣 #FBF8F2 |
| 元数据次级 / 解密中文字 | `HanaTokens.onPrimaryDark.withAlpha(180)` ~70% |
| 加载进度条 | `HanaTokens.primary` 黛蓝 |
| 删除/分享/对比 icon | `HanaTokens.onPrimaryDark` 雪宣（不用黛蓝） |
| 分享警告 BottomSheet（light）| 走 light 主题 token（ink / inkSecondary / primary） |
| 删除 dialog（light）| 走 light 主题 token + error 朱砂 |

> **核心约束**：本屏黛蓝可见点 ≤ 2 处。① 加载时屏底 1px primary 进度条 ② 分享警告 sheet「确认分享」HanaButton.primary（按 sheet 出现才计入）。错误态重试按钮走 ghost 雪宣不计入。本屏因黑底沉浸，主基调是雪宣 onPrimaryDark + 透明 —— 黛蓝出现即是焦点信号。

### 间距
| 用途 | Token |
|------|-------|
| AppBar 标题左对齐 | `HanaTokens.spacing.md` = 16（紧凑顶栏） |
| 工具栏按钮间距 | `HanaTokens.spacing.sm` = 8 |
| 元数据左对齐 padding | `HanaTokens.spacing.lg` = 32 |
| 元数据 → SafeArea 底 | `HanaTokens.spacing.lg` = 24（实际是 SafeArea 接管） |
| 加载文字 → 进度条 | `HanaTokens.spacing.sm` = 8 |
| 错误态 headline → body | `HanaTokens.spacing.sm` = 8 |
| 错误态 body → 重试按钮 | `HanaTokens.spacing.lg` = 32 |
| 分享警告 sheet 内 padding | `HanaTokens.spacing.lg` = 32 |

### 圆角
| 用途 | Token |
|------|-------|
| 工具栏按钮 | 0（无背板，无圆角） |
| HanaDialog | `HanaTokens.radius.dialog` = 8 |
| HanaBottomSheet | `kHanaBottomSheetRadius` = 16 |
| 图像本身 | 0（全屏不裁圆角）|

### 字体
| 用途 | Token / 字体 |
|------|------------|
| AppBar 标题日期 | `title` (18/26/0) Regular（左对齐，不居中） |
| 元数据 mono | `mono` (12/16/0) JetBrains Mono Light · onPrimaryDark @ 70% |
| 加载文字 | `mono` (14/20/0) JetBrains Mono Light · onPrimaryDark @ 70% |
| 错误标题 | `headline` (24/32/-0.2) Regular · onPrimaryDark |
| 错误描述 | `body-sm` (13/20/0) onPrimaryDark @ 70% |
| 分享警告 sheet title | `headline` (24/32/-0.2) Regular · ink |
| 分享警告 sheet body | `body` (15/24/0) Regular · inkSecondary |

### 动画
| 用途 | Token |
|------|-------|
| Hero 共享元素（photo → photo-view）| `motion.standard` = 240ms easeInOut |
| AppBar / 工具栏淡入 | `motion.instant` = 80ms |
| InteractiveViewer 双指缩放 | 系统接管（不可自定义） |
| Swipe-down 关闭 | `motion.standard` = 240ms easeOut（手势驱动）|
| 加载进度条 indeterminate | 系统 LinearProgressIndicator 默认（不自定义） |
| BottomSheet 升起 / 关闭 | `motion.standard` = 240ms easeInOut |
| 加载完成 → 图像 fadeIn | `motion.quick` = 150ms |

> **明确禁止**：图像入场 scale > 1 / 旋转、装饰粒子、加载时图像呼吸 / 闪烁、删除时图像爆炸滑出、工具栏弹跳。

---

## 5. 交互状态

### 默认（图像加载完成）
- AppBar transparent 浮于黑底，标题 = 日期 yMMMEEEEd
- 工具栏 3 按钮（删除 / 分享 / 对比）opacity 1.0，可点击
- 图像 BoxFit.contain 居中显示
- 底部元数据"4 月 28 日 · 周二 · HRT 第 245 天" mono inkSubdued 左对齐
- 双指捏合缩放：系统 InteractiveViewer 接管 maxScale 4

### Swipe-down 关闭手势
1. 用户从图像区向下拖动 ≥ 100px
2. 黑底逐渐变暗（→ Colors.transparent）+ 图像跟随手指下移
3. 释放手指：完成关闭走 Hero 共享元素 240ms 飞回缩略图位置 / 取消则弹回原位 motion-quick 150ms

### 删除流程
1. 右上删除按钮 ⌫ 按下 → motion-quick 150ms press scale 0.98
2. 升起 `HanaDialog.confirmDestructive`（light 主题，月白底）
3. 用户按"删除" → `_isDeleting=true` → 删除按钮显示 spinner（沿用 v1 行为）→ 删除完成 → `Navigator.pop(true)` 返回 photo 网格 → bloc reload

### 分享流程（**关键 P0 增量**）
1. 右上分享按钮 ⇪ 按下 → motion-quick 150ms press scale 0.98
2. 升起 `HanaBottomSheet.warning`（light 主题，drag handle）
3. 双行警告："图像将以未加密形式离开本机。\n接收方可以保存、转发、截屏。"
4. 用户按 "确认分享" → 调用 `Share.shareXFiles([临时解密 jpg 文件], subject: 日期)` 系统分享单
5. OS 接管 share sheet → 用户选择目标 app → 临时解密文件随分享完成自动清理（**安全要求：tempfile 在 Share 完成 callback 后立即删除**）
6. 取消 → BottomSheet 关闭，回到 photo-view

### 对比流程（P2 占位）
1. 右上对比按钮 ⇄ 按下 → motion-quick 150ms press scale 0.98
2. 升起 `HanaBottomSheet.info` 显示分组缩略图列表（按月份）
3. 当前查看的图像 disabled 不可选
4. 用户选某张 → P2 进双图对比模式 / **MVP 期可显示"功能开发中"toast 占位**

### 加载态
- thumbnail 半透明 opacity 0.6 显示（沿用 v1 initialThumbnail）
- 屏底 1px primary 进度条 indeterminate
- 元数据位置显示"解密中。" mono 14 onPrimaryDark @ 70%
- 工具栏 disabled opacity 0.4

### 错误态
- 黑底全屏
- 居左对齐 32px："无法读取。" headline + "图像可能已损坏，或加密密钥丢失。" body-sm + ghost 重试雪宣文字
- 工具栏隐藏（仅返回箭头）

### prefers-reduced-motion
- Hero 共享元素禁用 → 直接 jump-cut
- Swipe-down 关闭禁用 → 仅返回箭头
- 加载进度条降级为静态文字"解密中"（无 indeterminate 动画）

---

## 6. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 全屏黑底，图像 BoxFit.contain 占满，元数据左对齐 32px |
| 768–1024 (tablet) | 全屏黑底，图像 max-width 720px 居中 contain，元数据左对齐 32px |
| ≥ 1024 (web 桌面) | 全屏黑底，图像 max-width 1080px 居中 contain（避免 4K 屏巨字幅）；右侧可选 detail panel（HRT 第 N 天 + 备注）作为浮岛——**P2** |

> **关键约束**：photo-view 在所有断点保持**全屏黑底**——不为 detail panel 让路收窄。桌面端仅约束图像 max-width 避免视觉撕裂。

---

## 7. 动画规范

| 时机 | 时长 | 曲线 | Token |
|------|------|------|-------|
| Hero 入场（缩略图 → 全屏）| 240ms | easeInOut | `motion-standard` |
| Hero 出场（全屏 → 缩略图）| 240ms | easeInOut | `motion-standard` |
| AppBar / 工具栏淡入（图像加载完成）| 80ms | easeOut | `motion-instant` |
| 工具栏按钮 press scale 0.98 | 150ms | easeOut | `motion-quick` |
| Swipe-down 拖动 | 跟随手指 | — | — |
| Swipe-down 释放（关闭）| 240ms | easeOut | `motion-standard` |
| Swipe-down 释放（弹回）| 150ms | easeOut | `motion-quick` |
| 加载完成图像 fadeIn | 150ms | easeOut | `motion-quick` |
| BottomSheet 升起（分享警告 / 对比选择）| 240ms | easeInOut | `motion-standard` |
| HanaDialog 升起（删除确认）| 240ms | easeInOut | `motion-standard` |

**绝对禁止**：图像本身 scale > 1 入场弹跳、装饰粒子、图像呼吸 / 闪烁、删除时爆炸 / 翻转、工具栏旋转、双指缩放过程的边界橡皮筋（保留系统默认）。

---

## 8. i18n 注意

- AppBar 日期格式：zh `DateFormat.yMMMEEEEd('zh').format(date)` → "2026年4月28日 周二" / ja → "2026年4月28日 火曜日" / en → "Tue, Apr 28, 2026" —— 在窄屏可能溢出，需 `FittedBox` 或字体降级
- 元数据"4 月 28 日 · 周二 · HRT 第 245 天" zh / "4月28日 · 火曜日 · HRT 245日目" ja / "Apr 28 · Tue · HRT day 245" en —— 长度差异约 ±20%，单行 ellipsis
- "解密中。" / "Decrypting." / "復号中。" —— 中英日均简短
- 错误："无法读取。" / "Cannot be read." / "読み込めません。" + body 描述
- **分享警告（关键文案）**：
  - title: "分享前请确认。" / "Confirm before sharing." / "共有前に確認。"
  - body: "图像将以未加密形式离开本机。\n接收方可以保存、转发、截屏。" / "Image will leave this device unencrypted.\nRecipient can save, forward, screenshot." / "画像は暗号化されずに端末を離れます。\n受信者は保存、転送、スクリーンショットが可能です。"
  - confirm: "确认分享" / "Confirm share" / "共有を確認"
- 删除确认：title "删除这张。" / body "删除后无法找回。"

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — 工具栏按钮 44dp / 返回箭头 44dp / dialog 按钮 44dp / sheet 按钮 44dp |
| Semantics 完整朗读 | ✓ — 图像挂 `Semantics(image: true, label: "私人图像 4 月 28 日 周二 HRT 第 245 天")`（注意：label **不含**"身体 / 私密 / 健康"暗示词，"私人"是中性陈述）；工具栏按钮各自有 tooltip + Semantics label |
| 焦点顺序 | 返回箭头 → AppBar 标题 → 删除 → 分享 → 对比 → 图像（双指缩放）→ 底部元数据 |
| prefers-reduced-motion | ✓ — Hero 共享元素禁用 / Swipe-down 禁用 / 加载进度条降级为静态文字 |
| 对比度 | ✓ — onPrimaryDark 雪宣 #FBF8F2 on 黑底 21:1（AAA 顶级）/ 元数据 70% 雪宣 14.7:1（AAA） |
| 屏幕阅读器全屏图像 | 用户开启 VoiceOver / TalkBack 时，自动朗读 Semantics label + 元数据 |
| 跨性别敏感性 | ✓ — Semantics label 不暴露"身体 / 健康 / 私密"；分享警告必须显式确认；保存到相册按钮明确拒绝 |

---

## 10. 自我 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处）| ✓ | 全屏黑底主基调，黛蓝仅在加载进度条 + 分享警告 sheet「确认分享」按钮（按需出现），≤ 2 处。 |
| 2. 调和层次胜过投影 | ✓ | 全屏零层次（图像是唯一焦点）。删除底部白 panel + boxShadow + 24px 圆角 + 中央 spinner 圆容器。BottomSheet 是唯一允许 elev-high 例外。 |
| 3. 编辑级不对称 | ✓ | 元数据左对齐 32px（不居中）；错误态文字左对齐；图像本身居中是用户预期合理（不算居中懒惰）。 |
| 4. 慢节奏与留白 | ✓ | 全屏沉浸即最大留白；元数据单行不堆叠；间距 token 化（spacing.sm/md/lg）；删除 v1 拼凑值 4 / 12 / 28。 |
| 5. 内容即装饰 | ✓ | 删除 photo_outlined / broken_image / spinner 圆容器三处装饰；图像本身就是内容；文字态加载 / 错误"解密中。" / "无法读取。"。 |

**自审遗留风险**：
- 工具栏按钮的 `transparentDark` variant 是新需求（components/top-bar.md 中需补充）—— PR 1 实施前需先扩 HanaTopBar 组件
- 分享流程的 `Share.shareXFiles` 需要将解密图像写入临时文件 —— **临时文件清理是安全关键**：必须在 share 完成 / 取消 / app 后台时立即删除（不可依赖系统清理）
- "HRT 第 N 天" 派生需 PhotoEntry 关联到 user.hrtStartDate —— Photo domain entity 需扩展或在 presentation 层 join
- Swipe-down 关闭手势与 InteractiveViewer 双指缩放可能冲突（缩放后向下 pan 不应触发关闭）—— 需 GestureRecognizer 优先级处理
- 黑底全屏在系统 dark mode 下仍是黑底（不变），但顶栏 `transparent` 透出黑底正确 —— 但 light mode 下 photo-view 强制黑底，与系统 mode 冲突时需处理 status bar 颜色（强制走 dark icons）
- 对比模式（P2）的 spec 单独编写 —— 当前 photo-view 仅占位"对比"按钮触发选择 sheet

---

## 11. 与 critique-v1 的 13 个 P0 逐项消除

| critique-v1 P0 | v2 处理 |
|---------------|--------|
| 1. 删除底部白色固定 panel | **删除**，全屏黑底沉浸 + 元数据浮底单行 |
| 2. 删除 panel boxShadow + 24px 圆角 | 全屏零层次 |
| 3. 删除占位 220×220 灰盒 + photo_outlined 大图标 | 改半透明 thumbnail 显示 + 屏底 1px progress + 文字"解密中。" |
| 4. 删除中央 spinner 黑半透明圆容器 | 改屏底 1px primary 横条 indeterminate |
| 5. 删除"文件大小"显示 → 改"HRT 第 N 天" | 用户真正关心的对比锚点（mono 副行） |
| 6. AppBar 走 `HanaTopBar transparent` | 透明顶栏 + onPrimaryDark 文字 |
| 7. 删除 broken_image 错误图标 | 改文字态"无法读取。" + body 描述 + ghost 重试雪宣文字 |
| 8. 备注内容升起 `HanaBottomSheet.info` | 按需查看不常驻占屏（备注按钮：右上工具栏增加 P2 / 或长按图像触发 P2） |
| 9. 删除走 `HanaDialog.confirmDestructive` | 朱砂"删除"按钮替换 Material AlertDialog |
| 10. 加分享入口 + **隐私警告 BottomSheet** | "图像将以未加密形式离开本机" 双行警告 + 二次确认（**P0 红线**） |
| 11. 加对比入口 → 选另一张 sheet | 占位 BottomSheet（对比模式 P2 单独 spec） |
| 12. `HanaColors.*` → `HanaTokens.*(context)` | 全切单轨 API + onPrimaryDark |
| 13. 标题日期格式 `DateFormat.yMMMEEEEd(localeName)` | locale-aware 替换写死 'yyyy.MM.dd' |

> **额外消除（critique-v1 P1 顺带处理）**：
> - swipe-down 关闭手势新增
> - 元数据左对齐 32px
> - 间距值 4 / 12 / 28 全部 token 化
> - AppBar `centerTitle: false`
> - 双指捏合 maxScale 4 保留（已合规，不删）

> **明确拒绝（P2 阻止项）**：「保存到相册」按钮 —— 工程师在未来需求中**必须拒绝**该按钮的添加，因身体照片不应导出到系统相册。

—— 完 ——
