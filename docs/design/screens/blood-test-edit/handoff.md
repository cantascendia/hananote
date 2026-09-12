# Blood Test Edit 屏 v2 — Flutter Handoff Spec

> Generated 2026-04-29
> Pairs with `docs/design/screens/blood-test-edit/spec.md`
> 目标文件：`lib/features/blood_test/presentation/pages/blood_test_edit_page.dart`（537 行 inline → 拆 6 段，预计 ~620 行）
> 现有完成度：55%（domain `statusFor` / `targetRange` / `defaultUnit` / repository 接口齐全；UI + 文案 + 默认值 + 单位换算 + 测量来源 + 跨性别敏感性需重写）

---

## 1. 范围与不动项

**重写**:
- UI 层（`_CardWrapper` / `Dismissible` / `DropdownButtonFormField` / `showDatePicker` 全删）
- 文案（4 现有 key 改 + ~22 新增 key，详见 §4）
- 视觉 token（`HanaColors.*` → `HanaTokens.*(context)`）
- 数值字段字体（默认 sans → JetBrains Mono Light）
- Validation 路径（SnackBar → inline body-sm inkSecondary + HanaToast）
- 跨性别敏感文案（「睾酮」→「雄激素水平」中性词 ARB key）

**不动**:
- `BloodTestRepository.getReportById / addReport / updateReport` 接口
- `IdGenerator.generate()` 用法
- `BloodTestReport` / `HormoneReading` entity 结构
- `HormoneType` / `HormoneStatus` enum 值列表
- `HormoneTypeX.statusFor` / `targetRange` / `defaultUnit` 算法（本期沿用 feminizing 默认；profile 派发延后到 cubit 注入层）
- 路由 `context.pop()` 出口
- `BloodTestBloc.add(LoadDashboard)` 保存后刷新

---

## 2. State 管理

继续用本地 `StatefulWidget` state——单次表单提交场景，无需新 cubit。

### 2.1 字段重设计

```dart
class _BloodTestEditPageState extends State<BloodTestEditPage> {
  // -- 顶部字段 --
  late DateTime _testDate;
  MeasurementSource? _source;                  // ⚠ v1: 无（仅 labName 自由文本）
  late final TextEditingController _labNameController;
  late final TextEditingController _notesController;

  // -- 测量值列表 --
  final List<_ReadingDraft> _readings = [];

  // -- 状态 --
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDirty = false;                       // 取消时判断是否弹 ConfirmDialog
  BloodTestReport? _existingReport;

  // -- profile（settings 注入；缺失时 fallback feminizing）--
  UserHormoneProfile _profile = UserHormoneProfile.feminizing;

  bool get _isEditing => widget.reportId != null;
  bool get _canSave =>
      _readings.isNotEmpty &&
      _readings.every((r) => r.value != null && r.value! > 0) &&
      _source != null;
}

class _ReadingDraft {
  _ReadingDraft({
    required this.id,
    required this.type,
    this.value,
    required this.unit,
  });

  final String id;          // 新增时 IdGenerator.generate()，编辑时复用 reading.id
  HormoneType type;
  double? value;            // ⚠ v1: double（0 与未输入混淆）
  String unit;

  // 状态计算（lazy，blur 后缓存）
  HormoneStatus? cachedStatus;
}

enum MeasurementSource { selfPaid, publicHospital, transHealthClinic, selfTest }

extension MeasurementSourceX on MeasurementSource {
  String localizedName(AppLocalizations l10n) => switch (this) {
        MeasurementSource.selfPaid => l10n.sourceSelfPaid,
        MeasurementSource.publicHospital => l10n.sourcePublicHospital,
        MeasurementSource.transHealthClinic => l10n.sourceTransHealthClinic,
        MeasurementSource.selfTest => l10n.sourceSelfTest,
      };
}
```

**关键改动**:
- `_ReadingEntry` rename `_ReadingDraft`，`value` 改 `double?` 区分零值与未输入；新增 `id`（持久化）+ `cachedStatus`（避免每帧重算）
- 新增 `_source` enum 字段 + `MeasurementSource` enum + 扩展（**新文件** `lib/features/blood_test/domain/entities/measurement_source.dart`）
- `_isDirty` 由所有 setter 置 true，cancel 时判断
- `_profile` 注入：从 `getIt<SettingsCubit>().state.hormoneProfile` 读，缺失时 fallback `feminizing` + hero 副行显示 fallback 提示

