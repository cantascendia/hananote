# Notification Settings 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/
> 屏幕：`lib/features/notification/presentation/pages/notification_settings_page.dart`
> 阶段：Phase 3.4.a 新稿（spec）+ 自审 critique-v2
> 配对 critique：`docs/design/screens/notification-settings/critique-v1.md`
> 配对 handoff：`docs/design/screens/notification-settings/handoff.md`
> 父屏：Profile（"偏好"节列表项 → 跳本屏）

---

## 1. 设计意图

通知设置是这本内刊的**第七节·通知章**——杂志的"小机关页"，记录读者订阅了哪些章节、什么时段保持安静。三段段落（全局 / 服药提醒 / 静音时段）顺序铺陈，每节左侧 4px 黛蓝竖线段落标记。**视觉上必须沉默**：无 hero 卡、无圆形 icon 容器、无 chip pill、无 boxShadow、无 BackdropFilter。月白底 + `HanaSectionHeader` 三处 + `HanaListItem + HanaSwitch` 组合 + 末尾一颗"测试通知" `HanaButton.text`——总信息量 ≤ N+5 行（N = per-drug 数）。

v1 vs v2 核心差异：v1 是"双层堆叠的 bento 仪表盘"（每张卡都装饰满满），v2 是"三段落的内文页"（每节一张容器卡 + 文字行）。Per-drug 时间 v1 用 stadium chip pill 装饰，v2 用 mono 数值 inline 副行——把"装饰"还给排版，把"信号"留给 Switch。

跨性别敏感性继承 onboarding：通知文案、章节标题、按钮 label 全部中性陈述；ARB 句号收尾（"按时。" / "测试通知"）；emoji 零容忍。

---

