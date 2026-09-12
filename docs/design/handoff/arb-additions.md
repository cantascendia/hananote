# v2 重设计新增 ARB Key 总清单

> Generated 2026-04-29
> 收拢自 docs/design/screens/{today,onboarding,record,timeline,data,profile,drug-list,inventory,schedule-editor,add-drug}/{spec.md,handoff.md} + docs/design/ux-copy-v2/copy-revisions.md
> 三语并行修改不允许只加 zh；未提供 ja 翻译的暂用 [zh] placeholder 标 TODO

---

## 总数：约 105 个新增 / 改值 key 跨 7 类

类别分布（粗略估算）：
- Onboarding（5 屏新流程）：~16 个新增
- Today / Record / Timeline / Data 屏：~28 个新增
- Inventory / Drug list / Schedule editor / Add drug：~38 个新增
- Profile：~10 个新增
- 共享 hero / hint / 状态：~8 个新增
- copy-revisions 80 keys 改值：保留 key 仅改 value（不计入"新增"，单独列§9）

---

## 1. Today 屏（来源：today/spec.md §11 + record/spec.md §8）

| key | zh | en | ja | 用途 |
|-----|-----|-----|-----|------|
| heroMorning | 早。 | Morning. | おはよう。 | hero greeting 默认态 |
| heroDayComplete | 今日完毕。 | Day complete. | 一日終了。 | 全已服 hero |
| heroDateLine | {month} 月 {day} 日　{weekday} | {weekday}, {month} {day} | {month} 月 {day} 日　{weekday} | 副行日期 |
| heroHrtDays | 第 {n} 天　HRT | {n} days　HRT | 第 {n} 日　HRT | mono 副行 |
| sectionCurrent | 当前 | Current | 今 | 当前服药节标题 |
| sectionLater | 之后 | Later | のち | 已服节标题 |
| recordOnce | 记一次 | Mark taken | 一回記す | 服药 CTA（覆盖 takeDose） |
| celebrationRecorded | 今日已记。 | Recorded. | 今日、記し終えた。 | HanaCelebration 文字 |
| todayDoseTimeArrived | {time} 到时间了。 | {time} now. | {time} です。 | 卡内时间陈述 |
| todayEmptyTitle | 本期空白。 | Nothing yet. | まだなし。 | 空态标题 |
| todayEmptyMessage | 尚未设置每日用药。 | No daily medication set. | 服薬予定が未設定。 | 空态副行 |
| todayEmptyCta | 添加第一项 | Add the first | 最初の一項を | secondary 按钮 |
| todayErrorRetry | 载入失败。请下拉刷新。 | Load failed. Pull to refresh. | 読込失敗。下に引いて更新。 | 错误态 |
| commonRetry | 重试 | Retry | 再試行 | 错误态 ghost 按钮 |
| commonReading | 读取中。 | Loading. | 読込中。 | 加载态文字 |

---

## 2. Onboarding 屏（来源：onboarding/spec.md §2 + §10）

| key | zh | en | ja | 用途 |
|-----|-----|-----|-----|------|
| onboardingHrtStatusTitle | 进展。 | Progress. | 進み。 | 屏 3 标题 |
| onboardingHrtStatusOnHrt | 已经在 HRT。 | I'm on HRT. | HRT 中。 | 屏 3 选项 1 |
| onboardingHrtStatusNotStarted | 还没开始。 | Not yet. | まだ。 | 屏 3 选项 2 |
| onboardingHrtStatusPrefersNotToSay | 不想说。 | Rather not say. | 言いたくない。 | 屏 3 选项 3 |
| onboardingHrtStatusOnHrtDescription | 会进入用药记录。 | Continues to medication log. | 服薬記録へ進む。 | 选项 1 副述 |
| onboardingHrtStatusNotStartedDescription | 只是先走一遍内刊。 | Just browse the journal. | 内誌を一巡。 | 选项 2 副述 |
| onboardingHrtStatusPrefersNotToSayDescription | 会跳过相关问题。 | Skips related prompts. | 関連項目を飛ばす。 | 选项 3 副述 |
| onboardingDrugTitle | 记一种药。 | Note one medication. | 一種を記す。 | 屏 4 标题（与 onboardingAddDrug 拆分）|
| onboardingDrugSkip | 跳过这步 | Skip this step | このステップを後で | 屏 4 ghost 按钮 |
| onboardingMedicalDisclaimer | HanaNote 是私人记录工具，不替代医生的诊断。任何剂量调整请先咨询医师。 | HanaNote is a private journal, not medical advice. Consult a clinician before changing your regimen. | HanaNote は私的な記録です。診断の代わりにはなりません。方案調整は医師にご相談ください。 | 屏 5 法律免责 |
| onboardingEnterToday | 进入今日。 | Enter today. | 今日へ。 | 屏 5 primary 按钮 |
| onboardingNameSafety | 这是给自己看的，可化名。 | Just for yourself. A nickname is fine. | 自分のための名前です。 | 屏 2 helperText（替代旧 onboardingNameNote） |
| onboardingPagination | {current} / {total} | {current} / {total} | {current} / {total} | mono 页码 |
| onboardingSkipName | 跳过 | Skip | 後で | 屏 2 ghost 按钮 |
| onboardingHrtStartDateTitle | 从哪一天起，你不再是从前的自己。 | The day everything began. | あの日から、あなたは変わった。 | 屏 4 picker sheet 标题（copy-revisions §1） |

