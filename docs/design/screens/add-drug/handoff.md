# Add Drug 屏 v2 — Flutter Handoff Spec

> Generated 2026-04-29
> Pairs with `docs/design/screens/add-drug/spec.md`（单页表单 + 模板 sheet）
> 目标文件：`lib/features/medication/presentation/pages/add_drug_page.dart`（428 行 inline → 拆 5 段）
> 现有完成度：60%（功能跑通；模板 picker + 手动表单 cubit / repository 接口正确；UI + 文案 + 默认值需重写）

---

## 1. 范围与不动项

**重写**: UI 层（双态切换 → 单页表单）、文案（11 现有 key 改 / 删 + 14 新增 key）、视觉 token（`hana_colors.dart` → `HanaTokens`）、默认值（estrogen/oral → null）

**不动**:
- `DrugListCubit.addDrug(Drug)` 接口（line 63, 94）
- `IdGenerator.generate()` 用法
- `Drug` entity / `HrtDrugTemplates.byCategory` / `DrugTemplate` 数据结构（drug_templates.dart 的 emoji 字段保留——v2 widget 渲染时忽略，不动 domain 防止 storage 兼容性破坏）
- 路由 `context.pop()` 出口（保持）
- `AdministrationRoute.supportedUnits` 路径→单位约束逻辑（保留 v1 line 67-74）

---

## 2. State 管理

继续用本地 `StatefulWidget` state——本屏为单次表单提交场景，无需引入新 cubit。

### 2.1 字段重设计

```dart
class _AddDrugPageState extends State<AddDrugPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();   // ⚠ v1: _genericNameController
  final _dosageController = TextEditingController();  // ⚠ v1: 无此字段
  final _notesController = TextEditingController();

  // -- 选择字段：critique-v1 #1 修复 --
  DrugCategory? _category;          // ⚠ v1: DrugCategory.estrogen
  AdministrationRoute? _route;      // ⚠ v1: AdministrationRoute.oral
  DosageUnit? _unit;                // 仍 nullable，由 _route 联动

  // -- 日期字段（v1 缺失）--
  DateTime? _startDate;
  DateTime? _endDate;

  // -- inline error 文案 keys（不用 Form.validator 红色）--
  String? _nameError;
  String? _categoryError;
  String? _routeError;
}
```

**关键改动**:
- `_category` / `_route` 类型从 enum 改为 `enum?`，初值 `null` — critique-v1 #1 修复
- `_genericNameController` rename 为 `_aliasController`（label "别名"）
- 新增 `_dosageController` / `_startDate` / `_endDate` 三字段
- 新增 3 个 inline `*Error` 字段，由 `_validate()` 在 onBlur / submit 时填充——**替代 `Form.validator` 默认红色**

### 2.2 模板预填

```dart
void _selectTemplate(DrugTemplate template) {
  setState(() {
    _nameController.text = template.name;
    _aliasController.text = template.genericName;
    _category = template.category;
    _route = template.route;
    _unit = template.unit;
    _dosageController.text = template.commonDosage.toString();
    // _startDate / _endDate / _notes 不预填
    _nameError = _categoryError = _routeError = null;
  });
  Navigator.pop(context);
}
```

与 v1 line 51-65 差异：v1 直接 `addDrug + pop`，v2 仅预填字段供用户继续微调，**不提交、不出屏**——这是把"翻药册"从 wizard 终点改为表单快捷方式。

### 2.3 验证

```dart
bool _validate() {
  setState(() {
    _nameError = _nameController.text.trim().isEmpty
        ? l10n.addDrugErrorMissingName
        : null;
    _categoryError = _category == null
        ? l10n.addDrugErrorMissingCategory
        : null;
    _routeError = _route == null
        ? l10n.addDrugErrorMissingRoute
        : null;
  });
  return _nameError == null && _categoryError == null && _routeError == null;
}
```

调用时机：① 每个字段 `FocusNode` onBlur；② tap 保存按钮。**inline 文字用 `body-sm inkSubdued`**（不上红色——朱砂仅 destructive 用）。

### 2.4 提交

```dart
void _submit() {
  if (!_validate()) return;

  final drug = Drug(
    id: IdGenerator.generate(),
    name: _nameController.text.trim(),
    genericName: _aliasController.text.trim(),
    category: _category!,
    administrationRoute: _route!,
    defaultDosageUnit: _unit ?? _route!.supportedUnits.first,
    isActive: true,
    createdAt: DateTime.now(),
    notes: _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim(),
    // 起止日 + 默认剂量需扩展 Drug entity（见 §4 schema 改动）
  );

  context.read<DrugListCubit>().addDrug(drug);
  Navigator.pop(context);
}
```

---

## 3. 文件改动清单

### 3.1 改动

