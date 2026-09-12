# HanaNote v2 UX Copy Revisions

> Generated 2026-04-28 from DESIGN.md v2 + high-priority-keys.md
> 共 80 keys 跨 7 类
> 工程师按这份 markdown 改 ARB 文件即可（保持 ARB schema 不变，只改 value；带 `{count}`、`{drugName}` 等 placeholders 的 key 必须保留原占位符）
> 调性宪法：候选 A「编辑级东亚」§7 — 克制 / 第三人称编辑视角 / 句号收尾 / 零 emoji / 「敬」而非「哄」

---

## 方法

候选 A §7 给了 3 个对照锚点（服药 CTA「记一次」、空态「尚未起笔」、删除确认「删除后不可恢复。」）。本文剩余 77 个候选**原创但与锚点同源**——遵守同一调性，不照抄。

每条修订给具体动作而非空话：「由感叹号改陈述号」「去掉敬语前缀『お』」「删除『请』『可以』『仅』等弱化词」「改第二人称鼓励→第三人称陈述」「具体数字替换抽象副词」。

**长度卡尺**：CTA ≤ 6 字 zh / ≤ 4 单词 en / ≤ 6 字 ja；错误提示 ≤ 20 字；空态 ≤ 30 字（双行允许，但单行 ≤ 18 字）；庆祝 / quote 三五字。

---

## 1. Onboarding / first-impression（15 keys）

首启 4 屏 + PIN + 解锁回访。v1 是「教程 + 鼓励」，v2 是「一本书的扉页与目录」。所有问候去问号、去 emoji、句号收尾。

| key | 现 zh | 现 en | 现 ja | 改 zh | 改 en | 改 ja | 推荐理由 |
|-----|------|------|------|------|------|------|---------|
| onboardingWelcome | 欢迎来到 HanaNote | Welcome to HanaNote | HanaNote へようこそ | HanaNote。 | HanaNote. | HanaNote。 | 去掉「欢迎来到 / Welcome / へようこそ」三语客套，扉页只留产品名 + 句号，新潮文库装幀语法 |
| onboardingWelcomeSub | 你的私密 HRT 健康记录空间 | Your private HRT health journal | あなたのプライベート HRT 健康ノート | 私人健康内刊。仅你可见。 | A private health journal. Only you. | 私的な健康内誌。あなただけに。 | 三语隐喻统一为「内刊 / journal / 内誌」，删除「记录空间 / ノート」分裂；「仅你可见」前置隐私承诺，去掉冗余「あなたのプライベート」 |
| onboardingSetName | 你想被怎么称呼？ | What should we call you? | あなたの呼び名は？ | 你想被怎么称呼。 | What should we call you. | 呼び名を。 | 去问号改陈述（候选 A §10 第 2 屏明示「无问号—杂志 stand-first」）；ja 删除「あなたの」客套，留体言止め |
| onboardingNameHint | 可以是昵称或别名 | Nickname or alias | ニックネームでも OK | 昵称、别名皆可。 | Nickname or alias. | ニックネームでも。 | zh 去「可以是」弱化词，并入句号；en 加句号统一调性；ja 去「OK」轻松感 |
| onboardingNameNote | 随时可以在设置中修改 | Editable later in Settings | 後で設定から変更できます | 设置内随时可改。 | Editable in Settings. | 設定から変更可。 | zh 去「可以」「随时」叠加；en 删 later 冗余；ja 去「できます」敬语，体言止め压短 |
| onboardingSetHrtDate | 你的 HRT 起始日是？ | When did you start HRT? | HRT 開始日は？ | 从哪一天起，你不再是从前的自己。 | The day everything began. | あの日から、あなたは変わった。 | 候选 A §10 第 3 屏指定的「灵魂句」；从「工具型问句」转为「编辑型 stand-first」，把 HRT 起始日从填表升格为仪式 |
| onboardingSkipHrt | 稍后设置 | Set later | 後で設定 | 暂不填。 | Skip for now. | 後で。 | 三语对齐长度；zh「暂不填」比「稍后设置」更克制（不预设「将来一定要设」）；ja 删「設定」冗余 |
| onboardingAddDrug | 添加你的第一种药物 | Add your first medication | 最初のお薬を追加 | 加入第一条用药。 | Add your first dose. | 最初の一服を加える。 | ja 删敬语前缀「お」（候选 A §7 去客套）；en「dose」比「medication」更具体；zh「条」是杂志「条目」语感，避免「种」的医学味 |
| onboardingDone (1) | 开始使用 | Get Started | 始める | 翻开。 | Open. | 開く。 | 候选 A §10 第 1 屏明示按钮「翻开」；从动词命令式「Get Started」改名词性「Open」，与扉页隐喻闭合 |
| welcomeBack | 欢迎回来 | Welcome back | おかえりなさい | 你回来了。 | You're back. | 戻りました。 | 三语等温——v1 ja「おかえりなさい」温度过高失衡，统一为陈述式「事实 + 句号」，第三人称编辑视角 |
| setupSecurePassword | 创建安全密码 | Create Secure Password | セキュアパスワードを作成 | 设定密码。 | Set a passcode. | 暗証番号を設定。 | en「passcode」比「Secure Password」更准确（实际是 6 位 PIN）；zh 去「安全」赘词；ja 去外来语「セキュアパスワード」改本地「暗証番号」 |
| setupPinDescription | 设置 6 位 PIN 以保护你的私密健康数据。 | Set a 6-digit PIN to protect your private health data. | プライベートな健康データを守る6桁PINを設定してください。 | 6 位数字。仅本机可解。 | Six digits. Local only. | 6 桁。この端末のみ。 | 把「保护隐私」抽象承诺改为具体技术事实「仅本机可解 / Local only / この端末のみ」，更可信；ja 去「ください」过度敬语 |
| recordTitle | 今日记录 | Today's Record | 今日の記録 | 今日。 | Today. | 今日。 | 极简化——v2 杂志风「一字成章」；候选 A §9 Today 屏顶部 hero 仅用大字一词 |
| recordGreeting | 你好，\n今天想留下什么回忆？ | Hello,\nWhat memory would you like to keep today? | こんにちは、\n今日はどんな思い出を残しますか？ | 今日，写一行。 | One line for today. | 今日、一行。 | 删除「你好 / Hello / こんにちは」普通问候；从「记忆 / memory / 思い出」怀旧词转为「一行」具体动作，编辑指令式 |
| recordFooter | 每一次记录都是对未来的温柔期许 | Every record is a gentle promise to your future self | 一つ一つの記録が未来への優しい約束 | 写下，便不会忘记。 | What you write, you keep. | 書けば、残る。 | 删除「温柔期许 / gentle promise / 優しい」修辞自我感动；改为格言式三段事实；zh 仿《新潮文库》扉页 epigraph |

