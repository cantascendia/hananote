# Onboarding 屏 v2 — Flutter Handoff Spec

> Generated 2026-04-29
> Pairs with `docs/design/screens/onboarding/spec.md`（5 屏视觉与流程规范）
> 目标文件：`lib/features/auth/presentation/pages/onboarding_page.dart`（641 行 inline → 拆模块）
> 现有完成度：85%（功能跑通；BLoC 事件层正确；UI + 流程 + 文案需重写）

---

## 1. 范围与不动项

**重写**: UI 层（5 屏 PageView + 三步分支）、文案（80 keys 中 onboarding.* 段 + 8 个新 ARB key）、视觉 token（hana_colors → HanaTokens）、默认值（estrogen/oral → null）

**不动**:
- `SettingsBloc` 事件序列（`UpdateDisplayName` / `UpdateHrtStartDate` / `MarkOnboardingComplete`）— v1 line 49-81 `_completeOnboarding` 逻辑保持
- `MedicationRepository.addDrug` 接口
- `getIt<MedicationRepository>()` DI 调用
- 路由 `context.go('/today')` 入口
- `AuthCubit` — 与 onboarding **无关**（用户提示中"现有 OnboardingCubit 兼容"是误传：onboarding 没有独立 cubit，状态在 `_OnboardingPageState` 内本地管理 + 终结时一次性发 SettingsBloc 事件。AuthCubit 只管 PIN/setup/unlock/wipe）

---

## 2. State 管理（5 屏 PageView）

继续用 **本地 StatefulWidget state** + **完成时一次性派发 SettingsBloc events**——这是 v1 已经验证可行的模式，没有理由引入新 cubit。

### 2.1 字段重设计

```dart
class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  // -- 屏 2: 称呼 --
  final _nameController = TextEditingController();

  // -- 屏 3: HRT 状态（必选才能离屏）--
  OnboardingHrtStatus? _hrtStatus;

  // -- 屏 4: 药物（仅 onHrt 路径写入）--
  final _drugNameController = TextEditingController();
  DrugCategory? _selectedCategory;          // ⚠ v1: DrugCategory.estrogen
  AdministrationRoute? _selectedRoute;      // ⚠ v1: AdministrationRoute.oral
  DateTime? _hrtStartDate;
}
```

**关键改动**:
- `_selectedCategory` / `_selectedRoute` 类型从 enum 改为 `enum?`，初值 `null` — critique-v1 跨敏 #3 修复
- 新增 `_hrtStatus`（nullable）— 屏 3 必选，未选时屏 3「翻页」按钮 disabled
- 新增 `_OnboardingHrtStatus` enum（建议放 `lib/features/auth/domain/entities/onboarding_hrt_status.dart`，**纯 dart 文件**，不依赖 Flutter，符合 domain 零外部依赖原则 DEC-042/043）

### 2.2 屏间导航

```dart
void _next() {
  switch (_currentPage) {
    case 0: _goToPage(1); return;                         // 屏 1 → 屏 2
    case 1: _goToPage(2); return;                         // 屏 2 → 屏 3（无校验，name 可空）
    case 2:
      // 屏 3 → 屏 4 仅 onHrt；其他直接屏 5
      if (_hrtStatus == OnboardingHrtStatus.onHrt) {
        _goToPage(3);
      } else {
        _goToPage(4);
      }
      return;
    case 3: _goToPage(4); return;                         // 屏 4 → 屏 5
    case 4: _completeOnboarding(); return;                // 屏 5 提交
  }
}
```

**条件跳过的 PageView 索引保持 0-4**（5 个 child），避免动态 child 列表导致 PageController offset 错位。屏 4 在 non-onHrt 路径仍保留为 child，只是从未被显示。

### 2.3 _completeOnboarding 兼容性

