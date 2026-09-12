# Timeline 屏 v2 — Flutter Handoff Spec

> 配对 spec：docs/design/screens/timeline/spec.md
> 屏幕：lib/features/timeline/presentation/pages/timeline_page.dart
> 受 CLAUDE.md 约束：保留 bloc/state 不动，仅改 UI + domain 装饰清理；ARB 走 `lib/core/l10n/`
> Pilot Wave: 阶段 3.1.b（设计 → 工程交接）

---

## 1. 现有 BLoC 兼容性

`TimelineBloc` / `TimelineEvent`（bloc event）/ `TimelineState`（freezed union）**契约不动**——v2 重画 UI + domain 装饰清理 + 新增 filter 维度，状态机扩展不破。

**仍在用的事件**（`bloc/timeline_event.dart`）：
- `LoadTimelineEvents()` — 初次进入 / 重试 / 下拉刷新
- `SelectRange(TimelineRange range)` — Filter Pills 切换 → v2 改 BottomSheet 后**仍走此事件**

**新增事件**（v2 必须）：
- `SelectTypes(Set<TimelineEventType> types)` — 多选类型筛选（v1 不支持，v2 BottomSheet 引入）
- `ResetFilters()` — 筛选面板"重置"按钮触发

**仍在用的 state 字段**（loaded variant）：
- `events: List<TimelineEvent>` — 已按 selectedRange + selectedTypes 过滤好的事件
- `selectedRange: TimelineRange` — 时间范围
- 新增：`selectedTypes: Set<TimelineEventType>` — 类型多选（默认空集 = 全选）

**新 UI 派生逻辑**（仅 presentation 层）：
- `groupedByMonth: Map<YearMonth, List<TimelineEvent>>` — 按 `(year, month)` 分组，渲染章节断点
- `firstEventDate: DateTime?` — events 中最早一条日期，渲染起点 mono 副行
- `totalCount: int` — events.length，渲染 hero 副行 "共 142 条"

> **不动 bloc 主结构 + 加 2 事件**：现有测试 mock 仅需补 SelectTypes / ResetFilters 两个 case；UseCase `GetTimelineEvents` 需要扩展 `filter` 参数（type set + range）。

---

## 2. 文件改动清单

### 主文件（重写）
- `lib/features/timeline/presentation/pages/timeline_page.dart` — **完整重写**
  - 保留：BlocProvider 绑定、`BlocBuilder<TimelineBloc, TimelineState>` switch 模式
  - 删除：`Stack` + 中央 2px 渐变线（_TimelineLoadedView 218-235）、`BackdropFilter` AppBar（30-72）、`_TimelineEventRow` 双侧布局（338-397）、彩色圆点（364-381）、`_DateText` 内联（399-417）、卡片 boxShadow + 4 色彩边线、FAB 渐变（73-98）、`_TimelineStartPoint` 大脑 icon 灰圆（665-706）
  - 新结构：`CustomScrollView` + `SliverToBoxAdapter(hero)` + `SliverPersistentHeader(章节标记 sticky)` + `SliverList(卡片)` + `SliverToBoxAdapter(起点)`，外层 `Stack` 仅承载 sticky bottom CTA

### Domain 清理（DEC-042/043 合规）
- `lib/features/timeline/domain/entities/enums.dart` — **删除装饰 getter**
  - 删除 `extension TimelineEventTypeX` 的 `IconData icon`（30-35）+ `Color borderColor`（37-43）+ `Color iconColor`（45-51）
  - 保留 `enum TimelineEventType` 本身和 `String displayName`（但 `displayName` 也应迁出 — 见下）
  - 删除 `import 'package:flutter/material.dart'` + `import 'package:hananote/app/theme/hana_colors.dart'`（domain 零外部依赖）

