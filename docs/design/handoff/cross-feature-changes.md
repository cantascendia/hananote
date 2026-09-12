# Cross-feature 修复清单（v2 重设计共享改动）

> Generated 2026-04-29
> 收拢自 timeline / today / onboarding / record / data / profile / drug-list / inventory / schedule-editor / add-drug 十屏 spec + handoff
> 目的：把跨 feature / domain / non-screen-local 改动从 22 屏 spec 中抽出来集中调度，避免 UI PR 撞上未迁移的 domain 字段

---

## 1. Domain 层改动（独立 PR 优先实施）

按"血泵风险"排序——P0 都涉及 schema / 序列化 / freezed regen，必须先于 UI PR 落地。

- **[P0]** `lib/features/timeline/domain/entities/enums.dart` — 删除 `TimelineEventType` / `TimelineSubType` 等装饰 getter（`icon: IconData`、`borderColor: Color`、`iconColor: Color` 三处）。**违反 DEC-042/043**（domain 零外部依赖；UI 文案走 `enum_l10n.dart` 扩展）。落点：移到 `lib/features/timeline/presentation/widgets/timeline_event_type_l10n.dart`，提供 `localizedTypeLabel(l10n)` 文字扩展。来源：timeline/spec.md §11 P0-#3。
- **[P0]** `lib/features/medication/domain/entities/medication_schedule.dart` — `WeeklyMedicationFrequency.dayOfWeek: int` 单值 → `daysOfWeek: Set<int>` 多值（freezed sealed class regen）。同步改：DataSource 序列化 `dayOfWeek` 字段 → JSON `daysOfWeek` 数组；`notification_scheduler` 按 daysOfWeek 展开多个 PendingNotification。来源：schedule-editor/handoff.md §1。
- **[P0]** `lib/features/medication/domain/entities/drug.dart` — 新增 `bool isDeleted` + `DateTime? deletedAt`（freezed regen）。drug-list 软删 / 7 日恢复 / 永久删除三态机制。来源：drug-list/handoff.md §4。
- **[P0]** `lib/features/medication/domain/entities/stock_entry.dart` — **新建**。字段：`String id / String drugId / double delta / String? note / DateTime recordedAt`。inventory 屏补货历史与"+N 增量"语义的承载体。来源：inventory/handoff.md §1。
- **[P0]** `lib/features/medication/domain/entities/inventory_level.dart` — **新建** enum `{ample, warning, critical, unknown}`。从 InventoryStatus 派生，UI 染色直接消费。来源：inventory/handoff.md §1。
- **[P0]** `lib/features/auth/domain/entities/onboarding_hrt_status.dart` — **新建** enum `{onHrt, notStarted, prefersNotToSay}`。onboarding 屏 3 三选门控屏 4 是否显示（critique-v1 盲点 #2/#5 修复）。来源：onboarding/spec.md §2 屏 3。
- **[P1]** `lib/features/medication/domain/entities/drug.dart` — 可选扩展 `defaultDosage: double?` / `startDate: DateTime?` / `endDate: DateTime?`，承载 add-drug 起止日 + 模板默认剂量。**推迟到云同步阶段（R52-C）一并设计 schema**，本次 v2 重设计 PR 不强制；过渡期用 `Drug.notes` 字段占位（"起止日：YYYY-MM-DD 至 ——"）。来源：add-drug/handoff.md §3.4 / §4 PR 5。

---

## 2. 数据层改动（sqflite_sqlcipher migration）

