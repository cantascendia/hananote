# Phase 2.2 UX Copy 复盘 — 高优先级 i18n Key 清单

**版本**: v1.2.2 已上架基线 | **覆盖范围**: 80 keys / 约 510 总 keys (≈16%)
**调性目标**: 温柔守护者(gentle guardian) — 待新调性方案确认前作为复盘基准
**ARB 源文件**: `lib/core/l10n/arb/app_{en,zh,ja}.arb`
**审阅日期**: 2026-04-28

---

## 1. Onboarding / first-impression（15 keys）

用户首启动 4 屏 + PIN 创建 + 解锁回访 — 决定留存的"前 90 秒文案"。

| key | 当前 zh | 当前 en | 当前 ja | 出现位置 | 为何高优 | 跨语 drift |
|-----|--------|--------|--------|---------|---------|-----------|
| onboardingWelcome | 欢迎来到 HanaNote | Welcome to HanaNote | HanaNote へようこそ | onboarding_page.dart | 首启第 1 屏标题，定调全局 | OK |
| onboardingWelcomeSub | 你的私密 HRT 健康记录空间 | Your private HRT health journal | あなたのプライベート HRT 健康ノート | onboarding_page.dart | 首启价值主张 sub | zh "记录空间" vs en "journal" vs ja "ノート" — 三个不同的隐喻 |
| onboardingSetName | 你想被怎么称呼？ | What should we call you? | あなたの呼び名は？ | onboarding_page.dart | 第 2 屏 — 关键身份触发点（跨性别用户对名字极敏感） | zh/en 用问句友好，ja 较生硬可优化 |
| onboardingNameHint | 可以是昵称或别名 | Nickname or alias | ニックネームでも OK | onboarding_page.dart | 化解"必须用真名"焦虑 | zh "或别名" 暗含 deadname 焦虑，ja "OK" 偏轻松 — 调性不一 |
| onboardingNameNote | 随时可以在设置中修改 | Editable later in Settings | 後で設定から変更できます | onboarding_page.dart | 给"反悔权" — 跨性别社群对此非常重要 | OK |
| onboardingSetHrtDate | 你的 HRT 起始日是？ | When did you start HRT? | HRT 開始日は？ | onboarding_page.dart | 第 3 屏 — HRT 周年日是社群仪式感关键节点 | OK |
| onboardingSkipHrt | 稍后设置 | Set later | 後で設定 | onboarding_page.dart | 给"不知道精确日期"用户出口 | OK |
| onboardingAddDrug | 添加你的第一种药物 | Add your first medication | 最初のお薬を追加 | onboarding_page.dart | 第 4 屏 — 转化为留存的关键 CTA | ja "お薬" 用了敬语前缀 vs zh/en 中性 |
| onboardingDone | 开始使用 | Get Started | 始める | onboarding_page.dart | 完成 onboarding 收尾按钮 | OK |
| welcomeBack | 欢迎回来 | Welcome back | おかえりなさい | lock_screen_page.dart | 每次解锁第一句话（高频） | ja "おかえりなさい" 温度最高，zh/en 较平 |
| setupSecurePassword | 创建安全密码 | Create Secure Password | セキュアパスワードを作成 | setup_page.dart | PIN 创建首屏标题 — 信任感关键 | OK |
| setupPinDescription | 设置 6 位 PIN 以保护你的私密健康数据。 | Set a 6-digit PIN to protect your private health data. | プライベートな健康データを守る6桁PINを設定してください。 | setup_page.dart | 解释"为什么要设密码" — 隐私承诺核心 | OK |
| recordTitle | 今日记录 | Today's Record | 今日の記録 | record_page.dart | Record tab 主标题（每天首触） | OK |
| recordGreeting | 你好，\n今天想留下什么回忆？ | Hello,\nWhat memory would you like to keep today? | こんにちは、\n今日はどんな思い出を残しますか？ | record_page.dart | 每日打开 Record tab 第一句问候 | zh "你好" 较普通；en/ja 用 memory/思い出 — 偏怀旧而非"现在进行时" |
| recordFooter | 每一次记录都是对未来的温柔期许 | Every record is a gentle promise to your future self | 一つ一つの記録が未来への優しい約束 | record_page.dart | Record 页底部 "情书式" 收尾 | OK — 已最贴近"温柔守护者"调性 |

---

