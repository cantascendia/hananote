# Blood Test Edit 屏 v1 critique

> Generated 2026-04-29
> 屏幕：`lib/features/blood_test/presentation/pages/blood_test_edit_page.dart`（537 行）
> 配对：`spec.md` / `handoff.md`
> 上游：`DESIGN.md` v2 + `docs/design/design-system/v2/{tokens,principles,components/*}` + `screens/data/spec.md`（fl_chart + 数据展示原则）+ `screens/add-drug/spec.md`（表单 pattern）

---

## 1. 总评

Blood Test Edit 是 v2 里数据精度要求最高的录入屏。它有两层身份：① 临床数据的"档案录入页"——值的准确性高于一切（医学决策依据）；② v2 内刊里的"病历手账页"——克制、单色、敬而非哄。v1 把两者都做歪了：UI 层是 v1 樱色 token + Plus Jakarta Sans 圆润 + Material Dropdown + Material `showDatePicker`；交互层是 `Dismissible` 滑删（破坏数据级谨慎）+ 全屏 0 个状态反馈（验证失败只 SnackBar）+ 数值字段没用 mono 字体（与正文混排，难读）+ 缺乏单位换算 / 异常值提示 / 测量来源标记（数据语义薄）。

跨性别敏感性方面，v1 的 `HormoneType.testosterone` localizedName 直接是「睾酮」，对 MTF 用户来说每次录入都是性别焦虑触发点；同时 `targetRange` 写死了 feminizing HRT 的目标值，对 transmasc 用户的录入完全错配。这两个问题不是 edit 屏单独能修，但 edit 屏是这套语义首次落地的地方，spec 必须把住。

按 v2 五条原则评分：**1.5 / 10**——基本是 v1 樱色全套搬过来。下面 P0 / P1 逐条列。

---

## 2. P0（阻断 v2 上线，必须 spec 重写）

### P0-1 全套色 token 是 v1 樱色 `HanaColors.*`
`HanaColors.primary`（樱粉）/ `surfaceContainerLowest` / `errorContainer` / `onSurface` 在 line 213, 220, 229, 248, 290, 314, 397, 400 共 18 处，全部需换 `HanaTokens.*(context)` 单轨 API。AppBar 标题用 `Plus Jakarta Sans` 圆润 sans 是 v2 严禁字体（candidate-A § 4.1）。

### P0-2 数值字段未用 mono — 数据屏的根本失败
`hormoneValue` `TextFormField`（line 459-488）继承默认字体（Plus Jakarta Sans），数字 `158.5` 与正文行高字宽混排。v2 硬规则：**所有数值（剂量 / 时间戳 / 血检值 / 第 N 天）必须 JetBrains Mono Light**——这是 data 屏 spec §5 与 add-drug 剂量字段都明确要求的统一约束。Edit 屏作为录入端，预览态、输入态、display-md 24/32 大数字都必须 mono。

### P0-3 单位以纯文本 ListTile 显示，不可切换
line 491-501 单位字段是 `SizedBox(width: 80, Text(entry.unit))`——只读，仅显示 `defaultUnit`。但 E2 在国内自费检查常用 `pmol/L`、公立医院常用 `pg/mL`、美国实验室常用 `pg/mL`——同一指标三种单位，v1 直接锁死意味着用户必须心算换算，**输错的概率随之线性升高**。spec 必须给单位 picker（`HanaBottomSheet.picker`）+ 切换时 inline 换算提示「pmol/L → pg/mL：÷ 3.671」。

### P0-4 异常值无任何检测 / 提示
domain 里 `HormoneTypeX.statusFor(value)` 已有 `normal / warning / critical` 三态（enums.dart line 64-76），**edit 屏完全没用上**。E2 = 1500 pmol/L（critical 高）和 E2 = 30 pmol/L（critical 低）UI 表现一致——只显示一个数字。data spec §6 已经定义了「数值染黛蓝 + 朱砂注脚『建议复诊。』」的展示规则，edit 屏作为录入端必须在用户**离焦时**就反馈：让用户在保存前知道这个值偏离常规，避免输错没人提醒。

