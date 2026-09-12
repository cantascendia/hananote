# Settings Detail 屏开发 handoff

> Generated 2026-04-29 from `docs/design/screens/settings-detail/spec.md`
> 工程目标：`lib/features/settings/presentation/pages/settings_detail_page.dart`
> 配对 spec：`docs/design/screens/settings-detail/spec.md`
> 配对 critique：`docs/design/screens/settings-detail/critique-v1.md`

---

## 1. 改动总览（What changes）

把 v1 的"6 节 Profile 复制版"重写为 v2 的"4 节补遗页"。**this is a rewrite + scope shrink**——保留 SettingsBloc / SettingsEvent / SettingsState 已有契约（仅增量加 `ChangeThemeMode` 事件 + `themeMode` 字段），**presentation 层从头重做** + **大量功能搬出本屏**。

**删除（与 Profile 重叠或 dead code）**：
- 「个人信息」整节（displayName / hrtStartDate）→ Profile 已承担，删除 + `_showEditNameDialog` + `_selectHrtStartDate` 共 ~70 行
- 「隐私安全」整节（appLock / privacyMode / crashReporting）→ Profile 已承担，删除
- 「更新」整节（autoCheck / checkNow）+ `_checkForUpdates` 100+ 行 inline → Profile 已承担，删除
- 「下载 App」节（kIsWeb branch）→ Profile spec 已规划
- 主题 5 选 dead code（audit §2 已揭穿全部 return sakura）→ 改三选（system / light / dark）
- darkMode `Switch` toggle → 改三选 HanaListItem 卡
- `_SectionTitle` / `_SettingsCard` / `_SettingsTile` 三套 inline 容器（共 ~120 行）→ HanaSectionHeader / HanaCard.list / HanaListItem
- AppBar `BackdropFilter` + `ClipRRect` + `extendBodyBehindAppBar`（13 处 blur 工程债之一）
- 圆形彩色 icon 容器 14 处（`primaryContainer @ 50%, shape: circle`）
- 8% primary 横向分隔线 14 处（`Container height 1, primary @ 13`）
- Plus Jakarta Sans 字体硬编码 8+ 处
- 自定义 SnackBar `Container + Icon + 圆角`（widget-pattern-inventory P2-#19）→ HanaSnackbar.show
- `_showLanguagePicker` inline modal（~80 行）→ HanaBottomSheet variant=picker

**新增**：
- 4 节章节结构：显示（主题三选）/ 语言（四选）/ 数据（导出 / 导入占位 / 清除）/ 关于（版本 / 上次检查 / 隐私 / 条款）
- "导出形式"选择 `HanaBottomSheet` action-sheet：JSON 明文 / 加密 zip
- "清除所有数据" `HanaDialog confirmDestructive` + 二次 TextField "删除"输入校验
- "导入备份"占位项 disabled + subtitle "等待 R52 落地"
- 主题切换全屏色彩 600ms `motion.deliberate` 过渡

---

## 2. 关键依赖（Components needed）

### 已有 v2 components（components/*.md）
- `HanaTopBar.default`（top-bar.md）
- `HanaCard.list` variant（card.md）
- `HanaSectionHeader`（section-header.md）
- `HanaListItem` variants: `default` / `withSubtitle` / `destructive`（list-item.md）
- `HanaBottomSheet` variant=action-sheet（bottom-sheet.md）
- `HanaDialog.confirmDestructive`（dialog.md）— **本屏需扩展**支持 TextField 二次输入校验（spec §6 清除数据）
- `HanaButton.ghost` + `HanaButton.destructive`（button.md）
- `HanaSnackbar.show`（toast.md）
- `HanaLoadingView.block` / `HanaErrorState`

