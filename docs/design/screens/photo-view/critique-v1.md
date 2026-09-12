# Photo View 屏（全屏查看）v1 现状 critique

> Generated 2026-04-29 by AI design review against DESIGN.md v2 + tokens.md + principles.md
> 屏幕：lib/features/photo/presentation/pages/photo_view_page.dart
> 用户场景：从 photo 网格点开单张 → 全屏查看身体照片 → 查看元数据 / 删除 / (P2 分享 / 对比)
> 重设计阶段：Phase 3.1 Pilot Wave critique-v1（Photo View 屏）

## 1. 当前实现概要

photo_view_page.dart 是一个 `Scaffold(backgroundColor: Colors.black)` + `AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white)` + 标题 `DateFormat('yyyy.MM.dd').format(widget.entry.date)` 西文格式日期 + 右上 `Icons.delete_outline` IconButton（67-83）。Body 是 `Column` 上下分栏：上半 `Expanded` 居中显示图像 `_buildImageArea`（86-90、138-213），用 `InteractiveViewer(maxScale: 4)` 包 `Hero(tag: 'photo-${entry.id}')` 包 `Image.memory`；下半是固定底部 220-260px 高度的**白色卡片**（91-132）—— `Colors.white` 实色 + `BorderRadius.vertical(top: Radius.circular(24))` + `boxShadow(black @ 40alpha, blurRadius 16, offset 0,-4)` —— 内部 `Column.start` 显示备注 label + 备注内容 + 文件大小（109-130）。

加载态：thumbnail 占位 + 黑色半透明圆 spinner 居中（177-212）；无 thumbnail 时 220×220 `Colors.white.withAlpha(16)` 圆角灰盒 + `Icons.photo_outlined` 72px `Colors.white54` 大图标（189-202）。错误态：`Icons.broken_image_outlined` `Colors.white70` + 错误文字 + `FilledButton` 重试（153-174）。删除走标准 Material `showDialog<bool>` + `AlertDialog`（240-258）。

**功能缺失**：① 无分享入口（spec 提到的）；② 无对比入口；③ 无"图像将以未加密形式离开本机" 的隐私警告 BottomSheet —— 一旦 P2 加分享时这是高优先级红线。

## 2. 违规点逐项（按 v2 5 原则）

### 原则 1：一抹强色（黛蓝 ≤ 3 处/屏）

- 现状：① AppBar 删除 IconButton 走默认 foregroundColor: Colors.white（69、80）—— 可见但不突出；② FilledButton 重试按钮在错误态走 default primary（168-171）—— 暗背景下 primary 可能反差过强；③ 备注 label「备注」走 `HanaColors.onSurfaceVariant` 淡墨（112-114）；④ thumbnail 占位的灰盒 + photo_outlined 大图标（189-202）—— 装饰非黛蓝但视觉权重高。
- 违规：本屏黛蓝可见点 ≤ 1（FilledButton），其实**没有明确的 v2 黛蓝主导锚点**。但**白色固定底部 panel** 占屏 ~30% 高度是更大问题——它是大块亮色面板穿透黑底，破坏全屏沉浸感（隐私查看仪式感）。
- 优先级：P0（白色底部 panel 是核心问题，不是黛蓝过多）
- 改动建议：底部白色固定 panel **完全删除**，改为 `HanaTopBar transparent` 顶栏 + 底部 `inkSubdued` mono 元数据**单行**「4 月 28 日 · 周二 · HRT 第 245 天」浮在黑底上（无背板）；备注内容若有则升起 HanaBottomSheet.info（按需而非常驻占屏）；FilledButton 重试 → `HanaButton.ghost` 雪宣文字（透明底）。

### 原则 2：调和层次胜过投影

- 现状：① 底部白色 panel `boxShadow(black @ 40alpha, blurRadius: 16, offset: 0, -4)`（98-104）—— 投影向上呈现"漂浮卡"效果，是 Material 风格典型；② panel 24px 圆角顶部（97）—— 远超 v2 r-card=4；③ 加载占位 `Colors.white.withAlpha(16)` 半透明圆角灰盒（189-196）+ 24px 圆角；④ 中央 spinner 黑色半透明圆容器 `Colors.black.withAlpha(120)`（203-211）。
- 违规：boxShadow + 24px 圆角 + 半透明叠加圆 全部为 v2 严禁清单。photo-view 是**全屏沉浸屏**，应该**零层次**（图像本身是唯一焦点，不需要"卡片抬起"）。
- 优先级：P0
- 改动建议：删除底部 panel boxShadow + 圆角 + 实色背景；删除中央 spinner 圆容器（改极弱细线 progress 在屏幕底部 1px 横条）；占位 220×220 灰盒删除（改单行 mono "解密中…" inkSubdued 居中）。

### 原则 3：编辑级不对称（左对齐 32px，避免居中）