- **[P0]** `stock_entries` 新表 + 4 个 sqflite migration step：① `_createStockEntriesTable`（`id TEXT PK / drug_id TEXT FK / delta REAL / note TEXT / recorded_at INTEGER`）② `onUpgrade` v→v+1 分支 ③ 旧版本 db 升级测试 ④ `medication_local_data_source.dart` 增 `addStockEntry` / `getRecentStockEntries`。降级方案：若 R52 周期内来不及做，repo 方法 stub `right([])`，UI 段落整体不渲染（不阻塞 inventory 主重写）。来源：inventory/handoff.md §1 + §5。
- **[P0]** `medication_schedule` JSON schema 新版本 — `dayOfWeek INTEGER` → `days_of_week TEXT`（JSON 数组字符串）。SQL migration 旧 `dayOfWeek=1` → `daysOfWeek=[1]` 单条 UPDATE；回滚路径必测；release.yml 加入 staging 数据库验证步骤（schedule-editor/handoff.md §7 风险 1）。
- **[P0]** `drugs` 表 schema migration — `is_deleted INTEGER DEFAULT 0` + `deleted_at INTEGER NULL`。`getAllDrugs` 默认仍返回所有（含软删），presentation 层过滤 active/inactive/deleted 三节。来源：drug-list/handoff.md §4。
- **[P1]** soft-delete 7 日清理 — 启动时 `purgeExpiredSoftDeletes()` 扫 `deletedAt > 7 天前` 的 drugs 行硬删。可推迟到 v1.2，不阻塞 drug-list 主 PR。来源：drug-list/handoff.md §4。

---

## 3. Repository / Cubit 改动

- **[P0]** `InventoryCubit` — 新增 `addStock(drugId, delta, {note})` 增量语义（不是 reset）+ `loadRecentEntries({limit})`。state 扩展 `criticalCount` + `recentEntries`。来源：inventory/handoff.md §1。
- **[P0]** `InventoryStatus`（`check_inventory.dart`）— 扩展 `currentQuantity` / `unit` / `level: InventoryLevel`。来源：inventory/handoff.md §1。
- **[P0]** `DrugListCubit` — 新增 `restoreDrug(id)` / `permanentlyDeleteDrug(id)`；`deleteDrug(id)` 改语义为软删（`isDeleted=true + deletedAt=now`）。来源：drug-list/handoff.md §4。
- **[P0]** `MedicationRepository` — 扩展 `addStockEntry(StockEntry)` / `getRecentStockEntries({limit})`。来源：inventory/handoff.md §1。
- **[P1]** `OnboardingCubit`（或 `_OnboardingPageState` 内 setState）— 新增 `_hrtStatus: OnboardingHrtStatus?` 字段；屏 3 必选才能离开；onHrt 路径触发屏 4 / 否则跳过。`_drugCategory` / `_drugRoute` 改 nullable + 默认 null（critique-v1 盲点 #3）。来源：onboarding/spec.md §3。
- **[P1]** `_AddDrugPageState` — `_category` / `_route` enum → `enum?`，初值 null；`_genericNameController` rename 为 `_aliasController`；新增 `_dosageController` / `_startDate` / `_endDate` / `_nameError` / `_categoryError` / `_routeError` 字段；删除 `_showManualForm` 双态切换。来源：add-drug/handoff.md §2。
- **[P1]** `ScheduleEditorCubit` — public 接口保持向后兼容；`setFrequency(MedicationFrequency)` 仍是单 setter，但 weekly variant 内 `daysOfWeek: Set<int>` 多值（domain 改动透传）。来源：schedule-editor/handoff.md §1。

---

## 4. Domain enum localizedName 修复（DEC-042/043 系列）

每个 enum 都必须在 `enum_l10n.dart`（或 feature 内对应文件）提供 `localizedName(l10n)` 扩展，UI **禁止**直接读 `.displayName`。

- **[P0]** `DrugCategory.displayName` 直出 → `DrugCategory.localizedName(l10n)`。检查点：`lib/features/medication/presentation/pages/onboarding_page.dart:571`（v1 盲点）、`lib/features/medication/presentation/pages/add_drug_page.dart:355` 附近、drug-list 卡 subtitle、schedule-editor。来源：onboarding/spec.md §10 + add-drug/handoff.md §3.1。
- **[P0]** `AdministrationRoute.displayName` 直出 → `AdministrationRoute.localizedName(l10n)`。检查点：`lib/features/medication/presentation/pages/onboarding_page.dart:606`、add-drug、schedule-editor 路径选择器。
- **[P0]** `DosageUnit.displayName` 直出 → `DosageUnit.localizedName(l10n)`。检查点：add-drug 单位 toggle、schedule-editor 单位 toggle、today/inventory 卡内单位陈述。
- **[P0]** timeline `EventType` / `TimelineSubType` — domain 删 IconData/Color getter 后，presentation 层 `localizedTypeLabel(l10n)` 文字扩展承担「服药 / 血检 / 测量 / 照片 / 日记 / 里程碑」inline label。来源：timeline/spec.md §11 P0-#3。
- **[P1]** CI lint：`grep "\.displayName" lib/features/`（或 ripgrep）应在 v2 落地后返回 0 行。建议加到 `dart analyze` 自定义 rule 或 PR check script。