## 2. CTA buttons（15 keys）

按钮是用户每次点击的"动作摘要" — 文字直接决定点击意愿。

| key | 当前 zh | 当前 en | 当前 ja | 出现位置 | 为何高优 | 跨语 drift |
|-----|--------|--------|--------|---------|---------|-----------|
| takeDose | 服药 | Take Dose | 服薬 | dose_action_sheet.dart, today_dose_card.dart | 日均按 1-3 次的核心动作 | zh/ja "服药/服薬" 偏医学，en "Take Dose" 中性 |
| skipDose | 跳过 | Skip Dose | スキップ | dose_action_sheet.dart | 跳过药物时易触发愧疚情绪 — 文案需要更温柔 | zh "跳过" 太冷，en "Skip Dose" 也无情绪缓冲 |
| save | 保存 | Save | 保存 | 全局 (40+ 处) | 全 app 最高频按钮 | OK |
| cancel | 取消 | Cancel | キャンセル | 全局 (30+ 处) | 全 app 第二高频 | OK |
| confirm | 确认 | Confirm | 確認 | 全局 dialog 确认 | 删除/重要操作 confirm 文字 | OK |
| delete | 删除 | Delete | 削除 | drug_list, photo, measurement | 破坏性操作 — 文案应让用户三思 | OK 但偏冷淡 |
| addDrug | 添加药物 | Add Medication | 薬を追加 | drug_list_page.dart, today_page.dart | 用药管理入口 — drug vs medication 差异 | en "Medication" vs zh/ja "药物/薬" — 严重 drift（en 更软） |
| addPhoto | 添加照片 | Add Photo | 写真を追加 | photo_page.dart | 加密相册主 CTA | OK |
| addBloodTest | 添加验血报告 | Add blood test | 血液検査を追加 | timeline_page.dart, data_page.dart | 关键数据入口 | en 小写 "blood test" vs zh/ja 标题式 — 大小写 drift |
| addReport | 添加报告 | Add report | レポートを追加 | data_page.dart | 数据 tab 主 CTA | OK |
| onboardingNext | 下一步 | Next | 次へ | onboarding_page.dart | 4 屏 onboarding 每屏都有 | OK |
| onboardingDone | 开始使用 | Get Started | 始める | onboarding_page.dart | 完成按钮 — 决定首次留存的最后一步 | OK |
| exportBackup | 导出备份 | Export backup | バックアップを書き出す | profile_page.dart | 数据控制权关键操作 | en 小写偏低调 |
| importBackup | 导入恢复 | Import backup | バックアップを読み込む | profile_page.dart | 跨设备迁移关键 | zh "导入恢复"语义稍重复 |
| updateNow | 立即更新 | Update Now | 今すぐ更新 | update_dialog.dart | 更新弹窗主按钮 | OK |

---

## 3. Error / failed messages（10 keys）

错误文案是用户最焦虑时刻看到的 — "温柔守护者"调性最关键的考验。

| key | 当前 zh | 当前 en | 当前 ja | 出现位置 | 为何高优 | 跨语 drift |
|-----|--------|--------|--------|---------|---------|-----------|
| error | 错误 | Error | エラー | 全局 fallback | 通用错误 banner 标题 | OK 但太冷漠 |
| errorFallbackTitle | 出了点问题 | Something went wrong | 問題が発生しました | error_fallback_page.dart | App 崩溃后的兜底页第一句 — 信任修复关键 | zh "出了点问题"最温柔，ja "問題が発生" 偏正式 |
| errorFallbackDescription | 请重新打开应用。如果问题持续存在，请联系支持。 | Please reopen the app. If the problem continues, contact support. | アプリを再起動してください。問題が続く場合はサポートへ連絡してください。 | error_fallback_page.dart | 教用户怎么自救 | OK |
| saveFailed | 保存失败：{message} | Save failed: {message} | 保存に失敗しました：{message} | 多处 cubit | 用户最讨厌的"白干一场"提示 | OK |
| loadFailed | 加载报告失败 | Failed to load report | レポートの読み込みに失敗しました | blood_test_edit_page | 编辑页打开失败 — 数据焦虑触发点 | OK |
| exportFailed | 导出失败，请重试 | Export failed | エクスポートに失敗しました | profile_page.dart | 备份失败 — 数据安全感破裂 | zh 多了"请重试"指引，en/ja 没有 — drift |
| pdfFailed | PDF 生成失败 | PDF generation failed | PDF 生成失敗 | profile_page.dart | 看医生时报告生成失败的尴尬场景 | ja 太短不像句子 |
| importFailed | 导入失败 | Import failed | インポート失敗 | profile_page.dart | 迁移设备时失败 — 数据丢失焦虑 | ja 同上太短 |
| pinMismatch | 两次输入的密码不一致 | PINs do not match | PINが一致しません | setup_page.dart | PIN 创建时高频出现 — 挫败感 | OK |
| invalidValue | 请输入有效数字 | Enter a valid number | 有効な数値を入力してください | blood_test_edit_page | 血检数值输入校验（高频） | OK |

