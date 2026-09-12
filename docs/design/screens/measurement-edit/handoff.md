# Measurement Edit 屏 v2 — Flutter Handoff Spec

> 配对 spec：`docs/design/screens/measurement-edit/spec.md`
> 屏幕：`lib/features/measurement/presentation/pages/measurement_edit_page.dart`
> 受 CLAUDE.md 约束：保留 bloc/state；UI 重写 + 删除 `MeasurementTypeIcon` widget + ARB key 迁移
> Pilot Wave: 阶段 3.4.b（设计 → 工程交接）
> 配对 PR 建议：与 measurement 主屏 handoff §9 PR-D 同 PR merge

---

## 1. 现有 BLoC 兼容性

`MeasurementBloc` / `MeasurementEvent` / `MeasurementState`（freezed union）契约不动。

**仍在用的事件**：
- `SaveMeasurement(MeasurementEntry entry)` — 创建 / 更新

**仍在用的 state**：
- `MeasurementSaving` — 显示 button loading
- `MeasurementSaved` — 触发 `Navigator.pop(true)`
- `MeasurementError(String message)` — toast 显示

> 无新增事件 / state。

---

## 2. 文件改动清单

### 主文件（重写）
- `lib/features/measurement/presentation/pages/measurement_edit_page.dart` — 完整重写
  - 保留：`StatefulWidget` 框架、`_controllers` Map<MeasurementType, TextEditingController>、`_notesController`、`_selectedDate`、`_saveEntry()` 逻辑、`BlocListener` 监听 saved / error
  - 删除：
    - `_DatePickerTile` (L210-232) — 改 `HanaInput`-style + sheet
    - `_MeasurementSection` (L234-279) — 删除 Card 包装
    - `_MeasurementInputField` (L281-303) — 改 `HanaInput.numeric`，删除 `MeasurementTypeIcon` prefixIcon
    - `ExpansionTile`「扩展指标」(L91-111) — 9 项一次性展开
    - `showDatePicker` 调用 (L147-152) — 改 `HanaBottomSheet.picker`
    - `FilledButton` (L122-138) — 改 `HanaButton.primary`
    - `Card(color: surfaceContainerLowest)` × 3 — 全删

### 删除文件
- `lib/features/measurement/presentation/widgets/measurement_type_icon.dart` — **整个 widget 删除**
  - 删除原因：原则 5（内容即装饰）违规 + 跨性别敏感性盲点 C（人体部位象形图标隐含性别符号）
  - 引用清理：仅 `measurement_edit_page.dart:11` 一处 import + L297 一处使用

### 新增（presentation 层）
- `lib/features/measurement/presentation/widgets/measurement_date_picker_sheet.dart` — 新建
  - `HanaBottomSheet` 包装 `CalendarDatePicker`（如未来 `HanaCalendar` component 落地则替换）
  - props: `initialDate, firstDate=DateTime(2000), lastDate=DateTime.now().add(Duration(days:1)), onConfirm`
- `lib/features/measurement/presentation/widgets/measurement_numeric_field.dart` — 新建
  - `HanaInput.numeric` 包装：label 内嵌 `(cm)` 单位 + `controller` + `keyboardType: numberWithOptions(decimal: true)` + 校验 helper

### 共享组件复用
- `HanaTopBar.defaultBar`
- `HanaInput.numeric` / `HanaInput.multiline`
- `HanaButton.{primary, ghost, text}`
- `HanaBottomSheet.picker`
- `HanaToast.error`

### Domain（与 measurement 主屏共用）
- `lib/features/measurement/domain/entities/measurement_type.dart` — 删除 `displayName` 字段（详见 measurement/handoff.md §2）
- `lib/features/measurement/presentation/extensions/measurement_type_l10n.dart` — 共用（measurement/handoff.md §2 已建）

---

## 3. 日期 Picker Sheet 实现

```dart
Future<DateTime?> showMeasurementDatePicker(
  BuildContext context, {
  required DateTime initialDate,
}) async {
  return HanaBottomSheet.show<DateTime>(
    context: context,
    title: AppLocalizations.of(context)!.measurementEditDateSheetTitle,
    builder: (sheetContext) => _MeasurementDatePickerSheet(
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    ),
  );
}

class _MeasurementDatePickerSheet extends StatefulWidget {
  final DateTime initialDate, firstDate, lastDate;
  // ...
  State<_MeasurementDatePickerSheet> createState() => _State();
}

class _State extends State<_MeasurementDatePickerSheet> {
  late DateTime _picked = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Theme override: primary = HanaTokens.primary, surface = surfaceContainerLowest
        Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: HanaTokens.primary(context),
              onPrimary: HanaTokens.onPrimary(context),
              surface: HanaTokens.surfaceContainerLowest(context),
              onSurface: HanaTokens.ink(context),
            ),
            textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'JetBrains Mono', // mono 数字
            ),
          ),
          child: CalendarDatePicker(
            initialDate: _picked,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            onDateChanged: (d) => setState(() => _picked = d),
          ),
        ),
        SizedBox(height: HanaTokens.spacing.lg),
        Row(
          children: [
            HanaButton.ghost(label: l10n.cancel, onPressed: () => Navigator.pop(context)),
            const Spacer(),
            HanaButton.primary(
              label: l10n.measurementEditDateSheetConfirm, // "用此日"
              onPressed: () => Navigator.pop(context, _picked),
            ),
          ],
        ),
      ],
    );
  }
}
```

> 短期方案：用 `CalendarDatePicker` + Theme override（替换 Material 蓝为 v2 黛蓝 + mono 字体）。中期：抽 `HanaCalendar` component 单独 spec。

