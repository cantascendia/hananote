# Legal 屏开发 handoff

> Generated 2026-04-29 from `docs/design/screens/legal/spec.md`
> 工程目标：`lib/features/settings/presentation/pages/legal_page.dart`
> 配对 spec：`docs/design/screens/legal/spec.md`
> 配对 critique：`docs/design/screens/legal/critique-v1.md`

---

## 1. 改动总览（What changes）

把 v1 单段 Text + 玻璃顶栏的 97 行重写为 **三类 tab + markdown 渲染 + 联系底栏** 的 colophon 风格内文页。**this is a rewrite, not a refactor**——v1 已无法承载新增的 licenses 类与 markdown 章节渲染。

**删除**：
- `BackdropFilter blur` AppBar（DESIGN §4 工程债 #1，13 处之一）
- `Plus Jakarta Sans` 字体硬编码（DESIGN §3 工程债，4 处之一）
- `LegalPageType.fromString` 默认 fallback 到 privacy（改抛 ArgumentError + 路由层 404）
- 单段 Text 渲染整篇内容（改 flutter_markdown）

**新增**：
- `LegalPageType.licenses` 枚举值
- 三类 tab 切换 UI（HanaButton.secondary toggle）
- markdown asset 加载逻辑（`assets/legal/{type}.{locale}.md`）
- 许可证子屏 `LicenseDetailPage`（基于 `LicenseRegistry`）
- 联系底栏 + mailto: 链接
- 加载 / 错误 / 重试三态

---

## 2. 关键依赖（Components needed）

### 已有 v2 components
- `HanaTopBar.default`（components/top-bar.md）
- `HanaButton.secondary` + `HanaButton.text`（components/button.md）
- `HanaEmptyState.page`（components/empty-state.md）
- `HanaLoadingView.block`（components/loading.md）
- `HanaListItem.withSubtitle` + `HanaListItem.default`（spec 已抢跑使用，Phase 4 落地）
- `HanaSectionHeader`（许可证字母分组）

### 新增 / 待引入
- **`flutter_markdown`** package — 已在生态熟知，加 pubspec dependency `flutter_markdown: ^0.7.x`（**注意**：避开 0.8.x 后版本因 API breaking change）
- **`url_launcher`** — 已在 pubspec（knowledge_webview_page 使用），复用
- **`HanaTabBar`** (待补 v1.1 spec) — 三按钮 toggle 组件，临时用 `Row<HanaButton.secondary>` inline 实现，Phase 4 抽出

### Markdown asset 文件
新增 6 个 markdown 资源：
```
assets/legal/privacy.en.md
assets/legal/privacy.zh.md
assets/legal/privacy.ja.md
assets/legal/terms.en.md
assets/legal/terms.zh.md
assets/legal/terms.ja.md
```
在 `pubspec.yaml` 加：
```yaml
flutter:
  assets:
    - assets/legal/
```
内容由法务 + ux-copy 维护者协作产出，本屏 PR 仅占位"待补"+ retry 兜底。

---

## 3. 视觉契约（不可妥协项）

| 项 | 值 / Token |
|---|---|
| Scaffold bg | `HanaTokens.background(context)` |
| AppBar bg | `HanaTokens.surfaceContainerHigh(context)`（**禁** BackdropFilter） |
| AppBar title | "隐私 · 条款 · 许可"（label-md +0.6 ink） |
| AppBar leading | back chevron, color=`inkSecondary` size 20（**禁** primary） |
| AppBar elevation | 0；滚动后下方 0.5px outline @ 30% |
| 屏幕水平 padding | `spacing.lg` = 32（**禁** 24） |
| Tab 按钮 | `HanaButton.secondary`，active 下方 2px 黛蓝下划线 |
| Tab 行 → 时间戳 | `spacing.sm` = 8 |
| 时间戳 | mono 13/20 inkSecondary，右对齐 |
| Markdown body 行高 | **1.75（zh / en）/ 1.80（ja）**——locale 派生 |
| Markdown 段间距 | `spacing.md` = 16（pPadding bottom） |
| H2 上方 | `spacing.lg` = 32 |
| 链接颜色 | `HanaTokens.primary(context)` + decoration: underline + 1px |
| 行内代码 | mono 14/20 inkSecondary on `surfaceContainerHigh`（dark 切 `surfaceContainerHighest`） |
| Markdown → 联系底栏 | `spacing.xl` = 64 |
| 联系底栏 | body-sm 13/20 inkSecondary + 邮箱 黛蓝 underline |
| 屏底留白 | `spacing.xl` = 64 |

