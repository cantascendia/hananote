# Profile 屏开发 handoff

> Generated 2026-04-29 from `docs/design/screens/profile/spec.md`
> 工程目标：`lib/features/settings/presentation/pages/profile_page.dart`
> 配对 spec：`docs/design/screens/profile/spec.md`
> 配对 critique：`docs/design/screens/profile/critique-v1.md`

---

## 1. 改动总览（What changes）

把 v1 的"彩色 bento 仪表盘"重写为 v2 的"奥付页风格列表"。**this is a rewrite, not a refactor**——保留 SettingsBloc / SettingsState / Cubit 事件契约，**仅 presentation 层从头重做**。

**删除**：
- `_SquareCard` / `_ListTileItem` / `_ButtonRowItem` / `_bentoDecoration` / `_bentoSeparator` / `_showSnackBar` 6 个 inline helper（共 200+ 行）
- AppBar 的 `BackdropFilter` + `ClipRRect` + `Icons.notifications` action（通知入口下沉到"偏好"节）
- 顶部 `CircleAvatar` 头像 + `displayName + HRT pill` 三件套——重写为 hero（display-xl + mono 副行，**无头像**）
- 顶部"我的用药"卡 + "库存 / 用药计划"双拼方块——**整块删除**，搬出 Profile（用药管理不在 Profile 屏的职责内）
- HRT 第 N 天的 stadium pill（radius 9999）— 改为 mono 副行

**新增**：
- 5 节章节结构：（hero 无标题）/ 数据 / 隐私 / 偏好 / 关于 + 末尾"退出"按钮
- "检查更新"列表项（v1.2.0 update_service 已在产，UI 入口缺失）
- "存储用量"列表项（需 SettingsState 新增 `storageUsage` 字段，data 层补 `getStorageUsage()` UseCase）
- "退出"按钮（ghost · 朱砂文字 · 末尾居中或左对齐均可）

---

## 2. 关键依赖（Components needed）

### 已有 v2 components
- `HanaTopBar.default`（components/top-bar.md）
- `HanaCard.list` variant（components/card.md）
- `HanaButton.ghost` + `HanaButton.primary`（components/button.md）
- `HanaConfirmDialog` variant=destructive（components/confirm-dialog.md）
- `HanaBottomSheet` variant=action-sheet（components/bottom-sheet.md）
- `HanaErrorState` / `HanaLoadingView.block` / `HanaEmptyState.page`

### v1.1 待补（profile 屏抢跑使用，handoff 需提示工程在 Phase 4 落地正式 spec）
- **`HanaListItem`** — variants: `default` / `withSubtitle` / `switch` / `withTrailingText` / `destructive`；padding horiz 24 / vert 20；**无前置彩色圆形 icon 容器**
- **`HanaSectionHeader`** — label-md +0.6 inkSecondary + 4px 黛蓝竖线（覆盖首行高 16px）；今 today 屏已临时 inline 使用，本屏抢跑同款实现
- **`HanaSwitch`** — activeColor=primary, trackColor=accentMuted, 240ms 切换
- **`HanaSnackbar.show`** — 替代 inline `ScaffoldMessenger` 调用

> ⚠ 工程实施时若 HanaListItem / HanaSectionHeader / HanaSwitch 尚未落 lib，profile_page 内可临时 inline 实现，但 **必须** 严格遵守本 handoff §3 的视觉规范，且抽到 `lib/features/settings/presentation/widgets/` 私有文件，**不**回退到 ListTile / SwitchListTile / `_SettingsCard`。Phase 4 再迁出。

---

## 3. 视觉契约（不可妥协项）

