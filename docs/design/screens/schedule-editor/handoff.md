# Schedule Editor 屏 v2 — Flutter Handoff Spec

> 配对 spec：`docs/design/screens/schedule-editor/spec.md`
> 屏幕：`lib/features/medication/presentation/pages/schedule_editor_page.dart`
> 受 CLAUDE.md 约束：尽量保留 cubit/state 不动；ARB 走 `lib/core/l10n/`
> Pilot Wave: 阶段 3.x.b（设计 → 工程交接）

---

## 1. 现有 BLoC 兼容性

`ScheduleEditorCubit` / `ScheduleEditorState`（sealed class）大部分**不需要改动**——v2 重画 UI 层，setter 契约保持。

**仍在用的 setter**（`schedule_editor_cubit.dart`）：
- `setDosageAmount(double)` — 剂量数值变更
- `setDosageUnit(DosageUnit)` — 单位 toggle 切换
- `setFrequency(MedicationFrequency)` — 频率三卡切换 + 子参数变更（每日次数 / 隔 N 天 / 周几）
- `setStartDate(DateTime)` / `setEndDate(DateTime?)` — 起止日期
- `setScheduleTimes(List<TimeOfDay>)` — 时段全量替换（v2 删除单个时段：UI 算 `[...current]..removeAt(i)` 后调既有 setter；添加：`[...current, newTime]` 后调）
- `validate()` / `save()` — 保存流程

**需要 domain 改动**（破坏性，不可避免）：
- `WeeklyMedicationFrequency(dayOfWeek: int)` 单值 → `daysOfWeek: Set<int>` 多值，支持"周一三五"多选
  - 改 `lib/features/medication/domain/entities/medication_schedule.dart` 的 freezed sealed class
  - 改 `MedicationScheduleEntity` 序列化（DataSource 层 `dayOfWeek` 字段 → JSON `daysOfWeek` 数组）
  - 改 `notification_scheduler` 调度逻辑（按 daysOfWeek 展开多个 PendingNotification）
  - 数据迁移：旧 schedule.dayOfWeek=1 → schedule.daysOfWeek={1}，单条 SQL UPDATE migration（DEC-xxx 待补编号）
  - 测试 mock 全更新（基线 323 测试预计影响 8-10 个 medication 相关 spec）

**新增的 UI 派生逻辑**（仅 presentation 层）：
- `currentTimesWithLabel = state.scheduleTimes.map((t) => (t, _autoLabel(t.hour)))` — 时段卡左侧 label 自动按时间段贴
- `_hasConflict(times, i)` — 第 i 个时段与第 i-1 个间隔是否 < 4h
- 频率"特定星期"模式下 `Set<int> selectedDays = (state.frequency as WeeklyMedicationFrequency?).daysOfWeek ?? {}`

**仍在用的 state 字段**（ScheduleEditorEditing variant）：
- `drugId` / `drugName` / `administrationRoute` / `dosageAmount` / `dosageUnit` / `frequency` / `startDate` / `endDate` / `scheduleTimes` / `validation`
- `notes` 字段当前 cubit 留有 setter `setNotes()` 但 v2 spec 不暴露——保留 cubit 侧兼容（可能未来某 feature 复用），UI 层不渲染

> **不动 cubit + 单点 domain 改动的好处**：UI 层重写工时 ~3 天；domain 改动 + 迁移 + 测试更新 ~2 天，与 UI 解耦可分两 PR 上线（PR-A: domain `daysOfWeek` 迁移 + 旧 UI 兼容；PR-B: UI v2 重写）。**强烈建议合并到单 PR**，避免中间态出现 v1 UI 但 daysOfWeek 已扩展的诡异状态。

---

## 2. 文件改动清单

