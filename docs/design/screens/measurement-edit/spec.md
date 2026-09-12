# Measurement Edit 屏 v2 视觉与流程规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + add-drug/spec.md
> 单页表单（不再核心 / 扩展折叠切换）
> 屏幕：`lib/features/measurement/presentation/pages/measurement_edit_page.dart`
> Pilot Wave: 阶段 3.4.b（新稿）
> 上游基准：`add-drug/spec.md`（表单 pattern）+ `measurement/spec.md`（主屏 mono 数值表）

---

## 1. 设计意图

Measurement Edit 是用户**主动索取的体型笔记表单**：用户在 Measurement 主屏点击「记一次」或某条记录的「编辑」进入。和 add-drug 是同一类「内文页表单」语法——hero 段落标记 + 单章节 + 9 个 mono 数值字段 + 日期 picker + 备注 + 底部 [取消 / 保存] 双按钮。

v1 用 `ExpansionTile` 把 9 项分成「核心 5 项」「扩展 4 项」——这是 dashboard 语法，预设「胸腰臀腿臂是重要的，下胸围肩宽颈围体重是次要的」。v2 移除分类，9 项一次性平铺，让用户自己决定填哪些。也移除 `MeasurementTypeIcon`（人体部位象形 icon）——文字 label 已足够，且象形 icon 隐含性别符号有 critique 风险。

文案调性：第三人称 + 句号 + 零 emoji。AppBar 标题「记一次。」/ 章节「数据。」「日期。」「备注。」/ 单位用 `(cm)` `(kg)` 内嵌 label。

---

## 2. 单屏结构

### 2.1 ASCII Wireframe

```
┌────────────────────────────────────────┐
│ ←                                      │  ← AppBar: ghost back，无 title 实词
│                                        │     spacing.lg (32) 顶部留白
│                                        │
│ │ 记一次。                             │  ← display 32 + 4px 黛蓝竖线（hero）
│   把今天的样子记下来。                 │  ← body-sm 淡墨副文
│                                        │  spacing.xl (64)
│                                        │
│ │ 日期。                                │  ← title 18 段落标记（无竖线）
│   ─────                                │
│   2026 / 04 / 29                  ▾   │  ← mono 14 数值（点击触发 picker）
│                                        │  spacing.lg (32)
│                                        │
│ │ 数据。                                │  ← title 18 段落标记（无竖线）
│                                        │
│   胸围 (cm)                            │  ← label 12·+0.6
│   ─────                                │
│   88.5                                 │  ← mono 14 输入文字
│                                        │  spacing.md (16)
│   下胸围 (cm)                          │
│   ─────                                │
│                                        │  ← 留空
│                                        │  spacing.md (16)
│   腰围 (cm)                            │
│   ─────                                │
│   64                                   │
│                                        │  spacing.md (16)
│   臀围 (cm)                            │
│   ─────                                │
│   90                                   │
│                                        │  spacing.md (16)
│   大腿围 (cm)                          │
│   上臂围 (cm)                          │
│   肩宽 (cm)                            │
│   颈围 (cm)                            │
│   体重 (kg)                            │
│   [...同模板]                           │
│                                        │  spacing.lg (32)
│                                        │
│ │ 备注。                                │
│   ┌────────────────────────────┐       │  ← multiline 3 行起
│   │                            │       │
│   │                            │       │
│   └────────────────────────────┘       │
│                                        │  spacing.xl (64)
│                                        │
│   [取消]              [保存。]          │  ← ghost + primary
│                                        │     左右各 32px 对齐，非全宽
│                                        │     SafeArea bottom
└────────────────────────────────────────┘
```

### 2.2 顶部区

- **AppBar**: `HanaTopBar.defaultBar` 仅 leading ghost back（icon-only）+ `surfaceContainerHigh` 实色 + 滚动 0.5px outline。**无 trailing**——保存按钮在底部，不重复入口。
- **Hero 段**: 顶部 `lg=32` + display 32 宋体「记一次。」+ 4px 黛蓝竖线（**唯一稳态强色 #1**）+ body-sm 副文「把今天的样子记下来。」inkSecondary。右侧 96px+ 留白。

### 2.3 表单段落

3 章节：日期。 / 数据。 / 备注。
- 仅 hero 标题加 4px 黛蓝竖线（沿用 add-drug spec §2.3 决策：段落竖线**经济使用**，避免一屏 3 处稳态 + button = 4 处超原则 1）
- 后两章节用 `title 18` 黑墨宋体 + spacing.lg=32 跨级分隔，**不带**竖线
- 字段内 `spacing.md=16` / 章节间 `spacing.lg=32`

