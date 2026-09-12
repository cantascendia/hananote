# Profile 屏 v2 视觉规范

> Generated 2026-04-29 from DESIGN.md v2 + tokens.md + principles.md + components/
> 屏幕：`lib/features/settings/presentation/pages/profile_page.dart`
> 阶段：Phase 3.3.b 新稿（spec）+ 3.3.c 自审 critique-v2
> 配对 handoff：`docs/design/handoff/profile.md`
> 子屏（settings 详细）留 Phase 3.4：`settings_detail_page.dart`

---

## 1. 设计意图

Profile 是这本私人内刊的**奥付页 / 版权页**——读者偶尔翻到的"关于这本册子"。它聚合用户身份、数据归属、隐私边界、偏好选择、版权信息五件事，但**视觉上必须沉默**：无头像彩色 placeholder、无 bento 卡堆叠、无圆形彩色 icon 容器、无双拼方块。月白底 + 一行墨色宋体「{用户名}」+ 五节列表纵向铺陈，像翻新潮文库末页的版权 / 致谢 / 索引。

v1 vs v2 核心差异：v1 是"彩色仪表盘"（每功能一张 bento + 圆形 icon），v2 是"奥付页"（每节一张内文页 + 文字行）。v1 默认 1 屏装下所有；v2 默认 2-3 屏滚动呼吸——**Profile 屏不需要"压缩到一屏"，需要"分章节呼吸"**。

跨性别敏感性继承 onboarding：用户名旁不显示性别符号；HRT 状态用中性陈述（"HRT 第 245 天"），禁"服药 N 天" / 性别词。

---

## 2. 屏幕骨架（ASCII Wireframe）

```
┌─────────────────────────────────────────────┐
│ HanaTopBar.default · surfaceContainerHigh   │  ← 56dp 实色，无 blur，无 backLeading
│   "我的"  (label-md +0.6 · ink, 居中或左对齐) │     滚动出现 0.5px outline @ 30%
├─────────────────────────────────────────────┤
│   (顶部留白 spacing.xl = 64)                │
│                                             │
│   {displayName}                              │  ← display-xl (40·52·-0.5)
│   (Spectral SemiBold / 宋体 Medium)         │     ink 墨色，左对齐 spacing.lg=32
│                                             │     若空则显示「无名」
│   HRT 第 245 天　·　起始 2024-08-15          │  ← mono 14·20 inkSecondary
│   (JetBrains Mono Light)                    │     副行，跨性别中性陈述
│                                             │
│   (段落间 spacing.xl = 64)                  │
│                                             │
│  ┃ 数据                                      │  ← HanaSectionHeader
│  ┃ (label-md +0.6 inkSecondary + 4px 黛蓝竖线)│     竖线长度 = 首行 16px
│                                             │
│   (spacing.md = 16)                         │
│                                             │
│   ╭────────────────────────────────────╮    │  ← HanaCard.list（surfaceContainerLowest）
│   │  导出备份                          │    │     padding 0，列表项内部 horiz 24 vert 20
│   │       上次：4 月 12 日             │ →   │  ← HanaListItem (trailing=mono 日期)
│   ├────────────────────────────────────┤    │
│   │  导入备份                          │ ›   │  ← HanaListItem (trailing=chevron)
│   ├────────────────────────────────────┤    │
│   │  生成 PDF 报告                     │ ›   │
│   ├────────────────────────────────────┤    │     列表项之间用 surface 阶差极弱分组：
│   │  存储用量                          │ 28MB│     surfaceContainerLowest #FBF8F2 vs
│   ╰────────────────────────────────────╯    │     surfaceContainerLow #F4F1EA 1px 横向
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 隐私                                      │  ← HanaSectionHeader
│                                             │
│   ╭────────────────────────────────────╮    │
│   │  应用锁                       [⏤●]│    │  ← HanaListItem (trailing=Switch v2)
│   ├────────────────────────────────────┤    │
│   │  生物识别                     [●⏤]│    │
│   ├────────────────────────────────────┤    │
│   │  隐私模式                          │ ›   │
│   │       已开启                       │    │  ← subtitle inkSecondary body-sm
│   ├────────────────────────────────────┤    │
│   │  清除所有数据                      │ ›   │  ← title 朱砂 error，trailing 朱砂 chevron
│   ╰────────────────────────────────────╯    │     onTap → HanaConfirmDialog destructive
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 偏好                                      │
│                                             │
│   ╭────────────────────────────────────╮    │
│   │  主题                       中文宋│ ›   │  ← trailing 当前值 mono / body-sm
│   ├────────────────────────────────────┤    │
│   │  语言                         中文│ ›   │
│   ├────────────────────────────────────┤    │
│   │  通知                              │ ›   │  ← 跳 /notification_settings
│   ╰────────────────────────────────────╯    │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│  ┃ 关于                                      │
│                                             │
│   ╭────────────────────────────────────╮    │
│   │  版本                       1.2.0 │    │  ← trailing mono trailingText
│   ├────────────────────────────────────┤    │
│   │  检查更新                          │    │  ← subtitle: 上次检查 4 月 28 日
│   │       上次：4 月 28 日 14:30       │ ›   │     trailing chevron
│   ├────────────────────────────────────┤    │
│   │  隐私政策                          │ ›   │
│   ├────────────────────────────────────┤    │
│   │  使用条款                          │ ›   │
│   ╰────────────────────────────────────╯    │
│                                             │
│   (段落间 spacing.lg = 32)                  │
│                                             │
│   [ 退出 ]   HanaButton.ghost · 朱砂文字     │  ← 居中或左对齐均可，44dp 高
│                                             │     onTap → HanaBottomSheet 确认
│                                             │
│   (底部留白 spacing.xl = 64)                │
└─────────────────────────────────────────────┘
```