---

## 4. 数据契约

**沿用现有**：路由参数 `:type` 仍为 `privacy` / `terms` / `licenses`，但默认 fallback 行为变更。

**新增枚举**：
```dart
enum LegalPageType {
  privacy,
  terms,
  licenses;

  static LegalPageType? tryFromString(String value) => switch (value) {
    'privacy' => privacy,
    'terms' => terms,
    'licenses' => licenses,
    _ => null,
  };
}
```
路由层捕获 null 并跳 404 / settings。

**Markdown 加载（无需 Bloc，直接 FutureBuilder）**：
```dart
Future<String> loadLegalMarkdown(LegalPageType type, Locale locale) async {
  final lang = locale.languageCode; // 'zh' / 'en' / 'ja'
  final path = 'assets/legal/${type.name}.$lang.md';
  try {
    return await rootBundle.loadString(path);
  } catch (_) {
    // fallback en
    return await rootBundle.loadString('assets/legal/${type.name}.en.md');
  }
}
```

**许可证流（licenses 类）**：
```dart
Stream<LicenseEntry> licenseStream() => LicenseRegistry.licenses;
// 按 packages 字段聚合，去重
```

**新增 ARB keys**（lib/core/l10n/arb/app_{en,zh,ja}.arb 三语同步）：
- `legalTitle` = "隐私 · 条款 · 许可" / "Privacy · Terms · Licenses" / "プライバシー · 利用規約 · ライセンス"
- `legalTabPrivacy` / `legalTabTerms` / `legalTabLicenses`
- `legalLastUpdated(String date)` = "上次更新于 {date}" / "Last updated {date}" / "最終更新 {date}"
- `legalContactPrompt` = "如有疑问，请发邮件至" / "Questions? Email" / "ご質問は"
- `legalContactEmail` = "hello@hrtyaku.com"（不在 ARB 翻译，但作 key 方便后期切换）
- `legalLoadFailed` = "暂时无法读取该文档。" / "Couldn't load this document." / "この書類を読み込めませんでした。"
- `legalRetry` = "重试" / "Retry" / "再試行"
- `licensesIntro` = "本应用使用以下开源软件，特此致谢。" / ...
- `licensesEmpty` = "暂无许可证信息。"

**删除 ARB keys**：
- `privacyPolicyContent` / `termsOfUseContent`（巨型字符串，迁出到 markdown asset）

---

## 5. 路由契约

- `/legal/privacy` / `/legal/terms` / `/legal/licenses` 三路由共享 `LegalPage(type: ...)`
- 非法 `:type` 参数 → 路由层重定向到 `/settings`，附 SnackBar "无效的法律页类型"
- `/legal/licenses/:packageName` → `LicenseDetailPage`（许可证子屏，全屏 markdown）
- 子屏返回 → pop 回许可页，**保留主屏 active tab + 滚动位置**（用 `AutomaticKeepAliveClientMixin`）

---

## 6. P0 工程债清单（必须随本屏一并解决）

1. **删除 BackdropFilter blur**（DESIGN §4 / tokens §5）— 13 处工程债之一，本屏切 `HanaTopBar` 实底。
2. **删除 PlusJakartaSans 字体硬编码**（DESIGN §3）— 1 处。
3. **删除 ARB 巨型 content key**（i18n 维护性）— `privacyPolicyContent` / `termsOfUseContent` 共 ~6000 字符迁到 markdown asset。
4. **修复 fromString fallback 反模式** — 非法路由参数静默重定向到 privacy 是 UX bug，改抛 + 404。
5. **补全 licenses 类**（功能缺失）— v1.2.0 已在产却无应用内入口。

---

## 7. 测试清单（QA）

