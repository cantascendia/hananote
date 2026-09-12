# Today 屏 v2 — Flutter Handoff Spec

> 配对 spec：docs/design/screens/today/spec.md
> 屏幕：lib/features/medication/presentation/pages/today_page.dart
> 受 CLAUDE.md 约束：保留 cubit/state 不动，仅改 UI；ARB 走 `lib/core/l10n/`
> Pilot Wave: 阶段 3.1.b（设计 → 工程交接）

---

## 1. 现有 BLoC 兼容性

`TodayScheduleBloc` / `TodayScheduleEvent` / `TodayScheduleState`（freezed union）**不需要任何改动**——v2 只重画 UI 层，状态机保持原契约。

**仍在用的事件**（`today_schedule_event.dart`）：
- `LoadTodaySchedule()` — 初次进入 / 重试 / 下拉刷新触发
- `LogDoseTodaySchedule({drug, schedule, scheduledDateTime})` — 「记一次」按下触发
- （若未来加 markUntake 撤销，新增事件，本 PR 不动）

**仍在用的 state 字段**（loaded variant）：
- `items: List<TodayScheduleItem>` — 全部今日条目
- `date: DateTime` — 用于副行 "4 月 28 日　周二"
- `completedCount: int` / `totalCount: int` — 用于「今日完毕。」hero 切换 + 庆祝触发判定

**新 UI 派生逻辑**（仅 presentation 层）：
- `uncompletedItems = items.where((i) => !i.isCompleted)` — 渲染「当前」段
- `completedItems = items.where((i) => i.isCompleted)` — 渲染「之后」段（褪色态）
- 不再需要 `upcoming` / `upcomingTime` 计算（v2 删除 CountdownCard）

> **不动 cubit 的好处**：现有 widget test 可只改文案断言不改 state mock，323 基线测试影响最小化。

---

## 2. 文件改动清单

### 主文件（重写）
- `lib/features/medication/presentation/pages/today_page.dart` — **完整重写**
  - 保留：BlocProvider 绑定、BlocListener 触发庆祝的判断逻辑（completedCount 增加）
  - 删除：所有 `BackdropFilter` / `BoxShadow` / `LinearGradient` / `Icons.auto_awesome` / 字体 `'PlusJakartaSans'` / 颜色静态常量 `HanaColors.*` / radius 14·15·16·24·999

### 子组件（全删）
- `lib/features/medication/presentation/widgets/countdown_card.dart` — **删除整文件**（v2 不需要倒计时卡）
- `lib/features/medication/presentation/widgets/upcoming_dose_card.dart` — **删除整文件**（替换为内联 `HanaCard.tappable` + 卡内 `HanaButton.primary`）
- `lib/features/medication/presentation/widgets/medication_status_card.dart` — **删除整文件**（替换为内联 `HanaCard.flat` 褪色态）
- `lib/features/medication/presentation/widgets/quote_card.dart` — **删除整文件**（v2 一屏一重心，引言喧宾夺主）

### 共享庆祝（删旧建新）
- `lib/core/widgets/petal_celebration.dart` — **删除整文件**
- `assets/sounds/petal_drop.mp3`（如有）— 删除
- `pubspec.yaml` — 检查是否仅 petal 用 `flutter_animate`，是则删除依赖

### 新增（PR 1 范围）
- `lib/app/theme/hana_tokens_v2.dart` — 单一 API 入口（DEC tokens.md §8.1）
- `lib/app/theme/hana_semantic_colors.dart` — `ThemeExtension<HanaSemanticColors>`（success/warning/accentMuted）
- `lib/core/widgets/hana_card.dart`
- `lib/core/widgets/hana_button.dart`
- `lib/core/widgets/hana_top_bar.dart`
- `lib/core/widgets/hana_celebration.dart`
- `lib/core/widgets/hana_press_scale.dart`
- `lib/core/widgets/hana_section_header.dart`（spec §3 引用，4px 黛蓝竖线）
- `lib/core/widgets/hana_empty_state.dart`
- `lib/core/widgets/hana_error_state.dart`
- `lib/core/widgets/hana_loading_view.dart`