**空态 / 错误态 / 加载态** 与 today 屏一致：`HanaEmptyState.page` / `HanaErrorState` / `HanaLoadingView.block`，不重复定义。

---

## 3. 章节结构（5 节）

| # | 节名 (zh) | 节名 (en) | 节名 (ja) | 列表项 |
|---|----------|----------|----------|-------|
| 1 | （hero 区无标题） | (no header) | （ヘッダーなし） | displayName + HRT 副行 |
| 2 | 数据 | Data | データ | 导出备份 / 导入备份 / 生成 PDF / 存储用量 |
| 3 | 隐私 | Privacy | プライバシー | 应用锁 / 生物识别 / 隐私模式 / 清除所有数据 |
| 4 | 偏好 | Preferences | 設定 | 主题 / 语言 / 通知 |
| 5 | 关于 | About | このアプリ | 版本 / 检查更新 / 隐私政策 / 使用条款 |
| 末 | （退出按钮） | (Sign out) | （サインアウト） | HanaButton.ghost 朱砂 |

**v1 → v2 删除**：v1 顶部"我的用药"卡 + "库存 / 用药计划"双拼方块——这些属于 medication feature，搬出 Profile，进入 Today 或 Drugs 入口屏。Profile 不再聚合用药管理。

---

## 4. 组件映射

