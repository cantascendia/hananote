# Blood Test Edit 屏 v2 视觉与流程规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/ + screens/data/spec.md + screens/add-drug/spec.md
> 屏幕：`lib/features/blood_test/presentation/pages/blood_test_edit_page.dart`
> Pilot Wave: 阶段 3.4.b（新稿）
> 配对 handoff：`docs/design/screens/blood-test-edit/handoff.md`

---

## 1. 设计意图

Blood Test Edit 是 v2 中**数据精度等级最高的录入屏**——一次血检报告里录入的 4-7 个激素值，会落到 data 屏的 hormone 卡 + 趋势折线，进而影响用户对自己 HRT 进度的判断。它不能"流畅"，必须"谨慎"——节奏比 add-drug 慢一档。每个值离焦都触发 `statusFor` 评估，超出常规即显式反馈；单位切换前显示换算系数；删除条目从滑删改为长按 + 确认。

气质上，它是内刊里的「**病历手账页**」——sumi 墨黑的章节标题、JetBrains Mono Light 的数值列、宋体「在常规范围内。」的注脚。零警示色块、零状态徽章。**异常值靠数字染黛蓝 + 朱砂文字注脚表达**——继承 data spec §6 的展示原则，但 edit 端要更克制：数字仍是用户输入的数字，不抢戏。

跨性别敏感性：所有 hormone label 走中性医学术语（「雄激素水平」非「睾酮」），目标范围按 onboarding 的 `UserHormoneProfile`（feminizing / masculinizing / monitoring）派发。本 spec 视 profile 已在 settings 注入；edit 屏顶部 hero 副行显示「按 {profile} 范围参考」让用户清楚判定依据。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 默认态（编辑现有报告）

```
┌─────────────────────────────────────────────┐
│ ←                              记下。       │  ← HanaTopBar.default · 米灰实色
│                                             │     leading ghost back · trailing ghost「记下。」
├─────────────────────────────────────────────┤
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│ │ 记一份血检。                              │  ← display (32/42/-0.3) 宋体墨色
│   按 feminizing 范围参考　共 5 项           │  ← body-sm inkSecondary + mono「5」
│                                             │     左对齐 32，右侧 96px+ 留白
│   (spacing.xl = 64)                         │
│                                             │
│ │ 日期。                                    │  ← title 18 + 4px 黛蓝竖线（段落标记）
│                                             │
│   2026 / 04 / 29                            │  ← mono 18 ink，整行可点 → 日期 picker
│   tap to change                             │     行高 ≥ 48dp
│                                             │
│   (spacing.lg = 32)                         │
│                                             │
│ │ 来源。                                    │  ← 章节段落标记
│                                             │
│   [ 自费检查 ] [ 公立医院 ] [ 跨健康体检 ]   │  ← HanaButton.secondary toggle group
│   [ 自购试剂 ]                              │     选中 = 黛蓝 1px 边框 + ink 文字
│   实验室名（可空）                          │     未选 = 烟灰 1px 边框 + inkSecondary
│   ─────────────                             │
│   北京同仁医院                              │  ← HanaInput.singleLine
│                                             │
│   (spacing.lg = 32)                         │
│                                             │
│ │ 测量值。                                  │  ← 章节段落标记
│                                             │
│   ╭──────────────────────────────────╮      │  ← HanaCard.flat（无 BoxShadow）
│   │ 雌二醇                       ›   │      │  ← title 18 + chevron 16dp
│   │                                  │      │     tap title → hormone picker
│   │ 158        pg/mL    ›            │      │  ← display-md (24) mono Light + label 单位
│   │ ────────                         │      │     单位 chip 可点 → unit picker
│   │ 在常规范围内。                   │      │  ← body-sm inkSecondary（默认）
│   ╰──────────────────────────────────╯      │
│                                             │
│   (卡间 spacing.md = 16)                    │
│                                             │
│   ╭──────────────────────────────────╮      │  ← 异常值（critical 高）
│   │ 雄激素水平                   ›   │      │  ← 中性术语，非「睾酮」
│   │                                  │      │
│   │ 1240       pmol/L   ›            │      │  ← mono **染 primary 黛蓝**
│   │ ────────                         │      │
│   │ 超出常规范围。                   │      │  ← body-sm inkSecondary
│   │ 建议复诊。                       │      │  ← body-sm 朱砂（critical 才出，仅文字）
│   ╰──────────────────────────────────╯      │
│                                             │
│   ╭──────────────────────────────────╮      │  ← warning（轻微偏离）
│   │ 黄体酮                       ›   │      │
│   │ 12         ng/mL    ›            │      │  ← mono **染 primary 黛蓝**
│   │ ────────                         │      │
│   │ 略高于常规范围。                 │      │  ← body-sm inkSecondary（不出朱砂）
│   ╰──────────────────────────────────╯      │
│                                             │
│   (卡间 spacing.md = 16)                    │
│                                             │
│   添加一项。                                │  ← HanaButton.text（ghost variant）
│                                             │     左对齐 32，**不**居中
│                                             │
│   (spacing.lg = 32)                         │
│                                             │
│ │ 备注。                                    │  ← 章节段落标记
│                                             │
│   ┌──────────────────────────────────┐      │  ← HanaInput.multiline
│   │                                  │      │     minLines 3 maxLines 8
│   │                                  │      │
│   └──────────────────────────────────┘      │
│   可写采血时间、空腹与否、月经周期。        │  ← helperText body-sm inkSecondary
│                                             │
│   (spacing.xl = 64)                         │
│                                             │
│   [ 取消 ]                  [ 记下。 ]      │  ← ghost + primary 左右对齐 32px
│                                             │     primary 仅在字段齐全时启用
│                                             │  ← SafeArea bottom
└─────────────────────────────────────────────┘
```

