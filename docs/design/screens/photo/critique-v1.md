# Photo 屏（网格）v1 现状 critique

> Generated 2026-04-29 by AI design review against DESIGN.md v2 + tokens.md + principles.md
> 屏幕：lib/features/photo/presentation/pages/photo_page.dart
> 用户场景：HRT 用户在私密时刻打开身体变化对比工具 → 翻看按时间排列的加密照片 → 拍摄 / 导入新照片 → 长按删除
> 重设计阶段：Phase 3.1 Pilot Wave critique-v1（Photo 主屏）

## 1. 当前实现概要

photo_page.dart 是一个 `Scaffold` + `AppBar`（标题 `l10n.photoGallery` + 右上角 `Icons.add_a_photo_outlined` IconButton）+ `BlocBuilder` 切五态的标准 Material 实现。loaded 态走 `GridView.builder` 渲染 **2 列 0.78 长宽比卡片**（80-86），每张卡片 `_PhotoGridItem`（301-383）：surfaceContainerLowest 实色填充 + **20px 圆角** + `boxShadow(black @15alpha, blurRadius 18, offset 0,8)` 装饰投影 + `Hero(tag: 'photo-${entry.id}')` 包 `Image.memory` 缩略图 + 右下角一颗黑色半透明 pill（`Colors.black.withAlpha(150)`，999 圆角）打日期"yyyy.MM.dd"白字。无缩略图时显示 `_PhotoThumbnailPlaceholder`：`primaryContainer → surfaceContainerHigh` 对角线渐变 + 中央 spinner（385-410）。空态走 `_PhotoEmptyState`：120dp 黛蓝圆形容器 + `Icons.lock_person_outlined` 56dp 黛蓝大图标 + 标题 + 描述（210-262）。新增走 `showModalBottomSheet` 标准 Material 双 ListTile（拍摄 / 从图库选择，177-207）。

## 2. 违规点逐项（按 v2 5 原则）

### 原则 1：一抹强色（黛蓝 ≤ 3 处/屏）

- 现状：① 空态 120dp 黛蓝圆容器（227-239）面积 ≈ 120×120 = 14400px²，远超"≤ 屏宽 30%"硬规则；② 空态中央 56dp `Icons.lock_person_outlined` 黛蓝填充（234-238）；③ AppBar 右上 add_a_photo IconButton 默认走 primary（51-55）；④ 缩略图 placeholder 用 `primaryContainer → surfaceContainerHigh` 对角线渐变（392-399），渐变面积 = 单卡 100% 即多卡未加载时整屏黛蓝光带——网格屏首屏会出现 4-6 处黛蓝渐变块。
- 违规：黛蓝可见点 ≥ 4-6 处（多卡 placeholder + 空态大圆 + 空态大 icon + AppBar action），严重稀释稀缺色；锁形 icon `lock_person_outlined` **直接暴露"私密 / 健康 / 隐私"语义**——跨性别敏感性 P0 红线（参考 lock-screen critique 的 shield_moon 删除原则）。
- 优先级：P0
- 改动建议：删除空态圆形大容器 + 锁形大图标，改 `HanaEmptyState.page` 文字态 "图册空白。" + body-sm "记下第一张，对比由此开始。"；缩略图 placeholder 改 `surfaceContainerLow` 实色 + 极弱 spinner（无渐变）；AppBar action 删除（拍摄入口下移到底部 sticky CTA）。

### 原则 2：调和层次胜过投影

- 现状：① 每张卡片 `boxShadow(black @ 15alpha, blurRadius 18, offset 0,8)`（326-332）—— 在 N 张网格上累积 N 条阴影，整屏视觉嗡鸣；② 缩略图右下角 pill `Colors.black.withAlpha(150)` 999 圆角（354-358）—— 黑色块面 + 强圆角是 Instagram / 相册 app 视觉惯例，与杂志感冲突；③ 卡片 20px 圆角（321、325、335）—— 远超 v2 `r-card=4` 标准，Material 圆润感明显；④ 缩略图 placeholder 双色对角线 `LinearGradient`（392-399）—— v2 严禁渐变。
- 违规：BoxShadow + 大圆角 + 渐变 + 黑色半透明 pill 四项装饰承担层次——v2 严禁清单触犯 4/4。
- 优先级：P0
- 改动建议：删除全部 boxShadow；圆角 20 → 4（`HanaTokens.radius.card`）；删除 placeholder 渐变（改 surfaceContainerLow 实色）；删除右下角黑 pill —— 日期挪到**月份章节标题**（`HanaSectionHeader`），缩略图本身不打日期。