| 文件 | 改动 | 行数估算 |
|------|------|---------|
| `lib/features/medication/presentation/pages/add_drug_page.dart` | 删 `_showManualForm` 双态；改成单页表单 + AppBar `翻药册。` action 触发 sheet；改默认值；改 `_submit`；删 `LinearGradient` / 类别色硬编码 / `Icons.local_florist`-style 装饰 | 428 → ~520 |
| `lib/core/l10n/arb/app_zh.arb` / `app_en.arb` / `app_ja.arb` | 改 `drugTemplateTitle` / `drugTemplateSubtitle`，删 `drugCustomAdd`，新增 14 个 key（见 spec.md §10） | +~42 lines/locale |
| `lib/features/medication/domain/entities/enums.dart` | 已有 `localizedName(l10n)` 扩展（DEC-042/043）— **确认 `DrugCategory` / `AdministrationRoute` / `DosageUnit` 三 enum 都覆盖**；如缺则补 | ±0 ~ +30 |

### 3.2 删除

- v1 line 33-34 默认 `_category = DrugCategory.estrogen` / `_route = AdministrationRoute.oral`
- v1 line 26 `_showManualForm` 字段 + line 119-122 切换逻辑
- v1 line 199-280 模板卡内 `Container + r-16 + emoji 染色容器 + Icons.add_circle_outline`
- v1 line 282-319 "手动添加" 按钮整块
- v1 line 321-328 `_categoryColor` switch（4 个类别色硬编码 — 含非 token 色 `#4A90D9` / `#2CBAA0`）
- v1 line 343 / 356 / 412 `OutlineInputBorder()`
- v1 line 363-405 `SegmentedButton` + `Wrap+ChoiceChip` 三组（→ HanaInput-style picker 触发器）
- v1 line 417-423 `FilledButton` r-16 全宽（→ `HanaButton.primary` 非全宽）
- ARB key `drugCustomAdd` 三语全删

### 3.3 新增（依赖 v2 widget — Phase 5 实施）

本屏需要的 v2 组件全部在 design-system/v2/components 已有规格：
- `HanaButton` (button.md) — primary / ghost / text
- `HanaInput` (input.md) — singleLine / multiline / numeric
- `HanaBottomSheet` (bottom-sheet.md) — picker variant

**前置依赖**: 这 3 个组件需 Phase 5 落地（`lib/core/widgets/hana_*.dart`）后再开始 add_drug UI 重写。如组件还没建，建议拆 PR 先建组件再做本屏。可与 onboarding-v2 复用同一批 widget——两屏对组件需求高度重叠（spec.md §6 表）。

### 3.4 schema 扩展（可选 / 推迟）

- 增 `Drug.defaultDosage: double?` 存储模板默认剂量
- 增 `Drug.startDate: DateTime?` / `Drug.endDate: DateTime?`

二者若涉及 sqlcipher 迁移建议**拆独立 PR**——本屏 UI 重写 PR 不动 schema，先把字段写入 `Drug.notes` 占位（"起止日：2026-04-29 至 ——"格式），等 schema PR 落地后再拉出。`Drug.notes` 是现有字段（v1 line 89-91 已用），不破坏兼容性。

---

## 4. PR 拆分建议（≥ 3 个 PR）

### PR 1: ARB + enum 准备

**Branch**: `feat/add-drug-v2-arb-prep`

- 新增 14 个 ARB key（zh/en/ja 三语对齐，按 spec.md §10）
- 改写 `drugTemplateTitle` / `drugTemplateSubtitle`
- 删除 `drugCustomAdd` 三语
- 检查 `DrugCategory` / `AdministrationRoute` / `DosageUnit` 三 enum 都有 `localizedName(l10n)` 扩展（DEC-042/043）；如缺补齐
- 跑 `flutter pub run build_runner build --delete-conflicting-outputs` 重生成 `app_localizations*.dart`
- 测试：`flutter analyze --fatal-infos` 通过；现有 323 个 test 全 pass（本 PR 不动 widget code）

**Diff size**: ~150 行

### PR 2: HanaWidget 落地（如未完成）

**Branch**: `feat/v2-widgets-medication-deps`

仅当 Phase 5 widget 还没建时需要。如已落地（onboarding-v2 PR 已建），跳过此 PR。

### PR 3: Add Drug UI 重写

**Branch**: `feat/add-drug-v2-ui`

- 重写 add_drug_page.dart 为单页表单
- 删除 `_showManualForm` 双态
- 模板 sheet 用 `HanaBottomSheet.show(context, sheet: HanaBottomSheet(title: l10n.drugTemplateTitle, child: _TemplateList(onSelect: _selectTemplate)))`
- 默认值 estrogen/oral → null
- 验证用 inline `*Error` 字段 + body-sm inkSubdued
- 测试：现有 `add_drug_page_test.dart`（如有）需更新断言：① picker placeholder "选择…" 而非 "雌激素"；② 保存按钮在类别 / 路径未选时 disabled；③ 模板选中后字段预填，sheet 关闭，**不**直接出屏