### 2.2 模板预填 / 新增条目

```dart
Future<void> _addReading() async {
  final used = _readings.map((r) => r.type).toSet();
  final available =
      HormoneType.values.where((t) => !used.contains(t)).toList();
  if (available.isEmpty) return;

  // ⚠ v1: 自动选第一个未用 hormone（黑魔法）
  // v2: 让用户先选
  final picked = await HanaBottomSheet.show<HormoneType>(
    context,
    sheet: HanaBottomSheet(
      title: l10n.bloodTestEditPickHormone,           // "指标。"
      child: _HormonePickerList(items: available),
    ),
  );
  if (picked == null) return;

  setState(() {
    _readings.add(_ReadingDraft(
      id: IdGenerator.generate(),
      type: picked,
      unit: picked.defaultUnit,
    ));
    _isDirty = true;
  });
}
```

### 2.3 单位换算

```dart
Future<void> _switchUnit(_ReadingDraft draft) async {
  final supported = draft.type.supportedUnits;       // 新增 enum getter
  final picked = await HanaBottomSheet.show<_UnitChoice>(
    context,
    sheet: HanaBottomSheet(
      title: l10n.bloodTestEditPickUnit,
      child: _UnitPickerWithConversion(
        currentUnit: draft.unit,
        currentValue: draft.value,
        candidates: supported,
        // 每行显示 "{unit}　{value} {old} = {converted} {new}"
      ),
    ),
  );
  if (picked == null) return;

  setState(() {
    draft.unit = picked.unit;
    if (picked.convert && draft.value != null) {
      draft.value = _UnitConverter.convert(
        from: draft.unit,
        to: picked.unit,
        value: draft.value!,
        hormone: draft.type,
      );
    }
    draft.cachedStatus = null;       // 强制重算
    _isDirty = true;
  });
}
```

`_UnitConverter` 是新建工具类，含 E2 (pmol/L ↔ pg/mL: ÷ 3.671)、T (nmol/L ↔ ng/dL: × 28.84)、SHBG（同 nmol/L 标准）等换算系数。**单位是国际标准，不走 i18n**。

### 2.4 验证 + 状态评估

```dart
void _onValueBlur(_ReadingDraft draft) {
  if (draft.value == null) return;
  setState(() {
    draft.cachedStatus = draft.type.statusFor(draft.value!, profile: _profile);
  });
}
```

**关键改动**：`HormoneTypeX.statusFor` 新增 `profile` 可选参数（domain layer 修改：
```dart
HormoneStatus statusFor(double value, {UserHormoneProfile profile = UserHormoneProfile.feminizing}) {
  final (min, max) = targetRangeFor(profile);
  ...
}
```
`targetRangeFor(profile)` 替换原 `targetRange` getter；保留 `targetRange` 作为 deprecated alias 指向 feminizing 兼容性）。

### 2.5 删除条目

```dart
Future<void> _onLongPressDelete(_ReadingDraft draft) async {
  final confirmed = await showHanaConfirmDialog(
    context,
    title: l10n.bloodTestEditRemoveTitle,           // "移除该测量值？"
    body: l10n.bloodTestEditRemoveBody,             // "移除后该次测量将不再保留。"
    confirmText: l10n.remove,                       // 朱砂 ghost
    cancelText: l10n.cancel,                        // 默认 ghost（默认聚焦）
    destructive: true,
  );
  if (confirmed != true) return;
  setState(() {
    _readings.remove(draft);
    _isDirty = true;
  });
}
```

`Dismissible` widget + `errorContainer` 红底 + `Icons.delete` 全删。

### 2.6 取消 + dirty 检查

```dart
Future<void> _onCancel() async {
  if (!_isDirty) {
    context.pop();
    return;
  }
  final confirmed = await showHanaConfirmDialog(
    context,
    title: l10n.unsavedChangesTitle,                // "未保存的改动将被丢弃。"
    body: l10n.unsavedChangesBody,                  // "仍要离开？"
    confirmText: l10n.leave,                        // 朱砂 ghost
    cancelText: l10n.stay,
  );
  if (confirmed == true) context.pop();
}
```

