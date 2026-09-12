# Inventory 屏 v1 critique（针对 v2 编辑级东亚方向）

> 对象：`lib/features/medication/presentation/pages/inventory_page.dart`（209 行，单文件即全部 UI）
> 视角：DESIGN.md v2 + principles.md（一抹强色 / 调和层次 / 编辑级不对称 / 慢节奏 / 内容即装饰）
> Pilot Wave: 阶段 3.x.a — 与 today / data 同批节拍

---

## 1. 当前实现概要

inventory_page.dart 是 medication 模块下最薄的一屏：`AppBar(title: l10n.inventory, centerTitle: true)` → `BlocBuilder` → `ListView.separated`，每条用 `_buildInventoryCard` 渲染一张 Material `Card`（`elevation: 0`、`borderRadius: 16`、`color: surfaceContainerLow`）。卡内 `Row`：左侧 Column 装 `drug.name` (titleMedium bold) + `daysRemaining` 文案；右侧条件渲染一颗 `errorContainer` 底色 + `warning_amber_rounded` icon + 加粗 "lowStock" 文字的 stadium pill chip。点击整张卡 → `_showUpdateDialog` 弹标准 `AlertDialog` + 单个 `TextField` + Cancel / Save。低库存判定来自 `CheckInventory` 用例：`daysRemaining != null && daysRemaining < 14` 一刀切。

文件头第 2 行残留一段 release-prep 自白：「InventoryPage still relies on a deprecated color API and a few long medication labels until the post-release UI cleanup」+ `// ignore_for_file: deprecated_member_use, lines_longer_than_80_chars`——这条注释本身是 v2 重写的最强外部信号。

---

## 2. 违规点逐项（按 v2 5 原则）

### 原则 1：一抹强色（黛蓝 ≤ 3 处/屏）

- 现状：低库存条目同时出现三种"强信号"——① 卡片 border `errorContainer.withOpacity(0.5)` 2px（line 86-88）② 「剩余 N 天」文字染 `colorScheme.error`（line 113-114）③ 右侧 `errorContainer` 实色 stadium pill + `warning_amber_rounded` icon + 加粗 "lowStock" 文字（line 129-156）。一张卡里红色出现 3 次。
- 违规：v2 朱砂 `#9B2A2A` 仅限 **destructive**（删除确认 / 数据丢失警告）。"剩余 7 天" 不是 destructive，是 warning——data spec §6 已立法："偏离用黛蓝 mono 数字，仅 critical 加一行朱砂注脚 `建议补货。`，朱砂只落在文字注脚上"。当前实现把整套朱砂语法误用成 warning 主色。再加上整屏完全没有黛蓝，用户翻一页只看到红 + 灰，毫无品牌锚点。
- 优先级：P0
- 改动建议：删除 stadium pill chip + 卡片 error border + 数字染 error；改为 data spec §6 的三段染色——> 14 天 mono ink；7-14 天 mono 黛蓝（一抹强色）；< 7 天 mono 黛蓝 + body-sm 朱砂注脚 `建议补货。`。

### 原则 2：调和层次胜过投影

- 现状：卡片用 `Card` widget（line 79）—— Flutter 默认即便 `elevation: 0` 仍带 Material `surfaceTintColor` 渲染，且自带 `Material(type: card)` 包裹会注入隐式 elevation overlay；卡片 `borderRadius: 16`（line 83）+ side `BorderSide` 1-2px outlineVariant @ 50（line 86-89）—— v2 严禁卡片用边框分隔（只有 outline focus 是唯一例外）+ 严禁 ≥ 8px 圆角。`AppBar` 默认依赖 Material 主题，未走 `HanaTopBar` 实色 surfaceContainerHigh + 滚动 outline 模式。
- 违规：边框定义层级 + 16px 软糖角 + Material `Card` 默认 elevation 注入。
- 优先级：P0
- 改动建议：替换为 `HanaCard.tappable`（4px radius、surfaceContainerLowest、零边框、零阴影）；`AppBar` 换 `HanaTopBar`（实色米灰、无 blur、无 leading 装饰 icon）。