```dart
Future<void> _completeOnboarding() async {
  final bloc = context.read<SettingsBloc>();
  final name = _nameController.text.trim();
  if (name.isNotEmpty) {
    bloc.add(UpdateDisplayName(name: name));
  }

  // ⚠ 仅 onHrt 路径写入起始日；notStarted/prefersNotToSay 不发事件
  if (_hrtStatus == OnboardingHrtStatus.onHrt && _hrtStartDate != null) {
    bloc.add(UpdateHrtStartDate(date: _hrtStartDate!));
  }

  // ⚠ category/route 现在是 nullable，需要全部非空才创建 drug
  final drugName = _drugNameController.text.trim();
  if (_hrtStatus == OnboardingHrtStatus.onHrt &&
      drugName.isNotEmpty &&
      _selectedCategory != null &&
      _selectedRoute != null) {
    final route = _selectedRoute!;
    final drug = Drug(
      id: const Uuid().v4(),
      name: drugName,
      genericName: '',
      category: _selectedCategory!,
      administrationRoute: route,
      defaultDosageUnit: route.supportedUnits.first,
      isActive: true,
      createdAt: DateTime.now(),
    );
    await getIt<MedicationRepository>().addDrug(drug);
  }

  bloc.add(const MarkOnboardingComplete());
  if (mounted) context.go('/today');
}
```

与 v1 差异：
- `_hrtStartDate` 派发增加 `_hrtStatus == onHrt` 防御
- Drug 创建增加 `_selectedCategory != null && _selectedRoute != null` 防御
- 即使屏 4 整屏跳过（notStarted/prefersNotToSay），`MarkOnboardingComplete` 仍发，确保 `hasCompletedOnboarding=true`

---

## 3. 文件改动清单

### 3.1 改动

| 文件 | 改动 | 行数估算 |
|------|------|---------|
| `lib/features/auth/presentation/pages/onboarding_page.dart` | 删除 v1 inline `_WelcomeStep` / `_HrtDateStep` / `_DrugStep`，改成 5 个 inline `_HeroStep` / `_NameStep` / `_HrtStatusStep` / `_DrugStep` / `_OpenStep`；改默认值；改 `_completeOnboarding`；删除 `LinearGradient` / `Icons.local_florist` / `Plus Jakarta Sans` 硬编码 | 641 → ~750 |
| `lib/core/l10n/arb/app_zh.arb` / `app_en.arb` / `app_ja.arb` | 改 7 个 onboarding key（按 copy-revisions §1）；新增 ~12 个 key（见 spec.md §10） | +~36 lines/locale |
| `lib/features/auth/domain/entities/onboarding_hrt_status.dart` | **新建**——纯 dart enum + `localizedName(AppLocalizations l10n)` 扩展 | +30 |

### 3.2 删除

- v1 line 88-98 `LinearGradient`
- v1 line 263-276 / 371-383 / 494-506 圆形 hero icon 容器（3 处）
- v1 line 138-156 dot indicators（→ 改 mono "01 / 05" 页码）
- v1 line 282 / 389 / 512 `fontFamily: 'Plus Jakarta Sans'` 硬编码
- v1 line 401 `firstDate: DateTime(2000)` → 改 1990 + lastDate 加 90 天
- v1 line 553-577 / 588-612 `DropdownButtonFormField` → 改 `HanaBottomSheet.picker`

### 3.3 新增（依赖 v2 widget — Phase 5 实施）

本屏需要的 v2 组件全部在 design-system/v2/components 已有规格：
- `HanaButton` (button.md) — primary / ghost
- `HanaCard` (card.md) — flat / tappable
- `HanaInput` (input.md) — singleLine / numeric
- `HanaBottomSheet` (bottom-sheet.md) — picker variant

**前置依赖**: 这 4 个组件需 Phase 5 落地（`lib/core/widgets/hana_*.dart`）后再开始 onboarding UI 重写。如组件还没建，建议拆 PR 先建组件再做 onboarding。

---

## 4. PR 拆分建议（≥ 3 个 PR）

### PR 1: ARB + enum 准备

**Branch**: `feat/onboarding-v2-arb-prep`

- 新增 12 个 ARB key（zh/en/ja 三语对齐）
- 改写 7 个现有 onboarding key 按 copy-revisions §1
- 新建 `onboarding_hrt_status.dart` enum + `localizedName(l10n)` 扩展
- 跑 `flutter pub run build_runner build --delete-conflicting-outputs`
- 提交 `app_localizations*.dart` 重生成结果
- 测试：`flutter analyze --fatal-infos` 通过；现有 323 个 test 全 pass（**无应当 fail 的**——本 PR 不动 widget code）

