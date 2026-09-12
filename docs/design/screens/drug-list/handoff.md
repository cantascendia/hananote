# Drug list 屏开发 handoff

> Generated 2026-04-29 from `docs/design/screens/drug-list/spec.md`
> 工程目标：`lib/features/medication/presentation/pages/drug_list_page.dart`
> 配对 spec：`docs/design/screens/drug-list/spec.md`
> 配对 critique：`docs/design/screens/drug-list/critique-v1.md`

---

## 1. 改动总览（What changes）

把 v1 的"带 FAB 的 Material ListView + 4 色 chip 卡 + Switch 启停 + Dismissible 滑删"重写为 v2 的"杂志索引页 + 长按 BottomSheet + HanaDialog 红线确认"。**this is a rewrite, not a refactor**——保留 `DrugListCubit` / `DrugListState` 现有事件契约，**仅 presentation 层从头重做 + DataSource 增 soft delete 字段**。

**删除**：
- `DrugCard` 整个 widget（`lib/features/medication/presentation/widgets/drug_card.dart`）—— v2 改用 HanaListItem，不再保留双 chip / Switch / Card 圆角 16 / outlineVariant 边框
- `_buildDrugItem` 内的 `Dismissible` 直接删（不再 onDismissed → deleteDrug 一步式）
- inline `AlertDialog`（删除确认）—— 换 `HanaDialog.confirmDestructive`
- `FloatingActionButton.extended`（M3 FAB）—— 改屏底 `HanaButton.primary`「添加新药」内联
- AppBar `centerTitle: true` —— 改左对齐
- 节标题 `titleMedium · bold · primary / onSurfaceVariant`（与卡内主标题同字重）—— 换 `HanaSectionHeader` 4px 黛蓝竖线 + label-md +0.6
- DrugCard 内 `_buildChip` 4 色 category（pink/blue/purple/teal）—— 全删，改 mono 文字 subtitle
- DrugCard route icon（vaccines / healing / medication）—— 全删，改 mono 文字途径名
- Switch 启停控件 —— 下沉到长按 BottomSheet，不再常驻

**新增**：
- 三节章节结构：活跃 / 已停用 / 最近删除（可选）
- 长按 `HanaBottomSheet.action-sheet` 操作面板（编辑 / 停用 / 删除 或 恢复 / 删除）
- 软删机制（data 层补 `isDeleted` + `deletedAt` 字段，cubit 加 `restoreDrug` / `permanentlyDeleteDrug`）
- HanaDialog 红线确认（删除 + 永久删除）
- HanaSnackbar 替代 inline ScaffoldMessenger（reorder 后反馈）

---

## 2. 关键依赖（Components needed）

### 已有 v2 components
- `HanaTopBar.default`（components/top-bar.md）
- `HanaCard.list` + `HanaCard.flat` variant（components/card.md）
- `HanaButton.primary` + `HanaButton.ghost`（components/button.md）
- `HanaDialog.confirmDestructive`（components/dialog.md）
- `HanaBottomSheet` variant=action-sheet（components/bottom-sheet.md）
- `HanaErrorState` / `HanaLoadingView.block` / `HanaEmptyState.page`

### v1.1 待补（drug-list 屏抢跑使用，与 Profile 共享同款临时锚点）
- **`HanaListItem`** — variants: `withSubtitle + chevron` / `flat` / `withTrailingAction`；padding horiz 24 / vert 20（活跃）或 16（停用紧凑）；**无前置彩色 icon 容器**；支持 onLongPress
- **`HanaSectionHeader`** — label-md +0.6 inkSecondary + 4px 黛蓝竖线（覆盖首行高 16px）；与 today / profile 屏共用同款实现
- **`HanaSnackbar.show`** — 替代 inline `ScaffoldMessenger` 调用

> ⚠ 工程实施时若 HanaListItem / HanaSectionHeader 尚未落 lib，drug_list_page 内可临时 inline 实现，但 **必须** 严格遵守本 handoff §3 视觉规范，且抽到 `lib/features/medication/presentation/widgets/` 私有文件，**不**回退到 ListTile / `DrugCard` 旧实现。Phase 4 再迁出。

---

## 3. 视觉契约（不可妥协项）