---

## 2. CTA buttons（15 keys）

按钮 = 用户每次点击的「动作摘要」。CTA 长度卡尺：zh ≤ 6 字 / en ≤ 4 单词 / ja ≤ 6 字。

| key | 现 zh | 现 en | 现 ja | 改 zh | 改 en | 改 ja | 推荐理由 |
|-----|------|------|------|------|------|------|---------|
| takeDose | 服药 | Take Dose | 服薬 | 记一次 | Mark taken | 一回記す | 候选 A §7 锚点：从医学动词「服药 / 服薬」改杂志记录动词「记一次」；en「Take Dose」是命令式，改「Mark taken」（被动陈述） |
| skipDose | 跳过 | Skip Dose | スキップ | 暂不记 | Skip today | 今日は記さず | 「跳过」对漏服 HRT 用户带愧疚冲击；改「暂不记」转为「记录」语义而非「跳过药物」语义，去除道德负担；ja 去外来语 |
| save | 保存 | Save | 保存 | 收存 | Keep | 収める | 「保存 / Save」是工具语言；改「收存 / Keep / 収める」是文具 / 杂志语言（保留、收藏、归档）；同样 4 字符内 |
| cancel | 取消 | Cancel | キャンセル | 不了 | Not now | やめる | 去工具感「取消」；en「Not now」比「Cancel」温度更对（不否定意图，只否定此刻）；ja 去外来语 |
| confirm | 确认 | Confirm | 確認 | 好 | Yes | はい | 极简——确认按钮无需双字「确认 / Confirm」；单字「好 / Yes / はい」陈述同意，杂志记者答复式 |
| delete | 删除 | Delete | 削除 | 删除 | Delete | 削除 | 保持——删除是破坏性操作，必须保留原始动词的重量；不软化是负责 |
| addDrug | 添加药物 | Add Medication | 薬を追加 | 加入用药 | Add medication | 用薬を加える | 解决 high-priority §3 三语 drift；统一「medication / 用药 / 用薬」；ja「用薬」比「薬」更书面 |
| addPhoto | 添加照片 | Add Photo | 写真を追加 | 加入照片 | Add photo | 写真を加える | 三语动词统一为「加入 / Add / 加える」（v1 zh「添加」是工具感，「加入」更杂志栏目感） |
| addBloodTest | 添加验血报告 | Add blood test | 血液検査を追加 | 加入血检 | Add blood test | 血検を加える | 解决 high-priority §3 大小写 drift（en 全保持小写一致）；zh 去「报告」赘词；ja 缩短 |
| addReport | 添加报告 | Add report | レポートを追加 | 加入报告 | Add report | 記録を加える | ja 去外来语「レポート」改「記録」与全局一致；动词统一「加入 / Add / 加える」 |
| onboardingNext | 下一步 | Next | 次へ | 翻页 | Turn page | 次の頁 | 候选 A §10「翻开」隐喻延续；「下一步 / Next」是工具教程；「翻页 / Turn page / 次の頁」是杂志 / 文库语言 |
| onboardingDone (2) | 开始使用 | Get Started | 始める | 翻开 | Open | 開く | 与 onboardingDone (1) 合并语义（high-priority §问题清单 #12 建议合并） |
| exportBackup | 导出备份 | Export backup | バックアップを書き出す | 导出 | Export | 書き出す | 「备份 / backup / バックアップ」在按钮上是冗余（设置项已说明上下文）；缩短为单一动词 |
| importBackup | 导入恢复 | Import backup | バックアップを読み込む | 导入 | Import | 読み込む | zh 去「导入恢复」语义重复（high-priority §2 drift）；与 exportBackup 对称 |
| updateNow | 立即更新 | Update Now | 今すぐ更新 | 更新 | Update | 更新 | 删「立即 / Now / 今すぐ」催促语；陈述按钮即可，无需强调即时性 |

