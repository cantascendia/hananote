# Schedule Editor 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + components/
> 屏幕：`lib/features/medication/presentation/pages/schedule_editor_page.dart`
> Pilot Wave: 阶段 3.x（新稿）+ 自我 critique-v2
> 配对 handoff：`docs/design/handoff/schedule-editor.md`

---

## 1. 设计意图

新 Schedule editor 给用户的感觉是 **「在内刊封底页誊写时刻表」**——而不是 v1 那种"M3 政府表填写"的工具陪伴。点编辑某药提醒时进入时，屏幕给到的不是 OutlineBorder 紧绷格 + SegmentedButton 三等分横条 + 系统圆形钟面 picker 的"M3 教科书"，而是月白底 + 一行墨色宋体「时间表。」+ 副行 mono 药品索引 + 杂志栏目式三段（频率 / 时段 / 起止）+ 底部从下升起的 `HanaBottomSheet` 滚轮，像翻新潮文库末页的"附录·时刻表"。

引用 DESIGN.md「克制·沉静·不矫情·敬」调性：v1 用 SegmentedButton 三等分告诉用户"选一个吧 →"，v2 让屏幕给出三张并列 `HanaCard.tappable`——选中时只是黛蓝竖线被点亮，没有填充色爆炸。**v1 vs v2 核心叙事差异**：v1 是"app 让你填表"，v2 是"内刊请你誊抄"。一次"每周一三五早 8 点服药"的录入，从"切 SegmentedButton → 拉 Dropdown → 点 ListTile → 系统钟面"变成"选频率卡 → 点周几 toggle → 添加时段从底部弹滚轮"。仪式感来自 BottomSheet 升起时的 240ms 标准曲线，不是 picker 圆形钟面的旋转动画。

