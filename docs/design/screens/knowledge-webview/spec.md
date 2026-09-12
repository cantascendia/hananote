# Knowledge WebView 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/
> 屏幕：`lib/features/knowledge/presentation/pages/knowledge_webview_page.dart`
> 阶段：Phase 3.x 新稿（spec）+ critique-v2 配套
> 配对 handoff：`docs/design/screens/knowledge-webview/handoff.md`
> 配对 critique：`docs/design/screens/knowledge-webview/critique-v1.md`

---

## 1. 设计意图

知识库 WebView 是这本内刊的**外联读者参考资料**——hrtyaku.com 是我们维护的开放知识库，但它本身不是 v2 设计语言的一部分。本屏的设计责任**不是控制 hrtyaku 内容**，而是把"嵌入外站"这件事做得**克制、中性、不抢戏**——让 hrtyaku 在我们的容器里"被尊重地呈现"。

v1 vs v2 核心差异：v1 是"磨砂玻璃顶栏 + 全屏 WebView + 中央旋转圆环 + 静态标题"，v2 是"实色顶栏 + 动态当前页 title + Pull-to-refresh + 错误态兜底 + cookie 隔离 + 'web 端体面过渡'"。

跨性别敏感性：① WebView 强制 cookie 隔离（incognito + clear on enter/exit）② AppBar title 动态同步当前页可能暴露 "HRT" 等关键词，需在 app 进背景时屏蔽 thumbnail（FLAG_SECURE）③ web 平台 fallback 文案严禁出现 "HRT / 跨性别 / 健康" 等可暴露身份的词，仅 "正在打开 hrtyaku.com…" 中性陈述。

---

## 2. 屏幕骨架（ASCII Wireframe）

### 2.1 移动端（Android / iOS）默认态

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色，无 blur
│  ←  HRT 入门          ⎘                     │     leading=back chevron(inkSecondary)
│                                             │     title=label-md +0.6 ink (动态 title)
│                                             │     trailing=open_in_new(inkSecondary)
├─────────────────────────────────────────────┤
│ ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁                           │  ← 1px 进度条 inkSecondary @ 60%
│                                             │     0-100% 平移，加载完隐藏
├─────────────────────────────────────────────┤
│                                             │
│   [WebView 内容 by hrtyaku.com]             │  ← 外站 DOM，不在我们控制内
│                                             │     可 Pull-to-refresh 手势刷新
│                                             │
│                                             │
│                                             │
│                                             │
│                                             │
└─────────────────────────────────────────────┘
```

### 2.2 加载态（首次进入 / refresh）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default                          │  ← title="知识库"（fallback，动态 title 还没拿到）
│  ←  知识库            ⎘                     │
├─────────────────────────────────────────────┤
│ ▁▁▁▁▁▁▁▁▁▁▁                                 │  ← 进度条 0-60% 平移
├─────────────────────────────────────────────┤
│                                             │
│                                             │
│                                             │
│                                             │
│            [HanaLoadingView.block]          │  ← 居中
│            正在打开 hrtyaku.com…             │  ← body-sm 13/20 inkSecondary
│                                             │     无旋转圆环
│                                             │
│                                             │
└─────────────────────────────────────────────┘
```

### 2.3 错误态（网络失败 / DNS / 403）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default                          │
│  ←  知识库            ⎘                     │
├─────────────────────────────────────────────┤
│                                             │
│                                             │
│                                             │
│            [HanaEmptyState.page]            │
│                                             │
│             无法连接 hrtyaku。               │  ← title 18/26 ink
│           请检查网络后重试。                  │  ← subtitle 13/20 inkSecondary
│                                             │
│              [  重试  ]                      │  ← HanaButton.text (黛蓝文字)
│                                             │
│                                             │
└─────────────────────────────────────────────┘
```

### 2.4 Web 平台 fallback 过渡屏

```
┌─────────────────────────────────────────────┐
│                                             │  ← 月白纯色，无顶栏
│                                             │     仅 SafeArea，无 AppBar
│                                             │
│                                             │
│                                             │
│        正在打开 hrtyaku.com…                 │  ← display-md 32/42 黑墨宋体居中
│                                             │     0.4s 静默后淡入 0.6s
│                                             │     (与 auth-wrapper FrontPage 同节奏)
│                                             │
│                                             │
│                                             │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 3. 状态机与节奏

### 3.1 移动端状态

