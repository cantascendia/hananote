# Knowledge WebView 屏开发 handoff

> Generated 2026-04-29 from `docs/design/screens/knowledge-webview/spec.md`
> 工程目标：`lib/features/knowledge/presentation/pages/knowledge_webview_page.dart`
> 配对 spec：`docs/design/screens/knowledge-webview/spec.md`
> 配对 critique：`docs/design/screens/knowledge-webview/critique-v1.md`

---

## 1. 改动总览（What changes）

把 v1 的"磨砂玻璃顶栏 + 全屏 WebView + 中央旋转圆环 + 静态标题"重写为 **实色顶栏 + 动态 title + 进度条 + 错误态 + Pull-to-refresh + cookie 隔离 + web 端体面过渡**。**this is a rewrite, not a refactor**——StatefulWidget 内部结构与状态机大幅扩展（v1 仅 2 个 NavigationDelegate 回调，v2 需要 5 个 + 错误处理 + 生命周期监听）。

**删除**：
- `BackdropFilter blur` AppBar（DESIGN §4 工程债 #1，13 处之一）
- `Plus Jakarta Sans` 字体硬编码（DESIGN §3 工程债，2 处）
- `CircularProgressIndicator` 中央圆环（principles §1 / §5 工程债）
- v1 web 平台 `addPostFrameCallback → launchUrl → context.pop()` 同帧三连（改 1.4s 仪式过渡）
- `Icons.refresh` trailing action（改 Pull-to-refresh 手势）
- `IconButton(Icons.arrow_back, color: primary)` （改 inkSecondary chevron）

**新增**：
- 动态当前页 title sync（`controller.getTitle()` 每次 onPageFinished）
- 加载进度条（1px inkSecondary @ 60%）
- HanaEmptyState.page 错误态 + retry
- HanaPullRefresh 包裹 WebView
- `WebViewCookieManager().clearCookies()` 进/退屏强制清理
- onNavigationRequest 域名白名单（仅 hrtyaku.com）
- onWebResourceError + onHttpError 回调
- canGoBack 优先逻辑（webview 内导航 vs 整屏 pop）
- routeAware + AppLifecycleState 监听 + FLAG_SECURE（Android）/ overlay（iOS）
- Trailing "在浏览器打开" icon button（open_in_new）
- 子 cubit `KnowledgeWebViewCubit`（管理 loading / progress / error / currentTitle 状态）

---

## 2. 关键依赖（Components needed）

### 已有 v2 components
- `HanaTopBar.default`（components/top-bar.md）
- `HanaButton.text`（components/button.md）
- `HanaEmptyState.page`（components/empty-state.md）
- `HanaLoadingView.block`（components/loading.md）
- `HanaPullRefresh`（components/pull-refresh.md）
- `HanaSnackbar.show`

### 现有 package（pubspec 已在）
- `webview_flutter: ^4.x`
- `url_launcher: ^6.x`
- `go_router`
- `flutter_bloc` + `injectable`

### 新增 package（建议）
- `webview_cookie_manager: ^2.x`（cookie 清理；webview_flutter 自带 API 不够细致）
- 若 sentry 已启用（DEC R52-B）→ 复用 `SentryHelper.captureWebViewError`

---

## 3. 视觉契约（不可妥协项）

| 项 | 值 / Token |
|---|---|
| Scaffold bg | `HanaTokens.background(context)` |
| AppBar bg | `HanaTokens.surfaceContainerHigh(context)`（**禁** BackdropFilter） |
| AppBar title | 动态当前页 H1 / fallback "知识库"（label-md +0.6 ink） |
| AppBar leading | back chevron, color=`inkSecondary` size 20（**禁** primary） |
| AppBar trailing | `Icons.open_in_new` (outlined), color=`inkSecondary` size 20 |
| AppBar elevation | 0；滚动后下方 0.5px outline @ 30% |
| 加载进度条 | 1px 高 · color=`inkSecondary @ 60%` · 0-100% 平移（**禁** primary 黛蓝） |
| 加载文字 | "正在打开 hrtyaku.com…" body-sm 13/20 inkSecondary（**禁** CircularProgressIndicator） |
| 错误 title | "无法连接 hrtyaku。" title 18/26 ink |
| 错误 subtitle | "请检查网络后重试。" body-sm 13/20 inkSecondary |
| 重试按钮 | HanaButton.text 黛蓝文字 44dp 高 |
| Web fallback bg | `HanaTokens.background(context)` 月白纯色 |
| Web fallback 文字 | "正在打开 hrtyaku.com…" display-md 32/42 黑墨宋体居中 |
| Web fallback 节奏 | 0.4s 静默 + 0.6s 淡入 + 0.4s 停留 + auto pop（与 auth-wrapper 同语法） |