| 章节 | 字段 | Variant | 默认 |
|------|-----|---------|-----|
| 日期。 | 日期 | `HanaInput`-style 触发 `HanaBottomSheet.picker` 内嵌日期 picker | 今天（编辑态：原值）|
| 数据。 | 9 项数值 | `HanaInput.numeric`（mono Light + label 内嵌单位）| 全空（编辑态：原值）|
| 备注。 | 备注 | `HanaInput.multiline` minLines=3 | 空（编辑态：原值）|

### 2.4 底部按钮区

- 距上 `xl=64` + SafeArea bottom
- 左 `HanaButton.text` (ghost variant) "取消"
- 右 `HanaButton.primary` "保存。"（**唯一稳态强色 #2**）
- 两按钮各左右对齐 32px，**不**全宽

---

## 3. 日期 Picker（HanaBottomSheet.picker）

### 3.1 触发
点击日期字段 → `HanaBottomSheet.show(context, sheet: HanaBottomSheet(title: l10n.measurementEditDateSheetTitle, child: _DatePickerInline(initial: _date), maxHeightFraction: 0.6))`

**禁** `showDatePicker`（Material Calendar 弹层）—— 与 add-drug spec §2.3 同决策。

### 3.2 Sheet 内嵌日期 picker

```
        ───────                           ← drag handle
   选日子。                                 ← headline 24
                                            spacing.md (16)
   ┌──────────────────────────────┐
   │  ‹    2026 年 4 月        ›  │       ← title 18 + ghost prev/next
   │                              │
   │  日 一 二 三 四 五 六        │       ← label 12·+0.6 inkSecondary
   │  -- -- -- 1  2  3  4         │
   │   5  6  7  8  9 10 11        │
   │  12 13 14 15 16 17 18        │
   │  19 20 21 22 23 24 25        │
   │  26 27 28 29 30 -- --        │       ← mono 14 ink；选中日 黛蓝实色背景
   └──────────────────────────────┘
                                            spacing.lg (32)
   [ 用此日 ]   HanaButton.primary
   [ 取消 ]     HanaButton.ghost
```

- 选中日：背景 `primary` 实色 + onPrimary 文字（**sheet 内可见时算稳态强色 #3**——sheet 升起时主屏 hero 竖线 + 保存按钮 + 此选中日 = 3 处，处于硬上限）
- 范围：`firstDate=DateTime(2000)` / `lastDate=DateTime.now().add(Duration(days: 1))`（与 v1 一致；允许「明天」备用）

---

## 4. 组件映射

| 元素 | v1 inline 实现 | v2 组件 | tokens |
|------|---------------|--------|--------|
| AppBar back | `Scaffold.appBar.title` 字符串 (L73-75) | `HanaTopBar.defaultBar` ghost back only | `r-button=6` · ghost |
| Hero 标题 | (v1 用 AppBar 标题) | `display 32` 墨色宋体 + 4px 黛蓝竖线 | `display` · `ink` · `primary`(竖线) |
| 章节段落标记（日期 / 备注） | (v1 用 ExpansionTile / Card 标题) | `title 18` 墨色宋体（**无**竖线，spacing.lg 跨级分隔） | `title` · `ink` |
| 章节段落标记（数据） | `coreMeasurements` 标题 (L86) + ExpansionTile 标题「扩展指标」(L92) | 合并为「数据。」 `title 18` 墨色宋体（**无**竖线）+ 9 项一次性展开 | 同上 |
| 日期 picker 触发 | `_DatePickerTile` ListTile + `Icons.calendar_month` + chevron + `showDatePicker` (L210-232) | `HanaInput`-style 行：label「日期」+ mono 14 数值「2026 / 04 / 29」+ ghost ▾，触发 `HanaBottomSheet.picker` | `mono` · `r-input=2` |
| 数值字段 | `TextField + OutlineInputBorder + prefixIcon: MeasurementTypeIcon` (L293-302) | `HanaInput.numeric` label内嵌单位 (cm/kg)，**无 prefixIcon** | `body-sm` label · `mono` 输入 · `outline`(idle 1px) / `primary`(focus 2px) · `r-input=2` |
| 数值 prefixIcon | `MeasurementTypeIcon` 9 种装饰图标 (widget) | **删除**（原则 5） | — |
| 备注字段 | `TextField + OutlineInputBorder + maxLines: 3` (L113-120) | `HanaInput.multiline` minLines=3 maxLines=∞ | 同上 |
| ExpansionTile | L91-111 | **删除**（无折叠，9 项一次性展开） | — |
| Card 容器 | `Card(surfaceContainerLowest)` × 3 (L94, L221, L249) | **删除**（无独立卡，靠章节标题 + spacing.lg 分组） | — |
| 保存按钮 | `FilledButton` 全宽 r-default (L122-138) | `HanaButton.primary` 非全宽 + "保存。" | `primary` · `r-button=6` |
| 取消按钮 | (v1 无 — 仅系统返回) | `HanaButton.text` (ghost) | ghost variant |
| Validation error | (v1 无) | `HanaInput.errorText` body-sm inkSubdued（**不**红色） | `body-sm` · `inkSecondary` |
| Saving spinner | inline `CircularProgressIndicator` 在按钮内 (L130-134) | `HanaButton.primary(loading: true)` 内置 spinner（黛蓝色 strokeWidth 2）| `primary` |