### 主文件（重写）
- `lib/features/medication/presentation/pages/schedule_editor_page.dart` — **完整重写**
  - 保留：`BlocConsumer<ScheduleEditorCubit, ScheduleEditorState>`、`_onStateChange` listener（ScheduleEditorSaved → pop / ScheduleEditorError → toast）
  - 删除：所有 M3 `AppBar` / `Card` / `TextField` + `OutlineInputBorder` / `ChoiceChip` / `SegmentedButton` / `DropdownButton` / `ListTile` + `RoundedRectangleBorder` / `FilledButton`；所有 `Icons.medication_outlined` / `Icons.calendar_today` / `Icons.access_time` / `Icons.check`；所有 `theme.colorScheme.*` / `theme.textTheme.*` 直接调用（改 `HanaTokens.*` + `HanaTypography.*`）；所有 `showTimePicker` / `showDatePicker` 系统 picker 调用
  - 文件结构（节选）：
    ```dart
    class ScheduleEditorPage extends StatefulWidget {
      const ScheduleEditorPage({super.key});
      @override
      State<ScheduleEditorPage> createState() => _ScheduleEditorPageState();
    }
    class _ScheduleEditorPageState extends State<ScheduleEditorPage> {
      final _dosageController = TextEditingController();
      @override Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          backgroundColor: HanaTokens.background(context),
          appBar: HanaTopBar(
            title: l10n.scheduleEditorTitle, // "时间表。"
            actions: [HanaButton(
              label: l10n.save, variant: HanaButtonVariant.ghost,
              onPressed: () => context.read<ScheduleEditorCubit>().save(),
            )],
          ),
          body: BlocConsumer<ScheduleEditorCubit, ScheduleEditorState>(
            listener: _onStateChange,
            builder: (ctx, state) => switch (state) {
              ScheduleEditorIdle() || ScheduleEditorSaving() =>
                const HanaLoadingView.block(message: "读取中。"),
              ScheduleEditorEditing s => _buildForm(ctx, s, l10n),
              ScheduleEditorSaved() => const SizedBox.shrink(), // 等 pop
              ScheduleEditorError() => _buildForm(ctx, _lastEditing!, l10n), // 维持表单
            },
          ),
        );
      }
      Widget _buildForm(BuildContext ctx, ScheduleEditorEditing s, AppLocalizations l10n) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: HanaTokens.spacing.lg),
          children: [
            SizedBox(height: HanaTokens.spacing.xl),       // hero 顶部 64
            _Hero(drugName: s.drugName, dose: s.dosageAmount, unit: s.dosageUnit, route: s.administrationRoute),
            SizedBox(height: HanaTokens.spacing.lg),       // 段落间 32
            HanaSectionHeader(title: l10n.dosageSection),
            SizedBox(height: HanaTokens.spacing.md),
            _DosageCard(controller: _dosageController, state: s),
            SizedBox(height: HanaTokens.spacing.lg),
            HanaSectionHeader(title: l10n.frequencySection),
            SizedBox(height: HanaTokens.spacing.md),
            _FrequencyCards(state: s),
            if (s.frequency is WeeklyMedicationFrequency) ...[
              SizedBox(height: HanaTokens.spacing.md),
              _WeekdayToggleRow(state: s),
            ],
            SizedBox(height: HanaTokens.spacing.lg),
            HanaSectionHeader(title: l10n.scheduleTimesSection),
            SizedBox(height: HanaTokens.spacing.md),
            ..._buildTimeCards(ctx, s, l10n),
            SizedBox(height: HanaTokens.spacing.sm),
            HanaButton(
              label: l10n.scheduleEditorAddTime, variant: HanaButtonVariant.ghost,
              icon: null, // **绝不**用 Icons.add，文字 "+ 添加时段" 内嵌
              onPressed: () => _showTimePickerSheet(ctx, s, append: true),
            ),
            SizedBox(height: HanaTokens.spacing.lg),
            HanaSectionHeader(title: l10n.dateRangeSection),
            SizedBox(height: HanaTokens.spacing.md),
            _DateCard(label: l10n.startDate, value: s.startDate, ...),
            SizedBox(height: HanaTokens.spacing.md),
            _DateCard(label: l10n.endDate, value: s.endDate, isOptional: true, ...),
            SizedBox(height: HanaTokens.spacing.lg),
            HanaSectionHeader(title: l10n.notificationSection),
            SizedBox(height: HanaTokens.spacing.md),
            _NotificationCard(),
            SizedBox(height: HanaTokens.spacing.xl),       // 底部 64
          ],
        );
      }
    }
    ```