| 项 | 值 / Token |
|---|---|
| Scaffold bg | `HanaTokens.background(context)` |
| AppBar bg | `HanaTokens.surfaceContainerHigh(context)`（无 blur） |
| 列表卡 bg | `HanaTokens.surfaceContainerLowest(context)` |
| 列表卡 radius | `HanaTokens.radius.card` = 4（**禁** 24） |
| 列表卡 elevation | 0（**禁** BoxShadow） |
| 列表卡 border | none（**禁** primaryContainer @ 30% border） |
| 屏幕水平 padding | `HanaTokens.spacing.lg` = 32（**禁** 24） |
| Hero 顶部留白 | `HanaTokens.spacing.xl` = 64 |
| 节间留白 | `spacing.xl` 64 (hero→第 1 节) / `spacing.lg` 32（其余节间） |
| 章节标题 → 列表卡 | `spacing.md` = 16 |
| 列表项内 padding | horiz 24 / vert 20 |
| 列表项 separator | **零 1px 实线**——靠 surface 阶差或纯 spacing.sm 8 |
| Hero 字体 | `display-xl` 宋体 Medium（CJK） / Spectral SemiBold（西文） |
| Hero 副行 | `mono` JetBrains Mono Light（"HRT 第 N 天　·　起始 YYYY-MM-DD"） |
| 章节标题字体 | `label` 12·16·+0.6 Medium，inkSecondary |
| 章节竖线 | 4px wide × 16px tall（首行高），color = `HanaTokens.primary(context)` |
| 列表项 title 字号 | `body` 15·24·0 Regular（**禁** w800 bold） |
| 列表项 trailingText 字号 | `mono` 14·20（日期 / 版本号 / 容量）or `body-sm` 13·20（语言名 / 主题名） |
| chevron | size 16, color `inkSecondary` @ 60%（destructive 项用 `error`） |
| Switch | activeColor primary / trackColor accentMuted |
| destructive title 颜色 | `HanaTokens.error(context)` |
| 朱砂出现位置 | "清除所有数据"标题 + chevron + 退出按钮文字（共 2-3 处，朱砂不算黛蓝配额） |

---

## 4. 数据契约（Bloc / Cubit）

**沿用现有**：`SettingsBloc` + `SettingsEvent` + `SettingsState`，**不动**。

**事件**（已有，复用）：
- `LoadSettingsDashboard` — 初始化
- `ToggleAppLock(enabled)` / `TogglePrivacyMode(enabled)` / `ToggleBiometric(enabled)`（生物识别 v1 缺，加）
- `ExportDataEvent` / `SettingsEvent.importBackup(jsonString)` / `SettingsEvent.generatePdfReport(...)`
- `WipeSettingsData`
- `SettingsEvent.checkForUpdate`（**新增**——调用 update_service）
- `SettingsEvent.signOut`（**新增**——清除 session）

**State 字段需补**：
- `int storageUsageBytes` — "存储用量" 显示用
- `DateTime? lastUpdateCheckAt` / `String? availableUpdateVersion` — "检查更新" 子标题与未读标记
- `bool biometricEnabled` / `bool biometricSupported`（Web 端 false）— 隐私节"生物识别"开关；Web 平台需在 UI 层根据 `kIsWeb` 隐藏整行（不灰化）

**SnackBar 文案 keys（沿用 ARB，无需新增）**：`exportSuccess` / `exportFailed` / `pdfSuccess` / `pdfFailed` / `importSuccess(count)` / `importFailed`。

**新增 ARB keys**（lib/core/l10n/arb/app_{en,zh,ja}.arb 三语同步）：
- `profileSectionData` / `profileSectionPrivacy` / `profileSectionPreferences` / `profileSectionAbout`
- `profileItemStorageUsage` / `profileItemCheckUpdate` / `profileItemTheme` / `profileItemLanguage`
- `profileItemBiometric` / `profileItemSignOut`
- `profileNoName`（hero 空态）= "无名" / "Anonymous" / "名前未設定"
- `profileHrtSubtitle(int days, String startDate)` = "HRT 第 {days} 天　·　起始 {startDate}" 等
- `profileUpdateLastChecked(String when)` / `profileUpdateAvailable(String version)` / `profileUpdateLatest`
- `profileWipeConfirmTitle` = "清除所有数据后不可恢复。" + `profileWipeConfirmMessage`

---

## 5. 路由契约

- AppBar 无 leading（root tab）/ 无 actions（v1 的 settings gear + notifications 删除）
- 列表项跳转：
  - 主题 / 语言 → `/settings`（settings_detail_page，Phase 3.4 重设计）
  - 通知 → `/notification_settings`
  - 隐私政策 / 使用条款 → `/legal/privacy` / `/legal/terms`
  - 检查更新 → 不跳路由，inline 触发 update_service + 实时更新 subtitle
  - 清除数据 → HanaConfirmDialog（**不**跳路由）
  - 退出 → HanaBottomSheet 确认后 context.go('/')

