# Notification Settings 屏开发 handoff

> Generated 2026-04-29 from `docs/design/screens/notification-settings/spec.md`
> 工程目标：`lib/features/notification/presentation/pages/notification_settings_page.dart`
> 配对 spec：`docs/design/screens/notification-settings/spec.md`
> 配对 critique：`docs/design/screens/notification-settings/critique-v1.md`

---

## 1. 改动总览（What changes）

把 v1 的"双层堆叠 bento 仪表盘"重写为 v2 的"三段落内文页 + 静音时段新功能"。**this is a rewrite + a feature add**——保留 NotificationSettingsCubit / NotificationSettingsState 已有契约（drugs / schedules），但**新增 cubit 事件 + AppSettings 字段**支持 quiet hours，**修复 per-drug 伪开关**接入 schedule.enabled 真实持久化。

**删除**：
- `_DrugNotificationCard` / `_EmptyState` 两个 inline widget（共 ~150 行）— 全部替换为 `HanaListItem` + `HanaCard.list` + `HanaEmptyState.block`
- AppBar 的 `BackdropFilter` + `ClipRRect` + `extendBodyBehindAppBar`（13 处 blur 工程债之一）
- 全局开关行的 `Container(decoration: bento 24/4 shadow)` + 圆形 icon 容器（`primaryContainer @ 50%, shape: circle`）
- per-drug 卡内的时间 stadium chip pill（`Container radius 12, primaryContainer 实填`）+ Wrap
- `Plus Jakarta Sans` 字体硬编码 4 处
- Material `Switch` 2 处 → `HanaSwitch`
- per-drug 卡内 `_isNotificationEnabled` 本地 setState 伪开关（critique P0-8）

**新增**：
- 第 3 节"静音时段"：启用开关 + 开始时间 + 结束时间（HanaBottomSheet variant=picker）
- 「测试通知」`HanaButton.ghost` 末尾按钮 + `NotificationService.showImmediate(title, body)` API
- per-drug 开关接入 `MedicationSchedule.enabled` 持久化 + 切换后调用 `SyncMedicationReminders` 重排该药通知
- 全局关闭时节 2/3 整体 `AnimatedOpacity 0.38 + IgnorePointer` 视觉联动

---

## 2. 关键依赖（Components needed）

### 已有 v2 components（components/*.md）
- `HanaTopBar.default`（top-bar.md）
- `HanaCard.list` variant（card.md）
- `HanaSectionHeader`（section-header.md）
- `HanaListItem` variants: `withSubtitle` / `switch` / `withTrailingText`（list-item.md）
- `HanaSwitch`（switch.md）
- `HanaButton.ghost` + `HanaButton.secondary`（button.md）
- `HanaBottomSheet` variant=picker（bottom-sheet.md）
- `HanaEmptyState.block` / `HanaLoadingView.block` / `HanaErrorState`
- `HanaSnackbar.show`（toast.md）

### 需补 lib（与本屏 PR 同期）
- `NotificationService.showImmediate(String title, String body)` 公共 API（lib/core/notifications/notification_service.dart）
- `NotificationService` 调度时根据 `AppSettings.quietHoursEnabled / Start / End` **跳过**或 **延迟** 该时段通知触发

> ⚠ 不允许 inline 复制 list/section/switch widget——这些 v2 components 已落 spec，`profile_page` 已抢跑使用，本屏直接复用其私有实现或等 Phase 4 抽到 `lib/core/widgets/`。**禁止**回退到 ListTile / SwitchListTile / `_SettingsCard`。

---

## 3. 视觉契约（不可妥协项）

