# Record 屏 v2 工程实施 Handoff

> Generated 2026-04-29 配对 `docs/design/screens/record/spec.md`
> 实施分支建议：`feat/v2-record-screen`
> 上游基准：`docs/design/design-system/v2/{tokens.md,principles.md,components/*.md}` + `docs/design/screens/today/spec.md`

---

## 1. 现有 BLoC/Cubit 兼容性

read `lib/features/journal/presentation/bloc/record_bloc.dart` + `record_state.dart` + `record_event.dart` 后确认：

- **Bloc**：`RecordBloc` (`@lazySingleton`)，依赖注入已在 `injection.config.dart`，构造接收 `GetJournalStreak / JournalRepository / MeasurementRepository / PhotoRepository`。无需改 DI。
- **Events**：`LoadRecordSummary`（首屏）+ `RefreshRecordSummary`（下拉，目前未在 UI 触发）—— v2 视觉稿**不**改 events，仅在新 UI 中接 `HanaPullRefresh.onRefresh` → `add(RecordEvent.refresh())`。
- **States**：`RecordState.initial / loading / loaded / error`，`loaded` 已含 v2 spec 需要的全部字段（`journalStreak / lastJournalDate / lastPhotoDate / lastMeasurementDate / lastMeasurementSummary`）—— **零 state 改动**。
- **24h 活跃判定**：UI 层可在 BlocBuilder 内对 3 个 `lastXxxDate` 做 `now.difference(date).inHours <= 24` 判断，**不**进 state（避免污染 domain 层）。"哪栏 lastDate 最新"取最大值即可，纯 UI 计算。
- **measurementSummary**：`RecordBloc._buildMeasurementSummary` 已生成「B 87 · W 62 · H 90」格式；v2 spec 把分隔符从「·」换为「　·　」+ 句号，可在 UI 层 `'$summary　·　$dateStr。'` 拼接，**不**改 bloc。
- **结论**：BLoC 完全兼容，本次 PR **零 bloc/state/event/domain 改动**，仅替换 page widget 与文案。

---

## 2. 文件改动清单

### 删除
- `lib/features/journal/presentation/pages/record_page.dart` 内私有 `_StitchRecordCard` (226-436) 及其 `AnimatedController` / `ImageFiltered` / `BoxShadow` 等装饰逻辑

### 新增（依赖 v2 共享件，需 Phase 5 已落）
- `lib/core/widgets/hana_top_bar.dart`（如未落，先 inline 一个简化版：实色 surfaceContainerHigh + 滚动 outline）
- `lib/core/widgets/hana_card.dart`（HanaCard.tappable）
- `lib/core/widgets/hana_section_header.dart`（v1.1 待落 spec — 本 PR 落最小可用版：4px 黛蓝 Container + label · +0.6 · inkSecondary）
- `lib/core/widgets/hana_empty_state.dart`（HanaEmptyState.inline）
- `lib/core/widgets/hana_loading_view.dart`（block：「读取中。」）
- `lib/core/widgets/hana_error_state.dart`
- `lib/core/widgets/hana_pull_refresh.dart`（v1.1 待落 spec — 本 PR 可暂用 `RefreshIndicator(color: HanaTokens.primary)` 过渡）

> 若以上共享件由前置 PR（Today 屏 v2）已落地，本 PR 直接 import；若未落地，本 PR **不**重复实现，先用 Today PR 落的最小集，缺的（HanaSectionHeader / HanaPullRefresh）在本 PR 内补最小可用版 + 标注 TODO。

### 修改
- `lib/features/journal/presentation/pages/record_page.dart`：整体重写（≈ 437 行 → ~150 行），结构按 spec.md §2 wireframe
- `lib/core/l10n/arb/app_zh.arb` + `app_en.arb` + `app_ja.arb`：按 spec.md §8 改 12 个 key 的值 + 新增 3 个 key（`recordSectionEntries / recordLoading / recordErrorTitle`）+ deprecate `recordFooter`
- `lib/core/l10n/arb/app_localizations*.dart`：自动重生成（`flutter gen-l10n`）
- `test/features/journal/presentation/pages/record_page_test.dart`（如存在）：按新 widget tree 调整 finder

---

## 3. 组件依赖

