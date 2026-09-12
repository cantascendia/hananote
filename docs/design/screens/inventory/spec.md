# Inventory 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/
> 屏幕：`lib/features/medication/presentation/pages/inventory_page.dart`
> 配对：`docs/design/screens/inventory/{critique-v1,handoff}.md`

---

## 1. 设计意图

Inventory 在 v2 里是 **「内刊里的库房清单页」**——像独立书店收银台后挂的"今日还剩几本"小黑板，宋体小标题 + 等宽数字 + 留白注脚。它不是仓库管理系统，是**这一期我还有什么**。

v1 把 Inventory 做成"低库存报警面板"：红边框 + 红 chip + 警示 icon + 加粗红字四重警示，每翻一页都像在告状。v2 反过来：默认 90% 单色 + 10% 黛蓝，**库存数字用 mono 让它自己说话**，朱砂只在 < 7 天的注脚里出现一次——温度藏在文案颗粒度，不靠红色块。和 data 屏的"数据档案"语法一脉相承。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 默认态（有库存 + 含 1 项偏低）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色 米灰，无 blur
│   "库存"  (title 18 · ink 左对齐 16)         │     右侧 ghost: + (24dp 线性 → 跳新建)
├─────────────────────────────────────────────┤
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│   库存。                                     │  ← display-xl (40·52·-0.5)
│   (Spectral SemiBold / 宋体 Medium · ink)   │     左对齐 spacing.lg=32
│   共 5 项　·　1 项偏低                      │  ← body-sm · inkSecondary
│                                             │     mono 数字 + CJK 全角空格
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 当前库存                                  │  ← HanaSectionHeader · 4px 黛蓝竖线
│  ┃ (label · 12·+0.6 · inkSecondary)         │     竖线长度 = 首行 16px
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable
│   │  雌二醇凝胶                          │    │     surfaceContainerLowest #FBF8F2
│   │  (title 18 · ink)                    │    │     padding md, radius 4
│   │                                      │    │
│   │  剩 47 g                              │    │  ← mono 14 · ink
│   │  (mono Light · ink)                  │    │     当前余量 + 单位
│   │                                      │    │
│   │  约 23 天                             │    │  ← mono 14 · ink（> 14 天 = 默认 ink）
│   │  (mono Light · ink)                  │    │     "约" 是 body 字体，N 是 mono
│   ╰────────────────────────────────────╯    │
│                                             │
│   (卡间 spacing.md = 16)                    │
│                                             │
│   ╭────────────────────────────────────╮    │  ← 第二张：偏低（warning）
│   │  补佳乐                              │    │
│   │  剩 12 片                             │    │
│   │  约 9 天                              │    │  ← mono 染 primary 黛蓝（一抹强色）
│   │  (mono · primary)                    │    │     7-14 天区间
│   ╰────────────────────────────────────╯    │
│                                             │
│   ╭────────────────────────────────────╮    │  ← 第三张：critical（< 7 天）
│   │  螺内酯                              │    │
│   │  剩 18 片                             │    │
│   │  约 5 天                              │    │  ← mono primary 黛蓝（同 warning）
│   │  (mono · primary)                    │    │
│   │  建议补货。                           │    │  ← body-sm · error 朱砂（仅注脚）
│   ╰────────────────────────────────────╯    │
│                                             │
│   ...（按"剩余天数升序"排列，最多 1 列）       │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 最近补货                                  │  ← HanaSectionHeader
│  ┃                                           │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.flat（无 onTap）
│   │  04.27　雌二醇凝胶　+30 g            │    │  ← title 18 mono 日期 + body 药名
│   │  (mono 日期 + body 药名 + mono 增量)  │    │     ink，备注次行 inkSecondary
│   │  自家附近药局　                       │    │  ← body-sm · inkSecondary
│   ╰────────────────────────────────────╯    │
│                                             │
│   ╭────────────────────────────────────╮    │
│   │  04.18　补佳乐　+30 片                │    │
│   ╰────────────────────────────────────╯    │
│                                             │
│   ...（最多 5 条；超出折入 ghost「查看更多」）│
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 通知                                      │  ← HanaSectionHeader
│  ┃                                           │
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.tappable
│   │  低库存提醒　　　　　　　　            ›   │  ← title + chevron 16dp
│   │  剩余 ≤ 14 天时通知。                  │    │  ← body-sm · inkSecondary
│   ╰────────────────────────────────────╯    │     跳 settings 修改阈值
│                                             │
│   (底部 spacing.xl = 64)                    │
└─────────────────────────────────────────────┘
```

### 2.2 全部充足态（无偏低）

```
│   库存。                                     │  ← 同默认 hero
│   共 5 项　·　充足                          │  ← 副行换文案
│                                             │
│  ┃ 当前库存                                  │  ← 全 mono ink，无黛蓝染数字
│  ...                                        │
```

### 2.3 数据缺失态（daysRemaining == null）

某药 `daysRemaining` 为 null（schedule 缺失或剂量未定）—— 第二行只显示 `body-sm · inkSecondary`「估算需服药计划。」（不是错误，是数据未配齐的轻陈述），点卡 onTap 跳 `drug_edit` 让用户补 schedule。**不**显示 "约 N 天" 行。

### 2.4 空态（无任何启用药物）

```
│   库存。                                     │
│   尚未启用。                                 │
│                                             │
│   (spacing.xl = 64)                         │
│                                             │
│   [ HanaEmptyState · variant=page ]         │
│   ⌥ Icon inventory_2_outlined 32dp           │     ink @ 60%，无圆形容器
│                                             │
│   本期空白。                                 │  ← headline 24
│   尚未启用任何药物。                          │  ← body-sm
│                                             │
│   [ 添加第一项 ]   HanaButton.secondary     │  ← 月白底 + 黛蓝 1px 边框
```

### 2.5 错误态 / 加载态

- 错误：`HanaErrorState`「载入失败。请下拉刷新。」+ ghost「重试」（事件: `loadInventory()`）
- 加载：`HanaLoadingView.block`「读取中。」inkSecondary

---

## 3. 补货登记 BottomSheet（核心交互）

点击任何 `当前库存` 卡片 → 弹 `HanaBottomSheet.form`，**不是** AlertDialog。

```
        ───────                              ← drag handle 32×4 / r-pill
  ┌──────────────────────────────────────┐
  │                                      │
  │  补货 · 雌二醇凝胶                    │   ← headline 24
  │  (spacing.lg = 32)                   │
  │                                      │
  │  当前　47 g                           │   ← body-sm + mono · inkSecondary
  │  (spacing.md = 16)                   │
  │                                      │
  │  今日补                               │   ← label 12·+0.6 · inkSecondary
  │  ┌─────────┐  g                       │   ← HanaTextField (mono) + 单位 label
  │  │ + ___   │                          │     keyboardType: numberWithOptions
  │  └─────────┘                          │     底部 1px outline，focus 2px primary
  │  (spacing.md = 16)                   │
  │                                      │
  │  备注（可选）                         │   ← label
  │  ┌──────────────────────────────┐    │   ← HanaTextField · body
  │  │                              │    │     单行，maxLines: 1
  │  └──────────────────────────────┘    │
  │                                      │
  │  (spacing.lg = 32)                   │
  │                                      │
  │  [ 记入 ]   [ 取消 ]                  │   ← Primary 黛蓝 + ghost
  │                                      │
  └──────────────────────────────────────┘
   ↑ 16px radius (顶角)
   ↑ surfaceContainerLowest
   ↑ scrim ink @ 32%