---

## 4. Empty states（10 keys）

空状态是"什么都没有"的时刻 — 文案决定用户是关闭 app 还是开始第一条记录。

| key | 当前 zh | 当前 en | 当前 ja | 出现位置 | 为何高优 | 跨语 drift |
|-----|--------|--------|--------|---------|---------|-----------|
| noActiveDrugs | 暂无启用药物 | No active medications | 有効な薬がありません | drug_list_page.dart | Today tab 无药状态 — 留存关键 | OK |
| noTimelineEvents | 暂无时间线事件 | No timeline events yet | タイムラインの記録がありません | timeline_page.dart | Timeline tab 空 — 缺乏行动指引 | OK 但都缺 CTA |
| noBloodTestHistory | 暂无血检历史记录 | No blood test history yet | 血液検査の履歴がありません | data_page.dart | 数据 tab 空 — 鼓励第一次录入 | OK |
| photoEmptyTitle | 还没有加密照片 | No encrypted photos yet | まだ暗号化写真がありません | photo_page.dart | 加密相册空 | OK |
| photoEmptyDescription | 你的照片经过端到端加密，只有你能看到。 | Your photos are end-to-end encrypted. Only you can see them. | 写真はエンドツーエンドで暗号化され、あなただけが閲覧できます。 | photo_page.dart | E2E 信任承诺 | OK |
| recordDiaryEmpty | 开始你的第一篇日记 | Start your first diary entry | 最初の日記を書こう | record_page.dart | 邀请第一次写日记 | ja "書こう" 鼓励语，zh/en 较中性 — drift |
| recordPhotoEmpty | 还没有拍照记录 | No photo records yet | 写真記録はまだありません | record_page.dart | Record 页照片卡空态 | OK |
| recordMeasureEmpty | 还没有测量记录 | No measurement records yet | 測定記録はまだありません | record_page.dart | Record 页测量卡空态 | OK |
| measurementEmptyHint | 保存第一条测量后，这里会显示围度和体重的历史变化。 | After your first measurement, you'll see your history here. | 最初の測定を保存すると、ここに履歴が表示されます。 | measurement_page.dart | 解释"做了之后看到什么" | zh 提到"围度和体重"具体，en/ja 含糊 — drift |
| noTrendData | 暂无趋势数据 | No trend data yet | トレンドデータなし | data_page.dart | 趋势图无数据态 | OK |

---

## 5. Confirmation dialogs（10 keys）

破坏性操作的"确认弹窗" — 文案是数据安全感的最后防线。