- 现状：① AppBar 标题居中（默认 Material AppBar `centerTitle` 平台相关）—— 不一致；② 底部 panel 内文 `CrossAxisAlignment.start` 左对齐（107）—— 这一点 ✓；③ 加载态 / 错误态全部居中布局（87、177-179、156-174）—— 全屏 Center 是 v2 严禁的居中懒惰；④ panel 横向 padding `EdgeInsets.fromLTRB(16, 16, 16, 28)`（93）—— 16 未达 spacing.lg=32。
- 违规：居中 AppBar 标题 + 居中加载占位 + 16px panel padding 三处违规。但 **photo-view 本身是全屏图像查看屏 —— "居中显示图像"是用户预期合理行为，不算居中懒惰违规**（图像是视觉焦点）。问题在于**元数据 / CTA / 状态文字** 不应跟着居中。
- 优先级：P1
- 改动建议：AppBar 走 `HanaTopBar transparent` `centerTitle: false` 标题左对齐（或干脆无标题，仅左侧返回箭头 + 右侧操作）；底部元数据**左对齐 32px**（不居中、不全宽）；加载/错误状态文字左对齐 32px。

### 原则 4：慢节奏与留白

- 现状：① panel padding `(16, 16, 16, 28)`（93）—— 16 紧挨 16 + 28 拼凑非 token 值；② panel 内备注 label → 内容 `SizedBox(height: 4)`（116）—— 4 不在 v2 token；③ 备注 → 文件大小 `SizedBox(height: 12)`（121）—— 12 是 v2 故意删除的间距值；④ `_formatFileSize` 显示文件大小（123-129）—— 全屏查看屏显示文件 KB / MB 数对用户**毫无意义**（用户关心的是日期 / HRT 第 N 天，不是 1.2 MB）。
- 违规：间距值 4 / 12 / 28 全不在 token；文件大小信息低价值占用屏内空间；缺乏全屏查看应有的"留白沉浸"节奏。
- 优先级：P1
- 改动建议：删除文件大小行（替换为"HRT 第 N 天" mono 副行——这才是用户关心的对比锚点）；底部元数据单行 mono「4 月 28 日 · 周二 · HRT 第 245 天」inkSubdued 浮在黑底；备注若存在升起 HanaBottomSheet.info 按需查看（不常驻占屏）。

### 原则 5：内容即装饰

- 现状：① AppBar 右上 `Icons.delete_outline` IconButton（80）—— v2 优先文字 CTA 但删除是常用快捷动作允许 icon；② 加载占位 `Icons.photo_outlined` 72px 大图标（197-201）—— 装饰承担"图像即将出现"语义；③ 错误态 `Icons.broken_image_outlined`（160）—— 装饰图标承担情感；④ 中央 spinner 黑半透明圆容器（203-211）—— 装饰；⑤ 标题写死 `'yyyy.MM.dd'` 西文格式（70）—— 不走 locale。
- 违规：装饰 icon 多处 + 写死日期格式 + 缺少 v2 编辑陈述文案（如"解密中。" / "无法读取。"）。
- 优先级：P1
- 改动建议：删除 photo_outlined 占位大图标（改单行"解密中。" mono inkSubdued）；删除 broken_image 错误图标（改单行"无法读取。" + 重试 ghost button）；删除中央 spinner 圆容器（改屏底 1px 进度条）；日期格式走 `DateFormat.yMMMEEEEd(localeName)`（中文输出"4 月 28 日 周二"）。

## 3. 7 个评审维度

### 可用性
当前实现的核心问题：① **无分享入口**（spec 提到分享需带"图像将以未加密形式离开本机" HanaBottomSheet 警告）；② **无对比入口**（photo 屏的核心价值是身体变化对比，但 photo-view 单张查看无法触发对比）；③ **无双指捏合外的关闭手势**（无 swipe-down dismiss 是常见 photo-viewer 手势）。文件大小信息低价值。HRT 第 N 天信息缺失（用户最关心的对比锚点被替换为对用户无意义的 1.2 MB）。

### 层次
全屏查看屏应该是**零层次**（图像是唯一焦点）。当前 v1 用底部白色固定 panel + boxShadow + 24px 圆角制造"卡片抬起" → 屏幕被切两半，下半 30% 是亮色 panel 穿透黑底——破坏全屏沉浸。

### 一致性
与 DESIGN.md 偏差：① 全部用 `HanaColors.*` 未迁 `HanaTokens`；② 圆角 24 / 999 stadium 多种值；③ 文案"备注" / "文件大小" 未对齐 v2 编辑体；④ AppBar 用 Material AppBar 未走 `HanaTopBar`；⑤ 删除走 Material AlertDialog 未走 `HanaDialog.confirmDestructive`；⑥ FilledButton 走 default primary 未走 `HanaButton.*`。

