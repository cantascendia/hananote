> Archived 2026-04-28 as part of R52 redesign. Replaced by DESIGN.md (Editorial East Asian direction). See docs/design/design-language-v2/candidate-A-editorial-east-asian.md for the full v2 brief.

# 核心设计系统指南：花笺 (HanaNote)

## 1. 创意北极星：数码纸笺 (The Digital Stationery)
本设计系统的核心理念是“数码纸笺”。我们不只是在做一个工具化的用药追踪器，而是在为用户营造一个充满安全感、温润如玉的私人健康日记空间。

为了打破传统医疗App的冷冰冰和“模板感”，我们追求**非对称的呼吸感**与**触感化堆叠**。通过大面积的留白、如和纸般细腻的色彩分层，以及动漫美学中常见的柔光滤镜感，让每一次打开应用都像是在精美的花笺上落笔。

---

## 2. 色彩系统 (Color Palette)

色彩是情感的载体。本系统严禁使用纯黑 (#000000) 或纯白 (#FFFFFF)。

### 核心调色板
- **Primary (樱色 #864E5A / #FFB7C5):** 代表温柔的力量。用于核心交互和品牌识别。
- **Secondary (薰衣草 #745475 / #FCD3FB):** 用于辅助功能，营造宁静、放松的氛围。
- **Tertiary (珊瑚 #AC332A / #FFB9B0):** 仅用于生理提醒或健康警告，确保警示感的同时不失温度。
- **Neutral (奶油白 #FFF8F1):** 模拟高级信纸的底色，作为全局背景。

### 设计准则
- **“无线条”原则 (The No-Line Rule):** 严禁使用 1px 的实线进行区域分割。所有的边界必须通过背景色块的微调 (例如 `surface-container-low` 叠放在 `surface` 之上) 或微妙的色调过渡来定义。
- **玻璃感与渐变 (Glass & Gradient):** 重要行动按钮 (CTA) 或卡片应使用从 `primary` 到 `primary-container` 的微弱线性渐变（135度角），增加视觉的“灵魂”与液态美感。
- **表面层级 (Surface Hierarchy):** 利用 `surface-container` 的五个等级（Lowest 至 Highest）模拟纸张堆叠。越核心的内容，其容器色调应越接近 `lowest` (纯净感)；背景则使用 `dim` 或 `low`。

---

## 3. 字体系统 (Typography)

我们选用了 **Plus Jakarta Sans** 处理数字与英文字符，其现代且圆润的曲线与中文字体 **Be Vietnam Pro** (或系统默认的苹方-简) 完美契合，传递出一种亲切且专业的编辑感。

- **Display (大标题):** 用于打招呼或心情总结。使用 `display-md`，强调非对称排版，通过极大的字号对比建立视觉焦点。
- **Headline (页标题):** `headline-sm`，确保用户在弱光或服药后的模糊状态下也能清晰识别当前页面。
- **Body (正文):** `body-lg` 用于记录药物名称，确保中文的可读性与呼吸感。
- **Label (标签):** `label-md` 处理次要信息（如：已服用时间），字间距适当放宽。

---

## 4. 深度与高度 (Elevation & Depth)

我们拒绝传统的投影效果，转而使用**调和层次 (Tonal Layering)**。

- **分层原则:** 深度通过“堆叠”实现。例如：在一个 `surface-container-low` 的列表背景上，放置 `surface-container-lowest` 的卡片，通过明度差异产生自然的浮动感，而非依赖阴影。
- **环境阴影 (Ambient Shadows):** 若必须使用投影（如浮动按钮），阴影必须极度弥散。
  - *属性:* Blur: 24px, Opacity: 4%-8%, Color: 带有主题色的 `on-surface` 采样，模仿柔和的自然光。
- **雾面玻璃 (Glassmorphism):** 顶部导航栏和底部 Dock 应使用 `surface` 色值辅以 80% 不透明度及 `backdrop-blur(12px)`，让下方内容若隐若现地透出，增加层次深度。
- **幽灵边框 (Ghost Border):** 若因无障碍需求必须强调边界，请使用 `outline-variant` 令牌，并将其不透明度降至 15%。禁止出现 100% 不透明的边框。

---

## 5. 组件设计 (Components)

### 卡片 (Cards)
- **规则:** 统一使用 `1rem (16px)` 圆角。禁止使用分割线。
- **间距:** 内部元素使用 `spacing.4 (1.4rem)`，外部留白使用 `spacing.6 (2rem)`。
- **交互:** 点击时伴随轻微的比例缩放 (Scale down to 0.98)，增强触感反馈。

### 按钮 (Buttons)
- **Primary:** 使用樱色渐变，圆角为 `full`。文字颜色为 `on-primary`。
- **Secondary:** 无填充，仅使用 `surface-container-high` 背景，适合低优先级操作。

### 输入字段 (Input Fields)
- 放弃传统的框式输入。采用底层色块式布局，辅以底部 `primary` 色的 2px 呼吸线条（仅在聚焦时出现）。

### 专属组件：药丸胶囊 (Med-Capsule)
- 专门设计的进度组件，用于显示服药周期。使用非对称的椭圆造型，结合 `tertiary-container` 色彩，弱化“吃药”的医疗压力，使其看起来更像是一种生活仪式。

---

## 6. Do's and Don'ts (准则)

### ✅ 推荐做法 (Do's)
- **情感排版:** 允许标题文字适度偏左或偏右，打破对称的沉闷感。
- **微交互:** 在勾选“已服药”时，加入如花瓣散落般的轻微粒子特效。
- **无障碍:** 虽然追求浅淡色调，但核心操作文字必须满足 WCAG 2.1 的对比度要求。

### ❌ 严禁做法 (Don'ts)
- **禁止硬分割:** 绝对不要在列表项之间使用水平分割线。请通过间距 (`spacing.3`) 或交替背景色来区分。
- **禁止高饱和度:** 避免使用纯度过高的色彩，所有的颜色应像是在奶油中调和过一般。
- **禁止标准弹窗:** iOS 标准弹窗过于生硬。请使用半屏浮层 (Bottom Sheets) 并带有大圆角设计，以符合“手账”的握持感。

---

**设计总监评语：**
*“花笺”不仅是一个追踪器，它是一个温柔的守护者。请记住，在处理健康数据时，每一像素的柔和度都是对用户的一份关怀。不要被标准的 iOS 列表所束缚，要去创造那种如风吹过樱花林般的流动美感。”*