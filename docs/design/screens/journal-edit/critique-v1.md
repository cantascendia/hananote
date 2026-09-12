# Journal Edit 屏 v1 视觉审查 (critique-v1)

> Generated 2026-04-29
> 屏幕：`lib/features/journal/presentation/pages/journal_edit_page.dart` (273 行)
> 上游基准：`DESIGN.md` v2 + `docs/design/design-system/v2/{tokens.md, principles.md, components/*.md}`
> 配对 spec：`./spec.md`

---

## 1. 一句话定性

v1 的 Journal Edit 是**一张挂着 Material InputChip 与 emoji circle 的"心情打卡表"**——它把「写日记」这个最克制、最私密的动作做成了 Mood Tracker app 的标准 SaaS 件——和 v2「在内刊里写自己的页」彻底相反。问题不是缺组件，是**叙事错了**：v1 让用户先选 emoji（😢/😔/😐/😊/🥰）再写字、把心情格式化成五个表情，把日期信息整个丢失，把标签做成 Material 圆胶囊——五处违反「内容即装饰」「一抹强色」「编辑级不对称」三条原则。

---

## 2. 逐项 P0（必须 block-merge）

### P0-1 Mood selector 用 emoji 圆——破坏「零 emoji + 内容即装饰」
- **位置**：line 186-219 `_buildMoodSelector()`
- **现状**：5 个 emoji（😢/😔/😐/😊/🥰）在水平 `SingleChildScrollView` 里铺开，选中态加 `HanaColors.primary.withAlpha(26)` 圆形染色 + 字号从 24 跳到 32。
- **违反**：原则 5「零 emoji」（用户可见文案 / 装饰）+ 原则 1（圆形染色 + emoji 把色彩注意力分散到 5 处，黛蓝在选中态变成"心情 chip 背景"——稀缺感全无）+ DESIGN.md §5「严禁装饰性 emoji」。
- **额外问题**：emoji 在 ja/zh 不同 OS 渲染差异巨大（iOS 拟人化 / Android 平面化 / Win Segoe），破坏「克制东亚」调性；用户无法靠 emoji 朗读屏幕（a11y semanticLabel 缺失）。
- **修法**：v2 改 `HanaButton.secondary` 5 个文字 toggle，按用户要求「好 / 平 / 累 / 沉 / 激动」（覆盖 MoodLevel 5 档语义），未选 = 月白底 + 黛蓝 1px 边框 + 黛蓝文字；选中 = 黛蓝实色 + 雪宣文字。一屏选中态**最多 1 处黛蓝实色**（=primary 色用一次的稀缺）。详 spec.md §3.2。

### P0-2 标签用 Material `InputChip` + stadium 9999——双重违反
- **位置**：line 221-272 `_buildTagsSelector()` + line 261-264
- **现状**：`InputChip(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)))`，5 个预设标签（开心/焦虑/平静/疲惫/充满希望）在 `Wrap` 里。选中态用 `HanaColors.primaryContainer` 染色。
- **违反**：原则 4 严禁清单「圆角 ≥ 8px」+「Stadium / pill button」+ DESIGN.md §7「严禁 Stadium 默认场景」。`InputChip` 是 Material 件，与 v2「印章不糖果」按钮哲学冲突。
- **额外问题**：5 个标签三选一不限制——若用户全选则 5 个胶囊全填黛蓝色，黛蓝立刻贬值成"分类色"（v1 record 屏踩过同样的坑）。
- **修法**：保留**多选**语义但视觉换骨：用 `HanaButton.secondary` toggle（与 mood 同件复用），5 个标签 `Wrap` 排列，6px 圆角，不染色——选中靠 1px 黛蓝边框 → 黛蓝实色边 + 黛蓝文字 + accentMuted 远黛底。**总稳态黛蓝 ≤ 3 处**强制：5 个 mood + 5 个 tag 同屏 = 最多 1+3 选中（spec.md §3.4 给出节流策略）。

### P0-3 日期信息整个丢失——违反"日期 hero" 写作叙事
- **位置**：整屏（line 100-184 build）
- **现状**：日记保存时 `now = DateTime.now()` (line 68) 自动写入；UI 完全不显示「正在写哪一天的日记」。AppBar title 仅 "写日记" / "编辑日记"。
- **违反**：DESIGN.md「编辑级东亚」叙事——日记没有日期等于"在白纸上写"，不是「内刊的某一页」。Today 屏 hero「早。」+ display-md「4 月 28 日」+ body-md「周二」已建立日期 hero pattern，Journal Edit 必须复用。
- **额外问题**：编辑既有日记时（`existingEntry != null`）UI 仍不展示原日期，用户不知道在改"哪一天"——存在改错日期的认知风险。
- **修法**：spec.md §2 顶部 hero 段强制 `display-md "4 月 28 日"` + `body-md inkMuted "周二"`，新建用 `existingEntry.date` 或 `now`，编辑用 `existingEntry.date`；点击 hero 触发 `HanaBottomSheet.picker` 改日期（可空——保存仍用当前日期为默认）。

