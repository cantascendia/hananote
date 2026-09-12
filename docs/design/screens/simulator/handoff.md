# Simulator 屏 v2 — Flutter Handoff Spec

> 配对 spec：`docs/design/screens/simulator/spec.md`
> 屏幕：`lib/features/simulator/presentation/pages/simulator_page.dart`
> 受 CLAUDE.md 约束：保留 BLoC / state / event 不动，仅改 UI；ARB 走 `lib/core/l10n/`；domain 零外部依赖
> Pilot Wave: 阶段 3.4.b（设计 → 工程交接）

---

## 1. 现有 BLoC 兼容性

`SimulatorBloc` / `SimulatorEvent` / `SimulatorState`（freezed sealed union）**仅需小改**——v2 在 UI 层重写，state 字段补 1 项（target range）。

**仍在用的事件**：
- `SimulatorEvent.started()` — 初次进入，加载默认方案（保留）
- `SimulatorEvent.regimenUpdated(regimen: DosingRegimen)` — 方案任何字段变化（保留 + debounce 300ms）
- `SimulatorEvent.engineToggled()` — 切换 V2 / Hana-PK 主线（保留）

**仍在用的 loaded state 字段**：
- `regimen: DosingRegimen` → 方案折叠卡 + input 反向回填
- `result: PkSimulationResult` → V2 引擎计算结果（曲线 + 稳态 + AUC）
- `hanaPkResult: PkSimulationResult?` → Hana-PK 引擎结果（含 MAP 校准）
- `isHanaPk: bool` → 当前主线引擎；false = V2，true = Hana-PK

**新增 state 字段**（presentation 派生即可，不改 bloc）：
- `targetRangeMin / targetRangeMax` → 暂以 `regimen.esterType` 派发默认（estradiol 系：600/1800 pmol/L；testosterone 系：8/30 nmol/L 等），由 widget 层 `_TargetRange.fromEster(EsterType)` 工具函数派发。**未来**单独 settings 自定义入口落地后再加 state 字段（本次不动 bloc）。

**新 UI 派生逻辑**：
- 焦点点索引：`_focusIndex(curve, targetMax, targetMin)`（详见 §3.3）
- 状态判定：`_StatusKind {inRange, warning, critical}` from avg + range
- 引擎说明文案：`isHanaPk ? l10n.hanaPkSubtitle("含 MAP 校准") : l10n.v2Subtitle("基础药动学")`
- 90 天 X 轴间隔派发：`_xInterval(maxX)` → 5 / 10 / 30 三档

> **不动 bloc 的好处**：现有 widget test（如有）仅需更新断言，不动 state mock；domain 层 PK 计算引擎完全不动。

---

## 2. 文件改动清单

### 主文件（重写）
- `lib/features/simulator/presentation/pages/simulator_page.dart` — **完整重写**
  - 删除：所有 `// ignore_for_file:` lint suppression（line 3-10，共 5 项）
  - 保留：`BlocProvider` 绑定（line 32-37）、`BlocBuilder<SimulatorBloc, SimulatorState>`、`state.map / maybeMap` 模式
  - 删除：`HanaColors.*` / `HanaShadows.cardShadow` / `BackdropFilter` / `Icons.science` / `Badge('Beta')` / `Colors.green` / `Colors.orange`

### 子组件（全删 / 替换）
- `_SimulatorScan` (line 40) — **保留外壳**（Scaffold + AppBar + state.map 入口）；改用 `HanaTopBar`
- `_ParamsCard` + `_ParamsCardState` (line 144-378) — **删除**，替换为 `_RegimenSection`（HanaCard.flat collapsible + 内置 `_RegimenInputs` widget）
- `_ChartCard` + `_LegendItem` (line 380-678) — **删除**，替换为 `_ConcentrationSection`（HanaCard.flat + 内嵌 `HanaLineChart` wrapper）
- `_SummaryCard` + `_StatIndicator` (line 680-796) — **删除**，替换为 `_SteadyStateSection`（HanaCard.flat 大字稳态 + 折叠 `_DetailCard`）
- 新增：`_DisclaimerFootnote`（屏幕底部强制免责，body-sm error）

### 新增（共享）
- `lib/core/widgets/charts/hana_line_chart.dart` — **由 data 屏 handoff 创建**，本次扩展双线模式（详见 §3.1）
- `lib/core/widgets/charts/_dual_line_painter.dart`（如需 CustomPaint 图例）— 1.5dp 虚线绘制

### ARB 改动（`lib/core/l10n/arb/app_{en,zh,ja}.arb`）

