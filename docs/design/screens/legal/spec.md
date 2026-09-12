# Legal 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/
> 屏幕：`lib/features/settings/presentation/pages/legal_page.dart`
> 阶段：Phase 3.x 新稿（spec）+ critique-v2 配套
> 配对 handoff：`docs/design/screens/legal/handoff.md`
> 配对 critique：`docs/design/screens/legal/critique-v1.md`

---

## 1. 设计意图

Legal 是这本私人内刊的**奥付页 / 版权页**——读者偶尔翻到的"出版方信息、读者权利、第三方致谢"。三类文档（隐私政策 / 服务条款 / 第三方许可）共用一屏，用顶部 tab 切换；内文用宋体长文阅读姿态，零 bento、零彩色 icon、零磨砂玻璃。月白底 + 实色顶栏 + 三 tab + 滚动 markdown + 底部"联系我们"——像翻新潮文库末页的版权 / 致谢 / 索引。

v1 vs v2 核心差异：v1 是"法务文本墙"（单段 Text + 玻璃顶栏 + 24px padding），v2 是"奥付页"（章节化 markdown + 实色顶栏 + 32px padding + 1.75 行高 + 底部联系入口 + 三类 tab 互跳）。

跨性别敏感性：内文不预设性别表达；"您 / 用户"中性；不强调"HRT / 跨性别"等可在窥屏时暴露身份的关键词；提及健康数据时使用"用户主动填写的健康记录"宽泛措辞。

---