---

## 3. Error / failed messages（10 keys）

错误是用户最焦虑时刻看到的文字。v2 不安抚，只陈述事实 + 给具体下一步。≤ 20 字。

| key | 现 zh | 现 en | 现 ja | 改 zh | 改 en | 改 ja | 推荐理由 |
|-----|------|------|------|------|------|------|---------|
| error | 错误 | Error | エラー | 出现错误 | An error occurred | エラーが発生 | 单字「错误 / Error」太冷；三语都补足为完整短句，与 errorFallbackTitle 对齐；不加「请」「ください」 |
| errorFallbackTitle | 出了点问题 | Something went wrong | 問題が発生しました | 中断了。 | Interrupted. | 中断しました。 | 「出了点问题 / Something went wrong」是道歉语气；改「中断 / Interrupted」事实陈述（编辑视角）；句号收 |
| errorFallbackDescription | 请重新打开应用。如果问题持续存在，请联系支持。 | Please reopen the app. If the problem continues, contact support. | アプリを再起動してください。問題が続く場合はサポートへ連絡してください。 | 重启应用。仍异常，请联系支持。 | Reopen the app. If it persists, contact support. | アプリを再起動。続く場合は連絡を。 | 三语去「请 / Please / ください」客套；用句号断为两段陈述；ja 去「してください」改体言止め，长度对齐 |
| saveFailed | 保存失败：{message} | Save failed: {message} | 保存に失敗しました：{message} | 未能收存：{message} | Couldn't keep: {message} | 収められず：{message} | 与新 save (「收存 / Keep / 収める」) 对应；从「失败 / failed / 失敗」工具感转「未能 / couldn't / ず」陈述；保留 placeholder |
| loadFailed | 加载报告失败 | Failed to load report | レポートの読み込みに失敗しました | 报告未能打开。 | Couldn't open report. | 報告を開けず。 | 三语等长；动词改「打开 / open / 開ける」更日常；ja 体言止め压短 |
| exportFailed | 导出失败，请重试 | Export failed | エクスポートに失敗しました | 导出未完成。 | Export didn't finish. | 書き出し未了。 | 解决 high-priority §3 #7 drift（zh 多「请重试」）；统一为「未完成 / didn't finish / 未了」陈述；不主动叫用户重试（杂志不会催读者） |
| pdfFailed | PDF 生成失败 | PDF generation failed | PDF 生成失敗 | PDF 未能生成。 | PDF didn't generate. | PDF を生成できず。 | 解决 high-priority §3 #8 ja 太短问题；ja 改完整句「生成できず」；三语对齐 |
| importFailed | 导入失败 | Import failed | インポート失敗 | 导入未完成。 | Import didn't finish. | 読み込み未了。 | 同 importFailed 模式；ja 改完整句；与 exportFailed 句式对称 |
| pinMismatch | 两次输入的密码不一致 | PINs do not match | PINが一致しません | 两次不一致。 | The two don't match. | 二度が一致せず。 | 删「输入的密码 / PINs / PIN が」上下文冗余（用户正在 PIN 屏，知道在说什么）；缩短为 5-7 字 |
| invalidValue | 请输入有效数字 | Enter a valid number | 有効な数値を入力してください | 仅限数字。 | Numbers only. | 数値のみ。 | 三语去「请 / ください」；从「Enter / 输入」命令式改「仅限 / only / のみ」陈述限制；血检场景出现频次高，越短越不刺眼 |