| key | 当前 zh | 当前 en | 当前 ja | 出现位置 | 为何高优 | 跨语 drift |
|-----|--------|--------|--------|---------|---------|-----------|
| confirmDeleteDrug | 确定删除这种药物吗？此操作不可撤销。 | Delete this medication? This cannot be undone. | この薬を削除しますか？この操作は取り消せません。 | drug_list_page.dart | 删药 — 服药历史会断链 | OK |
| wipeAllDataTitle | 清除全部数据 | Wipe all data | すべてのデータを削除 | profile_page.dart | 核选项 — 用户最严重的不可逆操作标题 | OK |
| wipeAllDataMessage | 此操作会永久删除应用中的所有加密数据，且无法恢复。 | This will permanently delete all encrypted app data and cannot be undone. | アプリ内の暗号化データをすべて完全に削除します。元に戻せません。 | profile_page.dart | 描述后果 — 应该比当前更"刺痛" | OK |
| photoDeleteTitle | 删除照片 | Delete photo | 写真を削除 | photo_view_page.dart | 删一张加密身体照（极敏感） | en "photo" 小写偏轻 |
| photoDeleteMessage | 这将同时删除加密文件和记录。 | This will delete the encrypted file and its record. | 暗号化ファイルと記録を同時に削除します。 | photo_view_page.dart | 解释"文件 + 记录"双删 | OK |
| deleteMeasurementTitle | 删除测量记录 | Delete Measurement | 測定記録を削除 | measurement_page.dart | 删一条围度数据 | OK |
| deleteMeasurementConfirm | 确认删除这条身体测量记录吗？ | Delete this body measurement record? | このボディ測定記録を削除しますか？ | measurement_page.dart | 删除二次确认 | OK |
| importConfirmTitle | 确认导入？ | Import data? | インポートを実行？ | profile_page.dart | 导入备份前 — 可能覆盖现有数据 | OK |
| importConfirmMessage | 导入会把备份数据合并到现有记录中，相同 ID 的条目可能被覆盖。 | This will add backup data to your existing records. Existing items with matching IDs may be overwritten. | バックアップを既存データに統合します。同じ ID の項目は上書きされる可能性があります。 | profile_page.dart | 解释"合并 vs 覆盖"语义 | OK 但"ID"对小白用户费解 |
| importConfirmAction | 导入 | Import | インポート | profile_page.dart | 导入弹窗主按钮 | OK |

---

## 6. Status / progress text（10 keys）

加载/进行中文案 — 用户等待时看到的"app 还活着"信号。

| key | 当前 zh | 当前 en | 当前 ja | 出现位置 | 为何高优 | 跨语 drift |
|-----|--------|--------|--------|---------|---------|-----------|
| loading | 加载中... | Loading... | 読み込み中... | 全局 (50+ 处) | 全 app 最高频状态 | OK |
| exportInProgress | 正在导出数据... | Exporting data... | データをエクスポート中... | profile_page.dart | 备份等待时 — 数据安全期待感 | OK |
| importInProgress | 正在导入... | Importing... | インポート中... | profile_page.dart | 导入等待 | OK |
| pdfGenerating | 正在生成 PDF... | Generating PDF... | PDF 生成中... | profile_page.dart | 看病前 PDF 等待焦虑 | OK |
| downloadingUpdate | 正在下载更新... | Downloading update... | アップデートをダウンロード中... | update_dialog.dart | 更新等待 | OK |
| updateChecking | 正在检查更新... | Checking for updates... | 更新を確認中... | update_dialog.dart | 检查更新瞬间 | OK |
| todayCompleted | 今日已完成 ✅ | Completed for today ✅ | 今日は完了 ✅ | today_page.dart | 今日所有药打勾的成就时刻 | en "Completed for today" 最完整，ja "今日は完了" 偏平 |
| pdfSuccess | PDF 已生成 | PDF generated | PDF を生成しました | profile_page.dart | 看病报告完成的喜悦 | en 太短不像反馈，ja 最完整 |
| exportSuccess | 数据已导出 | Data exported successfully | データのエクスポートが完了しました | profile_page.dart | 备份成功的安全感 | drift — en 多了 "successfully"，zh/ja 都没有 |
| measurementRecorded | 已记录一次身体测量 | Measurement recorded | 測定を記録しました | measurement_page.dart | 测量保存成功 toast | zh 多了 "一次"，en/ja 没有 |

---

## 7. Legal / sensitive（10 keys）

隐私/法律/生物识别 — "你能不能信任这个 app" 的核心证据。