| 项 | 值 / Token |
|---|---|
| Scaffold bg | `HanaTokens.background(context)` |
| AppBar bg | `HanaTokens.surfaceContainerHigh(context)`（无 blur） |
| 列表卡 bg | `HanaTokens.surfaceContainerLowest(context)` |
| 列表卡 radius | `HanaTokens.radius.card` = 4（**禁** 16） |
| 列表卡 elevation | 0（**禁** BoxShadow） |
| 列表卡 border | none（**禁** outlineVariant 50% alpha border） |
| 屏幕水平 padding | `HanaTokens.spacing.lg` = 32（**禁** 16） |
| Hero 顶部留白 | `HanaTokens.spacing.xl` = 64 |
| Hero 字体 | `display` (32·42·-0.3) 宋体 Medium / Spectral SemiBold |
| Hero 副行 | `mono` JetBrains Mono Light（"共 N 味　·　活跃 M 味"） |
| Hero → 第 1 节 | `spacing.xl` = 64 |
| 节间留白 | `spacing.lg` = 32 |
| 章节标题 → 列表卡 | `spacing.md` = 16 |
| 列表项内 padding（活跃）| horiz 24 / vert 20 |
| 列表项内 padding（停用紧凑）| horiz 24 / vert 16 |
| 列表项 separator | **零 1px 实线**——靠 surface 阶差或 spacing.sm 8 |
| 章节标题字体 | `label` 12·16·+0.6 Medium，inkSecondary |
| 章节竖线 | 4px wide × 16px tall（首行高），color = `HanaTokens.primary(context)` |
| 活跃项 title 字号 | `title` 18·26·0 Regular（**禁** w800 bold） |
| 活跃项 subtitle | `body-sm` 13·20 inkSecondary（剂量数值用 mono 14） |
| 停用项 全文 | `body` 15·24 inkSecondary 紧凑一行 + 左侧 1px 淡墨竖线 |
| chevron | size 16, color `inkSecondary` @ 60% |
| 停用项 chevron | **不显示**（褪色项不可点击编辑路径） |
| 「添加新药」CTA | `HanaButton.primary` 44dp 高，左对齐 spacing.lg，**不** fullWidth |
| 「添加」AppBar trailing | `HanaButton.ghost` mini，文字"+ 添加" |
| 黛蓝出现位置 | ① 章节竖线 ② 「添加新药」primary CTA ③ 底栏 active tab 下划线 = 共 3 处 |
| 朱砂出现位置 | HanaDialog 删除按钮文字 + 永久删除（不算黛蓝配额） |

---

## 4. 数据契约（Bloc / Cubit）

**沿用现有**：`DrugListCubit` + `DrugListState`，**扩展**而非重写。

**Cubit 现有方法**（保留）：
- `loadDrugs()` — 初始化
- `addDrug(Drug)` — 新增
- `updateDrug(Drug)` — 更新
- `deleteDrug(String id)` — **改语义为软删**（设 isDeleted=true + deletedAt=now）
- `toggleDrugActive(Drug)` — 启停切换

**Cubit 新增方法**：
- `restoreDrug(String id)` — 软删恢复（isDeleted=false，但保持 isActive=false 进入"已停用"节）
- `permanentlyDeleteDrug(String id)` — 真硬删（仅"最近删除"节调用）
- `purgeExpiredSoftDeletes()` — 启动时调用，清除 deletedAt > 7 天的记录（可选 v1.2 加）

**State 字段需补**：
- `List<Drug> drugs` 现有字段保留，但 `Drug` entity 新增 `bool isDeleted` + `DateTime? deletedAt`（`drug.dart` 改 freezed 后 `flutter pub run build_runner build`）
- presentation 层 derive：`activeDrugs` = `where !isDeleted && isActive`；`inactiveDrugs` = `where !isDeleted && !isActive`；`recentlyDeletedDrugs` = `where isDeleted` 按 deletedAt 降序

**DataSource 改动**：
- `drug_local_data_source.dart`（sqflite_sqlcipher）schema migration 加 `is_deleted INTEGER DEFAULT 0` + `deleted_at INTEGER`
- `getAllDrugs` 默认仍返回所有（含软删），presentation 层过滤；或新增 `getActiveDrugs` / `getDeletedDrugs` 但当前 cubit 一次性 load 全量更简单

