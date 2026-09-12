# Drug list 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/
> 屏幕：`lib/features/medication/presentation/pages/drug_list_page.dart`
> 阶段：Phase 3.5.b 新稿（spec）+ 自审 critique-v2 内嵌
> 配对 handoff：`docs/design/screens/drug-list/handoff.md`
> 配对 critique：`docs/design/screens/drug-list/critique-v1.md`

---

## 1. 设计意图

Drug list 是这本内刊的**「索引页」**——读者从 Today 翻到这里，想看「我现在在用什么 / 我停过什么 / 我删除了什么」。v1 把它做成"带 chip 的 Material ListView"，v2 必须把它压回 **杂志的索引**：左对齐 hero、章节段落标记、单色克制行项、destructive 走 HanaDialog 红线确认。

跨性别敏感性：列表项不显示性别词，HRT 用药不强调"激素"二字（用 category enum 的本地化 label，inkSecondary，无色编码）；activeDay 用 mono "HRT 第 N 天" 中性陈述。

v1 vs v2 核心差异：v1 是"可滑删的彩色药盒"，v2 是"克制的索引页"。一个浏览动作，从"扫 chip 颜色 → 滑删 → 弹 dialog"变成"翻索引 → 长按出抽屉 → 选择编辑/停用/删除 → 红线确认"。

---