```

**语义重写**：v1 让用户输入"新数量"（reset 总量）；v2 让用户输入"今日补了多少"（增量）—— 存储侧 `qty = current + delta`。理由：用户记得"今天又买了 30 片"远比记得"现在剩 47 片"容易（critique-v1 §3 可用性结论）。

**保存触发**：`InventoryCubit.addStock(drugId, delta, note?)` —— 新增 cubit 方法（handoff §1 详述）；保存成功后 sheet 自动关闭 + 触发 `HanaCelebration.trigger(message: l10n.celebrationRecorded)`「今日已记。」（与 today 屏共享庆祝语法，建立模块一致感）。

---

## 4. 组件映射

| 区域 | v2 组件 | Variant | 关键 props |
|------|--------|---------|-----------|
| 顶部栏 | `HanaTopBar` | `defaultBar` | title=l10n.inventory, action: ghost `Icons.add` → `/medication/drug_list` |
| Hero「库存。」 | (Text) | display-xl 宋体 | 左对齐 spacing.lg |
| 副行（共 N 项 · 偏低 M 项）| (Text + mono) | body-sm | inkSecondary，0 偏低时换"充足" |
| 章节标题 | `HanaSectionHeader` | default | "当前库存" / "最近补货" / "通知" |
| 库存项卡 | `HanaCard` | `tappable` | 点击 → 弹补货 HanaBottomSheet.form |
| 补货历史卡 | `HanaCard` | `flat` | 不可点（**v1 缺该功能，spec 要求 cubit 新增**）|
| 通知入口 | `HanaCard` | `tappable` | 跳 `/settings` → notification 章 |
| 补货登记 | `HanaBottomSheet` | `form` | title=「补货 · {drug.name}」，child=表单，actions=[primary, ghost] |
| 输入框 | `HanaTextField` | default + mono variant | 增量字段强制 mono 字体；备注字段 body |
| 庆祝 | `HanaCelebration` | default | `trigger(message: l10n.celebrationRecorded)` |
| 空态 | `HanaEmptyState` | `page` | 跳新建药物 |
| 错误 / 加载 | `HanaErrorState` / `HanaLoadingView` | default / block | 同 today |

> **明确删除**：v1 `_buildInventoryCard` 内的 Material `Card` + `BorderSide` + 红色 stadium pill chip + warning icon + `_showUpdateDialog` 整段 AlertDialog。

---

## 5. Tokens 引用清单

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| Card 内文页 | `HanaTokens.surfaceContainerLowest(context)` |
| AppBar 米灰 | `HanaTokens.surfaceContainerHigh(context)` |
| Hero / 卡内主标题 / 充足态数值 | `HanaTokens.ink(context)` |
| 副行 / 注脚 / 备注 | `HanaTokens.inkSecondary(context)` |
| **偏低数值（< 14 天）** / 章节竖线 | `HanaTokens.primary(context)`（一抹强色）|
| critical 注脚「建议补货。」 | `HanaTokens.error(context)`（**仅文字注脚，不染数字**） |
| BottomSheet 输入下划线 | `HanaTokens.outline(context)` 1px / focus 2px primary |
| 庆祝文字 | `HanaTokens.primary(context)` |

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `spacing.lg` = 32 |
| Hero 顶部留白 | `spacing.xl` = 64 |
| 段落间（章节↔卡片群）| `spacing.lg` = 32 |
| 卡片之间（同段）| `spacing.md` = 16 |
| 卡内 padding | `spacing.md` = 16 |
| 卡内副行行间 | `spacing.xs` = 4 |
| 屏幕底部 | `spacing.xl` = 64 |
| BottomSheet 顶部 | `spacing.lg` = 32 |
| BottomSheet 字段间 | `spacing.md` = 16 |

> 强制跨级：卡内 4 + 卡间 16 + 段落间 32 三档逐级递增，符合 principles §4。

### 圆角
| 用途 | Token |
|------|-------|
| 所有卡片 | `radius.card` = 4 |
| 输入框 | `radius.input` = 2 |
| 按钮（BottomSheet primary / ghost） | `radius.button` = 6 |
| BottomSheet 顶角 | `kHanaBottomSheetRadius` = 16（**唯一大圆角例外**）|

### 字体
| 用途 | Token / 字体 |
|------|------------|
| Hero「库存。」 | `display-xl` Spectral SemiBold / 宋体 Medium |
| 章节 label | `label` (12/16/+0.6) Medium |
| 卡内主标题（药名 / 通知项标题）| `title` (18/26/0) Regular |
| **数值（剩余量 / 剩余天数 / 补货增量 / 补货历史日期）** | `mono` (14/20/0) JetBrains Mono Light **强约束** |
| 单位（g / 片 / mL）| `label` Medium，紧贴数字右侧 spacing.xs=4 |
| 副行 / 注脚 / 备注 | `body-sm` (13/20/0) inkSecondary |
| 输入框文字（数字增量）| `mono` Light |
| 输入框文字（备注）| `body` (15/24/0) Regular |

### 动画
| 时机 | Token |
|------|-------|
| Hero / 列表项入场 fadeIn | `motion.standard` (240ms) 错落 80ms |
| 卡片 press scale 0.98 | `motion.quick` (150ms) |
| BottomSheet 上移 + scrim 淡入 | `motion.standard` (240ms easeInOut) |
| 补货成功 → 卡片数字重绘（显示新值）| `motion.deliberate` (600ms easeOut) |
| 庆祝淡入 / 淡出 | `motion.deliberate` / `motion.fade` |

**绝对禁止**：粒子、scale > 1 弹跳、spring 曲线、卡片入场旋转 / translate 大位移。

---

## 6. 数据展示原则（剩余天数染色三段式）

参考 data spec §6，立法如下：

1. **> 14 天（充足）**：数字 mono `ink`，无任何修饰。"约 23 天" 这五个字就是装饰。
2. **7-14 天（偏低 / warning）**：数字 mono **`primary` 黛蓝**——一抹强色用在数值本身，无注脚加色。
3. **< 7 天（critical）**：数字仍 mono `primary` 黛蓝（**不染朱砂**），**额外多一行 body-sm 朱砂注脚**「建议补货。」——朱砂仅落在文字注脚上，确保 destructive 色保留稀缺感（与 data 屏 critical 完全同语法）。
4. **`daysRemaining == null`（数据缺失）**：第二行换 body-sm inkSecondary「估算需服药计划。」，无数字行。
5. 全屏可见区域内 mono primary 数字 ≤ 3 处。如果 4+ 个药都偏低 → spec 允许，PR 时人工 review；同时 hero 副行「N 项偏低」用 mono ink（不染黛蓝，避免叠加）。

> **isLowStock 阈值更新**：`CheckInventory` 当前用 `daysRemaining < 14` 一刀切（`check_inventory.dart:54`）—— v2 改为 `daysRemaining < 14`（warning）+ `daysRemaining < 7`（critical）双阈值，state 增加 `criticalCount` 字段（handoff §1）。

---

## 7. 交互状态

### 默认装载完成
- AppBar 实色米灰，无底线（offset = 0）
- Hero / 章节 / 卡片同时入场：列表项 `motion-standard` 240ms fadeIn 错落 80ms
- 排序：当前库存按 `daysRemaining` 升序（最紧迫的在最上）；null 值排最末

### 库存卡按下
- `HanaCard.tappable` press scale 0.98 + `motion-quick`
- onTap → `HanaBottomSheet.show(context, sheet: HanaBottomSheet.form(...))`
- **若 daysRemaining == null**：onTap 改跳 `/medication/drug_edit?id={drugId}` 让用户补 schedule（不是补库存）

### 补货登记保存
1. 校验：增量 > 0 + 不超过 9999（防误输）
2. cubit 派发 `addStock(drugId, delta, note?)` → repo `updateInventory(qty + delta)`
3. 成功 → BottomSheet `Navigator.pop()` 关闭 → cubit `loadInventory()` 重载
4. 该卡片数字 600ms 平滑重绘到新值（`AnimatedDefaultTextStyle` 不行，需用 `TweenAnimationBuilder<int>`）
5. 触发 `HanaCelebration.trigger(message: l10n.celebrationRecorded)`「今日已记。」
6. 如果该药从 critical/warning 升到充足 → 黛蓝染色自动消失（不另加动画）

### 补货历史卡
- `HanaCard.flat`，无 onTap（v2 暂不允许编辑历史，避免数据回溯篡改）
- 超过 5 条 → 末尾加 `HanaButton.ghost`「查看更多」→ 跳 `/medication/inventory_history`（**新路由，handoff §2 列为 follow-up，本 PR 不实施**）

### 通知入口
- onTap → `/settings`（直接到设置首页，由用户找通知章；R52-D 后通知设置可深链到具体阈值滑块）

### 错误重试 / 下拉刷新
- 同 today / data 屏规则；下拉触发 `loadInventory()`

---

## 8. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，padding 32，卡片占满 |
| 768–1024 (tablet) | 单列 max-width 720px 居中 |
| ≥ 1024 (web 桌面) | 三列：左 240 sidebar（章节锚点跳转）/ 中 720 内文页 / 右 240 浮岛（统计：本月补货 N 次・总支出未列入 v2） |

> mobile 主战场。tablet/web 仅约束 max-width。

---

## 9. i18n 注意

- ja「在庫」比 zh「库存」短，hero 不会撑开；但「補充します」「在庫切れ警告」比 zh 长 ~30%，BottomSheet 标题预留 `Wrap`。
- 单位（g / mL / 片 / 錠 / tab）保留 ARB key（不本地化数学单位 g/mL，但「片」zh / 「錠」ja / 「tab」en 需切）。
- 「约 N 天」zh / 「およそ N 日」ja / 「~N days」en —— ARB key `inventory.daysApprox(days)`。
- 「建议补货。」zh / 「補充をおすすめ。」ja / 「Restock soon.」en —— ARB key `inventory.criticalSuggest`。
- 「N 项偏低」/「充足」—— ARB key `inventory.heroSubLow(count)` / `inventory.heroSubAmple`。
- 数值 mono 字体不参与 locale 切换。

---

## 10. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — 库存卡 / 通知卡整张可点；BottomSheet 按钮 44dp+ |
| Semantics | 库存卡 = 「{drug.name}　剩 {qty}{unit}　约 {days} 天　{statusText}」整体 1 个 button |
| BottomSheet a11y | `Semantics(scopesRoute: true, namesRoute: true, label: title)`；ESC / 物理返回关闭 |
| 焦点顺序 | AppBar → hero → 当前库存（每卡 1 单元）→ 最近补货 → 通知入口 |
| prefers-reduced-motion | 卡片 fadeIn / 数字重绘 / BottomSheet 滑入全部跳过；庆祝退化静态 1.5s |
| 对比度（light）| ✓ — primary #1F3A5F on #FBF8F2 = 9.0:1（AAA）；error #9B2A2A on #FBF8F2 = 7.4:1（AAA） |
| 对比度（dark）| ✓ — primary #7A9CC2 on #252320 = 6.4:1（AA+） |

---

## 11. 自我 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色（黛蓝 ≤ 3 处）| ✓ | ① 章节竖线（结构装饰，3 处但首行高度）② 偏低/critical 数字 mono primary（典型 1-2 处，硬规则 ≤ 3）③ 庆祝触发时文字。AppBar / Hero / 充足态数字全部墨色。 |
| 2. 调和层次胜过投影 | ✓ | surface 4 级（background → containerLowest 卡 → containerHigh AppBar）。零 BoxShadow / 零 BackdropFilter / 零 border。 |
| 3. 编辑级不对称 | ✓ | Hero 左对齐 32px。章节竖线段落标记。库存 1 列（不 GridView）。AppBar 去 `centerTitle`。 |
| 4. 慢节奏与留白 | ✓ | 顶部 64px。卡间 16 + 段落间 32 跨级。1 列 + 副行注脚。BottomSheet 滑入 240ms。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零警示 icon（删 warning_amber_rounded）。状态用排版表达（mono 染色 + 朱砂注脚）。 |

**自审遗留风险**：
- 「最近补货」需要 cubit 新增 `getRecentStockEntries` API；如果 R52 周期内来不及，本节降级为隐藏（不阻塞主重写）—— handoff §2 标 follow-up。
- 全屏 5+ 个药都偏低的极端场景下黛蓝出现 5+ 次—— principles §1 硬规则被打破。spec 决策：可接受（用户库存全面紧张本身就是值得警觉的信号），但 hero 副行 mono primary 应改为 mono ink 避免叠加。
- 通知入口"跳 settings 首页"是过渡方案，理想是深链到通知阈值小屏。R52-D 通知子模块完成后调整。

---

## 12. 与 critique-v1 的 P0 逐项消除

| critique-v1 P0 | v2 处理 |
|---------------|--------|
| 1. 整套色 token 用 `colorScheme.error/errorContainer/withAlpha` | 全切 `HanaTokens.*(context)` 单轨 API |
| 2. Material `Card` + `BorderSide` 边框定义层级 | 替换 `HanaCard.tappable`，零边框零阴影 |
| 3. 圆角 16 / 20 / dialog 默认 | 全统一：卡片 4 / 按钮 6 / BottomSheet 16（顶角）/ 输入 2 |
| 4. `AlertDialog` + 单 TextField 表达补货 | 重写 `HanaBottomSheet.form` + 增量语义（+N） + 备注字段 |
| 5. 数值未用 mono 字体 | 全部走 `mono` JetBrains Mono Light |
| 6. 无 hero / 无章节标题 / 扁平列表 | 加 display-xl「库存。」+ 副行 + 3 个 HanaSectionHeader 段落 |
| 7. 低库存四重红色警示（border + chip + 字红 + icon）| 删除 chip + border + icon；改 mono 黛蓝数字（warning）+ 朱砂注脚（critical） |
| 8. AppBar `centerTitle` + 缺新建入口 | `HanaTopBar` 左对齐 + ghost「+」action |

> **额外消除（critique-v1 P1）**：
> - 删 line 1-3 release-prep 注释
> - 卡间 12 → 16；屏顶 64 留白
> - 增加补货历史段（cubit 扩展）
> - 增加通知入口（跳 settings）
> - 文案全部切 v2 编辑体（句号 + 第三人称）

---

— 完 —