| key | 当前 zh | 当前 en | 当前 ja | 出现位置 | 为何高优 | 跨语 drift |
|-----|--------|--------|--------|---------|---------|-----------|
| privacyPolicy | 隐私政策 | Privacy Policy | プライバシーポリシー | profile_page.dart, legal_page.dart | 法律入口 | OK |
| termsOfUse | 使用条款 | Terms of Use | 利用規約 | profile_page.dart, legal_page.dart | 法律入口 | OK |
| privacyPolicyContent | (8 节长文) | (8 sections) | (8 sections) | legal_page.dart | 隐私政策正文 — 信任根基 | OK 但日期硬编码 "2026年4月"，三语都需要更新机制 |
| termsOfUseContent | (9 节长文) | (9 sections) | (9 sections) | legal_page.dart | 服务条款正文 | 同上 — 日期硬编码 |
| simulatorDisclaimer | (PK 模拟器免责声明，120字) | (Disclaimer for PK simulator, 200 chars) | (PK シミュレーター免責、80字) | simulator_page.dart | 关键医疗免责 — 法律风险点 | en 字数最长，ja 最短 — 信息密度严重 drift |
| privacySecurity | 隐私与安全 | Privacy & Security | プライバシーとセキュリティ | profile_page.dart | 设置入口标题 | OK |
| privacyMode | 隐私模式 | Privacy mode | プライバシーモード | settings_detail_page | 隐藏最近任务截图 — 跨性别用户高需求 | OK |
| privacyModeEnabled | 最近任务中隐藏应用内容 | Hide app content in recents | 最近使ったアプリで内容を隠す | settings_detail_page | 解释隐私模式开效果 | OK |
| enableBiometric | 启用后使用生物识别 | Enable biometric unlock | 生体認証を有効にする | setup_page.dart | 生物识别开关 — 跨性别用户对面部解锁有顾虑 | zh "启用后使用" 语义打折，en/ja 更直接 |
| wipeAllData | 清除全部数据 | Wipe all data | すべてのデータを削除 | profile_page.dart | 设置项入口（核选项） | OK |

---

## 问题清单（跨语言 drift / 错译 / 长度差异）

按严重程度排序：

1. **CRITICAL — `confirmPassword` 中文错字**: `app_zh.arb` 第 374 行 `"確認密码"` 用了繁体"確認"+ 简体"密码"，明显笔误，应为"确认密码"。
2. **HIGH — `simulatorDisclaimer` 信息密度严重 drift**: en (~280 chars) > zh (~120 chars) > ja (~110 chars)。en 提到 "individual differences (metabolism, weight, injection site fat ratio)"，zh/ja 也提到，但 en 多了一层"具体后果"语气。法律免责场景，信息缺失即风险。
3. **HIGH — `addDrug` 用词不一致**: en `"Add Medication"`(软) vs zh `"添加药物"`(硬) vs ja `"薬を追加"`(中)。 "medication" 是温柔守护者调性的关键词，zh/ja 应改"用药/お薬"。
4. **HIGH — `onboardingWelcomeSub` 隐喻分裂**: zh "记录空间" / en "journal" / ja "ノート"。三个 metaphor 给三种不同的产品定位印象。建议三语统一到"健康日记/journal"调性。
5. **MEDIUM — `recordGreeting` zh "你好" 太普通**: en/ja 用 "Hello/こんにちは" 更暖。zh 可考虑"嗨" 或保留"你好" + 时段问候组合。
6. **MEDIUM — `everyPrefix` ja 留空字符串**: `app_ja.arb` 第 174 行 `"everyPrefix": ""`，因日语语法不需要"每隔"前缀，靠 `daySuffix" 日"` 表达。这是合理的本地化但需文档说明。
7. **MEDIUM — `exportFailed` 指引不一**: zh "导出失败，请重试" 给指引；en "Export failed" / ja "エクスポートに失敗しました" 不给指引。决定上要么三语都给要么都不给。
8. **MEDIUM — `pdfFailed` / `importFailed` 中日太短**: ja "PDF 生成失敗"/"インポート失敗" 像名词标题，不像完整句子，与 zh/en 的句式不对应。
9. **MEDIUM — `exportSuccess` "successfully" 只在 en**: en 多了 "successfully" 副词，zh/ja 没有 — 三语 reassurance 强度不一致。
10. **LOW — `notificationSettings` / `medicationReminders` 在 ARB 中重复定义**: en/zh/ja 三个文件中两个 key 都各定义了 2 次（第 145 行附近 + 第 283 行附近）。技术债，build_runner 会取后者。建议清理。
11. **LOW — `daysLeft` / `inventoryDaysRemaining` 完全相同**: 两个 key zh/en/ja 都译成同样的 "剩余 {days} 天"。重复定义，应合并 key。
12. **LOW — `addFirstDrug` / `addFirstDrugCta` / `onboardingAddDrug` 文案重叠**: 三个 key 在 zh/ja 都译成"添加你的第一种药物/最初の薬を追加"，仅 en 略有差异（first medication）。建议合并。
13. **LOW — `myGrowthTrajectory` 在 en ARB 中重复定义但翻译略不同**: en 一处 "My Growth Journey" 一处未列出（zh "我的成长轨迹" / ja "私の成長記録"）— 隐喻 drift（journey vs trajectory vs 記録）。
14. **LOW — `holdTimeVeryFast/Casual` 调性偏离**: ja "極速/適当" 偏口语，en "Very fast/Casual" 偏正式，zh "极快/随意" 居中。PK 模拟器是医疗严肃场景，三语应更正式。