**SnackBar 文案 keys（沿用 ARB，新增）**：
- `drugDeactivated(String name)` = "已停用 {name}"
- `drugDeletedSoft(String name)` = "已删除 {name}，7 日内可恢复"
- `drugRestored(String name)` = "已恢复 {name}"
- `drugDeletedPermanent(String name)` = "已永久删除 {name}"

**新增 ARB keys**（lib/core/l10n/arb/app_{en,zh,ja}.arb 三语同步）：
- `drugSectionActive` / `drugSectionInactive` / `drugSectionRecentlyDeleted`
- `drugCountSummary(int total, int active)` = "共 {total} 味　·　活跃 {active} 味" / "{total} total · {active} active" / "全 {total} 件　·　服用中 {active} 件"
- `drugAddNew` / `drugEdit` / `drugDeactivate` / `drugRestore` / `drugDelete` / `drugDeletePermanent`
- `drugDeleteConfirmTitle(String name)` / `drugDeleteConfirmMessage`
- `drugPermanentDeleteConfirmTitle(String name)` / `drugPermanentDeleteConfirmMessage` = "永久删除后不可恢复。"
- `drugDeactivateConfirmTitle(String name)` / `drugDeactivateConfirmBody`
- `drugListEmptyTitle` = "无药记录。" / `drugListEmptyMessage` = "添加你的第一味药品。"

---

## 5. 路由契约

- AppBar 无 leading（root tab 子级）/ trailing 单一 ghost「+ 添加」→ `context.push('/add_drug', extra: cubit)`
- 列表项跳转：
  - 活跃项 onTap → `/edit_schedule/${drug.id}`
  - 活跃项 onLongPress → HanaBottomSheet（不跳路由，inline 操作）
  - 停用项 onTap **不跳路由**（褪色项无编辑路径）
  - 停用项 onLongPress → HanaBottomSheet（恢复 / 删除）
- 「添加新药」屏底 CTA → `/add_drug`
- 「恢复」mini button → cubit.restoreDrug（不跳路由）
- 删除确认 → HanaDialog（不跳路由）

---

## 6. P0 工程债清单（必须随本屏一并解决）

1. **删除 `DrugCard` 整个 widget**（widget-pattern-inventory 单点专属抽象）—— `lib/features/medication/presentation/widgets/drug_card.dart` 整文件删除，引用方 inventory_page / today_page 等若复用需迁移到 HanaListItem
2. **删除 4 色 category Material 标准色硬编码**（DESIGN §1 / tokens §1）—— `Colors.pink / blue / purple / teal` 全部从 medication feature 移除
3. **删除 inline AlertDialog**（widget-pattern-inventory P1-#7）—— `_buildDrugItem` 内 `showDialog → AlertDialog` 替换为 `HanaDialog.confirmDestructive`
4. **删除 FloatingActionButton.extended**（DESIGN §6）—— Drug list / Drugs 入口屏 FAB 全删，改屏底 inline HanaButton.primary
5. **删除 Dismissible 直接删语义**——保留 onDismissed 触发 BottomSheet（不直接删）；或彻底删除 Dismissible 仅留长按
6. **删除 `genericName` 副行 bodyMedium**——改 body-sm + inkSecondary

---

## 7. 测试清单（QA）