### 新增（presentation 层）
- `lib/features/timeline/presentation/extensions/timeline_event_type_l10n.dart` — 新建
  ```dart
  extension TimelineEventTypeL10n on TimelineEventType {
    String localizedTypeLabel(AppLocalizations l10n) => switch (this) {
      TimelineEventType.medication => l10n.timelineTypeMedication,
      TimelineEventType.bloodTest => l10n.timelineTypeBloodTest,
      TimelineEventType.journal => l10n.timelineTypeJournal,
      TimelineEventType.milestone => l10n.timelineTypeMilestone,
    };
  }
  ```
  > 与 `enum_l10n.dart` 的 DEC-043 模式一致；删除 enums.dart 的 `displayName` 中文硬编码。

### 共享组件复用（PR 1 已建）
- `HanaTopBar.defaultBar` — 替换 BackdropFilter AppBar
- `HanaCard.tappable` — 替换 `_EventCard`
- `HanaSectionHeader` — 月份章节断点（Today PR 已建）
- `HanaButton.primary` / `HanaButton.secondary` / `HanaButton.ghost` — sticky CTA / 空态 / 重试
- `HanaEmptyState.page` — 空态 + 筛选无结果
- `HanaErrorState` — 错误态
- `HanaLoadingView.block` — 加载态
- `HanaPressScale` — 卡片按下

### 新增（本 PR 范围）
- `lib/core/widgets/hana_bottom_sheet.dart` — 实施 components/bottom-sheet.md（如尚未在 PR 1 落地）
- `lib/core/widgets/hana_choice_chips.dart` — 多选 / 单选 chip 组（杂志目录语法：下划线 active）
- `lib/features/timeline/presentation/widgets/timeline_axis.dart` — **新组件**：左侧 1px 黛蓝竖线
- `lib/features/timeline/presentation/widgets/timeline_filter_sheet.dart` — 筛选面板内容
- `lib/features/timeline/presentation/widgets/timeline_event_detail_sheet.dart` — 单事件详情面板内容

### 删除（v1 残留）
- `_TimelineEventRow` / `_DateText` / `_FilterPills` / `_TimelineStartPoint` / `_EventCard` 五个私有 class（timeline_page.dart 内）

### ARB 改动（`lib/core/l10n/arb/app_{en,zh,ja}.arb`）
| Key 新增 / 改动 | zh | ja | en |
|----------------|----|----|----|
| `timeline.heroTitle` (替换 `myGrowthTrajectory`) | 年表。 | 年表。 | The Timeline. |
| `timeline.heroSubtitle` | "共 {count} 条　始于 {date}" | "{count} 件　{date}より" | "{count} entries since {date}" |
| `timeline.sectionMonth` | "{year} · {month} 月" | "{year} · {month}月" | "{month} {year}" |
| `timeline.startLabel` | 起点。 | はじまり。 | The beginning. |
| `timeline.recordNew` (替换 FAB 拼装文案) | 新增一笔。 | 一筆を加える。 | Add an entry. |
| `timeline.emptyTitle` (替换 `noTimelineEvents`) | 尚未起笔。 | まだ何も。 | Not yet. |
| `timeline.emptyMessage` | 记下第一笔，年表自此展开。 | 一筆を記し、年表を始めましょう。 | Add your first entry to begin. |
| `timeline.emptyFilteredTitle` | 本期空白。 | 該当なし。 | Empty. |
| `timeline.emptyFilteredMessage` | 调整筛选试试。 | 絞り込みを変えてみる。 | Try different filters. |
| `timeline.errorRetry` | 载入失败。请下拉刷新。 | 読込失敗。引いて更新。 | Failed. Pull to refresh. |
| `timeline.loading` | 读取中。 | 読込中。 | Loading. |
| `timeline.filterTitle` | 筛选 | 絞り込み | Filter |
| `timeline.filterTypeLabel` | 类型 | タイプ | Type |
| `timeline.filterRangeLabel` | 时间范围 | 期間 | Range |
| `timeline.filterApply` | 应用筛选 | 適用 | Apply |
| `timeline.filterReset` | 重置 | リセット | Reset |
| `timeline.typeMedication` | 服药 | 服薬 | Medication |
| `timeline.typeBloodTest` | 血检 | 血液検査 | Blood test |
| `timeline.typeJournal` | 日记 | 日記 | Journal |
| `timeline.typeMilestone` | 里程碑 | マイルストーン | Milestone |
| `timeline.eventCardLine` | "{type} · {date}　{weekday}" | "{type} · {date}　{weekday}" | "{type} · {date}" |

