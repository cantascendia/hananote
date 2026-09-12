# Inventory 屏 v2 — Flutter Handoff Spec

> 配对 spec：`docs/design/screens/inventory/spec.md`
> 屏幕：`lib/features/medication/presentation/pages/inventory_page.dart`
> 受 CLAUDE.md 约束：保留 cubit 主契约、扩展两个新方法；UI 全部重写；ARB 走 `lib/core/l10n/`
> 假设：today / data 屏的 PR 1（HanaTokens + 共享组件）已合并；本 PR 仅新增 `HanaTextField` 若尚未存在

---

## 1. 现有 BLoC 兼容性 + 扩展

### 保留契约
`InventoryCubit` / `InventoryState`（freezed union） + `CheckInventory` 用例的 **public 接口保持向后兼容**：
- `loadInventory()` — 初次进入 / 下拉刷新 / 补货后重载
- `InventoryState.loaded(statuses, lowStockCount)` — 现有 UI 仍可消费

### 新增 API（spec §3 + §6 要求）

```dart
// inventory_cubit.dart 新增
Future<void> addStock(String drugId, double delta, {String? note}) async {
  // 1. fetch existing inventory
  // 2. quantity = existing.quantity + delta（增量语义，非 reset）
  // 3. updatedAt = DateTime.now()
  // 4. 同时写一条 StockEntry(drugId, delta, note, timestamp) 到补货历史表
  // 5. loadInventory() 重载
}

Future<void> loadRecentEntries({int limit = 5}) async { ... }
```

### state 扩展

```dart
@freezed
sealed class InventoryState with _$InventoryState {
  const factory InventoryState.loaded({
    required List<InventoryStatus> statuses,
    required int lowStockCount,         // daysRemaining < 14
    required int criticalCount,         // 新增：< 7 天
    required List<StockEntry> recentEntries,  // 新增：最近补货
  }) = InventoryLoaded;
  // ... initial / loading / error 不变
}
```

### `InventoryStatus` 扩展（`check_inventory.dart`）

```dart
class InventoryStatus {
  final Drug drug;
  final int? daysRemaining;
  final double currentQuantity;        // 新增：UI 直接展示「剩 47 g」
  final DosageUnit unit;               // 新增：单位（避免 UI 再访问 drug.defaultDosageUnit）
  final InventoryLevel level;          // 新增 enum：ample / warning / critical / unknown
}

enum InventoryLevel {
  ample,     // > 14 天 / null 时归 ample（UI 单独处理 unknown）
  warning,   // 7-14 天
  critical,  // < 7 天
  unknown,   // daysRemaining == null
}
```

### 新数据层（domain + data）

```dart
// domain/entities/stock_entry.dart
class StockEntry {
  final String id;
  final String drugId;
  final double delta;
  final String? note;
  final DateTime recordedAt;
}

// domain/repositories/medication_repository.dart 扩展
Future<Either<Failure, void>> addStockEntry(StockEntry entry);
Future<Either<Failure, List<StockEntry>>> getRecentStockEntries({int limit});

// data/datasources/medication_local_data_source.dart 扩展
//   新表 stock_entries: id / drug_id / delta / note / recorded_at
//   sqflite migration v? → v?+1
```

> **若 R52 周期内 stock_entries 表来不及做**：spec §11 已声明可降级——`recentEntries` 返回空列表，UI 段落整体不渲染（不阻塞主重写）。本 PR 内可以仅 stub repo 方法返回 `right([])`，DB schema 留 follow-up。

---

## 2. 文件改动清单

### 主文件（重写）
- `lib/features/medication/presentation/pages/inventory_page.dart` — **完整重写**
  - 删除：line 1-3 release-prep 注释 + `ignore_for_file`；`_buildInventoryCard` 整段；`_showUpdateDialog` 整段；Material `Card` + `BorderSide`；红色 stadium pill chip + warning icon
  - 保留：`InventoryCubit` BlocProvider 绑定；`initState` `loadInventory()` 触发

### 新增文件
- `lib/features/medication/presentation/widgets/inventory_card.dart` — 库存项卡（`HanaCard.tappable` + 染色逻辑）
- `lib/features/medication/presentation/widgets/restock_sheet.dart` — `HanaBottomSheet.form` 补货登记
- `lib/features/medication/presentation/widgets/stock_entry_card.dart` — 补货历史卡（`HanaCard.flat`）
- `lib/features/medication/domain/entities/stock_entry.dart`
- `lib/features/medication/domain/entities/inventory_level.dart`（enum）
- 测试：`test/features/medication/presentation/pages/inventory_page_test.dart` 重写 + 新增 `restock_sheet_test.dart`

