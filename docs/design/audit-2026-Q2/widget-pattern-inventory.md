# HanaNote 跨屏 Widget 模式盘点

**版本**: v1.2.2 / Phase 2.1 prep
**扫描范围**: `lib/features/{auth,blood_test,journal,knowledge,measurement,medication,notification,photo,settings,simulator,timeline}/presentation/**/*.dart`（不含 `*.freezed.dart` / `*.g.dart`）
**屏幕基数**: 21 个 page（11 个 feature module）+ 7 个 feature-local widget
**当前共享组件**: 仅 `lib/core/widgets/petal_celebration.dart`（1 个）

---

## 1. Top 20 抽象候选（按优先级）

| # | 模式名 | 出现次数 | 变体数量 | 屏幕分布 | 当前实现位置 | 抽象建议 | 优先级 |
|---|--------|---------|---------|---------|------------|---------|-------|
| 1 | Loading State | 18 | 4 | today / drug_list / inventory / measurement / measurement_edit / blood_test_data / blood_test_edit / journal / journal_edit / record / photo / photo_view / settings / profile / notification / timeline / simulator / knowledge / lock / schedule_editor | 各页面散落 `Center(child: CircularProgressIndicator())`，颜色与 strokeWidth 不一 | `HanaLoadingView({color, size, message?})` | P0 |
| 2 | Empty State | 8 | 3 | timeline_page:206、measurement_page:89、photo_page:210、blood_test/data_page:960、today_page:228、record_page（无内容态文案） | inline `Center(Column(Container+Icon+Text+Text))` 或纯 `Center(Text)` | `HanaEmptyState({icon, title, message?, action?, size?})` | P0 |
| 3 | Error State + Retry | 6 | 3 | photo_page:264 (`_PhotoErrorState`) / today_page:203 / profile_page:160 / settings_detail / knowledge_webview / timeline:105 (text-only) | 三种风格：图标+按钮 / 仅 Text / Text+按钮；retry label 全部走 `l10n.retry` | `HanaErrorState({message, onRetry, retryLabel?, icon?})` | P0 |
| 4 | Section Card / Surface Container | 14 | 5 | blood_test_edit:512 (`_CardWrapper`) / settings_detail:575 (`_SettingsCard`) / measurement_edit:221,249 / today_page 中各小卡片 / record_page:309 / inventory_page:79 / drug_card.dart:31 / data_page:960 | `Container+BoxDecoration(surfaceContainerLowest, radius 16~24, optional shadow)` 反复 inline；3 个 feature 各自定义私有 `_CardWrapper`/`_SettingsCard`/`_StitchHistoryCard` | `HanaCard({child, padding?, onTap?, elevation?, borderRadius?, variant: flat / elevated / outlined})` | P0 |
| 5 | Glass / Blur AppBar | 6 | 1 | timeline_page:35 / settings_detail:33 / blood_test/data_page:36 / journal/record_page:77 / notification_settings_page:31 / profile_page:218 / legal_page:54 / knowledge_webview:90 | `PreferredSize > ClipRRect > BackdropFilter(blur 12) > AppBar(backgroundColor.withAlpha(0.8*255))` 整段被复制 | `HanaGlassAppBar({title, actions?, leading?, blurSigma?})` | P0 |
| 6 | Card-style TextField (`_CardWrapper`-wrapped TextField) | 9 | 3 | blood_test_edit:307,331 / measurement_edit:113,293 / journal_edit:154 / schedule_editor:123 / setup:120,141 / onboarding:319,531 | `Container/Card + Padding + TextField(border: InputBorder.none, prefixIcon)` | `HanaTextField({controller, label, prefixIcon?, suffixIcon?, multiline?, keyboardType?})` | P0 |
| 7 | Confirm Dialog (Cancel + Confirm 双按钮) | 8 | 2 | measurement_page:198 / photo_view:242 / photo_page:154 / drug_list:129 / inventory:171 / settings_detail:488 / profile_page:64,448 | `AlertDialog(title, content, [TextButton(cancel), FilledButton/TextButton(confirm)])` | `HanaConfirmDialog.show({title, message, confirmLabel, cancelLabel?, isDestructive?})` 返回 `Future<bool?>` | P1 |
| 8 | Bottom Sheet (Action Picker) | 4 | 3 | timeline_page:121 (Add Event) / photo_page:181 (Pick Photo Source) / dose_action_sheet (Dose Confirmation) / settings_detail:413 | 都用 `showModalBottomSheet` + 顶部 drag handle / SafeArea / ListTile 列表；handle 仅 timeline 实现 | `HanaActionSheet.show({title?, items: List<HanaActionItem>})` + `HanaBottomSheetScaffold` 基础壳 | P1 |
| 9 | Pill Chip / Status Badge | 11 | 4 | drug_card:111 (`_buildChip`) / data_page:344 (status pill) / data_page:927 (reading badge) / inventory_page:130 (low stock pill) / onboarding:440 (HRT day pill) / data_page:927 / today_page:374 (status card) | `Container(padding 8x4, decoration: color.withAlpha(25), radius 8/9999)`，颜色和 radius 不统一 | `HanaPill({label, color?, icon?, variant: tinted / outlined / solid})` | P1 |
| 10 | Tappable Scale Card (按下缩放动画) | 4 | 1 | data_page:257 (`_StitchHormoneCard`) / data_page:847 (`_StitchHistoryCard`) / record_page:261 (`_StitchRecordCard`) | 三处近乎逐字复制 `AnimationController(duration:150ms) + Tween(1→0.95/0.98) + GestureDetector(onTapDown/Up/Cancel)`；目前在三个文件中是三套独立 State 类 | `HanaPressScale({scaleTo: 0.97, duration: 150ms, child, onTap})`（也可 mixin） | P1 |
| 11 | Primary CTA Button (52px 圆角 16) | 5 | 2 | onboarding_page:176,195,225 (3 处) / setup_page:174 / today_page:212 / measurement_edit:125 | `SizedBox(width: ∞, height: 52, child: FilledButton(style: FilledButton.styleFrom(backgroundColor, shape: RoundedRectangleBorder(radius: 16))))` | `HanaPrimaryButton({label, onPressed, icon?, isLoading?, fullWidth?})` | P1 |
| 12 | Switch Tile (List 行 + Switch) | 7 | 2 | settings_detail:153,176,192,213 / profile_page:411 / drug_card:75 / notification:116,312 / setup_page:164 (`SwitchListTile.adaptive`) | 多数为手写 `Row(Text + Switch)`；只有 setup_page 用了 `SwitchListTile.adaptive` | `HanaSwitchTile({title, subtitle?, value, onChanged, leading?})` | P1 |
| 13 | Date Picker Trigger Tile | 4 | 2 | blood_test_edit:277 (`_buildDateField`, ListTile 包裹) / schedule_editor:191,226 / settings_detail:530 / measurement_edit:147 / onboarding:396 (大圆角自定义卡) / timeline:61 (icon button) | `showDatePicker` 直调 + 各页自己显示 selected 日期 | `HanaDateField({label, value, onChanged, firstDate?, lastDate?, format?})` | P1 |
| 14 | Bottom Action Bar (Save / Cancel 行) | 5 | 2 | journal_edit:200 (AnimatedContainer) / measurement_edit:125 (FilledButton + spinner) / blood_test_edit:240 (CircularProgress) / schedule_editor:248 / add_drug:417 | 都是底栏粘性按钮 + 提交时 spinner 替换 label | `HanaSubmitBar({onSave, isLoading?, saveLabel?, secondaryAction?})` | P2 |
| 15 | Hero Card (Gradient Feature CTA) | 2 | 1 | data_page:401 (`_StitchSimulatorCard`) / data_page:489 (`_StitchKnowledgeCard`) | 两个完全镜像的 gradient + circle icon + 右箭头卡 | `HanaFeatureCard({gradient, icon, title, subtitle, onTap})` | P2 |
| 16 | Choice / Filter Chip Row | 5 | 1 | dose_action_sheet:81,98 / add_drug:382,398 / schedule_editor:149 | 都是 `Wrap > .map((e) => ChoiceChip(selected, onSelected))` | `HanaChoiceChips<T>({values, selected, onChanged, labelBuilder})` | P2 |
| 17 | DropdownField (with OutlineInputBorder) | 4 | 1 | dose_action_sheet:110,123 / blood_test_edit:411 / simulator:247 / onboarding:553,588 | `DropdownButtonFormField(decoration: OutlineInputBorder)` 每处自己写 itemBuilder | `HanaDropdownField<T>({label, items, value, onChanged, itemLabel})` | P2 |
| 18 | Chart Container (fl_chart 包装) | 2 | 2 | data_page:711 (LineChart trend with gradient) / simulator:438 (LineChart with thresholds) | 两屏各写一份 `LineChartData` + 网格 / 标签 / dot 样式；样式 token 类似（dashArray、dot radius 4、颜色） | `HanaLineChartCard({series, xLabelBuilder, yLabelBuilder, height?, threshold?})` | P2 |
| 19 | Snackbar Helper | 18 | 2 | profile_page:23 (`_showSnackBar`) / measurement / blood_test_edit / settings_detail (含 floating) / photo / auth_wrapper / schedule_editor | 一半 default / 一半 floating；profile_page 自己写过 helper | `HanaSnackbar.show(context, message, {variant: info / success / error, action?})` | P2 |
| 20 | Status Color Pill (low-stock / warning / out-of-range) | 6 | 2 | data_page:166 (warning_amber) / inventory:143 (low stock) / settings_detail:377 (system status) / profile_page:441 (warning) / data_page:344 (subtitle pill) | 均为 `Container(errorContainer/primaryContainer + Icon + Text)` | `HanaStatusBadge({label, status: info / warning / error / success, icon?})` | P2 |