### 需补 lib（与本屏 PR 同期）
- `HanaDialog.confirmDestructiveWithKeyword(...)` 静态方法 — 在 dialog.md 现有 confirmDestructive 基础上**新增**关键字校验变体；signature: `({title, message, confirmLabel, cancelLabel, requiredKeyword, hintText}) → Future<bool>`
- `ExportDataEvent(format: 'json' | 'encryptedZip')` 参数化 — settings_event.dart 加 `format` 字段（freezed regen）
- `EncryptedZipExporter` 数据层实现 — Phase 4 范围；本屏 PR 可先打通 JSON 路径，zip 选项显示但派事件后 Cubit 抛 `Failure.notImplemented` → Snackbar"加密 zip 即将上线"
- `AppSettings.themeMode: ThemeMode` 字段 — 替换 `bool darkModeEnabled`；MMKV / sqflite settings table 写 migration

---

## 3. 视觉契约（不可妥协项）

| 项 | 值 / Token |
|---|---|
| Scaffold bg | `HanaTokens.background(context)` |
| AppBar bg | `HanaTokens.surfaceContainerHigh(context)`（无 blur） |
| 列表卡 bg | `HanaTokens.surfaceContainerLowest(context)` |
| 列表卡 radius | `HanaTokens.radius.card` = 4（**禁** 24） |
| 列表卡 elevation | 0（**禁** BoxShadow） |
| 列表卡 border | none |
| 屏幕水平 padding | `HanaTokens.spacing.lg` = 32（**禁** 24） |
| 顶部留白 | `spacing.xl` = 64 |
| 节间留白 | `spacing.lg` = 32 |
| 章节标题 → 列表卡 | `spacing.md` = 16 |
| 列表项内 padding | horiz 24 / vert 20 |
| 列表项 separator | **零 1px 实线**（**禁** primary @ 13 横线 14 处） |
| 章节标题字体 | `label` 12·+0.6 Medium，inkSecondary |
| 章节竖线 | 4px wide × 16px tall，color = primary |
| 列表项 title 字号 | `body` 15·24 Regular（**禁** w800 / Plus Jakarta Sans） |
| 列表项 subtitle 字号 | `body-sm` 13·20 inkSecondary |
| 列表项 trailing "当前" | `mono` 14·20 inkSecondary |
| 列表项 trailing 版本号 / 日期 | `mono` 14·20 inkSecondary |
| 占位 subtitle "等待 R52" | `body-sm` 13·20 inkSecondary @ 60% |
| 导出 warning subtitle | `body-sm` 13·20 `HanaTokens.warning(context)` 香灰 |
| destructive title / chevron | `HanaTokens.error(context)` 朱砂 |
| HanaDialog scrim | `ink @ 32%` |
| HanaDialog radius | `radius.card` = 4 |
| HanaBottomSheet radius | top 16（系统例外） |
| 黛蓝出现位置 | 返回箭头 + 章节竖线（4 节同视觉语法计 1）+ "当前"mono 标记（不消耗黛蓝）≤ 3 处 |

---

## 4. 数据契约（Bloc / Cubit）

**沿用现有**：`SettingsBloc` + `SettingsState`，事件大部分保留。

**事件改动**：
- ❌ 废弃 `SettingsEvent.toggleDarkMode(enabled: bool)` — 改三态
- ✅ 新增 `SettingsEvent.changeThemeMode(mode: ThemeMode)` — `ThemeMode.{system, light, dark}`
- ✅ 修改 `SettingsEvent.exportData()` → `SettingsEvent.exportData(format: ExportFormat)` — `ExportFormat.{json, encryptedZip}`
- ✅ 沿用 `SettingsEvent.changeLanguage(languageCode)` 不动
- ✅ 沿用 `WipeSettingsData` 不动（dialog 二次输入校验在 UI 层完成）

**State 字段改动**：
- ❌ 废弃 `AppSettings.darkModeEnabled: bool`
- ✅ 新增 `AppSettings.themeMode: ThemeMode`
- DataSource 写 migration：darkModeEnabled true → ThemeMode.dark / false → ThemeMode.system（更宽容默认）