| 组件 | 来源 | 本 PR 角色 |
|------|------|-----------|
| `HanaTopBar` | components/top-bar.md | 用 |
| `HanaCard.tappable` | components/card.md | 用 |
| `HanaSectionHeader` | v1.1 待落 spec | **落最小可用版** |
| `HanaEmptyState.inline` | components/empty-state.md | 用 |
| `HanaLoadingView.block` | components/loading-view.md | 用 |
| `HanaErrorState` | components/error-state.md | 用 |
| `HanaPullRefresh` | v1.1 待落 spec | 暂用 system + 锁色 |
| `HanaTokens` | tokens.md §8 | 用单轨 API |

---

## 4. 实施代码骨架（~30 行 Dart 主体）

```dart
// lib/features/journal/presentation/pages/record_page.dart
class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tag = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      backgroundColor: HanaTokens.background(context),
      appBar: HanaTopBar(title: l10n.recordTitle), // 实色 + 滚动 outline
      body: BlocBuilder<RecordBloc, RecordState>(
        builder: (context, state) => switch (state) {
          RecordInitial() || RecordLoading() => const HanaLoadingView.block(),
          RecordError(:final message) => HanaErrorState(
              title: l10n.recordErrorTitle,
              message: message,
              onRetry: () => context.read<RecordBloc>().add(const RecordEvent.refresh()),
            ),
          RecordLoaded(:final journalStreak,
                       :final lastPhotoDate, :final lastMeasurementDate,
                       :final lastJournalDate, :final lastMeasurementSummary) =>
            HanaPullRefresh(
              onRefresh: () async => context.read<RecordBloc>().add(const RecordEvent.refresh()),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: HanaTokens.spacing.lg),
                children: [
                  SizedBox(height: HanaTokens.spacing.xl),
                  Text(l10n.recordGreeting, style: context.hanaText.displayXL),
                  SizedBox(height: HanaTokens.spacing.xs),
                  Text(DateFormat.MMMEd(tag).format(DateTime.now()),
                       style: context.hanaText.bodySm.copyWith(
                         color: HanaTokens.inkSecondary(context))),
                  SizedBox(height: HanaTokens.spacing.lg),
                  HanaSectionHeader(title: l10n.recordSectionEntries),
                  SizedBox(height: HanaTokens.spacing.md),
                  _RecordEntry(index: 1, title: l10n.recordPhoto,
                               body: l10n.recordPhotoSub,
                               status: lastPhotoDate != null
                                   ? l10n.recordLastPhoto(DateFormat.MMMd(tag).format(lastPhotoDate))
                                   : l10n.recordPhotoEmpty,
                               isFreshest: _isFreshest(lastPhotoDate, [lastMeasurementDate, lastJournalDate]),
                               onTap: () => context.push('/photo')),
                  SizedBox(height: HanaTokens.spacing.lg),
                  // ... 02 体测 / 03 日记 同结构
                  SizedBox(height: HanaTokens.spacing.xl),
                ],
              ),
            ),
        },
      ),
    );
  }
}
```

`_RecordEntry` 内部一个 `HanaCard.tappable` 包 `Column`：编号 mono → SizedBox sm → 标题 title → SizedBox sm → 副述 body → SizedBox md → 状态行 body-sm（默认 inkSecondary，`isFreshest && in24h` 时 primary）。`_isFreshest` 在 UI 计算"哪栏 lastDate 最新且 24h 内"——保证黛蓝陈述每屏 ≤ 1 处（spec §10 自审遗留风险解法）。

---

## 5. 测试策略

### Widget 测试（`test/features/journal/presentation/pages/record_page_test.dart`）
1. `RecordInitial` / `RecordLoading` → 渲染 `HanaLoadingView`，**不**渲染 `CircularProgressIndicator`
2. `RecordError` → 渲染 `HanaErrorState`，点击重试 → bloc 收到 `RefreshRecordSummary`
3. `RecordLoaded` 全空 → 三栏 inline empty「尚无影像。/ 尚无测量。/ 尚无日记。」
4. `RecordLoaded` streak=12 + lastPhoto=昨天 → 日记栏「连续　12 天。」+ 影像栏「上次　{date}。」
5. `RecordLoaded` 三栏全有，影像最新且 24h 内 → 影像栏状态行用 `HanaTokens.primary`，其余两栏用 `inkSecondary`（黄金路径：黛蓝 ≤ 1 处状态行 + 1 处章节竖线 = ≤ 2 处）
6. 点击影像卡 → `GoRouter.push('/photo')` 触发；体测 → `/measurement`；日记 → `/journal/edit`
7. 下拉触发 `HanaPullRefresh.onRefresh` → bloc 收到 `RefreshRecordSummary`

