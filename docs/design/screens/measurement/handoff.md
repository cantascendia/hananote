# Measurement 主屏 v2 — Flutter Handoff Spec

> 配对 spec：`docs/design/screens/measurement/spec.md`
> 屏幕：`lib/features/measurement/presentation/pages/measurement_page.dart`
> 受 CLAUDE.md 约束：保留 bloc/state；UI 重写 + domain 装饰清理 + ARB 文案迁移
> Pilot Wave: 阶段 3.4.b（设计 → 工程交接）

---

## 1. 现有 BLoC 兼容性

`MeasurementBloc` / `MeasurementEvent` / `MeasurementState`（freezed union）契约不动。

**仍在用的事件**：
- `LoadHistory()` — 初次进入 / 重试 / 下拉刷新
- `DeleteMeasurement(String id)` — 删除单条

**新 UI 派生逻辑（presentation 层）**：
- `groupedByMonth: Map<YearMonth, List<MeasurementEntry>>` — 按 `(date.year, date.month)` 分组
- `previousValueFor(MeasurementEntry, MeasurementType): double?` — 在 `entries` 中找该 type 上一次有值的记录，用于 trend 计算
- `topThreeFilled(MeasurementEntry): List<MeasurementType>` — 该条 entry 实际填写的前 3 项（按 `MeasurementTypes.all` 顺序）
- `summaryCount: int` — entries.length，用于 hero 副行
- `lastEntryDate: DateTime?` — 用于 hero 副行「近一次」

> 不动 bloc 主结构；trend 计算在 widget 内即可（O(N×9)，N 一般 < 100，无需 cubit 化）。

---

## 2. 文件改动清单

### 主文件（重写）
- `lib/features/measurement/presentation/pages/measurement_page.dart` — 完整重写
  - 保留：`BlocListener<MeasurementBloc>` 错误 SnackBar、`BlocBuilder` switch 模式
  - 删除：`FloatingActionButton.extended` (L39-43)、AppBar `Icons.add` (L33-37)、`_MeasurementHistoryCard` Material `Card` 阴影包装 (L143)、`IconButton(Icons.delete_outline)` + `AlertDialog` (L194-216)、`_MeasurementEmptyState` 120dp 圆形容器 + 56dp icon (L100-112)
  - 新结构：`Stack` 外层（承载 sticky CTA） + `CustomScrollView` 内层 [`SliverToBoxAdapter(hero)` + `SliverPersistentHeader(sticky 月份)` + `SliverList(卡片)` × N + `SliverPadding(底 64)`]

### Domain 清理（DEC-042/043 合规）
- `lib/features/measurement/domain/entities/measurement_type.dart` — 删除 displayName 字段中的中文
  - 现状：`enum MeasurementType { bust('胸围', 'cm'), ... }`
  - 改：`enum MeasurementType { bust('cm'), ... }`，删除 `final String displayName;`
  - 单位 `unit` 保留（cm/kg 是国际单位，非语言）

### 新增（presentation 层）
- `lib/features/measurement/presentation/extensions/measurement_type_l10n.dart` — 新建
  ```dart
  extension MeasurementTypeL10n on MeasurementType {
    String localizedName(AppLocalizations l10n) => switch (this) {
      MeasurementType.bust => l10n.measurementTypeBust,
      MeasurementType.underbust => l10n.measurementTypeUnderbust,
      MeasurementType.waist => l10n.measurementTypeWaist,
      MeasurementType.hip => l10n.measurementTypeHip,
      MeasurementType.thigh => l10n.measurementTypeThigh,
      MeasurementType.bicep => l10n.measurementTypeBicep,
      MeasurementType.shoulder => l10n.measurementTypeShoulder,
      MeasurementType.neck => l10n.measurementTypeNeck,
      MeasurementType.weight => l10n.measurementTypeWeight,
    };
  }
  ```

- `lib/features/measurement/presentation/widgets/measurement_record_card.dart` — 新建
  - `HanaListItem` 扩展，title=日期+周几，body=`MeasurementSummaryTable`，trailing=chevron
- `lib/features/measurement/presentation/widgets/measurement_summary_table.dart` — 新建
  - 三行 `Row(测量项 label · mono 数值 · 单位 label-sm · 趋势 body-sm)` + 「+ N 项」尾标
  - 使用 `Wrap` 应对 ja 长 label
