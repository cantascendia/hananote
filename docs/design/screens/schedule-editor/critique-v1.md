# Schedule Editor 屏 v1 现状 critique

> Generated 2026-04-29 by AI design review against DESIGN.md v2
> 屏幕：`lib/features/medication/presentation/pages/schedule_editor_page.dart`
> 用户场景：编辑某药的提醒时间表（多时段 + 频率 + 起止日期）
> 重设计阶段：Phase 3.x Pilot Wave critique-v1（最复杂的表单屏）

## 1. 当前实现概要

`schedule_editor_page.dart` 用一个 `ListView`（padding 24）从上到下堆 6 段：（a）顶部 Material `AppBar`，右侧 `IconButton(Icons.check)` 作为保存动作；（b）若 `state.drugName` 存在，一个 M3 `Card(color: surfaceContainerLow)` 当药品 header，左侧 `Icons.medication_outlined`；（c）Material `TextField` + `OutlineInputBorder` 作为剂量输入；（d）`Wrap` 横排一组 `ChoiceChip` 作为单位选择；（e）`SegmentedButton<int>` 切换三种 `MedicationFrequency`，命中后用 `DropdownButton` 配置子参数（每日次数 / 隔 N 天 / 周几）；（f）两个 `ListTile`（外框 `RoundedRectangleBorder` 8px）调系统 `showDatePicker` 配置起止日期；（g）`for (i in expectedTimes)` 循环出多个 `ListTile`，每行一个时间，点击调系统 `showTimePicker`；（h）底部 `FilledButton` 重复保存。验证错误用裸 `Text(color: errorColor)` 直接插在标签上方。

## 2. 违规点逐项（按 v2 5 原则）

### 原则 1：一抹强色（黛蓝 ≤ 3 处/屏）

- 现状：药品 header 的 `theme.colorScheme.primary`（90）+ `OutlineInputBorder` 的 focus border（M3 默认 primary）+ `ChoiceChip` 选中态填充 primary + `SegmentedButton` 选中段填充 primary + `IconButton(Icons.check)` 默认 primary + 底部 `FilledButton` primary 实色 + `showDatePicker` / `showTimePicker` 系统弹窗内整套 M3 primary 配色。粗算 7+ 处强色，且系统 picker 无法控色。
- 违规：① 整屏色板走 M3 `theme.colorScheme.*`，未切到 `HanaTokens`；② 强色出现远 > 3 处，"句号"语感完全丢失；③ 系统 `showTimePicker` 弹一个圆形钟面 + primary 填充，与 v2 月白纸感视觉断裂。
- 优先级：P0
- 改动建议：剂量输入 focus 线 + 频率 selected card + 底部「保存」CTA = 3 处黛蓝，其余全墨色 / 烟灰；时间选择改 `HanaBottomSheet.picker` + 自绘 mono 数字滚轮，弃用系统 picker。

### 原则 2：调和层次胜过投影

- 现状：① 药品 header 用 M3 `Card`（默认 elevation 1 + 底层投影）；② `TextField` 用 `OutlineInputBorder` 1px 实线四面框；③ 起止日期 / 时间项用 `RoundedRectangleBorder(side: BorderSide(outlineVariant), radius: 8)` —— 1px 全框实线 + 8px 圆角，是 v2 严禁的"卡片靠边框定义"语法；④ 底部 `FilledButton` 默认带 elevation；⑤ M3 `SegmentedButton` 整组用 outline 描边。
- 违规：v2 严禁 elevation > 0 + 严禁 1px 边框当容器 + 严禁圆角 8px（≥8 全部出局）。当前屏 4 类容器全靠边框 + 圆角伪造层次。
- 优先级：P0
- 改动建议：药品 header / 时段卡 / 频率选项卡 / 起止日期入口全切 `HanaCard.flat`（surfaceContainerLowest 实色 + 4px 圆角 + 0 边框 + 0 投影）；输入字段去 OutlineBorder，改 v2 `HanaTextField`（仅底部 1px 烟灰线 + focus 2px 黛蓝呼吸线）。

### 原则 3：编辑级不对称（左对齐 32px，避免居中）