---

## 5. 删除清单（不再使用的 widget / 文件 / 字段）

按 feature 分组列出，删除时 `grep` 引用方应为 0：

### Today / Medication
- `CountdownCard`（today_page.dart）— v1 大块渐变倒计时整组件。来源：today/spec.md §3 / §11-P0-#4。
- `QuoteCard`（today_page.dart）— 斜体引言 + 引号 icon。来源：today/spec.md §11 额外消除。
- `PetalCelebration`（lib/core/widgets/petal_celebration.dart 或 inline）+ `petal_celebration` AnimationController — 粉樱粒子 10 片 → 改 `HanaCelebration.trigger`。来源：today/spec.md §11-P0-#5。
- `MedicationStatusCard` 已服 ✓ 勾 — 改褪色态 `HanaCard.flat` + 1px 淡墨竖线。来源：today/spec.md §11-P0-#6。
- AppBar `Icons.auto_awesome` 闪光装饰 icon — 删除。来源：today/spec.md §11-P0-#9。
- 头像 56px hero 右上角 — 移到 Settings 入口，hero 区不放头像。来源：today/spec.md §11 额外消除 + profile/spec.md §1。

### Drug list / Drugs
- `DrugCard`（lib/features/medication/presentation/widgets/drug_card.dart）— **整个 widget 文件删除**。引用方（inventory_page / today_page 等若复用）需迁移到 `HanaListItem`。来源：drug-list/handoff.md §1 / §6-P0-#1。
- 4 色 category Material 标准色硬编码（`Colors.pink / blue / purple / teal`）— 全部从 medication feature 移除。来源：drug-list/handoff.md §6-P0-#2。
- `_buildChip` 4 色 category chip + Switch 启停常驻控件 + `Dismissible` 滑删 + inline `AlertDialog`。来源：drug-list/handoff.md §1。
- `FloatingActionButton.extended` — drug-list / drugs 入口屏 FAB 全删，改屏底 inline `HanaButton.primary`。来源：drug-list/handoff.md §6-P0-#4。

### Add drug
- `_showManualForm` 双态字段 + 切换逻辑（add_drug_page.dart line 26 + 119-122）。来源：add-drug/handoff.md §3.2。
- 默认 `_category = DrugCategory.estrogen` + `_route = AdministrationRoute.oral`（line 33-34）— 改 null。来源：add-drug/handoff.md §2.1。
- 模板卡内 `Container + r-16 + emoji 染色容器 + Icons.add_circle_outline`（line 199-280）。来源：add-drug/handoff.md §3.2。
- "手动添加" 按钮整块（line 282-319）。
- `_categoryColor` switch 4 个非 token 硬编码色（含 `#4A90D9` / `#2CBAA0` 非 token 色，line 321-328）。
- `OutlineInputBorder()` × 3 处 / `SegmentedButton` / `Wrap+ChoiceChip` 三组 / `FilledButton` r-16 全宽。
- ARB key `drugCustomAdd` 三语全删。来源：add-drug/handoff.md §3.2。