- `lib/features/measurement/presentation/widgets/measurement_detail_sheet.dart` — 新建
  - `HanaBottomSheet.info` 内容：9 项 mono 表 + 备注 + [编辑 / 删除]

### 共享组件复用
- `HanaTopBar.defaultBar` / `HanaSectionHeader` / `HanaListItem` / `HanaButton.{primary,secondary,ghost}` / `HanaEmptyState.page` / `HanaErrorState` / `HanaLoadingView.block` / `HanaPressScale` / `HanaBottomSheet.info` / `HanaConfirmDialog`

### 删除（旧 widget 清单）
- `_MeasurementEmptyState`（measurement_page.dart 89-134）— 移除
- `_MeasurementHistoryCard`（136-269）— 移除
- `widgets/measurement_type_icon.dart`（仅 edit 屏使用）— 见 measurement-edit/handoff.md

---

## 3. 数值格式化 + Trend 算法

```dart
String formatValue(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}

/// Returns trend annotation widget or null if no trend should display.
String? trendLabel({
  required double current,
  required double? previous,
  required String unit,
  required AppLocalizations l10n,
}) {
  if (previous == null) return null;
  final delta = current - previous;
  final abs = delta.abs();
  if (abs < 0.1) return null;                        // noise
  if (abs < 0.2) return l10n.measurementTrendFlat;   // "持平"
  final formatted = abs.toStringAsFixed(1);
  return delta > 0
      ? l10n.measurementTrendUp(formatted, unit)     // "↑ 0.5cm"
      : l10n.measurementTrendDown(formatted, unit);  // "↓ 0.3cm"
}
```

> 在 `MeasurementSummaryTable` 内调用：先 `topThreeFilled(entry)` 取 type 列表，对每个 type 查 `previousValueFor(entry, type)` → 渲染 trend 注脚。

---

## 4. ARB Key 清单

新增（`lib/core/l10n/arb/app_zh.arb` / `app_en.arb` / `app_ja.arb`）：

| Key | zh | en | ja |
|-----|----|----|----|
| `measurementHeroTitle` | 身体记录。 | Body record. | からだの記録。 |
| `measurementHeroSubtitle` | 共 {count} 期　近一次 {date} | {count} entries · last on {date} | 全 {count} 件　最近 {date} |
| `measurementSectionMonth` | {year} · {month} 月 | {month} {year} | {year} · {month}月 |
| `measurementCtaRecord` | 记一次。 | Record one. | 一度記す。 |
| `measurementEmptyTitle` | 未记录身体数据。 | No body data yet. | からだの記録なし。 |
| `measurementEmptySubtitle` | 首次记录将开启趋势对比。 | First entry opens trend tracking. | 最初の一筆で推移が始まる。 |
| `measurementTrendUp` | ↑ {value}{unit} | ↑ {value}{unit} | ↑ {value}{unit} |
| `measurementTrendDown` | ↓ {value}{unit} | ↓ {value}{unit} | ↓ {value}{unit} |
| `measurementTrendFlat` | 持平 | flat | 横ばい |
| `measurementMoreItems` | + {count} 项 | + {count} more | + {count} 項目 |
| `measurementDetailEdit` | 编辑 | Edit | 編集 |
| `measurementDetailDelete` | 删除 | Delete | 削除 |
| `measurementDeleteConfirmTitle` | 删除这次记录？ | Delete this entry? | この記録を削除？ |
| `measurementDeleteConfirmKeep` | 保留 | Keep | 残す |
| `measurementTypeBust` | 胸围 | Bust | 胸まわり |
| `measurementTypeUnderbust` | 下胸围 | Underbust | アンダーバスト |
| `measurementTypeWaist` | 腰围 | Waist | 腰まわり |
| `measurementTypeHip` | 臀围 | Hip | ヒップ |
| `measurementTypeThigh` | 大腿围 | Thigh | 太もも |
| `measurementTypeBicep` | 上臂围 | Bicep | 上腕 |
| `measurementTypeShoulder` | 肩宽 | Shoulder | 肩幅 |
| `measurementTypeNeck` | 颈围 | Neck | 首まわり |
| `measurementTypeWeight` | 体重 | Weight | 体重 |