- 现状：① `EdgeInsets.all(24)`（行 77）水平 padding 24 错值；② AppBar 标题 M3 默认居中（Android 也偏左但不到 32）；③ 没有 hero 段——直接进表单第一项，不符合 v2「顶部 64 留白 + 一行宋体编辑陈述」开篇；④ 各段标题用 `theme.textTheme.titleMedium`（"频率" / "开始日期" / "时间"）裸文字，无 4px 黛蓝竖线段落标记；⑤ `SegmentedButton` 是横向三等分居中铺满布局；⑥ `Wrap` 单位 ChoiceChip 默认从左排但没有锚定 spacing.lg；⑦ 底部 `FilledButton` 无 fullWidth 但用 `Padding(all: 16)` 撑大居中。
- 违规：水平 padding 错值；缺 hero；章节竖线缺失；SegmentedButton 居中铺满与杂志栏目并列结构冲突。
- 优先级：P0（padding + 竖线 + hero）/ P1（按钮位置）
- 改动建议：水平 padding 24 → 32（`spacing.lg`）；新增 hero「时间表。」display-xl 左对齐；所有段标题套 `HanaSectionHeader`（左 4px 黛蓝竖线仅覆盖首行 16px）；频率三选项改为 3 张 `HanaCard.tappable` 纵向排列（每张内一行 title + 一行陈述 body-sm），抛弃 SegmentedButton；底部「保存」改 `HanaButton.primary` 不 fullWidth 左对齐。

### 原则 4：慢节奏与留白

- 现状：① padding 24 + `SizedBox(height: 12)`（142）+ `SizedBox(height: 8)`（167/176/204/395）+ `SizedBox(height: 16)` + `SizedBox(height: 24)` + `SizedBox(height: 48)` 间距值混杂——12 / 24 / 48 三个非 v2 token 值（v2 跳过 12 / 20 / 24 / 48）；② 时段 ListTile 之间 `EdgeInsets.only(bottom: 8)`（397）紧贴排列，无段落呼吸；③ 段落与段落之间用 24（160/169/237），未达 v2 跨级要求（卡内 16 + 卡间 32 才合规）；④ AppBar 直接顶到第一项内容，零顶部留白。
- 违规：① 间距值非 token（12 / 24 / 48 三个非法值）；② 相邻间距未跨级（16 紧挨 24 紧挨 16）；③ 顶部 hero 留白 0（v2 要求 ≥ 64 / xl）；④ 时段列表 8 紧贴 8。
- 优先级：P1
- 改动建议：全屏间距按 `xs/sm/md/lg/xl = 4/8/16/32/64` 替换，删除 12 / 24 / 48；段间统一 32（lg），卡内 16（md），相邻强制跨级；hero 顶部 64（xl）；时段卡间距 16（md）+ 章节间 32（lg）。

### 原则 5：内容即装饰

- 现状：① 药品 header 用 `Icons.medication_outlined`（90）作为 leading，**装饰承担信息**——drugName 已在文字中，icon 冗余；② 起止日期 `ListTile.trailing` 用 `Icons.calendar_today`（189/218）；③ 时段 `ListTile.trailing` 用 `Icons.access_time`（412）—— v2 编辑级排版要求"内容即装饰"，时间用 mono 数字 + body 标签自带语义，icon 是工具语言冗余；④ 验证错误用裸 `Text(color: errorColor)` 红字弹出，未走 v2 inline body-sm 错误语法；⑤ 时段无标签（"早" / "午" / "晚"），用户对一列 mono 数字"08:00 / 12:00 / 20:00"无法快速识别语义；⑥ 时段冲突（间隔 < 4h 可能重复通知 / 漏服）零提示，是用户实际报修的高频痛点。
- 违规：装饰 icon 4 处；裸红字错误；时段缺语义标签；缺冲突警告。
- 优先级：P0（装饰 icon + 错误样式）/ P1（时段标签 + 冲突警告）
- 改动建议：删除全部 `Icons.medication_outlined` / `calendar_today` / `access_time`；错误改 inline body-sm 朱砂 + 字段下方一行陈述；时段卡左侧自动按时间段贴标签「早」（5-11 点）/「午」（11-17）/「晚」（17-24）/「夜」（0-5）；时段间隔 < 4h 时，下方加 body-sm `inkSubdued` 一行「与上一时段相隔不足 4 小时。」编辑陈述（不阻塞保存，仅提示）。

## 3. 7 个评审维度（来自重设计指挥手册模板 B）

### 可用性
核心动作链「选频率 → 设次数 → 调时间」当前路径：先点 SegmentedButton 切到"每日"，再点 Dropdown 选 3 次，**底层 `_buildTimeSelectors` 自动同步 expectedTimes 对齐到 3 项**（374-386）—— 这个隐式同步逻辑用户不可见：用户改"每日 3 次"后才发现下方多了两个时段，反向若改"每日 1 次"则后两个时段被静默截断（385），数据丢失无 undo。每段时间还得调系统 `showTimePicker` 圆形钟面（414），单手大拇指够不到 12 点位的痛感。建议改为：时段列表显式可增删（"+ 添加时段" / 每行右侧删除），频率不再自动覆盖时段数；时间选择改 `HanaBottomSheet` 滚轮 mono 数字。