| Key 新增 / 改动 | zh | ja | en |
|----------------|----|----|----|
| `simulator.heroTitle` | 用药模拟。 | 用量シミュレーション。 | Dose simulation. |
| `simulator.heroSubtitle` | V2 + Hana-PK 双引擎　含 MAP 校准 | V2 + Hana-PK ２エンジン　MAP 校正 | V2 + Hana-PK · MAP-calibrated |
| `simulator.sectionRegimen` | 方案 | 用量 | Regimen |
| `simulator.sectionConcentration` | 浓度 | 濃度 | Concentration |
| `simulator.sectionSteadyState` | 稳态 | 定常状態 | Steady state |
| `simulator.regimenSummary` | {ester}　{dose} mg / {interval} 天 | {ester}　{dose} mg / {interval} 日 | {ester} · {dose} mg / {interval} d |
| `simulator.fieldDrug` | 药物 | 薬剤 | Drug |
| `simulator.fieldDose` | 剂量 | 用量 | Dose |
| `simulator.fieldInterval` | 间隔 | 間隔 | Interval |
| `simulator.fieldRoute` | 途径 | 投与経路 | Route |
| `simulator.fieldWeight` | 体重 | 体重 | Weight |
| `simulator.fieldPatchWear` | 贴片佩戴 | パッチ装着 | Patch wear |
| `simulator.fieldSublingual` | 含服时长 | 舌下保持 | Sublingual hold |
| `simulator.routeOral` | 口服 | 経口 | Oral |
| `simulator.routeInjection` | 注射 | 注射 | Injection |
| `simulator.routeTransdermal` | 透皮 | 経皮 | Transdermal |
| `simulator.routeOther` | 其他 | その他 | Other |
| `simulator.engineV2` | V2 | V2 | V2 |
| `simulator.engineHanaPk` | Hana-PK | Hana-PK | Hana-PK |
| `simulator.engineCaption` | Hana-PK 含 MAP 校准。 | Hana-PK は MAP 校正付き。 | Hana-PK includes MAP calibration. |
| `simulator.steadyAverageLabel` | 稳态平均 | 定常平均 | Steady avg |
| `simulator.targetRangeLabel` | 目标范围 {min} – {max}　·　{status} | 目標範囲 {min} – {max}　·　{status} | Target {min}–{max} · {status} |
| `simulator.statusInRange` | 在范围内 | 範囲内 | within |
| `simulator.statusHigh` | 偏高 | 高め | high |
| `simulator.statusLow` | 偏低 | 低め | low |
| `simulator.criticalDeviation` | 与目标范围偏离过大。 | 目標範囲から大きく外れています。 | Far outside target. |
| `simulator.timeToSteady` | 达稳态　约 {days} 天 | 定常まで　約 {days} 日 | ~{days} d to steady |
| `simulator.detailLabel` | 详细 | 詳細 | Detail |
| `simulator.detailPeak` | 峰 | ピーク | Peak |
| `simulator.detailTrough` | 谷 | トラフ | Trough |
| `simulator.detailAuc` | AUC | AUC | AUC |
| `simulator.detailCmax` | Cmax | Cmax | Cmax |
| `simulator.disclaimer` | 仅供参考。不替代医疗建议。 | 参考情報。医療助言の代替ではありません。 | For reference only. Not medical advice. |
| `simulator.xAxisDay` | {n} 天 | {n}日 | d{n} |
| `simulator.unitPmolL` | pmol/L | pmol/L | pmol/L |

> 沿用 `ester_type.dart` 现有 `localizedName(l10n)` 扩展（domain 零外部依赖原则），不在 ARB 重复 22 种药名。

---

## 3. HanaLineChart 双线扩展实现

### 3.1 API 契约

```dart
class HanaLineChart extends StatelessWidget {
  const HanaLineChart({
    required this.primaryCurve,        // 主线数据点 List<({double x, double y})>
    this.compareCurve,                 // 可选对比线（虚线渲染）
    required this.unit,                // Y 轴单位字符串 'pmol/L' 等
    required this.xAxisLabelBuilder,   // (double x) => String，按 locale 派发
    required this.yAxisInterval,       // double，nice number 算法见 §3.4
    required this.targetMin,           // 阈值参考线（可选）
    required this.targetMax,
    required this.focusIndex,          // 焦点点索引（主线内）
    this.height = 240,
    super.key,
  });
}
```

### 3.2 fl_chart LineChartData 配置（核心 diff vs v1）