| 区域 | v2 组件 | Variant | 关键 props / 备注 |
|------|--------|---------|---------|
| 顶部栏 | `HanaTopBar` | default | title="我的"，无 leading，无 actions（v1 的 settings gear / notifications 删除——通知进"偏好"节，settings gear 整页就是 settings） |
| Hero 名字 | (Text 直接) | display-xl 宋体 | `state.profile.displayName`，空则 l10n.profileNoName="无名" |
| Hero 副行 | (RichText: mono + body-sm) | mono | "HRT 第 {n} 天　·　起始 {date}"，全角空格 |
| 章节标题 | `HanaSectionHeader` | default | label-md +0.6 inkSecondary + 4px 黛蓝竖线（覆盖首行高 16px） |
| 列表卡容器 | `HanaCard` | list | surfaceContainerLowest, radius 4, padding 0（列表项自带 padding） |
| 列表项 | **`HanaListItem`** (v1.1 待补) | default / switch / chevron / destructive | 见 §6 |
| Switch | `HanaSwitch` (v1.1 待补) | default | activeColor=primary, trackColor=accentMuted |
| 退出按钮 | `HanaButton` | ghost | label="退出"，textColor=error，44dp 高 |
| 退出确认 | `HanaBottomSheet` | info | title="退出登录", actions=[ghost cancel, primary 确认] |
| 清除数据确认 | `HanaConfirmDialog` | destructive | title="清除所有数据后不可恢复。", message="本机所有用药 / 检查 / 日记将被永久删除。仍要继续？", confirmLabel="清除" |
| 错误 / 加载 / 空 | `HanaErrorState` / `HanaLoadingView.block` / `HanaEmptyState.page` | — | 同 today 屏 |
| 提示 | `HanaSnackbar.show` | info / success / error | 替代 `_showSnackBar` inline helper |

---

## 5. Tokens 引用清单

### 颜色
| 用途 | Token |
|------|-------|
| Scaffold 背景 | `HanaTokens.background(context)` |
| 列表卡容器 | `HanaTokens.surfaceContainerLowest(context)` |
| AppBar 实底 | `HanaTokens.surfaceContainerHigh(context)` |
| Hero 名字 / 列表项主文 | `HanaTokens.ink(context)` |
| 副行 / subtitle / trailingText | `HanaTokens.inkSecondary(context)` |
| 章节竖线 / Switch active | `HanaTokens.primary(context)` |
| 清除数据 title / 退出文字 / chevron | `HanaTokens.error(context)` |
| Switch trackColor / 当前选中标记 | `HanaTokens.accentMuted(context)` |

### 间距
| 用途 | Token |
|------|-------|
| 屏幕水平 padding | `spacing.lg` = 32 |
| Hero 顶部留白 | `spacing.xl` = 64 |
| Hero 副行行间 | `spacing.xs` = 4 |
| 章节标题 → 列表卡 | `spacing.md` = 16 |
| 节与节之间 | `spacing.lg` = 32（hero 与第 1 节之间用 `xl` = 64） |
| 列表项内 padding | horiz 24 / vert 20（HanaListItem 内置） |
| 屏幕底部 | `spacing.xl` = 64 |

> 强制跨级：hero(64) → 章节(16) → 节间(32) → 屏底(64)，无 16 紧挨 16。

### 圆角
| 用途 | Token |
|------|-------|
| 列表卡容器 | `radius.card` = 4 |
| 退出按钮 | `radius.button` = 6 |
| Switch（系统） | thumb pill 999（仅此 + Confirm dialog 8 例外） |

> **彻底告别 v1**：bentoDecoration 24px 圆角 + HRT day pill 9999 全部删除。

### 字体
| 用途 | Token |
|------|-------|
| Hero displayName | `display-xl` (40·52·-0.5) Spectral SemiBold / 思源宋体 / Noto Serif JP Medium |
| Hero 副行 mono 数值 | `mono` (14·20·0) JetBrains Mono Light |
| 章节标题 | `label` (12·16·+0.6) Medium |
| 列表项 title | `body` (15·24·0) Regular |
| 列表项 subtitle | `body-sm` (13·20·0) inkSecondary |
| 列表项 trailingText（日期 / 容量 / 版本号） | `mono` (14·20·0) |
| 列表项 trailingText（语言名 / 主题名） | `body-sm` (13·20·0) inkSecondary |
| 退出按钮文字 | `body` (15·24·0) Medium |

### 动画
| 用途 | Token |
|------|-------|
| 列表项 press scale | `motion.quick` 150ms easeOut → 0.98 |
| Switch 切换 | `motion.standard` 240ms easeInOut |
| 章节入场 fadeIn | `motion.standard` 240ms 错落 80ms |
| HanaConfirmDialog 进出 | 240ms scale 0.96→1.0 / 200ms fadeOut |

