# Design Tokens — HanaNote v2 Editorial East Asian

> Generated 2026-04-28 from candidate-A-editorial-east-asian.md
>
> 蒸馏自 candidate-A § 3-6。每个 token 都 light + dark。
> Flutter 实现位置：`lib/app/theme/hana_colors_v2.dart`（待 Phase 5 实现）
> 命名约定：所有 token 通过 **`HanaTokens.<name>(context)`** 单一 API 访问，对齐 audit 报告 §5 P0-1 要求。

---

## 1. 色彩 (Colors)

色彩哲学：**90% 单色 + 10% 一抹强色**。黛蓝是稀缺资源，每屏使用 ≤ 3 处（详见 `principles.md`）。

### 1.1 Light Mode

| Token | Hex | 名称 | 用途 | Flutter 引用 |
|-------|-----|------|------|-------------|
| `background` | `#F4F1EA` | 月白 (Moon Paper) | Scaffold 基底，全屏铺满 | `HanaTokens.background(context)` |
| `surfaceContainerLowest` | `#FBF8F2` | 雪宣 (Snow Xuan) | 最核心内容的"内文页"，比 background 抬起一档 | `HanaTokens.surfaceContainerLowest(context)` |
| `surfaceContainerLow` | `#F4F1EA` | 月白 | 等同 background，作为基线层 | `HanaTokens.surfaceContainerLow(context)` |
| `surfaceContainerHigh` | `#EAE6DD` | 米灰 (Rice Grey) | 次级分组、AppBar backdrop、章节间隔块 | `HanaTokens.surfaceContainerHigh(context)` |
| `surfaceContainerHighest` | `#DCD7CC` | 砚灰 (Inkstone Grey) | 极少用，仅做"分隔块面"，绝不做边框 | `HanaTokens.surfaceContainerHighest(context)` |
| `ink` | `#1C1A18` | 墨色 (Sumi) | 主文本（onSurface），不是纯黑 | `HanaTokens.ink(context)` |
| `inkSecondary` | `#5E5A52` | 淡墨 (Pale Sumi) | 次要文本、caption | `HanaTokens.inkSecondary(context)` |
| `outline` | `#A39E92` | 烟灰 (Smoke Grey) | 仅在表单 focus 状态出现 1px | `HanaTokens.outline(context)` |
| `primary` | `#1F3A5F` | 黛蓝 (Sumi-Ai) | **一抹强色**，CTA / 链接 / 焦点 / 章节段落标记 | `HanaTokens.primary(context)` |
| `onPrimary` | `#FBF8F2` | 雪宣 | primary 上的文字（不用纯白，保持纸感） | `HanaTokens.onPrimary(context)` |
| `accentMuted` | `#E5E9EE` | 远黛 (Distant Indigo) | 黛蓝在 8% 透明度的等效不透明色，头像背景 / 已读态 | `HanaTokens.accentMuted(context)` |
| `error` | `#9B2A2A` | 朱砂 (Cinnabar) | 删除 / 警告 — 与黛蓝冷暖对峙的唯一暖色 | `HanaTokens.error(context)` |
| `success` | `#5C6B4F` | 苔色 (Moss) | 成功 / 已服 — 哑光军绿，不亮不饱和 | `HanaTokens.success(context)` |
| `warning` | `#A6814C` | 香灰 (Incense Ash) | 注意 / 跳过 — 哑光金茶 | `HanaTokens.warning(context)` |

> **可访问性**：`ink #1C1A18` on `background #F4F1EA` 对比度 14.8:1 (AAA)。
> **唯一例外**：`outline` 在非 focus 状态下不应出现；如必须用做分隔，用 surface 阶差 4-6 个明度单位替代。

### 1.2 Dark Mode