| 测试 | 期望 |
|------|------|
| 首屏渲染（privacy）| AppBar 实色无 blur，三 tab 显示，"隐私" tab active 下划线，markdown 加载 fadeIn |
| 一抹强色审计 | 静态截图全屏黛蓝出现 ≤ 3 处（active tab 下划线 + 内文链接 ≤ 1-2 + 联系邮箱）|
| Tab 切换 | 点击 "条款" → 下划线 240ms 平移 + markdown 区 cross-fade，滚动位置归零 |
| 链接点击（mailto:）| `url_launcher.launchUrl(externalApplication)` 触发，Android 打开默认邮件 client |
| 链接点击（https:）| 打开系统浏览器，无内嵌 webview |
| 加载失败 | 模拟 asset 缺失 → `HanaEmptyState.page` "暂时无法读取该文档。" + 重试按钮 |
| 重试 | 点击 "重试" → 重新加载，成功后 fadeIn |
| 非法路由参数 | 访问 `/legal/foo` → 重定向到 `/settings` + SnackBar |
| 许可证列表 | `/legal/licenses` → 30+ 包字母序排列，首字母 SectionHeader 分组 |
| 许可证详情 | 点击包名 → push `LicenseDetailPage`，全屏 markdown 渲染许可证全文 |
| 许可证返回 | 子屏 back → 回主屏，active tab=licenses，滚动位置保留 |
| i18n 三语 | ja "プライバシー · 利用規約 · ライセンス" 标题 22 字两行 wrap 不溢出 |
| CJK 行高 | zh body 1.75 / ja body 1.80，连读 3 屏不疲劳（人工感受验收） |
| 暗模式 | inline code 底色切 `surfaceContainerHighest`（dark 下 `surfaceContainerHigh` 与 bg 仅 1 单位差） |
| reduced-motion | tab 切换瞬时 / fadeIn 跳过 / 下划线瞬移 |
| 触控目标 | tab 按钮 ≥ 44dp / 链接行 ≥ 44dp |
| Semantics | tab "已选中" 朗读，链接 "电子邮箱链接" 朗读 |

---

## 8. 实施顺序建议（PR 拆分）

1. **PR-1（本屏主体）**：`legal_page.dart` 重写 + 新 ARB keys + markdown asset 占位 + `LicenseDetailPage` 新建 + `flutter_markdown` 依赖加入 + 路由层 fallback 修复
2. **PR-2（依赖组件）**：`HanaTabBar` 抽取到 `lib/core/widgets/`（Phase 4 合流）
3. **PR-3（内容填充）**：法务 + ux-copy 维护者补 6 个 markdown asset 真实内容（不在本屏 PR 范围）

> **不在本屏 PR 范围**：
> - 隐私政策 / 服务条款的法务文本撰写（PR-3）
> - 桌面 ≥ 1024 TOC sidebar（P2，留 Phase 5）
> - 许可证内容的法律审核（应用商店上架前由法务一次审核）

---

## 9. 已知风险与边界

- **风险 1：markdown asset 加载失败的 UX 兜底** — asset 缺失 / 损坏时的 fallback 链：当前 locale → en → 显示 EmptyState。en asset 是最后兜底，**必须随包打包**。pubspec 配置错误会让全语言 fallback 到 EmptyState。CI 应加 asset 存在性检查。
- **风险 2：flutter_markdown 版本兼容** — 0.8.x 之后 API 改动 + Flutter 3.38 锁版可能不兼容最新 plugin，建议锁 `^0.7.6` 或迁到更稳定的 `markdown_widget`（评估留 Phase 4）。
- **风险 3：许可证流性能** — `LicenseRegistry.licenses` 是 lazy stream，30+ 包首次解析 200-400ms，移动端 6+ 年老设备可能 600ms+。`HanaLoadingView.block` 兜底必须出现。
- **风险 4：mailto: 在某些设备无 default client** — Android 7- / 部分定制 ROM 可能没有默认邮件 app。`url_launcher.canLaunchUrl` 预检失败时 fallback 到 SnackBar "请手动复制邮箱地址" + Clipboard 写入。
- **风险 5：法律文本更新流程** — 隐私政策 / 服务条款变更时如何通知用户（强制弹框？SnackBar？仅更新时间戳？）—— 留 Phase 4 由 product+legal 决策，本屏仅显示"上次更新于 {date}"。

— 完 —