---

## 3. Record 屏（来源：record/spec.md §8）

| key | zh | en | ja | 用途 |
|-----|-----|-----|-----|------|
| recordSectionEntries | 三道入口 | Three entries | 三つの入口 | HanaSectionHeader |
| recordLoading | 读取中。 | Loading. | 読込中。 | 加载态（或复用 commonReading） |
| recordErrorTitle | 载入失败。请下拉刷新。 | Load failed. Pull to refresh. | 読込失敗。下に引いて更新。 | 错误态 |

> 复用现有 key 改 value（不计入新增）：`recordTitle` / `recordGreeting` / `recordPhoto` / `recordPhotoSub` / `recordMeasurement` / `recordMeasurementSub` / `recordDiary` / `recordDiarySub` / `recordPhotoEmpty` / `recordMeasureEmpty` / `recordDiaryEmpty` / `recordLastPhoto` / `recordStreak`。详见 §9 deprecated 灰度清单。

---

## 4. Timeline 屏（来源：timeline/spec.md §2-§5）

| key | zh | en | ja | 用途 |
|-----|-----|-----|-----|------|
| timelineHero | 年表。 | The chronicle. | 年表。 | hero display-xl |
| timelineHeroSub | 共 {n} 条　始于 {date} | {n} entries　since {date} | 計 {n} 件　{date} から | 副行 |
| timelineEmpty | 尚无记录 | None yet | 記録なし | 空态副行 |
| timelineEmptyTitle | 尚未起笔。 | Yet to begin. | まだ書かれず。 | 空态标题（copy-revisions §4） |
| timelineEmptyMessage | 记下第一笔，年表自此展开。 | Note your first entry — the chronicle begins. | 一筆目を記せば、年表が始まる。 | 空态副行 |
| timelineEmptyCta | 新增一笔 | Add an entry | 一筆を加える | secondary 按钮 |
| timelineCtaPrimary | 新增一笔。 | New entry. | 一筆を加える。 | 底部 sticky CTA |
| timelineStartPoint | 起点。 | The beginning. | はじまり。 | 起点标题 |
| timelineFilterTitle | 筛选 | Filter | 絞り込み | bottom sheet 标题 |
| timelineFilterTypeLabel | 类型 | Type | 種類 | 类型段 |
| timelineFilterRangeLabel | 时间范围 | Time range | 期間 | 时间范围段 |
| timelineRange7d / 30d / 90d / 6m / 1y / all | 近 7 天 / 近 30 天 / ... / 全部 | 7 d / 30 d / ... / All | 7 日 / 30 日 / ... / 全て | 6 个 chip |
| timelineFilterApply | 应用筛选 | Apply filter | 絞り込む | sheet primary |
| timelineFilterReset | 重置 | Reset | リセット | sheet ghost |
| timelineFilterEmpty | 本期空白。 | Empty for this range. | この期間は空白。 | 筛选无结果空态标题 |
| timelineFilterEmptyMessage | 调整筛选试试。 | Try adjusting filters. | 絞り込み条件を変えて。 | 副行 |
| timelineEventOpenDetail | 跳转详情 | Open detail | 詳細へ | bottom-sheet 行动 |
| timelineMonthSection | {year} · {month} 月 | {month} {year} | {year} · {month} 月 | 月份章节标记 |
| timelineEventTypeMedication / BloodTest / Measurement / Photo / Journal / Milestone | 服药 / 血检 / 测量 / 照片 / 日记 / 里程碑 | Med / Blood / Body / Photo / Journal / Milestone | 服薬 / 血検 / 体測 / 写真 / 日記 / 節目 | 6 个 inline label（DEC-042/043 替代 domain getter）|

