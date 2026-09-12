# Knowledge WebView 屏 v1 现状 Design Critique

> **审视范围**: `lib/features/knowledge/presentation/pages/knowledge_webview_page.dart`（139 行）
> **对照基准**: DESIGN.md（v2 编辑级东亚） + tokens.md + principles.md
> **配对输出**: `docs/design/screens/knowledge-webview/spec.md` + `docs/design/screens/knowledge-webview/handoff.md`
> **生成时间**: 2026-04-29

---

## 0. 一句话总结

v1 KnowledgeWebView 把"内嵌外站"做成了**一块磨砂玻璃顶栏 + 全屏 WebView + 中央旋转圆环**——三处 v2 严禁项叠加，且 web 平台直接 `launchUrl` 后立即 pop 回原屏，给用户一种"被弹回"的错位感。v2 必须重写为：HanaTopBar 实色 + leading "返回" + trailing "在浏览器打开" + 加载态 `HanaLoadingView.block` + 错误态 `HanaEmptyState` "无法连接 hrtyaku" + Pull-to-refresh + web 端中性的 "正在打开 hrtyaku.com…" 过渡屏（不立即 pop）。

---

## 1. 6 个 P0 违规（block reason）

### P0-1 BackdropFilter blur(12,12) 顶栏（DESIGN §4 / tokens §5）
L86-118 又是一处工程债：`ClipRRect + BackdropFilter(sigmaX:12, sigmaY:12) + background.withAlpha(0.8*255)`——但 WebView 屏比其他屏更危险：用户滚动外站内容时，磨砂带后面是**外站 DOM 渲染**（不在我们控制内的字体 / 颜色 / 图片），可能产生与 v2 设计语言完全冲突的视觉撞击（外站若有彩色 banner，磨砂后仍透出粉橙红色块）。换 `HanaTopBar.default` 实色 surfaceContainerHigh 严守边界。

### P0-2 CircularProgressIndicator 中央旋转圆环（principles §1 / §5）
L131-134 加载中页面正中央 `CircularProgressIndicator(color: HanaColors.primary)` ——在 v1 这是黛蓝旋转圆环，在 v2 哲学里这是**把稀缺色做成屏保动画**。WebView 加载典型耗时 800ms-3s，圆环旋转 800ms+ 是**长时间消耗黛蓝**的最坏情况。换 `HanaLoadingView.block` 居中 + body-sm 文字 "正在打开 hrtyaku.com…" 淡墨陈述，零旋转。

### P0-3 错误态完全缺失（功能缺失）
v1 只处理了 `onPageStarted` / `onPageFinished` 两个 NavigationDelegate 回调（L46-52），**没有 `onWebResourceError` / `onHttpError`**——网络断 / DNS 解析失败 / 403 禁止访问 / R2 down 时屏幕**永远停留在 loading**状态。这是用户最容易遇到的真实场景：在地铁 / 飞行模式 / 跨境网络受限时打开知识库，v1 给出的反馈是"无限旋转"。v2 必须加 `HanaErrorState` "无法连接 hrtyaku。" + retry 按钮（HanaButton.text 黛蓝文字）+ 错误日志 capture。

### P0-4 Web 平台 fallback 体验突兀（DEC-051 实施不全）
L31-40 web 平台逻辑：`addPostFrameCallback → launchUrl(externalApplication) → context.pop()`。这意味着：用户点击 "知识库" → 屏幕闪一下出现 loading → 立即 pop 回 settings → 同时浏览器开新 tab。这是**两件事同时发生**的混乱反馈。L62-79 虽然有"loading screen"但因为 `addPostFrameCallback` 是同帧触发，loading screen 几乎看不见。v2 必须改为：① 进屏即显示 "正在打开 hrtyaku.com…" 中性文字（display-md 黑墨宋体）+ ② 0.6s 后再 launchUrl + ③ 用户从浏览器返回 app 时本屏自动 pop（而非进屏即 pop）。

### P0-5 Cookie 注入风险（跨性别敏感性 + 安全）
L43-44 `WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted)` ——开启 JS unrestricted 但**无 cookie 隔离配置**。WebView 默认共享 system WebView cookie store，意味着：① 用户 hrtyaku.com 浏览历史 / cookie 会持久化 ② 若用户曾在系统浏览器登录过任何账号，cookie 可能透出到嵌入 WebView ③ HRT 相关 referer 可能被同设备其他 app 读取。**对跨性别用户是身份暴露的高危场景**。v2 必须：① WebView 启动时 `clearCookies()` ② 设置 incognito mode（`AndroidWebViewController` private browsing） ③ 退出时再次 clearCookies。