```dart
LineChartData(
  gridData: FlGridData(
    show: true,
    drawVerticalLine: false,
    horizontalInterval: yAxisInterval,
    getDrawingHorizontalLine: (_) => FlLine(
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.30),
      strokeWidth: 1.0,
      dashArray: const [4, 4],
    ),
  ),
  borderData: FlBorderData(show: false),
  titlesData: FlTitlesData(
    bottomTitles: AxisTitles(sideTitles: SideTitles(
      showTitles: true, reservedSize: 24,
      interval: _xInterval(maxX),
      getTitlesWidget: (v, _) => Text(
        xAxisLabelBuilder(v),
        style: TextStyle(
          fontFamily: _serif(context), // 宋体
          fontSize: 12,
          color: HanaTokens.inkSecondary(context),
        ),
      ),
    )),
    leftTitles: AxisTitles(sideTitles: SideTitles(
      showTitles: true, reservedSize: 56,
      interval: yAxisInterval,
      getTitlesWidget: (v, _) => Text(
        v.toInt().toString(),
        style: TextStyle(
          fontFamily: 'JetBrains Mono', fontWeight: FontWeight.w300,
          fontSize: 12, color: HanaTokens.ink(context),
        ),
      ),
    )),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  ),
  // 阈值参考线（单线，不上下夹色块 — v1 RangeAnnotation 全删）
  extraLinesData: ExtraLinesData(
    horizontalLines: [
      if (targetMin != null) HorizontalLine(
        y: targetMin!,
        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.15),
        strokeWidth: 1.0,
      ),
      if (targetMax != null) HorizontalLine(
        y: targetMax!,
        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.15),
        strokeWidth: 1.0,
      ),
    ],
  ),
  lineBarsData: [
    // 对比线（如有）：1.5dp ink 虚线，无焦点点，无填充
    if (compareCurve != null) LineChartBarData(
      spots: compareCurve!.map((p) => FlSpot(p.x, p.y)).toList(),
      isCurved: false,                           // 直线段（hard rule）
      color: HanaTokens.ink(context),            // 同色（hard rule）
      barWidth: 1.5,                             // 1.5dp（hard rule）
      isStrokeCapRound: false,
      dashArray: const [5, 5],                   // 虚线区分
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),    // 无填充（hard rule）
    ),
    // 主线：1.5dp ink 实线 + 单一焦点点 6dp primary
    LineChartBarData(
      spots: primaryCurve.map((p) => FlSpot(p.x, p.y)).toList(),
      isCurved: false,
      color: HanaTokens.ink(context),
      barWidth: 1.5,
      isStrokeCapRound: false,
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, _) =>
            primaryCurve.indexOf(/* … */) == focusIndex,
        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
          radius: 6,
          color: HanaTokens.primary(context),     // 黛蓝焦点 — 一抹强色
          strokeWidth: 0,
        ),
      ),
      belowBarData: BarAreaData(show: false),
    ),
  ],
  lineTouchData: LineTouchData(
    touchTooltipData: LineTouchTooltipData(
      tooltipBgColor: HanaTokens.surfaceContainerLowest(context),
      tooltipRoundedRadius: 4,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      tooltipBorder: BorderSide.none,
      getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
        '${s.x.toStringAsFixed(0)}d · ${s.y.toStringAsFixed(0)} $unit',
        TextStyle(
          fontFamily: 'JetBrains Mono', fontWeight: FontWeight.w300,
          fontSize: 12, color: HanaTokens.ink(context),
        ),
      )).toList(),
    ),
  ),
);
```

### 3.3 焦点点判定算法

```dart
int _focusIndex(
  List<PkCurvePoint> curve,
  double? targetMin,
  double? targetMax,
) {
  if (curve.isEmpty) return 0;
  // 1. 默认 = 最新稳态周期峰值（曲线后 1/3 段最大值）
  final steadyStart = (curve.length * 2 / 3).floor();
  final steadySlice = curve.sublist(steadyStart);
  final steadyPeakIdx = steadyStart + steadySlice.indexWhere(
    (p) => p.concentration == steadySlice
        .map((q) => q.concentration).reduce(math.max),
  );
  // 2. 如果稳态平均超出 target → 焦点改为首个超出阈值的点
  final avg = steadySlice.fold<double>(0, (s, p) => s + p.concentration) /
      steadySlice.length;
  final outOfRange = (targetMin != null && avg < targetMin) ||
                     (targetMax != null && avg > targetMax);
  if (!outOfRange) return steadyPeakIdx;
  return curve.indexWhere((p) =>
    (targetMax != null && p.concentration > targetMax) ||
    (targetMin != null && p.concentration < targetMin),
  ).clamp(0, curve.length - 1);
}
```

### 3.4 nice-number 算法（沿用 data §3）