| Token | Hex | 备注 | Flutter 引用 |
|-------|-----|------|-------------|
| `background` | `#1C1A18` | 暖深棕灰，绝不是 `#000` — 与 Light 的 `ink` 互为镜像 | `HanaTokens.background(context)` |
| `surfaceContainerLowest` | `#252320` | 抬起一档 | `HanaTokens.surfaceContainerLowest(context)` |
| `surfaceContainerLow` | `#1C1A18` | 等同 background | `HanaTokens.surfaceContainerLow(context)` |
| `surfaceContainerHigh` | `#2D2A26` | 章节间隔块 | `HanaTokens.surfaceContainerHigh(context)` |
| `surfaceContainerHighest` | `#363330` | 极少用 | `HanaTokens.surfaceContainerHighest(context)` |
| `ink` | `#E8E4DB` | 月白的暗色镜像 | `HanaTokens.ink(context)` |
| `inkSecondary` | `#A39E92` | 淡墨 dark | `HanaTokens.inkSecondary(context)` |
| `outline` | `#A39E92` | 同 light | `HanaTokens.outline(context)` |
| `primary` | `#7A9CC2` | 黛蓝在暗背景下亮一档，仍是同一色相 | `HanaTokens.primary(context)` |
| `onPrimary` | `#1C1A18` | dark 模式 primary 上用墨色 | `HanaTokens.onPrimary(context)` |
| `accentMuted` | `#2A3340` | 远黛 dark | `HanaTokens.accentMuted(context)` |
| `error` | `#D67878` | 朱砂柔化 | `HanaTokens.error(context)` |
| `success` | `#7E8F70` | 苔色提亮 | `HanaTokens.success(context)` |
| `warning` | `#C5A06A` | 香灰提亮 | `HanaTokens.warning(context)` |

> **可访问性**：`ink #E8E4DB` on `background #1C1A18` 对比度 12.6:1 (AAA)。

---

## 2. 字体 (Typography)

### 2.1 Font Stack（按语言分通道）

| 角色 | 西文 | 中文 (zh) | 日文 (ja) | 等宽 (数字) |
|------|------|----------|----------|------------|
| Display / Headline | **Spectral SemiBold** | **Source Han Serif SC Medium** | **Noto Serif JP Medium** | — |
| Title | Spectral Regular | Source Han Serif SC Regular | Noto Serif JP Regular | — |
| Body | **Inter Regular** | **Source Han Sans SC Regular** | **Noto Sans JP Regular** | — |
| Label / Caption | Inter Medium (tracking +0.6) | Source Han Sans SC Medium (tracking +0.4) | 同 ja Sans Medium | — |
| 数值 / 时间戳 | — | — | — | **JetBrains Mono Light** |

**核心立场**：标题用衬线（宋体/Spectral），正文用人文无衬线（思源黑体 / Inter）。这是与 v1（Plus Jakarta Sans 圆润 + Be Vietnam Pro 中性）的根本分手。

### 2.2 CJK Fallback Chain（candidate-A §4 强制要求）

Flutter 实现需在 `TextStyle.fontFamilyFallback` 显式声明：

```dart
// Locale 'zh'
fontFamily: 'Source Han Serif SC',
fontFamilyFallback: ['PingFang SC', 'Hiragino Sans GB', 'serif'],

// Locale 'ja'
fontFamily: 'Noto Serif JP',
fontFamilyFallback: ['Hiragino Mincho ProN', 'Yu Mincho', 'serif'],

// Locale 'en'
fontFamily: 'Spectral',
fontFamilyFallback: ['Georgia', 'serif'],

// 数字（locale 无关）
fontFamily: 'JetBrains Mono',
fontFamilyFallback: ['SF Mono', 'Consolas', 'monospace'],
```

> Web 端用 `font-display: optional` 异步加载思源宋体，首屏先用系统宋体（Mac: STSong / Win: 宋体 / iOS: 苹方-繁宋）避免闪烁。

### 2.3 Type Ramp