物理返回键走同一逻辑：`PopScope(canPop: !_isDirty, onPopInvoked: ...)`.

---

## 3. Widget 树拆分

把 537 行 inline 拆成 6 段（保持 1 文件，便于阅读）：

```
BloodTestEditPage (StatefulWidget)
└─ _BloodTestEditPageState
   ├─ build()
   │  └─ Scaffold
   │     ├─ HanaTopBar.default(leading: ghostBack, trailing: ghostSave)
   │     └─ ListView
   │        ├─ _Hero(profile: _profile, count: _readings.length)
   │        ├─ _DateSection(date: _testDate, onTap: _pickDate)
   │        ├─ _SourceSection(source: _source, labName: _labNameController, onSourceChange: ...)
   │        ├─ _ReadingsSection(readings: _readings, onAdd: _addReading, ...)
   │        ├─ _NotesSection(controller: _notesController)
   │        └─ _BottomActionBar(canSave: _canSave, onCancel: _onCancel, onSave: _save)
   ├─ _pickDate() → HanaBottomSheet 内嵌日期 picker（不是 showDatePicker）
   ├─ _addReading() / _switchUnit() / _onLongPressDelete() / _onValueBlur()
   ├─ _save() → repo + HanaToast + pop
   └─ _onCancel() → dirty check
```

`_Hero` / `_DateSection` / `_SourceSection` / `_ReadingsSection`（含 `_ReadingCard` 子组件）/ `_NotesSection` / `_BottomActionBar` 全部 `StatelessWidget` 嵌入私有 class（同文件内）。

**`_ReadingCard` 关键 widget 树**：
```dart
HanaCard.flat(
  onLongPress: () => _onLongPressDelete(draft),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    // Row 1: hormone title + chevron → 触发 hormone picker
    InkWell(
      onTap: () => _switchHormone(draft),
      child: Row(children: [
        Expanded(child: Text(draft.type.localizedNeutralName(l10n), style: title18)),
        const Icon(Icons.chevron_right, size: 16, color: inkSecondary),
      ]),
    ),
    SizedBox(height: spacing.sm),
    // Row 2: numeric input + unit chip
    Row(crossAxisAlignment: CrossAxisAlignment.baseline, children: [
      Expanded(
        flex: 3,
        child: HanaInput.numeric(
          controller: ...,
          textStyle: monoLight24,                  // ⚠ JetBrains Mono Light 24
          onSubmitted: (v) => _onValueBlur(draft),
          onChanged: (v) { draft.value = double.tryParse(v); _isDirty = true; },
        ),
      ),
      SizedBox(width: spacing.xs),
      InkWell(
        onTap: () => _switchUnit(draft),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(draft.unit, style: labelMedium),
          const Icon(Icons.chevron_right, size: 16, color: inkSecondary),
        ]),
      ),
    ]),
    SizedBox(height: spacing.sm),
    // Row 3: 状态注脚（按 cachedStatus 切换）
    _StatusFootnote(status: draft.cachedStatus),
  ]),
)
```

`_StatusFootnote` 切换逻辑（带 240ms fadeIn）：
```dart
Widget _StatusFootnote({HormoneStatus? status}) {
  return AnimatedSwitcher(
    duration: motion.standard,
    child: switch (status) {
      null || HormoneStatus.normal => Text(l10n.statusInRange, style: bodySmInkSecondary),
      HormoneStatus.warning => Text(l10n.statusOutMild, style: bodySmInkSecondary),
      HormoneStatus.critical => Column(children: [
        Text(l10n.statusOutOfRange, style: bodySmInkSecondary),
        SizedBox(height: spacing.xs),
        Text(l10n.statusCriticalSuggest, style: bodySmError),    // 朱砂仅此一处
      ]),
    },
  );
}
```

数值染色逻辑由 `_ReadingCard` 数值 `TextStyle.color` 派发：`status == null || normal ? ink : primary`（warning + critical 都黛蓝）。

---

## 4. ARB i18n 改动

### 4.1 改写现有 key

| key | v1 | v2 |
|-----|----|----|
| `editBloodReport` | 「编辑血检报告」 | 「记一份血检。」 |
| `addBloodReport` | 「添加血检报告」 | 「记一份血检。」（同 hero，与编辑共用） |
| `addReading` | 「添加读数」 | 「添加一项。」 |
| `selectHormone` | 「选择激素」 | 「指标。」 |
| `hormoneValue` | 「数值」 | 「数值。」 |