### 原则 3：编辑级不对称（左对齐 32px，避免居中）

- 现状：① AppBar 居中标题（默认 Material AppBar `centerTitle` 平台相关，iOS 居中、Android 左对齐——视觉不一致）；② 空态整段 `MainAxisAlignment.center` + `textAlign: TextAlign.center`（225、247、255）—— v2 严禁的居中懒惰；③ GridView padding 16（79）未达 v2 spacing.lg=32；④ **2 列网格本身是镜像对称布局**——缩略图栅格在响应式断点上未做单列变体，桌面会出现 2 列巨缩略图。
- 违规：居中空态 + 16px padding + 无月份章节标记 = 完全平铺无章节节奏，与 timeline / today 屏的"年表 / 章节"叙事脱节。
- 优先级：P0
- 改动建议：AppBar 走 `HanaTopBar.defaultBar` `centerTitle: false`，hero 标题左对齐 32px；空态左对齐（不 textAlign center）；padding 16 → 32 (lg)；网格在 mobile 3 列 / tablet 4 列 / web 5 列（更密——身体对比工具用户期望"可一眼扫几个月"），但每月之间插 `HanaSectionHeader`「2026 · 4 月」断节奏。

### 原则 4：慢节奏与留白

- 现状：① GridView padding `EdgeInsets.all(16)`（79）—— 16 不在 v2 推荐尺度（应为 32 lg 屏边 + 16 md 卡间）；② 卡间 `crossAxisSpacing: 12, mainAxisSpacing: 12`（82-83）—— **12 是 v2 故意删除的间距值**（强制设计师在 16/32 之间二选一）；③ AppBar 之下立刻接网格无 hero 留白；④ 无月份章节断点 —— 一屏可能堆 6-9 张缩略图，无段落呼吸。
- 违规：12 不在 token；padding 16 < lg 32；无 hero / 无章节断点 —— 杂志节奏全失。
- 优先级：P1
- 改动建议：卡间 12 → 16 (md)；屏边 padding 16 → 32 (lg)；首屏顶部 64 (xl) 留白后大字 hero「图册。」+ 副行 mono "{count} 张　始于 {date}"；按月份做章节断点（`HanaSectionHeader` 上下 lg=32 留白）。

### 原则 5：内容即装饰

- 现状：① `Icons.lock_person_outlined` 锁形 hero icon（234）—— **跨性别敏感性 P0 红线**：把 app 视觉上烙印为"隐私 app / 私密内容 app"，旁观者扫一眼即识别；② `Icons.add_a_photo_outlined` AppBar 装饰 action icon（53）—— v2 优先文字 CTA；③ `Icons.camera_alt` / `Icons.photo_library` BottomSheet 装饰 icon（188、196）—— Material 标准但非 v2 调性；④ 文案 `photoGallery` "我的相册" / `photoEmptyTitle` 第二人称鼓励语（沿 v1 樱色调性）。
- 违规：锁形 hero icon 是**整个 app 跨性别敏感性最高的反例**——它既泄露"我有秘密"又用 Material 装饰图标承担情感。其余 icon 装饰为 v2 普遍违规。
- 优先级：P0
- 改动建议：删除锁形 icon（保护用户在公共场合打开 app 的安全）；AppBar action icon → 删除，CTA 下移底部 sticky `HanaButton.primary` "记一张"；BottomSheet 用 `HanaListItem` 文字 + 简洁 leading（或纯文本）；文案改"图册。" / "图册空白。" / "记下第一张，对比由此开始。"（第三人称编辑陈述 + 句号）。

## 3. 7 个评审维度

### 可用性
身体变化对比是 photo 屏的核心动作，但 v1 网格无任何"对比"入口——长按只能删除，点击进单张查看。用户在多月对比身体变化时需要反复 back / forward，体验破碎。建议进入对比模式（选第一张 → 显示半屏 picker 选第二张 → 进 photo-view 双图对比）。Filter 维度（按月份 / 按 tag）目前完全缺失，超过 50 张照片后查找特定时间点变得困难。

### 层次
v2 要求 4 级 surface。当前实现：`background` + `surface` AppBar + `surfaceContainerLowest` 卡片底——只用 3 级，且卡片靠 boxShadow + 大圆角伪造抬起。零 surface 阶差使用，月份章节断点缺失。

