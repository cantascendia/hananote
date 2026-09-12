# Drug list 屏 v1 设计 critique

> Generated 2026-04-29 from `lib/features/medication/presentation/pages/drug_list_page.dart` + `widgets/drug_card.dart`
> 参照：DESIGN.md v2 / tokens.md / principles.md / widget-pattern-inventory.md
> 配对输出：`docs/design/screens/drug-list/spec.md` + `handoff.md`

---

## 0. 一句话总结

v1 Drug list 是「**带 FAB 的 Material 3 ListView**」——AppBar 居中标题、节标题用 `titleMedium · bold · primary` 与卡内字争抢、`DrugCard` 圆角 16 + 双色 chip 簇（粉 / 蓝 / 紫 / 青四色 category + 哑光 route icon）+ 右侧 Switch 作为内容控件、Dismissible 红块滑删 + inline AlertDialog——五种装饰语法各自喧哗，活脱脱 Android 工具屏。v2 必须把它压回**杂志的"目录与索引"**：左对齐 hero、章节段落标记、单色克制的列表项、destructive 走 HanaDialog、Switch 下沉到 BottomSheet 二级操作。

---

## 1. 8 个 P0 违规（block reason）

### P0-1 DrugCard 圆角 16 + outlineVariant 50% alpha 边框（principles §2 / tokens §4 双违规）
`Card(radius: 16, side: outlineVariant @ 50)` 同时叠加大圆角 + 实线边框 + `surfaceContainerLow` 三层装饰——v2 圆角全面收紧到 4，列表卡靠 surfaceContainerLowest vs background 6 个明度差，**禁实线边框**。

### P0-2 4 色 category chip（estrogen 粉 / antiAndrogen 蓝 / progestogen 紫 / auxiliary 青）违反"一抹强色"
`_getCategoryColor` 硬编码 `Colors.pink / blue / purple / teal` 四种 Material 标准色，每张卡至少 2 个 chip（category + route）+ inactive 时再加 1 个灰 chip——一屏 5 张卡就 10-15 个彩色 chip，黛蓝瞬间被淹没。v2 哲学：**药品分类不需要颜色编码**——category 用 label 文字 + tracking +0.6 即可，不进调色板。

### P0-3 chip 用 `withAlpha(25)` 底 + `withAlpha(50)` 边框 + 彩色文字三件套
每个 chip 是 `padding 8/4 + radius 8 + 25% alpha bg + 50% alpha border + bold colored text`——v2 全删：chip 改 `label` (12·16·+0.6) inkSecondary 纯文字，**无背景、无边框、无加粗**，chip 间用 `·` 中点分隔成一行 mono 副行（参考 today 屏「2.0 mg　·　涂抹」语法）。

### P0-4 右侧 Switch 暴露在卡内做"启停"控件（principles §1 + UX 双违规）
`Switch(value: drug.isActive, onChanged: ...)` 直接挂在 DrugCard 主行右侧——这把"启停"提到与"药名"同等视觉权重，且 active 态 Switch 用 `colorScheme.primary` 黛蓝，N 张活跃卡 = N 处黛蓝，立刻贬值强色。v2 处理：**启停下沉到长按 / 右键菜单 / 卡内 chevron 二级**——Drug list 主路径是"浏览 + 编辑"，启停是次级操作，不该常驻视觉。

### P0-5 Dismissible 滑删红块 + 内嵌 AlertDialog（widget-pattern-inventory P1-#7）
`Dismissible(background: Container(color: error, Icons.delete))` + `showDialog → AlertDialog(radius 系统默认 24, FilledButton 朱砂)`——v2 工程债之一。AlertDialog 全删，换 `HanaDialog.confirmDestructive`；滑动操作改为长按出 `HanaBottomSheet` action-sheet（含编辑 / 启停 / 删除三选项），避免「滑错就删」的恐慌。