### 子组件（新增 / 复用）
- 复用 Today 屏 PR 1 已落地：`HanaTokens` / `HanaCard` / `HanaButton` / `HanaTopBar` / `HanaSectionHeader` / `HanaCelebration` / `HanaPressScale` / `HanaLoadingView`
- 新增依赖：
  - `lib/core/widgets/hana_text_field.dart` — components/text-field.md 已 spec，需补 `numberDecimal large` variant（mono 24·ink 大数值）
  - `lib/core/widgets/hana_bottom_sheet.dart` — components/bottom-sheet.md 已 spec，需新增 `picker` variant 实现：内嵌 `CupertinoPicker` × 2（hour / minute）锁色 + 自绘选中下划线
  - `lib/core/widgets/hana_switch.dart` — **v1.1 待补 spec**，本 PR 临时降级 Material `Switch` + `MaterialStateProperty.resolveWith` 锁 `HanaTokens.primary` / `HanaTokens.inkSecondary`
  - `lib/core/widgets/hana_toast.dart` — **v1.1 待补 spec**，本 PR 临时降级 `ScaffoldMessenger.showSnackBar` + 锁色 `HanaTokens.error`

### Page 内私有 widget（_前缀，单文件内）
- `_Hero` — display-xl + 副行 mono 索引（drugName + dose + unit + route）
- `_DosageCard` — `HanaCard.flat` 包 `HanaTextField.numberDecimal large` + Wrap 单位 toggle
- `_FrequencyCards` — 3 张 `HanaCard.tappable` + 选中态左 4px 黛蓝竖线 + 子参数（每日"+/−"次数 / 隔 N 天）内嵌
- `_WeekdayToggleRow` — `Wrap(spacing: 8)` 包 7 个 `HanaButton.secondary` toggle，多选 `Set<int>`
- `_TimeCard` — `HanaCard.flat`，左 label 早/午/晚/夜 + mono 时间 + 右 ghost"删除"
- `_TimeConflictHint` — inline body-sm·inkSubdued「与上一时段相隔不足 4 小时。」
- `_DateCard` — `HanaCard.tappable`，body 标签 + mono 日期 / "未定。"
- `_NotificationCard` — `HanaCard.flat` + 一行 body + `HanaSwitch`
- `_showTimePickerSheet(ctx, s, {bool append, int? editIndex})` — 弹 `HanaBottomSheet.picker`，确认后调 `setScheduleTimes`
- `_showDatePickerSheet(ctx, s, {bool isStart})` — 弹 `HanaBottomSheet.picker`，确认后调 `setStartDate` / `setEndDate`

### ARB 改动（`lib/core/l10n/arb/app_{en,zh,ja}.arb`）

| Key 新增 / 改动 | zh | ja | en |
|----------------|----|----|----|
| `scheduleEditorTitle` (替换 `editDrug`) | 时间表。 | 予定表。 | Schedule. |
| `dosageSection` | 剂量 | 用量 | Dose |
| `frequencySection` (沿用 `frequency`) | 频率 | 頻度 | Frequency |
| `frequencyDailyTitle` (替换 `daily`) | 每日 | 毎日 | Daily |
| `frequencyDailyDesc` | 每天的同一时段。 | 毎日同じ時刻。 | Same time daily. |
| `frequencyEveryNDaysTitle` (替换 `everyNDays`) | 隔日 | 隔日 | Every N days |
| `frequencyEveryNDaysDesc` | 每两日记一次。 | 二日ごとに一回。 | Once every two days. |
| `frequencyWeeklyTitle` (替换 `weekly`) | 特定星期 | 特定の曜日 | Specific days |
| `frequencyWeeklyDesc` | 仅在选中的星期。 | 選んだ曜日のみ。 | Selected weekdays only. |
| `scheduleTimesSection` (替换 `scheduleTimes`) | 时段 | 時刻 | Times |
| `scheduleTimeLabelMorning` | 早 | 朝 | AM |
| `scheduleTimeLabelNoon` | 午 | 昼 | Noon |
| `scheduleTimeLabelEvening` | 晚 | 夜 | PM |
| `scheduleTimeLabelNight` | 夜 | 深夜 | Late |
| `scheduleEditorAddTime` | + 添加时段 | + 時刻を追加 | + Add time |
| `scheduleEditorRemoveTime` | 删除 | 削除 | Remove |
| `scheduleConflictHint` | 与上一时段相隔不足 4 小时。 | 前の時刻と 4 時間未満です。 | Less than 4 hours from previous. |
| `dateRangeSection` | 起止 | 期間 | Range |
| `dateStart` (沿用 `startDate`) | 开始 | 開始 | Start |
| `dateEnd` (替换 `endDateOptional`) | 结束 | 終了 | End |
| `dateNotSet` (替换 `noEndDate`) | 未定。 | 未定。 | Not set. |
| `notificationSection` | 通知 | 通知 | Notify |
| `notificationDesc` | 到时静默推送。 | 時刻に静かに通知。 | Silent push at time. |
| `weekdayShort1..7` (沿用现有 weekdayMonday-Sunday，加 short 变体) | 一二三四五六日 | 月火水木金土日 | M T W T F S S |
| `celebrationScheduleSaved` | 时间表已记。 | 予定を記しました。 | Schedule saved. |
| `validationDosageRequired` (沿用) | 请输入剂量。 | 用量を入力。 | Enter dose. |
| `save` (改文案，**保留 key**) | 保存 | 保存 | Save |