| Token | Size | Line Height | Tracking | 字重 / 字体角色 | 用例 |
|-------|------|-------------|----------|----------------|------|
| `display-xl` | 40 | 52 | -0.5 | SemiBold (Spectral) / Medium (CJK 宋体) | Today 顶部问候、Onboarding 首屏，**一屏只一个** |
| `display` | 32 | 42 | -0.3 | SemiBold / Medium | 章节首页（"血液检测"） |
| `headline` | 24 | 32 | -0.2 | Regular / Regular | 卡片主标题、对话标题 |
| `title` | 18 | 26 | 0 | Regular / Regular | 列表项主行 |
| `body` | 15 | 24 | 0 | Regular (Inter) / Regular (思源黑体) | 正文，所有日记 / 备注 |
| `body-sm` | 13 | 20 | 0 | Regular | 次要描述 |
| `label` | 12 | 16 | **+0.6** | Medium | tag、caption、表单 label — **tracking 强制 +0.6** |
| `mono` | 14 | 20 | 0 | Light (JetBrains Mono) | 数值、剂量、HRT 第 N 天 |

> **CJK 排版细节**：
> - 中日文段落首行 **不缩进**（杂志风）
> - 中文标点用全角，但标题中可选半角避免大空白
> - 中文行高从 1.7 起步（v1 没规定，导致中文段落显得局促）

---

## 3. 间距 (Spacing)

底层 4px 基线，但 v2 **故意跳过 12 和 20**，强制设计师在大尺度上做选择。

| Token | px | 用途 |
|-------|----|------|
| `xs` | 4 | 行内 icon ↔ 文本 |
| `sm` | 8 | 紧密元素之间 |
| `md` | 16 | 段落内、卡片 padding |
| `lg` | 32 | 段落之间、章节起始 |
| `xl` | 64 | 章节之间、Today 顶部留白 |
| `xxl` | 128 | 屏幕首屏到第一个内容块（Onboarding 用） |

**核心规则：相邻两个间距必须跨级**（不允许 16 紧挨 16），强制留白节奏。Flutter 引用：`HanaTokens.spacing.md` (返回 `double 16.0`)。

---

## 4. 圆角 (Radius)

| Token | px | 用途 |
|-------|----|------|
| `r-0` | 0 | 照片满边、章节 hero |
| `r-input` | 2 | 输入框 |
| `r-photo` | 2 | 照片（暗示纸感，绝不软糖） |
| `r-card` | 4 | 卡片 / surfaceContainer / 默认 |
| `r-button` | 6 | 按钮（不再 stadium full 圆角） |
| `r-pill` | 999 | 头像、必须圆形的小图标 |

> **v1 用 16-24px 圆角，v2 全面收紧到 4px 主导**。明确告别"软糖"造型，向"印刷品"靠拢。
> **照片绝不超过 2px 圆角**——杂志里照片要么直角，要么 2px 暗示纸感。

Flutter 引用：`HanaTokens.radius.card` (返回 `BorderRadius.circular(4)`)。

---

## 5. 阴影 (Shadow / Elevation)

**核心原则：v2 几乎不用阴影。** 沿袭 v1 唯一保留的"调和层次胜过投影"原则。下列 token 仅在极特殊情况（FAB / 底部 Sheet）使用。

| Token | 参数 | 用例 |
|-------|------|------|
| `elev-0` | none | **默认**——所有卡片、列表、按钮 |
| `elev-low` | `0 1px 2px rgba(28,26,24,0.04)` | 浮层卡片（极少） |
| `elev-high` | `0 4px 16px rgba(28,26,24,0.06)` | Bottom Sheet 唯一允许 |

> 所有阴影 opacity ≤ 6%，**用 ink 色采样** (`#1C1A18`) 而非纯黑（避免破坏纸感）。
> v1 在 13 个文件里手写 `BackdropFilter blur(12)` 是工程债，v2 全部删除——AppBar 改用 `surfaceContainerHigh` 实底 + 滚动时下方加 1px `outline @ 30%` 细线（且仅这一处允许实线）。

---

## 6. Motion