### ARB 改动（`lib/core/l10n/arb/app_{en,zh,ja}.arb`）
| Key 新增 / 改动 | zh | ja | en |
|----------------|----|----|----|
| `today.heroMorning` | 早。 | 朝。 | Morning. |
| `today.heroDayComplete` | 今日完毕。 | 今日も終え。 | Done for today. |
| `today.sectionCurrent` | 当前 | いま | Now |
| `today.sectionLater` | 之后 | あと | Later |
| `today.recordOnce` (替换 `takeDose`) | 记一次 | 一回記す | Record |
| `celebration.recorded` | 今日已记。 | 今日も記しました。 | Recorded. |
| `today.emptyTitle` (替换 `noMedicationRecords`) | 本期空白。 | 本記なし。 | Empty. |
| `today.emptyMessage` | 尚未设置每日用药。 | 服薬予定が未設定です。 | No daily doses yet. |
| `today.addFirst` | 添加第一项 | 最初の一項を追加 | Add first |
| `today.errorRetry` | 载入失败。请下拉刷新。 | 読込失敗。引いて更新。 | Failed. Pull to refresh. |
| `today.loading` | 读取中。 | 読込中。 | Loading. |
| `today.timeAtDue` | "${time} 到时间了。" | "${time} になりました。" | "It's ${time}." |

旧 key（`takeDose` / `nextDose` / `todayCompleted` / `pendingDoses` / `takenDoses` / `dailyQuote0..11` / `hourUnit` / `minuteUnit`）保留 1 版本备 i18n 灰度后清理，不在本 PR 删除。

---

## 3. 组件依赖（按实施顺序）

```
1. HanaTokens               (依赖：无 — 仅静态色 + 常量)
2. HanaSemanticColors       (依赖：无 — ThemeExtension)
3. HanaPressScale           (依赖：HanaTokens.motion)
4. HanaCard                 (依赖：HanaTokens, HanaPressScale)
5. HanaButton               (依赖：HanaTokens, HanaPressScale)
6. HanaTopBar               (依赖：HanaTokens)
7. HanaCelebration          (依赖：HanaTokens — Overlay 自封装)
8. HanaSectionHeader        (依赖：HanaTokens)
9. HanaEmptyState           (依赖：HanaTokens, HanaButton)
10. HanaErrorState          (依赖：HanaTokens, HanaButton)
11. HanaLoadingView         (依赖：HanaTokens)

═══ PR 1 boundary ═══

12. today_page.dart 重写    (依赖：上述 1-11 全部 + 既有 cubit)
```

---

## 4. 实施代码骨架

```dart
// lib/features/medication/presentation/pages/today_page.dart (节选 build)
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: HanaTokens.background(context),
      appBar: HanaTopBar(
        title: l10n.appTitle,
        actions: [
          HanaIconButton(
            icon: Icons.calendar_today_outlined,
            onPressed: () => context.go('/timeline'),
          ),
        ],
      ),
      body: BlocListener<TodayScheduleBloc, TodayScheduleState>(
        listenWhen: (p, c) =>
            (c.mapOrNull(loaded: (s) => s.completedCount) ?? 0) >
            (p.mapOrNull(loaded: (s) => s.completedCount) ?? 0),
        listener: (context, _) => HanaCelebration.trigger(
          context,
          message: l10n.celebrationRecorded,
        ),
        child: BlocBuilder<TodayScheduleBloc, TodayScheduleState>(
          builder: (context, state) => state.when(
            initial: () => const HanaLoadingView(variant: block),
            loading: () => const HanaLoadingView(variant: block),
            error: (msg) => HanaErrorState(
              message: l10n.todayErrorRetry,
              onRetry: () => context
                  .read<TodayScheduleBloc>()
                  .add(const LoadTodaySchedule()),
            ),
            loaded: (items, date, done, total) => _TodayContent(
              items: items, date: date, done: done, total: total,
            ),
          ),
        ),
      ),
    );
  }
}

// _TodayContent 内：
//   - SliverPadding(top: spacing.xl)
//   - Hero Text (display-xl ink，「早。」/「今日完毕。」)
//   - 副行 mono+body-sm (date + HRT day)
//   - SliverPadding(spacing.lg)
//   - HanaSectionHeader(title: l10n.todaySectionCurrent) — 黛蓝竖线
//   - SliverList<HanaCard.tappable>(uncompletedItems → 卡内 HanaButton.primary)
//   - HanaSectionHeader(title: l10n.todaySectionLater) — 无竖线，灰 label
//   - SliverList<HanaCard.flat>(completedItems → 全文 inkSecondary 褪色态)
//   - SliverPadding(bottom: spacing.xl)
//   - empty fallback: HanaEmptyState.page
```

