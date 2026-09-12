# Settings Detail 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/
> 屏幕：`lib/features/settings/presentation/pages/settings_detail_page.dart`
> 阶段：Phase 3.4.b 新稿（spec）+ 自审 critique-v2
> 配对 critique：`docs/design/screens/settings-detail/critique-v1.md`
> 配对 handoff：`docs/design/screens/settings-detail/handoff.md`
> 父屏：Profile（"偏好"节列表项 → 跳本屏）

---

## 1. 设计意图

Settings Detail 是这本内刊的**版本页 / 奥付补遗**——读者翻完 Profile 奥付页后，少数情况下需要进一步调整"本期排版"（显示 / 语言）或"本期发行"（导出 / 清除）的页面。它**不是 Profile 的副本**，而是 Profile 的**配套补充**：四节段落、每节回答一个唯一问题、不与 Profile 重叠任何 tile。视觉上彻底沉默：月白底 + 4 处 `HanaSectionHeader` + `HanaCard.list` + `HanaListItem` 文字行 + 一处朱砂"清除数据"红线。

v1 vs v2 核心差异：v1 是"Profile 的放大复制版"（6 节 14+ tile，与 Profile 严重重叠 + 5 主题伪选择 + crashReporting / 个人信息 / 检查更新 重复入口），v2 是"Profile 的补遗页"（4 节 ~10 tile，零重叠 + 真实主题三选 + 数据导出形式选择 + 真正的 destructive 红线）。

跨性别敏感性：导出文件不加密的提示用 warning 香灰色（不是 error 朱砂——"提醒"不是"危险"）；clear data 二次确认要求用户输入"删除"二字，避免误触摧毁数据。

---

## 2. 屏幕骨架（ASCII Wireframe）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色，无 blur
│   ←  "设置"  (label-md +0.6 ink, 居中)      │     leading 黛蓝返回箭头
├─────────────────────────────────────────────┤
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│  ┃ 显示                                      │  ← HanaSectionHeader
│  ┃ (label-md +0.6 inkSecondary + 4px 黛蓝竖线)│
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.list（主题三选）
│   │  跟随系统                    当前 │    │  ← HanaListItem (trailing=mono)
│   ├────────────────────────────────────┤    │
│   │  浅色                              │    │
│   ├────────────────────────────────────┤    │
│   │  深色                              │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (节间 spacing.lg = 32)                    │
│                                             │
│  ┃ 语言                                      │  ← HanaSectionHeader
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.list（语言三选 + 系统）
│   │  跟随系统                          │    │
│   ├────────────────────────────────────┤    │
│   │  中文                        当前 │    │  ← trailing mono "当前"
│   ├────────────────────────────────────┤    │
│   │  English                           │    │
│   ├────────────────────────────────────┤    │
│   │  日本語                            │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (节间 spacing.lg = 32)                    │
│                                             │
│  ┃ 数据                                      │  ← HanaSectionHeader
│                                             │
│   ╭────────────────────────────────────╮    │
│   │  导出备份                          │ ›   │  ← onTap → HanaBottomSheet 选形式
│   │       上次：4 月 12 日             │    │  ← subtitle mono inkSecondary
│   ├────────────────────────────────────┤    │
│   │  导入备份                          │    │  ← disabled (opacity 0.38)
│   │       等待 R52 落地                │    │  ← subtitle body-sm inkSubdued
│   ├────────────────────────────────────┤    │
│   │  清除所有数据                      │ ›   │  ← title 朱砂 error，chevron 朱砂
│   │       本机数据将不可恢复           │    │  ← subtitle warning 香灰
│   ╰────────────────────────────────────╯    │
│                                             │     onTap → HanaDialog confirmDestructive
│                                             │     + 二次 TextInput "删除"
│                                             │
│   (节间 spacing.lg = 32)                    │
│                                             │
│  ┃ 关于                                      │  ← HanaSectionHeader
│                                             │
│   ╭────────────────────────────────────╮    │
│   │  版本                       1.2.0 │    │  ← trailing mono
│   ├────────────────────────────────────┤    │
│   │  上次检查更新           4-28 14:30│    │  ← trailing mono（无 chevron，纯展示）
│   ├────────────────────────────────────┤    │
│   │  隐私政策                          │ ›   │
│   ├────────────────────────────────────┤    │
│   │  使用条款                          │ ›   │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (底部留白 spacing.xl = 64)                │
└─────────────────────────────────────────────┘
```

**导出 BottomSheet**（onTap 数据 → 导出备份）：
```
─────
导出备份                                 (headline 24)

  ╭──────────────────────────────────╮
  │  JSON 明文                       │ ›  ← HanaListItem
  │  导出文件不会加密，请妥善保管    │    ← subtitle warning 香灰
  ├──────────────────────────────────┤
  │  加密 zip（推荐）                │ ›
  │  使用应用密码加密                 │
  ╰──────────────────────────────────╯
                       [ 取消 ghost ]