---

## 5. Data 屏（来源：data/spec.md §3 + §6 + §9）

| key | zh | en | ja | 用途 |
|-----|-----|-----|-----|------|
| dataHero | 本期数据。 | This period. | 今期データ。 | hero display-xl |
| dataHeroSub | 截至 {date}　共 {n} 期 | Through {date}　{n} reports | {date} まで　計 {n} 期 | 副行 |
| dataSectionCurrent | 当前指标 | Current | 今期 | section header |
| dataSectionTrend | 趋势 | Trend | 推移 | section header |
| dataSectionTools | 工具 | Tools | ツール | section header |
| dataSectionHistory | 历次报告 | History | 履歴 | section header |
| dataStatusInRange | 在范围内 | In range | 範囲内 | hormone 状态副述 |
| dataStatusHigh | 偏高 | High | 高め | hormone 状态副述 |
| dataStatusLow | 偏低 | Low | 低め | hormone 状态副述 |
| dataCriticalSuggest | 建议复诊。 | Recheck soon. | 再検査を。 | critical 朱砂注脚 |
| dataRangeFormat | 范围 {min} – {max}　·　{statusText} | Range {min} – {max}　·　{statusText} | 範囲 {min} – {max}　·　{statusText} | hormone 范围行 |
| dataTrendNotEnough | 需至少两次报告才能成线。 | Two or more reports needed to chart. | 線になるまで二件以上を。 | inline empty |
| dataTrendLatest | 最近一次　{value} {unit}　·　{compareText} | Latest　{value} {unit}　·　{compareText} | 最近　{value} {unit}　·　{compareText} | 趋势注脚 |
| dataTrendCompareSame | 与上次持平 | Same as last | 前回と同 | 比较 |
| dataTrendCompareUp / Down | 较上次升 {delta} / 降 {delta} | Up / Down {delta} | 前回 +{delta} / -{delta} | 比较 |
| dataChartXMonth | {n} 月 | {month} | {n} 月 | X 轴 label |
| dataToolsSimulator | PK 模拟器 | PK simulator | PK シミュレータ | 工具卡 |
| dataToolsSimulatorSub | 按药物代谢估算次日血药浓度。 | Estimate tomorrow's plasma level. | 翌日の血中濃度を推定。 | 副述 |
| dataToolsKnowledge | 知识库 | Knowledge | 文献 | 工具卡 |
| dataToolsKnowledgeSub | HRT 流程、药物百科与文献摘要。 | HRT protocols, drug pedia, literature. | HRT 流程・薬辞典・文献抄。 | 副述 |
| dataEmptyTitle | 本期空白。 | Nothing yet. | まだなし。 | 空态 |
| dataEmptyMessage | 尚未录入血检报告。 | No blood tests recorded. | 血検報告が未記入。 | 副行 |
| dataEmptyCta | 录入第一份 | Record the first | 一件目を記入 | secondary 按钮 |

---

## 6. Inventory 屏（来源：inventory/handoff.md §2）

