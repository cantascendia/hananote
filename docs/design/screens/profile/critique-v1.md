# Profile 屏 v1 设计 critique

> Generated 2026-04-29 from `lib/features/settings/presentation/pages/profile_page.dart`
> 参照：DESIGN.md v2 / tokens.md / principles.md / widget-pattern-inventory.md
> 配对输出：`docs/design/screens/profile/spec.md` + `docs/design/handoff/profile.md`

---

## 0. 一句话总结

v1 Profile 把"我的"屏当成了**装满 bento 卡的展柜**——粉色头像 + 圆形彩色 icon 容器 + bento decoration（24px 圆角 + 4% primary shadow + 30% primaryContainer 边框）+ 双倍胶囊 HRT day pill + 内嵌方形 SquareCard 双拼区——五种装饰语法叠加，每个 ListTile 都喧宾夺主。v2 必须把它压回**杂志的"奥付页 / 版权页"**：克制、章节化、零装饰。

## 1. 9 个 P0 违规（block reason）

### P0-1 粉色头像 + primaryContainer 圆形容器（principles §1 / §5 双违规）
`CircleAvatar(radius: 48, backgroundColor: HanaColors.primaryContainer)` 把"用户身份"当成需要装饰的视觉重心。v2 哲学：用户身份在 Profile 屏不需要圆形头像 placeholder，**直接删除**——以 display-xl 宋体的"无名"或用户填写的代号开头即可。粉色 placeholder 是"花笺"残留，必须切割。

### P0-2 14+ 处 _SettingsCard / ListTile / bento 复制（widget-pattern-inventory P0-#4）
profile_page.dart 内自定义了 `_SquareCard` / `_ListTileItem` / `_ButtonRowItem` 三套容器+九次复用，全屏一共 14+ 个 surface bento 块；settings_detail_page.dart 也是 14+ 处复制。这是 inventory 报告 P0 抽象候选第 4 名。**v2 必须用统一的 `HanaCard` + `HanaListItem` 组件替代**——任何 surface 容器禁止再 inline 写 `_bentoDecoration()`。

### P0-3 bentoDecoration 同时叠加 5 种装饰
`borderRadius: 24` + `border 30% primaryContainer` + `boxShadow blurRadius 16, 4% primary` + `surfaceContainerLowest` 背景 + 内嵌 icon 圆形容器（10% alpha）。**v2 全删**：圆角 4px、零边框、零 shadow、靠 surface 阶差区分（lowest #FBF8F2 vs background #F4F1EA）。

### P0-4 BackdropFilter blur(12,12) AppBar（DESIGN §4 / tokens §5）
v1 AppBar 用 `ClipRRect + BackdropFilter(blur 12) + background.withAlpha(0.8*255)`——v2 工程债 13 处之一。换 `HanaTopBar.default` 实色 surfaceContainerHigh + 滚动出现 0.5px outline @ 30%。

### P0-5 HRT day 用 stadium pill（999 圆角）+ 双重粗体
`Container(radius 9999, surfaceContainerHigh, 16x6, body bold)` 包裹「HRT 第 N 天」——v2 圆角策略禁 stadium，且 HRT 第 N 天应该用 **mono 数值**（JetBrains Mono Light）作为副行 inline，**不**包 pill。

### P0-6 章节标题（"用药 / 隐私 / 备份 / 关于"）样式不一致 + 无段落标记
v1 章节标题用 `titleMedium · w800 · primary`，与卡内主标题同样字重，无视觉层级差，且没有 v2 强制的"4px 黛蓝竖线段落标记"。换 `HanaSectionHeader`（label-md +0.6 + 4px 黛蓝竖线只覆盖首行）。

### P0-7 SquareCard 双拼 inventory + plan（principles §3 不对称违规）
两张方形卡 1:1 ratio 等宽并列居中——典型对称栅格懒惰。v2 列表屏一律单列纵向，不允许 2-column bento。

### P0-8 wipeAllData 用 inline AlertDialog 写死（widget-pattern-inventory P1-#7）
`showDialog → AlertDialog(radius 24, surfaceContainerLowest)` 内联写在 onTap callback——8 处复制之一。换 `HanaConfirmDialog.show(context, variant: destructive)`。Profile 屏的"清除所有数据"是**少数应该用 Dialog（destructive variant）而非 BottomSheet 的场景**——一次性、不可逆、需要明确"页脚问询"。