### 一致性
与 DESIGN.md 偏差：① 全部用 `HanaColors.*`（v1 樱色调色板）未迁 `HanaTokens`；② 圆角 20 / 999 多种值，未对齐 r-card=4；③ 文案"我的相册"未按 v2 编辑体改写；④ BottomSheet 用 Material `showModalBottomSheet` + `ListTile` 未走 `HanaBottomSheet.actionSheet`；⑤ AppBar 直接用 Material `AppBar` 未走 `HanaTopBar.defaultBar`。

### 情感色彩
身体照片是 HanaNote 中**最敏感的内容**。当前 v1 整屏视觉与普通相册 app 完全相同（缩略图网格 + add_a_photo + 锁图标 hero）——既未传达"这是受加密保护的私密空间"的安心感，也通过锁图标暴露了"私密 app"身份。v2 需要做的是**矛盾的统一**：视觉上像普通笔记 app（不暴露身份），文案上含蓄确认隐私（"图像本地加密 · N 张" 底部 mono inkSubdued 状态栏）。

### 暗色模式
`HanaColors.primary / .primaryContainer / .surface / .surfaceContainerHigh / .surfaceContainerLowest / .onSurfaceVariant / .error` 多处静态常量（46、49、231-238、324、396-397、253、283）—— dark 永远走 light 值。`Colors.black.withAlpha(150)` 日期 pill（356）+ `Colors.black.withAlpha(15)` 阴影（328）在暗色背景下行为异常。

### i18n
缩略图日期写死 `DateFormat('yyyy.MM.dd')`（365）不走 locale。`photoGallery` / `photoEmptyTitle` / `photoEmptyDescription` ARB 已存在但调性沿 v1 樱色（鼓励语 + 第二人称）。日文"撮影 / ライブラリから選択"较中文长 ~30%，BottomSheet 标准 ListTile 单行截断风险。

### 响应式
完全未处理 ≥768 tablet / ≥1024 web 断点。GridView 写死 2 列（81）—— 桌面下 2 列巨缩略图（每张 ~960px 宽）阅读体验荒诞。photo 是高频回顾型屏，理应 mobile 3 列 / tablet 4 列 / web 5 列以提供"一眼扫多月"质感。

## 4. P0 / P1 / P2 总清单

**P0（必须 v2 重做）**：
1. 删除 `Icons.lock_person_outlined` 空态锁形 hero icon（**跨性别敏感性 P0 红线**）
2. 删除全部 boxShadow（卡片 326-332）
3. 卡片圆角 20 → 4（`HanaTokens.radius.card`）
4. 删除 placeholder 双色对角线 LinearGradient（392-399）改 surfaceContainerLow 实色
5. 删除右下角黑色半透明日期 pill（350-374）—— 日期挪到月份章节标题
6. 网格列数 mobile 2 → 3，加 tablet 4 / web 5 响应式
7. 加月份章节断点 `HanaSectionHeader`「2026 · 4 月」按月分组
8. 顶部 hero 「图册。」display-xl 宋体左对齐 + 副行"{count} 张　始于 {date}"mono
9. AppBar add_a_photo IconButton 删除，CTA 下移到底部 sticky `HanaButton.primary` "记一张"
10. BottomSheet 拍摄/导入选择器走 `HanaBottomSheet.actionSheet` + 文字主导
11. 全部 `HanaColors.*` → `HanaTokens.*(context)`
12. 文案 "我的相册" / 鼓励语 → "图册。" / "图册空白。" / "记下第一张，对比由此开始。"
13. 加底部隐私状态栏"图像本地加密 · N 张" mono inkSubdued —— 含蓄确认加密保护

**P1（强烈推荐）**：
- 屏边 padding 16 → 32（lg）
- 卡间 12 → 16（md）
- 首屏顶部 64（xl）留白
- `DateFormat` 走 locale
- AppBar 走 `HanaTopBar.defaultBar` `centerTitle: false`
- 文字态空态走 `HanaEmptyState.page` 不打 emoji 不打装饰 icon
- 加 filter 入口（按月份 / 按 tag）—— 至少占位

**P2（增强）**：
- 进入"对比模式"流程（多选 2 张 → 跳 photo-view 双图对比）
- 长按手势 → `HanaBottomSheet.actionSheet`（删除 / 分享 / 对比 / 备注）替代当前直接 delete dialog

—— 完 ——