---

## 4. 主页面伪代码

```dart
class _MeasurementEditPageState extends State<MeasurementEditPage> {
  // ... 保留 _selectedDate, _controllers, _notesController, dispose ...

  bool get _hasAnyValue =>
      _controllers.values.any((c) => c.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<MeasurementBloc, MeasurementState>(
      listener: _handleStateChange,
      child: Scaffold(
        backgroundColor: HanaTokens.background(context),
        appBar: const HanaTopBar.defaultBar(),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: HanaTokens.spacing.lg),
          children: [
            SizedBox(height: HanaTokens.spacing.xl),
            _Hero(),
            SizedBox(height: HanaTokens.spacing.xl),

            _SectionTitle(label: l10n.measurementEditSectionDate, withBar: false),
            SizedBox(height: HanaTokens.spacing.md),
            _DateRow(date: _selectedDate, onTap: _pickDate),
            SizedBox(height: HanaTokens.spacing.lg),

            _SectionTitle(label: l10n.measurementEditSectionData, withBar: false),
            SizedBox(height: HanaTokens.spacing.md),
            for (var i = 0; i < MeasurementTypes.all.length; i++) ...[
              MeasurementNumericField(
                type: MeasurementTypes.all[i],
                controller: _controllers[MeasurementTypes.all[i]]!,
              ),
              if (i != MeasurementTypes.all.length - 1)
                SizedBox(height: HanaTokens.spacing.md),
            ],
            SizedBox(height: HanaTokens.spacing.lg),

            _SectionTitle(label: l10n.measurementEditSectionNotes, withBar: false),
            SizedBox(height: HanaTokens.spacing.md),
            HanaInput.multiline(
              controller: _notesController,
              minLines: 3,
            ),
            SizedBox(height: HanaTokens.spacing.xl),

            _ActionBar(
              onCancel: () => Navigator.pop(context),
              onSave: _hasAnyValue ? _saveEntry : null,
              isSaving: context.watch<MeasurementBloc>().state is MeasurementSaving,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + HanaTokens.spacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showMeasurementDatePicker(context, initialDate: _selectedDate);
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ... _saveEntry 不变（仅末尾不再依赖 IdGenerator + DateTime cleanup 已 OK） ...
}
```

> `_Hero` / `_SectionTitle(withBar: bool)` / `_DateRow` / `_ActionBar` 都是文件内 private widget，无需独立 component。

---

## 5. ARB Key 清单

新增（`lib/core/l10n/arb/app_zh.arb` / `app_en.arb` / `app_ja.arb`）：

| Key | zh | en | ja |
|-----|----|----|----|
| `measurementEditHeroTitle` | 记一次。 | Record one. | 一度記す。 |
| `measurementEditHeroSubtitle` | 把今天的样子记下来。 | Note today's shape. | いまのからだを記す。 |
| `measurementEditSectionDate` | 日期。 | Date. | 日付。 |
| `measurementEditSectionData` | 数据。 | Data. | データ。 |
| `measurementEditSectionNotes` | 备注。 | Notes. | メモ。 |
| `measurementEditDateSheetTitle` | 选日子。 | Pick a date. | 日付を選ぶ。 |
| `measurementEditDateSheetConfirm` | 用此日 | Use this date | この日を使う |
| `measurementEditCancel` | 取消 | Cancel | やめる |
| `measurementEditSave` | 保存。 | Save. | 保存。 |
| `measurementEditFieldLabel` | {name} ({unit}) | {name} ({unit}) | {name} ({unit}) |

> 现有 ARB key 复用：`editMeasurement` / `createMeasurement` / `coreMeasurements` / `extendedIndicators` / `notes` / `save` / `measurementDate` — measurement edit v2 不再使用 `coreMeasurements` `extendedIndicators` `measurementDate`，可在 R6 后清理。

---

## 6. HanaInput.numeric 用法

```dart
class MeasurementNumericField extends StatelessWidget {
  final MeasurementType type;
  final TextEditingController controller;
  // ...
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return HanaInput.numeric(
      controller: controller,
      label: l10n.measurementEditFieldLabel(type.localizedName(l10n), type.unit),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      // mono Light font applied internally by HanaInput.numeric
    );
  }
}
```

> `HanaInput.numeric` 是 `HanaInput` 的 variant：内置 JetBrains Mono Light 字体，仅底部 1px outline / focus 2px primary，**无 prefixIcon / 无 OutlineInputBorder**。

---

## 7. 测试改动

- `test/features/measurement/presentation/pages/measurement_edit_page_test.dart`
  - 删除：`MeasurementTypeIcon` finder / `ExpansionTile` interaction / `showDatePicker` mock / `FilledButton` finder
  - 新增：
    - 「9 项全空时保存按钮 disabled」
    - 「至少 1 项非空时按钮 enabled」
    - 「点日期字段 → sheet 升起 → 选中 → 字段更新」
    - 「Saving 状态按钮 spinner」
    - 「Saved → Navigator.pop(true)」
    - 「Error → HanaToast.error」
- `test/features/measurement/presentation/widgets/measurement_numeric_field_test.dart` — 新建（label 内嵌单位 / FilteringTextInputFormatter / mono 字体应用）

---

## 8. 实施顺序

随 measurement 主屏 PR 切分（measurement/handoff.md §9）：
- **PR-A**: domain + ARB（共用）
- **PR-D**: 本屏重写（与主屏 PR-C 同 merge 避免 ARB key 不一致 + 删除 `MeasurementTypeIcon` widget 一次完成）

— 完 —