**新增 ARB keys**（lib/core/l10n/arb/app_{en,zh,ja}.arb 三语同步）：
- `settingsSectionAppearance` / `settingsSectionLanguage` / `settingsSectionData` / `settingsSectionAbout`
- `themeFollowSystem` / `themeLight` / `themeDark`
- `settingsTrailingCurrent` = "当前" / "Current" / "現在"
- `dataImportPlaceholder` = "等待 R52 落地" / "Pending R52 sync" / "R52 同期を待機中"
- `dataExportFormatTitle` = "选择导出形式" / "Choose export format" / "書き出し形式を選択"
- `dataExportJsonTitle` / `dataExportJsonHint` = "导出文件不会加密。"（warning 香灰 subtitle）
- `dataExportZipTitle` / `dataExportZipHint` = "使用应用密码加密。"
- `dataExportZipPending` = "加密 zip 即将上线"（PR-1 占位用）
- `dataWipe` = "清除所有数据"
- `dataWipeSubtitle` = "本机数据将不可恢复"（warning 香灰）
- `dataWipeConfirmTitle` = "清除所有数据后不可恢复。"
- `dataWipeConfirmMessage` = "本机所有用药 / 检查 / 日记将被永久删除。仍要继续？"
- `dataWipeConfirmKeyword` = "删除" / "delete" / "削除"
- `dataWipeConfirmInputHint` = "输入「删除」以确认" / "Type \"delete\" to confirm" / "「削除」と入力して確認"
- `settingsAboutLastChecked` / `settingsAboutLastCheckedNever` = "—"

---

## 5. 路由契约

- AppBar leading = 黛蓝返回箭头 → `context.pop()`（返回 Profile 屏）
- 列表项跳转：
  - 主题三选 / 语言四选 → 不跳路由，inline 派 bloc 事件
  - 导出备份 → `HanaBottomSheet` 选形式 → bloc 事件 → SnackBar
  - 导入备份 → 永远 disabled（onTap = null）
  - 清除所有数据 → `HanaDialog.confirmDestructiveWithKeyword` → bloc → context.go('/')
  - 上次检查更新 → 不响应 onTap（纯展示）
  - 隐私政策 → `context.push('/legal/privacy')`
  - 使用条款 → `context.push('/legal/terms')`

---

## 6. P0 工程债清单（必须随本屏一并解决）

1. **删除与 Profile 重叠功能**（架构债）— 个人信息 / 隐私 / 更新 / 下载 App 共 4 节，~250 行代码 + 8+ tile 重复入口。
2. **删除 5 主题伪选择**（audit §2-8）— `AppThemeType` enum + `themeType` 字段 dead code，settings_state / app_settings / data layer 全清。
3. **删除 BackdropFilter blur**（DESIGN §4 / tokens §5）— 13 处之一。
4. **删除 PlusJakartaSans 字体硬编码**（DESIGN §3）— 8+ 处。
5. **删除 14+ inline _SettingsCard / _SettingsTile / _SectionTitle**（widget-pattern-inventory P0-#4）— 与 Profile 屏并行清算。
6. **删除 14+ 横向分隔线**（principles §2）— 1px primary @ 13。
7. **删除 14+ 圆形彩色 icon 容器**（principles §5）— `primaryContainer @ 50%, shape: circle`。
8. **替换 inline AlertDialog（编辑显示名）+ DatePicker（HRT 日期）+ AlertDialog（更新成功 / 失败 SnackBar）+ ListTile picker（语言）** — 全部走 v2 components 或直接删除（功能搬到 Profile）。

---

## 7. 测试清单（QA）