旧 key（`myGrowthTrajectory` / `noTimelineEvents` / 卡片旧装饰文案）保留 1 版本备灰度，不在本 PR 删除。

---

## 3. 性能注意（百级 entry 滚动）

Timeline 是聚合屏，事件总数无上限（用户使用 1 年 = 服药 365×N 条 + 测量 + 日记 + 里程碑 ≈ 千级）。**性能必须在 spec 阶段就锁死**，不能等 Phase 6 打补丁：

1. **SliverList.builder + addAutomaticKeepAlives: false**：默认 SliverChildBuilderDelegate 会缓存所有已 build 子项，千级 entry 时内存爆炸；显式 `addAutomaticKeepAlives: false` + `addRepaintBoundaries: true` 让滚出屏的卡片释放
2. **每张卡片外层包 RepaintBoundary**：`HanaCard.tappable` 实施时已加，但 timeline 卡内有 mono 数值 + label + title + body 四级 Text，RepaintBoundary 边界要确保是整张卡而非局部
3. **章节标记用 SliverPersistentHeader**：sticky 月份切换不要用 `Sliver + Stack + Visibility`（每帧重测量），用 `SliverPersistentHeaderDelegate` + `pinned: true`
4. **避免 setState 重建整列表**：筛选切换走 Bloc → BlocBuilder 仅在 events 列表 identity 变化时重建；`buildWhen` 加上 `previous.events != current.events || previous.selectedTypes != current.selectedTypes`
5. **时间轴竖线性能**：左侧 1px 黛蓝竖线**不能用 `Stack + Positioned.fill`**（v1 中央渐变线的做法），那会让竖线跨越整个 SliverList 导致 layout 重算。改为**每个章节内独立绘制竖线**：`SliverPadding` 内部用 `Padding(left: 32) > Stack > Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 1, color: primary))` 包裹该章节的卡片群——竖线随章节滚动出场退场，而不是通屏全长
6. **图片资产**：照片类事件的 thumbnail 用 `cacheWidth` / `cacheHeight` 显式约束，避免 timeline 加载千级 entry 时同时解码大图
7. **首屏可见 N 张入场动画错落 60ms**：仅前 6 张参与 fadeIn，第 7 张起静态出现，避免动画 controller 数量爆炸
8. **筛选去抖**：BottomSheet 内 chips 切换不立即触发查询，等"应用筛选"按下才发事件——避免用户多选时连续 10+ 次重新查询

> **基准目标**：1000 entries × 5 个章节，scroll 60fps（jank rate < 5%），冷启动到首屏可见 < 800ms（不含数据库读取）。Phase 6 perf audit 阶段用 DevTools timeline 验证。

---

## 4. UseCase / Repository 改动

- `lib/features/timeline/domain/usecases/get_timeline_events.dart` — 扩展参数：
  ```dart
  Future<Either<Failure, List<TimelineEvent>>> call({
    required TimelineRange range,
    Set<TimelineEventType> types = const {}, // 空集 = 全选
  });
  ```
- Repository 层做类型 + 时间范围的并行查询：现有跨 feature 数据源（medication / blood_test / journal / measurement / photo）保持不变，仅在聚合层加 `where types.isEmpty || types.contains(event.type)` 过滤
- 排序：按 `event.date desc`（最近的在 hero 下方）—— 起点是最早一条（页面底部）
- 月份分组在 presentation 层做（不在 domain），保持 `List<TimelineEvent>` 平铺契约

---

## 5. 测试（融入 323 基线）

- **bloc test**：现有 `TimelineBloc` 测试保留；新增 2 个：`SelectTypes` emits filtered events / `ResetFilters` emits all events
- **widget test**：
  - 章节断点正确（按月份分组渲染 `HanaSectionHeader`）
  - 时间轴竖线 a11y `ExcludeSemantics` 包裹
  - 空态 vs 筛选无结果文案区分
  - sticky CTA 始终可见（IntegrationTest 滚动到底部仍在）