旧 key（`editDrug` / `frequency` / `daily` / `everyNDays` / `weekly` / `scheduleTimes` / `selectDate` / `noEndDate` / `endDateOptional`）保留 1 版本备 i18n 灰度后清理，不在本 PR 删除。

---

## 3. 组件依赖（按实施顺序）

```
═══ 已落地（Today 屏 PR 1）═══
1. HanaTokens / HanaTypography / HanaSemanticColors
2. HanaPressScale
3. HanaCard
4. HanaButton
5. HanaTopBar
6. HanaSectionHeader
7. HanaCelebration
8. HanaLoadingView

═══ 本 PR 新增（PR-Schedule 1 范围）═══
9. HanaTextField.numberDecimal large variant     (依赖：HanaTokens)
10. HanaBottomSheet.picker variant               (依赖：HanaTokens, HanaButton)
11. HanaSwitch（v1.1 待补 spec，临时 Material Switch 锁色） (依赖：HanaTokens)
12. HanaToast（v1.1 待补 spec，临时 SnackBar 锁色） (依赖：HanaTokens)

═══ Domain 改动（PR-Schedule 2 范围 / 强烈建议合并 PR-Schedule 1）═══
13. MedicationFrequency.weekly: dayOfWeek → daysOfWeek (Set<int>)
14. DataSource 序列化适配
15. SQL migration v(N) → v(N+1)
16. notification_scheduler 多日展开
17. 测试 mock 更新

═══ Page 重写（PR-Schedule 1 范围）═══
18. schedule_editor_page.dart 重写  (依赖：上述 1-12 + 13-17 的扩展 daysOfWeek)
```

---

## 4. 实施代码骨架（关键片段）

### 4.1 频率"每日 N 次"子参数（卡内嵌）
```dart
// 内嵌在 _FrequencyCards 选中"每日"卡时
if (s.frequency is DailyMedicationFrequency && _isSelected(daily)) ...[
  SizedBox(height: HanaTokens.spacing.md),
  Row(
    children: [
      Text(l10n.timesPerDay, style: HanaTypography.body(context)),
      SizedBox(width: HanaTokens.spacing.md),
      _StepperButton(
        icon: '−', // 文字而非 Icons.remove
        onPressed: () => _setDailyTimes(context, currentN - 1),
      ),
      SizedBox(width: HanaTokens.spacing.sm),
      Text('$currentN', style: HanaTypography.mono(context)),
      SizedBox(width: HanaTokens.spacing.sm),
      _StepperButton(
        icon: '+',
        onPressed: () => _setDailyTimes(context, currentN + 1),
      ),
    ],
  ),
],
```

### 4.2 时段冲突检测
```dart
List<Widget> _buildTimeCards(BuildContext ctx, ScheduleEditorEditing s, AppLocalizations l10n) {
  final widgets = <Widget>[];
  final times = List<TimeOfDay>.from(s.scheduleTimes)..sort((a, b) =>
      (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
  for (var i = 0; i < times.length; i++) {
    widgets.add(_TimeCard(time: times[i], index: i, ...));
    if (i > 0 && _hasConflict(times[i], times[i - 1])) {
      widgets.add(Padding(
        padding: EdgeInsets.only(top: HanaTokens.spacing.xs, left: HanaTokens.spacing.lg),
        child: Text(l10n.scheduleConflictHint,
          style: HanaTypography.bodySm(ctx).copyWith(color: HanaTokens.inkSubdued(ctx))),
      ));
    }
    if (i < times.length - 1) widgets.add(SizedBox(height: HanaTokens.spacing.md));
  }
  return widgets;
}
bool _hasConflict(TimeOfDay a, TimeOfDay b) {
  final am = a.hour * 60 + a.minute;
  final bm = b.hour * 60 + b.minute;
  return (am - bm).abs() < 240; // 4h = 240 min
}
```