| 测试 | 期望 |
|------|------|
| 首屏渲染 | hero "我的药品" + 副行计数 + 2-3 节列表 + 屏底 CTA，无 FAB，无 Switch，无彩色 chip |
| 一抹强色审计 | 静态截图全屏黛蓝出现 ≤ 3 处（章节竖线 + primary CTA + tab 下划线） |
| 活跃项点击 | press scale 0.98 → push `/edit_schedule/{id}` |
| 活跃项长按 | HanaBottomSheet action-sheet 上移 240ms，3 个选项（编辑 / 停用 / 删除） |
| 停用操作 | 选「停用」→ cubit toggleDrugActive → 列表 reorder 600ms 该项从活跃节迁到已停用节 → snackbar |
| 删除操作 | 选「删除」→ HanaDialog destructive → 确认 → 软删 + reorder 到「最近删除」节 → snackbar 提示 7 日 |
| 取消删除 | HanaDialog 取消 → sheet 关闭 → 列表无变化 |
| 停用项长按 | BottomSheet 2 选项（恢复 / 删除） |
| 恢复操作 | 选「恢复」→ cubit toggleDrugActive → reorder 到「已停用」节（不进活跃，需用户手动激活） |
| 最近删除「恢复」按钮 | 点击 → cubit.restoreDrug → reorder 到「已停用」节 → snackbar |
| 最近删除「永久删除」 | 长按 → BottomSheet → HanaDialog 二次确认 → cubit.permanentlyDeleteDrug → 从最近删除节消失 |
| 添加新药 CTA | 点击 → `/add_drug` 路由 |
| AppBar trailing「+ 添加」 | 与屏底 CTA 同路由（双入口冗余可接受） |
| 滑动手势 | 向左滑 50% 阈值 → 触发 BottomSheet（不直接删）；< 50% 回弹 |
| 空态 | 无任何药记录 → HanaEmptyState.page："无药记录。" + secondary「添加第一味」 |
| i18n 三语 | en "Recently deleted" / zh "最近删除" / ja "最近削除"——节标题不溢出，必要时 Wrap 2 行 |
| dark mode | hero 字符 #E8E4DB on #1C1A18 = 12.6:1，所有列表项对比度 AAA |
| reduced-motion | reorder 瞬时；列表入场 fadeIn 跳过 |
| 触控目标 | 列表项 ≥ 64dp / CTA 44dp / 「恢复」mini 44dp（提升） |
| 软删 7 日清理 | （v1.2）启动时 purgeExpiredSoftDeletes 移除 deletedAt > 7 天的记录 |

---

## 8. 实施顺序建议（PR 拆分）

1. **PR-1（data 层 + entity）**：`Drug` entity 加 isDeleted / deletedAt（freezed regenerate）+ DataSource schema migration + Cubit 加 restoreDrug / permanentlyDeleteDrug + 单测覆盖软删与恢复路径
2. **PR-2（本屏主体）**：`drug_list_page.dart` 重写 + 删除 `drug_card.dart` + 新 ARB keys + HanaListItem / HanaSectionHeader inline 临时实现（私有 widget 文件）
3. **PR-3（依赖组件）**：HanaListItem / HanaSectionHeader / HanaSnackbar 抽取到 `lib/core/widgets/`（与 Phase 4 + Profile PR-2 合流）
4. **PR-4（最近删除节启用）**：v1.2 加软删过期清理 + 首屏 onboarding tooltip "长按药品可管理"

> **不在本屏 PR 范围**：
> - `/add_drug` 添加流程屏重设计（Phase 3.6 单独）
> - `/edit_schedule/{id}` 编辑流程屏重设计（Phase 3.6 单独）
> - DrugCard 在 inventory_page / today_page 的引用迁移（这些屏 phase 各自处理）

---

## 9. 与 critique-v1 的 8 个 P0 逐项消除

| critique-v1 P0 | v2 处理 |
|---------------|--------|
| 1. DrugCard 圆角 16 + outlineVariant 边框 | 删 DrugCard，改 HanaListItem in HanaCard.list（radius 4 / 无边框 / surfaceContainerLowest）|
| 2. 4 色 category chip（pink/blue/purple/teal）| 全删，category 改 label 文字 inkSecondary 进 subtitle |
| 3. chip 三件套（alpha bg + alpha border + bold colored text） | 全删，subtitle 用 mono 数值 + body-sm 文字中点分隔 |
| 4. Switch 启停常驻卡内 | 下沉到长按 BottomSheet，主路径不再有 Switch |
| 5. Dismissible 滑删 + 内嵌 AlertDialog | Dismissible 仅触发 BottomSheet 不直接删；AlertDialog 换 HanaDialog.confirmDestructive |
| 6. 节标题与卡内主标题同字重同色 | 换 HanaSectionHeader（label-md +0.6 + 4px 黛蓝竖线 16px 高）|
| 7. FloatingActionButton.extended | 删 FAB，改屏底内联 HanaButton.primary「添加新药」+ AppBar ghost trailing |
| 8. 空态 Center+Icon 64+titleMedium | 换 HanaEmptyState.page（icon 32 + headline + body-sm + secondary 按钮）|

> **额外消除（critique-v1 P1 顺带处理）**：
> - 卡间间距 8 → 32（活跃）/ 16（停用紧凑）
> - 已停用药改 HanaCard.flat 褪色态 + 1px 淡墨竖线
> - 新增"最近删除"第三节（v1.2，软删机制就绪后启用）
> - genericName 字号 bodyMedium → body-sm + inkSecondary

---

— 完 —