---

## 建议覆盖 + 调研重点（阶段 -1 用户访谈）

基于 80 keys 的分布，建议团队在用户访谈中重点观察以下场景，按情绪权重排序：

### 优先级 P0 — 身份与信任时刻

1. **首次启动 4 屏（Onboarding 1-4）+ 第一次设 PIN**: 看用户在"你想被怎么称呼？"屏的反应 — 是否犹豫、是否反复修改、是否担心日后被锁定。建议让用户朗读"setupPinDescription"和 "onboardingNameNote"，听他们解释自己的理解；这是检验"温柔守护者"调性是否落地的关键 60 秒。
2. **删除照片 / 清除全部数据弹窗**: 让用户走到 `wipeAllDataMessage` 和 `photoDeleteMessage` 弹窗的那一刻（不实际执行），观察犹豫时长、再次点开的次数。文案是否给了"安心点击/安心取消"两条情绪通道？
3. **PIN 输入错误 / 不匹配（pinMismatch）**: 故意让用户输错两次 PIN，观察其挫败反应；当前文案 "两次输入的密码不一致" 是否带歉意？

### 优先级 P1 — 日常高频时刻

4. **每日打开 Today + Record tab 第一秒**: `welcomeBack` + `recordTitle` + `recordGreeting` 是用户每天首触的三层文案。访谈中追问"如果你看到这句话，会觉得 app 在跟你说什么？"
5. **服药 / 跳过药物（takeDose / skipDose）**: 重点观察"跳过"场景的情绪 — 跨性别用户对漏服 HRT 有强烈愧疚，"跳过" 二字是否需要更温柔（如"今天先不"、"延后"）？
6. **空状态首遇时刻**: 让用户进入 Timeline、Photo、Data 等空 tab，看他们能否从 empty state 文案判断"下一步该做什么"。当前 10 个 empty states 普遍缺少 CTA 引导。

### 优先级 P2 — 高焦虑时刻

7. **错误兜底页（errorFallbackTitle）**: 故意触发 app 异常重启，看用户读到 "出了点问题" 时的情绪 — 是放心还是更慌？对比 zh/en/ja 三语温度差异。
8. **导出 / 导入 / PDF 生成**: 三个流程都有 inProgress + Success + Failed 三态，让用户在弱网环境下走完完整流程，记录每一态文案的接受度。备份场景关联"换设备"的迁移焦虑，是品牌承诺的高赌注时刻。
9. **隐私政策 / 服务条款页**: 让用户进入 legal_page，观察滚动深度。当前隐私政策第 1 节"数据存储"是品牌差异化的最大资产，调研用户是否真的读到、是否相信"本地存储"的承诺。

### 调研问卷必问题（基于上述高优 keys 设计）

- "如果一个 HRT app 在你第一次打开时说 [onboardingWelcomeSub 三语候选]，你会觉得它是 ___ 类型的产品？"（隐喻测试 — 验证 journal vs 记录空间 vs ノート 的差异）
- "[skipDose] 这个按钮如果换成 [候选 4 个：跳过 / 今天先不 / 延后 / 暂跳]，你会更愿意点哪个？为什么？"
- "在 [wipeAllDataMessage] 弹窗中，你最希望看到 app 提到什么？"（验证是否需要加倒计时、二次输入 PIN 等仪式感）
- "[recordFooter] 让你想到了什么？" — 这是当前最贴近"温柔守护者"调性的文案，可作为新调性基线参考。

### 输出建议

复盘后生成：
1. **温柔守护者调性词库 v1**（替代 dailyQuote 12 条 + recordGreeting + onboardingWelcomeSub 等 ~25 keys 作为调性锚点）
2. **三语统一性 lint 规则**（针对上述问题清单的 #1-#5 自动化检测）
3. **空状态 CTA 模板**（针对 10 个 empty states 补全"下一步动作"指引）

---

**报告字数**: 约 1380 字（不含表格）| **覆盖 keys**: 80 个 | **问题清单**: 14 项