## 2. 屏幕骨架（ASCII Wireframe）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色，无 blur
│  ←  隐私 · 条款 · 许可                       │     leading=back chevron(inkSecondary)
│                                             │     title=label-md +0.6 ink
├─────────────────────────────────────────────┤
│   (顶部留白 spacing.md = 16)                │
│                                             │
│  ╭ 隐私 ╮  条款   许可                      │  ← Tab 行：HanaButton.secondary toggle 风
│  ╰━━━━╯                                     │     active 下方 2px 黛蓝下划线
│                                             │     spacing.sm = 8 间距
│   (上次更新于 2026-04-15)                   │  ← mono 13/20 inkSecondary 右对齐
│                                             │
│   (spacing.lg = 32)                         │
│                                             │
│   ╔═══════════════════════════════════╗     │
│   ║ # 我们收集什么                     ║     │  ← H2 headline 24/32 ink 宋体
│   ║                                   ║     │     段落上 spacing.lg
│   ║ HanaNote 是一本只在你设备上书写的   ║     │  ← body 15/26 ink 宋体（行高 1.75）
│   ║ 私人内刊。我们不收集、不上传、不    ║     │     段间 spacing.md = 16
│   ║ 分析任何用户主动填写的健康记录…     ║     │
│   ║                                   ║     │
│   ║ ## 本机存储                        ║     │  ← H3 title 18/26 ink Medium 宋体
│   ║                                   ║     │
│   ║ 你填写的所有内容（用药、检查、日记） ║     │
│   ║ 都加密保存在本机数据库 (`sqlcipher`)│     │  ← inline code mono 14 inkSecondary
│   ║ 中。密钥由设备 KeyManager 派生…     ║     │
│   ║                                   ║     │
│   ║ ## 你的权利                        ║     │
│   ║                                   ║     │
│   ║ 你可以随时：                       ║     │
│   ║   · 导出全部数据为加密备份          ║     │  ← bullet list, marker=· dot
│   ║   · 永久清除所有数据               ║     │
│   ║   · 联系开发者 [hello@hrtyaku.com] │     │  ← link 黛蓝下划线 mailto:
│   ║   · 浏览开源代码于 [github.com/…]  │     │  ← link 黛蓝下划线 https
│   ║                                   ║     │
│   ╚═══════════════════════════════════╝     │
│                                             │
│   (spacing.xl = 64)                         │
│                                             │
│   ────────────────────                      │  ← 极弱分隔：surfaceContainerHigh 1px
│                                             │     宽度 = padding 内（不到边）
│   如有疑问，请发邮件至                      │  ← body-sm 13/20 inkSecondary
│   hello@hrtyaku.com。                       │     邮箱黛蓝下划线 mailto:
│                                             │
│   (底部 spacing.xl = 64)                    │
└─────────────────────────────────────────────┘
```

**空态 / 错误态 / 加载态**：
- 加载 → `HanaLoadingView.block`（markdown asset 加载中）
- 错误 → `HanaEmptyState.page` "暂时无法读取该文档。" + `HanaButton.text "重试"`（黛蓝文字按钮）
- 空（理论不存在，markdown asset 必随包打包）→ 同错误态文案"该文档为空。"

---

## 3. 三类 tab 结构

| Tab | type 路由参数 | 标题 (zh) | 标题 (en) | 标题 (ja) | Markdown 资源 |
|---|---|---|---|---|---|
| 1 | `privacy` | 隐私 | Privacy | プライバシー | `assets/legal/privacy.{locale}.md` |
| 2 | `terms` | 条款 | Terms | 利用規約 | `assets/legal/terms.{locale}.md` |
| 3 | `licenses` | 许可 | Licenses | ライセンス | 运行时生成（见 §6） |

**路由**：`/legal/:type` 接受 `privacy` / `terms` / `licenses` 三值；非法值跳 404 而非静默 fallback。Tab 切换不重新路由（`type` 是初始 tab，切换后用 setState）——避免每次切换都触发 navigator history 污染。

---

## 4. 组件映射

| 区域 | v2 组件 | Variant | 关键 props / 备注 |
|------|--------|---------|---------|
| 顶部栏 | `HanaTopBar` | default | title="隐私 · 条款 · 许可"（label-md +0.6 ink），leading=back chevron(inkSecondary) |
| Tab 行 | `HanaButton.secondary` (toggle) | secondary | 三个并排按钮，active 下方 2px 黛蓝下划线 + label ink；inactive 无下划线 + label inkSecondary |
| 更新时间戳 | (Text 直接) | mono 13/20 | "上次更新于 {date}" inkSecondary，右对齐 |
| Markdown 渲染 | `flutter_markdown` (MarkdownBody) | 自定义 styleSheet | 见 §5 styleSheet |
| 链接行为 | `url_launcher` | externalApplication | mailto: / https:// 一律 externalApplication 模式 |
| 加载态 | `HanaLoadingView` | block | 居中 + body-sm "正在打开文档…" |
| 错误态 | `HanaEmptyState` | page | title + retry 按钮 |
| 重试按钮 | `HanaButton` | text | 黛蓝文字，无背景，44dp 高 |
| 联系底栏 | (Text + GestureDetector) | body-sm | 邮箱内联黛蓝下划线 mailto: |
| 弱分隔线 | (Container) | — | 1px high · color=surfaceContainerHigh · margin horiz=padding 内 |

---

## 5. Markdown StyleSheet（与 tokens 对齐）

```dart
MarkdownStyleSheet(
  // 段落 body
  p: HanaTokens.textTheme.body.copyWith(
    color: HanaTokens.ink(context),
    height: locale.isJa ? 1.80 : 1.75, // CJK 强制 ≥ 1.75
  ),
  pPadding: EdgeInsets.only(bottom: HanaTokens.spacing.md), // 段间 16

  // H1 仅文档顶部使用（隐私政策 / 服务条款 / 第三方许可）
  h1: HanaTokens.textTheme.displayMd.copyWith(color: HanaTokens.ink(context)),
  h1Padding: EdgeInsets.only(top: HanaTokens.spacing.xl, bottom: HanaTokens.spacing.lg),

  // H2 章节标题（"我们收集什么 / 我们如何使用…"）
  h2: HanaTokens.textTheme.headline.copyWith(
    color: HanaTokens.ink(context),
    fontWeight: FontWeight.w500, // 宋体 Medium
  ),
  h2Padding: EdgeInsets.only(top: HanaTokens.spacing.lg, bottom: HanaTokens.spacing.md),

  // H3 子节
  h3: HanaTokens.textTheme.title.copyWith(
    color: HanaTokens.ink(context),
    fontWeight: FontWeight.w500,
  ),
  h3Padding: EdgeInsets.only(top: HanaTokens.spacing.md, bottom: HanaTokens.spacing.sm),

  // 链接：黛蓝 + 下划线
  a: TextStyle(
    color: HanaTokens.primary(context),
    decoration: TextDecoration.underline,
    decorationColor: HanaTokens.primary(context),
    decorationThickness: 1.0,
  ),

  // 行内代码
  code: TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 14,
    height: 20 / 14,
    color: HanaTokens.inkSecondary(context),
    backgroundColor: HanaTokens.surfaceContainerHigh(context),
  ),

  // 列表项
  listBullet: HanaTokens.textTheme.body.copyWith(color: HanaTokens.inkSecondary(context)),
  listIndent: HanaTokens.spacing.md, // 16

  // blockquote（许可证全文用）
  blockquote: HanaTokens.textTheme.bodySmall.copyWith(color: HanaTokens.inkSecondary(context)),
  blockquoteDecoration: BoxDecoration(
    border: Border(left: BorderSide(color: HanaTokens.outline(context), width: 2)),
  ),
  blockquotePadding: EdgeInsets.only(left: HanaTokens.spacing.md),
)
```

> **关键**：行高从 1.6（西文）→ 1.75（zh）→ 1.80（ja）三档调整，由 locale 派生，不是固定值。

---

## 6. 第三方许可（Licenses）页特殊处理

许可页**不**走 markdown asset 加载，而是基于 Flutter 内置 `LicenseRegistry.licenses` 流构建：

- 顶部一段 markdown："本应用使用以下开源软件，特此致谢。"（ARB key `licensesIntro`）
- 主体：纵向 `HanaListItem.withSubtitle` 列表，每项：
  - title = 包名（body 15 ink）
  - subtitle = 版本号 + 许可证类型，如 "0.10.13 · MIT"（mono 13/20 inkSecondary）
  - trailing = chevron 16 inkSecondary
  - onTap → push `/legal/licenses/{packageName}` 全屏 markdown 显示该包许可证全文
- 列表按包名字母序排列，章节首字母用 `HanaSectionHeader` "A / B / C…" 分组（label-md +0.6 inkSecondary + 4px 黛蓝竖线）

**许可证详情子屏**：HanaTopBar leading=back / title=`包名` (label-md) / 内文 = 该许可证全文 markdown，渲染规则同主屏 §5。

---

## 7. Tokens 引用清单

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| AppBar 实底 | `HanaTokens.surfaceContainerHigh(context)` |
| 章节标题 / 内文 / H2 H3 | `HanaTokens.ink(context)` |
| 副标题 / 时间戳 / inline code 文字 / 联系底栏 | `HanaTokens.inkSecondary(context)` |
| Tab active 下划线 / 内文超链接 / 邮箱链接 | `HanaTokens.primary(context)` |
| 弱分隔线 | `HanaTokens.surfaceContainerHigh(context)` |
| inline code 底色 | `HanaTokens.surfaceContainerHigh(context)` |
| blockquote 左竖线 | `HanaTokens.outline(context)` |

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `spacing.lg` = 32 |
| 顶部 tab 行上方 | `spacing.md` = 16 |
| Tab 行 → 时间戳 | `spacing.sm` = 8 |
| 时间戳 → markdown 顶部 | `spacing.lg` = 32 |
| H2 上方 | `spacing.lg` = 32 |
| 段落下方 | `spacing.md` = 16 |
| Markdown → 联系底栏 | `spacing.xl` = 64 |
| 屏底 | `spacing.xl` = 64 |

### 圆角
| 用途 | Token |
|------|-------|
| Tab 按钮 | `radius.button` = 6 |
| inline code 底色块 | `radius.input` = 2 |
| HanaListItem（licenses）| `radius.card` = 4（容器）|

### 字体
| 用途 | Token / 值 |
|------|---|
| Tab label | `body` 15·24·0 Medium |
| 时间戳 | `mono` 14·20·0 → 实际渲 13/20 inkSecondary |
| H1（文档大标题，可选不显示）| `display-md` 32·42·-0.3 SemiBold 宋体 |
| H2（章节标题）| `headline` 24·32·-0.2 Medium 宋体 |
| H3（子节）| `title` 18·26·0 Medium 宋体 |
| body 段落 | `body` 15·24·0 Regular **height 1.75 / ja 1.80** |
| 行内代码 | `mono` 14·20·0 Light JetBrains Mono |
| 联系底栏 | `body-sm` 13·20·0 Regular inkSecondary |

### 动画
| 用途 | Token |
|------|-------|
| Tab 切换 markdown 区 cross-fade | `motion.standard` 240ms easeInOut |
| Tab 下划线 active 移动 | `motion.standard` 240ms easeInOut |
| 链接 tap 高亮 | `motion.quick` 150ms easeOut |

---

## 8. 交互状态

### 默认（首次进入）
- 顶栏滚动到顶部时无下边线；滚动后 0.5px outline @ 30% 出现
- 三 tab 中 `type` 路由参数对应的 tab 为 active
- markdown 加载完成后 `motion-standard` 240ms fadeIn

### Tab 切换
1. 点击非 active tab → tab 下划线 240ms 平移
2. markdown 区 240ms cross-fade（旧文档 fadeOut 同时新文档 fadeIn）
3. 滚动位置重置到顶部
4. 不触发路由变更（仅 setState 切换 type）

### 链接点击
- mailto: → `url_launcher.launchUrl(mode: externalApplication)` → 打开系统邮件 client
- https:// → 同上 → 打开系统浏览器
- tap 反馈：链接文字短暂 inkSecondary（150ms）后恢复 primary

### 加载失败
- markdown asset 抛 Exception → `HanaEmptyState.page` "暂时无法读取该文档。"
- "重试" 按钮 → 重新加载 asset
- 三连失败后 subtitle 提示 "请检查应用安装是否完整。"

### 许可证子屏
- 列表项 tap → push `/legal/licenses/:packageName`
- 子屏 leading back → pop 回许可页（保留滚动位置 + active tab 状态）

---

## 9. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，水平 padding 32，markdown 占满 |
| 768–1024 (tablet) | 内文页 max-width 720px 居中，padding 仍 32 |
| ≥ 1024 (web 桌面) | 三列：左 240 sidebar（H2 章节锚点 TOC：可选 P2）/ 中 720 主体 / 右 240 留白 |

**TOC 锚点**（P2，桌面 ≥ 1024 才显示）：解析 markdown H2 列表，左侧固定 sidebar 显示锚点链接，点击平滑滚动到对应章节。锚点 active 时左侧 4px 黛蓝竖线（章节段落标记语法）。

---

## 10. i18n 注意

| key | en | zh | ja | 最长 |
|-----|----|----|----|------|
| legalTitle | Privacy · Terms · Licenses | 隐私 · 条款 · 许可 | プライバシー · 利用規約 · ライセンス | **ja 22 字** |
| legalTabPrivacy | Privacy | 隐私 | プライバシー | ja 7 |
| legalTabTerms | Terms | 条款 | 利用規約 | ja 4 |
| legalTabLicenses | Licenses | 许可 | ライセンス | ja 5 |
| legalLastUpdated | Last updated {date} | 上次更新于 {date} | 最終更新 {date} | en |
| legalContactPrompt | Questions? Email | 如有疑问，请发邮件至 | ご質問は | zh |
| legalLoadFailed | Couldn't load this document. | 暂时无法读取该文档。 | この書類を読み込めませんでした。 | ja |
| legalRetry | Retry | 重试 | 再試行 | en |

**排版兼容规则**：
- ja AppBar title 22 字超 360dp 宽，**HanaTopBar 自动两行 wrap**（line-height label 16，title slot 高度 ≥ 32px）
- Tab 按钮三排并排在 ja locale 下可能溢出 → 360dp 宽下改 horizontal scroll；≥ 480dp 三排平铺
- 邮箱 / URL 链接在 mono 字体下不换行，溢出靠 `softWrap: true` + `overflow: visible`

---

## 11. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — Tab 按钮 44dp / 链接行 ≥ 44dp / 重试 44dp |
| Semantics | ✓ — Tab "隐私选项卡，3 项中的第 1 项，已选中"；链接 "电子邮箱链接 hello@hrtyaku.com，双击打开邮件" |
| 焦点顺序 | AppBar back → Tab1 → Tab2 → Tab3 → markdown 内联链接（按文档顺序）→ 联系底栏邮箱 |
| prefers-reduced-motion | ✓ — Tab 切换 fadeIn 跳过；下划线移动改瞬时 |
| 对比度 | ✓ — primary `#1F3A5F` on background `#F4F1EA` = 8.7:1 (AAA)；ink on background = 14.8:1 (AAA) |
| dynamic type | ✓ — 所有字号支持系统字号缩放；markdown body 15 缩放后行高按比例缩放 |
| 屏幕阅读器朗读 | ✓ — H2/H3 朗读为"标题级别 2 / 3"；列表项朗读"项目，1 / 4 中的第 1 个" |

