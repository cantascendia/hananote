# 核心设计系统指南：内刊 (HanaNote v2)

## 1. 创意北极星：一本你愿意每天翻一页的私人健康内刊

HanaNote v2 不是健康 app，是一份**沉静的私人内刊**。江户蓝染的克制 × 京都写经纸的留白 × 新潮文库的杂志衬线节奏，三者构成基底。

我们彻底告别 v1 花笺的「樱色温柔守护者」叙事——粉色、樱花、渐变光晕、花瓣粒子全部出局。**我们放弃 16-20 岁子市场，赌成人位**：22-35 岁、读独立书店选物店、想要"健康记录但不想感觉自己是个病人"的成熟用户。这是赛道里 TRACE / Clue / Trans Memo **没有人占领过的位置**——杂志感的健康记录。

设计哲学一句话：**少 = 贵，留白 = 重量，克制 = 重审美。**

---

## 2. 色彩系统

**色彩哲学：90% 单色 + 10% 一抹强色。** 让强色稀缺到每出现一次都像句号。

### 核心调色板（Light Mode / Dark Mode）

| 角色 | Light | Dark | 灵感 |
|---|---|---|---|
| `background` 月白 | `#F4F1EA` | `#1C1A18` | 京都写经纸 / 暖深棕灰，绝不是 #000 |
| `surfaceContainerLowest` 雪宣 | `#FBF8F2` | `#252320` | 抬起最核心内容 |
| `surfaceContainerHigh` 米灰 | `#EAE6DD` | `#2D2A26` | AppBar / 次级分组 |
| `surfaceContainerHighest` 砚灰 | `#DCD7CC` | `#363330` | 极少用，分隔块面 |
| `ink` 墨色（onSurface） | `#1C1A18` | `#E8E4DB` | 新潮文库标题墨 |
| `inkSecondary` 淡墨 | `#5E5A52` | `#A39E92` | caption 灰阶 |
| `outline` 烟灰 | `#A39E92` | `#A39E92` | 仅 form focus 1px |
| **`accent` 黛蓝（primary）** | **`#1F3A5F`** | **`#7A9CC2`** | **江户蓝染，唯一一抹强色** |
| `onAccent` | `#FBF8F2` | `#1C1A18` | 不用纯白 |
| `accentMuted` 远黛 | `#E5E9EE` | — | 黛蓝 8% 等效色 |
| `error` 朱砂 | `#9B2A2A` | `#D67878` | 唯一暖色，仅删除 / 警告 |
| `success` 苔色 | `#5C6B4F` | — | 哑光军绿，不亮不饱和 |
| `warning` 香灰 | `#A6814C` | — | 哑光金茶 |

可访问性：Light `ink` on `background` 14.8:1（AAA）；Dark 12.6:1（AAA）。

### 设计准则
- **无线条原则**（保留 v1）：严禁 1px 实线分割，靠 surface 色阶差 4-6 明度单位定义边界。唯一例外：滚动时 AppBar 下方 1px `outline @ 30%`。
- **一抹强色原则**：单色基底 + 黛蓝点睛，强色稀缺即句号。
- **严禁纯黑 #000 / 纯白 #FFF**（保留 v1）。
- **严禁粉色 / 樱色 / 樱花 / 二次元装饰**（v2 新禁忌）。

---

## 3. 字体系统

| 角色 | 西文 | 中文 | 日文 |
|---|---|---|---|
| Display / Title | **Spectral SemiBold** | **思源宋体 Medium** | **Noto Serif JP Medium** |
| Body | **Inter Regular** | **思源黑体 Regular** | **Noto Sans JP Regular** |
| Label / Caption | Inter Medium（tracking +60） | 思源黑体 Medium（tracking +40） | 同 |
| 数值（剂量 / HRT 第 N 天 / 时间戳） | **JetBrains Mono Light** | — | — |

全部 SIL OFL / Apache 2.0 开源免费，APK 增 5-8MB（CJK 子集化），Web 端 Google Fonts CDN。

### Type Ramp
| Token | Size / Line / Tracking | 用途 |
|---|---|---|
| `display-xl` | 40 / 52 / -0.5 | Today 顶部、Onboarding 大标题（一屏一个） |
| `display` | 32 / 42 / -0.3 | 章节首页 |
| `headline` | 24 / 32 / -0.2 | 卡片主标题 |
| `title` | 18 / 26 / 0 | 列表项主行 |
| `body` | 15 / 24 / 0 | 正文，行高 CJK 1.7 起 |
| `body-sm` | 13 / 20 / 0 | 次要描述 |
| `label` | 12 / 16 / +0.6 | tag、表单 label（**必须 +0.6 tracking**） |
| `mono` | 14 / 20 / 0 | 数值、剂量 |

### CJK Fallback Chain（v1 缺失，v2 必须）
- 中文：`Source Han Serif SC` → `STSong`（macOS）→ `宋体`（Windows）→ `serif`
- 中文 Sans：`Source Han Sans SC` → `PingFang SC`（Apple）→ `Microsoft YaHei`（Windows）→ `sans-serif`
- 日文：`Noto Serif JP` → `Hiragino Mincho ProN`（Apple）→ `Yu Mincho`（Windows）→ `serif`
- Web：`font-display: optional` 系统宋体打底，二屏切思源宋体，首屏 0 闪烁。

### CJK 排版细节
- 段落首行**不缩进**（杂志风）。
- 中文标点用全角，标题中可半角避免大空白。

---

## 4. 深度与层次

**只靠"纸的厚度"，不靠投影 / 边框 / 渐变 / blur。**