---

## 4. 数据契约（Cubit）

新增 `KnowledgeWebViewCubit` + `KnowledgeWebViewState`：

```dart
@freezed
class KnowledgeWebViewState with _$KnowledgeWebViewState {
  const factory KnowledgeWebViewState({
    @Default(true) bool loading,
    @Default(0) int progress, // 0-100
    String? error,
    @Default('知识库') String currentTitle, // 动态同步
    String? currentUrl,
  }) = _KnowledgeWebViewState;
}

@injectable
class KnowledgeWebViewCubit extends Cubit<KnowledgeWebViewState> {
  KnowledgeWebViewCubit() : super(const KnowledgeWebViewState());

  void onPageStarted() => emit(state.copyWith(loading: true, progress: 0, error: null));
  void onProgress(int p) => emit(state.copyWith(progress: p));
  Future<void> onPageFinished(WebViewController c, String url) async {
    final title = await c.getTitle();
    emit(state.copyWith(
      loading: false,
      progress: 100,
      currentTitle: title?.isNotEmpty == true ? title! : '知识库',
      currentUrl: url,
    ));
  }
  void onError(String description) => emit(state.copyWith(loading: false, error: description));
  void clearError() => emit(state.copyWith(error: null, loading: true));
}
```

**新增 ARB keys**（lib/core/l10n/arb/app_{en,zh,ja}.arb 三语同步）：
- `knowledgeBase`（已存在，复用）
- `knowledgeLoadingHint` = "正在打开 hrtyaku.com…" / "Opening hrtyaku.com…" / "hrtyaku.com を開いています…"
- `knowledgeErrorTitle` = "无法连接 hrtyaku。" / "Couldn't reach hrtyaku." / "hrtyaku に接続できませんでした。"
- `knowledgeErrorSubtitle` = "请检查网络后重试。" / "Check your connection and retry." / "接続を確認して再試行してください。"
- `knowledgeRetry` = "重试" / "Retry" / "再試行"
- `knowledgeOpenInBrowser` = "在浏览器打开" / "Open in browser" / "ブラウザで開く"
- `knowledgeOpenedInBrowser` = "已在浏览器打开" / "Opened in browser" / "ブラウザで開きました"

---

## 5. 路由契约

- `/knowledge-base` 路由 → `KnowledgeWebViewPage`
- AppBar leading back 优先 `controller.canGoBack()` → goBack；否则 `context.pop()`
- Android system back 同上逻辑（`PopScope` / `WillPopScope`）
- iOS edge swipe back 同上
- Trailing "在浏览器打开" → `launchUrl(currentUrl, externalApplication)`，**不** pop 当前屏

---

## 6. P0 工程债清单（必须随本屏一并解决）

1. **删除 BackdropFilter blur**（DESIGN §4 / tokens §5）— 13 处工程债之一，本屏切 `HanaTopBar` 实底。
2. **删除 PlusJakartaSans 字体硬编码**（DESIGN §3）— 2 处。
3. **删除 CircularProgressIndicator**（principles §1 / §5）— v2 严禁的 SDK 默认装饰。
4. **修复 Cookie 隔离**（跨性别隐私 P0）— 进/退屏强制清理，配置 incognito。
5. **补全错误态**（功能缺失）— 网络断 / DNS 失败时 v1 永远 loading，必修。
6. **修复 web 平台过渡突兀**（DEC-051 实施不全）— 加 1.4s 仪式而非立即 pop。

---

## 7. 测试清单（QA）