### P0-4 文本输入用 `TextField + InputBorder.none`——丢"呼吸线"语法
- **位置**：line 154-176
- **现状**：`TextField(maxLines: null, expands: true, decoration: InputDecoration(border: InputBorder.none, focusedBorder: InputBorder.none, ...))` 全去边框；hint 用 `onSurfaceVariant.withAlpha(128)` 旧 token。
- **违反**：表面看"无边框"是 v2 风，实则**完全没线**——丢失了 v2 输入语义关键的 `focus 时底部 2px 黛蓝呼吸线`（HanaTextField §States），用户看不到当前焦点反馈。中文输入法候选条遮挡时焦点状态不明。
- **修法**：换 `HanaInput.multiline`（minLines 8, maxLines null, 自动撑高），idle 1px 烟灰底线 / focus 2px 黛蓝呼吸线 240ms。详 spec.md §3.3。

### P0-5 AppBar 字体 / 居中 / 图标 CTA——三件套违反编辑级
- **位置**：line 105-144
- **现状**：`AppBar(centerTitle: true)` + `fontFamily: 'Plus Jakarta Sans'` + `actions: IconButton(Icons.check_circle_outline)` + `IconButton(Icons.arrow_back)`。
- **违反**：原则 3「居中是默认懒惰，v2 强制偏移」+ tokens §2 v1 字体 Plus Jakarta Sans 已 deprecate（必须 Spectral / 思源宋体）+ 原则 5「内容即装饰」（save 用图标承担动作语义错位）。
- **修法**：换 `HanaTopBar.defaultBar` 实色米灰 + 滚动 outline；leading ghost 返回 icon-only 保留；title「写一篇。」/「编辑此页。」**左对齐 32px**；trailing 改 `HanaButton.ghost` 文字 "保存。"（同 add-drug spec §2.2 模式）。

---

## 3. P1（应 block，但可后续 PR）

| # | 位置 | 现状 | 修法 |
|---|------|------|------|
| P1-1 | line 104 | `backgroundColor: HanaColors.surfaceContainerLow` 旧 token | 切 `HanaTokens.background(context)` |
| P1-2 | line 159-167 | TextField textStyle 用 `Theme.bodyLarge` | 切 v2 `body` (15·24) Inter / 思源黑体；行高 CJK 1.7 起步（=line-height 26 起） |
| P1-3 | line 228-235 | 标签段 `Text "添加标签"` label 无 tracking +0.6 + 下方仅 8px 间距 | 改 `label-md +0.6 inkSecondary` + 章节段落标记结构（**不**加竖线，详 spec §3.4 规避一抹强色超限）|
| P1-4 | line 60-97 | 删除既有日记入口缺失（编辑模式无删除按钮） | spec §3.5 在 AppBar overflow 加 ghost「删除。」→ `HanaConfirmDialog.destructive` |
| P1-5 | 整屏 | 无下拉关闭键盘行为 | TextField 外层 `GestureDetector(onTap: FocusScope.of(context).unfocus)` |
| P1-6 | line 122-143 | `_isSaving` 用 `CircularProgressIndicator` (Material 圆环) | 改 `HanaButton.ghost(isLoading: true)`，loading 用 onPrimary 色描边圆 |
| P1-7 | i18n | `presetTagHappy / Anxious / Calm / Tired / Hopeful` ARB 值带情绪化中文（"开心"/"充满希望"）| spec §6 改克制陈述（"喜" / "安" / "倦" / "沉" / "起" — 单字编辑体）+ helper 文案表 |
| P1-8 | line 92-96 | `getIt<RecordBloc>().add(refresh)` 调用 hidden side-effect | 保留逻辑，但 handoff §1 注明这是**唯一允许的跨 feature 直调**（lazySingleton 强约束） |

---

## 4. P2（nit，可记入跟进）

- line 27 `_contentController` 未做 `dispose` 路径下的草稿保留——长篇日记中途返回会丢失。建议未来引入 draft 自动保存（不在本 PR 范围）。
- line 33-39 `_presetTags` 把 ARB 字符串数组 inline 计算——可未来抽 enum + l10n extension（DEC-042/043 模式）。
- line 47-50 `_selectedTags.addAll(widget.existingEntry!.tags!)` 未去重——若 entity 含重复 tag 会双显。

---

## 5. v1 vs v2 视觉叙事差异（一句话）

| 维度 | v1 | v2 |
|------|----|----|
| 整体隐喻 | 心情打卡表 | 在内刊里写自己的页 |
| 心情表达 | emoji 圆（5 个图） | 文字 toggle（5 个字） |
| 标签视觉 | Material InputChip 圆胶囊 | HanaButton.secondary 6px 直角 toggle |
| 日期 | 不显示 | display-md hero + 周名副行 |
| 输入框 | 无边框 = 无反馈 | 无外框 + focus 2px 黛蓝呼吸线 |
| AppBar | 居中 + 图标 save | 左对齐 + 文字 "保存。" |
| 字体 | Plus Jakarta Sans | Spectral / 思源宋体 / Noto Serif JP |
| 一抹强色 | 5 处（mood 选中圆 / chip 选中色 / save 图标 / back 图标 / focus...） | ≤ 3 处稳态（mood 实色 1 + tag 边框 ≤ 2） |

— 完 —