---

## 12. 自审 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色 ≤ 3 处 | ✓ | ① Tab active 下划线 ② 内文超链接（按文档不同 1-3 个）③ 联系底栏邮箱链接。返回箭头是 inkSecondary 不算黛蓝。许可证子屏因无内文链接，黛蓝仅 1 处（active tab 也不存在）。 |
| 2. 调和层次胜过投影 | ✓ | 零 BoxShadow / 零 BackdropFilter / 零 border。AppBar 靠 surfaceContainerHigh 与 background 6 个明度差。inline code 底色 surfaceContainerHigh 同样不用边框。 |
| 3. 编辑级不对称 | ✓ | markdown 内文左对齐 32px / 右侧 70% 留白；联系底栏左对齐而非居中。HanaTopBar title 是允许居中的"奥付页页眉"特例。Tab 行是横向布局，但 active 下划线只覆盖文字宽度（不全行通底），保持不对称感。 |
| 4. 慢节奏与留白 | ✓ | 顶部 16 → tab 8 → 时间戳 32 → markdown 顶部 32（H1 上）/ 16（H2 段间）/ md→联系 64 → 屏底 64。无 16 紧挨 16。CJK 行高 1.75-1.80 强制呼吸感。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零彩色装饰。装饰存在于宋体起笔、链接下划线 1px 笔触、章节段落标记。tab 切换 cross-fade 而非滑入，避免动画喧宾夺主。 |

**遗留风险**：
- markdown asset 三语 × 三类 = 9 个文件需法务审核 + 译者维护，更新流程需建立（Phase 4 文档说明）
- 许可证页性能：30+ 包列表 + LicenseRegistry stream 解析，首次进入耗时可能 200-400ms，需 `HanaLoadingView.block` 兜底
- 桌面 web ≥ 1024 的 TOC sidebar 留 P2 验证，初版可不实现
- 暗模式下 inline code 底色 `surfaceContainerHigh` (#2D2A26) on body bg (#1C1A18) 仅 2 个明度差，可能视觉不明显——dark 下需切 `surfaceContainerHighest` (#363330) 或加 1px outline @ 20%

---

— 完 —