**Diff size**: ~150 行

### PR 2: HanaWidget 落地（如未完成）

**Branch**: `feat/v2-widgets-onboarding-deps`

仅当 Phase 5 widget 还没建时需要——按 design-system/v2/components/{button,card,input,bottom-sheet}.md 规格落地 4 个 widget。

如已落地，跳过此 PR。

### PR 3: Onboarding UI 重写

**Branch**: `feat/onboarding-v2-ui`

- 重写 onboarding_page.dart（5 屏 PageView）
- 删除 v1 inline 实现
- 接入 PR 1 的 ARB + enum
- 接入 PR 2 / 已有的 HanaWidget
- 默认值 estrogen/oral → null
- 5 屏 motion 落实（240ms 切屏 + 屏 5 静默 400ms + 1200ms 淡入）
- 测试：现有 auth_wrapper_page_test.dart 不受影响（它只断言路由到 `/onboarding` route，不触达 OnboardingPage 内部）

**Diff size**: ~+750 行（onboarding_page.dart）/ -641 行（旧版） = 净 +109 行

### PR 4 (可选): 屏 3 + 屏 5 widget test

**Branch**: `test/onboarding-v2-flow`

新增 widget test 覆盖：
- 屏 3 三选项分支（onHrt → 屏 4 / notStarted → 屏 5 / prefersNotToSay → 屏 5）
- 屏 4 默认值 null（assertion: drug category dropdown 显示 placeholder "选择…" 而非 "雌激素"）
- 屏 5 法律免责文本可见 + button 触发 `_completeOnboarding`

---

## 5. 现有 widget test 影响

### 5.1 不受影响（确认 grep 过）

- `test/features/auth/presentation/pages/auth_wrapper_page_test.dart`：只用 `Scaffold(body: Text('onboarding'))` stub `/onboarding` route（line 79-82），断言 `find.text('onboarding')`——不触达 OnboardingPage widget，重写不会破坏
- 所有 `test/features/medication/**` 中的 `DrugCategory.estrogen / AdministrationRoute.oral` 引用都是 medication / timeline / simulator 自己的 fixture，**与 onboarding 默认值无关**

### 5.2 不存在的测试

- 没有 `onboarding_page_test.dart`、没有 onboarding widget test、没有 onboarding cubit（critique-v1 已确认 onboarding 全部 inline 在单文件）

### 5.3 可能受影响（需手动验证）

- 任何 i18n smoke test 如断言具体 onboarding 文案字符串（如 "欢迎来到 HanaNote"）——PR 1 改 ARB 后会断言失败。Grep 暂未发现具体 case，但 PR 1 跑全 test 时若有红用例需同步更新断言。

---

## 6. Domain 零外部依赖检查

新增 `OnboardingHrtStatus` enum + `localizedName(l10n)` 扩展按 DEC-042/043:

```dart
// lib/features/auth/domain/entities/onboarding_hrt_status.dart
// ✅ NO Flutter imports, NO third-party
enum OnboardingHrtStatus { onHrt, notStarted, prefersNotToSay }
```

```dart
// lib/features/auth/presentation/extensions/onboarding_hrt_status_l10n.dart
// ✅ Presentation 层挂 localizedName extension
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/features/auth/domain/entities/onboarding_hrt_status.dart';

extension OnboardingHrtStatusL10n on OnboardingHrtStatus {
  String localizedName(AppLocalizations l10n) => switch (this) {
    OnboardingHrtStatus.onHrt => l10n.onboardingHrtStatusOnHrt,
    OnboardingHrtStatus.notStarted => l10n.onboardingHrtStatusNotStarted,
    OnboardingHrtStatus.prefersNotToSay => l10n.onboardingHrtStatusPrefersNotToSay,
  };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
    OnboardingHrtStatus.onHrt => l10n.onboardingHrtStatusOnHrtDescription,
    OnboardingHrtStatus.notStarted => l10n.onboardingHrtStatusNotStartedDescription,
    OnboardingHrtStatus.prefersNotToSay => l10n.onboardingHrtStatusPrefersNotToSayDescription,
  };
}
```