### 情感色彩
photo-view 是 HRT 用户**最私密的查看时刻**——可能在私密时刻独自对比身体变化。当前 v1 的视觉是"标准 photo viewer"（黑底 + 白底 panel + Material 删除按钮）—— 缺少"这是受加密保护的私密时刻"的安心感和"沉浸式查看"的仪式感。**没有显式分享警告也是情感安全红线**：用户不小心分享一张未加密身体照片到社交 app 会是灾难。

### 暗色模式
`HanaColors.onSurfaceVariant` 在 panel 内文（112-127）—— light 值固定。全屏黑底是 light 模式下的强制反转（与 background 月白冲突）—— v2 photo-view 应**保持黑底**（沉浸感不分明暗模式）。错误态 `Colors.white70` / `Colors.white54` / `Colors.black.withAlpha(120)` 多处写死。

### i18n
标题写死 `DateFormat('yyyy.MM.dd')`（70）不走 locale。`fileSize` ARB 已存在但调性 + 价值低。HRT 第 N 天 mono 副行需新增 ARB key。日文"備考" / "ファイルサイズ" 较中文长 ~30-50%，panel 单行展示风险。

### 响应式
完全未处理 ≥1024 web 端。Web 桌面下底部白 panel 全宽展开 → 用户在 27" 屏看一张身体照片下方 1920px 宽空白白底 panel —— 视觉荒诞。photo-view 在桌面应限制图像 max-width 1080 居中 + 元数据浮在屏底（不全宽）。

## 4. P0 / P1 / P2 总清单

**P0（必须 v2 重做）**：
1. 删除底部白色固定 panel（91-132）—— 全屏沉浸黑底 + 元数据浮在底部 mono inkSubdued 单行
2. 删除 panel boxShadow（98-104）+ 24px 圆角（96-97）
3. 删除占位 `Colors.white.withAlpha(16)` 220×220 灰盒（189-196）+ `Icons.photo_outlined` 72px 大图标（197-201）
4. 删除中央 spinner 黑半透明圆容器（203-211）—— 改屏底 1px 进度条 + 单行"解密中。"
5. 删除"文件大小"显示（123-129）—— 替换为"HRT 第 N 天" mono 副行（用户真正关心的对比锚点）
6. AppBar 走 `HanaTopBar transparent`（黑底之上透明顶栏 + 雪宣 onPrimaryDark 文字）
7. 删除 `Icons.broken_image_outlined`（160）—— 改单行文字"无法读取。" + ghost 重试
8. 备注内容若有 → 升起 `HanaBottomSheet.info`（按需查看，不常驻占屏）
9. 删除走 `HanaDialog.confirmDestructive`（朱砂"删除"按钮）替换 Material AlertDialog
10. 加分享入口：右上工具栏 `HanaIconButton` 分享 → 升起 `HanaBottomSheet` 警告："图像将以未加密形式离开本机"+「确认分享」+「取消」（**跨性别敏感性 P0 红线 — 必须有警告**）
11. 加对比入口：右上工具栏第二个按钮 → 升起 `HanaBottomSheet` 选另一张 `HanaListItem` 列表 → 进对比模式
12. 全部 `HanaColors.*` → `HanaTokens.*(context)` + `HanaTokens.onPrimaryDark`（黑底白字）
13. 标题日期格式走 `DateFormat.yMMMEEEEd(localeName)`

**P1（强烈推荐）**：
- 加 swipe-down 关闭手势（标准 photo-viewer 行为）
- 双指捏合缩放保留 `InteractiveViewer(maxScale: 4)`（不删，已合规）
- 元数据左对齐 32px（不居中）
- 间距值 4 / 12 / 28 全部 token 化
- AppBar 走 `centerTitle: false` 不再居中标题（或干脆无标题让 hero 元数据承担日期）
- prefers-reduced-motion 跳过 Hero 共享元素

**P2（增强）**：
- 对比模式：双图分屏左右对比（mobile 上下分屏）+ 顶部时间轴 slider 在月份间快速切换
- 长按图像呼出"图像信息" sheet（HRT 起始日 / 标签 / 备注 / 元数据完整列表）
- 不要"保存到相册"按钮（**关键 P2 拒绝项**：身体照片不应允许导出到系统相册——会与系统云同步泄露）

## 5. 跨性别敏感性总览

| 层面 | v1 现状 | v2 修复 |
|-----|--------|--------|
| 全屏沉浸感 | 底部白 panel 切走 30% 屏 | 全屏黑底 + 元数据浮底单行 |
| 分享警告 | **无**（spec 要求"图像将以未加密形式离开本机"警告） | HanaBottomSheet 阻断式警告 + 二次确认 |
| 保存到系统相册 | 无此按钮（✓ 沿用） | **明确拒绝**——不加该按钮（避免与系统云同步泄露） |
| 元数据信息价值 | 文件大小（无价值）| HRT 第 N 天（高价值，对比锚点） |
| 删除二次确认 | Material AlertDialog | HanaDialog.confirmDestructive 朱砂 |

—— 完 ——