### 2.2 新增态

副行换文案「按 feminizing 范围参考　尚未添加测量值」；测量值段不显示卡片，仅一行「先添加一项。」`HanaButton.secondary` 居中——首次添加是仪式动作，给一次居中按钮例外（与 onboarding 屏 5 同等级）。添加首项后切回 §2.1 默认布局，按钮回到左对齐 ghost。

### 2.3 加载态 / 错误态

加载：`HanaLoadingView.block`「读取中。」inkSecondary。
错误：`HanaErrorState`「读取失败。请重试。」+ ghost「重试」按钮。**不**用 SnackBar。

---

## 3. 组件映射

| 区域 | v1 inline | v2 组件 | 关键 props |
|------|----------|--------|----------|
| AppBar | `AppBar(Material) + IconButton check_circle` | `HanaTopBar.default` | leading ghost back arrow / trailing ghost「记下。」（保存按钮镜像） |
| Hero「记一份血检。」 | (无) | `Text` display 宋体 + 4px 黛蓝竖线 | 左对齐 32px，右侧 ≥ 96px 留白 |
| Hero 副行 | (无) | `Text` body-sm + mono 数字 | inkSecondary，「按 {profile} 范围参考」+ 「共 {n} 项」 |
| 章节段落标记 | (无) | `HanaSectionHeader` | title 18 + 4px 黛蓝竖线（覆盖首行）— 共 4 段（日期 / 来源 / 测量值 / 备注） |
| 日期行 | `ListTile + showDatePicker` | tap row → `HanaBottomSheet.picker` 内嵌日期 | mono 18 ink，禁 Material `showDatePicker` |
| 来源 toggle | (无) | `HanaButton.secondary` ×4 横排 Wrap | 选中 = 黛蓝边框 + ink；多选互斥（单选语义） |
| 实验室名 | `TextField` 内嵌卡 | `HanaInput.singleLine` | 无外框，底部 1px outline / focus 2px primary |
| Hormone 卡 | `_CardWrapper + Dropdown + TextFormField` | `HanaCard.flat` | radius 4，elev-0，含 hormone picker 触发 + 数值输入 + 单位 picker 触发 + 状态注脚 |
| Hormone 选择 | `DropdownButtonFormField` (line 411) | tap title row → `HanaBottomSheet.picker(items: HormoneType.values)` | items 走 `localizedNeutralName(l10n)`（中性术语 ARB key） |
| 数值输入 | `TextFormField` outlineBorder | `HanaInput.numeric` | **JetBrains Mono Light 24/32**；onBlur 触发 `statusFor` 重绘卡注脚 |
| 单位 chip | 只读 Text 80dp | tap chip → `HanaBottomSheet.picker` 单位 + inline 换算提示 | 切换前显示「pmol/L → pg/mL：÷ 3.671，{value} → {converted}」预览 |
| 删除条目 | `Dismissible` 红底滑删 | 长按 hormone 卡 → `HanaConfirmDialog`「移除该测量值？」 | confirm = 朱砂 ghost「移除」+ 默认 ghost「取消」 |
| 添加按钮 | `TextButton.icon` 居中 | `HanaButton.text`「添加一项。」 | 左对齐与列表左缘对齐；**仅**新增态例外为 secondary 居中 |
| 备注 | `TextField` minLines 2 maxLines 4 | `HanaInput.multiline` minLines 3 maxLines 8 | helperText「可写采血时间、空腹与否、月经周期。」 |
| 底部按钮区 | (无 — 仅 AppBar 保存) | 左 `HanaButton.text`「取消」/ 右 `HanaButton.primary`「记下。」 | 距上 64，左右对齐 32，**不**全宽 |
| 反馈 | `ScaffoldMessenger.SnackBar` | `HanaToast` | 错误「保存失败。{reason}」/「读取失败。请重试。」 |