### Golden 测试（可选）
- `record_page_golden_test.dart` 三组：light loaded / dark loaded / light empty。涉及字体需在 `flutter_test` 中加载真实字体，否则 fallback 渲染会与 spec 不一致——参考 Today PR 的 golden 配置。

### 集成断言（lint）
- `dart analyze --fatal-infos` 通过
- 加 grep 自动断言：`record_page.dart` 不含 `BackdropFilter` / `BoxShadow` / `Plus Jakarta Sans` / `HanaColors.` / `BorderRadius.circular(16)` / `BorderRadius.circular(9999)` 任一字符串（防回归）

---

## 6. PR 拆分建议（≤ 3 个 PR）

### PR-1：ARB 文案 v2 改写（小且独立）
- 改 12 个 key 值 + 新增 3 key（`recordSectionEntries / recordLoading / recordErrorTitle`）+ deprecate `recordFooter`（保留 key 但标注 `@@deprecated`）
- 三 locale (zh / en / ja) 同步
- `flutter gen-l10n` 重生成
- **零 UI 改动** —— 旧 `record_page.dart` 仍读旧 key 名，但显示新文案（短期视觉错位可接受 1~2 天）
- 风险低，先 merge 解锁后续 PR

### PR-2：v2 共享件最小集（如 Today PR 未落齐则补）
- `HanaSectionHeader`（最小可用版：4px 黛蓝 Container + label tracking +0.6 + inkSecondary 文字）
- `HanaPullRefresh`（暂时仅 wrap `RefreshIndicator(color: HanaTokens.primary)`，TODO 后续 v1.1 spec 落地时替换）
- 加 unit test 覆盖
- 不动 page

### PR-3：record_page.dart 重写
- 整文件重写（437 → ~150 行），删除 `_StitchRecordCard` 私有件
- 接 PR-1 的 ARB + PR-2 的共享件
- 加 widget 测试 7 组 + golden 3 组
- grep 防回归断言加进 CI（`scripts/ci/check-v2-bans.sh` 或 lint 规则）

> 若 v2 共享件已由 Today PR 全部落齐 → 合并 PR-2 / PR-3 为单 PR，总 PR 数 = 2。

---

## 7. 风险

1. **`HanaSectionHeader` / `HanaPullRefresh` 无 component spec**：v1.1 待落，本 PR 落最小可用版可能与未来正式 spec 不完全一致 —— 缓解：在 PR description 标注「临时实现，正式 spec 落地时回填」+ 在 widget 文件顶部加 `// TODO(v1.1-component-spec): 等待 docs/design/design-system/v2/components/{section-header,pull-refresh}.md 落地后回填` 注释。

2. **24h 活跃黛蓝陈述与原则 1「≤ 3 处」边界**：极端情况下章节竖线（1）+ 三栏状态行黛蓝（3）= 4 处。已在 spec §10 + 代码骨架 `_isFreshest` 解决：状态行黛蓝**仅**用于"最近一次"那一栏，最多 1 处。需在 widget test 第 5 组明确断言。

3. **字体加载**：v2 ramp 依赖 Spectral / Source Han Serif SC / Noto Serif JP / JetBrains Mono — 若 Today PR 未把这些字体加进 `pubspec.yaml` + `assets/fonts/`，本 PR 必须先加（APK +5-8MB CJK 子集化）。Web 端走 Google Fonts CDN，确认 `web/index.html` `<link>` 已注入 —— 否则首屏闪烁会暴露 v2 排版骨架。

4. **i18n 字段 `recordFooter` deprecate**：若运营 / 发布说明 / 帮助文档别处引用了「每一次记录都是对未来的温柔期许」—— 需全局 grep 确认无外部引用再下线。保守做法：保留 ARB key，在 widget 中不渲染。

5. **路由 `/photo` / `/measurement` / `/journal/edit`**：Web 端 `/photo` 可能因 file_picker 缺失而 fallback 到提示页 —— 与本 spec 无关，但实施时需保留 v1 的 fallback 行为，**不**误删 GoRouter 配置。

6. **"半迁移"风险**：critique-v1 §8 已警告，v2 是互锁系统。本 PR 必须**一次性** merge 全部 9 条 P0，**不**允许"先迁色不删 BackdropFilter" / "先删粒子不动文案"等增量上线 —— 中间态视觉比 v1 更难看。CI grep 防回归是底线。

— 完 —