| 测试 | 期望 |
|------|------|
| 首屏渲染 | 4 节段落 + ~10 tile，无 hero，无 bento 圆角 24，无 blur，无 1px 分隔线 |
| 一抹强色审计 | 静态截图全屏黛蓝 ≤ 3 处（返回箭头 + 章节竖线 + "当前"mono 标记不算黛蓝） |
| 主题三选切换 | 选"深色" → 全屏色彩 600ms `motion.deliberate` crossfade → 持久化重启保留 |
| 语言四选切换 | 选"日本語" → 全屏文案立即切换 → AppLocalizations 重建 |
| 当前选中 trailing | 主题 / 语言当前项 trailing = mono "当前"；其他项 trailing = 空 |
| 导出 BottomSheet | onTap "导出备份" → action-sheet 升起 → 选 JSON → SnackBar 流转 → 写文件 |
| 导出加密 zip（PR-1 占位）| 选加密 zip → SnackBar info "加密 zip 即将上线"（不抛错） |
| 导入占位 | "导入备份"行 opacity 0.38 + 不响应 tap + subtitle "等待 R52 落地" |
| 清除所有数据（成功路径）| onTap → HanaDialog 出现 → TextField 输入"删除" → confirm 按钮 enabled → 确认 → context.go('/') |
| 清除所有数据（取消路径）| onTap → HanaDialog → TextField 留空 → confirm disabled → 取消 dismiss |
| 清除所有数据（输入错误）| 输入"清除"或其他词 → confirm 仍 disabled |
| 清除所有数据（i18n）| ja locale 显示「削除」要求；en 显示 "delete"；zh 显示「删除」 |
| 上次检查更新 | trailing mono 显示 lastUpdateCheckAt，无 chevron，不响应 tap |
| 隐私政策 / 使用条款 | onTap → push 到 /legal/* |
| 加载态 | HanaLoadingView.block，无 inline CircularProgressIndicator |
| 错误态 | HanaErrorState |
| 三语 i18n | ja "システムに合わせる" 不溢出（允许 wrap 2 行）；en "Type \"delete\" to confirm" hint 单行 horizontal scroll |
| dark mode | 主题选 dark 后 ink #E8E4DB on #1C1A18 = 12.6:1 AAA |
| reduced-motion | 主题切换 600ms 退化为瞬时；fadeIn 跳过；BottomSheet 上移瞬时 |
| 触控目标 | 列表项 ≥ 64dp / 返回箭头 ≥ 44 / Dialog 按钮 ≥ 44 / TextField ≥ 48 |
| 文案中性 | 全屏无 emoji，destructive 文案"清除所有数据后不可恢复。"句号收尾 |

---

## 8. 实施顺序建议（PR 拆分）

1. **PR-1（domain + bloc 准备）**：
   - `AppSettings.themeMode: ThemeMode` 替换 `darkModeEnabled` + DataSource migration
   - `SettingsEvent.changeThemeMode(mode)` 新增 + `toggleDarkMode` 废弃
   - `SettingsEvent.exportData(format)` 参数化 + `ExportFormat` enum
   - 删除 `AppThemeType` 5 主题枚举 + 相关 dead code（audit §2 落地）
   - bloc_test 覆盖
2. **PR-2（HanaDialog 扩展）**：
   - `HanaDialog.confirmDestructiveWithKeyword` 新静态方法（signature 见 §2）
   - 在 dialog.md 补 spec
3. **PR-3（本屏主体）**：
   - `settings_detail_page.dart` 重写为 4 节
   - 删除与 Profile 重叠的 4 节（~250 行）
   - 新 ARB keys（en/zh/ja）
   - 应用主屏 ThemeMode 监听 + 600ms motion 过渡
4. **PR-4（依赖组件抽出）**：
   - HanaListItem / HanaSectionHeader / HanaSnackbar 从 profile_page 私有实现迁到 `lib/core/widgets/`（与 notification settings PR 合流，Phase 4 范围）

> **不在本屏 PR 范围**：加密 zip 导出实现（Phase 4）/ R52 cloud sync 导入功能（R52 范围）/ 系统主题监听器（已在 app/theme/ 处理）。

---

— 完 —