> **明确删除**：`_CardWrapper`（line 512-536）整个 class、`Dismissible` 滑删、`showDatePicker` 调用、`DropdownButtonFormField` 三处、`Icons.check_circle_outline` AppBar action、所有 `Plus Jakarta Sans` 引用、所有 `BoxShadow` / `BorderRadius.circular(16)`。

---

## 4. Tokens 引用清单

### 颜色

| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| Hormone 卡 / 备注卡 | `HanaTokens.surfaceContainerLowest(context)` |
| AppBar 米灰 | `HanaTokens.surfaceContainerHigh(context)` |
| Hero / 章节标题 / 范围内数值 / 标签 | `HanaTokens.ink(context)` |
| 副行 / helperText / 「在常规范围内。」/ 「略高于常规范围。」 | `HanaTokens.inkSecondary(context)` |
| **超出范围数值（warning + critical）** / 章节竖线 / Hero 竖线 / 保存按钮实色 / 来源 toggle 选中边框 / input focus 线 | `HanaTokens.primary(context)` |
| **「建议复诊。」（critical only）** | `HanaTokens.error(context)` |
| HanaInput idle 底线 / 来源 toggle 未选边框 | `HanaTokens.outline(context)` |

### 一抹强色配额（principles §1 ≤ 3 处稳态）

| 位置 | 计入配额 |
|------|---------|
| Hero 段「记一份血检。」竖线 | ✓ 1 处 |
| 底部「记下。」primary 实色按钮 | ✓ 2 处 |
| 章节段落标记竖线（日期 / 来源 / 测量值 / 备注 = 4 处）| **超额** — 决策同 add-drug spec §7：仅 hero 保留竖线，章节段落标记改用 title 18 黑墨宋体 + spacing.lg 跨级分隔，**无竖线** |
| 异常值数字（warning / critical）| 偶发态，每屏 ≤ 2 处偏离才 PR 自动通过；3+ 处需 reviewer ack（同 data spec §6） |
| 来源 toggle 选中边框（1 处）| ✓ 3 处（用户选中状态固定 1 个） |
| input focus 2px 黛蓝呼吸线 | 瞬时态，不计入稳态配额 |

**最终稳态黛蓝出现位置**：① Hero 竖线 ② 来源 toggle 选中边框 ③ 保存按钮 = **3 处**。异常值数字 + hormone picker focus 等为偶发态。

### 间距

| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `spacing.lg` = 32 |
| Hero 顶部留白 / Hero 到首章节 | `spacing.xl` = 64 |
| 章节间（日期↔来源↔测量值↔备注） | `spacing.lg` = 32 |
| 章节内字段间 / 卡间 | `spacing.md` = 16 |
| 卡内 padding | `spacing.md` = 16 |
| 卡内段落（hormone 名↔数值行↔状态注脚）| `spacing.sm` = 8 |
| 末段到底部按钮 | `spacing.xl` = 64 |

强制跨级：8 → 16 → 32 → 64 四档逐级递增。

### 圆角

`r-card` = 4 · `r-input` = 2 · `r-button` = 6 · `r-bottom-sheet` = 16（顶角）

### 字体

| 用途 | Token |
|------|-------|
| Hero「记一份血检。」 | `display` (32/42/-0.3) Spectral SemiBold / 思源宋体 Medium / Noto Serif JP Medium |
| 章节段落标记 | `title` (18/26/0) 黑墨宋体（中文走思源宋体 Medium） |
| Hormone 卡内主标题 | `title` (18/26/0) Regular |
| **数值（hormone 输入 / 大数字 readout / 日期 / 单位换算预览）** | `mono` JetBrains Mono Light，readout 24/32，输入 18/24 |
| 单位 chip / hormone 卡内单位标签 | `label` (12/16/+0.6) Inter Medium / 思源黑体 Medium，紧贴数字右侧 spacing.xs=4 |
| 状态注脚 / helperText / 副行 / 实验室名 helperText | `body-sm` (13/20/0) inkSecondary |
| 来源 toggle 文字 | `label` (12/16/+0.6) Medium |

### 动画

| 时机 | 时长 / 曲线 | Token |
|------|------------|-------|
| HanaInput focus 1→2px | 80ms easeOut | `motion.instant` |
| HanaButton press scale 0.98 | 150ms easeOut | `motion.quick` |
| Bottom sheet 升起（日期 / hormone / unit picker）| 240ms easeInOut | `motion.standard` |
| Hormone 卡数值离焦 → 状态注脚切换 | 240ms fadeIn 替换 | `motion.standard` |
| 单位换算预览（pmol/L → pg/mL）| 240ms fadeIn | `motion.standard` |
| 保存按钮按下 → 跳回 data 屏 | 直接 pop（无 celebration） | — |

**绝对禁止**：滑删过场动画、SnackBar 弹出、Material Ink 涟漪。

---

## 5. 数据展示原则（继承 data spec §6 + edit 端补充）

1. **范围内**：mono ink 数字 + body-sm inkSecondary「在常规范围内。」——零修饰，零 ✓，零色块。
2. **warning（distance/span ≤ 0.5）**：mono **primary 黛蓝**数字 + body-sm inkSecondary「略高于常规范围。」/「略低于常规范围。」——**不**给注脚加色块，**不**出朱砂。
3. **critical（distance/span > 0.5）**：mono **primary 黛蓝**数字（不染朱砂）+ body-sm inkSecondary「超出常规范围。」+ 多一行 body-sm **朱砂**「建议复诊。」——朱砂仅落在文字注脚，确保 destructive 色稀缺。
4. **离焦时机**：用户 textfield blur 即触发 `statusFor(value)`，注脚 240ms fadeIn 切换；不在每次 keystroke 触发。
5. **单位换算时**：切换单位前 sheet 内显示「{old}{unit_old} = {new}{unit_new}」预览；用户确认后 mono 数字 + 单位同步更新，状态重新评估。

---

## 6. 交互状态

### 6.1 默认装载

- 编辑态：`getReportById` → 字段预填 → fadeIn 240ms 错落 80ms（hero / 章节 / 卡片依次）
- 新增态：所有字段空，hero 副行「尚未添加测量值」+ 测量值段中央「先添加一项。」secondary 按钮

### 6.2 添加测量值

1. tap「添加一项。」
2. → `HanaBottomSheet.picker(items: HormoneType.values 排除已添加)` 标题「指标。」
3. 选中 hormone → sheet dismiss → 卡片 fadeIn 240ms 加入列表 → 数值字段自动获焦
4. 用户输入数值 → blur → `statusFor` 评估 → 注脚切换