---

## 5. 测试策略

### widget test（新增 / 改写）
- `today_page_test.dart`：
  - 默认态（混合未服 + 已服）→ 渲染 2 个 section header + 正确卡片数
  - 全部已服态 → hero 文字为 `today.heroDayComplete`，无 current section
  - 空态 → 渲染 HanaEmptyState page variant + secondary 按钮可点
  - 错误态 → HanaErrorState 渲染 + 重试派发 LoadTodaySchedule
  - 「记一次」按下 → 派发 LogDoseTodaySchedule + completedCount 增加触发 HanaCelebration overlay 出现

### a11y test
- Semantics 节点完整：每张当前卡 = 1 个 button 角色，label = "${section}　${name}　${dose}　${time}　${status}"
- Focus 顺序断言（traversal）：AppBar → hero → 章节 → 卡片群

### golden test
- `today_page.golden_test.dart`：light + dark 各 1 张 default 态截图，目标 `goldens/today_default_{light,dark}.png`
- 字体加载需在 setUpAll 内 `await loadAppFonts()`（goldenToolkit）

### 现有测试影响
- `lib/features/medication/test/presentation/pages/today_page_test.dart`（如存在）需更新断言：
  - "标记已服" / "服药" → `today.recordOnce`
  - "已服用" / 检查 ✓ Icon → 改检 inkSecondary 文字 + 缺失 ✓
  - "倒计时" 相关断言整段删除（CountdownCard 不存在）

---

## 6. CI / Build 注意

### 字体注入
新增 `assets/fonts/`：
- Spectral-SemiBold.ttf / Spectral-Regular.ttf（西文 Display / Title）
- Inter-Regular.ttf / Inter-Medium.ttf（西文 Body / Label）
- SourceHanSerifSC-Medium.otf / SourceHanSerifSC-Regular.otf（中文宋体）
- SourceHanSansSC-Regular.otf / SourceHanSansSC-Medium.otf（中文黑体）
- NotoSerifJP-Medium.ttf / NotoSerifJP-Regular.ttf（日文宋体）
- NotoSansJP-Regular.ttf（日文黑体）
- JetBrainsMono-Light.ttf（数值）

`pubspec.yaml` 在 `flutter.fonts` 节点登记（family + asset）。CJK 字体务必子集化（脚本 `tools/subset_cjk.sh` — 本 PR 不涉及，PR 1 后 follow-up）。

### Web 端
- `web/index.html` 加 Google Fonts CDN preconnect：Spectral / Inter / Noto Serif JP / Noto Sans JP / JetBrains Mono
- `font-display: optional`（responsive.md 已规范）— 首屏先用系统宋体（STSong / 苹方-繁宋 / Yu Mincho），二屏切思源宋体，避免闪烁

### ARB 重新生成
```bash
flutter gen-l10n
```
ARB 改动后 `app_localizations*.dart` 自动更新（不要手改生成文件，CLAUDE.md 铁律）。

### 依赖检查
- `dart analyze --fatal-infos` 必须通过
- `flutter test` 基线 323 不退化（预期 ±5 个测试因 v2 重写）
- CI lock：Flutter 3.38.4 + bloc_test ^10.0.0（CLAUDE.md）

### Lint 防回归
推荐在 PR 1 同时加 `analysis_options.yaml`：
```yaml
custom_lint:
  rules:
    - hana_no_backdrop_filter
    - hana_no_box_shadow
    - hana_no_linear_gradient
    - hana_no_legacy_hana_colors_static
```
（自定义 lint 规则在另一个 PR 内实施，本 PR 留 TODO）