- **调和层次胜过投影**（保留 v1）：5 级 surface 色阶（Lowest #FBF8F2 / Low #F4F1EA / High #EAE6DD / Highest #DCD7CC）模拟纸张堆叠。
- **以"段落"为视觉单位**（v2 新原则）：一个 surfaceContainerLowest 里放标题 + 3 段文本 + 1 张图，不再切 3 张小卡。从"卡片堆叠"转向"杂志版面"。
- **绝不投影**（保留 v1）。
- **AppBar 不用 BackdropFilter blur**（v1 13 处工程债清算）：实色 surfaceContainerHigh + 滚动时下方 1px `outline @ 30%` 细线。
- **照片圆角 ≤ 2px**：要么直角，要么圆 2px 暗示纸感。**绝不 16px 软糖角**。

### 圆角策略（明确告别 v1 的 16-24px）
- 卡片 / surfaceContainer：**4px**
- 输入框：**2px**
- 按钮：**6px**（不再 stadium full）
- 头像 / 圆形小图标：圆形（保留）
- 照片：**0-2px**
- Bottom Sheet：**16px**（仅此一处保留大圆角，符合握持感）

### 间距网格（4px 基线，跳过 12 / 20）
| Token | Value | 场景 |
|---|---|---|
| xs / sm / md / lg / xl / xxl | 4 / 8 / 16 / 32 / 64 / 128 | 行内 / 紧密 / 段落内 / 段落间 / 章节间 / Onboarding 首屏 |

**规则**：相邻间距必须跨级（不许 16 紧挨 16），强制留白节奏。

### 不对称呼吸感
- 顶部 hero 标题左对齐 24px，右侧给 96px+ 留白（不居中）。
- 章节标题左侧加 4px 黛蓝竖线，长度只覆盖标题首行（"段落标记"，非分隔符）。
- 一屏一个视觉重心，允许偏左 30% 或偏右 30%，**绝不居中**。

---

## 5. 组件原则

### 卡片
4px 圆角、surfaceContainer 堆叠、点击 `Scale to 0.98` 触感反馈。**段落视觉单位**——内部元素 16px，段落间 32px，无分割线。

### 按钮
- **Primary**：黛蓝 #1F3A5F 实色填充、6px 圆角、文字 #FBF8F2（不用纯白）。
- **Secondary**：月白底 + 黛蓝 1px 边框（这是允许实线的极少例外）。
- **触控目标 ≥ 44dp**（a11y）。

### 输入字段
无外框，底部 1px 烟灰线 / focus 时 2px 黛蓝呼吸线（保留 v1 概念）+ 月白底色。圆角 2px。

### Bottom Sheet（替代 Dialog）
保留 v1 的「禁标准 iOS 弹窗」原则。圆角 16px（手账握持感的唯一大圆角例外）。

### 庆祝反馈（明确告别 v1 花瓣粒子）
点击「记一次」后屏幕静默 0.4s，淡入一行宋体「**今日已记。**」黑墨居中，1.2s 淡出。**无粒子、无渐变、无声、震动可选**。仪式感来自"等待"，不是"爆发"。

---

## 6. 文案调性

**克制、第三人称编辑视角、句号收尾、零 emoji**。从 v1 的"哄"转向 v2 的"敬"。温度藏在文案颗粒度里，不靠装饰。

| 场景 | v1 → v2 |
|---|---|
| 服药 CTA | `服药 💊` → `记一次` |
| 通知 | `该吃药啦 💊` → `{drug}　{dose}{unit}　到时间了。`（全角空格 + 句号收尾） |
| 删除确认 | `确定删除？此操作不可撤销。` → `删除后不可恢复。\n仍要继续？` |
| 庆祝 | （花瓣粒子） → `今日已记。` |
| 每日 quote | `你的每一次坚持，都会悄悄开花。` → `今日宜，按时。`（黄历体三五字） |

---

## 7. Do's and Don'ts

### 推荐
- **编辑级排版**：标题敢偏左偏右，章节首竖线段落标记。
- **数据用等宽字体**：仅限剂量 / HRT 第 N 天 / 时间戳，避免与正文 Spectral 冲突。
- **一抹强色不滥用**：黛蓝出现一次像一个句号。
- **a11y 对比度 WCAG AA**，触控目标 ≥ 44dp，文案温度藏在颗粒度里。
- **服药状态用褪色不打勾**：未服 = 黛蓝竖线 + 黑墨；已服 = 淡墨竖线 + 淡墨（褪色是日记语言，勾是工具语言）。

### 严禁
- **粉色 / 樱色 / 樱花 / 二次元** 任何元素。
- **圆角 > 8px**（除 Bottom Sheet 16px、头像圆形）。
- **渐变背景**（除非极微弱编辑性装饰）。
- **任何投影 / BackdropFilter blur**。
- **iOS 标准弹窗**（用 Bottom Sheet）。
- **装饰性 emoji**（💊✅🌸 等全部出局；状态符号如 ⚠ 极少数允许，不滥用）。
- **纯黑 #000 / 纯白 #FFF**。
- **居中对称的英雄标题、列表分割线、卡片软糖角**。

---

**设计总监评语：**
*v2 是 HanaNote 在赛道上最难复制、最贴近"陪你十年"愿景的方向。它不哄你，它敬你。当 v1 用花瓣说"你做到了"，v2 让屏幕静下来一秒，用一行黑墨宋体写「今日已记。」——后者更有重量。推荐力度 **8.5 / 10**：扣的 1.5 分留给冷漠感的持续校准与 v1 工程债的硬重写。*