### 层次
v2 要求 4 级 surface（Lowest / Low / High / Highest）。当前实现：scaffold 默认背景 + 药品 header `surfaceContainerLow` + 全屏其余卡片靠 1px outline 描边——只用了 1.5 级 surface，且层次完全靠"边框 + 圆角"伪造，纸阶差零利用。频率三选项是 SegmentedButton 一根横条，毫无段落感。

### 一致性
与 DESIGN.md 偏差：① 字体仍用 M3 `theme.textTheme.*`（titleMedium / bodySmall）—— v2 要求宋体 Display + Inter Body + JetBrains Mono 数值，时间应是 mono；② 圆角 8（ListTile RoundedRectangleBorder）非 token，应统一 4（卡）/ 6（按钮）/ 16（BottomSheet）；③ 颜色全走 `theme.colorScheme.*`，未迁 `HanaTokens`；④ 文案 `l10n.editDrug` / `l10n.frequency` / `l10n.scheduleTimes` 仍是 v1 系（"编辑药物" / "频率" / "时间"），需迁 v2 编辑体（"时间表。" / "几时" / "频率"）；⑤ 与 Today 屏 hero 语法不一致——Today 有「早。」+ 章节竖线，editor 直接进表单。

### 情感色彩
v2 调性："克制·沉静·不矫情"。当前 editor 是 M3 标准表单——SegmentedButton 工具感、OutlineBorder 紧绷感、IconButton 保存（90 度斜对角，Material 教科书）—— 完全无杂志感、无内刊感、无敬意。用户编辑时间表是个"日常仪式行为"（一周一次微调），v2 应让这个动作像"在内刊封底页誊写时刻表"，不是"填表单"。

### 暗色模式
当前 `theme.colorScheme.*` 全走 M3 ThemeData，dark mode 下 outline / surfaceContainerLow / primary 都自动切——理论可用。但系统 `showDatePicker` / `showTimePicker` dark 主题与 v2 月白基底（dark `#1C1A18` 暖深棕灰）不匹配，会出 M3 紫调 vs 暖灰调撕裂。

### i18n
日文「毎日 3 回」/「隔日」/「特定の曜日」比中文「每日」/「隔日」/「每周」长 30%-60%。当前 SegmentedButton 三段定宽等分，日文必溢出。`Wrap` ChoiceChip 单位选择 `spacing: 8` 在 ja "ミリリットル" / "ティースプーン" 长 chip 下会换 2-3 行难看。验证文案 `validationScheduleTimeRequired` 现走 `_localizeValidation` switch 表（455-464），新增 key 需同步三处 ARB + switch case，机械重复。

### 响应式
完全未处理 ≥ 768px Web 端：`ListView(padding: all 24)` 撑满宽度，平板 / 桌面会出现单列 1200px+ 表单"巨字幅"——剂量输入框拉到一千多像素，键盘 IME 候选词与输入位严重失焦。需要 max-width 720px 内文页约束。

## 4. P0 / P1 / P2 总清单

### P0（违规必改 — 阻塞 v2 落地）
1. 整屏色 token 从 `theme.colorScheme.*` 切到 `HanaTokens.*(context)`，单轨 API；强色限制到 ≤ 3 处（① 输入字段 focus 线 ② 频率 selected card ③ 底部「保存」CTA）。
2. 删除 M3 `Card` 药品 header 的 elevation + 投影（80），改 `HanaCard.flat` surfaceContainerLowest。
3. `TextField` 的 `OutlineInputBorder` 全 4 边实线 → `HanaTextField` 仅底部 1px 烟灰线 + focus 2px 黛蓝呼吸线 + 圆角 2px。
4. 起止日期 / 时段 `ListTile` 的 `RoundedRectangleBorder(side: BorderSide, radius: 8)` → `HanaCard.tappable` surfaceContainerLowest 4px 圆角 0 边框。
5. `SegmentedButton` 三选频率 → 3 张 `HanaCard.tappable` 纵向排列（每张内 title + body-sm 陈述）。
6. 系统 `showTimePicker`（414）→ `HanaBottomSheet.picker` 自绘 mono 数字滚轮（hour × minute 两列）。
7. 系统 `showDatePicker`（191/226）→ `HanaBottomSheet.picker` 自绘日期滚轮 / 月历卡。
8. 删除装饰 icon 4 处：`Icons.medication_outlined`（90）/ `Icons.calendar_today`（189/218）/ `Icons.access_time`（412）/ AppBar 保存 `Icons.check`（70 改文字按钮）。
9. AppBar 改 `HanaTopBar.default` 实色 `surfaceContainerHigh` + 标题"时间表。"左对齐 32 + 右侧 ghost 文字按钮「保存」。
10. 字体迁 v2 ramp：标题 Spectral SemiBold / 思源宋体 Medium，body Inter / 思源黑体，时间数字 + 剂量数值 JetBrains Mono Light。
11. 验证错误从裸 `Text(color: errorColor)` → inline body-sm 朱砂（`HanaTokens.error`）+ 字段下方一行编辑陈述。
12. 圆角全部统一 v2 token：卡片 4 / 按钮 6 / BottomSheet 16（删除现存 8）。