| State | 渲染 | 触发 | 节奏 |
|-------|------|------|------|
| `Initial` | HanaLoadingView.block | 进屏 | 立即显示 + 加载 webview |
| `Loading` | HanaLoadingView.block + 进度条 | onPageStarted | 进度条 0→60%（资源开始加载） |
| `Ready` | WebView 显示 + 进度条隐藏 | onPageFinished | 进度条 60→100% 200ms 后 fadeOut |
| `Error` | HanaEmptyState.page + retry | onWebResourceError / onHttpError | 立即切错误态 |
| `Refreshing` | HanaPullRefresh spinner（顶部） | 用户下拉 | spinner 在 webview 上方 1px 细线表示 |

### 3.2 Web 端状态（`kIsWeb`）

| Phase | 时间 | 渲染 | 行为 |
|-------|------|------|------|
| 0.0-0.4s | 静默期 | 月白纯色 | 等待入屏稳定 |
| 0.4-1.0s | 文字淡入 | "正在打开 hrtyaku.com…" display-md fadeIn 600ms | `motion-deliberate` |
| 1.0-1.4s | 停留 | 文字保持 | 让用户读到这句 |
| 1.4s | 触发 launchUrl | externalApplication 模式 | 打开新 tab |
| 1.4-3.0s | 等待用户回 app | 文字保持 | 用户在新 tab 阅读 hrtyaku |
| 3.0s | auto pop | 检测窗口 visibility 变 hidden 后 pop | 而不是立即 pop |

> **关键**：v1 是 launchUrl + 立即 pop，造成"屏幕闪一下"的混乱。v2 是先文字陈述 + 延迟 launchUrl + 等用户回来再 pop——给用户时间理解"我正在被引导到外部"。

---

## 4. 组件映射

| 区域 | v2 组件 | Variant | 关键 props / 备注 |
|------|--------|---------|---------|
| 顶部栏 | `HanaTopBar` | default | title=动态当前页 / fallback "知识库"，leading=back chevron(inkSecondary)，trailing=open_in_new(inkSecondary) |
| 加载进度条 | (Container) | — | 1px 高 · color=inkSecondary @ 60% · 平移 0-100% |
| 加载态 | `HanaLoadingView` | block | 居中 + body-sm "正在打开 hrtyaku.com…" inkSecondary |
| 错误态 | `HanaEmptyState` | page | title="无法连接 hrtyaku。" subtitle="请检查网络后重试。" + retry |
| 重试按钮 | `HanaButton` | text | label="重试"，黛蓝文字，44dp 高 |
| Pull-to-refresh | `HanaPullRefresh` | default | 包裹 WebViewWidget，下拉触发 controller.reload() |
| WebView 容器 | `WebViewWidget` | — | controller 配置见 §5 |
| Web fallback | (Text + AnimatedOpacity) | display-md | "正在打开 hrtyaku.com…" 黑墨宋体居中淡入 |
| Snackbar（错误日志） | `HanaSnackbar.show` | error | "已记录错误（不含个人数据）" |

---

## 5. WebView 控制器配置（cookie 隔离强制）

```dart
final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setBackgroundColor(HanaTokens.background(context))
  // 隐私模式（cookie 隔离）
  ..clearCache()
  ..clearLocalStorage();

// Android 平台特例
if (controller.platform is AndroidWebViewController) {
  final androidController = controller.platform as AndroidWebViewController;
  await androidController.setMediaPlaybackRequiresUserGesture(false);
  // FLAG_SECURE 在 routeAware 中处理（app 进背景时屏蔽 thumbnail）
}

// 进屏清 cookie
await WebViewCookieManager().clearCookies();

controller.setNavigationDelegate(NavigationDelegate(
  onPageStarted: (_) => emit(state.copyWith(loading: true, progress: 0)),
  onProgress: (p) => emit(state.copyWith(progress: p)),
  onPageFinished: (url) async {
    final title = await controller.getTitle();
    emit(state.copyWith(loading: false, currentTitle: title ?? '知识库'));
  },
  onWebResourceError: (err) {
    emit(state.copyWith(error: err.description, loading: false));
    SentryHelper.captureWebViewError(err); // 不含 PII
  },
  onHttpError: (err) {
    if (err.response?.statusCode != null && err.response!.statusCode! >= 400) {
      emit(state.copyWith(error: 'HTTP ${err.response!.statusCode}', loading: false));
    }
  },
  onNavigationRequest: (req) {
    // 限制只允许 hrtyaku.com 子域；外链自动 launchUrl externalApplication
    final uri = Uri.tryParse(req.url);
    if (uri == null) return NavigationDecision.prevent;
    if (uri.host.endsWith('hrtyaku.com')) return NavigationDecision.navigate;
    launchUrl(uri, mode: LaunchMode.externalApplication);
    return NavigationDecision.prevent;
  },
));

// 退屏再清
@override
void dispose() {
  WebViewCookieManager().clearCookies();
  controller.clearCache();
  controller.clearLocalStorage();
  super.dispose();
}
```