### P0-5 `Dismissible` 滑删录入条目
line 388-401 用 `Dismissible.endToStart` 滑删 hormone reading。临床数据条目用滑删交互在 UX 上是错误的——滑删属于"邮件 / 通知"这种低破坏性场景。一份血检报告里录错滑删后无 undo，且 `errorContainer` 红底 + 红 `Icons.delete` 是 v1 Material 警示语言。v2 改：**长按进入选择态 + 确认 sheet 删除**，或行内 ghost 删除按钮 + `HanaConfirmDialog`「移除该条记录？」。

### P0-6 `showDatePicker` Material 标准弹窗
line 112-117 用了 Flutter 默认 `showDatePicker`——v2 严禁清单 #8 明确禁止 iOS / Material 标准弹窗。改 `HanaBottomSheet.picker` 内嵌日期。这是与 add-drug spec §6 起止日完全对齐的约束。

### P0-7 `_CardWrapper` 自带 BoxShadow
line 525-530 卡片有 `BoxShadow(blurRadius: 8, offset (0, 2))`——v2 默认 elev-0，调和层次胜过投影（principles §2）。整个 `_CardWrapper` class 删除，统一改 `HanaCard.tappable / flat`。

### P0-8 圆角 16px 软糖角
line 398, 524 都是 `BorderRadius.circular(16)`——v2 严禁清单：圆角 > 8px（除 BottomSheet 16 / 头像圆形）。卡片 4 / 输入 2 / 按钮 6。

### P0-9 测量来源缺失 — 数据语义薄
v1 仅有 `labName` 自由文本字段（line 306-325）。但临床上「自费检查 / 公立医院 / 跨健康体检 / 自购试剂」四种来源的可信度差异显著（参考区间不同、检测方法不同、是否走 LC-MS/MS）。spec 应增 `MeasurementSource` enum + `HanaButton.secondary` toggle group，落到 trend 段统计时可按来源分组。

### P0-10 跨性别敏感性零保护
- `HormoneTypeX.displayName` 硬编码「睾酮」——MTF 用户每次进 edit 屏都看到这个词。spec 需走 ARB key `bloodTest.hormone.testosterone.neutral` 文案改为「雄激素水平」（中性医学化）。
- `targetRange` 单组写死 feminizing 范围——transmasc 用户录入会全部 critical 警告。spec 需引入 `UserHormoneProfile`（onboarding 设置）按 profile 派发 range；edit 屏上方加一行「按 {profile} 范围参考」让用户知道判定依据。
- 章节标题不用「性激素」用「激素水平」——避开"性"字。

---

## 3. P1（影响内刊气质，spec 重写）

### P1-1 AppBar 视觉
- `Icons.arrow_back` + `Icons.check_circle_outline`（line 220, 247）是 Material 实心装饰 icon。改 ghost 文字 action「记下。」（保存）+ ghost back arrow 16dp 线性。
- `centerTitle: true` 是 iOS / Material 默认。v2 编辑级不对称（principles §3）要求左对齐 32px。

### P1-2 字段排序与 hero 缺失
v1 顺序：日期 → 实验室 → 备注 → 读数列表。读数（最重要的数据）反而在最下，备注（可选）反而在中段。v2 改：hero「记一份血检。」display 32 + 章节段落标记「日期。」「来源。」「测量值。」「备注。」四段，测量值段最大、最先（章节标题更靠上的视觉权重）。

### P1-3 添加测量值的交互
line 372-377 是 `TextButton.icon(icon: add_circle_outline, label: addReading)`——居中 Material text button。v2 改：列表底「添加一项。」`HanaButton.text`（ghost variant）左对齐，与列表项左缘对齐。点击后行为不是直接 append + 默认 hormone，而是先开 `HanaBottomSheet.picker` 让用户先选指标——避免 v1 line 124-129 的「自动选第一个未用的 hormone」黑魔法（用户搞不清为什么默认是 LH）。