---

## 5. Tokens 引用清单

**Colors**:
- `background` 月白 — Scaffold
- `surfaceContainerHigh` 米灰 — AppBar
- `ink` 墨色 — Hero 标题 + 章节标题 + 输入文字 + 选中日 onPrimary 反白
- `inkSecondary` 淡墨 — 副文 + label + helperText + 单位标记 + validation error
- `primary` 黛蓝 — **每屏 ≤ 3 处稳态**：① hero 竖线 ② 保存按钮 ③ sheet 内选中日（仅 sheet 打开时）— input focus 2px 瞬时不计
- `outline` 烟灰 — `HanaInput` idle 底线 1px

**Typography**:
- `display` 32 — Hero「记一次。」
- `title` 18 — 章节段落标记（日期。 / 数据。 / 备注。）
- `body` 15 — 备注 textarea 输入
- `body-sm` 13 — 副文 / helperText / validation error
- `label` 12·+0.6 — `HanaInput` label（含 `(cm)` `(kg)` 单位内嵌）
- `mono` 14 — 9 项数值输入 + 日期数值

**Spacing**:
- `xl` (64) — Hero ↔ 首章节 / 末章节 ↔ 按钮 / 屏顶留白
- `lg` (32) — 章节间 / 屏幕水平 padding / 章节标题 ↔ 首字段
- `md` (16) — 字段间 / 备注 textarea 上下 padding
- `sm` (8) — date picker sheet 行间
- `xs` (4) — label ↔ input 底线

**Radius**: `r-input=2` · `r-button=6` · `r-bottom-sheet=16`(顶角)

**Motion**:
- `motion-instant` (80ms) — input focus 1→2px 呼吸线
- `motion-quick` (150ms) — `HanaButton` press scale 0.98
- `motion-standard` (240ms) — bottom sheet 升起 / 日期切月动画

---

## 6. 交互状态

- **HanaInput focus**: 80ms 1→2px primary 呼吸线
- **数值字段**: 仅接受数字 + 小数点；输入用 `keyboardType: numberWithOptions(decimal: true)`；mono 字体显示输入文字
- **日期 picker**: tap 行 → `HanaBottomSheet.picker` 内嵌日期；点「用此日」→ sheet dismiss + setState 字段值 mono 重渲染（80ms instant）
- **保存按钮**:
  - **disable**: 当 `_controllers.values.every((c) => c.text.trim().isEmpty)`（9 项全空时禁用——避免空记录入库；备注非空但数值全空也禁用）
  - **enable**: 至少 1 项数值非空
  - **loading**: `state is MeasurementSaving` 时显示 spinner，按钮 disable
  - tap → bloc.add(SaveMeasurement(entry)) → `state is MeasurementSaved` → `Navigator.pop(true)`
- **取消按钮**: 直接 `Navigator.pop()` 不弹确认 dialog（与 add-drug 同决策——measurement 也是低破坏性）
- **物理返回键**: 等价取消
- **错误反馈**: `state is MeasurementError` → `HanaToast.error(message)`（替换 v1 的 SnackBar）

---

## 7. 断点行为

| 断点 | 行为 |
|------|------|
| mobile (< 600dp) | 全宽，水平 padding 32 |
| tablet (600-1024dp) | 居中宽度 480，左右大留白 |
| web ≥ 1024dp | 居中宽度 720，左右各 ≥ 152 留白 |