### Data
- `_StitchHormoneCard`（line 234）/ `_StitchHistoryCard`（line 832）/ `_StitchSimulatorCard`（line 401）/ `_StitchKnowledgeCard`（line 489）/ `_EmptyHistoryCard`（line 960）— **5 个 _Stitch* 私有 widget 全部删除/重写**。Hormone 96px 装饰水滴 icon、status pill、stadium 9999 chip 全删。来源：data/spec.md §3。
- `_TrendChart`（line 580）— fl_chart Material 风曲线 / 渐变填充全删，重写为「印刷品折线图」（直线 / 1.5dp ink / 实心数据点 / mono Y 轴 / 宋体「N 月」X 轴）。来源：data/spec.md §5。

### Record
- `_StitchRecordCard`（v1 226-436 整段）— 三色多彩卡 + 旋转药片 + 莲花 footer 全部下线。来源：record/spec.md §3。
- footer `Icons.spa` + 红点装饰（v1 line 182-205）— 整段删除。来源：record/spec.md §11-P0-#6。
- `AnimatedRotation` / `ImageFiltered blur(24)` 装饰圆 / 卡内右侧 64dp 装饰图标 — 全删。来源：record/spec.md §3。

### Profile
- 顶部"我的用药"卡 + "库存 / 用药计划"双拼方块 — 搬出 Profile，回归 Today / Drugs 入口屏。Profile 不再聚合用药管理。来源：profile/spec.md §3。
- 头像彩色 placeholder + bento 卡堆叠 + 圆形彩色 icon 容器 + 双拼方块 — 全删（hero 仅 displayName + 一行 mono 副行）。来源：profile/spec.md §1 / §4。
- `_showSnackBar` inline helper — 改 `HanaSnackbar.show`。

### Onboarding
- `Icons.local_florist` 96×96 圆容器（屏 1 hero icon）— 删除，无替代。来源：onboarding/spec.md §6。
- `LinearGradient` 屏 1 背景（line 88-98）— 改实色 background。
- dot indicators (line 138-156) — 改 mono 14「03 / 05」左下/右上角。

### Timeline
- `_TimelineLoadedView` Stack 中央通屏 2px 渐变线（218-235）— 改左侧贴 padding 内边的 1px 黛蓝实色竖线。来源：timeline/spec.md §11-P0-#1。
- `_TimelineEventRow` 彩色圆点（364-381）+ 卡片 4 色彩边线（534-540）+ `Icons.stars`（562、587）+ 卡片 boxShadow（541-547）— 全删。
- `_TimelineStartPoint` 灰圆 + 大脑 icon（674-705）— 改 4px 黛蓝实心点 + headline「起点。」+ mono 日期。来源：timeline/spec.md §11-P0-#7。
- FAB 渐变（73-98）— 改底部 sticky `HanaButton.primary` 单色实色。
- AppBar 居中标题（40）+ `BackdropFilter` blur（33-37）— 改 `HanaTopBar.defaultBar` 实色 + 滚动 0.5px outline + 左对齐。

### 全屏共享
- 13+ 处 `BackdropFilter blur(12)` 玻璃 AppBar — 全部 `HanaTopBar` 替换。
- 所有 `HanaColors.*` v1 樱色 token — 全切 `HanaTokens.*(context)` 单轨 API。

---

## 6. 新增依赖（无 / 内部抽取）

**重申：v2 重设计未引入任何新 pub.dev dependency**。所有"新增组件"都是 `lib/core/widgets/hana_*.dart` 内部抽取，不动 pubspec.yaml。

需在 PR-C（HanaTokens + 16 组件落地）一并就位的 widget：
- 已存在并需补 variant：`HanaTextField.numberDecimal large` / `HanaBottomSheet.picker` / `HanaCard.list` / `HanaCard.tappable`
- 新建：`HanaListItem`（多 variant）/ `HanaSectionHeader` / `HanaSwitch` / `HanaToast`（v1.1 spec 待补）/ `HanaPullRefresh`（v1.1 spec 待补）
- 复用：`HanaTokens` / `HanaTypography` / `HanaSemanticColors` / `HanaPressScale` / `HanaCelebration` / `HanaLoadingView` / `HanaEmptyState` / `HanaErrorState` / `HanaButton` / `HanaTopBar` / `HanaDialog` / `HanaInput` / `HanaCard` / `HanaBottomSheet`