### 原则 3：编辑级不对称（左对齐 32px、避免居中）

- 现状：① `AppBar` 用 `centerTitle: true`（line 37）—— v2 杂志感屏全部要左对齐 hero，`centerTitle` 是 v1 信纸感残留；② `ListView.separated` `padding: EdgeInsets.all(16)`（line 50）—— 水平 16 错值，v2 要 32 (lg)；③ 屏顶无 hero 段，从 AppBar 直接进列表，缺少 "本期补货。"/"库存。" 编辑级开篇；④ 没有章节标题（缺 HanaSectionHeader 4px 黛蓝竖线），所有库存项与"历次补货"扁平展开（事实上历次补货功能 v1 完全没实现，是个 spec 缺口）。
- 违规：标题居中、padding 错值、缺 hero、缺章节段落标记。
- 优先级：P0
- 改动建议：`HanaTopBar.default` title `库存` 左对齐 16；列表 padding 改 `lg=32`；屏顶加 `display-xl` "本期补货。"/"库存。" hero + 副行 `共 N 项・低库存 M 项`；用 `HanaSectionHeader` 划「当前库存」/「最近补货」两段。

### 原则 4：慢节奏与留白

- 现状：列表项之间 `SizedBox(height: 12)` 分隔（line 53）—— **12 是 v2 token 表故意跳过的禁用值**（v2 间距：4/8/16/32/64/128）；卡内 padding 16 + 副行 spacing 4 是合规；但卡间 12 紧挨卡内 16 也未跨级。屏顶无任何留白，AppBar 紧贴第一张卡。
- 违规：① 12 非 token；② 缺顶部留白（spec 要求 ≥ xl=64）；③ 间距未跨级。
- 优先级：P1
- 改动建议：卡间 16 (md)；段落间 32 (lg)；屏顶留白 64 (xl)；副行行间 4 (xs)。

### 原则 5：内容即装饰

- 现状：① 低库存 stadium pill 内嵌 `Icons.warning_amber_rounded`（line 142-146）—— icon 承担警示情感；② 无 mono 字体——"剩余 N 天" 用 `bodyMedium` 默认字体（CJK 走 fallback）—— v2 强约束「数值 / 时间戳必须 JetBrains Mono Light」；③ 更新 stock 用标准 `AlertDialog`（line 174）—— v2 严禁 iOS / Material 弹窗，全部走 `HanaBottomSheet`；④ `_showUpdateDialog` 表单只有一个 TextField，连"上次补货时间 / 备注 / 单位选择"都没有，是个半成品；⑤ AppBar 缺 ghost「+」入口（无法在屏内新增药品，需要绕到 drug_list）。
- 违规：装饰 icon 承担情感、缺 mono 字体、AlertDialog 替代 BottomSheet、表单功能残缺、缺操作入口。
- 优先级：P0（mono 字体 + 弹窗替换）/ P1（icon 删除 + 表单丰富）
- 改动建议：删 warning icon；数字全部走 mono；`_showUpdateDialog` 重写为 `HanaBottomSheet.form` —— 标题「补货 · {drug.name}」+ 「今日补 N 片」mono TextField + 「备注」可选输入 + 主按钮「记入」+ ghost「取消」。

---

## 3. 7 个评审维度

### 可用性
核心动作"补货登记"埋在"点击整张卡 → 弹 dialog → 输入新数量 → 保存"四步——而且是**用户自己**输入"新数量"（而非"今日补了多少"），逻辑反人类：用户记得"今天又买了 30 片"远比记得"现在剩 47 片"容易。语义错位 + 步数偏多。建议改为 `HanaBottomSheet` 内主输入是 `+N` 增量、副位 readonly 显示当前总数，存储侧 `qty = current + delta`。"阅读提醒/通知设置"入口当前完全缺失，用户调整低库存阈值需要去 settings 屏摸索。

### 层次
当前只用了 1 级 surface（`surfaceContainerLow` 卡片，背景默认）。AppBar 默认透明走 Material，与背景同色不构成 backdrop。低库存靠"红边框 + 红 chip"伪造层次而不是 surface 阶差。完全没实现 v2 4 级 surface 语法。