---

## 6. P0 工程债清单（必须随本屏一并解决）

1. **删除 `_SettingsCard` 14+ 处复制**（widget-pattern-inventory P0-#4）— Profile 屏 + settings_detail_page.dart 共 14+ 处 inline `_SettingsCard` / `_ListTileItem` / `_ButtonRowItem`，本屏先收口 Profile 7+ 处，settings_detail 留 Phase 3.4。**禁止**新代码再 inline 写 `_bentoDecoration`。
2. **删除 BackdropFilter blur**（DESIGN §4 / tokens §5）— Profile AppBar 是 13 处 blur 工程债之一，本屏切 `HanaTopBar` 实底。
3. **删除 PlusJakartaSans 字体硬编码**（DESIGN §3）— `fontFamily: 'Plus Jakarta Sans'` 4 处，全切 v2 ramp。
4. **删除 stadium pill（HRT day）** — radius 9999 包裹 HRT 计数 → 改 mono 副行 inline。
5. **删除粉色 placeholder 头像** — `CircleAvatar(backgroundColor: primaryContainer)` 整块删除。
6. **替换 inline AlertDialog** — 2 处（importBackup 确认 + wipeAllData 确认）→ HanaConfirmDialog。

---

## 7. 测试清单（QA）

| 测试 | 期望 |
|------|------|
| 首屏渲染 | hero displayName + 5 节列表 + 退出按钮，无头像，无 bento 圆角，无 blur |
| 一抹强色审计 | 静态截图全屏黛蓝出现 ≤ 3 处（章节竖线 + active Switch + tab 下划线） |
| 应用锁切换 | Switch 240ms 平移 + track 色 crossfade + 状态持久化 |
| 隐私模式切换 | subtitle 实时切"已开启 / 已关闭" |
| 清除所有数据 | HanaConfirmDialog destructive 出现 → 确认后 context.go('/') |
| 退出 | HanaBottomSheet action-sheet 出现 → 确认后清 session |
| 检查更新（无新版本）| subtitle 切"已是最新版"，无未读标记 |
| 检查更新（有新版本）| subtitle 切"发现 1.2.1"，title 右侧出现未读标记 |
| 导出备份 | SnackBar 流转 in_progress → success/failed |
| 导入备份 | filePicker → HanaConfirmDialog → SnackBar |
| 生成 PDF | SnackBar 流转 |
| Web 平台 | 生物识别行隐藏（不灰化），file_picker fallback 到上传 input |
| i18n 三语 | ja "通知設定" / en "Notifications" / zh "通知"——列表项不溢出，必要时 Wrap 2 行 |
| dark mode | hero 字符 #E8E4DB on #1C1A18 = 12.6:1，所有列表项对比度 AAA |
| reduced-motion | Switch 切换瞬时；列表入场 fadeIn 跳过 |
| 触控目标 | 列表项 ≥ 64dp / Switch ≥ 56dp / 退出按钮 ≥ 44dp |

---

## 8. 实施顺序建议（PR 拆分）

1. **PR-1（本屏主体）**：`profile_page.dart` 重写 + 新 ARB keys + SettingsState 新字段（storageUsage / lastUpdateCheckAt / availableUpdateVersion / biometricSupported）+ 单测保留 SettingsBloc 既有覆盖
2. **PR-2（依赖组件）**：HanaListItem / HanaSectionHeader / HanaSwitch / HanaSnackbar 抽取到 `lib/core/widgets/`（与 Phase 4 合流）
3. **PR-3（settings_detail 跟进）**：用相同组件清算 settings_detail_page 的剩余 14+ `_SettingsCard` 复制（Phase 3.4 范围，不在本屏 PR 中）

> **不在本屏 PR 范围**：主题切换二级页（settings_detail）/ 语言切换二级页 / 通知设置详细页——这些 Phase 3.4 重设计，本屏只负责入口列表项。

---

— 完 —