```

**清除数据 HanaDialog confirmDestructive**：
```
        scrim ink @ 32%
   ┌────────────────────────────┐
   │ 清除所有数据后不可恢复。   │  headline ink
   │                            │
   │ 本机所有用药 / 检查 / 日记 │  body inkSecondary
   │ 将被永久删除。仍要继续？   │
   │                            │
   │ ┌──────────────────────┐   │  TextField outline
   │ │ 输入"删除"以确认     │   │  hint inkSubdued
   │ └──────────────────────┘   │
   │                            │
   │      [不删除]  [删除]      │  ghost / destructive
   └────────────────────────────┘
```

---

## 3. 章节结构（4 节，无 hero，无末尾按钮）

| # | 节名 (zh) | 节名 (en) | 节名 (ja) | 列表项 |
|---|----------|----------|----------|-------|
| 1 | 显示 | Appearance | 表示 | 跟随系统 / 浅色 / 深色 |
| 2 | 语言 | Language | 言語 | 跟随系统 / 中文 / English / 日本語 |
| 3 | 数据 | Data | データ | 导出备份 / 导入备份（占位）/ 清除所有数据 |
| 4 | 关于 | About | このアプリ | 版本 / 上次检查更新 / 隐私政策 / 使用条款 |

**v1 → v2 删除**（因 Profile 已承担或 dead code）：
- v1 「个人信息」节（displayName / hrtStartDate）→ Profile 已有
- v1 「隐私安全」节（appLock / privacyMode / crashReporting）→ Profile 已有
- v1 「更新」节（autoCheck / checkNow）→ Profile "关于"节已有
- v1 「下载 App」节（kIsWeb branch）→ Profile spec 已规划
- v1 主题 5 选（sakura / lavender / sky / starryNight / cyberpunk）→ audit §2 揭穿全部 return sakura，删
- v1 darkMode `Switch` toggle → 改三选卡（system / light / dark）

---

## 4. 组件映射

| 区域 | v2 组件 | Variant | 关键 props / 备注 |
|------|--------|---------|---------|
| 顶部栏 | `HanaTopBar` | default | title=l10n.settingsTitle，leading=back arrow（黛蓝） |
| 章节标题 | `HanaSectionHeader` | default | label-md +0.6 inkSecondary + 4px 黛蓝竖线 |
| 列表卡容器 | `HanaCard` | list | surfaceContainerLowest, radius 4 |
| 列表项 | `HanaListItem` | default / withSubtitle / destructive | trailing 槽容纳 mono "当前" / chevron / 朱砂 chevron |
| 导出形式选择 | `HanaBottomSheet` | action-sheet | 标题"导出备份" + 两个 HanaListItem（JSON / 加密 zip）+ ghost 取消 |
| 清除数据确认 | `HanaDialog` | confirmDestructive | title + message + 二次 TextField "删除"输入 + 取消/删除按钮 |
| 操作反馈 | `HanaSnackbar.show` | success / error | "已导出。" / "导出失败。" / "已清除。" |
| 加载态 | `HanaLoadingView` | block | — |
| 错误态 | `HanaErrorState` | — | — |

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
| 占位 subtitle "等待 R52" | `HanaTokens.inkSecondary(context)` @ 60%（即 inkSubdued 派生） |
| 章节竖线 / 返回箭头 | `HanaTokens.primary(context)` |
| "导出文件不会加密" subtitle | `HanaTokens.warning(context)`（香灰，不是朱砂） |
| 清除数据 title / chevron / dialog confirm | `HanaTokens.error(context)`（朱砂） |
| HanaDialog scrim | `HanaTokens.ink(context).withOpacity(0.32)` |

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `spacing.lg` = 32 |
| 顶部留白 | `spacing.xl` = 64 |
| 章节标题 → 列表卡 | `spacing.md` = 16 |
| 节与节之间 | `spacing.lg` = 32 |
| 列表项内 padding | horiz 24 / vert 20 |
| 屏幕底部 | `spacing.xl` = 64 |
| HanaDialog 全围 padding | `spacing.lg` = 32 |
| HanaBottomSheet 顶部 padding | `spacing.lg` = 32，水平 `spacing.md` = 16 |

### 圆角
| 用途 | Token |
|------|-------|
| 列表卡容器 | `radius.card` = 4 |
| HanaDialog | `radius.card` = 4 |
| HanaBottomSheet | top 16（系统例外） |
| HanaButton | `radius.button` = 6 |
| TextField（dialog 二次确认输入） | `radius.input` = 2 |

### 字体
| 用途 | Token |
|------|-------|
| AppBar title | `label` 12·+0.6 Medium ink |
| 章节标题 | `label` 12·+0.6 Medium inkSecondary |
| 列表项 title | `body` 15·24 Regular ink（destructive 时 error 色） |
| 列表项 subtitle | `body-sm` 13·20 inkSecondary |
| 列表项 trailing "当前" / 版本号 / 日期 | `mono` 14·20 JetBrains Mono Light inkSecondary |
| HanaDialog title | `headline` 24·32 Regular ink |
| HanaDialog body | `body` 15·24 inkSecondary |
| HanaBottomSheet title | `headline` 24·32 Regular ink |
| HanaButton label | `body` 15·24 Medium |

### 动画
| 用途 | Token |
|------|-------|
| 列表项 press scale | `motion.quick` 150ms easeOut → 0.98 |
| 章节入场 fadeIn | `motion.standard` 240ms 错落 80ms |
| 主题 / 语言切换 trailing "当前"标记 | `motion.standard` 240ms crossfade |
| HanaBottomSheet 进出 | `motion.standard` 240ms 上移 |
| HanaDialog 进出 | 240ms scale 0.96→1.0 / 200ms fadeOut |
| 主题切换全屏色彩过渡 | `motion.deliberate` 600ms easeOut（背景色 / surface crossfade） |

---

## 6. 交互状态

### 主题三选
- `HanaListItem` onTap → `SettingsBloc.add(ChangeThemeMode(mode))`（**新事件**，废弃 `ToggleDarkMode`）
- `themeMode: ThemeMode.{system, light, dark}` 写 settings + 持久化
- 全屏 surface / ink 色 600ms 过渡（背景 / surfaceContainerLowest crossfade）
- 当前选中 trailing = mono "当前"（其他项 trailing 空）

### 语言四选
- `HanaListItem` onTap → `SettingsBloc.add(SettingsEvent.changeLanguage(languageCode))`（沿用现有事件）
- `languageCode: '' (system) / 'zh' / 'en' / 'ja'`
- 当前选中 trailing = mono "当前"
- AppLocalizations 立即重建 → 全屏文案切换

### 导出备份
1. `HanaListItem` onTap → `HanaBottomSheet.show(action-sheet)`
2. 用户选 JSON → 调 `ExportDataEvent(format: 'json')`；选加密 zip → `ExportDataEvent(format: 'encryptedZip')`（**新参数**）
3. 流转：HanaSnackbar info "正在导出..." → success "已导出。" + 路径 / failed "导出失败。"
4. 选项 2 subtitle 黄色 warning："导出文件不会加密。"（JSON 选项）/ "使用应用密码加密。"（zip 选项）

### 导入备份（占位）
- `HanaListItem` 永远 disabled（opacity 0.38 + onTap null）
- subtitle = "等待 R52 落地"（inkSubdued 60%）

### 清除所有数据
1. `HanaListItem` onTap（destructive 朱砂）→ `HanaDialog.confirmDestructive`
2. Dialog 内含 TextField，hint "输入「删除」以确认"
3. TextField 内容 == "删除" 时 confirm 按钮变为 destructive enabled，否则 disabled
4. 确认 → `SettingsBloc.add(WipeSettingsData)`
5. SettingsWiped 状态 → `context.go('/')`
6. 失败 → HanaSnackbar.error

### 隐私政策 / 使用条款
- onTap → `context.push('/legal/privacy')` / `context.push('/legal/terms')`

### 上次检查更新（纯展示）
- 不响应 onTap，trailing mono 显示 `state.settings.lastUpdateCheckAt` 格式化
- 若 null → mono 显示 "—"
- "检查更新"按钮在 Profile 屏，本屏不重复

---

## 7. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，水平 padding 32，列表卡占满 |
| 768–1024 (tablet) | 单列内文页 max-width 720px 居中 |
| ≥ 1024 (web 桌面) | 两列：左 240 sidebar（章节锚点：显示 / 语言 / 数据 / 关于）/ 右 720 主体 |

---

## 8. i18n 注意（最长文案预测）

| key | en | zh | ja | 最长 |
|-----|----|----|----|------|
| settingsTitle | Settings | 设置 | 設定 | en 8 字 |
| settingsSectionAppearance | Appearance | 显示 | 表示 | en 10 字 |
| settingsSectionLanguage | Language | 语言 | 言語 | en 8 字 |
| settingsSectionData | Data | 数据 | データ | en 4 / ja 4 |
| settingsSectionAbout | About | 关于 | このアプリ | **ja 6 字** |
| themeFollowSystem | Follow system | 跟随系统 | システムに合わせる | **ja 11 字** |
| themeLight | Light | 浅色 | ライト | en 5 字 |
| themeDark | Dark | 深色 | ダーク | en 4 字 |
| settingsTrailingCurrent | Current | 当前 | 現在 | en 7 字 |
| dataExport | Export backup | 导出备份 | バックアップを書き出し | **ja 12 字** |
| dataImportPlaceholder | Pending R52 sync | 等待 R52 落地 | R52 同期を待機中 | **ja 10 字** |
| dataExportNotEncryptedHint | File is not encrypted | 导出文件不会加密 | ファイルは暗号化されません | **ja 13 字** |
| dataWipe | Clear all data | 清除所有数据 | すべてのデータを削除 | **ja 12 字** |
| dataWipeConfirmInput | Type "delete" to confirm | 输入「删除」以确认 | 「削除」と入力して確認 | **en 24 字** |
| settingsAboutVersion | Version | 版本 | バージョン | **ja 6 字** |
| settingsAboutLastChecked | Last checked | 上次检查更新 | 最終確認 | **zh 6 字** / en 12 字 |

**排版兼容规则**：
- 列表项 title 允许 Wrap 2 行；超 2 行截断
- subtitle 允许 2 行
- mono trailing（"当前" / 版本 / 日期）固定 mono 14 / line 20
- HanaDialog message ja 常更长，dialog 高度自适应
- TextField hint ja "「削除」と入力して確認" 较长，TextField 单行 + horizontal scroll

---

## 9. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — 列表项 ≥ 64dp / 返回箭头 ≥ 44×44 / Dialog 按钮 ≥ 44dp |
| Semantics | ✓ — 主题 / 语言 selected 项加 `Semantics(selected: true, label: "中文，当前")`；destructive title 加 `Semantics(value: 'destructive')` |
| 焦点顺序 | AppBar back → 显示三项 → 语言四项 → 数据三项 → 关于四项 |
| prefers-reduced-motion | ✓ — fadeIn 跳过；主题切换全屏色 600ms → 瞬时；BottomSheet 进出瞬时 |
| 对比度 | ✓ — error #9B2A2A on #FBF8F2 = 7.1:1 (AAA)；ink on background = 14.8:1 (AAA)；warning #A6814C on #FBF8F2 = 4.6:1 (AA) |
| dynamic type | ✓ — title body 15 / subtitle body-sm 13 / mono 14 |
| Dialog 焦点陷阱 | ✓ — tab 仅在 TextField / 取消 / 删除 间循环；ESC / 物理返回关闭 |

---

## 10. 自审 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色 ≤ 3 处 | ✓ | ① 返回箭头 ② 章节竖线（4 节同色块同义视觉计 1 处）③ 主题/语言"当前"mono 标记（不是黛蓝点，避免第 4 处）。共 3 处。朱砂 destructive 不算黛蓝。 |
| 2. 调和层次胜过投影 | ✓ | 零 BoxShadow / 零 BackdropFilter / 零 border。HanaDialog 也无阴影（scrim 已建立层级）。 |
| 3. 编辑级不对称 | ✓ | 章节竖线段落标记。AppBar leading 偏左破对称。Dialog 按钮右对齐（编辑级阅读流向）。 |
| 4. 慢节奏与留白 | ✓ | xl(64) / lg(32) / md(16) 跨级。Dialog padding lg 32 全围。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零彩色 icon 圆形容器 / 零 stadium pill。当前选中用 mono "当前"陈述，不是装饰图标。 |

**遗留风险**：
- 主题三选依赖 `AppSettings.themeMode: ThemeMode` 字段（v1 是 `bool darkModeEnabled`），需 freezed regen + DataSource migration。Phase 4 落地。
- 导出形式选择依赖 `ExportDataEvent(format: 'json' | 'encryptedZip')` 新参数 + data 层 `EncryptedZipExporter` 实现——Phase 4 范围；本屏 PR 可先用占位（先只 JSON 路径生效，加密 zip 显示"等待"）。
- 清除数据二次输入"删除"在 ja locale 用「削除」，需 ARB key 覆盖（`dataWipeConfirmKeyword: zh "删除" / en "delete" / ja "削除"`）。
- 与 Profile 屏的"数据"节存在 1 处职责重叠：Profile "数据"节有"导出备份 / 生成 PDF / 存储用量"（快捷）；本屏"数据"节有"导出 / 导入 / 清除"（完整）——**导出**两屏都有，但 Profile 是 1-tap 默认 JSON，本屏是选择形式。可接受（前者快捷、后者完整），但需在 ARB 文案上区分 subtitle。

---

— 完 —