同时**修复 v1 line 571 / 606 的 DEC-042/043 违规**：`cat.displayName` 直出 → 改 `cat.localizedName(l10n)`（`DrugCategory` / `AdministrationRoute` extension 在屏 4 用）。如这两个 enum 还没有 `localizedName` extension，需补建；critique-v1 已经把这一项列为已知技术债。

---

## 7. CI 与测试 check 路径

```bash
# PR 1 (ARB + enum)
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
dart analyze --fatal-infos
flutter test
# 应该 323/323 通过（不动 widget）

# PR 3 (UI 重写)
flutter pub run build_runner build --delete-conflicting-outputs
dart analyze --fatal-infos                # 重点：HanaTokens API 用法 + DEC-042/043 lint
flutter test                              # 应该 323/323（可能需新增 onboarding 的 4-5 个 case）
flutter build apk --debug                 # CI 验证
flutter build web                         # web 端验证（Onboarding 不依赖 native，应 OK）
```

**专项检查**:
- `flutter test test/features/auth/`：auth_wrapper_page_test 应仍 pass
- `grep -rn "Plus Jakarta Sans" lib/features/auth/`：应为空
- `grep -rn "Icons.local_florist" lib/`：应为空
- `grep -rn "showDatePicker" lib/features/auth/`：应为空（改 HanaBottomSheet.picker）
- `grep -rn "DrugCategory.estrogen\|AdministrationRoute.oral" lib/features/auth/presentation/pages/onboarding_page.dart`：应为空（默认值改 null）

---

## 8. 风险与回退

**风险**:
1. **HanaWidget 还没落地**：onboarding UI 重写依赖 4 个 v2 组件，如组件 PR 没合并先做 onboarding 会重复造轮子。**Mitigation**: 先合 PR 2 再开 PR 3，或在 PR 3 中先内联 widget 再后续抽离。
2. **新增 ARB key 破坏 build_runner**：12 个新 key 缺一会让 `app_localizations*.dart` 生成失败。**Mitigation**: PR 1 跑 `flutter pub run build_runner build --delete-conflicting-outputs` 验证；三语 key 必须等量补齐（没有 "暂时只补中文" 选项）。
3. **屏 5 仪式时长 2.6s 过长**：用户测试可能反馈 "卡住了"。**Mitigation**: 仪式期间 button 已可点（IgnorePointer 不拦截底层），用户可立即按 "进入今日。" 跳过等待——这是 candidate-A "等待是仪式" 的核心立场，不让步。
4. **firstDate 改 1990**：极少数 < 1990 开始 HRT 的用户被排除。**Mitigation**: 接受——下限放到 1980+ 会让 picker 滚动列表过长损害可用性；如出现真实用户反馈再改。

**回退**:
- PR 1 (ARB) 出问题 → revert single commit，build_runner regenerate
- PR 3 (UI) 出问题 → revert 单 commit；旧 onboarding_page.dart 仍可工作（因为 PR 1 的 ARB 改值兼容旧 key 引用）
- 不存在跨 PR 的耦合破坏（ARB key 改值不破旧 widget；新 key 旧 widget 不引用即可）

---

## 9. 估时

| PR | 估时 |
|----|------|
| PR 1 (ARB + enum) | 0.5 天 |
| PR 2 (Hana widget) | 1-2 天（如未做） |
| PR 3 (UI 重写) | 1.5 天 |
| PR 4 (test 增量) | 0.5 天 |
| **合计** | 2.5-4.5 天 |

PR 2 可与其他 v2 组件落地共享（不算 onboarding 专属成本）。

---

## 10. Definition of Done

PR 3 合并条件:
- [ ] `flutter test` 323/323 + 新增 onboarding case 全 pass
- [ ] `dart analyze --fatal-infos` 0 warning
- [ ] `flutter build apk --debug` 成功
- [ ] `flutter build web` 成功
- [ ] grep 5 项 forbidden pattern (§7) 全为空
- [ ] critique-v2 自审表（spec.md §12）由 design 角色签字
- [ ] 跨性别敏感性 6 盲点（spec.md §4）每条对应代码 / 文案 commit hash 列出

---

— 完 —