---

## 4. Empty states（10 keys）

空态是「还没有开始」的时刻——v1 用圆形图标 + 鼓励文，v2 是杂志的「本期空白」stand-first。≤ 30 字、可双行。

| key | 现 zh | 现 en | 现 ja | 改 zh | 改 en | 改 ja | 推荐理由 |
|-----|------|------|------|------|------|------|---------|
| noActiveDrugs | 暂无启用药物 | No active medications | 有効な薬がありません | 清单空着。 | The list is empty. | 一覧は空白。 | 删工具词「启用 / active / 有効」；改杂志栏「清单 / list / 一覧」+「空着 / 空白」陈述；不催促添加 |
| noTimelineEvents | 暂无时间线事件 | No timeline events yet | タイムラインの記録がありません | 尚未起笔。 | Yet to begin. | まだ書かれず。 | 候选 A §7 锚点直接采用；从「无事件 / no events」工具语转「起笔 / begin / 書かれず」文学语，杂志记者笔法 |
| noBloodTestHistory | 暂无血检历史记录 | No blood test history yet | 血液検査の履歴がありません | 尚无血检。 | No tests yet. | 検査記録なし。 | 删「历史记录 / history / 履歴」赘词；三语压到 5 字内 |
| photoEmptyTitle | 还没有加密照片 | No encrypted photos yet | まだ暗号化写真がありません | 暗匣空着。 | The vault is empty. | 暗箱は空白。 | 强烈隐喻——「暗匣 / vault / 暗箱」是摄影暗房 / 宝匣词，比「加密照片」工具术语更杂志感；隐私感不靠形容词靠词汇选择 |
| photoEmptyDescription | 你的照片经过端到端加密，只有你能看到。 | Your photos are end-to-end encrypted. Only you can see them. | 写真はエンドツーエンドで暗号化され、あなただけが閲覧できます。 | 端到端加密。仅你可见。 | End-to-end encrypted. Only you. | エンドツーエンド。あなただけ。 | 删第二人称「你的 / Your / あなたの」过度强调；两段陈述；ja 用名词 + 句号止结构对应西式短句风 |
| recordDiaryEmpty | 开始你的第一篇日记 | Start your first diary entry | 最初の日記を書こう | 第一页待写。 | Page one awaits. | 一頁目を待つ。 | 删命令式「开始 / Start / 書こう」（候选 A §7 命令式 vs 陈述式）；改「页 / page / 頁」杂志语；ja「書こう」鼓励改「待つ」陈述 |
| recordPhotoEmpty | 还没有拍照记录 | No photo records yet | 写真記録はまだありません | 尚无照片。 | No photos yet. | 写真なし。 | 三语压短；删「记录 / records / 記録」赘词（在照片栏目下不需要） |
| recordMeasureEmpty | 还没有测量记录 | No measurement records yet | 測定記録はまだありません | 尚无测量。 | No measurements yet. | 測定なし。 | 同 recordPhotoEmpty 句式对称 |
| measurementEmptyHint | 保存第一条测量后，这里会显示围度和体重的历史变化。 | After your first measurement, you'll see your history here. | 最初の測定を保存すると、ここに履歴が表示されます。 | 记第一条后，此处显示围度与体重曲线。 | After your first entry, weight and body curves appear here. | 最初の一件で、体重と体型の推移を表示。 | 解决 high-priority §4 drift（zh 提到具体「围度体重」，en/ja 含糊）；三语都补足「围度 + 体重」具体词，让用户知道将看到什么 |
| noTrendData | 暂无趋势数据 | No trend data yet | トレンドデータなし | 数据未成线。 | Not enough to chart. | 線になるまで未だ。 | 文学化——从「无数据」工具陈述转「未成线 / not enough to chart / 線になるまで」具体可视化术语，体现「攒够才有曲线」的过程感 |