### 共享组件依赖（应已存在 from today/data PR 1）
- `HanaTokens` / `HanaSemanticColors`
- `HanaTopBar` / `HanaCard` / `HanaButton` / `HanaSectionHeader`
- `HanaCelebration` / `HanaPressScale`
- `HanaEmptyState` / `HanaErrorState` / `HanaLoadingView`
- `HanaBottomSheet`（`form` variant 必须支持，见 `components/bottom-sheet.md`）
- **可能新增**：`HanaTextField`（如尚未存在 — 应在 `components/text-field.md` 定义；本 PR 内可提一个最小实现：底部 1px outline / focus 2px primary / radius 2 / mono variant）

### 路由
- `/medication/inventory` 已存在，不动
- `/medication/inventory_history` 标 follow-up，本 PR 不实施

### ARB 改动（`lib/core/l10n/arb/app_{en,zh,ja}.arb`）

| Key 新增 / 改动 | zh | ja | en |
|----------------|----|----|----|
| `inventory` | 库存 | 在庫 | Inventory |
| `inventory.heroSubAmple` | 共 {n} 项　·　充足 | 計 {n} 項　·　十分 | {n} items · ample |
| `inventory.heroSubLow` | 共 {n} 项　·　{m} 项偏低 | 計 {n} 項　·　{m} 項不足 | {n} items · {m} low |
| `inventory.heroEmpty` | 尚未启用。 | 未設定。 | None yet. |
| `inventory.sectionCurrent` | 当前库存 | 在庫 | Current |
| `inventory.sectionRecent` | 最近补货 | 補充履歴 | Recent |
| `inventory.sectionNotify` | 通知 | 通知 | Notify |
| `inventory.daysApprox` | 约 {n} 天 | およそ {n} 日 | ~{n} days |
| `inventory.qtyRemaining` | 剩 {qty} {unit} | 残 {qty} {unit} | {qty} {unit} left |
| `inventory.criticalSuggest` | 建议补货。 | 補充をおすすめ。 | Restock soon. |
| `inventory.scheduleMissing` | 估算需服药计划。 | 服薬計画が必要。 | Schedule needed. |
| `inventory.restockTitle` | 补货 · {drug} | 補充 · {drug} | Restock · {drug} |
| `inventory.restockCurrentLabel` | 当前 | 現在 | Current |
| `inventory.restockDeltaLabel` | 今日补 | 今日補充 | Add |
| `inventory.restockNoteLabel` | 备注（可选） | メモ（任意） | Note (optional) |
| `inventory.restockSubmit` | 记入 | 記録 | Record |
| `inventory.lowStockNotifyTitle` | 低库存提醒 | 在庫不足通知 | Low stock alert |
| `inventory.lowStockNotifyDesc` | 剩余 ≤ {days} 天时通知。 | 残り {days} 日以下で通知。 | Notify when ≤ {days} days. |
| `inventory.emptyTitle` | 本期空白。 | まだなし。 | Empty. |
| `inventory.emptyMessage` | 尚未启用任何药物。 | 服薬予定が未設定です。 | No active medications. |

旧 key（`lowStock` / `daysLeft` / `noActiveDrugs` / `inventoryDataUnavailable` / `inventoryUpdateHint` / `inventoryDaysRemaining` / `inventoryComingSoon`）保留 1 版本灰度，本 PR 不删除（与 today 屏 ARB 灰度策略一致）。

---

## 3. 实施代码骨架