- **golden test**：light / dark mode 各一张 timeline 整屏 golden（mobile 375x812 + tablet 768x1024）
- **a11y test**：`Semantics` 树验证 — 章节挂 header level 2 / 卡片挂 button / 时间轴 ExcludeSemantics

---

## 6. 关键提醒

1. **不要把 timeline 设计成 social feed**：避免任何"avatar + name + timestamp + reaction" 的 Twitter / Facebook 模式。本屏是私人年表，不是社交流。卡片不出现头像、不出现"X 分钟前"相对时间（用绝对日期）、不出现 like / comment / share。
2. **域模型零外部依赖（DEC-042/043）**：domain/entities/enums.dart 删除 IconData / Color 后，再做一次 `flutter analyze --fatal-infos`，确认 domain 层导入零 `package:flutter/*`。
3. **i18n 不能把月份硬编码 `{year} · {month} 月`**：用 `DateFormat.yMMM(localeName)` + locale-aware 分隔符，避免 ja "2026 · 4月" 与 zh "2026 · 4 月" 混用全角空格。
4. **筛选状态持久化**：`selectedTypes` + `selectedRange` 不要持久化到磁盘（每次进入 timeline 默认全选 + 范围 30 天），避免用户上次筛了某一类后下次打开看到空表困惑。
5. **时间轴竖线色不能跟随事件类型变色**：v1 的 4 色 borderColor 是反例。竖线永远 `HanaTokens.primary(context)`，宽度恒 1px、长度跟随章节内容、无渐变无光晕。
6. **不要在 timeline_page.dart 内联画杂志感**：所有原子组件走 `lib/core/widgets/`；timeline 自己只组装 `timeline_axis.dart` + `timeline_filter_sheet.dart` + `timeline_event_detail_sheet.dart` 三个 feature-local widget。

---

## 7. PR 拆分建议

按 widget-pattern-inventory.md 第 4 段"5 个文件首批迁移目标"建议，timeline 是第 4 个 PR：

1. **PR 1（前置依赖）**：`hana_tokens_v2` + `HanaCard` + `HanaTopBar` + `HanaButton` + `HanaSectionHeader` + 5 个状态件（已在 Today PR 中落地）
2. **PR 2（前置依赖）**：`HanaBottomSheet` + `HanaChoiceChips`（如未在其他 PR 落地）
3. **PR 3（domain 清理）**：仅修 `enums.dart` 删除三个装饰 getter + 新建 `timeline_event_type_l10n.dart` + ARB 增 4 个类型 key + presentation 层 imports 更新；PR diff 小，便于 review
4. **PR 4（本屏重写）**：`timeline_page.dart` 完整重写 + 3 个 feature-local widget + UseCase 参数扩展 + bloc 加 2 事件 + ARB 全套 timeline.* key

> 不允许把 PR 3 + PR 4 合并：domain 装饰清理是跨 PR 影响（其他屏可能也引用了 `TimelineEventTypeX.icon`，需要全局搜索 + 替换），独立 PR 才能让 reviewer 专注审 domain 边界合规。

---

## 8. 风险与回滚

最大风险是**时间轴竖线被 CTO 评审认为破坏"一抹强色"**——竖线纵向连续覆盖屏高 60-100%，单从面积算可能超出"3 处"硬规则。回滚方案：

- **A 方案**（首选）：保留黛蓝 1px 竖线，把章节标记的 4px 黛蓝竖线改为同色家族延展（视觉上是同一根线的"加粗段落标记"），整屏黛蓝合并为"1 根装订线 + 底部 CTA + 1 处选中态"= 3 处
- **B 方案**（fallback）：竖线改 `HanaTokens.outline(context)` 烟灰色 1px，不进强色家族；黛蓝仅保留章节标记 + CTA + 选中态 = 3 处。视觉冲击稍弱但合规风险归零
- **C 方案**（极端 fallback）：完全删除时间轴竖线，仅保留章节断点 + 卡间留白；月份 sticky 标记承担所有"年表"语义。最克制但失去"装订线"隐喻

CTO 在 critique-v2 评审时三选一。其余实施细节按 spec.md 对齐。

—— 完 ——