### P1（应当改 — 显著影响 v2 视感）
1. 水平 padding 24 → 32（lg token）。
2. 顶部留白 0 → 64（xl），新增 hero `display-xl` 「时间表。」+ 副行 mono `{drugName}　{dosage}{unit}　{route}`。
3. 章节标题（"频率" / "时段" / "起止日期"）套 `HanaSectionHeader` + 4px 黛蓝竖线仅覆盖首行 16px。
4. 间距全 token 化：删除 12（142）、24（160/169/237）、48（247）三个非法值。
5. 相邻间距强制跨级：卡内 16 + 卡间 32 / 章节间 32。
6. 时段 `HanaCard` 列表项左侧自动按时间段贴 label「早」（5-11）/「午」（11-17）/「晚」（17-24）/「夜」（0-5），右侧 ghost 删除按钮（`Icons.close` 改文字"删除"，**唯一删除场景才允许 close 微 icon**）。
7. 时段间冲突警告：相邻时段间隔 < 4h 时，下方一行 body-sm `inkSubdued` 编辑陈述「与上一时段相隔不足 4 小时。」**不阻塞保存**，仅提示。
8. 频率"星期"模式：`DropdownButton<int>` 选周几 → 7 个 `HanaButton.secondary` toggle（周一-周日 + 多选支持）。
9. 时段添加：底部一个 ghost 文字按钮「+ 添加时段」（左对齐），点击后从底部弹 `HanaBottomSheet` 时间选择，确认后 append 到 scheduleTimes 列表。
10. 文案迁 v2：`l10n.editDrug`（"编辑药物"）→ "时间表。"；`l10n.scheduleTimes`（"提醒时间"）→ "时段"；`l10n.save`（"保存"）→ "保存。"句号收尾。

### P2（可改 — 优化项）
1. Web ≥ 768 加 max-width 720px 内文页宽约束。
2. 频率改"每日 N 次"时，自动同步时段数的隐式逻辑（374-386）改显式：弹 `HanaBottomSheet.info`「将时段数从 3 调整为 1，多余时段会被删除。仍要继续？」用户确认才同步，避免静默数据丢失。
3. 通知开关用 `HanaSwitch`（待补 spec），独立段落「通知」+ 一行陈述「到时静默推送。」+ 开关右对齐。
4. 起止日期可视化：选定的"开始 4 月 29 日 → 结束（无）"用 mono 一行陈述，去掉 trailing 删除 IconButton（用长按或左滑替代）。
5. 时段重排（drag-reorder）：长按拖拽改顺序，松手用 `motion-deliberate` 600ms easeOut。
6. `flutter analyze` 加 lint 规则禁用 `OutlineInputBorder` / `SegmentedButton` / `Card`（M3）/ `showDatePicker` / `showTimePicker`，防回归。

## 5. 既有重复模式映射（来自 widget-pattern-inventory）

- HanaCard variant=flat → 替换药品 header `Card`（80）、起止日期 `ListTile`（177/205）、时段 `ListTile`（397）三类容器
- HanaCard variant=tappable → 替换 SegmentedButton 频率三选（273）→ 3 张可点卡
- HanaButton variant=primary → 替换底部 `FilledButton`（248）+ 删除 padding all 16
- HanaButton variant=ghost → 替换 AppBar `IconButton(Icons.check)`（69）+ 时段卡尾删除按钮 + 「+ 添加时段」入口
- HanaButton variant=secondary（toggle）→ 替换"星期"模式 `DropdownButton<int>`（338）→ 7 个 toggle 按钮（周一-周日）
- HanaBottomSheet variant=picker → 替换系统 `showTimePicker`（414）+ `showDatePicker`（191/226）
- HanaTextField → 替换剂量 `TextField` + `OutlineInputBorder`（123-140）
- HanaTopBar.default → 替换 M3 `AppBar`（66-75）
- HanaSectionHeader（左竖线版）→ 替换裸 `Text(titleMedium)` 段标题（161/170/203/391）4 处
- HanaSwitch（v1.1 待补 spec）→ 新增"通知"段落开关
- HanaCelebration → 保存成功后触发「时间表已记。」（替换 `Navigator.pop` 静默返回）

