# Notification Settings 屏 v1 设计 critique

> Generated 2026-04-29 from `lib/features/notification/presentation/pages/notification_settings_page.dart`
> 参照：DESIGN.md v2 / tokens.md / principles.md / widget-pattern-inventory.md
> 配对输出：`docs/design/screens/notification-settings/spec.md` + `docs/design/screens/notification-settings/handoff.md`

---

## 0. 一句话总结

v1 把"通知设置"做成**双层堆叠的 bento 仪表盘**——顶部一张"全局开关"卡（圆角 24 + primary 4% shadow + primaryContainer 圆形 icon 容器 + Plus Jakarta Sans w600 标题 + Material `Switch`），下方"用药提醒"标题之后再堆 N 张同等装饰强度的 per-drug 卡，每张内嵌时间 chip pill（primaryContainer 实底 + radius 12 + 粗体 12px），右侧再悬一个 Material `Switch`。**全屏装饰元素 ≥ 5 类**（24px 圆角 + boxShadow + 圆形 icon 容器 + stadium chip pill + AppBar BackdropFilter blur），每张卡都"喧宾夺主"。v2 必须把它压回**杂志栏目"小机关"语法**：三节段落（全局 / 服药提醒 / 静音时段），surface 阶差分组，HanaSwitch 28×16 安静长条，时间用 mono 数值副行而不是 stadium chip。

## 1. 8 个 P0 违规（block reason）

### P0-1 AppBar BackdropFilter blur(12)（DESIGN §4 / tokens §5）
v1 顶栏照搬 13 处工程债之一：`ClipRRect + BackdropFilter(blur 12) + background.withAlpha(0.8)`，再用 `extendBodyBehindAppBar: true` 让内容从 0 滚上去。v2 改 `HanaTopBar.default` 实色 surfaceContainerHigh + 滚动出现 0.5px outline @ 30%。

### P0-2 全局开关卡 + per-drug 卡 共用 bentoDecoration 5 件套（principles §2 / §5）
两类卡都套同一个 `BoxDecoration(borderRadius: 24, color: surfaceContainerLowest, border: 2px surfaceContainerLowest, boxShadow: blur 24, primary @ 10)`。**v2 全删**：圆角 4px、零边框、零 shadow、靠 surfaceContainerLowest 在 background 上的 6 个明度差自然分层。

### P0-3 圆形 icon 容器（principles §5 内容即装饰）
全局开关行左侧 40×40 `Container(decoration: primaryContainer @ 50%, shape: circle)` 包 `Icons.notifications_active`——v2 ListItem 严禁前置彩色圆形 icon，改 outlined icon 紧贴 title 左 12px 或干脆**不要 leading**（更克制）。

### P0-4 时间显示用 stadium chip pill（principles §5）
per-drug 卡内 `Wrap` 渲染 `Container(radius 12, primaryContainer 实填, padding 10/4, body bold 12 primary)` 显示 "08:00 / 20:00"。v2 圆角策略禁 stadium / 大圆角 + 时间应该用 **JetBrains Mono Light 14** 副行内联呈现（"08:00　·　20:00"），而不是装饰化 chip。

### P0-5 Plus Jakarta Sans w800/w600 圆润 sans 字体（DESIGN §3）
AppBar 标题 / 全局开关行 / 章节标题 / per-drug 药名 全部硬编码 `fontFamily: 'Plus Jakarta Sans'`——v2 字体 ramp 全切宋体（display）/ 思源黑体（body）/ JetBrains Mono Light（mono），**禁止再硬编码字体名**。

### P0-6 Material Switch（DESIGN §5 / components/switch.md）
全局 Switch + per-drug Switch 都直接用 Material `Switch(activeTrackColor: primary)`，默认尺寸 52×32 + iOS-Material 混血造型。v2 强制 `HanaSwitch` 28×16 长条 + 12dp 圆 thumb + 240ms crossfade——这是杂志"小机关"语法，不喧宾夺主。