---

## 2. 详细模式分析

### 模式 1：Loading State（P0）
- **出现位置**: 18 个文件，覆盖所有 11 个 feature module
- **当前变体**:
  - 默认 `CircularProgressIndicator()`（无颜色）：`photo_page.dart:61`、`simulator_page.dart:81-82`、`auth_wrapper:83`、`drug_list:39`、`inventory:42`、`schedule_editor:59`、`measurement_page:48,52`、`blood_test_edit:256`
  - 带主色 `CircularProgressIndicator(color: HanaColors.primary)`：`timeline:103`、`profile_page:193`、`record_page:32`、`knowledge_webview:70,133`、`notification_settings:64`、`data_page:74`
  - 细化版 `strokeWidth: 2 / 2.5`：`photo_view_page:78`、`measurement_edit:133`、`blood_test_edit:240`、`journal_edit:131`、`photo_page:405`
  - 反向色（白色 over dark）：`photo_view_page:209`
- **共同点**: 居中、单一 spinner、出现在异步等待的整页或局部
- **差异点**: 颜色使用习惯不一（一半带主色一半默认）、strokeWidth 不一、是否 `SliverFillRemaining` / `Center`
- **抽象 API 建议**:
  ```dart
  class HanaLoadingView extends StatelessWidget {
    const HanaLoadingView({
      this.message,
      this.size = HanaLoadingSize.medium,
      this.useSliverFill = false,
      super.key,
    });
    final String? message;       // 可选副文案，例如 "Loading..."
    final HanaLoadingSize size;  // small=24 / medium=36 / large=48
    final bool useSliverFill;    // 在 CustomScrollView 中自动用 SliverFillRemaining
  }
  ```
