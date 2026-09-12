# Journal Edit 屏 v2 工程实施 Handoff

> Generated 2026-04-29 配对 `./spec.md` + `./critique-v1.md`
> 实施分支建议：`feat/v2-journal-edit-screen`
> 上游基准：`docs/design/design-system/v2/{tokens.md, principles.md, components/*.md}` + `docs/design/screens/{record,add-drug}/spec.md`

---

## 1. 现有 BLoC/UseCase 兼容性

read `lib/features/journal/presentation/pages/journal_edit_page.dart` (273 行) + 同目录 cubit / bloc 后确认：

- **UseCases**：`AddJournalEntry` / `UpdateJournalEntry` 已在 `injection.config.dart` 注册，`@injectable` 装配完毕。本 PR **零 UseCase / domain 改动**。
- **删除既有日记**：v1 该屏未实现删除；本 PR 需新增 `DeleteJournalEntry` UseCase 与配套 `JournalRepository.deleteEntry(id)` 方法（若已存在则复用；通过 `Grep "deleteJournalEntry|deleteEntry"` 在 `lib/features/journal/domain/usecases/` 与 `repositories/` 内确认）。如缺失，新建 UseCase 文件 + repository 方法 + dataSource 调用，此为本 PR **唯一 domain 增量**。
- **MoodLevel enum**：`lib/features/journal/domain/entities/enums.dart` 当前含 `displayName` / `emoji` 扩展（hardcoded zh-CN）。v2 **不**删除既有扩展（domain 层零外部依赖、避免破坏其他屏），新增 `lib/features/journal/domain/entities/enum_l10n.dart`：`extension MoodLevelL10n on MoodLevel { String localizedName(AppLocalizations l10n) => switch (this) { MoodLevel.veryBad => l10n.moodVeryBad, ... } }`——遵循 DEC-042/043 模式。新 widget 仅调用 `localizedName(l10n)`；旧 `displayName / emoji` 暂保留待全局清理任务（不在本 PR 范围）。
- **RecordBloc 跨 feature 调用**：v1 line 92-94 `getIt<RecordBloc>().add(refresh())` 是 lazySingleton 模式下唯一允许的 side-effect，v2 保留——这是 record 屏与 journal edit 屏间的"数据回流"约定，其他 feature 不得效仿。
- **结论**：BLoC / UseCase 兼容；domain 层增量 = 1 个 UseCase（DeleteJournalEntry，若不存在）+ 1 个 enum_l10n 文件。

---

## 2. 文件改动清单

### 删除
- `lib/features/journal/presentation/pages/journal_edit_page.dart` 整文件 273 行重写（spec.md §2 wireframe）
- 删除内部私有方法 `_buildMoodSelector` (line 186-219) / `_buildTagsSelector` (line 221-272)
- 移除 `import 'package:flutter/material.dart' InputChip` 等 Material 件 import

### 新增（如未由前置 PR 落地，本 PR 落最小可用版）
- `lib/features/journal/domain/entities/enum_l10n.dart`（DEC-042/043 模式扩展，Mood / preset tag）
- `lib/features/journal/domain/usecases/delete_journal_entry.dart`（如不存在，参考 `add_journal_entry.dart` 模板）
- `lib/core/widgets/hana_top_bar.dart`（如未落，inline 简化版：实色 surfaceContainerHigh + 滚动 outline + leading/trailing slot）
- `lib/core/widgets/hana_input.dart`（如未落，inline 简化版：multiline + 底线呼吸；参考 components/text-field.md §工程实现提示）
- `lib/core/widgets/hana_button.dart`（如未落，inline 简化版：variants + isLoading + toggle 状态机；参考 components/button.md）
- `lib/core/widgets/hana_section_header.dart`（4px 黛蓝 Container + label · +0.6 · inkSecondary）
- `lib/core/widgets/hana_bottom_sheet.dart`（如未落，参考 components/bottom-sheet.md）
- `lib/core/widgets/hana_confirm_dialog.dart`（如未落，参考 components/confirm-dialog.md）

> 若 record / add-drug / today 三个前置 PR 已落 hana_top_bar / hana_input / hana_button / hana_section_header / hana_bottom_sheet / hana_confirm_dialog，本 PR 直接 import；否则按 add-drug handoff 既有约定补落最小可用版（标注 TODO 待 v1.1 spec 完成回填）。

### 修改
- `lib/features/journal/presentation/pages/journal_edit_page.dart`：整体重写（≈ 273 行 → ~200 行），结构按 spec.md §2
- `lib/core/l10n/arb/app_zh.arb` + `app_en.arb` + `app_ja.arb`：按 spec.md §8 改 5 个既有 key 的值（writeJournal / editDiary / diaryPlaceholder / addTags / 5 个 presetTagXxx）+ 新增 12 个 key（mood ×5、journalSave、journalDelete、journalDeleteConfirmTitle、journalDeleteConfirmMessage、journalSaveError、journalDatePickerTitle、journalMoodSection）
- `lib/core/l10n/arb/app_localizations*.dart`：自动重生成（`flutter gen-l10n`）
- `test/features/journal/presentation/pages/journal_edit_page_test.dart`（如存在）：按新 widget tree 调整 finder（emoji 圆 / InputChip 整段移除，改为 HanaButton toggle 查找）