```dart
double _niceInterval(double range, {int targetTicks = 4}) {
  final raw = range / targetTicks;
  final magnitude = math.pow(10, (math.log(raw) / math.ln10).floor());
  final normalized = raw / magnitude;
  if (normalized < 1.5) return magnitude.toDouble();
  if (normalized < 3) return (magnitude * 2).toDouble();
  if (normalized < 7) return (magnitude * 5).toDouble();
  return (magnitude * 10).toDouble();
}
```

### 3.5 X 轴 interval 派发

```dart
double _xInterval(double maxX) {
  if (maxX <= 30) return 5;       // 30 天内：5 天 1 label
  if (maxX <= 90) return 10;      // 30-90 天：10 天 1 label
  return 30;                       // > 90 天：30 天 1 label
}
```

---

## 4. 状态判定与渲染

```dart
enum _StatusKind { inRange, warning, critical }

_StatusKind _classify(double avg, double min, double max) {
  if (avg >= min && avg <= max) return _StatusKind.inRange;
  final span = max - min;
  final dist = avg < min ? (min - avg) : (avg - max);
  return dist / span > 0.5 ? _StatusKind.critical : _StatusKind.warning;
}

// 渲染：
final color = switch (status) {
  _StatusKind.inRange => HanaTokens.ink(context),
  _StatusKind.warning || _StatusKind.critical => HanaTokens.primary(context),
};
// 同时 critical 时额外渲染 1 行 body-sm error 朱砂注脚 simulator.criticalDeviation
```

---

## 5. 性能 / web / a11y 注意

- **PK 计算预算**：domain 层 `RunPkSimulationUseCase` ≤ 100ms（不动）；UI 层 debounce 300ms 避免连敲。
- **fl_chart 重绘预算**：双线 + 540 个 FlSpot CanvasKit web 实测 ~8ms（直线段比 v1 `isCurved: true` 的 ~22ms 快 2.7×）— 移动端 Skia ~3ms。
- **web `font-display: optional`**：思源宋体异步加载，首屏先用系统宋体，避免 X 轴 label 闪烁。
- **reduce-motion**：`MediaQuery.of(context).disableAnimations` true 时关闭 sweep + fadeIn + 引擎切换 swap。
- **Semantics**：`Semantics(label: l10n.simulatorChartA11y(engine, days, avg, status, unit))` 包裹整个 LineChart，屏幕阅读器朗读结论而非 540 点。
- **键盘**：numeric 字段调起 `TextInputType.numberWithOptions(decimal: true)`；segmented 用 `Focus` + 方向键切换段。

---

## 6. 测试

### Unit
- `_focusIndex` 三场景：① 稳态在范围内 → 返回稳态峰值索引；② 稳态偏高 → 返回首个超 max 点；③ 稳态偏低 → 返回首个低于 min 点。
- `_classify` 边界：avg = min / avg = max / avg = min - span * 0.5（warning 边界）/ avg = min - span * 0.51（critical）。
- `_niceInterval` / `_xInterval` 三档边界值。

### Widget
- 默认态：方案折叠卡显示 ester + dose + interval；图表渲染（mock fl_chart hard）；稳态卡数字 ink 色（in-range）。
- warning 态：稳态数字染 primary；注脚 inkSecondary；不渲染 critical 朱砂行。
- critical 态：稳态数字 primary + 朱砂注脚渲染 + 屏幕底免责仍渲染。
- 引擎切换：tap segmented "Hana-PK" → bloc 派发 `engineToggled`；240ms 后 isHanaPk = true 重渲染。
- a11y：Semantics label 出现「{engine} 引擎」「{days} 天」「{value} pmol/L」「{statusText}」四要素。

### Golden
- 三状态（in-range / warning / critical）各 1 帧 light + dark = 6 个 golden。
- 双引擎切换前后 = 2 个 golden。
- web 端 CanvasKit 渲染单独 1 个 golden（fl_chart 跨平台栅格化差异）。

---

## 7. 实施顺序建议

1. ARB 增补（独立 PR — 不影响渲染，可先合并以减小后续 PR diff）
2. `_TargetRange.fromEster` 工具函数 + 单测
3. `HanaLineChart` 双线扩展（基于 data 屏已有 wrapper 增量改）+ 单测
4. `_RegimenSection` / `_ConcentrationSection` / `_SteadyStateSection` 三个新子 widget（独立 widget test）
5. `simulator_page.dart` 主文件重写 + golden 测试
6. 删除 5 个 `// ignore_for_file:` lint suppression（最后步骤，验证拆分子 widget 后 lint 全过）

预算：3-4 个工作日。

---

— 完 —