| 测试 | 期望 |
|------|------|
| 首屏渲染（mobile）| AppBar 实色无 blur，loading.block + 进度条显示，无 CircularProgressIndicator |
| 一抹强色审计 | 静态截图全屏黛蓝出现 ≤ 1 处（仅错误态 retry 按钮，默认/加载/正常态 0 处）|
| 加载进度条 | 0→60% 800ms linear → 60→100% 200ms ease-out → 200ms 后 fadeOut |
| 加载完成 | WebView 显示 + AppBar title 240ms fadeIn 切到当前页 H1 |
| Pull-to-refresh | WebView 顶部下拉 → spinner → controller.reload() → 同首屏 loading |
| Trailing 在浏览器打开 | 点击 → 系统浏览器开新 tab + SnackBar "已在浏览器打开"（200ms）+ 不 pop |
| 错误态（网络断） | 飞行模式打开屏 → 1-3s 后 HanaEmptyState.page "无法连接 hrtyaku。" + retry |
| 错误态 retry | 点 retry → 切回 loading → 加载成功 → 正常态 |
| 错误态三连失败 | subtitle 升级 "请检查网络是否可访问 hrtyaku.com。" |
| onNavigationRequest 白名单 | webview 内点击外链（如 GitHub 卡片）→ launchUrl externalApplication，不在 webview 内打开 |
| canGoBack 逻辑 | 从 hrtyaku 首页点入子页 → leading back → goBack 回首页（不 pop 整屏）|
| canGoBack=false → pop | hrtyaku 首页 → leading back → pop 整屏 |
| Android system back | 同 leading back 逻辑 |
| Cookie 隔离 | 进屏前 / 退屏后 用 adb 验证 webview cookie store 为空 |
| FLAG_SECURE | app 进背景 → 多任务 thumbnail 模糊，看不到 "HRT" title |
| iOS overlay | app 进背景 → 屏幕被月白 overlay 遮挡 |
| Web 平台 fallback | kIsWeb 进屏 → 0.4s 月白静默 → "正在打开 hrtyaku.com…" 淡入 → 1.4s 后 launchUrl + visibility hidden 后 pop |
| Web 平台返回 app | 用户切回 app → 文字仍在 → 再次切走 → pop（visibility 二次 hidden 触发） |
| i18n 三语 | ja "hrtyaku に接続できませんでした。" 错误 title 不溢出（24 字单行 / 必要时 wrap）|
| reduced-motion | 进度条改静态 60% / fadeIn 跳过 / web fallback 文字立即可见 |
| 暗模式 | hrtyaku.com 若支持 prefers-color-scheme dark 则 webview 自动跟随；否则容器与 webview 撞色（已知风险） |
| 触控目标 | back/trailing/retry 全 ≥ 44dp |
| Semantics | back/trailing 朗读正确；进度条朗读 "正在加载，{percent}%"；错误态朗读 title + subtitle + retry |

---

## 8. 实施顺序建议（PR 拆分）

1. **PR-1（本屏主体）**：`knowledge_webview_page.dart` 重写 + `KnowledgeWebViewCubit` + `KnowledgeWebViewState` + 新 ARB keys + cookie 隔离 + 错误态 + 进度条 + Pull-to-refresh + canGoBack 逻辑 + FLAG_SECURE + Web fallback 仪式过渡
2. **PR-2（依赖）**：`webview_cookie_manager` 加入 pubspec + Sentry capture helper 扩展
3. **PR-3（联调验证）**：与 hrtyaku.com 维护者确认外链白名单 / dark mode 支持 / PWA refresh 是否冲突 — 不在本屏 PR 范围

> **不在本屏 PR 范围**：
> - hrtyaku.com 站点本身的 dark mode 支持（外站职责）
> - 桌面 web ≥ 1024 的不同 UI（直接 fallback 到 launchUrl，无 webview）
> - 离线缓存 hrtyaku 部分章节（P3 长远方向，需 service worker 配合）

---

## 9. 已知风险与边界

- **风险 1：iOS WebView Cookie 隔离 API 验证** — `webview_flutter` 4.x 在 iOS 是否暴露 `WKWebsiteDataStore.nonPersistent()` 配置需验证；不暴露则需 native 层补 platform channel。
- **风险 2：FLAG_SECURE 与截图禁用副作用** — Android 设置 FLAG_SECURE 会让用户**无法截图本屏**；这是隐私必需但用户可能希望截图保存某段知识——需在用户帮助文档说明。iOS overlay 不影响截图（用户截图时 overlay 已移除）。
- **风险 3：动态 title 同步 vs FLAG_SECURE 时序** — onPageFinished 同步 title 后立即进入 background 时，多任务 thumbnail 已快照，FLAG_SECURE 来不及生效。需在 routeAware 的 didChangeAppLifecycleState `inactive` 阶段就开始 set flag，而非 paused。
- **风险 4：onNavigationRequest 白名单粒度** — 当前限制 `*.hrtyaku.com`，但 hrtyaku 内可能内嵌 youtube / vimeo iframe（视频教程）—— iframe 是否被 onNavigationRequest 拦截需验证 webview_flutter 行为。若拦截，需扩展白名单或允许 iframe 内任意。
- **风险 5：Pull-to-refresh 与 PWA service worker 冲突** — 若 hrtyaku.com 启用 service worker 拦截 reload 请求，Pull-to-refresh 可能不生效。需联调验证。
- **风险 6：Web 平台 visibility 检测兼容性** — `document.visibilityState` 在 Safari 14- 行为不一致；fallback 到 `window.onblur` 监听。Flutter Web 的 dart:html 桥接需验证。

— 完 —