---

## 3. 组件依赖

| 组件 | 来源 | 本 PR 角色 |
|------|------|-----------|
| `HanaTopBar` | components/top-bar.md | 用 |
| `HanaInput.multiline` | components/text-field.md | 用 |
| `HanaButton.secondary` (toggle) | components/button.md | 用 + 增加 toggle 状态机（selected → primary 实色） |
| `HanaButton.ghost` (loading) | components/button.md | 用 |
| `HanaSectionHeader` | v1.1 待落 spec | 用 / 落最小版 |
| `HanaBottomSheet.picker` | components/bottom-sheet.md | 用（日期 picker） |
| `HanaConfirmDialog.destructive` | components/confirm-dialog.md | 用（删除确认） |
| `HanaTokens` | tokens.md §8 | 用单轨 API（强制） |

> **HanaButton 扩展点**：v1.0 component spec 仅定义 `default / pressed / disabled / loading` 4 个 state；本屏需 `selected` 第 5 态——secondary variant 选中→ primary 实色填充 + onPrimary 文字。在本 PR 内最小扩展 `HanaButtonVariant.secondary` + 新增 `selected: bool` prop（默认 false）；待 button.md v1.1 正式补 toggle pattern 后回填到组件 spec。

---

## 4. 实施顺序（推荐）

1. **新增 ARB key + gen-l10n**（先跑通 i18n 链路，后续 widget 改写不会卡在文案上）
2. **新增 enum_l10n.dart**（MoodLevel.localizedName / 预设 tag → ARB 映射）
3. **新增 DeleteJournalEntry UseCase**（如需）
4. **改写 journal_edit_page.dart**：
   - 4.1 顶层 Scaffold + HanaTopBar（leading/trailing 双 ghost）
   - 4.2 hero 段：display-md 日期 + body-md 周名 + GestureDetector 触发 picker
   - 4.3 写作区：HanaInput.multiline，预填 controller
   - 4.4 心绪段：HanaSectionHeader + Row of HanaButton.secondary toggle ×5（单选）
   - 4.5 标签段：纯 label 标题（无竖线）+ Wrap of HanaButton.secondary toggle ×5（多选）
   - 4.6 saveEntry / deleteEntry / changeDate handlers + inline error 状态
5. **测试调整**：调整 widget test finder；新增 mood toggle 单选 / tag toggle 多选 / 日期 picker / 删除确认 4 个测试用例
6. **截图回归**：light / dark / zh / ja / en 五个 locale × 两个主题 × 新建 / 编辑两态 = 20 张截图，对照 spec.md §2 wireframe

---

## 5. ARB 三语对齐表

| Key | zh | en | ja |
|-----|-----|----|----|
| `writeJournal` | 写一篇。 | Write a page. | 一筆を。 |
| `editDiary` | 编辑此页。 | Edit this page. | この頁を編む。 |
| `diaryPlaceholder` | 今日宜，按时落墨。 | Today is good. Write a line. | 今日は静かに。一筆を。 |
| `addTags` | 留几个字 | A few words | 一言を |
| `presetTagHappy` | 喜 | Joy | 喜 |
| `presetTagAnxious` | 沉 | Heavy | 沈 |
| `presetTagCalm` | 安 | Calm | 安 |
| `presetTagTired` | 倦 | Weary | 倦 |
| `presetTagHopeful` | 起 | Rising | 起 |
| `moodVeryGood` | 激动 | Soaring | 高揚 |
| `moodGood` | 好 | Good | 良 |
| `moodNeutral` | 平 | Plain | 平 |
| `moodBad` | 累 | Worn | 疲 |
| `moodVeryBad` | 沉 | Sunk | 沈 |
| `journalMoodSection` | 今日心绪 | Today's mood | 今日の心 |
| `journalSave` | 保存。 | Save. | 保存。 |
| `journalDelete` | 删除。 | Delete. | 削除。 |
| `journalDeleteConfirmTitle` | 删除后不可恢复。 | Cannot be undone. | 削除すると戻せません。 |
| `journalDeleteConfirmMessage` | 这一页将抹去。仍要继续？ | This page will be erased. Continue? | この頁は消えます。続けますか？ |
| `journalSaveError` | 保存失败。请重试。 | Save failed. Please retry. | 保存に失敗しました。再試行してください。 |
| `journalDatePickerTitle` | 记在哪一天。 | Which day. | どの日に。 |

---

## 6. 验证清单（PR 自检）