| 项 | 值 / Token |
|---|---|
| Scaffold bg | `HanaTokens.background(context)` |
| AppBar bg | `HanaTokens.surfaceContainerHigh(context)`（无 blur） |
| 列表卡 bg | `HanaTokens.surfaceContainerLowest(context)` |
| 列表卡 radius | `HanaTokens.radius.card` = 4（**禁** 24） |
| 列表卡 elevation | 0（**禁** BoxShadow） |
| 列表卡 border | none（**禁** 2px primaryContainer border） |
| 屏幕水平 padding | `HanaTokens.spacing.lg` = 32（**禁** 24） |
| 顶部留白 | `spacing.xl` = 64 |
| 节间留白 | `spacing.lg` = 32 |
| 章节标题 → 列表卡 | `spacing.md` = 16 |
| 列表项内 padding | horiz 24 / vert 20 |
| 列表项 separator | **零 1px 实线**——靠 surface 阶差或 spacing.sm 8 |
| 章节标题字体 | `label` 12·16·+0.6 Medium，inkSecondary |
| 章节竖线 | 4px wide × 16px tall（首行高），color = primary |
| 列表项 title 字号 | `body` 15·24·0 Regular（**禁** w800 bold / Plus Jakarta Sans） |
| 列表项 subtitle 字号 | `body-sm` 13·20 inkSecondary |
| 时间副行 / trailing | `mono` 14·20 JetBrains Mono Light inkSecondary |
| Switch | `HanaSwitch` 28×16，**禁** Material `Switch` |
| 测试通知按钮 | `HanaButton.ghost`，44dp 高 |
| 黛蓝出现位置 | 返回箭头 + 章节竖线 + active Switch thumb（≤ 3 处） |

---

## 4. 数据契约（Bloc / Cubit）

**沿用现有**：`NotificationSettingsCubit` + `NotificationSettingsState`（drugs / schedules）保留。

**SettingsBloc 新增事件**（lib/features/settings/presentation/bloc/settings_event.dart）：
- `ToggleQuietHours(enabled: bool)` — 派给 SettingsBloc
- `UpdateQuietHoursStart(time: TimeOfDay)`
- `UpdateQuietHoursEnd(time: TimeOfDay)`

**NotificationSettingsCubit 新增事件**：
- `ToggleDrugReminder(drugId: String, enabled: bool)` — 写 `MedicationSchedule.enabled` + 调用 `SyncMedicationReminders` 重排该药

**AppSettings 新增字段**（lib/features/settings/domain/entities/app_settings.dart）：
- `bool quietHoursEnabled` (default false)
- `TimeOfDay quietHoursStart` (default 22:00)
- `TimeOfDay quietHoursEnd` (default 07:00)

**MedicationSchedule 已有字段**（lib/features/medication/domain/entities/medication_schedule.dart）：
- `bool enabled` — 若已存在则直接用；若缺，本屏 PR 同步补 + freezed regen + DataSource 字段

**新增 ARB keys**（lib/core/l10n/arb/app_{en,zh,ja}.arb 三语同步）：
- `notificationGlobalSection` / `notificationMedSection` / `notificationQuietSection`
- `notificationGlobalToggleTitle` / `notificationGlobalToggleSubtitle`
- `notificationGlobalDisabledHint`（节 2/3 全局禁用时副行）
- `notificationQuietEnableTitle` / `notificationQuietStart` / `notificationQuietEnd` / `notificationQuietHelpSubtitle`
- `notificationTest` / `notificationTestTitle` / `notificationTestBody`（推送内容也走 ARB）
- `notificationTestSent` / `notificationTestFailed` / `notificationPermissionDenied`
- `notificationDrugSubtitle(List<String> times)` = "08:00　·　20:00"（用全角空格分隔，而非 chip pill）

**ARB 修订**（既有 key 调性纠偏）：
- `reminderNotifBody` 删 emoji `💊`，改"{drugName} {dosage}{unit}　·　按时。"

---

## 5. 路由契约

- AppBar leading = 黛蓝返回箭头 → `context.pop()`
- 列表项跳转：
  - 静音时段「开始 / 结束」→ 不跳路由，inline `HanaBottomSheet` picker
  - "去添加"按钮（空态）→ `context.push('/drugs')`
- 测试通知按钮 → 不跳路由，inline 调用 NotificationService

---

## 6. P0 工程债清单（必须随本屏一并解决）