### P0-9 PlusJakartaSans 圆润 sans + 装饰 emoji-style icon（DESIGN §3 / §5）
所有标题 `fontFamily: 'Plus Jakarta Sans', fontWeight: w800` + `Icons.medication / inventory_2 / view_quilt / lock / visibility_off / warning / cloud_upload / cloud_download / description` 圈中圆形彩色装饰——v2 字体全切宋体/思源黑体；icon 装饰必须收敛：列表项前置 icon 一律 `outlined` style + ink @ 60%，**禁止彩色 alpha 圆形容器**。

## 2. 7 个 P1 问题

- **P1-1 ListTile separator 用 `_bentoSeparator`（5% primary 横线 24px margin）** — v2 列表分项用间距（spacing.md 16）分隔，不用线。
- **P1-2 chevron 颜色 `outlineVariant`** — 列表项右侧 chevron 应该 inkSecondary（淡墨）@ 60%，且 size 16 而非 20。
- **P1-3 错误态 / 加载态 inline** — 走 `HanaErrorState` / `HanaLoadingView.block`，不再 `Center(CircularProgressIndicator)`。
- **P1-4 SnackBar helper inline `_showSnackBar`** — 替换为 `HanaSnackbar.show`（widget-pattern-inventory P2-#19）。
- **P1-5 `notifications` AppBar action** — Profile 屏不应承担"通知中心"入口；通知设置应作为"偏好"节列表项，AppBar action 改为单一 settings gear（去重）或干脆无 action。
- **P1-6 章节顺序混乱** — v1 顺序：用药 → 隐私 → 备份 → 关于；v2 应按"身份 → 数据 → 隐私 → 偏好 → 关于"五节，"用药"完全不在 Profile（Profile ≠ 用药管理首页）。
- **P1-7 应用更新入口缺失** — v1.2.0 自动更新系统已上线，但 v1 Profile 屏的"关于"节只有版本号、隐私、条款，**没有"检查更新"入口**——必须在"关于"节加一项，使用 mono 显示当前版本 + 上次检查时间。

## 3. 4 个 P2 问题

- 章节间距 40px 是 12/20 之外的"非 token"数（v2 禁止）—改 spacing.lg 32 或 xl 64。
- "我的用药"卡 + 库存/计划双拼区共占屏幕一半——这块功能属于 medication feature，不该在 Profile（Profile 是"我的设置"，不是"用药首页"）。
- "导出 / 导入 / PDF" 三个 ButtonRowItem 视觉相同但层级不同：导出有 trailingText（上次备份日期），导入/PDF 无——应统一为 trailing slot（mono 时间戳或 chevron）。
- 法律页跳转 `/legal/privacy` 与 `/legal/terms` 在 v2 应统一进"关于"列表，与版本号、检查更新放同一卡内。

## 4. 整体叙事重写

v1 想说："这是你的彩色仪表盘，每个功能都有专属圆形 icon 等你点击。" v2 应该说："这是这本内刊的奥付页——你是谁、数据去哪、谁能看见、版本几何，五节读完即关。"

**信息密度**: v2 不"压缩到 1 屏"——profile 是用户**偶尔翻阅**的页，可滚动 2-3 屏没关系。关键是**分章节呼吸**：每节之间 spacing.xl 64 留白，章节内列表项之间用 surfaceContainerLowest 容器内分组（非分隔线）。

**视觉重心**: 移除头像 + bento 卡片堆叠 + 双拼方卡。**唯一视觉重心**是顶部 hero「{用户名 / 无名}」display-xl 宋体 + 副行 mono「HRT 第 245 天　·　起始 2024-08-15」——左对齐 32px，右侧 70% 留白。下方五节顺序铺陈，每节左侧 4px 黛蓝竖线段落标记。**全屏黛蓝出现 ≤ 3 处**：① 顶部 hero 副行的"HRT" tag（可选） ② 当前选中的语言/主题（如"中文"右侧黛蓝小点） ③ 底栏 Profile tab active 下划线。Destructive 操作（清除数据 / 退出）用朱砂，不算黛蓝。