| key | zh | en | ja | 用途 |
|-----|-----|-----|-----|------|
| inventory | 库存 | Inventory | 在庫 | hero |
| inventoryHeroSubAmple | 共 {n} 项　·　充足 | {n} items · ample | 計 {n} 項　·　十分 | 全充足副行 |
| inventoryHeroSubLow | 共 {n} 项　·　{m} 项偏低 | {n} items · {m} low | 計 {n} 項　·　{m} 項不足 | 偏低副行 |
| inventoryHeroEmpty | 尚未启用。 | None yet. | 未設定。 | 空 hero |
| inventorySectionCurrent | 当前库存 | Current | 在庫 | section |
| inventorySectionRecent | 最近补货 | Recent | 補充履歴 | section |
| inventorySectionNotify | 通知 | Notify | 通知 | section |
| inventoryDaysApprox | 约 {n} 天 | ~{n} days | およそ {n} 日 | 剩余天数 |
| inventoryQtyRemaining | 剩 {qty} {unit} | {qty} {unit} left | 残 {qty} {unit} | 剩余量 |
| inventoryCriticalSuggest | 建议补货。 | Restock soon. | 補充を。 | critical 注脚 |
| inventoryScheduleMissing | 估算需服药计划。 | Schedule needed. | 服薬計画が必要。 | 缺计划注脚 |
| inventoryRestockTitle | 补货 · {drug} | Restock · {drug} | 補充 · {drug} | sheet 标题 |
| inventoryRestockCurrentLabel | 当前 | Current | 現在 | sheet 字段 |
| inventoryRestockDeltaLabel | 今日补 | Add | 今日補充 | sheet 字段 |
| inventoryRestockNoteLabel | 备注（可选） | Note (optional) | メモ（任意） | sheet 字段 |
| inventoryRestockSubmit | 记入 | Record | 記録 | sheet primary |
| inventoryLowStockNotifyTitle | 低库存提醒 | Low stock alert | 在庫不足通知 | 通知卡标题 |
| inventoryLowStockNotifyDesc | 剩余 ≤ {days} 天时通知。 | Notify when ≤ {days} days. | 残り {days} 日以下で通知。 | 副述 |
| inventoryEmptyTitle | 本期空白。 | Empty. | まだなし。 | 空态 |
| inventoryEmptyMessage | 尚未启用任何药物。 | No active medications. | 服薬予定が未設定。 | 空态副行 |

---

## 7. Drug list / Schedule editor / Add drug（来源：drug-list/handoff.md §4 + schedule-editor/handoff.md §2 + add-drug/spec.md §10）