落地路径全部在 `lib/core/widgets/`，handoff/snippets/ 已有 16 个 dart 参考实现。

---

## 7. PR 拆分顺序建议

**铁律：domain / data 改动必须先于 UI 改动落地，否则中间态会出现"v1 UI + 已扩展 daysOfWeek/isDeleted 字段"的撕裂状态。**

```
PR-A（domain layer fix + DEC-042/043 + 新建 enum）
├─ 删 timeline domain enums.dart 的 IconData/Color getter（DEC-042/043 修复）
├─ 新建 OnboardingHrtStatus / InventoryLevel / StockEntry entity
├─ Drug entity + isDeleted/deletedAt（freezed regen）
├─ MedicationFrequency.weekly: dayOfWeek → daysOfWeek (Set<int>)（freezed regen）
├─ 补齐 DrugCategory / AdministrationRoute / DosageUnit / EventType 的 localizedName(l10n) 扩展
└─ 单测覆盖：所有 enum 扩展 / 新 entity 序列化

PR-B（data layer migration + repo 扩展）
├─ stock_entries 新表 + sqflite migration v→v+1（含旧 db 升级测试）
├─ medication_schedule.dayOfWeek → daysOfWeek JSON schema migration（含回滚测试）
├─ drugs.is_deleted / deleted_at schema migration
├─ MedicationRepository.addStockEntry / getRecentStockEntries
├─ DrugListCubit.restoreDrug / permanentlyDeleteDrug
├─ InventoryCubit.addStock 增量语义 + state 扩展
└─ release.yml 加 staging 数据库验证步骤

PR-C（HanaTokens + 16 组件落地 + ARB 三语 key 总落地）
├─ lib/app/theme/hana_tokens.dart + hana_typography.dart + hana_semantic_colors.dart
├─ lib/core/widgets/ 16 个 hana_*.dart 组件（参考 handoff/snippets/）
├─ HanaTextField.numberDecimal large variant + HanaBottomSheet.picker variant
├─ ARB 三语 80+ 新增 key 落地（详见 docs/design/handoff/arb-additions.md）
├─ flutter gen-l10n 重生成 app_localizations*.dart
└─ 删 5 个 v1 stub 组件 spec（已 archive 到 _archived/）

PR-D（Pilot Wave 2 屏切：Today + Onboarding）
├─ today_page.dart 完全重写（删 CountdownCard / QuoteCard / PetalCelebration / 头像）
├─ onboarding_page.dart 5 屏重构（屏 3 三选门控屏 4）
├─ 删 default estrogen/oral，改 nullable + null
└─ widget test + golden test

PR-E（Record + Data 屏切）
├─ record_page.dart 重写（删 _StitchRecordCard 整段 + footer）
├─ data_page.dart 重写（删 5 个 _Stitch* + _TrendChart 重写「印刷品折线图」）
└─ fl_chart theme 配置抽到 HanaLineChart wrapper

PR-F（Drug list + Add drug + Schedule editor）
├─ drug_list_page.dart 重写（删 DrugCard / FAB / Dismissible / inline AlertDialog）
├─ add_drug_page.dart 单页表单 + 模板 sheet（默认 null）
└─ schedule_editor_page.dart 重写（含 weekday 多选 toggle）

PR-G（Inventory + Profile + Timeline）
├─ inventory_page.dart 重写 + RestockSheet + StockEntryCard（消费 PR-B 的 stock_entries）
├─ profile_page.dart 重写（删头像 / 双拼方块 / bento）
└─ timeline_page.dart 重写（书脊装订线 + 月份章节 sticky + 起点小点）
```

**关键依赖箭头**：PR-A → PR-B → PR-C → (PR-D / PR-E / PR-F / PR-G 并行)。后四个屏 PR 可分配到不同工程师并行实施，因为它们都消费同一套 PR-A/B/C 提供的接口。

**回滚策略**：每个 UI PR 单点 revert 不影响其他屏；PR-A/B/C 是基础设施，revert 影响面大，必须 staging 充分验证。

---

— 完 —