**Diff size**: ~+520 行 / -428 行 = 净 +92 行

### PR 4 (可选): widget test

**Branch**: `test/add-drug-v2-flow`

新增 widget test 覆盖：
- 默认值 null（picker placeholder 显示 `addDrugCategoryHelper` "可在记完后修改。"）
- 模板预填（点击 "补佳乐" 后 7 字段全部填入 + sheet dismiss + 仍在表单页）
- inline validation（药名 / 类别 / 路径任一未填，保存触发 inline error，**无红色，无 SnackBar**）
- 路径变更时单位联动（route oral→intramuscularInjection 后单位从 mg/mcg 切换为 mg/ml）

### PR 5 (推迟): schema 扩展

**Branch**: `feat/drug-entity-extend-dosage-dates`

仅当产品确认要持久化 `defaultDosage` / `startDate` / `endDate` 时启动；涉及 freezed 重生成 + sqlcipher 迁移 + DataSource adapter 改动，建议独立 PR 并配合 R52-C 云同步 schema 一并设计。

---

## 5. 测试清单

| 测试 | 文件 | 期望 |
|------|------|-----|
| 默认值 null | `add_drug_page_test.dart` | category picker 触发器显示 placeholder "选择…"，**不**显示 "雌激素" |
| 模板预填 7 字段 | 同上 | tap "补佳乐" → name="补佳乐" / category=estrogen / route=oral / unit=mg / dosage="2.0" / 仍在表单页 |
| inline validation 无红色 | 同上 | tap 保存（缺药名）→ HanaInput.errorText body-sm inkSubdued 出现，颜色 = `inkSecondary` 而非 `error` |
| 路径变更单位联动 | 同上 | route oral→intramuscularInjection → unit auto fallback to `mg`（保留 v1 line 67-74 逻辑） |
| 取消不弹确认 | 同上 | tap 取消 → 直接 `Navigator.pop`，无 dialog |
| 模板 sheet 零 emoji | golden test | `find.byType(Text).where(t => emoji regex)` 应返回 0 | 

---

## 6. 与 onboarding 屏 4 的复用机会

onboarding 屏 4 已建立的 pattern（spec.md §2 屏 4）与本屏高度重叠：
- 单卡多字段（药名 + 类别 + 路径 + 单位）
- 类别 / 路径 picker 用 `HanaBottomSheet.picker(items: enum.values.map(localizedName))`
- 默认 null 立场
- HanaInput-style 触发器

**建议**: 把"类别 picker 触发器" / "路径 picker 触发器"抽成 `lib/features/medication/presentation/widgets/_drug_field_pickers.dart`，onboarding 屏 4 + add_drug + (未来) edit_drug 三处共用。这是 audit-2026-Q2 widget-pattern-inventory 的下一步收敛目标。

---

## 7. 兼容性 / 回滚

- **DI**: 不动 — 本屏不新增 inject 依赖
- **Storage**: `Drug` entity 不动；schema 扩展推到 PR 5
- **i18n**: 删除 `drugCustomAdd` 后凡引用此 key 的位置都需迁移——`grep` 结果应为 0（v1 仅 add_drug_page.dart:307 使用）
- **回滚路径**: PR 3 单点 revert 即可回到 v1 双态切换；ARB key 在 PR 1 中以**新增 + 改写**方式落地，revert PR 3 后 PR 1 的 key 仍可向后兼容（旧值仍能被读取）

---

## 8. 风险

| 风险 | 缓解 |
|------|-----|
| 模板 emoji 在 v2 widget 渲染时忽略，但 domain 字段仍存在——如未来通知 / Today 卡又用了 emoji 会破坏一致性 | 在 widget 层加 lint：`grep "template.emoji"` 应只在 domain 测试文件出现 |
| 剂量字段在 add_drug 与 schedule editor 双处可填，语义不清 | spec.md §12 决策注明：add_drug 的剂量是"模板默认"，schedule editor 是"单次安排"；UI 文案区别 helperText 强调 |
| `DrugCategory` / `AdministrationRoute` / `DosageUnit` 三 enum 的 `localizedName(l10n)` 扩展如未全覆盖会触发 DEC-042/043 违规 | PR 1 确认前置，缺则补；CI grep `\.displayName` 应在 lib/features/medication 下返回 0（v1 残留） |
| 模板列表 22 条单屏滚动可能超 sheet 85% 高度 | bottom sheet 内 ListView，滚动；类别段落标记 sticky header（可选） |

---

— 完 —