---

## 8. i18n 注意

- 9 项术语 ARB key 复用 measurement 主屏（见 measurement/handoff.md §4 表）
- ja「胸まわり (cm)」label 较长——HanaInput label 单行允许 1.5 行环绕
- 「数据。」zh / ja 都为「数据。」/「データ。」/ en「Data.」
- 单位 `(cm)` `(kg)` **不本地化**（国际单位）
- 日期 picker sheet 标题：zh「选日子。」/ ja「日付を選ぶ。」/ en「Pick a date.」
- 副文「把今天的样子记下来。」/ ja「いまのからだを記す。」/ en「Note today's shape.」

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 | ✓ — HanaInput 最小 48dp / 按钮 44dp / 日期触发行 ≥ 48dp |
| 焦点顺序 | AppBar back → Hero → 日期 → 9 项数值（按 enum order） → 备注 → 取消 → 保存 |
| Bottom sheet 焦点 trap | 进入 sheet 焦点到首日 / 首按钮；ESC / 物理返回关闭 |
| `prefers-reduced-motion` | bottom sheet 240ms → 0ms 直显；input focus 1→2 微动可保留 |
| Screen reader | validation error 用 `Semantics(liveRegion: true)` 朗读；数值字段 `Semantics(textField: true, label: "{type} {unit}")` 把单位拼进 label |
| 数值字段单位歧义 | label「胸围 (cm)」+ `Semantics(value: "{value} 厘米")` 双重保障 |
| 对比度（light）| ✓ — ink 14.8:1（AAA） |
| 对比度（dark）| ✓ — 12.6:1 |

---

## 10. 自我 critique-v2

| 原则 | 自审结果 | 落点 |
|------|---------|------|
| 1. 一抹强色 | ✅ hero 竖线 + 保存按钮 = 2 处稳态；sheet 内选中日 +1 处仅在打开时；input focus 瞬时不计 | §5 |
| 2. 调和层次胜过投影 | ✅ 全屏 elev-0；删除 Card / ExpansionTile；bottom sheet `elev-high`（唯一允许）；零 BackdropFilter；零渐变 | §4 |
| 3. 编辑级不对称 | ✅ Hero 左对齐 32px；按钮非全宽；段落竖线仅覆盖 hero 首行；右侧 ≥ 96px 留白；9 项数值左对齐字段 | §2 |
| 4. 慢节奏与留白 | ✅ Hero ↔ 首章节 xl=64；章节间 lg=32；字段间 md=16，跨级合规 | §5 |
| 5. 内容即装饰 | ✅ 删除 `MeasurementTypeIcon`（9 处装饰图标）；按钮文案句号收尾；validation 用 inkSubdued 不用红色；零 emoji | §4 |

**残留风险**：
- 9 项一次性展开后表单较长（垂直滚动 ~3 屏）。决策：保留——杂志表单不分页，让用户自由滚动；备注在末尾保证写完才看到「保存」CTA，反向作为「写慢一点」的节奏暗示。
- 编辑态 `existingEntry != null` 时 Hero 标题文案应否改为「改一改。」？v2 决策：**统一「记一次。」**——编辑也是「记下当下」，不二态切换 hero 文案，避免 ARB 冗余。
- 日期 picker 内嵌 `HanaBottomSheet.picker` 而非系统 `showDatePicker`——若工程层 sheet 内日历组件未抽出，临时方案是 `HanaBottomSheet` 容纳 `CalendarDatePicker(theme: HanaCalendarTheme)`（详 handoff §3）。

---

## 11. 节奏与停顿

- **进入屏**: `context.push('/measurement/edit')` → motion-standard 240ms slideUp
- **打开日期 sheet**: 字段 tap → 240ms easeInOut + scrim 淡入
- **选中日切换**: 点击日期 → 80ms instant 选中态切换；点击「用此日」→ sheet dismiss 240ms + 字段 mono 数值 80ms 替换
- **数值输入**: 用户输入时 mono 字体即时渲染，**无**字符级动画
- **保存**: tap → press scale 0.98 → bloc 派发 → `MeasurementSaved` → `Navigator.pop(true)` 直回主屏；**不**触发庆祝（ritual 留给「记一次」服药动作，不在 measurement edit）
- **错误**: `MeasurementError` → toast 240ms 升起 + 1.6s hold + 240ms 淡出（`HanaToast.error`）

— 完 —