---

## 6. Tokens 引用清单

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| AppBar 实底 | `HanaTokens.surfaceContainerHigh(context)` |
| AppBar title / 错误 title / web fallback 文字 | `HanaTokens.ink(context)` |
| Back chevron / open_in_new icon / 错误 subtitle / 加载文字 | `HanaTokens.inkSecondary(context)` |
| Retry 按钮文字 | `HanaTokens.primary(context)` |
| 加载进度条 | `HanaTokens.inkSecondary(context).withOpacity(0.6)` |
| WebView background（外站 DOM 透明区域 fallback）| `HanaTokens.background(context)` |

### 间距
| 用途 | Token |
|------|-------|
| 错误态内 padding | `spacing.lg` = 32 |
| 错误态 title → subtitle | `spacing.sm` = 8 |
| 错误态 subtitle → retry | `spacing.lg` = 32 |
| Web fallback 文字垂直居中 | (Center) |
| 加载进度条高度 | 1px（非 token，物理像素） |

### 圆角
| 用途 | Token |
|------|-------|
| Retry button | `radius.button` = 6 |
| WebView 容器 | 0（直角，全屏占满） |

### 字体
| 用途 | Token / 值 |
|------|---|
| AppBar title | `label` 12·16·+0.6 Medium ink |
| 加载文字 | `body-sm` 13·20·0 inkSecondary |
| 错误 title | `title` 18·26·0 Regular ink |
| 错误 subtitle | `body-sm` 13·20·0 inkSecondary |
| 重试按钮文字 | `body` 15·24·0 Medium primary |
| Web fallback 文字 | `display-md` 32·42·-0.3 SemiBold 宋体 ink |

### 动画
| 用途 | Token |
|------|-------|
| 加载进度条 0→60% | linear 800ms |
| 加载进度条 60→100% | ease-out 200ms |
| 进度条 fadeOut | `motion.standard` 240ms |
| 错误态 fadeIn | `motion.standard` 240ms |
| Web fallback 文字淡入 | `motion.deliberate` 600ms easeOut |
| Pull-to-refresh spinner | 系统默认 |

---

## 7. 交互状态

### 默认（首次进入 mobile）
1. 进屏立即显示 HanaLoadingView.block + 进度条 0%
2. WebView 加载触发 onPageStarted → 进度条 0→60% 动画
3. onPageFinished → 进度条 60→100% → 200ms 后 fadeOut → WebView 显示
4. AppBar title 从 "知识库" fadeIn 240ms 切到当前页 H1

### Pull-to-refresh
1. 用户在 WebView 顶部下拉 → HanaPullRefresh spinner 出现
2. 触发 controller.reload() → 同 "默认" 状态机
3. 加载完成 spinner 消失

### Trailing "在浏览器打开"
1. 点击 → `launchUrl(currentUrl, externalApplication)` 打开系统浏览器
2. 不 pop 当前屏（用户可能想回来继续在 app 内浏览）
3. SnackBar 提示 "已在浏览器打开"（仅 200ms 短暂）

### 返回（leading back / Android system back）
1. 检查 `controller.canGoBack()`
2. 若 true → `controller.goBack()`（webview 内导航）
3. 若 false → `context.pop()`（退出整屏）
4. iOS 滑动手势返回也走同逻辑

### 错误态 → 重试
1. onWebResourceError / onHttpError → 切错误态
2. 用户点 "重试" → `controller.reload()` → 回 "默认" 状态机
3. 三连失败后 subtitle 升级 "请检查网络是否可访问 hrtyaku.com。"

### App 进背景（隐私）
1. routeAware 监听 didChangeAppLifecycleState
2. AppLifecycleState.paused → Android: setFlag(FLAG_SECURE)；iOS: 显示 overlay 遮挡 thumbnail
3. resumed → 移除 overlay / 取消 flag

### Web 平台
1. 进屏即显示 Web fallback 屏（month-white + display-md 文字淡入）
2. 1.4s 后触发 launchUrl externalApplication
3. 监听 window visibility hidden → pop
4. 用户从新 tab 切回 → visibility visible → 仍保持文字屏 → 再次切走 → pop

---

## 8. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | WebView 全屏占满，AppBar 56dp |
| 768–1024 (tablet) | 同 mobile（WebView 自适应） |
| ≥ 1024 (web 桌面) | 不存在该屏（kIsWeb 直接 fallback 过渡屏 → launchUrl） |

> Web 平台不嵌入 webview_flutter（DEC-051），桌面 web 用户用 launchUrl 在新 tab 打开。

---

## 9. i18n 注意