---

## 5. Confirmation dialogs（10 keys）

破坏性操作的最后一道屏障。v2 规则：先说**后果**，再问**意愿**；句末用句号或问号，绝不用感叹号。

| key | 现 zh | 现 en | 现 ja | 改 zh | 改 en | 改 ja | 推荐理由 |
|-----|------|------|------|------|------|------|---------|
| confirmDeleteDrug | 确定删除这种药物吗？此操作不可撤销。 | Delete this medication? This cannot be undone. | この薬を削除しますか？この操作は取り消せません。 | 删除后不可恢复。\n仍要继续？ | Cannot be undone.\nContinue? | 削除すれば戻せません。\n続けますか。 | 候选 A §7 锚点直接采用；后果前置（先「不可恢复」再「继续？」）；删除「确定 / 这种 / 此操作」冗余；句末问号但不叹号 |
| wipeAllDataTitle | 清除全部数据 | Wipe all data | すべてのデータを削除 | 清除全部 | Wipe everything | すべて削除 | 标题缩短到 4-5 字（杂志栏头长度）；保留「全部 / everything / すべて」的不可逆暗示 |
| wipeAllDataMessage | 此操作会永久删除应用中的所有加密数据，且无法恢复。 | This will permanently delete all encrypted app data and cannot be undone. | アプリ内の暗号化データをすべて完全に削除します。元に戻せません。 | 加密数据将被永久清除。\n不可恢复。 | All encrypted data will be erased.\nIt cannot be undone. | 暗号化データはすべて消去。\n戻せません。 | 双行结构（候选 A §7 范式）；删「此操作 / This / この操作」赘述；后果分两步陈述更刺痛 |
| photoDeleteTitle | 删除照片 | Delete photo | 写真を削除 | 删除照片 | Delete Photo | 写真を削除 | 解决 high-priority §5 en 大小写 drift；en 大写「Delete Photo」与 zh/ja 标题式对齐 |
| photoDeleteMessage | 这将同时删除加密文件和记录。 | This will delete the encrypted file and its record. | 暗号化ファイルと記録を同時に削除します。 | 加密文件与索引一并删除。 | The encrypted file and its index will be removed. | 暗号化ファイルと索引も削除。 | 「记录 / record / 記録」改「索引 / index / 索引」更准确（实际删的是数据库索引）；技术真相比婉转词更让用户信任 |
| deleteMeasurementTitle | 删除测量记录 | Delete Measurement | 測定記録を削除 | 删除测量 | Delete Measurement | 測定を削除 | zh/ja 删「记录 / 記録」赘词，与 en 长度对齐 |
| deleteMeasurementConfirm | 确认删除这条身体测量记录吗？ | Delete this body measurement record? | このボディ測定記録を削除しますか？ | 删除这条测量？ | Delete this measurement? | この測定を削除？ | 三语全部去「身体 / body / ボディ」（语境已知是身体测量）+「记录 / record / 記録」赘词；保留问号 |
| importConfirmTitle | 确认导入？ | Import data? | インポートを実行？ | 导入备份？ | Import backup? | バックアップを読込？ | 三语统一对象（备份 / backup / バックアップ），不再用模糊「数据 / data」；ja 去「実行」工具感 |
| importConfirmMessage | 导入会把备份数据合并到现有记录中，相同 ID 的条目可能被覆盖。 | This will add backup data to your existing records. Existing items with matching IDs may be overwritten. | バックアップを既存データに統合します。同じ ID の項目は上書きされる可能性があります。 | 备份将合并到现有数据。\n同名条目会被覆盖。 | Backup will merge with existing data.\nDuplicate entries get overwritten. | バックアップを既存に統合。\n重複項目は上書き。 | 解决 high-priority §5 #9「ID」对小白用户费解；改「同名 / Duplicate / 重複」普通词；双行结构清晰 |
| importConfirmAction | 导入 | Import | インポート | 合并 | Merge | 統合 | 与 importConfirmMessage「合并 / merge / 統合」语义一致；按钮文字反映**实际行为**（合并 ≠ 替换） |

