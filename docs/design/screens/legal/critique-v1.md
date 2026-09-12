# Legal 屏 v1 现状 Design Critique

> **审视范围**: `lib/features/settings/presentation/pages/legal_page.dart`（97 行）
> **对照基准**: DESIGN.md（v2 编辑级东亚） + tokens.md + principles.md
> **配对输出**: `docs/design/screens/legal/spec.md` + `docs/design/screens/legal/handoff.md`
> **生成时间**: 2026-04-29

---

## 0. 一句话总结

v1 Legal 把"应用内法律文档"做成了**一个被 BackdropFilter 玻璃磨砂顶栏压住的 SingleChildScrollView**——24px padding + Plus Jakarta Sans 圆润 sans 标题 + `fontSize: 15 / height: 1.7` 一段无章节、无段落标记、无强调层级的纯文本墙。v2 必须把它重写成杂志的 **colophon（奥付页）**：宋体内文、章节小标题、链接黛蓝下划线、底部一行淡墨"联系我们"——严肃但温柔，让用户读条款时感到被尊重而不是被法务恐吓。

---

## 1. 6 个 P0 违规（block reason）

### P0-1 BackdropFilter blur(12,12) 顶栏（DESIGN §4 / tokens §5）
L52-77 又是 13 处工程债之一：`ClipRRect + BackdropFilter(sigmaX:12, sigmaY:12) + background.withAlpha(0.8*255)` 包裹 AppBar。法律页是用户**长时间阅读**的屏幕，磨砂玻璃顶栏在滚动时会出现内容透过模糊带的视觉噪音，反而干扰阅读。换 `HanaTopBar.default` 实色 surfaceContainerHigh + 滚动出现 0.5px outline @ 30% 细线。

### P0-2 Plus Jakarta Sans 标题字体硬编码（DESIGN §3）
L67 `fontFamily: 'Plus Jakarta Sans', fontWeight: w600, fontSize: 18, letterSpacing: -0.5`——v2 字体策略已切宋体（display/title）+ 思源黑体（body），Plus Jakarta Sans 是 v1 残留圆润 sans 必须删除。Legal 页标题应是 `label-md +0.6` Medium inkSecondary 居中（HanaTopBar default 自带），不是装饰性大字。

### P0-3 三类文档共用一屏，无分类切换（功能缺失）
v1 仅支持 `LegalPageType.privacy` / `LegalPageType.terms` 两类（L7-22），用户配置的"第三方许可"（licenses）**整类缺失**——v1.2.0 落地页和 R2 自动更新已经引用第三方依赖（webview_flutter / sqlite3.wasm / pointycastle 等），但应用内**无法浏览许可文本**。v2 必须扩展为三类：privacy / terms / licenses，并且**在屏内提供 tab 切换**而非每次返回 settings 重选——这是用户实际阅读条款时的高频路径（隐私 ↔ 条款互相引用，需要快速来回跳）。

### P0-4 单段纯文本墙（无章节 / 段落标记 / 强调）
L85-92 整个 body 是一个 `Text(content, fontSize: 15, height: 1.7)`——`l10n.privacyPolicyContent` 是一个超长 ARB 字符串塞进单一 Text widget。这意味着：① 无标题分级（H1/H2/H3）② 无段落间距（`\n` 仅插入硬换行，无 paragraph spacing）③ 无超链接（"邮箱 hello@hrtyaku.com" 不是可点击）④ 无强调（粗体 / 下划线 / inline code 全无）。v2 必须改为 **markdown 渲染**（`flutter_markdown` 或 `markdown_widget`），章节用 H2（headline 24/32）+ 段落 body 15 + 链接黛蓝下划线 + 行内代码 mono 14。

### P0-5 24px 水平 padding 不足（节奏违规）
L82-83 `padding: left: 24, right: 24` ——v2 Legal 页是**长时间阅读**屏，水平 padding 应是 `spacing.lg = 32`（移动端）或 max-width 720px 居中（≥ 768 平板/web）。24 是 v1 默认值，在 360dp 宽度下行长 312px，CJK 每行约 22-24 字过密；v2 32px padding 后行长 296px，每行 19-21 字，更接近"内文页"的呼吸节奏。

### P0-6 行高 1.7 + 字号 15（CJK 阅读体验未优化）
L88-91 `fontSize: 15, height: 1.7` 看似合规（tokens.md §2.3 body = 15/24/0 即 height 1.6），但 v2 强制 **CJK 行高从 1.7 起步**（tokens.md §2.3 footnote）——而 1.7 是 zh 起步值，**ja 应 1.75 / 长法律文本宋体应 1.8** 才能让用户连读三屏不疲劳。当前 height 仅按西文标准取值，未做 CJK 优化。同时缺少**段间距**（v2 markdown 段落之间应 spacing.md=16 留白），单纯靠行高拉开段落不够编辑级。