### 一致性
- 颜色：散用 `colorScheme.error / errorContainer / outlineVariant.withAlpha(50) / onSurface.withAlpha(128)` 等 6 处直接 hex/alpha 调色，**未走 `HanaTokens.*(context)` 单轨**（line 81/86/114/123/137/146）。
- 圆角：卡片 16 / chip 20 / dialog 默认（line 83/137）—— v2 token 表只有 0/2/4/6/16(BottomSheet)。
- 字体：所有文字走 textTheme 默认，**数值未用 mono**——与 today/data spec 立的「mono Light」强约束直接冲突。
- 文案：「库存偏低」「剩余 N 天」「暂无启用药物」未走 v2 编辑体（句号 + 第三人称）。

### 情感色彩
v2 调性：克制·沉静·不矫情。当前一张低库存卡 = 红边框 + 红 chip + 警示 icon + 加粗红字 = 四重警示。这是工具类 app 的「报警面板」语法，不是 HanaNote v2「编辑级私人内刊」的「这一期还剩 5 天，需要补印」的轻陈述语法。改造方向：**库存偏低不是事故，是日常事项**——文案从「lowStock」改「{N} 天后用尽。」（mono N + 句号），低于 7 天再加一行朱砂注脚「建议补货。」——温度藏在文案颗粒度，不靠红色块。

### 暗色模式
颜色全走 Material `colorScheme.*`，主题切换名义上能跑；但 `withOpacity(0.5)` / `withAlpha(50)` / `withAlpha(128)` 这种手动 alpha 在 dark mode 下与背景对比度未验证（暗底 + 红边 50% alpha 经验上偏暗）。`onSurface.withAlpha(128)` 表达"数据不可用" 在 dark 下也容易消失。需切到 `HanaTokens.inkSecondary(context)` 让 token 自己处理 brightness 分支。

### i18n
`l10n.daysLeft({days})` 中文「剩余 N 天」、日文一般写「あと N 日」、英文「N days left」长度差不多，但加上低库存 chip「库存偏低 / 在庫不足 / Low stock」和 update dialog hint「新数量 (mg) / 新しい数量 (mg) / New quantity (mg)」时，长 ja 文案在 stadium pill 里容易被 ellipsis 吞 —— 需 `Wrap` 或换行兜底。

### 响应式
`ListView.separated` 直接撑满宽度，无 `max-width` 约束 —— Web ≥768px 平板 / 1024px 桌面会出现单列拉宽到 1200px+ 的"巨字幅库存表"，杂志感破坏。需 `ConstrainedBox(maxWidth: 720)` 居中。

---

## 4. P0 / P1 总清单

### P0（违规必改 — 阻塞 v2 落地）
1. 颜色 token 全切 `HanaTokens.*(context)`，删除 `colorScheme.error / errorContainer / withAlpha`
2. 删除卡片 `BorderSide` + 替换 Material `Card` → `HanaCard.tappable`
3. 圆角全部收紧到 4 / 6 / 16(BottomSheet)
4. `AlertDialog` 重写为 `HanaBottomSheet.form` 补货登记
5. 数值（剩余天数、当前数量、补货增量）全部走 `mono` JetBrains Mono Light
6. 屏顶加 hero「库存。」+ 副行 + `HanaSectionHeader` 章节段落标记
7. 低库存视觉语法重写：朱砂仅文字注脚「建议补货。」，warning 用 mono 黛蓝数字
8. AppBar 切 `HanaTopBar`，去 `centerTitle`，加 ghost「+」入口

### P1（顺手清理）
- 删除 line 1-3 release-prep 注释 + `ignore_for_file`
- 卡间 12 → 16；屏顶 64 留白；副行 4
- BottomSheet 表单丰富为 +N 增量 + 备注 + 单位
- 增加「最近补货」章节（最多 5 条，HanaCard.flat 列表）
- 增加「通知设置」入口（跳 settings 修改低库存阈值）
- AppBar 文案 + 卡内文案全部切 v2 编辑体（句号 + 第三人称）
- Web ≥768 加 `max-width: 720` 内文页约束

— 完 —
