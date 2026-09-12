# Data 屏 v2 — Flutter Handoff Spec

> 配对 spec：`docs/design/screens/data/spec.md`
> 屏幕：`lib/features/blood_test/presentation/pages/data_page.dart`
> 受 CLAUDE.md 约束：保留 BLoC / state / event 不动，仅改 UI；ARB 走 `lib/core/l10n/`
> Pilot Wave: 阶段 3.3.b（设计 → 工程交接）

---

## 1. 现有 BLoC 兼容性

`BloodTestBloc` / `BloodTestEvent` / `BloodTestState`（freezed sealed union）**不需要任何改动**——v2 只重画 UI 层。

**仍在用的事件**：
- `LoadBloodTestData()` — 初次进入 / 重试 / 下拉刷新
- `SelectHormoneForTrend(HormoneType)` — Hormone 卡 onTap 触发；趋势 segmented 切换触发
- `SelectTrendRange(TrendRange)` — 趋势 range chip 切换
- `DeleteBloodTestReport(id)` — 历次卡左滑删除（v2 暂不引入手势）

**仍在用的 loaded state 字段**（详见 `blood_test_state.dart:19-26`）：
- `reports: List<BloodTestReport>`
- `latestReadings: Map<HormoneType, HormoneReading>` → 渲染「当前指标」段
- `selectedTrendHormone: HormoneType` → 趋势卡当前 hormone
- `selectedRange: TrendRange` → 趋势卡当前时间窗
- `trendData: List<HormoneReading>` → 趋势折线 data points
- `lastUpdated: DateTime?` → Hero 副行「截至 4 月 28 日」

**新 UI 派生逻辑**（仅 presentation 层）：
- `latestReadings.values.toList()` → 1 列 hormone 卡（**不再是 GridView 2×2**）
- 焦点点 = `trendData.last`（除非超出范围则为首个超出点，详见 §3 `_focusIndex`）
- 历次报告倒序：`reports..sort((a,b) => b.testDate.compareTo(a.testDate))`

> **不动 bloc 的好处**：现有 widget test 可只改文案断言不改 state mock。

---

## 2. 文件改动清单

### 主文件（重写）
- `lib/features/blood_test/presentation/pages/data_page.dart` — **完整重写**
  - 保留：`BlocProvider` 绑定、`BloodTestBloc.add(...)` 调用点
  - 删除：所有 `BackdropFilter` / `BoxShadow` / `LinearGradient` / `'Plus Jakarta Sans'` / `HanaColors.*` / radius 16·24·9999

### 子组件（全删 / 替换）
- `_StitchHormoneCard` (line 234-399) — **删除**，替换为 `HanaCard.tappable` + `_HormoneRow` 内部 widget（同文件保留）
- `_StitchHistoryCard` (line 832-958) — **删除**，替换为 `HanaCard.tappable` + 单行内容
- `_StitchSimulatorCard` (line 401-487) — **删除**，替换为 `HanaCard.tappable` 列表项
- `_StitchKnowledgeCard` (line 489-578) — **删除**，替换为 `HanaCard.tappable` 列表项
- `_TrendChart` (line 580-830) — **重写**为 `_TrendCard`（HanaCard.flat + 内嵌 `HanaLineChart` wrapper）
- `_EmptyHistoryCard` (line 960-983) — **删除**，替换为 `HanaEmptyState.inline`

### 新增（共享）
- `lib/core/widgets/charts/hana_line_chart.dart` — fl_chart wrapper，封装 §3 theme（Phase 5 实施 / 未单独 component md，由本 handoff 定义契约）

### ARB 改动（`lib/core/l10n/arb/app_{en,zh,ja}.arb`）