---

## 6. Status / progress text（10 keys）

进度态是「app 还活着」的信号。v2 不省略号，用句号收（候选 A §7 句号收尾铁律）。

| key | 现 zh | 现 en | 现 ja | 改 zh | 改 en | 改 ja | 推荐理由 |
|-----|------|------|------|------|------|------|---------|
| loading | 加载中... | Loading... | 読み込み中... | 加载中。 | Loading. | 読込中。 | 三语统一去「...」（候选 A §7 零省略号）；ja 缩短「読み込み」→「読込」（书面语风） |
| exportInProgress | 正在导出数据... | Exporting data... | データをエクスポート中... | 正在导出。 | Exporting. | 書出中。 | 删「数据 / data / データ」赘词（用户已知道在导出什么）；省略号改句号 |
| importInProgress | 正在导入... | Importing... | インポート中... | 正在导入。 | Importing. | 読込中。 | 与 loading 风格一致；ja 改本地词 |
| pdfGenerating | 正在生成 PDF... | Generating PDF... | PDF 生成中... | PDF 生成中。 | Generating PDF. | PDF 生成中。 | 三语等长；省略号改句号 |
| downloadingUpdate | 正在下载更新... | Downloading update... | アップデートをダウンロード中... | 更新下载中。 | Downloading update. | 更新を取得中。 | ja 去外来语「アップデート」改「更新」、「ダウンロード」改「取得」（与全局一致） |
| updateChecking | 正在检查更新... | Checking for updates... | 更新を確認中... | 检查更新中。 | Checking for updates. | 更新を確認中。 | 三语对齐；省略号改句号 |
| todayCompleted | 今日已完成 ✅ | Completed for today ✅ | 今日は完了 ✅ | 今日已记。 | Recorded for today. | 今日、記し終えた。 | 候选 A §7 锚点「今日已记。」；删 emoji ✅（候选 A §7 零 emoji 铁律）；从「完成 / completed」工具语转「记 / recorded / 記し終えた」记录语 |
| pdfSuccess | PDF 已生成 | PDF generated | PDF を生成しました | PDF 已就绪。 | PDF ready. | PDF が整いました。 | 解决 high-priority §6 #8 en 太短不像反馈；改「就绪 / ready / 整う」更具温度且陈述完整；ja「整う」是文具词（整理整顿） |
| exportSuccess | 数据已导出 | Data exported successfully | データのエクスポートが完了しました | 已导出。 | Exported. | 書き出し済み。 | 解决 high-priority §6 #9（en 多「successfully」副词）；三语压到 1-2 词，去主语；reassurance 来自「已 / -ed / 済み」完成态本身 |
| measurementRecorded | 已记录一次身体测量 | Measurement recorded | 測定を記録しました | 已记入。 | Recorded. | 記しました。 | 解决 high-priority §6 #10（zh 多「一次」赘词）；三语等长；删「身体测量 / measurement / 測定」赘词（toast 语境已知） |

---

## 7. Legal / sensitive（10 keys）

隐私 / 法律 / 生物识别——「能否信任这个 app」的核心证据。这一类**不软化**：法律文案需要正式感与精确感。