---

## 7. PR 拆分建议

| PR | 范围 | Diff 量级 | Reviewer 重点 |
|----|------|----------|-------------|
| **PR 1** | 添加 `HanaTokens` + `HanaSemanticColors` + 7 个 P0 共享组件（HanaCard / HanaButton / HanaTopBar / HanaCelebration / HanaPressScale / HanaSectionHeader / HanaEmptyState）。**不动任何 page**。 | +2k / -0 | tokens 单一 API 是否符合 §8.1，组件 props 是否锁字面量（不接受外部 backgroundColor / radius） |
| **PR 2** | 重写 `today_page.dart` 用 PR 1 组件；删除 `widgets/countdown_card.dart` / `upcoming_dose_card.dart` / `medication_status_card.dart` / `quote_card.dart` / `core/widgets/petal_celebration.dart`；ARB 新 key + gen_l10n。 | +400 / -1.2k | hero / 章节 / 卡片层级是否符合 spec §2 wireframe；3 处黛蓝硬规则；庆祝触发链路 |
| **PR 3** | 文案断言 + widget test 更新 + golden 截图基线；新增 `today_page.golden_test.dart` light/dark；CI lint 规则桩（TODO 标注）。 | +600 / -200 | 测试覆盖率 / golden 是否能在 CI 渲染（字体 fallback） |

> **三 PR 独立可 review、可 revert**。PR 1 不影响线上（仅新增 unused 组件）；PR 2 是视觉切换日；PR 3 锁基线防回归。

> **禁止合并为单 PR**——critique-v1 §8 风险提示「半迁移」与「单一巨型 PR」两种失败模式都要避免，三 PR 拆分既保留 v2 互锁系统的整体性（PR 2 一次性切完，不存在中间态），又给每个层面独立 review 空间。

---

## 8. 风险

### 风险 1：HanaCelebration 替代 PetalCelebration 引发"粉丝纪念效应"
v1 重度用户可能对花瓣消失感到失落（粉樱花瓣是 v1 的 brand recall）。
- **缓解**：在 release notes / Onboarding 第 5 屏明示设计哲学转变（"克制 = 重审美"）；提供 Settings 选项「庆祝反馈风格」未来可加可选静默模式（不本 PR 实施）。

### 风险 2：字体体积对 Web PWA 首屏影响
Spectral + Source Han Serif SC + Noto Serif JP 全集 ~12MB，未子集化时首屏加载明显。
- **缓解**：① `font-display: optional` 让首屏走系统宋体不闪 ② 思源宋体子集化（GB 2312 + JIS 第一水准 + Latin Basic）压到 ~2MB ③ 移动端 APK CJK 子集压到 5-8MB 内（candidate-A §4 已估算）。

### 风险 3：移除 4 处 BackdropFilter 后状态栏与内容融合
取消玻璃模糊后，滚动到 hero 上方时状态栏背景与内容色相同（都 #F4F1EA），可能视觉融合。
- **缓解**：HanaTopBar 用 `surfaceContainerHigh #EAE6DD` 实色不透明，与背景 #F4F1EA 形成 6 个明度差，肉眼可分辨；滚动时下方加 0.5px outline @ 30% 进一步强化边界。已在 spec §2 / components/top-bar.md 锁定。

### 风险 4：CountdownCard 删除导致"下次提醒时间"信息丢失
v1 用户依赖大数字倒计时知道还差多久。
- **缓解**：spec §2 在当前药卡内嵌一行「08:00 到时间了。」陈述句（`today.timeAtDue` ARB），信息保留但去掉强调；Web ≥1024 右侧浮岛 240px 可补一个轻量「下一次 12:30」小卡（PR 2 后 follow-up，不阻塞）。

### 风险 5：现有 323 widget test 多处文案 / Icon 断言失败
- **缓解**：PR 3 专门处理测试更新；预期 ~10 处断言改写（"服药" → "记一次"，"checkmark icon" → "absent"）；总数预期保持 323 ± 5 内。

---

— 完 —