| Token | duration | curve | 用例 |
|-------|---------|-------|------|
| `motion-instant` | 80ms | `Curves.easeOut` | hover 状态切换 |
| `motion-quick` | 150ms | `Curves.easeOut` | press scale (0.98) 反馈 |
| `motion-standard` | 240ms | `Curves.easeInOut` | bottom sheet / 页面过场 |
| `motion-deliberate` | 600ms | `Curves.easeOut` | "今日已记。" 庆祝淡入 |
| `motion-fade` | 1200ms | `Curves.linear` | 庆祝淡出 |

> **庆祝反馈节奏**（替代 v1 的花瓣粒子）：
> 1. 屏幕静默 0.4s（不立即 dismiss）
> 2. `motion-deliberate` 淡入一行黑墨宋体「今日已记。」
> 3. 停留约 0.4s
> 4. `motion-fade` 淡出
> 总时长 ~2.6s，无声、无粒子、无震动（震动可作为可选项）。**仪式感来自"等待"而不是"爆发"**。

Flutter 引用：`HanaTokens.motion.standard` (返回 `Duration(milliseconds: 240)`)。

---

## 7. 与 Material 3 ColorScheme 的对应

让 Flutter 工程师能直接 hand-roll `ColorScheme(...)`（**不**用 `fromSeed` — 黛蓝是稀缺色，不能让算法泛化派生）。

| M3 Slot | v2 Token | Light Hex | Dark Hex |
|---------|----------|-----------|----------|
| `primary` | `primary` | `#1F3A5F` | `#7A9CC2` |
| `onPrimary` | `onPrimary` | `#FBF8F2` | `#1C1A18` |
| `primaryContainer` | `accentMuted` | `#E5E9EE` | `#2A3340` |
| `onPrimaryContainer` | `primary` | `#1F3A5F` | `#7A9CC2` |
| `secondary` | `inkSecondary` | `#5E5A52` | `#A39E92` |
| `onSecondary` | `background` | `#F4F1EA` | `#1C1A18` |
| `secondaryContainer` | `surfaceContainerHigh` | `#EAE6DD` | `#2D2A26` |
| `onSecondaryContainer` | `ink` | `#1C1A18` | `#E8E4DB` |
| `tertiary` | `warning` | `#A6814C` | `#C5A06A` |
| `onTertiary` | `background` | `#F4F1EA` | `#1C1A18` |
| `error` | `error` | `#9B2A2A` | `#D67878` |
| `onError` | `onPrimary` | `#FBF8F2` | `#1C1A18` |
| `errorContainer` | (派生 error @ 12% on bg) | `#F4DCDC` | `#3A2222` |
| `background` | `background` | `#F4F1EA` | `#1C1A18` |
| `onBackground` | `ink` | `#1C1A18` | `#E8E4DB` |
| `surface` | `background` | `#F4F1EA` | `#1C1A18` |
| `onSurface` | `ink` | `#1C1A18` | `#E8E4DB` |
| `surfaceContainerLowest` | `surfaceContainerLowest` | `#FBF8F2` | `#252320` |
| `surfaceContainerLow` | `surfaceContainerLow` | `#F4F1EA` | `#1C1A18` |
| `surfaceContainer` | `surfaceContainerLow` | `#F4F1EA` | `#1C1A18` |
| `surfaceContainerHigh` | `surfaceContainerHigh` | `#EAE6DD` | `#2D2A26` |
| `surfaceContainerHighest` | `surfaceContainerHighest` | `#DCD7CC` | `#363330` |
| `onSurfaceVariant` | `inkSecondary` | `#5E5A52` | `#A39E92` |
| `outline` | `outline` | `#A39E92` | `#A39E92` |
| `outlineVariant` | (outline @ 30%) | rgba(163,158,146,0.3) | rgba(163,158,146,0.3) |
| `surfaceTint` | `primary` | `#1F3A5F` | `#7A9CC2` |
| `inverseSurface` | `ink` | `#1C1A18` | `#E8E4DB` |
| `inverseOnSurface` | `background` | `#F4F1EA` | `#1C1A18` |
| `inversePrimary` | `primary` (dark) | `#7A9CC2` | `#1F3A5F` |
| `scrim` | `ink @ 32%` | rgba(28,26,24,0.32) | rgba(0,0,0,0.32) |
| `shadow` | `ink` | `#1C1A18` | `#000000` |