### P0-6 章节标题（"有效 / 已停用"）样式 = 卡内主标题（principles §3 / §5）
v1 节标题用 `titleMedium · bold · primary（有效）` / `bold · onSurfaceVariant（已停用）`——黛蓝 + bold 同时给到节标题，与 DrugCard 主行的 `titleMedium · bold` **同字重同位置同色**，无段落标记语法。换 `HanaSectionHeader`：`label` 12·16·+0.6 inkSecondary + 4px 黛蓝竖线（覆盖首行 16px 高）。

### P0-7 FloatingActionButton.extended「+ 新增」违反"内容即装饰"
v1 用 M3 FAB extended（圆角 16 + elevation 6 + icon + label）漂浮右下——这是 Material 招牌语法，破坏纸感。v2 处理：**新增药** CTA 改为屏幕底部内联 `HanaButton.primary` 或顶部 `HanaTopBar.actions` 单一 trailing「+」（label 文字"添加"，无 icon），FAB 整组件删除（与 DESIGN.md 移除 FAB 一致）。

### P0-8 空态用 `Center + Icon 64 + titleMedium`（components/empty-state.md 违规）
`Icon(medication_outlined, size: 64, color @ 100/255)` + `titleMedium "无活跃药"`——图标过大 + 居中 + 单 title 无 message——换 `HanaEmptyState.page`：icon 32dp 单色线性 + `headline` "无药记录。" + `body-sm` 副行 "添加你的第一味药品。" + `HanaButton.secondary`「添加第一味」。

---

## 2. 5 个 P1 问题

- **P1-1 卡内 padding 16 / 间距 8 是 v2 跨级合规但密度过高** — 5 张卡叠在半屏，无章节呼吸。改卡间 `spacing.lg` 32（活跃组）/ `spacing.md` 16（停用组褪色态紧凑）。
- **P1-2 `DrugCard.onToggleActive(_)` 接收 bool 但不读** — Switch 与 isActive 内联绑定，UI 与 cubit 耦合且无确认二次问询；v2 启停应触发 BottomSheet "停用 {药名}？" 短陈述 + 确认。
- **P1-3 已停用药与有效药同 surface 同视觉** — 仅靠 inactive chip 区分，弱区分。换 `HanaCard.flat` 褪色态：所有文字 inkSecondary，左侧 1px 淡墨竖线（参考 today 屏已服褪色卡），明确"日记语义"。
- **P1-4 缺"已删除（可恢复）"第三组** — Drug 一旦 Dismissible 就硬删，无回收站语义；v2 增加第三章节「最近删除」（可选，软删 7 天保留），列表项 trailing 加「恢复」action。
- **P1-5 ListView padding bottom 88 给 FAB 让位** — FAB 删除后 padding 改 `spacing.xl` 64。

---

## 3. 3 个 P2 问题

- AppBar `centerTitle: true` 居中违反编辑级不对称——改左对齐 32px。
- DrugCard 内 `_buildChip` route icon（medication / vaccines / healing 等）作为彩色装饰存在——v2 列表项前置 icon 一律 `outlined` 单色 inkSecondary @ 60%，且 administration route 应用 mono 文字（"皮下注射" / "经皮贴片"）取代 icon。
- `genericName` 副行字号 bodyMedium = body 15，与主行 titleMedium = title 18 仅 3 字号差 + 颜色差 → v2 用 `body-sm` 13 + inkSecondary 拉开层级。

---

## 4. 整体叙事重写

v1 想说："这是你的药盒，每个药一张彩色 chip 卡片，启停滑动删除——像 Material 工具那样。" v2 应该说："这是这本内刊的'索引'——你正在用什么、你停过什么、你删除过什么；每一行都克制，因为药本身已经够重。"

**视觉重心**：顶部 hero「我的药品」display 32 宋体 + 副行 mono「共 N 味　·　活跃 M 味」左对齐 32px，下方两节列表纵向铺陈：① 活跃 ② 已停用（可选 ③ 最近删除）。**全屏黛蓝 ≤ 3 处**：① 章节竖线（计 1 处段落标记语法） ② 底部「添加新药」`HanaButton.primary`（计 1） ③ 底栏 active tab 下划线（计 1）。Switch 下沉到长按 BottomSheet，不再常驻。删除走 HanaDialog 红线确认，滑动手势保留但仅触发 BottomSheet 不直接删。