> 现有 ARB key 复用：`bodyMeasurementsTitle` / `newMeasurement` / `startRecordingChanges` / `measurementEmptyHint` / `measurementRecorded` / `deleteMeasurementTitle` / `deleteMeasurementConfirm` / `cancel` / `delete` — 保留兼容，但 measurement 主屏 v2 新代码全部用上表新 key。可在 R6 之后清理旧 key。

---

## 5. 列表分组实现伪代码

```dart
final entries = state.entries; // already sorted desc by date
final months = LinkedHashMap<YearMonth, List<MeasurementEntry>>();
for (final e in entries) {
  final ym = YearMonth(e.date.year, e.date.month);
  months.putIfAbsent(ym, () => []).add(e);
}

CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: _Hero(count: entries.length, last: entries.firstOrNull?.date)),
    for (final entry in months.entries) ...[
      SliverPersistentHeader(
        pinned: true,
        delegate: _MonthHeaderDelegate(label: entry.key.format(localeName)),
      ),
      SliverList.separated(
        itemBuilder: (_, i) => MeasurementRecordCard(
          entry: entry.value[i],
          previousValueFor: (type) => _findPrevious(entries, entry.value[i], type),
          onTap: () => _openDetail(context, entry.value[i]),
        ),
        separatorBuilder: (_, __) => SizedBox(height: HanaTokens.spacing.sm),
        itemCount: entry.value.length,
      ),
      SliverToBoxAdapter(child: SizedBox(height: HanaTokens.spacing.xl)),
    ],
    SliverToBoxAdapter(child: SizedBox(height: 96)), // sticky CTA reserve
  ],
)
```

> `_findPrevious(allEntries, currentEntry, type)`: 在 `allEntries` 里找 `date < currentEntry.date && valueFor(type) != null` 的最近一条，返回该项数值。entries 已 desc sorted，从 currentEntry index+1 开始线性扫即可。

---

## 6. 性能注意

- 100 条 entry × 9 type → trend 计算 O(N²×9) = 90,000 次比较。实测可接受（<10ms）。如未来 N > 500，改为预计算 `Map<MeasurementType, List<(date, value)>>` 索引。
- `SliverPersistentHeader` sticky 月份切换 60fps OK（与 timeline 共用 `_MonthHeaderDelegate`）。
- 详情 sheet 9 项表用 `Column` 静态构建（不是 ListView，9 项无需虚拟化）。

---

## 7. 路由

- 现有：`/measurement` (本屏) / `/measurement/edit` (含 `extra: MeasurementEntry?`)
- 不变。详情 sheet 内「编辑」按钮：`Navigator.pop(); context.push('/measurement/edit', extra: entry);`。
- 主屏 sticky CTA：`context.push('/measurement/edit')`（无 extra = 新建）。
- 删除走 cubit `bloc.add(DeleteMeasurement(entry.id))` + `pull-to-refresh` 自动 reload。

---

## 8. 测试改动

- `test/features/measurement/presentation/pages/measurement_page_test.dart`
  - 删除：FAB tap 测试 / IconButton delete 测试 / Material AlertDialog 找节点
  - 新增：sticky CTA tap 跳路由 / 详情 sheet 升起 / 删除走 HanaConfirmDialog / 月份章节 sticky 出现 / trend 注脚渲染（包括 flat / up / down / null 四种）
- `test/features/measurement/presentation/widgets/measurement_summary_table_test.dart` — 新建
  - trend 算法 4 case + topThreeFilled 排序 + 「+ N 项」尾标渲染
- 现有 mock `MeasurementEntry.fixture` 复用；新增「连续 3 期 entry」fixture 用于 trend 测试

---

## 9. 实施顺序（PR 切分建议）

1. **PR-A**: domain 清理（删 displayName）+ `enum_l10n.dart` 扩展 + ARB key 新增（DEC-042/043 合规先行）
2. **PR-B**: 新增 widgets（`MeasurementSummaryTable` / `MeasurementRecordCard` / `MeasurementDetailSheet`）+ 单元测试
3. **PR-C**: 主页面重写（CustomScrollView + sticky CTA）+ 删除旧 widget + 集成测试
4. **PR-D**: measurement_edit_page 同步重写（见 measurement-edit/handoff.md，建议同 PR-C 一起 merge 避免 ARB key 不一致）

— 完 —