```dart
// lib/features/medication/presentation/pages/inventory_page.dart
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: HanaTokens.background(context),
      appBar: HanaTopBar(
        title: l10n.inventory,
        actions: [
          HanaIconButton(
            icon: Icons.add,
            onPressed: () => context.go('/medication/drug_list'),
          ),
        ],
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) => state.maybeWhen(
          loading: () => const HanaLoadingView(variant: block),
          error: (msg) => HanaErrorState(
            message: l10n.todayErrorRetry,
            onRetry: () => context.read<InventoryCubit>().loadInventory(),
          ),
          loaded: (statuses, lowCount, criticalCount, recentEntries) {
            if (statuses.isEmpty) return _InventoryEmpty(l10n: l10n);
            return _InventoryContent(
              statuses: statuses,
              lowCount: lowCount,
              recentEntries: recentEntries,
              l10n: l10n,
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// _InventoryContent 内 CustomScrollView：
//   - SliverPadding(top: spacing.xl=64)
//   - Hero「库存。」display-xl ink，左对齐 spacing.lg=32
//   - 副行：lowCount==0 ? heroSubAmple(n) : heroSubLow(n, m)，body-sm + mono
//   - SliverPadding(spacing.lg)
//   - HanaSectionHeader(l10n.inventorySectionCurrent)
//   - SliverList<InventoryCard>(statuses)  // 见下
//   - SliverPadding(spacing.lg)
//   - if (recentEntries.isNotEmpty) ...
//       HanaSectionHeader(sectionRecent)
//       SliverList<StockEntryCard>(recentEntries.take(5))
//   - SliverPadding(spacing.lg)
//   - HanaSectionHeader(sectionNotify)
//   - HanaCard.tappable("低库存提醒" + chevron) → /settings
//   - SliverPadding(bottom: spacing.xl)

// inventory_card.dart：
class InventoryCard extends StatelessWidget {
  final InventoryStatus status;
  // ...
  Widget build(...) {
    final daysColor = switch (status.level) {
      InventoryLevel.ample || InventoryLevel.unknown => HanaTokens.ink(context),
      InventoryLevel.warning || InventoryLevel.critical => HanaTokens.primary(context),
    };
    return HanaCard.tappable(
      onTap: () => status.level == InventoryLevel.unknown
        ? context.go('/medication/drug_edit?id=${status.drug.id}')
        : RestockSheet.show(context, status: status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(status.drug.name, style: HanaTextStyles.title(context)),
          SizedBox(height: HanaTokens.spacing.xs),
          Text(
            l10n.inventoryQtyRemaining(status.currentQuantity, unit),
            style: HanaTextStyles.mono(context),
          ),
          SizedBox(height: HanaTokens.spacing.xs),
          if (status.daysRemaining != null) ...[
            Text(
              l10n.inventoryDaysApprox(status.daysRemaining!),
              style: HanaTextStyles.mono(context).copyWith(color: daysColor),
            ),
            if (status.level == InventoryLevel.critical) ...[
              SizedBox(height: HanaTokens.spacing.xs),
              Text(
                l10n.inventoryCriticalSuggest,
                style: HanaTextStyles.bodySmall(context)
                    .copyWith(color: HanaTokens.error(context)),
              ),
            ],
          ] else
            Text(
              l10n.inventoryScheduleMissing,
              style: HanaTextStyles.bodySmall(context)
                  .copyWith(color: HanaTokens.inkSecondary(context)),
            ),
        ],
      ),
    );
  }
}

// restock_sheet.dart：
class RestockSheet extends StatefulWidget {
  static Future<void> show(BuildContext ctx, {required InventoryStatus status}) =>
    HanaBottomSheet.show(ctx, sheet: HanaBottomSheet(
      title: l10n.inventoryRestockTitle(status.drug.name),
      child: RestockSheet(status: status),
    ));
  // ...
  // controller for delta + note
  // 验证 delta > 0 && delta <= 9999
  // onSubmit → cubit.addStock(drug.id, delta, note: note)
  //          → Navigator.pop()
  //          → HanaCelebration.trigger(...)
}
```

---

## 4. 测试策略

### widget test（重写 + 新增）
- `inventory_page_test.dart`（重写）：
  - 默认态（含 ample/warning/critical 各 1 项）→ 渲染 hero + 3 章节 + 正确卡数；warning 数字 mono primary；critical 多渲染朱砂注脚
  - 全部充足 → hero 副行文案 `heroSubAmple`
  - 空态（statuses 空）→ `HanaEmptyState.page` + secondary 按钮可点
  - 错误态 → `HanaErrorState` + 重试派发 `loadInventory`
  - 数据缺失（daysRemaining null）→ 不渲染天数行；点击跳 drug_edit 路由（用 mockGoRouter）
- `restock_sheet_test.dart`（新增）：
  - 输入合法 delta → 派发 `addStock(drugId, delta, note)`
  - 输入 delta ≤ 0 / 非数字 / > 9999 → 提交按钮 disabled 或 inline 错误
  - 提交成功 → BottomSheet `pop`，`HanaCelebration` overlay 出现

### a11y test
- 库存卡 Semantics label = `"${name}　剩 ${qty}${unit}　约 ${days} 天　${statusText}"` 整体作为 1 个 button
- BottomSheet `Semantics(scopesRoute: true, namesRoute: true)`
- Focus traversal：AppBar → hero → current 段 → recent 段 → notify 卡
- prefers-reduced-motion：fadeIn / 数字补间 / sheet 滑入全跳过

### golden test
- `inventory_page.golden_test.dart`：light + dark 各 1 张 default 态（含 1 项 critical 用于固定朱砂注脚位置）