- **i18n 注意**: `message` 由调用方传 ARB key 的解析结果，组件不内置任何文案

### 模式 2：Empty State（P0）
- **出现位置**: 8 处显式 + 4 处 inline 文本
  - `measurement_page.dart:89` `_MeasurementEmptyState`（圆形容器 + Icon 56px + 标题 + 副标题）
  - `photo_page.dart:210` `_PhotoEmptyState`（同样结构 + lock icon）
  - `today_page.dart:228` inline（icon 64 + Title + FilledButton.icon CTA）
  - `data_page.dart:960` `_EmptyHistoryCard`（Container + 灰边 + 居中 Text，无图标）
  - `timeline_page.dart:206` 仅 `Center(Text(emptyLabel))`
  - `record_page.dart` 用 mood/photo/measure 三种空文案 inline 在卡片内
- **共同点**: 居中、ICON + 主文案 + 可选副文案 + 可选 CTA
- **差异点**:
  - 图标尺寸：56 / 64
  - 图标背景：圆形 container 带 alpha 容器色 / 无背景
  - CTA：FilledButton.icon / 无
  - 是否有副文案：4 处有，4 处无
- **抽象 API 建议**:
  ```dart
  class HanaEmptyState extends StatelessWidget {
    const HanaEmptyState({
      required this.icon,
      required this.title,
      this.message,
      this.action,
      this.size = HanaEmptyStateSize.medium,
      super.key,
    });
    final IconData icon;       // 例: Icons.medication_outlined
    final String title;        // 来自 ARB
    final String? message;
    final Widget? action;      // 例: HanaPrimaryButton
    final HanaEmptyStateSize size;  // small / medium / large 控制 icon + container 尺寸
  }
  ```