### P0-7 缺失"静音时段"整节（spec 缺口）
v1 完全没有"静音时段"功能——夜间、工作时段、会议时段静音是用药通知 app 的标配。v2 必须新增第三节"静音时段"：开始/结束时间 picker（HanaBottomSheet variant=picker 双 TimePicker）+ 总开关 HanaSwitch。

### P0-8 per-drug 开关无持久化（"// Temporary local state for the MVP"）
`_DrugNotificationCardState._isNotificationEnabled` 是纯本地 setState，关闭后不持久化、不同步通知调度——这是**伪开关**，用户操作零意义。v2 必须把每药提醒开关接入 `MedicationSchedule.enabled` 字段（已在 entity，需补 toggle UseCase），切换后调用 `SyncMedicationReminders` 重排或取消该药的本地通知。

## 2. 6 个 P1 问题

- **P1-1 全局开关与 SettingsBloc 双源真实** — 全局通知开关读 `settings.notificationsEnabled`，但 per-drug 卡的本地 `_isNotificationEnabled` 与之无联动；全局关闭时 per-drug 行应整体灰化（opacity 0.38）+ 不响应 tap，v1 只调用 `cancelAllReminders` 但 UI 不反馈。
- **P1-2 章节标题样式不一致** — "通知设置"用 `titleLarge w800 primary + Plus Jakarta Sans`；v2 应换 `HanaSectionHeader`（label-md 12 +0.6 inkSecondary + 4px 黛蓝竖线只覆盖首行高 16px）。
- **P1-3 EmptyState 内嵌 FilledButton** — 空态用 `FilledButton.icon(Icons.add, addFirstDrugCta)`，应换 `HanaButton(variant: secondary)`（primary 在本屏要给"测试通知"或干脆不出现）。
- **P1-4 缺"测试通知"动作** — 用户配完静音时段、试音前应该能"立即测试一条通知"——v2 在第三节末尾加 `HanaButton(variant: text/ghost)` "测试通知"。
- **P1-5 加载态 inline `Center(CircularProgressIndicator)`** — 换 `HanaLoadingView.block`。
- **P1-6 错误态 inline `Center(Text(message))`** — 换 `HanaErrorState`。

## 3. 4 个 P2 问题

- per-drug 卡内 `Switch` 与 title 间距 16px 紧挨 `Wrap` chip 8px，违反"相邻间距跨级"——chip 删了之后这问题自然消失。
- 屏幕水平 padding 24 是 v2 禁止的中间值（v2 强制 spacing.lg = 32 或 spacing.md = 16），改 32。
- AppBar leading IconButton（arrow_back, primary 黛蓝）——黛蓝在子屏返回箭头消耗 1 处稀缺资源，可接受，但需计入"≤ 3 处"配额（本屏：返回箭头 + active Switch track + 测试通知 button = 3 处）。
- 通知文案中性度需复核：现有 ARB `reminderNotifBody` "Time to take your meds 💊" 含 emoji（违反 v2 §5 零 emoji），需在 ARB 同步删除（不是本屏 UI 问题，但跨性别敏感性 + 编辑级语调要求"按时。"句号收尾即可）。

## 4. 整体叙事重写

v1 想说："这是你的通知中心——每个药一张卡，每张卡都长得像首页 bento。" v2 应该说："这是这本内刊第七节·通知。三段：全局 / 服药 / 静音。文字与开关，没有别的。"

**视觉重心**：本屏没有"hero"——直接进入三节段落。每节顶部 `HanaSectionHeader` 4px 黛蓝竖线段落标记，下方一张 `HanaCard.list` 容纳 N 个 `HanaListItem`。Per-drug 行：`title` 药名（body 15 ink Regular，不再 w800）+ `subtitle` 时间 mono 副行（"08:00　·　20:00"）+ trailing `HanaSwitch`。**全屏黛蓝 ≤ 3 处**：① AppBar 返回箭头 ② 章节竖线（3 节同色块同义视觉计 1 段落标记语法）③ active Switch thumb——共 3 处，达上限。

跨性别敏感性：通知章节标题、ARB 文案中性陈述，禁"服药 N 天" / 性别词；emoji 全删；标题陈述句"按时。"句号收尾。