### 视觉
- [ ] 全屏零 emoji（mood / tag / placeholder / error 全文字化）
- [ ] 全屏零渐变 / 零 BoxShadow / 零 BackdropFilter / 零 Border.all（除 secondary toggle 1px 黛蓝边）
- [ ] 全屏稳态黛蓝 ≤ 3 处（截图核对：竖线 1 + mood 选中 1 + tag 选中视觉合并 1 = 3）
- [ ] 圆角全部 ≤ 6（toggle 6 / 写作区底色 2 / 无 stadium / 无 16+）
- [ ] AppBar 实色米灰、滚动出现 outline，**无** BackdropFilter
- [ ] 字体：display-md 用 Spectral SemiBold / 思源宋体 / Noto Serif JP；body 用 Inter / 思源黑体；**零** Plus Jakarta Sans

### 交互
- [ ] 写作区 focus 240ms 1→2px 黛蓝呼吸线生效
- [ ] Mood toggle 单选（选 A 后选 B，A 自动取消）
- [ ] Tag toggle 多选（A B C 可同时选中，再 tap 取消）
- [ ] Hero 日期 tap → HanaBottomSheet.picker 升起
- [ ] 删除（编辑态）→ HanaConfirmDialog.destructive 弹出，confirm 朱砂、cancel 黛蓝 ghost
- [ ] 保存失败 → inline 朱砂错误，trailing「保存。」可重试
- [ ] 物理返回直接 pop（无未保存确认——本 PR 不实现，P3 跟进）

### i18n
- [ ] 5 个既有 key 文案改写完成（zh/en/ja 同步）
- [ ] 12 个新 key 落地，三语对齐
- [ ] `flutter gen-l10n` 成功无报错
- [ ] 切换 zh / en / ja，hero 日期格式正确（zh「4 月 28 日」/ en「Apr 28」/ ja「4 月 28 日」）+ 周名正确

### a11y
- [ ] Mood toggle Semantics radio + selected
- [ ] Tag toggle Semantics checkbox + selected
- [ ] Hero 日期 Semantics「2026 年 4 月 28 日 周二，可点击修改」
- [ ] inline error liveRegion=true
- [ ] 触控目标全部 ≥ 44dp
- [ ] 对比度（Light / Dark）AAA 通过

### 工程
- [ ] `dart analyze --fatal-infos` 通过
- [ ] `flutter test` 全绿（基线 323 通过 + 本屏新增 4 个用例）
- [ ] `flutter build apk --debug` 通过（CI 验证）
- [ ] 删除 `import 'package:flutter/material.dart' show InputChip` 等装饰 import
- [ ] 颜色 / 间距 / 字号全部走 `HanaTokens.xxx(context)`，禁止 hex 字面量与 magic number

---

## 7. 风险与决策

| 风险 | 决策 | 备注 |
|------|------|------|
| HanaButton toggle pattern 不在 v1.0 component spec | 本 PR 内最小扩展 + 标注 TODO，待 button.md v1.1 回填 | 不阻塞本 PR |
| MoodLevel.displayName / emoji 旧扩展保留 | 不删除，仅新 widget 不调用；全局清理任务排 backlog | 避免破坏 timeline / today 已有调用点 |
| 长 ja 文案 trailing 双 ghost 「削除します」「保存します」溢出 | ja key 锁 4 字内（「削除。」「保存。」），web 断点切 overflow menu | spec §10 已记 |
| Tag「沉」与 Mood「沉」同字 | 保留同字，靠段落标题语义 + spacing.lg 分离 | spec §10 已记 |
| 删除 UseCase 缺失 | 本 PR 新增（约 30 行 + 1 个 repo 方法）；如已存在则复用 | implementation 第 3 步 |
| `getIt<RecordBloc>().add(refresh())` 跨 feature 直调 | 保留 v1 行为，handoff §1 注明这是 lazySingleton 唯一允许 side-effect | 其他 feature 不得效仿 |
| 写作区 focus 时 mood/tag 段被键盘遮挡 | 预期行为（用户先写后选），不调整 | spec §10 已记 |
| 未保存草稿物理返回丢失 | 本 PR 范围外（P3）；如长内容（>50 字）时弹 ghost confirm | 后续 PR |

---

## 8. 节奏与停顿

- **进入屏**：路由 `context.push('/journal/edit', extra: existingEntry)` 后 240ms slideUp（go_router 默认）
- **新建态键盘自动升起**：100ms 延迟后 requestFocus，避免 hero 入场动画与键盘升起同时发生造成跳动
- **Hero 日期切换**：bottom sheet dismiss 后 240ms 文本淡入新值（替换硬切）
- **保存成功**：trailing isLoading=true → 200~600ms 后 pop（不上 HanaCelebration，仪式感留给「记一次」服药动作；日记保存是连续写作流的延伸，不破坏沉浸）
- **删除成功**：confirm dialog dismiss → 240ms slideDown → pop（不上"已删除"toast，删除是用户主动决断，无需反馈确认）

— 完 —