| Key 新增 / 改动 | zh | ja | en |
|----------------|----|----|----|
| `data.heroTitle` | 本期数据。 | 今期データ。 | This period. |
| `data.heroSubtitleAsOf` | 截至 {date}　共 {count} 期 | {date} 時点　全 {count} 件 | As of {date} · {count} reports |
| `data.heroSubtitleEmpty` | 尚未导入。 | 未導入。 | Not yet imported. |
| `data.sectionCurrent` | 当前指标 | 今期の指標 | Current readings |
| `data.sectionTrend` | 趋势 | 推移 | Trend |
| `data.sectionTools` | 工具 | ツール | Tools |
| `data.sectionHistory` | 历次报告 | 過去の報告 | Past reports |
| `data.statusInRange` | 范围 {min} – {max}　·　在范围内 | 範囲 {min} – {max}　·　範囲内 | Range {min}–{max} · within |
| `data.statusHigh` | 范围 {min} – {max}　·　偏高 | 範囲 {min} – {max}　·　高め | Range {min}–{max} · high |
| `data.statusLow` | 范围 {min} – {max}　·　偏低 | 範囲 {min} – {max}　·　低め | Range {min}–{max} · low |
| `data.criticalSuggest` | 建议复诊。 | 再診を推奨。 | Consider re-test. |
| `data.trendLatestNote` | 最近一次　{value} {unit}　·　{trend} | 直近　{value} {unit}　·　{trend} | Latest {value} {unit} · {trend} |
| `data.trendNeedsTwo` | 需至少两次报告才能成线。 | 推移には 2 回以上の記録が必要。 | Need ≥ 2 reports for a trend. |
| `data.simulatorTitle` | PK 模拟器 | PK シミュレータ | PK simulator |
| `data.simulatorSubtitle` | 按药物代谢估算次日血药浓度。 | 薬物動態から翌日の血中濃度を予測。 | Estimate next-day plasma level. |
| `data.knowledgeTitle` | 知识库 | 知識ベース | Knowledge base |
| `data.knowledgeSubtitle` | HRT 流程、药物百科与文献摘要。 | HRT 手順、薬剤百科、文献要約。 | HRT flow, drug wiki, literature. |
| `data.emptyTitle` | 本期空白。 | 本期記録なし。 | Empty. |
| `data.emptyMessage` | 尚未录入血检报告。 | 血液検査報告が未登録です。 | No blood test reports yet. |
| `data.addFirstReport` | 录入第一份 | 最初の一件を追加 | Add first |
| `data.xAxisMonth` | {n} 月 | {n}月 | (locale-specific Mon abbr) |

旧 key（`dataAndTrends` / `myStatus` / `bodyChanging` / `trendSection` / `historyReports` / `lastHalfYear` / `noBloodTestHistory` / `noTrendData` / `pkSimulatorTitle` / `pkSimulatorSubtitle` / `knowledgeBase` / `knowledgeBaseSubtitle` / `noUpdatesYet` / `lastUpdated` / `trendDecreasing` / `trendStable`）保留 1 版本备 i18n 灰度，本 PR 不删。

---

## 3. fl_chart 主题配置（核心代码片段）

`lib/core/widgets/charts/hana_line_chart.dart`（约 90 行，节选关键 30 行）：

```dart
class HanaLineChart extends StatelessWidget {
  const HanaLineChart({
    super.key,
    required this.points,        // List<({DateTime date, double value})>
    required this.unit,
    this.focusIndex,             // 默认 = points.length - 1
    this.height = 180,
  });

  final List<({DateTime date, double value})> points;
  final String unit;
  final int? focusIndex;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ink = HanaTokens.ink(context);
    final inkSecondary = HanaTokens.inkSecondary(context);
    final primary = HanaTokens.primary(context);
    final outlineVariant = Theme.of(context).colorScheme.outlineVariant;

    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];
    final (minY, maxY, interval) = _niceRange(
      points.map((p) => p.value),
    );
    final focus = focusIndex ?? points.length - 1;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: outlineVariant.withOpacity(0.30),
              strokeWidth: 1,
              dashArray: const [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                interval: interval,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      color: ink,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                // 按数据密度限制 ≤ 6 个 label
                interval: max(1, (points.length / 6).ceil()).toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      _formatMonth(context, points[index].date),
                      style: _serifLabelStyle(context),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,        // **关键** 直线段
              isStrokeCapRound: false,
              color: ink,             // **关键** 单色 ink
              barWidth: 1.5,          // **关键** 印刷级细线
              belowBarData: BarAreaData(show: false), // **关键** 无填充
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, idx) => FlDotCirclePainter(
                  radius: idx == focus ? 6 : 4,
                  color: idx == focus ? primary : ink,
                  strokeWidth: 0,    // **关键** 无描边
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  HanaTokens.surfaceContainerLowest(context),
              tooltipRoundedRadius: 4,
              tooltipBorder: BorderSide.none,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItems: (spots) => spots.map((s) {
                final p = points[s.x.toInt()];
                return LineTooltipItem(
                  '${DateFormat('yyyy.MM.dd').format(p.date)}\n'
                  '${p.value.toStringAsFixed(1)} $unit',
                  TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    color: ink,
                    height: 1.4,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        duration: HanaTokens.motion.deliberate, // 600ms 折线 sweep
        curve: Curves.easeOut,
      ),
    );
  }

  /// "nice number" Y 轴：把 minY/maxY 取整到刻度并 3 等分
  (double minY, double maxY, double interval) _niceRange(Iterable<double> vs) {
    if (vs.isEmpty) return (0, 100, 25);
    final lo = vs.reduce(min);
    final hi = vs.reduce(max);
    final pad = (hi - lo) * 0.15;
    final niceLo = ((lo - pad) / 10).floor() * 10.0;
    final niceHi = ((hi + pad) / 10).ceil() * 10.0;
    return (niceLo, niceHi, ((niceHi - niceLo) / 3).ceilToDouble());
  }

  String _formatMonth(BuildContext context, DateTime d) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'en') return DateFormat.MMM('en').format(d);
    return l10n.dataXAxisMonth(d.month); // "{n} 月" / "{n}月"
  }

  TextStyle _serifLabelStyle(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final family = switch (lang) {
      'zh' => 'Source Han Serif SC',
      'ja' => 'Noto Serif JP',
      _ => 'Spectral',
    };
    return TextStyle(
      fontFamily: family,
      fontSize: 12,
      color: HanaTokens.ink(context),
      height: 1.0,
    );
  }
}
```