| key | en | zh | ja | 最长 |
|-----|----|----|----|------|
| knowledgeBase | Knowledge Base | 知识库 | 知識ベース | en 14 |
| knowledgeLoadingHint | Opening hrtyaku.com… | 正在打开 hrtyaku.com… | hrtyaku.com を開いています… | ja |
| knowledgeWebFallback | Opening hrtyaku.com… | 正在打开 hrtyaku.com… | hrtyaku.com を開いています… | (复用同 key) |
| knowledgeErrorTitle | Couldn't reach hrtyaku. | 无法连接 hrtyaku。 | hrtyaku に接続できませんでした。 | ja |
| knowledgeErrorSubtitle | Check your connection and retry. | 请检查网络后重试。 | 接続を確認して再試行してください。 | ja |
| knowledgeRetry | Retry | 重试 | 再試行 | en |
| knowledgeOpenInBrowser | Open in browser | 在浏览器打开 | ブラウザで開く | en |

**排版兼容规则**：
- AppBar 动态 title 来自外站可能任意长度，强制 `overflow: ellipsis` + 单行
- 错误 subtitle ja 较长，允许 wrap 2 行（line-height 20，spacing.xs 4 行间）
- Web fallback display-md 单行，超 ja "hrtyaku.com を開いています…" 在 360dp 宽度可能溢出 → 允许 wrap 2 行（line-height 42 调到 36）

---

## 10. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — Back/Trailing/Retry 全 ≥ 44dp，Pull 手势区域全屏 |
| Semantics | ✓ — Back "返回，按钮"；Trailing "在浏览器打开，按钮"；进度条 "正在加载，{percent} 完成"；错误 "无法连接 hrtyaku" |
| 焦点顺序 | AppBar back → AppBar title → AppBar trailing → WebView 内（由系统接管） |
| prefers-reduced-motion | ✓ — 进度条改静态 60% bar / fadeIn 跳过 / web fallback 文字立即可见 |
| 对比度 | ✓ — primary on background = 8.7:1 / ink on bg = 14.8:1 / inkSecondary on bg = 5.9:1（AAA / AA） |
| dynamic type | ✓ — 错误态文字支持系统缩放；webview 内 zoom 由系统手势 / 浏览器接管 |
| FLAG_SECURE | ✓ — Android app 进背景时 thumbnail 模糊，避免 "HRT" title 暴露在多任务窗口 |

---

## 11. 自审 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色 ≤ 3 处 | ✓ | 默认态全屏黛蓝 0 处（进度条是 inkSecondary 60%，不算黛蓝）；错误态 1 处（retry 按钮文字）；web fallback 0 处（display-md 是黑墨）。所有状态 ≤ 1 处。 |
| 2. 调和层次胜过投影 | ✓ | 零 BoxShadow / 零 BackdropFilter / 零 border。AppBar 实底；WebView 占满无圆角；进度条 1px 细线靠 inkSecondary 60% 而非黛蓝。 |
| 3. 编辑级不对称 | ⚠ 部分 | AppBar title 居中（HanaTopBar default 是 label-md +0.6，居中是奥付页特例）；错误态居中是 EmptyState 标准；web fallback 居中是扉页前页特例（同 auth-wrapper）。三个居中都是允许例外，不算违规。 |
| 4. 慢节奏与留白 | ✓ | Web fallback 严格执行 0.4s 静默 + 0.6s 淡入 + 0.4s 停留 + auto pop；mobile 加载进度条 800ms+200ms 分两段 ease-out 避免突变。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零彩色装饰。WebView 内容是外站，我们的容器是月白 + 实色顶栏 + 1px 细线 + 黑墨宋体——全部装饰存在于排版而非装饰元素。 |

**遗留风险**：
- WebView 当前页 title 同步可能暴露 "HRT 入门" 等敏感词到 AppBar / 多任务 thumbnail / 锁屏通知（FLAG_SECURE 兜底但需验证 iOS）
- hrtyaku.com 自身的 dark mode 是否支持 `prefers-color-scheme` 待确认；不支持则 dark mode WebView 区呈白底，与月白 AppBar 撞色（可接受但不优雅）
- Pull-to-refresh 与外站 hrtyaku.com 自身的 PWA refresh 行为可能冲突（外站若有 service worker 可能拦截）—— Phase 4 联调验证
- onNavigationRequest 限制 hrtyaku.com 子域可能阻止合法跳转（如外链 GitHub / Twitter 卡片），需联调 hrtyaku 开发者明确白名单
- iOS WebView Cookie 隔离需用 `WKWebView` non-persistent dataStore，flutter `webview_flutter` 默认共享，需在 iOS 配置 `WKWebsiteDataStore.nonPersistent()`——验证 webview_flutter 4.x 是否暴露此 API

---

— 完 —