- **i18n 注意**: title/message 必须从 ARB 取；图标来自调用方（不同领域用不同图标）；副文案对齐居中

### 模式 3：Error State + Retry（P0）
- **出现位置**:
  - `photo_page.dart:264` `_PhotoErrorState`（最完整：Icon + Text + FilledButton）— 这是事实上的 reference impl
  - `today_page.dart:203` inline error 文本 + ElevatedButton
  - `profile_page.dart:160` Text + ElevatedButton
  - `settings_detail_page.dart:303,377` SnackBar 风格的错误反馈
  - `knowledge_webview_page.dart` 文本（无重试）
  - `timeline_page.dart:105` 仅 `Center(Text(message))`
- **共同点**: 错误图标（可选）+ 文案 + 重试按钮（可选）
- **差异点**: ElevatedButton vs FilledButton；带图标 vs 不带；retry 文案统一从 `l10n.retry` 来
- **抽象 API 建议**:
  ```dart
  class HanaErrorState extends StatelessWidget {
    const HanaErrorState({
      required this.message,
      this.onRetry,
      this.retryLabel,        // 默认调 l10n.retry，但 widget 库不能依赖 l10n -> 必传
      this.icon = Icons.error_outline,
      super.key,
    });
  }
  ```
- **i18n 注意**: 组件不内置 "Retry" 文案，由调用方传 `l10n.retry`

### 模式 4：Section Card / Surface Container（P0）
- **出现位置**: 14+ 处，至少 3 个 feature 各自定义私有变体
  - `blood_test_edit:512` `_CardWrapper`（surfaceContainerLowest + radius 16 + 浅 shadow）
  - `settings_detail:575` `_SettingsCard`（surfaceContainerLowest + radius 24 + 浅 shadow）
  - `data_page:832` `_StitchHistoryCard`（surfaceContainerLowest + radius 24 + shadow）
  - `measurement_page:143` 直接 `Card(color: surfaceContainerLowest)`
  - `today_page` 多种 inline
- **共同点**: surfaceContainerLowest 背景色 + 圆角（16 或 24） + 弱阴影
- **差异点**: 圆角值（12/16/24）、阴影强度、padding（16/20/24）、是否 InkWell 包裹
- **抽象 API 建议**:
  ```dart
  class HanaCard extends StatelessWidget {
    const HanaCard({
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.onTap,
      this.variant = HanaCardVariant.flat,  // flat / elevated / outlined
      this.borderRadius,                    // 默认 token，调用方可覆盖
      super.key,
    });
  }
  ```
- **i18n 注意**: 无文案，纯容器

### 模式 5：Glass / Blur AppBar（P0）
- **出现位置**: 6 个屏幕完整复制同样片段（timeline / settings_detail / data_page / record_page / notification / profile / legal / knowledge_webview）
- **共同片段**:
  ```dart
  PreferredSize(
    preferredSize: const Size.fromHeight(64),
    child: ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppBar(
          backgroundColor: HanaColors.background.withAlpha((255 * 0.8).round()),
          ...
        ),
      ),
    ),
  )
  ```
- **差异点**: 仅 title / actions / leading 不同，blur 强度和 alpha 全部一致
- **抽象 API**:
  ```dart
  class HanaGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
    const HanaGlassAppBar({
      required this.title,
      this.actions,
      this.leading,
      this.blurSigma = 12.0,
      this.backgroundOpacity = 0.8,
      super.key,
    });
  }
  ```
- **i18n 注意**: title 由调用方传

### 模式 6 / 7 / 8 / 9 / 10
（同上结构略，详见 §1 表格 API 列）

---

## 3. 不抽象的反例