### 4.3 时段 label 自动贴
```dart
String _autoLabel(int hour, AppLocalizations l10n) => switch (hour) {
  >= 5 && < 11 => l10n.scheduleTimeLabelMorning,
  >= 11 && < 17 => l10n.scheduleTimeLabelNoon,
  >= 17 && < 24 => l10n.scheduleTimeLabelEvening,
  _ => l10n.scheduleTimeLabelNight,
};
```

### 4.4 BottomSheet 时间选择
```dart
Future<void> _showTimePickerSheet(BuildContext ctx, ScheduleEditorEditing s,
    {required bool append, int? editIndex}) async {
  final initial = append
      ? _suggestNextTime(s.scheduleTimes)
      : s.scheduleTimes[editIndex!];
  final result = await HanaBottomSheet.show<TimeOfDay>(ctx, sheet: HanaBottomSheet(
    title: AppLocalizations.of(ctx)!.scheduleTimesSection,
    child: HanaTimeWheelPicker(initial: initial),
    actions: [
      HanaButton(label: l10n.cancel, variant: ghost, onPressed: () => Navigator.pop(ctx)),
      HanaButton(label: l10n.confirm, variant: primary, onPressed: () => Navigator.pop(ctx, _selectedTime)),
    ],
  ));
  if (result != null && ctx.mounted) {
    final newTimes = append
        ? [...s.scheduleTimes, result]
        : ([...s.scheduleTimes]..[editIndex!] = result);
    ctx.read<ScheduleEditorCubit>().setScheduleTimes(newTimes);
  }
}
```

### 4.5 庆祝触发（_onStateChange listener）
```dart
void _onStateChange(BuildContext context, ScheduleEditorState state) {
  final l10n = AppLocalizations.of(context)!;
  switch (state) {
    case ScheduleEditorSaved():
      HanaCelebration.trigger(context, message: l10n.celebrationScheduleSaved);
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (context.mounted) Navigator.of(context).pop();
      });
    case ScheduleEditorError(:final message):
      HanaToast.error(context, message: _localizeValidation(message, l10n));
    case ScheduleEditorEditing(:final dosageAmount):
      if (dosageAmount != null && _dosageController.text.isEmpty) {
        _dosageController.text = dosageAmount.toString();
      }
    case _: break;
  }
}
```

---

## 5. 测试影响

### 既有测试（基线 323 passing）
- `test/features/medication/presentation/bloc/schedule_editor_cubit_test.dart` — **保持**，cubit 契约不变
- `test/features/medication/presentation/pages/schedule_editor_page_test.dart` — **重写**断言：
  - `find.byType(SegmentedButton)` → `find.byType(HanaCard).at(频率三卡)`
  - `find.text('每日')` → `find.text(l10n.frequencyDailyTitle)`
  - `find.byIcon(Icons.calendar_today)` → 删除（v2 无 icon）
  - 新增：「+ 添加时段」点击弹 BottomSheet 断言
  - 新增：周几 toggle 多选断言
  - 新增：时段冲突警告 inline 文本断言
  - 新增：保存触发 `HanaCelebration` 断言（mock overlay）
- `test/features/medication/domain/entities/medication_schedule_test.dart` — **更新** `WeeklyMedicationFrequency.daysOfWeek` 字段断言

### 新增测试
- `test/core/widgets/hana_text_field_number_decimal_test.dart` — large variant
- `test/core/widgets/hana_bottom_sheet_picker_test.dart` — picker variant + 滚轮交互
- `test/features/medication/data/migrations/v(N+1)_weekly_days_of_week_test.dart` — SQL migration 旧 dayOfWeek=1 → daysOfWeek={1}

预计基线 323 → 335 passing（+12 新增 / -0 移除 / 8 重写）。

---

## 6. 性能 / 工程注意