### 6.3 切换 hormone

- tap 卡内 hormone title row → `HanaBottomSheet.picker` 重选
- 切换后单位回到该 hormone 的 `defaultUnit`，数值保留（用户决定是否换算）
- 状态重新评估

### 6.4 切换单位

- tap 卡内单位 chip → `HanaBottomSheet.picker(items: hormone.supportedUnits)`
- sheet 内每行显示「{unit}　换算：{value} {old} = {converted} {new}」
- 选中 → 数值自动换算（保留 1 位小数）+ unit 更新 + 状态重新评估
- 用户可在 sheet 内点「不换算（仅改单位）」直接改单位不动数值——给手动录入留出口

### 6.5 长按卡删除

- 长按 ≥ 500ms → `HanaConfirmDialog` 弹起
- title「移除该测量值？」+ body-sm「移除后该次测量将不再保留。」
- actions：左 ghost「取消」/ 右 朱砂 ghost「移除」
- confirm → 卡 fadeOut 240ms + 列表收起；**无** undo（删除是显式确认动作）

### 6.6 保存

- 启用条件：① 日期已选 ② 测量值 ≥ 1 ③ 每条测量值有非零数字 ④ 来源已选（实验室名可空）
- 不满足时按钮 inkSecondary 灰态（不可点）+ 失败原因不显式（避免红色感）
- tap 启用按钮 → cubit / repo addOrUpdate → success → `HanaToast`「已记下。」inkSecondary 1.2s + `context.pop()`
- 失败 → `HanaToast`「保存失败。{reason}」inkSecondary（不用红）

### 6.7 取消

- 直接 `context.pop()` 不弹确认（除非有未保存改动 → `HanaConfirmDialog`「未保存的改动将被丢弃。仍要离开？」）
- 物理返回键等价取消

---

## 7. 断点行为

| 宽度 | 布局 |
|------|------|
| < 600 (mobile) | 单列，水平 padding 32 |
| 600–1024 (tablet) | 内容居中宽度 600px，左右大留白 |
| ≥ 1024 (web 桌面) | 内容居中宽度 720px；hormone 卡仍 1 列（不分栏） |

mobile 主战场。tablet/web 仅约束 max-width。

---

## 8. i18n 注意

- **跨性别敏感性 ARB key**（中性医学术语）：
  - `bloodTest.hormone.estradiol` → 「雌激素」/ "Estrogen" /「エストロゲン」
  - `bloodTest.hormone.testosterone` → 「雄激素水平」/ "Androgen level" /「アンドロゲン値」（**不**用「睾酮」）
  - `bloodTest.hormone.progesterone` → 「孕激素」
  - `bloodTest.hormone.prolactin` / `lh` / `fsh` / `shbg` → 走标准缩写
- **hero 副行**: `bloodTestEdit.heroSubtitle("feminizing", n)` → 「按 feminizing 范围参考　共 {n} 项」/ "Per feminizing reference, {n} items" /「フェミナイジング基準で {n} 項目」
- **状态注脚**:
  - `bloodTest.statusInRange` → 「在常规范围内。」/ "Within reference range." /「基準範囲内。」
  - `bloodTest.statusHighMild` → 「略高于常规范围。」
  - `bloodTest.statusLowMild` → 「略低于常规范围。」
  - `bloodTest.statusOutOfRange` → 「超出常规范围。」
  - `bloodTest.statusCriticalSuggest` → 「建议复诊。」（朱砂）
- **来源 toggle**: `source.selfPaid` / `source.publicHospital` / `source.transHealthClinic` / `source.selfTest`
- **单位换算 sheet**:
  - `unit.conversionPreview(from, to, value, converted)` → 「{from} → {to}：{value} 换算为 {converted}」