### 4.2 新增 key（~22 个）

中性医学术语：
- `hormone.estradiol.neutral` 「雌激素」/ "Estrogen" /「エストロゲン」
- `hormone.testosterone.neutral` 「雄激素水平」/ "Androgen level" /「アンドロゲン値」
- `hormone.progesterone.neutral` 「孕激素」/ "Progestogen" /「プロゲストゲン」
- `hormone.prolactin.neutral` 「泌乳素」/ "Prolactin" /「プロラクチン」
- `hormone.lh.neutral` `hormone.fsh.neutral` `hormone.shbg.neutral`（保留缩写）

测量来源：
- `source.selfPaid` 「自费检查」
- `source.publicHospital` 「公立医院」
- `source.transHealthClinic` 「跨健康体检」
- `source.selfTest` 「自购试剂」

状态注脚：
- `bloodTest.statusInRange` 「在常规范围内。」
- `bloodTest.statusOutMild` 「略偏离常规范围。」
- `bloodTest.statusOutOfRange` 「超出常规范围。」
- `bloodTest.statusCriticalSuggest` 「建议复诊。」

CTA / 章节：
- `bloodTestEdit.heroSubtitle` 「按 {profile} 范围参考　共 {n} 项」（带 ICU placeholder）
- `bloodTestEdit.sectionDate` 「日期。」
- `bloodTestEdit.sectionSource` 「来源。」
- `bloodTestEdit.sectionReadings` 「测量值。」
- `bloodTestEdit.sectionNotes` 「备注。」
- `bloodTestEdit.notesHelper` 「可写采血时间、空腹与否、月经周期。」
- `bloodTestEdit.save` 「记下。」
- `bloodTestEdit.removeTitle` 「移除该测量值？」
- `bloodTestEdit.removeBody` 「移除后该次测量将不再保留。」
- `bloodTestEdit.unitConversionPreview` 「{from} → {to}：{value} 换算为 {converted}」
- `bloodTestEdit.unitDontConvert` 「不换算（仅改单位）」
- `bloodTestEdit.profileFallback` 「未设置 profile，按 feminizing 默认。」+ 「{action} 设置」（可点跳 settings）

DEC-042/043 修复：picker 内 hormone 文案必须用 `t.localizedNeutralName(l10n)`（**新扩展方法**），不用 v1 line 32 的 `displayName` 直出。

---

## 5. 视觉 token 应用清单（替换表）

| v1 | v2 |
|----|-----|
| `HanaColors.primary`（樱粉） | `HanaTokens.primary(context)`（黛蓝 #1F3A5F） |
| `HanaColors.surfaceContainerLow` | `HanaTokens.background(context)` |
| `HanaColors.surfaceContainerLowest` | `HanaTokens.surfaceContainerLowest(context)` |
| `HanaColors.errorContainer` | **删除**（v2 无 errorContainer，destructive 仅文字朱砂） |
| `HanaColors.error` | `HanaTokens.error(context)` 朱砂 |
| `HanaColors.onSurface` | `HanaTokens.ink(context)` |
| `HanaColors.onSurfaceVariant` | `HanaTokens.inkSecondary(context)` |
| `fontFamily: 'Plus Jakarta Sans'` | **全删**；标题走 `Spectral SemiBold` / 思源宋体 Medium / Noto Serif JP Medium 三语 fallback chain；正文 `Inter` / 思源黑体 / Noto Sans JP；数值 `JetBrains Mono Light` |
| `BoxShadow blur 8 offset (0,2)` | **全删**（elev-0） |
| `BorderRadius.circular(16)` | `BorderRadius.circular(4)`（卡）/ `2`（input）/ `6`（button） |
| `Icons.calendar_today` / `Icons.local_hospital_outlined` / `Icons.notes_outlined`（章节 prefix）| **全删**（章节标题不带 icon，靠段落标记 + spacing） |
| `Icons.check_circle_outline`（save）| **全删**（trailing 改文字 ghost「记下。」） |
| `Icons.add_circle_outline`（add reading）| **全删**（改 `HanaButton.text` 文字） |
| `Icons.remove_circle_outline`（行内删除）| **全删**（改长按 + ConfirmDialog） |