Today / Record 已建立 hero + 章节竖线 + `HanaCard` 段落 + 一抹黛蓝 CTA 的页面骨架；Schedule editor 复用这套语法但把"展示型卡片"换成"可编辑表单卡片"，把单一 CTA 换成"AppBar ghost 保存 + 底部主 CTA"——三屏同源，**不**重新发明轮子。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 默认态（编辑已有时间表，每日 3 次）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色 米灰，无 blur
│   "时间表。"  (title 18 · ink, 左对齐 32)   │     右侧 ghost 文字按钮「保存」
│                              [ 保存 ]       │     滚动出现 0.5px outline @ 30%
├─────────────────────────────────────────────┤
│                                             │
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│   时间表。                                   │  ← display-xl (40·52·-0.5)
│   (Spectral SemiBold / 宋体 Medium)         │     ink 墨色，左对齐 spacing.lg=32
│   雌二醇凝胶　2.0 mg　·　涂抹                │  ← body-sm (13·20)
│   (mono 数值 + 思源黑体)                    │     inkSecondary 淡墨副行索引
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 剂量                                      │  ← HanaSectionHeader
│  ┃ (label·12·+0.6 · inkSecondary)           │     左侧 4px 黛蓝竖线，长度仅覆盖首行 16
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat
│   │   2.0                              │    │  ← mono 24·ink 大数值 + HanaTextField
│   │   ─────────────                    │    │     底部 1px 烟灰线 + focus 2px 黛蓝
│   │   (spacing.sm = 8)                 │    │
│   │   [mg] [mL] [片]                   │    │  ← HanaButton.secondary toggle 单位
│   ╰────────────────────────────────────╯    │     选中黛蓝 1px 边框 + 黛蓝文字
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 频率                                      │  ← HanaSectionHeader
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable selected
│   │ ┃ 每日                              │    │  ← 选中态：左 4px 黛蓝竖线 + ink
│   │ ┃ 每天的同一时段。                  │    │     未选：无竖线 + inkSecondary
│   ╰────────────────────────────────────╯    │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable
│   │   隔日                              │    │     未选态全 inkSecondary
│   │   每两日记一次。                    │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable
│   │   特定星期                          │    │
│   │   仅在选中的星期。                  │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 时段                                      │  ← HanaSectionHeader
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat 时段项 1
│   │   早　08:00              [ 删除 ]  │    │  ← label 12·inkSecondary +0.6
│   ╰────────────────────────────────────╯    │     mono 18·ink 时间 / ghost 删除
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← 时段项 2
│   │   午　12:00              [ 删除 ]  │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← 时段项 3
│   │   晚　20:00              [ 删除 ]  │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (spacing.sm = 8)                          │
│                                             │
│   [ + 添加时段 ]                            │  ← HanaButton.ghost 左对齐
│   (body·15·primary)                         │     点击弹 HanaBottomSheet.picker
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 起止                                      │  ← HanaSectionHeader
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable
│   │   开始　4 月 29 日。                │    │  ← body 15·ink + mono 日期
│   ╰────────────────────────────────────╯    │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable
│   │   结束　未定。                       │    │  ← inkSecondary "未定。" 编辑陈述
│   ╰────────────────────────────────────╯    │     有值时切 mono 日期 + ink
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 通知                                      │  ← HanaSectionHeader
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat
│   │   到时静默推送。       [ ◯───● ]    │  ← body·ink + HanaSwitch（v1.1 待补 spec）
│   ╰────────────────────────────────────╯    │
│                                             │
│   (底部 spacing.xl = 64)                    │
└─────────────────────────────────────────────┘
```

### 2.2 频率"特定星期"模式

`频率` 段切到第 3 张卡选中后，`时段` 段上方多出一段 `星期` 子选择：

```
│  ┃ 频率                                      │
│   ... (3 张频率卡，"特定星期"选中)            │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat 嵌入
│   │  [一][二][三][四][五][六][日]      │    │  ← 7 个 HanaButton.secondary toggle
│   │   ↑ 多选，已选 = 黛蓝 1px 边框 +  │    │     未选 = 月白底 + 烟灰文字
│   │     黛蓝文字；未选 = 月白底       │    │     高 44dp 触控区 + 6px 圆角
│   ╰────────────────────────────────────╯    │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│  ┃ 时段 ...                                  │
```

### 2.3 时段冲突警告（间隔 < 4h）

若新添加时段「13:00」紧接午时段「12:00」（间隔 1h < 4h），第 3 张时段卡下方插入一行编辑陈述：

```
│   ╭────────────────────────────────────╮    │
│   │   午　13:00              [ 删除 ]  │    │
│   ╰────────────────────────────────────╯    │
│   与上一时段相隔不足 4 小时。               │  ← inline body-sm·inkSubdued
│   (spacing.md = 16)                         │     左对齐 spacing.lg=32 起
```

**不阻塞保存**——仅作为编辑陈述提示，黛蓝 / 朱砂均不上，保持淡墨克制。

### 2.4 添加时段弹层（HanaBottomSheet.picker）

点击「+ 添加时段」从底部升起：

```
        ───────                         ← drag handle 32×4 / r-pill
  ┌──────────────────────────────┐
  │                              │
  │  时段                         │  ← title headline 24 · ink
  │                              │
  │     ┌────┐  ┌────┐           │
  │     │ 08 │  │ 00 │           │  ← mono 32·ink 滚轮（hour × minute）
  │     │ 09 │  │ 05 │           │     选中行黛蓝下划线
  │     │▓10▓│  │▓10▓│           │
  │     │ 11 │  │ 15 │           │
  │     │ 12 │  │ 20 │           │
  │     └────┘  └────┘           │
  │                              │
  │      [ 取消 ]   [ 添加 ]      │  ← ghost / primary，右对齐
  │                              │
  └──────────────────────────────┘
   ↑ 16px radius 顶角
   ↑ surfaceContainerLowest 背景 + scrim ink @ 32%