## 2. 屏幕骨架（ASCII Wireframe）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色，无 blur
│   "我的药品"  (label-md +0.6 · ink, 左对齐) │     trailing: "+ 添加" (ghost)
├─────────────────────────────────────────────┤
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│   我的药品                                   │  ← display (32·42·-0.3) 宋体
│   (Spectral SemiBold / 宋体 Medium)         │     ink, 左对齐 spacing.lg=32
│                                             │
│   共 8 味　·　活跃 5 味                      │  ← mono 14·20 inkSecondary 副行
│   (JetBrains Mono Light)                    │
│                                             │
│   (段落间 spacing.xl = 64)                  │
│                                             │
│  ┃ 活跃                                      │  ← HanaSectionHeader
│  ┃ (label-md +0.6 inkSecondary + 4px 黛蓝竖线)│     竖线长度 = 首行 16px
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.list（surfaceContainerLowest）
│   │  雌二醇凝胶                        │    │     列表项内 padding 24 / 20
│   │  estradiol gel                     │ ›   │  ← HanaListItem.withSubtitle + chevron
│   │  2.0 mg　·　涂抹　·　每日 2 次       │    │     subtitle: mono dose · body route · freq
│   ├────────────────────────────────────┤    │
│   │  螺内酯                            │    │
│   │  spironolactone                    │ ›   │
│   │  100 mg　·　口服　·　每日           │    │
│   ├────────────────────────────────────┤    │
│   │  补佳乐                            │    │
│   │  estradiol valerate                │ ›   │
│   │  1.0 mg　·　口服　·　每日 2 次       │    │
│   ╰────────────────────────────────────╯    │
│                                             │     卡间 surface 阶差极弱分组：
│   (节间 spacing.lg = 32)                    │     surfaceContainerLowest (列表项)
│                                             │     vs surfaceContainerLow (1px 横向带)
│  ┃ 已停用                                    │  ← HanaSectionHeader
│  ┃                                          │     竖线同样黛蓝（视觉计 1 处段落标记）
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat（褪色态）
│   │ ⏐ 黄体酮　200 mg　·　口服　·　已停  │    │  ← 1px 淡墨竖线 + inkSecondary 全文
│   ├────────────────────────────────────┤    │     **无 chevron**（褪色项不可编辑路径）
│   │ ⏐ 醋酸环丙孕酮　50 mg　·　口服      │    │     长按出 BottomSheet（恢复 / 删除）
│   ╰────────────────────────────────────╯    │
│                                             │
│   (节间 spacing.lg = 32)                    │
│                                             │
│  ┃ 最近删除  (可选，仅当软删存在)              │  ← HanaSectionHeader
│  ┃                                          │     副行 mono "7 日内可恢复"
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │
│   │ ⏐ 螺内酯（旧）　删除于 4 月 22 日     │ ↺   │  ← trailing: "恢复" ghost mini
│   ╰────────────────────────────────────╯    │
│                                             │
│   (节间 spacing.xl = 64)                    │
│                                             │
│   [ 添加新药 ]   HanaButton.primary          │  ← 黛蓝实色 + 6px + onPrimary
│                  44dp 高，左对齐不 fullWidth │     全屏 primary CTA 唯一 1 处
│                                             │
│   (底部留白 spacing.xl = 64)                │
└─────────────────────────────────────────────┘
```

**空态 / 错误态 / 加载态** 与 today 屏一致：`HanaEmptyState.page`（"无药记录。" + secondary 「添加第一味」）/ `HanaErrorState` / `HanaLoadingView.block`。

---

## 3. 章节结构（2-3 节）

| # | 节名 (zh) | 节名 (en) | 节名 (ja) | 列表项形态 | 卡 variant |
|---|----------|----------|----------|----------|-----------|
| 1 | 活跃 | Active | 服用中 | HanaListItem.withSubtitle + chevron | HanaCard.list |
| 2 | 已停用 | Inactive | 中止中 | HanaListItem flat（褪色） | HanaCard.flat |
| 3 | 最近删除（可选）| Recently deleted | 最近削除 | HanaListItem + trailing "恢复" ghost | HanaCard.list |
| 末 | （添加按钮） | (Add new) | （新規追加） | HanaButton.primary | — |

**v1 → v2 删除**：FloatingActionButton extended、Switch 启停控件（下沉到 BottomSheet）、Dismissible 直接删（保留滑动手势但仅触发 BottomSheet）、4 色 category chip、route icon 装饰。

**第三节"最近删除"启用条件**：当 `softDeletedDrugs.isNotEmpty`；若 v1.1 软删未实施则该节不渲染（feature flag）。

---

## 4. 组件映射

| 区域 | v2 组件 | Variant | 关键 props / 备注 |
|------|--------|---------|---------|
| 顶部栏 | `HanaTopBar` | default | title="我的药品"，无 leading（root tab），trailing 单一 ghost「+ 添加」 |
| Hero 标题 | (Text 直接) | display (32·42) 宋体 | l10n.medications "我的药品"，左对齐 spacing.lg=32 |
| Hero 副行 | (Text mono) | mono | "共 {total} 味　·　活跃 {active} 味"，全角空格 + 中点 |
| 章节标题 | `HanaSectionHeader` | default | 4px 黛蓝竖线（覆盖首行 16px）+ label-md +0.6 inkSecondary |
| 活跃列表卡 | `HanaCard` | list | surfaceContainerLowest, radius 4, padding 0 |
| 活跃列表项 | `HanaListItem` (v1.1 待补 spec) | withSubtitle + chevron | title=drug.name, subtitle=mono dose · route · freq |
| 已停用列表卡 | `HanaCard` | flat | 同 surface 但内容全 inkSecondary，1px 淡墨竖线 |
| 已停用列表项 | `HanaListItem` (v1.1 待补 spec) | flat | 全文 inkSecondary，无 chevron，长按出 BottomSheet |
| 最近删除项 | `HanaListItem` (v1.1 待补 spec) | withTrailingAction | trailing=「恢复」HanaButton.ghost mini |
| 添加 CTA | `HanaButton` | primary | label="添加新药"，44dp 高，左对齐 spacing.lg，**不** fullWidth |
| 长按操作面板 | `HanaBottomSheet` | action-sheet | 活跃药：编辑 / 停用 / 删除；停用药：恢复 / 删除 |
| 删除确认 | `HanaDialog` | destructive | confirmDestructive(title="删除 {药名}？", message="删除后保留 7 日。", confirm="删除", cancel="取消") |
| 永久删除确认（最近删除节）| `HanaDialog` | destructive | "永久删除后不可恢复。" |
| 停用确认 | `HanaBottomSheet` | info | title="停用 {药名}？", body="停用后将不在 Today 显示，可随时恢复。" + ghost cancel + primary 确认 |
| 错误 / 加载 / 空 | `HanaErrorState` / `HanaLoadingView.block` / `HanaEmptyState.page` | — | 同 today 屏 |
| 提示 | `HanaSnackbar.show` | info / success / error | 替代 inline ScaffoldMessenger |

---

## 5. Tokens 引用清单

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| 列表卡容器 | `HanaTokens.surfaceContainerLowest(context)` |
| AppBar 实底 | `HanaTokens.surfaceContainerHigh(context)` |
| Hero 标题 / 活跃列表项主文 | `HanaTokens.ink(context)` |
| 副行 / subtitle / 已停用全文 | `HanaTokens.inkSecondary(context)` |
| 章节竖线 / primary CTA | `HanaTokens.primary(context)` |
| primary CTA 文字 | `HanaTokens.onPrimary(context)` |
| 删除确认 dialog 按钮 | `HanaTokens.error(context)` |
| 已停用左侧 1px 竖线 | `HanaTokens.inkSecondary(context)` @ 60% |

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `spacing.lg` = 32 |
| Hero 顶部留白 | `spacing.xl` = 64 |
| Hero 副行行间 | `spacing.xs` = 4 |
| Hero → 第 1 节 | `spacing.xl` = 64 |
| 节与节之间 | `spacing.lg` = 32 |
| 章节标题 → 列表卡 | `spacing.md` = 16 |
| 活跃列表项内 padding | horiz 24 / vert 20 |
| 已停用列表项内 padding（紧凑）| horiz 24 / vert 16 |
| 末尾 CTA → 屏底 | `spacing.xl` = 64 |
| 节末 → 添加 CTA | `spacing.xl` = 64 |

> 强制跨级：hero(64) → 章节(16) → 项内(20) → 节间(32) → CTA(64) → 屏底(64)，无 16 紧挨 16。

### 圆角
| 用途 | Token |
|------|-------|
| 列表卡容器 | `radius.card` = 4 |
| HanaButton.primary "添加新药" | `radius.button` = 6 |
| HanaButton.ghost「恢复」mini | `radius.button` = 6 |
| HanaDialog 删除确认 | `radius.card` = 4 |
| HanaBottomSheet 长按面板 | 顶 16（kHanaBottomSheetRadius，唯一例外） |

### 字体
| 用途 | Token |
|------|-------|
| Hero "我的药品" | `display` (32·42·-0.3) Spectral SemiBold / 思源宋体 / Noto Serif JP Medium |
| Hero 副行 mono | `mono` (14·20·0) JetBrains Mono Light |
| 章节标题 | `label` (12·16·+0.6) Medium |
| 活跃列表项 title（药名） | `title` (18·26·0) Regular |
| 活跃列表项 subtitle（剂量·途径·频率）| `body-sm` (13·20·0) inkSecondary，含 mono 数值 |
| 活跃列表项 genericName（如显示）| `body-sm` (13·20·0) inkSecondary |
| 已停用列表项 全文 | `body` (15·24·0) inkSecondary 紧凑一行 |
| 最近删除 trailing「恢复」 | `body-sm` (13·20·0) Medium · primary |
| 添加 CTA 文字 | `body` (15·24·0) Medium · onPrimary |

### 动画
| 用途 | Token |
|------|-------|
| 列表项 press scale | `motion.quick` 150ms easeOut → 0.98 |
| 列表入场 fadeIn | `motion.standard` 240ms 错落 80ms |
| 长按出 BottomSheet | `motion.standard` 240ms easeInOut |
| 停用后 reorder（活跃 → 已停用） | `motion.deliberate` 600ms easeOut |
| 删除后 reorder（→ 最近删除） | `motion.deliberate` 600ms easeOut |
| HanaDialog 进出 | 240ms scale 0.96→1.0 / 200ms fadeOut |

---

## 6. HanaListItem（v1.1 spec 待补，本屏与 Profile 共用临时锚点）

继承 Profile spec §6 约定，本屏新增 variants：

| Variant | 视觉 | 用例 |
|---------|------|------|
| `withSubtitle + chevron` | title body·ink + subtitle body-sm·inkSecondary + chevron 右 | 活跃药列表项 |
| `flat`（已停用）| 单行 body·inkSecondary，左侧 1px 淡墨竖线（覆盖整行高），无 chevron | 已停用药 |
| `withTrailingAction` | title body·ink + 删除日期 body-sm·inkSecondary + trailing HanaButton.ghost mini | 最近删除项 |

**长按手势（gestureDetector）**：所有 variants 支持长按出 `HanaBottomSheet.action-sheet`。滑动手势可选保留（向左滑出"删除"快捷），但**不**直接执行删除——仅触发与长按相同的 BottomSheet。

---

## 7. 交互状态

### 默认（首屏装载完成）
- AppBar 实底无底线（offset = 0）
- Hero + 各节列表项依次 fadeIn `motion-standard` 240ms 错落 80ms

### 列表项点击（活跃药）
- HanaPressScale 0.98 / 150ms
- 跳路由：`context.push('/edit_schedule/${drug.id}')`

### 列表项长按（活跃药）
1. `HanaBottomSheet.show(action-sheet)` 240ms 上移
2. 选项：
   - 「编辑」→ 跳 `/edit_schedule/{id}`
   - 「停用」→ 关闭 sheet → `HanaBottomSheet.show(info)` 二次确认 → cubit toggleDrugActive → reorder 600ms → HanaSnackbar 「已停用 {药名}」
   - 「删除」→ 关闭 sheet → `HanaDialog.confirmDestructive` 红线 → cubit deleteDrug → reorder 到「最近删除」节 600ms → HanaSnackbar.error "已删除，7 日内可恢复"

### 列表项长按（已停用药）
1. BottomSheet 选项：「恢复」/「删除」
2. 恢复：cubit toggleDrugActive → reorder 到「活跃」节 → snackbar
3. 删除：HanaDialog 二次确认 → reorder 到「最近删除」

### 「恢复」按钮（最近删除节）
- HanaButton.ghost mini press scale 0.98
- cubit restoreDrug → reorder 到「已停用」节 → HanaSnackbar.success "已恢复"

### 「添加新药」CTA
- HanaButton.primary press scale 0.98
- 跳路由：`context.push('/add_drug', extra: cubit)`

### 滑动手势（保留但不直接删）
- 向左滑动 50% 阈值 → 触发与长按相同的 BottomSheet
- 不再 onDismissed 直接删——避免误删

### 错误态 / 加载态 / 空态
- 与 today 屏完全一致

---

## 8. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，水平 padding 32，列表卡占满 |
| 768–1024 (tablet) | 单列内文页 max-width 720px 居中 |
| ≥ 1024 (web 桌面) | 三列：左 240 sidebar（章节锚点）/ 中 720 主体 / 右 240 留白（不放浮岛） |

---

## 9. i18n 注意（最长文案预测）

| key | en | zh | ja | 最长 |
|-----|----|----|----|------|
| medicationsTitle | Medications | 我的药品 | 服薬リスト | en 11 字 |
| drugSectionActive | Active | 活跃 | 服用中 | en 6 字 |
| drugSectionInactive | Inactive | 已停用 | 中止中 | en 8 字 |
| drugSectionRecentlyDeleted | Recently deleted | 最近删除 | 最近削除 | **en 16 字** |
| drugCountSummary | {total} total · {active} active | 共 {total} 味　·　活跃 {active} 味 | 全 {total} 件　·　服用中 {active} 件 | zh/ja 较长 |
| drugAddNew | Add new | 添加新药 | 新規追加 | en 7 字 |
| drugEdit | Edit | 编辑 | 編集 | — |
| drugDeactivate | Deactivate | 停用 | 中止する | ja 4 字 |
| drugRestore | Restore | 恢复 | 復元 | en 7 字 |
| drugDelete | Delete | 删除 | 削除 | en 6 字 |
| drugDeleteConfirmTitle | Delete {name}? | 删除 {name}？ | {name} を削除しますか？ | ja 较长 |
| drugDeleteConfirmMessage | Kept for 7 days. | 删除后保留 7 日。 | 削除後 7 日間保管されます。 | ja 13 字 |
| drugDeactivateBody | Won't appear on Today. Restore anytime. | 停用后将不在 Today 显示，可随时恢复。 | Today に表示されなくなります。いつでも復元可能。 | zh/ja 较长 |

**排版兼容规则**：
- 列表项 title 允许 `Wrap` 两行（spacing.xs 4 行间）；超出截断 + ellipsis
- 章节竖线高度 = title 首行 line-height（16px），不随多行延长
- subtitle 三段（dose · route · freq）若总宽 > 卡宽 90% → 换 2 行（保留 mono 数值不缩字）
- 「最近删除」trailing「恢复」按钮 ja 「復元」/ en 「Restore」差 4× 字符宽度，按钮按内容自适应宽度（min 64dp / max 96dp）

---

## 10. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — 列表项 ≥ 64dp / CTA 44dp / 「恢复」mini 36dp 偏小 → 提升至 44dp |
| Semantics | ✓ — 活跃项朗读"雌二醇凝胶，2 毫克，涂抹，每日 2 次，按钮"；停用项"已停用：黄体酮，长按管理" |
| 焦点顺序 | AppBar → Hero → 活跃节 → 已停用节 → 最近删除节 → 添加 CTA |
| prefers-reduced-motion | ✓ — reorder 退化为瞬时；fadeIn 跳过 |
| 对比度 | ✓ — ink #1C1A18 on #FBF8F2 = 14.8:1（AAA）；inkSecondary on #FBF8F2 = 7.2:1（AAA） |
| dynamic type | ✓ — title body 18 / subtitle body-sm 13 / mono 14，全部支持系统字号缩放 |
| 长按可发现性 | ⚠ — 长按操作无显式提示；首次进入屏弹一次性 onboarding tooltip "长按药品可管理"（v1.1 加） |

---

## 11. 自审 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色 ≤ 3 处 | ✓ | ① 章节竖线（3 节同色块同义，视觉计 1 处段落标记语法）② 「添加新药」primary CTA（计 1 处） ③ 底栏 active tab 下划线（计 1 处）。「恢复」按钮文字色 primary 但仅在最近删除节出现，单页可见 ≤ 3 项，可接受。 |
| 2. 调和层次胜过投影 | ✓ | 零 BoxShadow / 零 BackdropFilter / 零 border。列表卡靠 surfaceContainerLowest vs background 6 个明度差。已停用褪色 = 全文 inkSecondary + 1px 淡墨竖线（不是边框是段落标记）。 |
| 3. 编辑级不对称 | ✓ | Hero 左对齐 32，右侧 70% 留白。章节竖线段落标记。「添加新药」CTA 不 fullWidth，左对齐放置。 |
| 4. 慢节奏与留白 | ✓ | hero(64) → 章节(16) → 项内(20) → 节间(32) → CTA(64) → 屏底(64)，强制跨级。已停用紧凑（项内 16）但节间仍 32 呼吸。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零彩色 chip / 零 Switch 常驻。category 改 label 文字（"雌激素 / 抗雄"），无色编码。route 改 mono 文字（"皮下注射"）替代 vaccine icon。已停用褪色 = 日记语义（淡墨）取代工具语义（灰 chip）。 |

**遗留风险**：
- HanaListItem 三个新 variants（withSubtitle+chevron / flat / withTrailingAction）未在 components/ 落地，本屏抢跑同 Profile 的临时锚点；Phase 4 补 components/list-item.md 时统一收口
- 「最近删除」节依赖软删机制（soft delete + 7 日保留 + 定时清理），v1 cubit 的 `deleteDrug` 是硬删——需 data 层加 `isDeleted` 字段 + `deletedAt` + 调度任务，否则该节不渲染
- 长按可发现性弱（无显式 hint），首次 onboarding tooltip 暂不在本屏 PR 范围
- "停用" Sheet 用 info variant 但需要 confirm action——HanaBottomSheet info variant 当前 spec 仅一个 close 按钮，需扩展或改用 `action-sheet` 单选 + 确认双层（更重）；折中方案：直接用 `action-sheet` 三选项（编辑 / 停用 / 删除）取消二次确认，停用动作可逆故无需 dialog

---

— 完 —