| key | 现 zh | 现 en | 现 ja | 改 zh | 改 en | 改 ja | 推荐理由 |
|-----|------|------|------|------|------|------|---------|
| privacyPolicy | 隐私政策 | Privacy Policy | プライバシーポリシー | 隐私政策 | Privacy Policy | プライバシーポリシー | 保持——法律入口标题保持正式 |
| termsOfUse | 使用条款 | Terms of Use | 利用規約 | 使用条款 | Terms of Use | 利用規約 | 保持——同上 |
| privacyPolicyContent | (8 节长文) | (8 sections) | (8 sections) | 标题级 keys：将开头「最后更新：2026年4月」改为占位符 `{lastUpdated}`，由代码注入；正文调性保持当前编辑级文风（其本身已较克制） | 同 zh | 同 zh | high-priority §7 指出硬编码日期问题；本次仅给「日期占位符化」改造建议（涉及代码改动，超出文案范围）；正文 8 节本身调性合格，不重写 |
| termsOfUseContent | (9 节长文) | (9 sections) | (9 sections) | 同 privacyPolicyContent | 同 zh | 同 zh | 同上 |
| simulatorDisclaimer | （PK 模拟器免责声明，~120字） | （~280 chars） | （~110字） | 三语统一约 130 字符。建议口径：「本模拟仅供参考。个体差异（代谢、体重、注射部位脂肪比）会影响实际数值。调整方案前必须咨询医师。」 | "This simulation is for reference only. Individual factors (metabolism, weight, injection-site fat ratio) affect actual values. Always consult a clinician before changing your regimen." | 「本シミュレーションは参考用です。代謝・体重・注射部位の脂肪率など個人差で実数値は変わります。方案調整前に必ず医師にご相談ください。」 | 解决 high-priority CRITICAL #2 三语长度严重 drift；三语都补足「个体差异具体三因素」+「调整方案前咨询医师」具体行动指引；这是法律风险点，信息密度必须等同 |
| privacySecurity | 隐私与安全 | Privacy & Security | プライバシーとセキュリティ | 隐私与安全 | Privacy & Security | プライバシーとセキュリティ | 保持——设置入口标题保持正式 |
| privacyMode | 隐私模式 | Privacy mode | プライバシーモード | 隐私模式 | Privacy Mode | プライバシーモード | en 大写改「Privacy Mode」与 zh/ja 标题式对齐 |
| privacyModeEnabled | 最近任务中隐藏应用内容 | Hide app content in recents | 最近使ったアプリで内容を隠す | 最近任务中遮蔽应用画面。 | Hide the app from recents. | 最近使ったアプリで画面を遮る。 | 「内容 / content / 内容」改「画面 / app / 画面」更精确（实际遮的是截图缩略图）；增加句号收 |
| enableBiometric | 启用后使用生物识别 | Enable biometric unlock | 生体認証を有効にする | 启用生物识别。 | Enable biometric unlock. | 生体認証を有効化。 | 解决 high-priority §7 zh「启用后使用」语义打折；zh 改单一动作；ja「有効にする」→「有効化」体言止め压短 |
| wipeAllData | 清除全部数据 | Wipe all data | すべてのデータを削除 | 清除全部数据 | Wipe All Data | すべてのデータを削除 | en 改 Title Case 与 zh/ja 标题式对齐；保持「清除 / Wipe / 削除」原始重量（破坏性入口不软化） |

**confirmPassword (P0 必修，已识别)**：`app_zh.arb` 笔误「確認密码」（繁简混用）→「确认密码」，立即修。

---

## 8. 必须修复的 14 项问题（沿用 high-priority-keys 报告）

### P0 必修
- **confirmPassword (zh)**：`app_zh.arb:374` 附近 `"確認密码"` → `"确认密码"`（简繁混用错字，立即修，与本次 80 keys 修订同 PR 落地）
- **simulatorDisclaimer**：三语长度 drift（en 280 / zh 120 / ja 110）。本文 §7 已给统一口径候选三语（约 130 字符等长），可直接采用

### P1 调性对齐
- **addDrug / addPhoto / addBloodTest / addReport**：三语动词从「添加 / Add / 追加」混合改统一「加入 / Add / 加える」（杂志栏目语，本文 §2 已给）
- **onboardingWelcomeSub**：三语隐喻分裂（zh「记录空间」/ en「journal」/ ja「ノート」）→ 三语统一为「内刊 / journal / 内誌」（本文 §1 已给）
- **recordGreeting**：zh「你好」太普通 → 三语统一为「今日，写一行 / One line for today / 今日、一行」编辑指令式（本文 §1 已给）
- **exportFailed**：zh 多「请重试」指引，en/ja 没有 → 三语统一为「未完成 / didn't finish / 未了」陈述式，不主动催重试（本文 §3 已给）
- **pdfFailed / importFailed**：ja 太短像名词标题 → 三语统一完整句式（本文 §3 已给）
- **exportSuccess**：en 独有「successfully」副词 → 三语统一压短到 1-2 词（本文 §6 已给）
- **measurementRecorded**：zh 独有「一次」赘词 → 三语统一「已记入 / Recorded / 記しました」（本文 §6 已给）
- **measurementEmptyHint**：zh 提到具体「围度体重」，en/ja 含糊 → 三语都补具体词（本文 §4 已给）
- **enableBiometric**：zh「启用后使用」语义打折 → 改单动作（本文 §7 已给）