---

## 6. 验收清单（Acceptance）

实施完成后需逐项确认：

- [ ] `flutter analyze --fatal-infos` 0 issue
- [ ] `flutter test` 基线 323 个仍通过；新增 `_UnitConverter` / `MeasurementSourceX` / `_canSave` 单测各 ≥ 3 case
- [ ] 黛蓝稳态出现 = 3 处（hero 竖线 + 来源 toggle 选中 + 保存按钮）；异常值偶发态 ≤ 2 处
- [ ] 所有数值字段使用 JetBrains Mono Light（hormone readout 24 / 输入 18 / 单位换算预览 14 / 日期 18）
- [ ] 单位 picker 含换算预览 + 「不换算」出口
- [ ] 长按删除 + ConfirmDialog 走通；`Dismissible` widget 0 处
- [ ] `showDatePicker` 0 处；日期走 `HanaBottomSheet.picker`
- [ ] `DropdownButtonFormField` 0 处；hormone / source / unit 全部走 `HanaBottomSheet.picker`
- [ ] `BoxShadow` / `BackdropFilter` 0 处
- [ ] `Plus Jakarta Sans` 0 处
- [ ] 跨性别敏感性：「睾酮」字符串在源码与运行 UI 中均不出现；中性 ARB key 三语对齐
- [ ] `UserHormoneProfile` 缺失时 hero fallback 提示可见
- [ ] `prefers-reduced-motion` 行为：fadeIn 切换 0ms；input focus 80ms 保留
- [ ] a11y screen reader 朗读：「{hormone} {value} {unit} {statusText}」整体一单元
- [ ] 取消 dirty 检查：未保存改动时弹 ConfirmDialog
- [ ] 保存按钮在不满足条件时 inkSecondary 灰态不可点

---

## 7. 节奏与停顿

- **进入屏**: `context.push('/data/add_report?id={id?}')` → go_router 默认 240ms slideUp
- **加载现有报告**: `motion.standard` 240ms fadeIn 错落 80ms（hero / 章节 / 卡片依次）
- **打开 bottom sheet**（日期 / hormone / unit）: 240ms easeInOut 上移 + scrim 淡入
- **数值离焦 → 状态注脚切换**: 240ms `AnimatedSwitcher` fadeIn 替换
- **单位换算后数值更新**: 240ms `AnimatedDefaultTextStyle` fadeIn（避免数字突变跳动）
- **保存**: tap → button press scale 0.98 (150ms) → repo addOrUpdate → `HanaToast`「已记下。」inkSecondary 1.2s + `context.pop()`；**不**触发 HanaCelebration（庆祝留给"记一次"服药动作，"录入一份血检"是工具操作）
- **删除条目**: ConfirmDialog confirm → 卡 fadeOut 240ms + 列表 collapse `motion.standard`

---

## 8. 风险与待补

- **`HanaSegmented` 未落地**: 来源 toggle 当前用 `HanaButton.secondary` ×4 横排 Wrap 替代；后续若 settings 屏 / data 屏 chip 行复用，再抽 `HanaSegmented` component spec。
- **`_UnitConverter` 范围**: 本期仅覆盖 7 个 HormoneType 的常用 2-3 个单位；若用户输入非标准单位（如 ng/L）则 picker 中不显示，需先改单位为标准再录入。后续可扩展 supportedUnits map。
- **`UserHormoneProfile` enum 落地**: 本 handoff 假设 `lib/features/settings/domain/entities/user_hormone_profile.dart` 已存在；若未实现，先建 enum + settings cubit 字段 + onboarding 屏 X 注入路径，再做本屏 fallback。该依赖可与本屏并行实施。
- **`HanaCard.flat`**: 当前 `HanaCard` component spec 仅有 `tappable`；本 spec 引用 `flat` variant 表示 elev-0 + radius-4 + 点击交给子 widget（hormone row / unit chip），需在 `components/card.md` 加 `flat` variant 说明。
- **测量来源 enum 持久化**: `BloodTestReport` entity 需新增 `MeasurementSource? source` 字段 + freezed 重生成 + `BloodTestReportModel` JSON serialize + 数据库 migration（v? → v?+1，加 `source TEXT NULL` 列）。该 schema 改动**不在 UI 层 PR**，需配套 R52-X data migration 任务。

— 完 —
