# Settings Detail 屏 v1 设计 critique

> Generated 2026-04-29 from `lib/features/settings/presentation/pages/settings_detail_page.dart`
> 参照：DESIGN.md v2 / tokens.md / principles.md / widget-pattern-inventory.md / audit 报告
> 配对输出：`docs/design/screens/settings-detail/spec.md` + `docs/design/screens/settings-detail/handoff.md`
> 父屏：Profile（"偏好"节列表项 → 跳本屏）

---

## 0. 一句话总结

v1 Settings Detail 是 Profile 屏的"放大镜版"——同样的 `_SettingsCard` + `_SettingsTile` + 圆形彩色 icon 容器（`primaryContainer @ 50%, shape: circle`），但**重复堆叠 5 节 ≥ 14 个 tile + 8% primary 横向分隔线 + Plus Jakarta Sans w600 + AppBar BackdropFilter blur**。功能层面更糟糕：① 主题切换是**虚假交互**——audit §2 已证明 v1 的 `AppThemeType` 5 个主题（sakura / lavender / sky / starryNight / cyberpunk）实际全部 `return Sakura`，是死代码 ② 与父屏 Profile 职责严重重叠（个人信息 / 隐私 / 关于三节都重复），只有"语言 / 数据导出 / 关于"三块是 Profile 没有的。v2 必须**狠狠瘦身**：删除 5 主题伪选择，删除与 Profile 重叠的"个人信息 / 隐私安全 / 关于"，本屏只留"显示 / 语言 / 数据 / 关于"4 节，把"主题"压成"light/dark/跟随系统"三选一卡。

## 1. 9 个 P0 违规（block reason）

### P0-1 与 Profile 屏严重职责重叠（架构违规）
v1 同时在 Profile 和 Settings Detail 渲染：「个人信息」（displayName / hrtStartDate）+「隐私安全」（appLock / privacyMode / crashReporting）+「关于」（version / privacyPolicy / termsOfUse）三节——一份功能两处入口、两份代码、两份 ListTile copy。v2 Settings Detail **只承担**"显示 / 语言 / 数据 / 关于"四块（Profile 已涵盖个人信息 / 隐私），删除重叠 8+ tile。

### P0-2 5 主题伪选择（audit §2 已揭穿）
audit 报告 §2-8 明确：v1 `AppThemeType` enum 声明 5 主题（sakura / lavender / sky / starryNight / cyberpunk），但 `applyTheme` 实际**全部 return sakura**——5 个选项是 dead code。v2 直接删除多主题选择，仅保留 `light / dark / system` 三选一（沿用 `darkModeEnabled` bool 升级为 `themeMode` enum）。

### P0-3 14+ 处 _SettingsTile / _SettingsCard 复制（widget-pattern-inventory P0-#4）
本屏自定义 `_SectionTitle` / `_SettingsCard` / `_SettingsTile` 三套容器，14+ 处复用——叠加 Profile 屏的 14+ 处复制，是 inventory 报告 P0 抽象候选第 4 名核心受害者。**v2 必须用统一的 `HanaCard.list` + `HanaListItem` 组件替代**。

### P0-4 AppBar BackdropFilter blur(12)（DESIGN §4 / tokens §5）
13 处工程债之一。换 `HanaTopBar.default` 实色 surfaceContainerHigh + 滚动出现 0.5px outline @ 30%。

### P0-5 圆形彩色 icon 容器 14 处（principles §5 内容即装饰）
每个 `_SettingsTile` 左侧 40×40 `Container(decoration: primaryContainer @ 50%, shape: circle)`——v2 ListItem 严禁前置彩色圆形 icon，改 outlined icon 紧贴 title 左 12px 或干脆**不要 leading**。

### P0-6 _SettingsCard radius 24 + boxShadow（principles §2）
`BoxDecoration(borderRadius: 24, boxShadow: blur 16, primary @ 8%)`——v2 全删，圆角 4px、零 shadow。

### P0-7 8% primary 横向分隔线 14 处（widget-pattern-inventory）
tile 之间用 `Container(height: 1, margin-left: 56, color: primary @ 13)` 显式画分隔线——v2 列表项之间靠 surface 阶差或 spacing.sm 留白，**禁止** 1px 实线分隔。

### P0-8 主题切换走 `Switch(value: darkModeEnabled)` 开关式（语义错位）
v1 的 darkMode 是布尔开关——但 v2 标准三态（light / dark / system）需要"三选卡片"或单选列表，不是 toggle。改 `HanaCard.list` 三个 `HanaListItem`：跟随系统 / 浅色 / 深色，当前选中 trailing = mono 文字"当前"或黛蓝小圆点。