### P2 技术债（建议团队侧解决，不在本次 v2 文案范围）
- **重复定义清单**：`notificationSettings` / `medicationReminders` 在三语 ARB 中各定义 2 次（145 行 / 283 行附近）；build_runner 取后者，应清理。
- **key 合并清单**：`daysLeft` ≡ `inventoryDaysRemaining`（三语完全相同）；`addFirstDrug` ≡ `addFirstDrugCta` ≡ `onboardingAddDrug`（zh/ja 完全相同）；建议 PR 单独合并并删冗余 key。
- **myGrowthTrajectory**：en ARB 重复定义且翻译略不同（journey vs trajectory），与 zh「成长轨迹」/ ja「成長記録」三语隐喻分裂；建议团队选定一个 metaphor（推荐「轨迹 / trajectory / 軌跡」，与杂志「年表」语感对齐）。
- **holdTimeVeryFast / holdTimeCasual**：PK 模拟器是医疗严肃场景，ja「極速 / 適当」偏口语，应改正式（如「最速 / 標準」），en/zh 已合格。

---

## 9. 风险与注意

### ja 长词风险
日语候选词若超出按钮宽度需排查的 keys：`confirmDeleteDrug`(双行 zh/ja 对齐)、`importConfirmMessage`(双行结构)、`simulatorDisclaimer`(段落级，需 word-wrap 测试)、`wipeAllDataMessage`(双行)。建议工程实施时在最窄 360dp 屏幕走查这 4 个 key 的视觉断行。

### zh 简繁地区差异
本次修订全部按**简体**口径（HanaNote 中文目前仅简体 ARB）。若未来增繁体 zh-Hant ARB，需另起 commit 处理：「默认 → 預設」「视频 → 影片」「计算机 → 電腦」「数据 → 資料」类典型差异。本次仅修「确认 / 確認」笔误（这是简体 ARB 内部错字，非简繁差异）。

### 日语敬语层级
v2 调性指令 candidate-A §7「不过度敬语」。本次三语修订对 ja 的处理原则：保留です / ます基础敬体（不滑到普通体），但**删除前缀「お」「ご」**（如「お薬」→「薬」「用薬」）、**删除「〜してください」过度敬语**（改「〜を」体言止め或动词原形 + 句号）、**删除「あなたの」第二人称强调**（v2 编辑视角第三人称）。这一层级最贴近新潮文库扉页与日本独立杂志（如 BRUTUS、暮しの手帖）的书面敬体。

### 工程实施 SOP
- **保留 ARB schema**：`@@locale`、`@key` metadata、`placeholders` 字段一律不动；只改 value 字符串。
- **保留 placeholders**：含 `{count}` `{drugName}` `{message}` `{time}` 等占位符的 keys（如 `saveFailed`、`importSuccess`、`updateEstimatedTime`），新候选已保留对应占位符；勿误删。
- **改 PR 单独提**：建议拆 3 个 PR：(1) P0 confirmPassword + simulatorDisclaimer；(2) 80 keys 三语调性对齐；(3) P2 重复定义清理与 key 合并。三个 PR 都需跑 `flutter pub run build_runner build --delete-conflicting-outputs` 重生成 `app_localizations*.dart`。
- **测试**：现有 323 个测试 case 中含 i18n smoke test，全部需 pass。重点关注 `*WidgetTest` 中含具体文案断言的用例（修文案后断言需同步更新）。

---

## 10. 跳过的 keys

经核查 `app_zh.arb` 498/538/547 行附近**未发现实际 merge conflict 标记**（无 `<<<<<<<` / `=======` / `>>>>>>>`）。该区段是 web download banner（498-503）+ onboarding 块（505-516）+ pdf 块（518-526）+ import 块（528-541）+ termsOfUseContent（543）的正常分块。本次复盘**未跳过任何 keys**。

如后续真出现 conflict，建议跳过策略：先解 conflict 再补做该 key 的 v2 修订，避免在未稳定的 ARB 行号上做文案改动。

---

**报告字数**：约 3100 字（不含表格） | **覆盖 keys**：80 / 80 | **CRITICAL 修复**：2 项 | **P1 调性对齐**：10 项 | **P2 技术债**：4 项

— 完 —