## 2. 屏幕骨架（ASCII Wireframe）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色，无 blur
│   ←  "通知"  (label-md +0.6 ink, 居中)      │     leading 黛蓝返回箭头（消耗强色 1 处）
├─────────────────────────────────────────────┤
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│  ┃ 全局                                      │  ← HanaSectionHeader
│  ┃ (label-md +0.6 inkSecondary + 4px 黛蓝竖线)│
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.list
│   │  通知                         [⏤●]│    │  ← HanaListItem (trailing=HanaSwitch)
│   │       关闭后所有提醒不再发送       │    │     subtitle body-sm inkSecondary
│   ╰────────────────────────────────────╯    │
│                                             │
│   (节间 spacing.lg = 32)                    │
│                                             │
│  ┃ 服药提醒                                  │  ← HanaSectionHeader
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │
│   │  雌二醇                       [⏤●]│    │  ← HanaListItem (withSubtitle + switch)
│   │       08:00　·　20:00              │    │     subtitle = mono 14 inkSecondary
│   ├────────────────────────────────────┤    │
│   │  螺内酯                       [●⏤]│    │
│   │       09:00                        │    │
│   ├────────────────────────────────────┤    │
│   │  孕酮                              │    │  ← 全局关闭时整个卡 opacity 0.38
│   │       21:00                  [⏤●]│    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (空态：HanaEmptyState.block)              │
│   "尚未添加任何用药。"                       │
│   [HanaButton.secondary "去添加"]           │  ← onTap → context.push('/drugs')
│                                             │
│   (节间 spacing.lg = 32)                    │
│                                             │
│  ┃ 静音时段                                  │  ← HanaSectionHeader
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │
│   │  启用静音时段                [⏤●]│    │  ← HanaListItem (switch)
│   ├────────────────────────────────────┤    │
│   │  开始                       22:00 │ ›   │  ← trailing mono + chevron
│   │       (启用后此时段静默通知)       │    │  ← subtitle body-sm
│   ├────────────────────────────────────┤    │
│   │  结束                       07:00 │ ›   │
│   ╰────────────────────────────────────╯    │
│                                             │     onTap → HanaBottomSheet variant=picker
│                                             │     单 TimePicker，确认后派 cubit event
│                                             │
│   (节间 spacing.lg = 32)                    │
│                                             │
│           [ 测试通知 ]                       │  ← HanaButton.ghost / text · 居中或左
│                                             │     onTap → 立即触发一条本地通知
│                                             │
│   (底部留白 spacing.xl = 64)                │
└─────────────────────────────────────────────┘
```

**空态**（drugs.isEmpty）：`HanaEmptyState.block` 替代 v1 的 inline `_EmptyState`——居中陈述"尚未添加任何用药。" + `HanaButton.secondary "去添加"`。
**加载态**：`HanaLoadingView.block`。
**错误态**：`HanaErrorState`（cubit error message 入参）。
**全局关闭态**：节 2 + 节 3 整体 `opacity: 0.38` + `IgnorePointer`，subtitle 副行"已被「全局」关闭"提示。

---

## 3. 章节结构（3 节 + 末尾按钮）

| # | 节名 (zh) | 节名 (en) | 节名 (ja) | 列表项 |
|---|----------|----------|----------|-------|
| 1 | 全局 | Global | 全体 | 通知（withSubtitle + switch） |
| 2 | 服药提醒 | Medication | 服薬リマインダー | per-drug N 行（withSubtitle + switch）/ 空态 |
| 3 | 静音时段 | Quiet hours | サイレント時間 | 启用静音（switch）/ 开始（mono + chevron）/ 结束（mono + chevron） |
| 末 | （测试通知按钮） | Test notification | テスト通知 | HanaButton.ghost |

---

## 4. 组件映射

| 区域 | v2 组件 | Variant | 关键 props / 备注 |
|------|--------|---------|---------|
| 顶部栏 | `HanaTopBar` | default | title=l10n.notificationSettings，leading=back arrow（黛蓝），无 actions |
| 章节标题 | `HanaSectionHeader` | default | label-md +0.6 inkSecondary + 4px 黛蓝竖线（覆盖首行 16px） |
| 列表卡容器 | `HanaCard` | list | surfaceContainerLowest, radius 4, padding 0 |
| 列表项 | `HanaListItem` | withSubtitle / switch / withTrailingText | trailing 槽容纳 HanaSwitch / mono 时间 + chevron |
| 开关 | `HanaSwitch` | default | 28×16 / activeColor=primary / 240ms |
| 时间 picker | `HanaBottomSheet` | picker | 单 TimePicker（开始 / 结束分别打开） |
| 测试通知按钮 | `HanaButton` | ghost | label="测试通知"，44dp 高 |
| 空态 | `HanaEmptyState` | block | 配 HanaButton.secondary "去添加" |
| 加载态 | `HanaLoadingView` | block | — |
| 错误态 | `HanaErrorState` | — | 接收 cubit error message |
| 操作反馈 | `HanaSnackbar.show` | success / error | "测试通知已发送。" / "发送失败。" |

---

## 5. Tokens 引用清单

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| 列表卡容器 | `HanaTokens.surfaceContainerLowest(context)` |
| AppBar 实底 | `HanaTokens.surfaceContainerHigh(context)` |
| 列表项 title | `HanaTokens.ink(context)` |
| 列表项 subtitle / mono trailing | `HanaTokens.inkSecondary(context)` |
| 章节竖线 / Switch active / 返回箭头 | `HanaTokens.primary(context)` |
| Switch track off | `HanaTokens.outline(context).withValues(alpha: 0.15)` |

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `spacing.lg` = 32 |
| 顶部留白（AppBar 下） | `spacing.xl` = 64 |
| 章节标题 → 列表卡 | `spacing.md` = 16 |
| 节与节之间 | `spacing.lg` = 32 |
| 列表项内 padding | horiz 24 / vert 20（HanaListItem 内置） |
| 屏幕底部 | `spacing.xl` = 64 |

> 强制跨级：xl(64) → lg(32) → md(16) → 列表项内 20。

### 圆角
| 用途 | Token |
|------|-------|
| 列表卡容器 | `radius.card` = 4 |
| 测试通知按钮 | `radius.button` = 6 |
| HanaSwitch thumb | pill 999（系统例外） |
| HanaBottomSheet（picker） | top 16（系统例外） |

### 字体
| 用途 | Token |
|------|-------|
| AppBar title | `label` 12·16·+0.6 Medium ink |
| 章节标题 | `label` 12·16·+0.6 Medium inkSecondary |
| 列表项 title（药名 / 通知 / 启用静音 / 开始 / 结束） | `body` 15·24·0 Regular ink |
| 列表项 subtitle | `body-sm` 13·20·0 inkSecondary |
| 时间副行 / trailing mono | `mono` 14·20 JetBrains Mono Light inkSecondary |
| 测试通知按钮 | `body` 15·24·0 Medium ink |

### 动画
| 用途 | Token |
|------|-------|
| 列表项 press scale | `motion.quick` 150ms easeOut → 0.98 |
| HanaSwitch 切换 | `motion.standard` 240ms easeInOut |
| 章节入场 fadeIn | `motion.standard` 240ms 错落 80ms |
| HanaBottomSheet picker 进出 | 240ms 上移 / fadeOut |

---

## 6. 交互状态

### 默认
- 三节列表依次 fadeIn `motion-standard` 240ms 错落 80ms
- AppBar 实色无底线（offset = 0）

### 全局通知开关切换
- HanaSwitch onChanged → `SettingsEvent.toggleNotifications(enabled: bool)`
- 关闭分支 → `getIt<NotificationService>().cancelAllReminders()`
- 开启分支 → `getIt<SyncMedicationReminders>().call()`
- **视觉联动**：全局关闭时节 2 + 节 3 整体 `AnimatedOpacity 0.38 / IgnorePointer`，subtitle 切"已被「全局」关闭"

### Per-drug 切换
- HanaSwitch onChanged → cubit 派 `ToggleDrugReminder(drugId, enabled)`（**新事件**）
- cubit 写 `MedicationSchedule.enabled` + 重排该药通知调度
- 失败回滚：HanaSnackbar.error("切换失败。")

### 静音时段「启用」开关
- onChanged → cubit 派 `ToggleQuietHours(enabled)`（**新事件**）
- 关闭后下方"开始/结束"两行 `opacity 0.38 + IgnorePointer`，但仍可见时间值

### 静音「开始 / 结束」时间编辑
- onTap → `HanaBottomSheet.show(variant: picker, child: TimePicker)`
- 用户拖滚选时间 → Confirm → cubit 派 `UpdateQuietHoursStart(time)` / `UpdateQuietHoursEnd(time)`
- mono trailing 实时更新

### 「测试通知」按钮
- onTap → `getIt<NotificationService>().showImmediate(title: l10n.testNotificationTitle, body: l10n.testNotificationBody)`
- 成功 → HanaSnackbar.success("测试通知已发送。")
- 失败（权限拒绝）→ HanaSnackbar.error("通知权限未授予。")+ 引导跳系统设置

---

## 7. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，水平 padding 32，列表卡占满 |
| 768–1024 (tablet) | 单列内文页 max-width 720px 居中 |
| ≥ 1024 (web 桌面) | 单列居中 720，左右对称留白；不放浮岛 |

---

## 8. i18n 注意（最长文案预测）

| key | en | zh | ja | 最长 |
|-----|----|----|----|------|
| notificationSettings | Notifications | 通知 | 通知設定 | ja 4 字 |
| notificationGlobalSection | Global | 全局 | 全体 | en 6 字 |
| notificationMedSection | Medication | 服药提醒 | 服薬リマインダー | **ja 9 字** |
| notificationQuietSection | Quiet hours | 静音时段 | サイレント時間 | **ja 8 字** |
| notificationGlobalToggleSubtitle | When off, all reminders are silenced | 关闭后所有提醒不再发送 | オフにするとすべての通知が停止 | **ja 16 字** |
| notificationQuietEnableTitle | Enable quiet hours | 启用静音时段 | サイレント時間を有効化 | **ja 11 字** |
| notificationQuietStart | Start | 开始 | 開始 | en 5 字 |
| notificationQuietEnd | End | 结束 | 終了 | en 3 字 |
| notificationTest | Test notification | 测试通知 | テスト通知 | en 17 字 |
| notificationGlobalDisabledHint | Disabled by Global | 已被「全局」关闭 | 「全体」によりオフ | **zh 8 字** |

**排版兼容规则**：
- 列表项 title 允许 `Wrap` 两行；超 2 行截断 + ellipsis
- subtitle 允许 2 行（mono 时间副行固定 1 行）
- mono trailing（22:00 / 07:00）固定 `mono 14 / line 20`，不为 locale 缩字

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — 列表项 ≥ 64dp / Switch 触控扩到 56×44 / 测试按钮 44dp |
| Semantics | ✓ — Switch 朗读 "通知，开关，已开启"；时间项朗读 "开始 22:00，按钮" |
| 焦点顺序 | AppBar back → 全局 Switch → per-drug Switch（按列表顺序）→ 静音 Switch → 开始 → 结束 → 测试通知 |
| prefers-reduced-motion | ✓ — Switch 切换瞬时；fadeIn 跳过 |
| 对比度 | ✓ — ink on background 14.8:1 (AAA) / Switch on track 11.4:1 (AAA) |
| dynamic type | ✓ — title body 15 / subtitle body-sm 13 / mono 14，全部支持系统字号缩放 |
| 全局禁用态 | ✓ — opacity 0.38 + IgnorePointer + Semantics enabled=false，朗读 "已被全局关闭" |

---

## 10. 自审 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色 ≤ 3 处 | ✓ | ① 返回箭头 ② 章节竖线（3 节同色块同义视觉计 1 处段落标记语法）③ active Switch thumb（按需）。共 3 处达上限。测试按钮 ghost 不消耗黛蓝。 |
| 2. 调和层次胜过投影 | ✓ | 零 BoxShadow / 零 BackdropFilter / 零 border。列表卡靠 surfaceContainerLowest vs background 6 个明度差。 |
| 3. 编辑级不对称 | ✓ | 章节竖线段落标记。测试按钮 ghost 可左对齐 32 或居中（不强势）。AppBar 标题虽居中但 leading 偏左破对称。 |
| 4. 慢节奏与留白 | ✓ | xl(64) / lg(32) / md(16) 跨级，节间不挤压。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零彩色 icon 圆形容器 / 零 stadium pill。时间用 mono 副行。 |

**遗留风险**：
- "静音时段"功能依赖新增 cubit 事件（`ToggleQuietHours` / `UpdateQuietHoursStart` / `UpdateQuietHoursEnd`）+ AppSettings 新增字段（`bool quietHoursEnabled` / `TimeOfDay quietHoursStart` / `TimeOfDay quietHoursEnd`）+ NotificationService 调度时跳过 quiet 区间。Phase 4 落地。
- 「测试通知」依赖 NotificationService 加 `showImmediate(title, body)` API（v1 仅 `cancelAllReminders` 公开）——本屏 PR 同时补。
- per-drug 开关持久化依赖 `MedicationSchedule.enabled` toggle UseCase——若未实现则该开关仍为伪开关（critique P0-8）。本屏 PR **必须**一并解决，否则禁止 merge。

---

— 完 —