---

## 6. HanaListItem（v1.1 spec 待补，本屏先行使用）

**形态**（在 components/list-item.md 落地前的临时锚点）：

| Variant | 视觉 | 用例 |
|---------|------|------|
| `default` | title body·ink 左 / chevron 右（可选） | 普通跳转项 |
| `withSubtitle` | title + subtitle body-sm·inkSecondary 上下两行 | "隐私模式 / 已开启" |
| `switch` | title + Switch 右 | 应用锁 / 生物识别 |
| `withTrailingText` | title + trailingText（mono 或 body-sm）+ 可选 chevron | 版本 1.2.0 / 上次：4 月 12 日 |
| `destructive` | title=error / chevron=error | 清除所有数据 |

**关键 props（建议）**：
- padding 横 24 / 纵 20（44dp+ 触控）
- **无前置 icon 圆形容器**——v1 的 `Container(decoration: iconColor.withAlpha(26), shape: circle)` 全部删除；如必须 icon 仅允许 `outlined` style + `inkSecondary` size 20 紧贴 title 左侧 12px gap
- **无 separator 横线**——分项靠 surface 阶差（surfaceContainerLowest 列表项 vs surfaceContainerLow 1px 横向带）或就用 spacing.sm 8 留白
- title 默认 `body 15 ink Regular`（不是 v1 的 w800 bold）

> 上述细节将在 Phase 4 补 `components/list-item.md` 时正式收口。本屏先按此约定实现。

---

## 7. 交互状态

### 默认
- Hero + 5 节列表项依次 fadeIn `motion-standard` 240ms 错落 80ms
- AppBar 实色无底线（offset = 0）

### Switch 切换
- Switch press → 派 `ToggleAppLock` / `ToggleBiometric` event
- 视觉：thumb 240ms 平移 + track color crossfade（accentMuted ↔ primary）
- 失败回滚：HanaSnackbar.show(variant=error)

### 列表项 chevron 按下
- HanaPressScale 0.98 / 150ms
- 跳路由：`/legal/privacy` / `/legal/terms` / `/notification_settings` / `/settings`（详细 settings）

### "清除所有数据"
1. HanaConfirmDialog.show(variant=destructive)
2. 确认 → bloc add WipeSettingsData
3. SettingsWiped 状态 → context.go('/')
4. 失败 → HanaSnackbar error

### "退出"
1. HanaBottomSheet.show(action-sheet variant)
2. 确认 → bloc 派出 sign out event
3. 跳转登录 / onboarding 入口

### "检查更新"
- 列表项 onTap → 触发 update_service 检查
- subtitle 实时更新："上次：刚刚" / "已是最新版" / "发现新版本 1.2.1"
- 若有新版本，title 右侧出现 1 个黛蓝小圆点（4dp）作"未读标记"——这是黛蓝的合规第 4 处出现（章节竖线 + Switch active + tab 下划线 + 更新点 = 仍 ≤ 4，但本屏可见区域 ≤ 3 处需调度）

---

## 8. 断点行为

| 宽度 | 布局 |
|------|------|
| < 768 (mobile) | 单列，水平 padding 32，列表卡占满 |
| 768–1024 (tablet) | 单列内文页 max-width 720px 居中 |
| ≥ 1024 (web 桌面) | 三列：左 240 sidebar（章节锚点：数据 / 隐私 / 偏好 / 关于）/ 中 720 主体 / 右 240 留白（不放浮岛） |

---

## 9. i18n 注意（最长文案预测）