> **Audit 报告 §1.1 P0-3 要求**：删除 `surfaceBright` / `surfaceDim` / `surfaceVariant` / 12 个 `*Fixed*` 重复或未使用 token。v2 不再声明这些。
> **success 不进 M3 ColorScheme**——M3 没有 success slot。在 Theme 里挂 extension：`ThemeData.extension<HanaSemanticColors>()!.success`。

---

## 8. 引用方式（Flutter）

### 8.1 单一 API 规范（对齐 audit §2 P0-1）

```dart
// lib/app/theme/hana_tokens_v2.dart
class HanaTokens {
  HanaTokens._();

  // -- Colors --
  static Color primary(BuildContext context) =>
      _isDark(context) ? const Color(0xFF7A9CC2) : const Color(0xFF1F3A5F);

  static Color background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1C1A18) : const Color(0xFFF4F1EA);

  static Color ink(BuildContext context) =>
      _isDark(context) ? const Color(0xFFE8E4DB) : const Color(0xFF1C1A18);

  // ... 其他 token 同上模式 ...

  // -- Spacing (无 context 依赖) --
  static const _Spacing spacing = _Spacing();

  // -- Radius --
  static const _Radius radius = _Radius();

  // -- Motion --
  static const _Motion motion = _Motion();

  static bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
}

class _Spacing {
  const _Spacing();
  final double xs = 4;
  final double sm = 8;
  final double md = 16;
  final double lg = 32;
  final double xl = 64;
  final double xxl = 128;
}
```

### 8.2 严禁的旧 API（v1 残留）

旧代码 `hana_colors.dart` 同时存在三套 API：
- `HanaColors.primary` (静态常量，永远是 light 值)
- `HanaColors.primaryOf(context)` (context-aware)
- `Theme.of(context).colorScheme.primary` (M3 标准)

**v2 仅保留 `HanaTokens.primary(context)` 单轨**。新代码 ban 掉前两种用法（`flutter analyze` 加 lint 规则）。Audit §5 P0-1 已列为最高优先级。

### 8.3 ThemeExtension 挂语义色

```dart
@immutable
class HanaSemanticColors extends ThemeExtension<HanaSemanticColors> {
  final Color success;
  final Color warning;
  final Color accentMuted;
  // ... copyWith / lerp ...
}

// 使用：
final success = Theme.of(context).extension<HanaSemanticColors>()!.success;
// 或封装为：HanaTokens.success(context)
```

---

## 9. 删除清单（v1 → v2 迁移）

按 audit §1 + §5 P0/P1 结论，v2 直接删除：

| 类别 | 删除项 | 原因 |
|------|--------|------|
| 重复 surface | `surfaceBright`, `surfaceDim`, `surfaceVariant` | 与 background / containerHighest 重复 |
| Dead M3 fixed | `primaryFixed*` / `secondaryFixed*` / `tertiaryFixed*` (12 个) | 0 引用 |
| Outlier | `statusGreen #34D399` | 非 palette 家族成员，被 `success #5C6B4F` 取代 |
| Dead gradient | `primaryGradient`, `countdownGradient*`, `takeDoseButtonGradient*` | candidate-A 明确禁止渐变 |
| Dead shadow | `cardShadow`, `navBarShadow` | v2 elev-0 默认，不用阴影 |
| BackdropFilter | 13 处 hand-rolled blur | v2 用实色 surfaceContainerHigh + 1px outline 替代 |
| `AppThemeType` enum | 5 个虚构主题（lavender/sky/starryNight/cyberpunk）| audit §2-8 已揭穿"全部 return Sakura"——v2 仅 `{light, dark}` |

---

— 完 —