### cubit test
- `inventory_cubit_test.dart` 扩展：
  - `addStock(id, 30)` → repo `updateInventory` 收到 `qty + 30`，重载 state；StockEntry 写入
  - `addStock` failure → emit error
  - `loadInventory` 计算 `criticalCount`（< 7 天）正确

### 现有测试影响
- `lib/features/medication/test/...`（如有）：「lowStock」字样断言改 `inventory.heroSubLow` 或染色检查；「warning_amber_rounded」icon 断言全删

---

## 5. CI / Build 注意

### ARB 重新生成
```bash
flutter gen-l10n
```
ARB 改动后 `app_localizations*.dart` 自动更新（不要手改生成文件，CLAUDE.md 铁律）。

### freezed 重生成
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
`InventoryState` / `StockEntry` / `InventoryLevel` 改动后必跑。

### 数据库 migration
若实施 `stock_entries` 表，需要：
- `lib/core/database/secure_database.dart` 添加 `_createStockEntriesTable`
- `onUpgrade` 增加 v→v+1 分支
- 写一个测试：旧版本 db 升级后 stock_entries 表存在且空
- **或者**：本 PR stub 仅返回空列表，留 follow-up issue（spec §11 允许）

### 依赖检查
- `dart analyze --fatal-infos` 必须通过
- `flutter test` 基线 323 不退化（预期 ±8 个测试因 v2 重写 + 新 widget）
- CI lock：Flutter 3.38.4

---

## 6. PR 拆分建议

| PR | 范围 | Diff | Reviewer 重点 |
|----|------|------|-------------|
| **PR A** | cubit/state/usecase 扩展（`addStock` / `criticalCount` / `InventoryLevel` / `StockEntry` stub）+ ARB 新 key + cubit test | +400/-50 | 增量语义、freezed 兼容、ARB 三语对齐 |
| **PR B** | UI 重写：`inventory_page.dart` + `inventory_card.dart` + `restock_sheet.dart` + `stock_entry_card.dart`；删除旧 `_buildInventoryCard` / `_showUpdateDialog` | +700/-200 | 三段染色规则、BottomSheet 替换、零 BackdropFilter / BoxShadow / border、字体 mono |
| **PR C** | widget/golden test + a11y 断言 + 现有断言文案更新 | +500/-100 | 染色覆盖、Semantics 完整、reduce-motion |

> 三 PR 独立可 review、可 revert；PR A 不影响线上（仅扩展）；PR B 是视觉切换日；PR C 锁基线防回归。可参考 today 屏的三段拆分模式。

> **可选合并**：若团队倾向单 PR，至少把 cubit 扩展（PR A）独立——它零 UI 改动、独立可测，回滚成本低。

---

## 7. 风险

### 风险 1：补货语义从「reset 总量」切到「+N 增量」
v1 用户习惯输入"现在剩多少"；v2 改输"今天补了多少"。语义反转。
- **缓解**：BottomSheet 字段 label 显式写「今日补」+ 副位 readonly 显示「当前 N」让两个语义在屏内对照可见；Onboarding 或 release notes 简单提示一次。

### 风险 2：stock_entries 表 migration 失败 / 旧用户无数据
新表上线后旧用户初始 recent entries 为空，「最近补货」段直接不渲染——属于优雅降级，不算 bug。
- **缓解**：`recentEntries.isEmpty` 时整段不显示（不显示「最近补货 + 空态」组合，避免空段落）。

### 风险 3：3 个章节 + hero + 多卡 → 滚动屏长度增加
v1 单纯列表很短，v2 加 hero + 3 段后，5 项库存的屏长度从 ~600px 变 ~1200px。
- **缓解**：mobile 可接受（用户预期是滚动浏览的内刊页）；Web 端 max-width 720 + 三列布局右浮岛已规划。如反馈过长，可考虑章节折叠（本 PR 不实施）。

### 风险 4：黛蓝染数字数量 > 3 时违反 principles §1
spec §6 已声明：4+ 项偏低时 hero 副行 mono primary 要降级为 mono ink。但卡片本身的染色不收紧——critical 信号必须保留。
- **缓解**：PR review 时 lint「单屏 mono primary > 3 处需 reviewer 显式 ack」（与 data 屏共用规则）。

### 风险 5：BottomSheet 替换 AlertDialog 后旧 widget test 失败
`test_finder` 找 `AlertDialog` 的断言会全失败。
- **缓解**：PR C 专门处理；预期 ~5 处断言改写。

---

— 完 —