### P0-6 PlusJakartaSans 字体硬编码（DESIGN §3）
L100-107 AppBar title 又是 `fontFamily: 'Plus Jakarta Sans', fontWeight: w600, fontSize: 18, letterSpacing: -0.5`——v2 切宋体 / 思源黑体 ramp。同时 L73-76 web fallback 屏的 onSurfaceVariant 文字未指定 fontFamily，依赖 Theme 派生在 v1 是 Plus Jakarta，v2 应是思源黑体。

---

## 2. 5 个 P1 问题

- **P1-1 trailing action 是 `Icons.refresh`（L111-114）** — refresh 按钮放在 trailing 位置消耗了"在浏览器打开"的入口位置。v2 应该把刷新做成 **Pull-to-refresh** 手势（HanaPullRefresh 组件），trailing 位置让给"在浏览器打开"icon（`Icons.open_in_new` outlined inkSecondary）——后者对希望脱离应用沙盒、把页面转发给医生 / 朋友的用户更高频。
- **P1-2 leading IconButton 用 primary 色（L97）** — 返回箭头是导航辅助，不该消耗黛蓝配额。改 inkSecondary。
- **P1-3 当前页 title 始终是 "知识库" 静态文字（L101）** — WebView 应该 `onPageFinished` 时调 `controller.getTitle()` 取 hrtyaku 当前页 H1，更新 AppBar title。这样用户从 "HRT 入门" 翻到 "副作用" 时能看到上下文。
- **P1-4 无 SafeArea 处理底部** — L121-136 body Stack 没有 bottom SafeArea，iOS Home Indicator 可能遮挡 WebView 底部内容。
- **P1-5 缺少 "返回" 行为分歧** — 当前 leading back 直接 `context.pop()` 退出整屏。但 WebView 有内部导航栈（用户从 hrtyaku 首页点进 "HRT 入门" 后再点 leading back，期望应该是 webview 内 goBack 而非整屏 pop）。v2 应：webview canGoBack → goBack；否则 pop 整屏。Android 系统 back 按键也按此逻辑。

---

## 3. 4 个 P2 问题

- v1 文件 139 行但**已经有 5 处 v2 严禁项 + 1 处安全风险**——重写后约 220 行（含错误态 + cookie 隔离 + pull refresh + title sync + canGoBack）。
- "在浏览器打开" 入口完全缺失 — 用户希望脱离 app 时无渠道。v2 trailing icon 必加。
- WebView 加载进度条 — v1 仅有"全或无"loading 圆环，无进度反馈。v2 可在 AppBar 下方加 1px 黛蓝细线（progress 0-100%），但要小心黛蓝配额——建议改 inkSecondary @ 60% 1px 细线，不算黛蓝。
- 暗模式下 WebView 内容不会自动跟随 — 外站 hrtyaku.com 自身有暗模式（待确认），WebView 应在 system dark mode 时通过 JS 注入 `prefers-color-scheme: dark` media query。这是 P2 优化项。

---

## 4. 整体叙事重写

v1 想说："这是嵌入的外站，请等待加载。" v2 应该说："你正在阅读 hrtyaku 的当前章节。如需更舒适的阅读体验，可在浏览器打开。"

**信息密度**: WebView 屏的 99% 内容是外站（不归我们控），我们的设计责任在**包装与过渡**——AppBar / 加载 / 错误 / 返回。v2 把这些边框做得克制、中性、不抢戏，让 hrtyaku 的内容在我们的容器里"被尊重地呈现"。

**视觉重心**: AppBar 当前页 title（动态从 webview 取）+ 右侧 "在浏览器打开" icon。**全屏黛蓝出现 ≤ 2 处**：① 错误态 retry 按钮文字（仅错误时）② 加载进度细线（如启用）。返回箭头、refresh icon、空态文字全部 ink / inkSecondary。Web fallback 屏特例：display-md 黑墨宋体 "正在打开 hrtyaku.com…" 居中（与 auth-wrapper `_FrontPageView` 同语法），过渡后由 system browser 接管。

**跨性别敏感性**: WebView 不能注入 cookie（P0-5）；title 同步时如果当前页是 "HRT 入门" 等敏感词，AppBar title 暴露在锁屏通知 / 任务切换 thumbnail 中——必须在 routeAware 检测 app 进入背景时立即模糊 thumbnail（Android: `FLAG_SECURE` / iOS: hidden screen overlay）。这是隐私模式的隐性需求。

— 完 —