1. **删除 BackdropFilter blur**（DESIGN §4 / tokens §5）— 13 处之一，本屏切 `HanaTopBar` 实底。
2. **删除 PlusJakartaSans 字体硬编码**（DESIGN §3）— 4 处全切 v2 ramp。
3. **删除 stadium chip pill**（principles §5）— per-drug 时间 chip → mono 副行。
4. **删除 Material Switch**（components/switch.md）— 2 处 → HanaSwitch。
5. **修复 per-drug 伪开关**（critique P0-8）— 接入 `MedicationSchedule.enabled` 持久化。
6. **删除 inline `_DrugNotificationCard` + `_EmptyState`**（widget-pattern-inventory P0-#4）— 替换为 v2 组件。

---

## 7. 测试清单（QA）

| 测试 | 期望 |
|------|------|
| 首屏渲染 | 三节段落 + per-drug N 行 + 静音节 3 行 + 测试按钮，无 bento 圆角，无 blur，无 chip |
| 一抹强色审计 | 静态截图全屏黛蓝出现 ≤ 3 处（返回箭头 + 章节竖线 + active Switch thumb） |
| 全局开关切换 | HanaSwitch 240ms 平移；关闭分支调 cancelAllReminders；开启分支调 SyncMedicationReminders |
| 全局关闭联动 | 节 2/3 整体 opacity 0.38 + 不可点 + subtitle 切"已被「全局」关闭" |
| per-drug 切换持久化 | 切换后重启 app 状态保留；NotificationService 重排该药调度 |
| 静音时段启用切换 | 子项 opacity 0.38 / 1.0 切换；mono 时间值不消失 |
| 静音开始时间编辑 | onTap → HanaBottomSheet picker 升起 → 选 21:30 → 确认 → mono 立即更新为 "21:30" |
| 静音结束时间编辑 | 同上 |
| 静音时段生效（次日凌晨）| NotificationService 调度命中 quiet 区间 → 该通知跳过或延后到 endTime |
| 测试通知（已授权）| 立即收到本地通知 + Snackbar success |
| 测试通知（未授权）| Snackbar error "通知权限未授予。" + 引导跳系统设置 |
| 空态（drugs.isEmpty）| HanaEmptyState.block "尚未添加任何用药。" + secondary "去添加" button |
| 加载态 | HanaLoadingView.block，无 inline CircularProgressIndicator |
| 错误态 | HanaErrorState 接收 cubit message |
| Web 平台 | 通知章节正常显示（Web 端通知走 Web Notifications API），quiet hours 仍生效 |
| i18n 三语 | ja "サイレント時間" 不溢出；en "Test notification" subtitle 允许换行 |
| dark mode | ink on background 12.6:1 AAA；HanaSwitch on/off 对比度合规 |
| reduced-motion | Switch 切换瞬时；fadeIn 跳过；BottomSheet 上移退化为瞬时 |
| 触控目标 | 列表项 ≥ 64dp / Switch 触控 ≥ 56×44 / 测试按钮 ≥ 44dp / 返回箭头 ≥ 44×44 |
| 文案中性 | 通知 body 无 emoji，"按时。"句号收尾，禁性别词 |

---

## 8. 实施顺序建议（PR 拆分）

1. **PR-1（domain + service 准备）**：`AppSettings` 加 quiet hours 字段（freezed regen） + `MedicationSchedule.enabled` 字段（若缺）+ `NotificationService.showImmediate` API + `NotificationService` 调度跳过 quiet 区间逻辑 + 单测
2. **PR-2（cubit + bloc 事件）**：`SettingsBloc` 新事件 3 个 + `NotificationSettingsCubit` 新事件 1 个 + bloc_test 覆盖
3. **PR-3（本屏主体）**：`notification_settings_page.dart` 重写 + 新 ARB keys（en/zh/ja）+ 既有 ARB 调性纠偏
4. **PR-4（依赖组件抽出）**：HanaListItem / HanaSectionHeader / HanaSwitch / HanaSnackbar 从 profile_page 私有实现迁到 `lib/core/widgets/`（Phase 4 范围，本屏与 profile 并行抢跑）

> **不在本屏 PR 范围**：通知权限请求弹层（已在 onboarding 处理）/ 系统设置页面跳转入口（HanaSnackbar action）。

---

— 完 —