| key | en | zh | ja | 最长 |
|-----|----|----|----|------|
| profileTitle | Profile | 我的 | プロフィール | ja 6 字 |
| profileSectionData | Data | 数据 | データ | en 4 / ja 4 |
| profileSectionPrivacy | Privacy | 隐私 | プライバシー | **ja 7 字** |
| profileSectionPreferences | Preferences | 偏好 | 設定 | **en 11 字** |
| profileSectionAbout | About | 关于 | このアプリ | **ja 6 字** |
| profileItemAppLock | App Lock | 应用锁 | アプリロック | **ja 7 字** |
| profileItemBiometric | Biometric | 生物识别 | 生体認証 | en 9 字 |
| profileItemNotifications | Notifications | 通知 | 通知設定 | **en 13 字** vs zh 2 字（差 6.5×）|
| profileItemWipeAll | Clear All Data | 清除所有数据 | すべてのデータを削除 | **ja 12 字** |
| profileItemCheckUpdate | Check for Update | 检查更新 | 更新を確認 | **en 16 字** |

**排版兼容规则**：
- 列表项 title 允许 `Wrap` 两行（spacing.xs 4 行间）；超过两行截断 + ellipsis
- 章节竖线高度 = title 首行 line-height（16px），不随多行延长——保持"段落标记"语义
- ja 「すべてのデータを削除」+ 朱砂 chevron 总宽超 90% → 允许换 2 行
- mono trailingText（日期 / 版本）固定 `body-sm` 字号在所有 locale 一致——不为长文案缩字

---

## 10. a11y 检查

| 项 | 状态 |
|----|------|
| 触控目标 ≥ 44dp | ✓ — 列表项 64dp / Switch 56dp / ghost 按钮 44dp |
| Semantics | ✓ — Switch 朗读 "应用锁，开关，已开启"；destructive 朗读 "清除所有数据，按钮，警告" |
| 焦点顺序 | AppBar → Hero → 数据节 → 隐私节 → 偏好节 → 关于节 → 退出 |
| prefers-reduced-motion | ✓ — Switch 动画退化为瞬时切换；fadeIn 跳过 |
| 对比度 | ✓ — error #9B2A2A on #FBF8F2 = 7.1:1 (AAA)；ink on background = 14.8:1 (AAA) |
| dynamic type | ✓ — title body 15 / subtitle body-sm 13 / trailingText mono 14，全部支持系统字号缩放 |

---

## 11. 自审 critique-v2

| 原则 | 是否符合 | 备注 |
|------|---------|------|
| 1. 一抹强色 ≤ 3 处 | ✓ | ① 章节竖线（5 个但同色块同义，视觉计 1 处段落标记语法）② Switch active thumb（开关时计 1）③ tab 下划线（底栏，跨屏共享，本屏计 1）。朱砂用于 destructive，不算黛蓝。更新红点是黛蓝第 4 处但仅在有新版本时短暂出现，可接受。 |
| 2. 调和层次胜过投影 | ✓ | 零 BoxShadow / 零 BackdropFilter / 零 border。列表卡靠 surfaceContainerLowest vs background 6 个明度差。 |
| 3. 编辑级不对称 | ✓ | Hero 左对齐 32，右侧 70% 留白。章节竖线段落标记。退出按钮可左对齐或居中（ghost 不强势）。 |
| 4. 慢节奏与留白 | ✓ | hero(64) / 节间(32) / 章节标题→列表(16) / 列表项内(20)，强制跨级。 |
| 5. 内容即装饰 | ✓ | 零 emoji / 零渐变 / 零彩色 icon 圆形容器 / 零 stadium pill。HRT 副行用 mono 而非 pill 装饰。 |

**遗留风险**：
- HanaListItem / HanaSectionHeader / HanaSwitch 三组件 spec 未在 components/ 落地（本屏抢跑使用），需 Phase 4 补
- "存储用量"（28MB）数据来源未在 SettingsState 暴露，需后端 cubit 加 storageUsage 字段
- 更新检查的"未读黛蓝点" 是否破坏"≤ 3 处"原则，待 3.3.c 自审复议——保守做法是改为 inkSecondary 的"NEW"label 而非黛蓝点

---

— 完 —