> 注：`LineChart.duration` 是 fl_chart 0.65+ API；如锁版 < 0.65 则改 `swapAnimationDuration`/`swapAnimationCurve`。

---

## 4. 组件依赖（按实施顺序）

```
今日已落地（today PR 范围）：
  HanaTokens / HanaSemanticColors / HanaPressScale / HanaCard /
  HanaButton / HanaTopBar / HanaSectionHeader / HanaEmptyState /
  HanaErrorState / HanaLoadingView

本 PR 新增：
  HanaLineChart                (依赖：HanaTokens, fl_chart)
  HanaSegmented (可选)          (依赖：HanaTokens — 若延期可临时用 HanaChoiceChips)

本 PR 重写：
  data_page.dart 全屏          (依赖：上述全部 + 既有 BloodTestBloc)
```

---

## 5. 实施代码骨架（节选）

```dart
// lib/features/blood_test/presentation/pages/data_page.dart
class DataPage extends StatelessWidget {
  const DataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: HanaTokens.background(context),
      appBar: HanaTopBar(
        title: l10n.dataTabTitle,
        actions: [
          HanaTopBarAction.ghost(
            icon: Icons.add,
            onTap: () => context.push('/data/add_report'),
          ),
        ],
      ),
      body: BlocBuilder<BloodTestBloc, BloodTestState>(
        builder: (context, state) => switch (state) {
          BloodTestInitial() => const SizedBox.shrink(),
          BloodTestLoading() => const HanaLoadingView.block(),
          BloodTestError(:final message) => HanaErrorState(
              message: message,
              retryLabel: l10n.retry,
              onRetry: () => context
                  .read<BloodTestBloc>()
                  .add(const LoadBloodTestData()),
            ),
          BloodTestLoaded(
            :final reports,
            :final latestReadings,
            :final selectedTrendHormone,
            :final trendData,
            :final lastUpdated,
          ) =>
            _LoadedView(
              reports: reports,
              latestReadings: latestReadings,
              selectedHormone: selectedTrendHormone,
              trendData: trendData,
              lastUpdated: lastUpdated,
            ),
        },
      ),
    );
  }
}

// _LoadedView 主结构（简化）：
ListView(
  padding: EdgeInsets.symmetric(horizontal: HanaTokens.spacing.lg),
  children: [
    SizedBox(height: HanaTokens.spacing.xl),
    _Hero(lastUpdated: lastUpdated, count: reports.length),
    SizedBox(height: HanaTokens.spacing.lg),

    HanaSectionHeader(label: l10n.dataSectionCurrent),
    SizedBox(height: HanaTokens.spacing.md),
    for (final reading in latestReadings.values) ...[
      _HormoneCard(reading: reading),
      SizedBox(height: HanaTokens.spacing.md),
    ],
    SizedBox(height: HanaTokens.spacing.lg),

    HanaSectionHeader(label: l10n.dataSectionTrend),
    SizedBox(height: HanaTokens.spacing.md),
    _TrendCard(
      hormone: selectedHormone,
      trendData: trendData,
      reports: reports,
    ),
    SizedBox(height: HanaTokens.spacing.lg),

    HanaSectionHeader(label: l10n.dataSectionTools),
    SizedBox(height: HanaTokens.spacing.md),
    _ToolEntry(
      title: l10n.dataSimulatorTitle,
      subtitle: l10n.dataSimulatorSubtitle,
      onTap: () => context.push('/data/simulator'),
    ),
    SizedBox(height: HanaTokens.spacing.md),
    _ToolEntry(
      title: l10n.dataKnowledgeTitle,
      subtitle: l10n.dataKnowledgeSubtitle,
      onTap: () => context.push('/knowledge'),
    ),
    SizedBox(height: HanaTokens.spacing.lg),

    HanaSectionHeader(label: l10n.dataSectionHistory),
    SizedBox(height: HanaTokens.spacing.md),
    if (reports.isEmpty)
      HanaEmptyState.inline(
        icon: Icons.insert_chart_outlined,
        title: l10n.dataEmptyTitle,
        message: l10n.dataEmptyMessage,
      )
    else
      for (final report in reports) ...[
        _HistoryCard(report: report),
        SizedBox(height: HanaTokens.spacing.md),
      ],
    SizedBox(height: HanaTokens.spacing.xl),
  ],
)
```

