# Responsive — HanaNote v2 Editorial East Asian

> Generated 2026-04-28 from candidate-A-editorial-east-asian.md
>
> 三个断点 + 三种栅格策略。Type ramp 跨断点不变，间距与列宽随断点放大。
> Flutter 实现：`HanaBreakpoints.of(context)` 返回 `mobile | tablet | web` 枚举。

---

## 1. 断点 (Breakpoints)

| 断点 | 宽度范围 | 主要场景 | 栅格 |
|------|---------|---------|------|
| `mobile` | `< 768` | Android 手机、Web 移动浏览器 | 单列 |
| `tablet` | `768 – 1023` | iPad、Android 平板、Web 中等窗口 | 双列（master-detail） |
| `web` | `≥ 1024` | 桌面浏览器（Web 是 Production 平台） | 三列编辑式 |

> **不用 480 / 960 / 1200 这些 Material default 断点**——v2 的断点对齐杂志阅读经验：768 是杂志双页跨页的临界点，1024 是大开本三栏阅读的临界点。

Flutter 引用：

```dart
enum HanaBreakpoint { mobile, tablet, web }

extension HanaBreakpointX on BuildContext {
  HanaBreakpoint get breakpoint {
    final w = MediaQuery.of(this).size.width;
    if (w >= 1024) return HanaBreakpoint.web;
    if (w >= 768) return HanaBreakpoint.tablet;
    return HanaBreakpoint.mobile;
  }
}
```

---

## 2. 列宽与内容最大宽度

| 断点 | 屏幕边距 | 内容栏数 | 单栏最大宽 | 阅读宽度上限 |
|------|---------|---------|-----------|------------|
| `mobile` | `lg` (32px) | 1 | `screenWidth - 64` | 全屏宽 |
| `tablet` | `xl` (64px) | 2（master 320px + detail 弹性）| detail ≤ 600 | 600 |
| `web` | `xxl` (128px) | 3（章节 nav 240 + 内文 720 + 余白）| **内文恒定 720** | **720** |

### 2.1 Web 端的特殊处理：阅读宽度限定 720px

**核心规则**：Web 端正文阅读宽度永远 ≤ 720px（像 Notion 文档限宽、像 Medium 文章限宽）。

理由：
- 长行（每行 > 80 字符）破坏阅读节奏
- 杂志栏宽传统：单栏 65-75 字符是黄金阅读宽度
- HanaNote 是"健康内刊"——内刊不靠铺满屏幕显得"专业"

实现：

```dart
// Web 三列布局
Row(
  children: [
    SizedBox(width: 240, child: ChapterNav()),       // 左：章节目录
    SizedBox(
      width: 720,                                     // 中：阅读栏，恒定 720
      child: ArticleContent(),
    ),
    Expanded(child: SizedBox.shrink()),              // 右：留白（≥ 余下空间）
  ],
)
```

> **不用 `Expanded` 让内文吃满**。余白是 v2 的内容，不是 bug。

### 2.2 Mobile 单列

- 屏幕边距 = `lg` (32px) 左右各
- 列宽 = `screenWidth - 64`
- 顶部 hero 留白 = `xl` (64px)
- Onboarding 首屏到首个内容块 = `xxl` (128px)

### 2.3 Tablet 双列（Master-Detail）

仅在以下页面启用 master-detail：
- Timeline → 左侧月视图，右侧当日详情
- Knowledge / Journal → 左侧文章列表，右侧正文
- Settings → 左侧分类，右侧详情

不启用的页面（Today / Onboarding）退化为 mobile 单列居中（最大宽 600）。

---

## 3. Type Ramp 跨断点策略

**核心立场：v2 的 type ramp 不随断点变化**。Display-xl 在 mobile 是 40px，在 web 也是 40px。

理由：
- 字号变化打破"杂志感"——杂志在不同尺寸的设备上字号是定的
- Mobile 上 40px 已经够大；Web 上 40px 不显小，因为内文宽度限定 720（参见 §2.1）
- 减少跨设备 QA 成本（一套 type ramp 走天下）

**唯一例外**：`mono` 数字在 web 端可放大到 16px（默认 14px）以提升数据可视化的可读性，仅限 BloodTest 趋势图、Measurement 大屏看板这两个场景。

---

## 4. 间距随断点放大

虽然 type ramp 固定，但 **间距 token 在不同断点取不同值**：

| 间距 | mobile | tablet | web |
|------|--------|--------|-----|
| 屏幕边距 | `lg` (32) | `xl` (64) | `xxl` (128) |
| 段落间距 | `lg` (32) | `lg` (32) | `xl` (64) |
| 章节间距 | `xl` (64) | `xl` (64) | `xxl` (128) |
| 卡片 padding | `md` (16) | `md` (16) | `lg` (32) |

Flutter 引用：

```dart
double screenMargin(BuildContext c) {
  switch (c.breakpoint) {
    case HanaBreakpoint.mobile: return HanaTokens.spacing.lg;   // 32
    case HanaBreakpoint.tablet: return HanaTokens.spacing.xl;   // 64
    case HanaBreakpoint.web:    return HanaTokens.spacing.xxl;  // 128
  }
}
```

---

## 5. 图片与照片的响应式策略

| 断点 | 照片最大宽 | 圆角 | 排版 |
|------|----------|------|------|
| mobile | `screenWidth - 64` | `r-photo` (2) 或 `r-0` | 单列流式 |
| tablet | 600 | `r-photo` (2) | 双列 grid |
| web | **720**（与正文同宽）| `r-0` | 满栏 hero / 文中嵌入 |

> **照片在 web 端用 `r-0` 直角**——杂志大开本里照片直角更显高级。Mobile 上 2px 圆角暗示纸感。

---

## 6. 平台特殊性（Web 端）

CLAUDE.md 已声明 Web 端缺失能力，v2 设计上需要响应：

| 能力 | Web 端策略 |
|------|----------|
| 生物识别 | 仅 PIN 入口，不显示 Face ID / 指纹按钮 |
| `file_picker` | 用 `<input type="file">` 等效，但 UI 保持 v2 一致（黛蓝按钮 + 6px 圆角） |
| `webview_flutter` | 用 `url_launcher` 在新标签打开，配上 v2 的「外链」label tracking +0.6 |
| CJK 字体 | `font-display: optional` + 系统宋体 fallback（避免 FOIT） |

---

## 7. 验证清单

设计稿提交前自查：

- [ ] mobile 设计稿宽度为 375 或 390（iPhone 标准）
- [ ] tablet 设计稿宽度为 834（iPad）或 768
- [ ] web 设计稿宽度为 1280 或 1440，但**正文栏宽度恒为 720**
- [ ] type ramp 在三个断点完全一致（除 mono 在 web 可放大）
- [ ] 屏幕边距按断点放大（32 → 64 → 128）
- [ ] web 端右侧有显著留白（不被 Expanded 吃满）
- [ ] 照片在 web 端用直角

---

— 完 —