```

### 2.5 保存成功

`save()` 成功后触发 `HanaCelebration.trigger(context, message: l10n.celebrationScheduleSaved)`「时间表已记。」黛蓝宋体 0.4s 静默 → 1.2s 淡入 → 0.6s 停留 → 1.2s 淡出（总 ~3.4s），淡出后自动 `Navigator.pop()`。

### 2.6 加载态 / 错误态

- 加载：`HanaLoadingView.block` 一行宋体「读取中。」`inkSecondary` 居中。
- 错误：保存失败 → 顶部 `HanaToast.error`（v1.1 待补 spec，临时降级 SnackBar 但锁色 `HanaTokens.error`）显示 `_localizeValidation` 翻译后的陈述句。

---

## 3. 组件映射（每元素 → v2 组件）

| 区域 | v2 组件 | Variant | 关键 props |
|------|--------|---------|-----------|
| 顶部栏 | `HanaTopBar` | `defaultBar` | title="时间表。"，actions=[HanaButton.ghost("保存")] |
| Hero 标题 | (Text 直接) | display-xl 宋体 | "时间表。" 左对齐 spacing.lg=32 |
| 副行（药品索引）| (Text + mono) | body-sm | "{drugName}　{dosageAmount}{unit}　·　{route}" 全 inkSecondary |
| 章节标题 | `HanaSectionHeader` | default | title="剂量" / "频率" / "时段" / "起止" / "通知"，左 4px 黛蓝竖线 |
| 剂量数值输入 | `HanaTextField` | numberDecimal | mono 24·ink 大数值，底部 1px 烟灰线，focus 2px 黛蓝 |
| 单位 toggle | `HanaButton` | `secondary` | 多个并排，selected=黛蓝 1px 边框 + 黛蓝文字 |
| 频率三选 | `HanaCard` | `tappable` | 选中态左 4px 黛蓝竖线 + ink；未选 inkSecondary |
| 周几 toggle（特定星期）| `HanaButton` | `secondary` | 7 个并排（一-日），多选支持 |
| 时段列表项 | `HanaCard` | `flat` | 左 label 早/午/晚/夜 + mono 时间 + 右 ghost 删除 |
| "+ 添加时段" | `HanaButton` | `ghost` | 左对齐，body·primary，点击弹 BottomSheet |
| 时间选择弹层 | `HanaBottomSheet` | `picker` | 自绘 hour × minute mono 滚轮，actions=[ghost 取消, primary 添加] |
| 起止日期入口 | `HanaCard` | `tappable` | body "开始　{date}。" mono 日期；未定时 inkSecondary "未定。" |
| 日期选择弹层 | `HanaBottomSheet` | `picker` | 自绘月历 / 滚轮，actions=[ghost 取消, primary 选定, ghost 清除（仅结束）] |
| 通知开关 | `HanaSwitch` | default | **v1.1 待补 spec** — track inkSecondary / 选中 primary，handle onPrimary |
| 保存 CTA（顶栏）| `HanaButton` | `ghost` | AppBar action 文字按钮"保存"，ink |
| 冲突提示 | (Text 直接) | body-sm | inkSubdued"与上一时段相隔不足 4 小时。" |
| 错误验证 | (Text 直接) | body-sm | error 朱砂 + 字段下方一行陈述 |
| 庆祝反馈 | `HanaCelebration` | default | message=l10n.celebrationScheduleSaved "时间表已记。" |
| 加载态 | `HanaLoadingView` | block | "读取中。" |
| 错误 toast | `HanaToast` | error | **v1.1 待补 spec** — 临时降级 SnackBar 锁 `HanaTokens.error` |

> **明确删除**：v1 的 M3 `Card`（药品 header，行 80）、`OutlineInputBorder`（130）、`ChoiceChip` 单位选择（149）、`SegmentedButton` 频率三选（273）、`DropdownButton<int>` 次数 / N天 / 周几（296/317/338）、`ListTile` + `RoundedRectangleBorder(radius:8)` 起止日期 / 时段（177/205/397）、`Icons.medication_outlined`（90）、`Icons.calendar_today`（189/218）、`Icons.access_time`（412）、AppBar `IconButton(Icons.check)`（69）、底部 `FilledButton`（248）。

---

## 4. Tokens 引用清单

所有色 / 间距 / 圆角 / 字号 / 时长**严禁**直接 hex / 数字字面量。一律走 `HanaTokens.xxx(context)`。

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| Card 内文页 | `HanaTokens.surfaceContainerLowest(context)` |
| AppBar 米灰 | `HanaTokens.surfaceContainerHigh(context)` |
| Hero / 卡内主标题 / 选中频率卡文字 | `HanaTokens.ink(context)` |
| 副行 / 未选频率 / 未选 toggle / "未定。" | `HanaTokens.inkSecondary(context)` |
| 章节竖线 / 选中频率竖线 / 输入 focus 线 / 滚轮选中下划线 / "+ 添加时段" / Switch 选中态 / 庆祝文字 | `HanaTokens.primary(context)` |
| onPrimary（保存按钮文字、Switch handle）| `HanaTokens.onPrimary(context)` |
| 输入未 focus 底线 | `HanaTokens.outline(context)` |
| 错误验证文字 | `HanaTokens.error(context)` |
| 冲突警告陈述 | `HanaTokens.inkSubdued(context)`（如未落地，取 `inkSecondary` @ 80%） |

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `spacing.lg` = 32 |
| Hero 顶部留白 / 屏幕底部 | `spacing.xl` = 64 |
| 段落间（章节↔卡片群 / 章节↔章节）| `spacing.lg` = 32 |
| 卡间（频率三卡 / 时段列表 / 起止两卡）| `spacing.md` = 16 |
| 卡内 padding | `spacing.md` = 16 |
| 卡内段落 / 数值与单位 toggle | `spacing.sm` = 8 |
| 章节标题 → 卡片 | `spacing.md` = 16 |
| "+ 添加时段" 与最后一张时段卡间 | `spacing.sm` = 8 |
| 副行行间 | `spacing.xs` = 4 |

> 强制跨级：禁止 16 紧挨 16；卡内 16 + 卡间 16 + 章节间 32 通过"卡内→卡外→章节"层层放大达成节奏。

### 圆角
| 用途 | Token |
|------|-------|
| 卡片（HanaCard） | `radius.card` = 4 |
| 按钮（HanaButton 全 variant） | `radius.button` = 6 |
| 输入框（HanaTextField） | `radius.input` = 2 |
| BottomSheet 顶角 | `kHanaBottomSheetRadius` = 16 |

### 字体
| 用途 | Token / 字体 |
|------|------------|
| Hero「时间表。」 | `display-xl` (40/52/-0.5) Spectral SemiBold / Source Han Serif SC Medium / Noto Serif JP Medium |
| 章节 label / 单位 toggle / 时段时段 label（"早""午""晚"）| `label` (12/16/+0.6) Medium |
| 频率卡 / 起止卡主行 / 通知陈述 | `body` (15/24/0) |
| 副行 / 频率卡 body / 冲突陈述 / 错误陈述 | `body-sm` (13/20/0) |
| 剂量数值（输入大字）| `mono` 24·ink JetBrains Mono Light（mono token 加大版） |
| 时段时间（"08:00"）| `mono` 18·ink |
| 起止日期值 | `mono` 14·ink |
| BottomSheet 滚轮选中行 | `mono` 32·ink |
| 保存按钮 / "+ 添加时段"  | `body` 15 Medium |

### 动画
| 用途 | Token |
|------|-------|
| 卡片 press scale 0.98 | `motion.quick` 150ms easeOut |
| 频率卡 selected 切换（黛蓝竖线淡入）| `motion.standard` 240ms easeInOut |
| toggle 按钮选中色切换 | `motion.standard` 240ms easeInOut |
| BottomSheet 升起 / 关闭 | `motion.standard` 240ms easeInOut |
| 滚轮惯性滑动 | `motion.deliberate` 600ms（CupertinoPicker 内置参考）|
| 添加时段后列表 fadeIn 错落 | `motion.standard` 240ms × N，错落 80ms |
| 删除时段后 collapse | `motion.deliberate` 600ms easeOut |
| 庆祝静默 | 400ms 硬常量 `kHanaCelebrationSilence` |
| 庆祝淡入 / 淡出 | 1200ms `motion.deliberate` extended / `motion.fade` |

---

## 5. 交互状态

### 默认（编辑已有时间表）
- AppBar 实色米灰 + 右侧 ghost「保存」按钮（offset = 0 时无底线）
- 各段同时入场：标题 + 卡片列表 fadeIn 240ms 错落 80ms

### 剂量输入聚焦
- `HanaTextField` 底部 1px 烟灰线 → 2px 黛蓝呼吸线（240ms）
- 输入数值变更触发 `setDosageAmount(parsed)`；不合法（≤0 或非数字）时**不**立即报错，仅在保存时 emit 验证错误

### 单位 toggle 切换
- 命中后调 `setDosageUnit(unit)`
- 选中态：月白底 + 黛蓝 1px 边框 + 黛蓝文字；未选：月白底 + 烟灰 1px 边框 + 烟灰文字
- press scale 0.98 / `motion.quick`

### 频率三卡选择
- 点中某张 `HanaCard.tappable` → 调 `setFrequency(...)` 切换 sealed type
- 选中态：左 4px 黛蓝竖线（高度=卡内首行 line-height）+ 主标题 ink + body-sm ink
- 未选：无竖线 + 全 inkSecondary
- 切换时 240ms 淡入竖线 + 文字色过渡

### 频率"每日 N 次" / "隔 N 天"子参数
- v2 规范：合并到选中卡内部，不再用 `DropdownButton`
- "每日"卡选中后，卡尾追加一行：`次数　[ - ]　mono "3"　[ + ]`，左右两个 ghost 圆形按钮（**唯一允许 + / - 微 icon 的场景**）
- "隔日"卡同理：`间隔　[ - ]　mono "2"　[ + ]　日`

### 频率"特定星期"周几 toggle
- 选中"特定星期"卡后，下方插入 7 个 `HanaButton.secondary` toggle（一-日横排 + Wrap 自动换行）
- 多选支持：state 用 `Set<int>` 记录；当前 cubit 的 `WeeklyMedicationFrequency(dayOfWeek: 1)` 单值需扩展为 `Set<int> daysOfWeek`（**domain 改动，见 handoff §1**）
- 选中：黛蓝 1px 边框 + 黛蓝文字；未选：月白底 + 烟灰 1px 边框 + 烟灰文字

### 时段卡操作
- 默认每张卡左侧自动按时间贴 label：5-11 = "早" / 11-17 = "午" / 17-24 = "晚" / 0-5 = "夜"
- 点击卡主区 → 弹 `HanaBottomSheet.picker` 编辑当前时段
- 点击卡尾「删除」ghost 按钮 → 直接调 `setScheduleTimes(updated)`，列表 collapse 600ms
- 间隔 < 4h 时，卡下方插入 inline body-sm·inkSubdued「与上一时段相隔不足 4 小时。」**不阻塞**保存

### "+ 添加时段"
- 点击 → 弹 `HanaBottomSheet.picker`，初始时间根据现有最晚时段 +4h（无时段时默认 08:00）
- 确认后 append 到 `scheduleTimes`，列表新项 fadeIn 240ms

### 起止日期
- 起始默认为今日 `DateTime.now()`（从 cubit `startDate` 取）
- 点击 → 弹 `HanaBottomSheet.picker` 月历卡 / 滚轮
- 结束日期 actions 多一个 ghost「清除」按钮，调 `setEndDate(null)` → 显示"未定。"

### 通知开关
- `HanaSwitch` 默认 ON
- track inkSecondary / 选中 primary，handle onPrimary（v1.1 spec 待补落细节）

### 保存
- 顶栏 ghost「保存」点击 → `cubit.save()`
- 成功 → `HanaCelebration` 触发"时间表已记。"→ 自动 `Navigator.pop`
- 失败 → `HanaToast.error` 朱砂陈述 + 字段下方 inline 错误（如剂量 ≤ 0 → 剂量字段下方"请输入剂量。"）

### 加载态
- 整屏 `HanaLoadingView.block`：一行宋体「读取中。」inkSecondary 居中

### 错误态（保存失败）
- 不整屏切换；维持表单 + 顶部 `HanaToast.error` 一次性陈述 + inline 字段错误

---

## 6. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，padding 水平 32（spacing.lg），卡片占满 |
| 768–1024 (tablet) | 单列内文页 max-width 720px 居中（呼吸更宽，但保持杂志页宽节奏）|
| ≥ 1024 (web 桌面) | 单列内文页 max-width 720px 居中，左右各 ≥ 240px 留白；BottomSheet 在桌面降级为 v2 `HanaBottomSheet` 中央浮岛（width 480px，圆角 16，scrim 全屏）|

> mobile 是主战场。tablet / web 仅约束 max-width 避免巨字幅；BottomSheet 在桌面保持 16px 圆角不变，仅位置中浮。

---

## 7. 动画规范

| 时机 | 时长 | 曲线 | Token |
|------|------|------|-------|
| 首屏入场（章节 + 卡片 fadeIn）| 240ms × N，错落 80ms | easeInOut | `motion.standard` |
| 卡片 press scale 0.98 | 150ms | easeOut | `motion.quick` |
| 频率卡 selected 切换（竖线 + 文字色）| 240ms | easeInOut | `motion.standard` |
| toggle 按钮选中色切换 | 240ms | easeInOut | `motion.standard` |
| 输入字段 focus 线 1px → 2px 黛蓝 | 240ms | easeInOut | `motion.standard` |
| BottomSheet 升起 / 关闭 | 240ms | easeInOut | `motion.standard` |
| 滚轮惯性滑动 | 600ms 默认 | iOS spring | CupertinoPicker 内置 |
| 添加时段 fadeIn | 240ms | easeOut | `motion.standard` |
| 删除时段 collapse | 600ms | easeOut | `motion.deliberate` |
| 保存庆祝 | 静默 400 + 淡入 1200 + 停留 600 + 淡出 1200 | — | `kHanaCelebrationSilence` + `motion.deliberate` + `motion.fade` |
| AppBar 底线淡入（滚动）| 80ms | easeOut | `motion.instant` |

**绝对禁止**：粒子动画、scale > 1（弹跳放大）、translate 大位移、spring 曲线（除滚轮内置）、SegmentedButton selected 段背景填充动画（已删除组件）。

---

## 8. i18n 注意

- ja「特定の曜日」比 zh「特定星期」长 30%。频率三卡纵向排列**不**强制等高，body-sm 描述允许换 1 行。
- ja「ティースプーン」/「ミリリットル」单位 toggle 长 chip，`Wrap` `runSpacing: spacing.sm`（8）允许换 2 行，**不**横向溢出。
- ja「八時」/ "08 時" 时段时间格式特殊，保留 mono "08:00" 24h 制（v2 不分语言区分 12/24h）。
- en「Schedule.」短 → 同样左对齐 32px，不强制居中。
- 副行 mono 数字 + CJK 全角空格：`雌二醇凝胶　2.0 mg　·　涂抹`（zh）/ `Estradiol Gel　2.0 mg　·　Topical`（en）。
- 周几 toggle 标签：zh"一二三四五六日" / ja"月火水木金土日" / en"M T W T F S S"——en 双 T 不友好，spec 暂保留 7 个 toggle 单字符，handoff 阶段视觉评估是否改"Mon-Sun" 3 字符（会增宽 60%）。
- 庆祝「时间表已记。」/ ja「予定を記しました。」/ en「Schedule saved.」长度差 1.5 倍，`HanaCelebration` 内置 display-md → display-sm 自动缩放规则。

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — AppBar action / 卡片整张 / toggle 按钮 / Switch / 删除按钮 全 44dp+ |
| Semantics 完整朗读 | ✓ — 卡片 label「频率　每日　每天的同一时段　已选中」/ 时段「时段　早 8 点　删除按钮」 |
| 焦点顺序 | AppBar → Hero → 副行 → 剂量段 → 频率段（三卡） → 周几 toggle（仅特定星期） → 时段段（每张卡 + 删除按钮 + 添加按钮）→ 起止段 → 通知段 → 顶栏保存 |
| prefers-reduced-motion | ✓ — 卡片 fadeIn 跳过；BottomSheet 升起降级为瞬时；庆祝退化为 1.5s 静态显示 |
| 对比度（light）| ✓ — ink #1C1A18 on background #F4F1EA = 14.8:1（AAA） |
| 对比度（toggle 选中）| ✓ — primary #1F3A5F on background #F4F1EA = 8.6:1（AAA） |
| 对比度（dark）| ✓ — ink #E8E4DB on background #1C1A18 = 12.6:1（AAA） |
| 屏幕阅读器冲突警告 | `Semantics(liveRegion: true)` 朗读「与上一时段相隔不足 4 小时」 |
| 屏幕阅读器庆祝 | `Semantics(liveRegion: true)` 自动播报"时间表已记" |
| 表单错误关联 | 每个字段 `Semantics(textField: true, label: ..., value: ..., hint: errorMessage)`，错误时焦点跳到首个错误字段 |

---

## 10. 自我 critique-v2（短）

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处）| ✓ | ① 章节竖线（5 处但视觉等同段落标记，**视为同 1 处语法**）② 选中频率卡左 4px 竖线 + Switch 选中 ③ 输入 focus 线 / "+ 添加时段" 文字 / BottomSheet 滚轮下划线 / toggle 选中边框（视为"选中态"同 1 处语法）—— 总分类 ≤ 3 类语法槽：段落标记 / 选中态 / focus。AppBar 保存 ghost 文字按钮已退到墨色，不再算第 4 处强色。 |
| 2. 调和层次胜过投影 | ✓ | surface 4 级（background → containerLowest → containerHigh AppBar → BottomSheet containerLowest 浮岛）。零 BoxShadow / 零 BackdropFilter / 零 OutlineInputBorder / 零 RoundedRectangleBorder side（除 AppBar 滚动 0.5px outline 唯一例外 + secondary 按钮 1px 黛蓝边框 v2 允许例外）。 |
| 3. 编辑级不对称 | ✓ | Hero 左对齐 32px，右侧 70% 留白。章节竖线段落标记。**无**居中。频率三卡纵向并列陈列。"+ 添加时段" / 保存 CTA 全左对齐（顶栏保存除外，居栏右是 AppBar 惯例不算居中）。 |
| 4. 慢节奏与留白 | ✓ | 顶部留白 64px。章节间 32px。卡内 16 + 卡间 16 + 章节间 32 三级跨级。BottomSheet 升起 240ms。庆祝 0.4s 静默。 |
| 5. 内容即装饰 | ✓ | 删除全部装饰 icon（药盒 / 日历 / 时钟）。时段 label 用文字"早 / 午 / 晚 / 夜"代替 icon。冲突警告用淡墨陈述代替 ⚠ 符号。频率"每日 N 次"的"+/−"是**唯一允许微 icon**例外，因为是工具语义高频操作（spec.md §5"频率每日子参数"声明）。 |

**自审遗留风险**：
- `HanaSwitch` spec 尚未在 components/ 落地（v1.1 待补），目前 spec 暂用 Material `Switch` + `MaterialStateProperty` 锁色过渡——3.x.d 阶段补一个 v2 版开关 spec。
- `HanaToast` spec 尚未在 components/ 落地（v1.1 待补），保存失败临时降级 SnackBar 锁 `HanaTokens.error` —— 3.x.d 阶段补 toast spec。
- `HanaTextField` 数值变体（mono 24·ink 大数值 + 单位 toggle 行）的具体内边距 / 触控区还需在 components/text-field.md 补"numberDecimal large"variant，handoff 阶段对齐。
- 频率"每日 N 次"的"+/−"圆形 ghost 按钮虽然 spec §10 自审豁免，但 lint 上仍需在 today_page lint 规则之外加 schedule-editor 局部豁免。
- `WeeklyMedicationFrequency(dayOfWeek: int)` 改 `daysOfWeek: Set<int>` 是 domain 改动，破坏向后兼容——handoff §1 必须详细描述 migration 策略。

---

## 11. 与 critique-v1 的 12 个 P0 逐项消除

| critique-v1 P0 | v2 处理 |
|---------------|--------|
| 1. 整屏色 token `theme.colorScheme.*` | 全切 `HanaTokens.*(context)`，强色限 3 类语法槽 |
| 2. M3 `Card` 药品 header elevation + 投影 | 删除整 header `Card`，副行 mono 直接挂 hero 下方，无容器 |
| 3. `OutlineInputBorder` 4 边实线框 | 全切 `HanaTextField` 仅底部 1px 烟灰线 + focus 2px 黛蓝 + 圆角 2px |
| 4. 起止 / 时段 `RoundedRectangleBorder(side, radius:8)` | 全切 `HanaCard.tappable` / `HanaCard.flat` 4px 圆角 0 边框 0 投影 |
| 5. `SegmentedButton` 频率三选居中铺满 | 改 3 张 `HanaCard.tappable` 纵向并列陈列 |
| 6. 系统 `showTimePicker` 圆形钟面 | 改 `HanaBottomSheet.picker` 自绘 mono 数字滚轮（hour × minute 两列）|
| 7. 系统 `showDatePicker` M3 紫调 | 改 `HanaBottomSheet.picker` 自绘月历卡 / 滚轮 |
| 8. 装饰 icon 4 处 | 全删（药盒 / 日历 / 时钟 / AppBar 保存 check），保存改 ghost 文字按钮 |
| 9. AppBar M3 标准 | 改 `HanaTopBar.default` 实色米灰 + 右侧 ghost 文字保存 |
| 10. 字体 M3 `theme.textTheme.*` | 全切 v2 ramp：Hero Spectral SemiBold / 思源宋体；body Inter / 思源黑体；数值 + 时间 JetBrains Mono Light |
| 11. 验证错误裸 `Text(color: errorColor)` | 改 inline body-sm 朱砂 + 字段下方一行编辑陈述（句号收尾） |
| 12. 圆角 8 非 token | 全统一：卡 4 / 按钮 6 / 输入 2 / BottomSheet 16 |

> **额外消除（critique-v1 P1 顺带处理）**：
> - 水平 padding 24 → 32（spacing.lg）
> - 顶部留白 0 → 64（xl），新增 hero "时间表。"
> - 章节标题套 `HanaSectionHeader` 4 处加左竖线
> - 间距 12 / 24 / 48 三个非 token 值全部清除
> - 时段卡左侧自动贴 label「早 / 午 / 晚 / 夜」
> - 时段间隔 < 4h 冲突警告（inline body-sm·inkSubdued）
> - 频率"特定星期"`Dropdown` 单选 → 7 个 `HanaButton.secondary` toggle 多选
> - "+ 添加时段" 显式 ghost 按钮，弃用 SegmentedButton 自动 append 隐式逻辑
> - 文案"编辑药物" / "保存" → "时间表。" / "保存。" 句号收尾
> - 通知开关新段落 `HanaSwitch`（v1.1 待补）
> - 庆祝反馈 `HanaCelebration`「时间表已记。」替代静默 `Navigator.pop`

---

— 完 —