- **CTA 文案**: `bloodTestEdit.heroTitle` 「记一份血检。」/ `bloodTestEdit.save` 「记下。」/ `bloodTestEdit.addReading` 「添加一项。」/ `bloodTestEdit.cancel` 「取消」/ `bloodTestEdit.removeConfirm` 「移除该测量值？」
- ja 章节标题字数比 zh 多 ~30%（「測定値。」vs「测量值。」），章节标记 Wrap 自动折行
- 单位（pmol/L / pg/mL / ng/dL / mIU/mL / nmol/L）保持英文不本地化——单位是国际标准
- mono 字符表无全角点，zh/ja 数值小数点保留 `.`

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — 日期行 / 来源 toggle / hormone 卡 / 单位 chip / 删除按钮均 ≥ 48 |
| Semantics（hormone 卡）| `Semantics(label: "{hormone} {value} {unit} {statusText}", textField: false)` 整张卡作为 1 单元朗读 |
| Semantics（数值输入）| `Semantics(textField: true, label: "{hormone} 数值，单位 {unit}")` |
| 焦点顺序 | AppBar back → 日期 → 来源 toggle（4 项）→ 实验室名 → 测量值卡 1（hormone → 数值 → 单位 → 删除）→ ... → 添加一项 → 备注 → 取消 → 保存 → AppBar trailing |
| Bottom sheet 焦点 trap | sheet 进入时焦点到 sheet 内首条；ESC / 物理返回关闭并回到触发字段 |
| Confirm dialog 焦点 | 默认聚焦"取消"（避免误删） |
| `prefers-reduced-motion` | 240ms fadeIn 替换 → 0ms 直显；input focus 80ms 保留 |
| 对比度（light）| ✓ ink #1C1A18 on #FBF8F2 = 14.4:1 (AAA)；mono primary #1F3A5F on #FBF8F2 = 9.0:1 (AAA)；error #9B2A2A on #FBF8F2 = 7.4:1 (AAA) |
| 对比度（dark）| ✓ primary #7A9CC2 on #252320 = 6.4:1 (AA+) |

---

## 10. 自我 critique-v2

| 原则 | 自审 | 备注 |
|------|------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处）| ✓ | Hero 竖线 + 来源 toggle 选中 + 保存按钮 = 3 处稳态。异常值数字为偶发态，每屏 ≤ 2 处不破规。章节标记改用 title 18 黑墨宋体无竖线。 |
| 2. 调和层次胜过投影 | ✓ | `_CardWrapper` 全删；`HanaCard.flat` elev-0；零 BackdropFilter；零 BoxShadow；零边框（除 input idle / focus + 来源 toggle）。 |
| 3. 编辑级不对称 | ✓ | Hero 左对齐 32，右侧 96+ 留白；底部按钮非全宽；段落竖线仅 hero 首行；添加按钮左对齐而非居中（新增态首项例外）。 |
| 4. 慢节奏与留白 | ✓ | 章节间 32 + 段内 16 + 卡内 8 + 顶/底 64 四档跨级。状态注脚离焦 fadeIn 而非即时 — 节奏比 add-drug 慢一档。 |
| 5. 内容即装饰 | ✓ | 状态用排版表达（mono 染色 + 注脚）而非色块 / icon / 徽章。零 emoji / 零渐变 / 零装饰图标（删除 calendar / hospital / notes 三处 prefix icon）。Validation 用 inline body-sm inkSecondary 不用红色。 |

**残留风险**：
- **单位换算精度**：用户在 pmol/L 输入 1500 → 切到 pg/mL → 换算 408.6 → 再切回 pmol/L → 1500.7（浮点误差）。决策：保留 1 位小数 + 切换 sheet 内提供「不换算」出口；后续对照 data spec 趋势线时以单位为索引隔离比对。
- **`UserHormoneProfile` 未在 onboarding 落地**：本 spec 假设 `feminizing` / `masculinizing` / `monitoring` 已在 settings 注入。若 profile 缺失，hero 副行 fallback 显示「无 profile，按 feminizing 默认」+ 跳转 settings 的 ghost 链接——避免静默错配。该兜底逻辑由 handoff §3 实施。
- **删除条目无 undo**：长按 + ConfirmDialog 已经是双重门槛，但血检数据敏感性高于 medication，未来 v2.1 可考虑加 5s `HanaToast` undo。本期不做。

---

— 完 —