| 模式 | 出现位置 | 不抽象原因 |
|-----|---------|----------|
| `progress_ring.dart` 服药进度环 | `medication/widgets/progress_ring.dart` | 这是一个领域特化的可视化（中央百分比 + 环形进度），仅 `today_page` 使用；逻辑与剂量服药率耦合，抽到 core 反而需要把领域语义剥离，得不偿失 |
| `petal_celebration.dart` 樱花庆祝 | 已在 `core/widgets/` | 已经是 P0 共享件，不需要再"抽" |
| `_StitchSimulatorCard` / `_StitchKnowledgeCard` | `blood_test/data_page` | 表格中我列为模式 15（Hero Card）— 但**目前只有 2 处使用**，介于"应该抽"和"等第三个出现再抽"之间；建议 v1.1 再抽，现阶段保留在 data_page |
| `lock_screen_page` 数字键盘 | `auth/lock_screen_page.dart:33` | PIN 键盘是 auth 高度领域特化件（数字 0-9 + delete），其他模块不会用；Material 3 也无对等组件；保留 |
| 注射部位选择 ChoiceChip | `dose_action_sheet:81,98` | 虽然结构与模式 16 一致，但选项内容（InjectionSite / PatchSite enum）是医疗领域；但模式 16 的抽象层只到"ChoiceChip Wrap"层即可，enum 由调用方注入，所以这个反例的反例其实可以走模式 16 |
| `measurement_type_icon.dart` | `measurement/widgets/` | 把 enum 映射到图标，是领域查表；保留 feature-local |

---

## 4. 给阶段 2.1 的优先级建议

基于"出现频次 × 改动放大效应 × i18n / theme token 暴露面"，**v1 组件库优先实现 8 个**：

### v1.0（必做，覆盖所有屏的基础态）
1. **HanaLoadingView**（18 处使用，0 风险）
2. **HanaEmptyState**（8 处，规范图标 + 文案 + CTA 三段式）
3. **HanaErrorState**（6 处，统一重试交互）
4. **HanaCard**（14+ 处，干掉 3 个 feature 各自的 `_CardWrapper`/`_SettingsCard`/`_StitchHistoryCard` 重复实现）
5. **HanaGlassAppBar**（6 处逐字复制的 BackdropFilter，是阶段 2.1 主题改色后**最容易留旧值的硬编码点**）

### v1.1（高 ROI 表单 / 弹层规范）
6. **HanaTextField**（9 处自定义包装，统一 prefixIcon / 圆角 / 边框）
7. **HanaPrimaryButton**（5 处 52px 高度圆角 16 的 CTA，落地"按钮 token"的载体）
8. **HanaConfirmDialog**（8 处 AlertDialog 复制）

### 后续（v1.2+）
- 模式 8（ActionSheet）/ 9（Pill）/ 10（PressScale）/ 12（SwitchTile）建议在 v1 落地后再做，因为它们要么变体多（Pill 4 种）要么有动画状态（PressScale）要么需要先确定 list-style 规范（SwitchTile）
- 模式 18（ChartCard）建议放到 Phase 2.2 一起做：v2.1 阶段先把图表 token 沉淀，v2.2 再封容器
- 模式 19（Snackbar）可以走简单 `static` helper，不需要 widget

### 落地建议
- **目录结构**: `lib/core/widgets/` 下按"原子 / 分子"分两层。原子（Card / Pill / Button / TextField）放根，组合（EmptyState / ErrorState / GlassAppBar / SubmitBar）单独子目录
- **命名前缀**: 全部 `Hana` 前缀，避免与 `material.Card / Switch` 同名
- **i18n 边界**: 组件层**不依赖 `AppLocalizations`**，所有文案参数由调用方传入（与 `enum_l10n.dart` 的 `localizedName(l10n)` 模式一致 — DEC-042/043）
- **测试基线**: 每个 v1 组件写 1 golden test + 1 widget test（参数化、tap、a11y label）；融入现有 323 个测试基线

### 改动放大效应估算
- 抽完 v1 这 5 个组件，预期能消除 **约 70 处 inline 实现**，减少 `lib/features` 中 ~1200 LOC 的复制；更重要的是 Phase 2.1 的色彩 / 圆角 / 阴影 token 改一次就 21 屏全部生效，而不是逐屏修复
- v1 + v1.1 共 8 个组件，预期消除 ~95 处 inline，覆盖**全部基础态 + 表单 + 弹层**三大高频面

---

**附录：文件级唯一引用统计（用于 PR 拆分）**

P0 五件命中率最高的 5 个文件（首批迁移目标）：
1. `features/blood_test/presentation/pages/data_page.dart`（5/5 命中）
2. `features/medication/presentation/pages/today_page.dart`（4/5 命中）
3. `features/settings/presentation/pages/settings_detail_page.dart`（4/5 命中）
4. `features/timeline/presentation/pages/timeline_page.dart`（4/5 命中）
5. `features/photo/presentation/pages/photo_page.dart`（4/5 命中）

建议按上述顺序提 5 个独立 PR，每 PR 触发 1 个 feature 的迁移，便于 code review 和回滚。