`_HormoneCard` 关键逻辑：

```dart
final status = reading.type.statusFor(reading.value);
final isOutOfRange = status != HormoneStatus.normal;
final valueColor = isOutOfRange
    ? HanaTokens.primary(context)   // 一抹强色：超出 = 黛蓝数字
    : HanaTokens.ink(context);
final statusText = switch (status) {
  HormoneStatus.normal => l10n.dataStatusInRange(min, max),
  HormoneStatus.warning => reading.value < min
      ? l10n.dataStatusLow(min, max)
      : l10n.dataStatusHigh(min, max),
  HormoneStatus.critical => /* 同 warning + 多一行 */ ...,
};

return HanaCard.tappable(
  onTap: () => context
      .read<BloodTestBloc>()
      .add(SelectHormoneForTrend(reading.type)),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(reading.type.localizedName(l10n), style: HanaTextStyles.title(context)),
      SizedBox(height: HanaTokens.spacing.sm),
      Row(crossAxisAlignment: CrossAxisAlignment.baseline, ... [
        Text(reading.value.toStringAsFixed(1),
            style: HanaTextStyles.monoDisplay(context).copyWith(color: valueColor)),
        SizedBox(width: HanaTokens.spacing.xs),
        Text(reading.type.defaultUnit, style: HanaTextStyles.label(context)),
      ]),
      SizedBox(height: HanaTokens.spacing.sm),
      Text(statusText, style: HanaTextStyles.bodySmall(context)
          .copyWith(color: HanaTokens.inkSecondary(context))),
      if (status == HormoneStatus.critical) ...[
        SizedBox(height: HanaTokens.spacing.xs),
        Text(l10n.dataCriticalSuggest, style: HanaTextStyles.bodySmall(context)
            .copyWith(color: HanaTokens.error(context))),
      ],
    ],
  ),
);
```

---

## 6. 测试影响

- 现有 `data_page` 相关 widget test 文案断言走新 ARB key（`data.heroTitle` 等）
- `HanaLineChart` 新增 1 个 widget test + 1 个 golden（在范围 / 偏高 / 单点态三种 fixture）
- `_HormoneCard` 新增 widget test：3 状态 × 2 主题 = 6 个 case
- 基线 323 → 预计 +12 = 335，CI 时长影响 < 5%

---

## 7. PR 拆分建议

由于 today 屏 PR 已落地 11 个核心 widget，data 屏可单 PR：
1. **PR 1**：`hana_line_chart.dart` 新增 + golden test
2. **PR 2**：`data_page.dart` 重写 + ARB 改动 + 删除 5 个 _Stitch* 私有 widget + widget test 改造

如果 segmented 控件优先级高，可在本 PR 之前先做 `HanaSegmented` 落地 PR。

---

## 8. 已知风险与对策

| 风险 | 对策 |
|-----|-----|
| fl_chart 锁版 < 0.65 不支持 `LineChart.duration` | 改用 `swapAnimationDuration`/`swapAnimationCurve` 并加 pubspec 注释 |
| `HanaSegmented` 未实施 | spec §3 已允许 fallback 到 `HanaChoiceChips`，4 个文字 chip + 黛蓝下划线 |
| Web 端 `JetBrains Mono` Google Fonts CDN 加载 | 已在 tokens.md §2.2 处理，本屏沿用相同 fallback 链 |
| 焦点点判定在多 hormone 数据下歧义 | spec §5.2 锁定为「该 hormone 最新一次 OR 首个超出点」二选一，UI 不再自定义 |
| 单屏 mono primary 数字 > 3 处（多 hormone 全偏离） | spec §11 决策：可接受但需 reviewer ack；后续如频繁触发再考虑「按距离排序仅前 3 染色」|

---

— 完 —