- `HanaBottomSheet.picker` 内嵌 `CupertinoPicker × 2`（hour 24 项 / minute 60 项）首次构建 ~100ms，可接受；**避免**每次 setState rebuild 整 sheet（用 `StatefulBuilder` 局部更新选中值）
- `_buildTimeCards` 在 scheduleTimes 变更时全量重排（先 sort 再 map），N ≤ 10 性能无忧；超过 10 个时段属异常状态
- `daysOfWeek: Set<int>` 序列化用 `daysOfWeek.toList()..sort()` 保证 JSON 稳定，avoid Set 顺序不确定导致 hash 不稳
- `notification_scheduler` 多日展开：原"每周一 8:00 一条 PendingNotification" → "周一三五 8:00 三条" 数量 ×3，注意 Android `AlarmManager` 上限（300 条 / app）
- Web 平台（DEC-051 sqlite3.wasm）：`BottomSheet` 桌面降级中央浮岛，`CupertinoPicker` 在 Web 滑动惯性受 bridge 影响略卡顿，可接受
- `HanaSwitch` 临时降级 Material Switch 时 dark mode `MaterialStateProperty.resolveWith` 必须显式覆盖 `selectedColor: HanaTokens.primary(context)` + `inactiveTrackColor: HanaTokens.inkSecondary(context)` 否则会出 M3 紫调
- `HanaToast` 临时降级 SnackBar 必须 `behavior: SnackBarBehavior.floating, margin: EdgeInsets.all(16), shape: RoundedRectangleBorder(radius: 4)` 模拟 v2 卡片质感
- AppBar 顶部 `HanaButton.ghost("保存")` 触控热区注意 padding 拉到 44dp（`HanaButton` props 已锁定，无需额外处理）

---

## 7. 风险登记

| 风险 | 严重度 | 缓解 |
|------|-------|------|
| `daysOfWeek` domain 改动破坏向后兼容 | 高 | SQL migration 必须回滚可测；建议 release.yml 加入 staging 数据库验证步骤 |
| `HanaBottomSheet.picker` 自绘滚轮工时不可控 | 中 | 使用 `CupertinoPicker` 锁色降级，**不**自绘整个滚轮 |
| `HanaSwitch` / `HanaToast` v1.1 spec 未落地 | 中 | 临时降级方案明确（Material + 锁色）；v1.1 spec 落地后补 PR 替换 |
| `ScheduleEditorError` 维持表单态需要保留上一份 editing state | 中 | 在 page state 里保留 `_lastEditing` 引用，BlocConsumer listener 中更新；不动 cubit 状态机 |
| 周几 toggle en 双 T 不可读 | 低 | spec 暂保 1 字符，handoff 阶段 visual review 决定是否切 3 字符（"Mon"-"Sun"），增宽 60% 需 Wrap 自动换行验证 |
| 系统 picker 用户习惯 | 低 | v2 整体语法已切，schedule editor 是最后一屏；用户跨屏一致后迁移成本可吸收 |
| 通知调度 ×3 触发 Android 300 条上限 | 低 | 用户极端场景（10 时段 × 7 天 = 70 条 / schedule × 3 schedules = 210 条）仍未超限；监控埋点观察 P99 |

---

## 8. PR 切片建议

**强烈建议合并到单一 PR**（避免中间态 v1 UI + 新 daysOfWeek domain 撕裂）：

```
PR-Schedule v2 全量
├─ commit 1: ARB 三语新 key
├─ commit 2: domain MedicationFrequency.weekly daysOfWeek 改造 + freezed regen
├─ commit 3: data layer 序列化适配 + SQL migration v(N+1)
├─ commit 4: notification_scheduler 多日展开
├─ commit 5: HanaTextField numberDecimal large variant
├─ commit 6: HanaBottomSheet picker variant
├─ commit 7: HanaSwitch / HanaToast 临时降级
├─ commit 8: schedule_editor_page.dart 重写（删 v1 + 引入 v2 私有 widget）
├─ commit 9: 测试更新（cubit + page + migration + 新增 widget tests）
└─ commit 10: docs/ai-cto 状态记忆更新（DEC-xxx 编号录入）
```

预计工时：UI 重写 3d + domain 迁移 2d + 测试 + review 1.5d = **6.5 工程日**，对齐 medication 模块最复杂表单屏的预算。

---

— 完 —