### P0-9 数据导出 / 导入完全缺席（critique-spec gap）
v1 settings_detail 只有"个人信息 / 显示 / 隐私 / 更新 / 下载 App / 关于"——**数据导出 / 导入 / 清除数据**不在本屏（Profile 屏的"数据"节 spec 已规划）。v2 重新分配：Profile 仍保留"数据"节作为快捷入口（导出 / PDF / 存储用量），Settings Detail 增加**完整版**"数据"节（导出 / 导入 / 清除）——其中"清除"是真正的 destructive 红线，需 HanaDialog confirmDestructive + 二次输入"删除"。

## 2. 7 个 P1 问题

- **P1-1 语言切换 BottomSheet inline 写死** — `_showLanguagePicker` 自实现 `showModalBottomSheet`，标题 / handle / ListTile / Icons.check_circle 全部 inline——换 `HanaBottomSheet variant=picker`。
- **P1-2 显示名 / HRT 日期编辑用 AlertDialog + DatePicker** — `_showEditNameDialog` 自实现 `AlertDialog`；`_selectHrtStartDate` 调 `showDatePicker` 并用 `Theme.copyWith` 局部覆盖 colorScheme——本屏不再承担这两个动作（Profile 已承担），整段删除；如保留则换 HanaBottomSheet variant=form。
- **P1-3 "更新" + "下载 App" 两节互斥（kIsWeb 分支）但都在本屏** — 移动端"更新"应保留，Web "下载 App" spec 上属于 Profile（已在 Profile spec），本屏不再渲染。
- **P1-4 _checkForUpdates 全 inline 600+ 行** — 加载弹窗 / SnackBar 成功 / SnackBar 失败全部硬编码 Container + Icon + Text——与 Profile 屏的"检查更新"列表项重复实现。本屏不承担"检查更新"（Profile 已承担）。
- **P1-5 SnackBar 自定义 Container + Icon + 圆角**（widget-pattern-inventory P2-#19）— 替换 `HanaSnackbar.show`。
- **P1-6 隐私安全节 crashReporting 子标题与 title 同字号同字重** — `_SettingsTile.subtitle` 用 12px inkSecondary 是 v1 默认；v2 应是 `body-sm 13 inkSecondary`，且 crashReporting 整项移到 Profile 隐私节（与 appLock / privacyMode 同框），本屏不承担。
- **P1-7 AppBar leading 用 IconButton(arrow_back, primary)** — 黛蓝返回箭头消耗强色配额，可接受（与 Profile 子屏一致），但需计入"≤ 3 处"。

## 3. 5 个 P2 问题

- 屏幕水平 padding 24 是 v2 禁止中间值——改 spacing.lg 32。
- `_SectionTitle` 用 14·600·onSurfaceVariant·tracking 0.5——应换 `HanaSectionHeader` 12·+0.6 + 4px 黛蓝竖线。
- "导入"功能在 R52 cloud sync 落地前应显式标注"等待 R52 落地"占位——直接 `HanaListItem disabled + subtitle "等待 R52 落地"`，不跳路由不执行。
- 数据导出菜单 v1 没有"形式选择"——`exportData` 直接落 JSON 文件；v2 spec 要求 `HanaBottomSheet` 让用户选 "JSON 明文 / 加密 zip"（spec 任务）。
- 导出确认应有"导出文件不会加密"提示（跨性别敏感性 / 隐私保护）——subtitle 红色（warning 香灰，不是 error 朱砂）"导出文件不会加密，请妥善保管。"

## 4. 整体叙事重写

v1 想说："这是设置中心——我把 Profile 上能看到的全部又复制了一遍，再加几个 Profile 没有的功能。" v2 应该说："这是这本内刊的版本页——四节：显示 / 语言 / 数据 / 关于，每节只回答一个问题。"

**信息密度**：从 v1 的 6 节 14+ tile 收敛到 v2 的 4 节 ~10 tile：① 显示（主题三选）② 语言（三选）③ 数据（导出 / 导入占位 / 清除）④ 关于（版本 / 上次更新检查 / 隐私 / 条款）。**与 Profile 重叠的"个人信息 / 隐私 / 检查更新 / 下载 App"全部不在本屏**。

**视觉重心**：本屏无 hero，AppBar 黛蓝返回箭头偏左承担"返回 Profile"语义；下方四节段落顺序铺陈，每节左 4px 黛蓝竖线段落标记。**全屏黛蓝 ≤ 3 处**：① 返回箭头 ② 章节竖线（4 节同色块同义视觉计 1 处段落标记语法）③ 当前选中主题/语言的"当前"标记（mono 而非黛蓝点，避免第 4 处）——共 3 处。"清除数据" title 用朱砂 error 色（不算黛蓝），HanaDialog 确认按钮用 destructive variant。