| key | zh | en | ja | 用途 |
|-----|-----|-----|-----|------|
| drugSectionActive | 活跃 | Active | 服用中 | section |
| drugSectionInactive | 已停用 | Inactive | 停止中 | section |
| drugSectionRecentlyDeleted | 最近删除 | Recently deleted | 最近削除 | section |
| drugCountSummary | 共 {total} 味　·　活跃 {active} 味 | {total} total · {active} active | 全 {total} 件　·　服用中 {active} 件 | hero 副行 |
| drugAddNew | 添加新药 | Add medication | 新規追加 | 屏底 primary |
| drugEdit | 编辑 | Edit | 編集 | bottom-sheet 选项 |
| drugDeactivate | 停用 | Deactivate | 停止 | bottom-sheet 选项 |
| drugRestore | 恢复 | Restore | 復元 | bottom-sheet 选项 |
| drugDelete | 删除 | Delete | 削除 | bottom-sheet 选项 |
| drugDeletePermanent | 永久删除 | Delete permanently | 完全削除 | bottom-sheet 选项 |
| drugDeleteConfirmTitle | 删除 {name}？ | Delete {name}? | {name} を削除？ | dialog 标题 |
| drugDeleteConfirmMessage | 删除后 7 日内可恢复。\n仍要继续？ | Recoverable for 7 days.\nContinue? | 7 日以内なら復元可。\n続けますか。 | dialog body |
| drugPermanentDeleteConfirmTitle | 永久删除 {name}？ | Permanently delete {name}? | {name} を完全削除？ | dialog |
| drugPermanentDeleteConfirmMessage | 永久删除后不可恢复。 | Cannot be undone. | 戻せません。 | dialog body |
| drugDeactivateConfirmTitle | 停用 {name}？ | Deactivate {name}? | {name} を停止？ | dialog |
| drugDeactivateConfirmBody | 不会从历史中删除。 | Will not be removed from history. | 履歴からは消えません。 | dialog body |
| drugDeactivated | 已停用 {name} | Deactivated {name} | {name} を停止 | snackbar |
| drugDeletedSoft | 已删除 {name}，7 日内可恢复 | Deleted {name}, recoverable 7 d | {name} を削除、7 日以内なら復元 | snackbar |
| drugRestored | 已恢复 {name} | Restored {name} | {name} を復元 | snackbar |
| drugDeletedPermanent | 已永久删除 {name} | Permanently deleted {name} | {name} を完全削除 | snackbar |
| drugListEmptyTitle | 无药记录。 | No medications. | 薬剤なし。 | 空态 |
| drugListEmptyMessage | 添加你的第一味药品。 | Add your first medication. | 最初の一味を加える。 | 副行 |
| scheduleEditorTitle | 时间表。 | Schedule. | 予定表。 | hero（替换 editDrug） |
| dosageSection | 剂量 | Dose | 用量 | section |
| frequencySection | 频率 | Frequency | 頻度 | section |
| frequencyDailyTitle / Desc | 每日 / 每天的同一时段。 | Daily / Same time daily. | 毎日 / 毎日同じ時刻。 | 频率卡 |
| frequencyEveryNDaysTitle / Desc | 隔日 / 每两日记一次。 | Every N days / Once every two days. | 隔日 / 二日ごとに一回。 | 频率卡 |
| frequencyWeeklyTitle / Desc | 特定星期 / 仅在选中的星期。 | Specific days / Selected weekdays only. | 特定の曜日 / 選んだ曜日のみ。 | 频率卡 |
| scheduleTimesSection | 时段 | Times | 時刻 | section |
| scheduleTimeLabelMorning / Noon / Evening / Night | 早 / 午 / 晚 / 夜 | AM / Noon / PM / Late | 朝 / 昼 / 夜 / 深夜 | 4 个时段 label |
| scheduleEditorAddTime | + 添加时段 | + Add time | + 時刻を追加 | ghost 按钮 |
| scheduleEditorRemoveTime | 删除 | Remove | 削除 | ghost 按钮 |
| scheduleConflictHint | 与上一时段相隔不足 4 小时。 | Less than 4 hours from previous. | 前の時刻と 4 時間未満です。 | inline 警告 |
| dateRangeSection | 起止 | Range | 期間 | section |
| dateNotSet | 未定。 | Not set. | 未定。 | 替换 noEndDate |
| notificationSection | 通知 | Notify | 通知 | section |
| notificationDesc | 到时静默推送。 | Silent push at time. | 時刻に静かに通知。 | section 副述 |
| weekdayShort1..7 | 一二三四五六日 | M T W T F S S | 月火水木金土日 | 7 个 weekday short |
| celebrationScheduleSaved | 时间表已记。 | Schedule saved. | 予定を記しました。 | celebration |
| addDrugErrorMissingName / Category / Route | 请输入药名 / 请选择类别 / 请选择给药途径 | Name required / Category required / Route required | 薬名が必要 / 類別が必要 / 投与経路が必要 | inline error |
| addDrugCategoryHelper | 可在记完后修改。 | Editable after saving. | 後で変更可。 | helperText |
| addDrugAliasLabel | 别名 | Alias | 別名 | input label（rename from genericName） |
| addDrugDosageLabel | 默认剂量 | Default dose | 既定量 | input label |
| addDrugStartDate / EndDate | 起始日 / 结束日 | Start date / End date | 開始日 / 終了日 | date picker label |
| addDrugTemplateTitle | 翻药册 | Browse templates | 薬冊を開く | 模板 sheet 标题（替换 drugTemplateTitle） |

---

## 8. Profile 屏（来源：profile/spec.md §3 + §9）