---

## 2. 5 个 P1 问题

- **P1-1 leading IconButton 用 `Icons.arrow_back` + primary 色（L60-62）** — chevron 在 v2 应是 `inkSecondary` size 20 而非 primary（黛蓝在 Legal 屏只允许 ≤ 3 处，分别是：tab active 下划线 / 内文超链接 / "联系我们" 邮箱）。返回箭头是导航辅助，不该消耗黛蓝配额。
- **P1-2 "联系我们" 入口缺失** — v1 整屏无"如何反馈疑问"的引导。Legal 屏底部应固定一行 inkSecondary body-sm "如有疑问，请发邮件至 hello@hrtyaku.com。"——其中邮箱是**唯一允许的内文黛蓝下划线**（mailto: 链接）。这是杂志 colophon 页的标准结构。
- **P1-3 ARB content 是巨型字符串，i18n 维护困难** — `privacyPolicyContent` / `termsOfUseContent` 在三个 ARB 文件里各是一个 1500-3000 字的单 key value，Lokalise / 译者无法分章节翻译，维护时容易整段错位。v2 应拆分为 markdown asset 文件（`assets/legal/privacy.{en,zh,ja}.md`）+ 应用启动时按 locale 加载，ARB 仅放标题和少量 UI 文案 key。
- **P1-4 无加载态 / 错误态** — markdown asset 加载失败 / 文件缺失时 v1 没有 fallback。v2 应：加载中 → `HanaLoadingView.block`；加载失败 → `HanaEmptyState` "暂时无法读取该文档。" + retry 按钮。
- **P1-5 路由参数 `:type` 默认 fallback 到 privacy（L19）** — `LegalPageType.fromString` 的 default case 静默返回 privacy 是错误恢复的反模式（用户输错路由不应静默重定向到隐私页，应跳到 404 / 引导回 settings）。Critical 不属 P0 但应修。

---

## 3. 4 个 P2 问题

- v1 fileSize 仅 97 行但**已经有 5 处 v2 严禁项**（blur / Plus Jakarta / hardcoded color / 无 markdown / 无章节）——重写后约 180 行（含 3 类 tab 切换 + markdown 渲染 + 加载态）。
- 暗模式未单独验证 — markdown 渲染需要 dark theme 下重映射 `code` / `blockquote` / `link` 颜色，v1 完全没考虑。
- "上次更新于 YYYY-MM-DD" 时间戳缺失 — 法律文档应在标题下方显示版本日期（mono 13），用户能判断条款是否近期变更。这是隐私合规的隐性要求（GDPR / 中国《个人信息保护法》均建议显示更新时间）。
- 第三方许可页（licenses）应能展开/折叠每个依赖 — 一个长 list（webview_flutter / sqlite3 / freezed / fpdart 等 30+ 项），每项含名称、版本、许可证类型（MIT / Apache-2.0 / BSD-3）、许可证全文。如果一次铺平会有 200+ 屏，应做 expandable list（`HanaListItem` + onTap 展开许可证全文 markdown）。

---

## 4. 整体叙事重写

v1 想说："这是法务文本，请阅读。" v2 应该说："这是这本内刊的奥付页——出版方信息、读者权利、第三方致谢，五分钟读完即关。"

**信息密度**: v2 不"压缩到一屏"——隐私政策本身就是 3-5 屏的内容。关键是**章节呼吸**：H2 章节标题（"我们收集什么 / 我们如何使用 / 你的权利 / 联系方式"）之间用 `spacing.lg = 32` 留白，章节内段落之间 `spacing.md = 16`，整屏行高 1.75-1.8。

**视觉重心**: 顶部 HanaTopBar 中性标题（"隐私 · 条款 · 许可" 三选 tab）+ 内文宋体内文 + 底部一行"联系我们"。**全屏黛蓝出现 ≤ 3 处**：① 当前选中 tab 下方 2px 下划线（黛蓝） ② 内文中"邮箱 / 官网"超链接下划线 ③ 底部"hello@hrtyaku.com" 邮箱链接。返回箭头、章节标题、段落正文全部墨色 / 淡墨。

**跨性别敏感性**: 法律文案不能预设用户性别表达——"用户" / "您"是中性，禁用"他 / 她"；"医疗信息"是中性，禁用"HRT 用户 / 跨性别者"等可能在他人窥屏时暴露身份的词。隐私政策提及"用户主动填写的健康数据"即可，不必强调具体类目（HRT / 血检 / 日记），避免用户向不知情家人展示条款时被推断使用场景。

— 完 —