### P1-4 备注 textarea 尺寸
line 333 `minLines: 2, maxLines: 4`——血检备注通常需要写"空腹"「服药后 X 小时」「月经周期 D{n}」等较长描述，4 行上限太紧。改 `minLines: 3, maxLines: 8` + helperText「可写采血时间、空腹与否、月经周期。」。

### P1-5 验证文案 + 反馈通道
line 149-153 仅在 `_save` 时 SnackBar「至少一项读数」。v2 spec 要求：① 字段失焦即时校验（数值非数字 / 异常值提醒）；② 错误用 inline `body-sm inkSecondary` 文字（不用红）；③ 保存按钮在「日期已选 + 读数 ≥ 1 + 每条读数有数值」时启用，否则 `inkSecondary` 灰态——避免点了才知道错。

### P1-6 i18n 文案
v1 文案 `editBloodReport` / `addBloodReport` / `addReading` / `selectHormone` / `hormoneValue` 全部直白短句。v2 调性句号收尾：「记一份血检。」「记下。」「添加一项。」「指标。」「数值。」——需要新增 ARB key 集（详见 spec §10）。

### P1-7 `loadFailed` / `saveFailed` SnackBar
line 81, 198 仍用 Material `SnackBar`——v2 改 `HanaToast`（components 已定义）；错误文案改「读取失败。请重试。」「保存失败。{reason}」（句号收尾 + 句子化）。

### P1-8 dropdown 用 `DropdownButtonFormField`
line 411-442 用了 Material `DropdownButtonFormField`——下拉箭头 / hover 高亮 / Material Ink 涟漪全是 v1 Material 语言。v2 改：tap row 触发 `HanaBottomSheet.picker(items: HormoneType.values)`，与 add-drug spec §6 类别 picker 完全对齐。

---

## 4. P2（润饰）

- `IdGenerator.generate()` 在 `_save` 里 readings.map 内调用——单次保存生成 N 个 id，建议单条新增时即生成绑定到 entry，便于未来 undo。
- `_existingReport` 加载失败的失败态没有 retry，仅 SnackBar 提示后留空白屏。建议 `HanaErrorState` 全屏 + 「重试」ghost。
- `entry.value == 0 ? '' : entry.value.toString()`（line 460）零值与未输入混淆。建议 `entry.value` 改 `double?` 区分。

---

## 5. v2 重写大纲（落到 spec）

| 维度 | v1 | v2 |
|------|----|----|
| 色 token | `HanaColors.*` | `HanaTokens.*(context)` |
| 字体 | Plus Jakarta Sans | Spectral / 宋体 / Inter；**所有数值 mono Light** |
| 卡 | `_CardWrapper` BoxShadow + r-16 | `HanaCard.flat` elev-0 + r-4 |
| 日期 | `showDatePicker` | `HanaBottomSheet.picker` 日期 |
| hormone 选择 | `DropdownButtonFormField` | tap row → `HanaBottomSheet.picker` |
| 单位 | 只读 Text | tap chip → `HanaBottomSheet.picker` + 换算提示 |
| 异常值 | 无 | `statusFor(value)` 离焦判定 + mono 数字染黛蓝 + 朱砂注脚 |
| 测量来源 | 自由文本 labName | `MeasurementSource` enum + `HanaButton.secondary` toggle |
| 删除条目 | `Dismissible` 红底滑删 | 长按选择态 + `HanaConfirmDialog` |
| 保存 CTA | AppBar `Icons.check_circle` | AppBar 文字 ghost「记下。」+ 底部 `HanaButton.primary`「记下。」（依字段完成度启用） |
| 反馈 | `SnackBar` | `HanaToast` + inline `body-sm inkSecondary` |
| 跨性别敏感 | 「睾酮」/ feminizing range 写死 | 中性词「雄激素水平」+ `UserHormoneProfile` 派发 range |

— 完 —