| key | zh | en | ja | 用途 |
|-----|-----|-----|-----|------|
| profileTitle | 我的 | Profile | プロフィール | top bar |
| profileNoName | 无名 | Anonymous | 無名 | hero fallback |
| profileHrtSub | HRT 第 {n} 天　·　起始 {date} | HRT day {n}　·　since {date} | HRT 第 {n} 日　·　{date} から | hero 副行 |
| profileSectionData | 数据 | Data | データ | section |
| profileSectionPrivacy | 隐私 | Privacy | プライバシー | section |
| profileSectionPreferences | 偏好 | Preferences | 設定 | section |
| profileSectionAbout | 关于 | About | このアプリ | section |
| profileItemAppLock | 应用锁 | App Lock | アプリロック | list item |
| profileItemBiometric | 生物识别 | Biometric | 生体認証 | list item |
| profileItemNotifications | 通知 | Notifications | 通知設定 | list item |
| profileItemWipeAll | 清除所有数据 | Clear All Data | すべてのデータを削除 | destructive item |
| profileItemCheckUpdate | 检查更新 | Check for Update | 更新を確認 | list item |
| profileItemCheckUpdateSub | 上次：{date} | Last: {date} | 最終：{date} | subtitle |
| profileItemStorage | 存储用量 | Storage | 容量 | list item |
| profileItemStoragePending | — | — | — | 占位（CubitState 暂未暴露 storageUsage 时） |
| profileItemSignOut | 退出 | Sign out | サインアウト | bottom button |
| profileSignOutConfirmTitle | 退出登录？ | Sign out? | サインアウト？ | sheet 标题 |
| profileExportLastBackup | 上次：{date} | Last: {date} | 最終：{date} | trailingText |

---

## 9. copy-revisions 改值 key（80 个，仅改 value 不动 schema）

完整清单见 `docs/design/ux-copy-v2/copy-revisions.md` §1-§7 七类 80 keys。这些 key **保留 schema 不动**（包括 `@@locale`、`@key` metadata、`placeholders` 字段），只改 value 字符串。建议拆 3 个 PR：
- PR-A1：P0 修复（`confirmPassword` zh 简繁笔误 + `simulatorDisclaimer` 三语长度 drift）
- PR-A2：80 keys 三语调性对齐（按 §1-§7 分批）
- PR-A3：P2 重复定义清理（`notificationSettings` / `medicationReminders` / `myGrowthTrajectory` 等）

---

## 10. 同步策略

- **ARB 改动建议拆为独立 PR-A**（与 domain fix 同优先级，不要混进 UI PR）
- 三语并行修改，**不允许只加 zh**；未提供 ja 翻译的暂用 `[zh]` placeholder + 注释 `// TODO: ja translation pending`
- 每次 ARB 改动后必须跑 `flutter gen-l10n` 重生成 `app_localizations*.dart`，**不要手改生成文件**（CLAUDE.md 铁律 #4 不动生成文件）
- 现有 323 个测试中含 i18n smoke test 与文案断言，修改后 widget test 需同步更新断言
- 涉及 `{count}` / `{drugName}` / `{message}` / `{time}` 等 placeholder 的 key（如 `saveFailed`、`importSuccess`、`updateEstimatedTime`）必须保留对应占位符不删

---

## 11. 已 deprecated 但保留 1 版本灰度的旧 key 清单

按 spec / handoff 明示"保留 1 版本灰度"的 key（不在 v2 重设计 PR 中删除，下一版本（v1.2 或 v2.1）清理）：

- **today**: 现有 today 屏的 v1 key（具体清单 today/spec.md 未列举，参考 today_page.dart 当前 ARB 引用）
- **schedule-editor**: `editDrug` / `frequency` / `daily` / `everyNDays` / `weekly` / `scheduleTimes` / `selectDate` / `noEndDate` / `endDateOptional`（schedule-editor/handoff.md §2 ARB 段末注）
- **inventory**: `lowStock` / `daysLeft` / `noActiveDrugs` / `inventoryDataUnavailable` / `inventoryUpdateHint` / `inventoryDaysRemaining` / `inventoryComingSoon`（inventory/handoff.md §2 ARB 段末注）
- **add-drug**: `drugCustomAdd`（add-drug/handoff.md §3.2 — 标记三语全删，但 release 阶段先 deprecate 不删）
- **record**: `recordFooter`（copy-revisions §1 行末标 deprecate；record/spec.md §8 注 "deprecate `recordFooter`"）
- **重复 / 冗余 key**（copy-revisions §8 P2）：`notificationSettings` / `medicationReminders` 各定义 2 次（145 / 283 行附近）；`daysLeft` ≡ `inventoryDaysRemaining`；`addFirstDrug` ≡ `addFirstDrugCta` ≡ `onboardingAddDrug`（zh/ja 完全相同）；`myGrowthTrajectory` en ARB 重复定义且翻译略不同（journey vs trajectory）

---

— 完 —