## 6. 用户故事影响分析

- 进入编辑时间表（v1 vs v2）：v1 是 M3 表单 — 顶部小标题「编辑药物」+ icon 药盒 header + 一段段 OutlineBorder 圆角 8 卡片 + Material `SegmentedButton` 三选 + 系统 picker 圆形钟面（情绪温度=工具感、像填政府表）；v2 是 — 月白底 + 一行墨色宋体「时间表。」hero + 副行 mono 「雌二醇凝胶　2.0 mg　涂抹」+ 章节竖线段落标记 + 三段并列 `HanaCard` + 底部 `HanaBottomSheet` 滚轮选时（情绪温度=克制、像在内刊封底誊写时刻表）。
- 多时段编辑（变化最大）：v1 频率切"每日 3 次" → 隐式自动 append 两个 08:00 占位时段 → 用户挨个点 ListTile 调系统 picker，无标签无冲突提示；v2 显式「+ 添加时段」按钮 → 弹 BottomSheet 选时 → 时段 `HanaCard` 自动贴「早 / 午 / 晚 / 夜」label + 间隔 < 4h 时下方淡墨陈述提示 → 删除按钮明确暴露在每张卡尾。
- 频率"特定星期"：v1 一个 `Dropdown` 单选周几（不支持多选）；v2 7 个 toggle 按钮（周一-周日）多选黛蓝填充，"少 = 贵"语法下选中态格外醒目。
- 保存成功：v1 `Navigator.pop` 静默返回上一屏；v2 触发 `HanaCelebration`「时间表已记。」黛蓝宋体 0.4s 静默 → 1.2s 淡入淡出 → 自动返回。

## 7. 阶段下一步指示

critique-v1 完成后下一步出新视觉稿（spec.md）。三条具体起手指引：

1. **复用 Today 屏建立的 P0 共享件**：`HanaCard` / `HanaButton` / `HanaTopBar` / `HanaSectionHeader` / `HanaCelebration` 已落地（today/handoff §3 列表）。Schedule editor 新增依赖：`HanaBottomSheet.picker`（自绘时间 / 日期滚轮）+ `HanaTextField`（剂量输入）+ `HanaSwitch`（通知开关，v1.1 待补 spec）。先确认 `HanaBottomSheet.picker` variant 在 components/bottom-sheet.md §Variants 已声明，spec 阶段直接引用；`HanaTextField` 已在 components/text-field.md 落地。
2. **保持 cubit 不动**：`ScheduleEditorCubit` + `ScheduleEditorState` 保持原契约——v2 只重画 UI 层，setter 方法（`setDosageAmount` / `setFrequency` / `setScheduleTimes` / `setStartDate` 等）全部沿用。新增"删除单个时段"由 UI 层算 `newTimes = [...current]..removeAt(i)` 后调既有 `setScheduleTimes(newTimes)` 实现，无需改 cubit。
3. **裁掉一半设计空间**：spec.md 不画两版对比稿，直接走"hero + 章节竖线 + 三段 HanaCard + 底部 BottomSheet"路径——这是 Today + Record 已验证的杂志骨架，editor 是同源延伸。频率"星期"模式的 7 个 toggle 是唯一新交互模式，重点画清楚。

## 8. 风险与注意

最大风险是"半迁移留 M3 表单 DNA"——只换色不删 `OutlineInputBorder` / 只改容器不动 `SegmentedButton` / 只迁 cubit 不删系统 `showTimePicker`。v2 表单是一套互锁系统：宋体 hero 需要顶部 64 留白支撑，黛蓝稀缺需要去掉 SegmentedButton 选中填充，`HanaBottomSheet` 滚轮需要弃用系统 picker 才能形成视觉一致。任何一项保留 v1 残留，整屏会失败回 "v1.5 缝合怪"——这是 medication 模块最复杂的表单屏，编辑时间表的"政府表" vs "内刊时刻表"语感差异极大，建议 P0 十二条作为单一 PR 一次性 merge。**特别注意**：系统 `showTimePicker` 的 dark mode 主题与 v2 月白基底撕裂，工程必须自绘 BottomSheet 滚轮——这是本屏与 Today 屏最大的工程差异，预计 +2 天工时。

— 完 —
