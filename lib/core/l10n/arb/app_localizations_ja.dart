// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'HanaNote';

  @override
  String get loading => '読み込み中...';

  @override
  String get error => 'エラー';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'キャンセル';

  @override
  String get closeAction => '閉じる';

  @override
  String get goodMorning => 'おはよう';

  @override
  String get goodAfternoon => 'こんにちは';

  @override
  String get goodEvening => 'こんばんは';

  @override
  String get addDrug => '薬を追加';

  @override
  String get editDrug => '薬を編集';

  @override
  String get drugName => '薬剤名';

  @override
  String get genericName => '一般名';

  @override
  String get dosage => '用量';

  @override
  String get frequency => '頻度';

  @override
  String get takeDose => '服薬';

  @override
  String get skipDose => 'スキップ';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get confirm => '確認';

  @override
  String get confirmDeleteDrug => 'この薬を削除しますか？この操作は取り消せません。';

  @override
  String get inventory => '在庫';

  @override
  String get remaining => '残り';

  @override
  String get lowStock => '在庫が少ないです';

  @override
  String daysLeft(int days) {
    return '残り $days 日';
  }

  @override
  String nextTime(String time) {
    return '次回: $time';
  }

  @override
  String get completedDose => '完了';

  @override
  String get noActiveDrugs => '有効な薬がありません';

  @override
  String get addFirstDrug => '最初の薬を追加';

  @override
  String get category => 'カテゴリ';

  @override
  String get route => '投与経路';

  @override
  String get unit => '単位';

  @override
  String get notes => 'メモ';

  @override
  String get injectionSite => '注射部位';

  @override
  String get patchSite => '貼付部位';

  @override
  String get quantity => '数量';

  @override
  String get active => '有効';

  @override
  String get inactive => '無効';

  @override
  String get today => '今日';

  @override
  String get medications => '用薬';

  @override
  String get photoGallery => '暗号化ギャラリー';

  @override
  String get addPhoto => '写真を追加';

  @override
  String get takePhoto => '撮影';

  @override
  String get chooseFromLibrary => 'ライブラリから選択';

  @override
  String get photoEmptyTitle => 'まだ暗号化写真がありません';

  @override
  String get photoEmptyDescription => '写真はエンドツーエンドで暗号化され、あなただけが閲覧できます。';

  @override
  String get photoDeleteTitle => '写真を削除';

  @override
  String get photoDeleteMessage => '暗号化ファイルと記録を同時に削除します。';

  @override
  String get retry => '再試行';

  @override
  String get fileSize => 'ファイルサイズ';

  @override
  String get errorFallbackTitle => '問題が発生しました';

  @override
  String get errorFallbackDescription => 'アプリを再起動してください。問題が続く場合はサポートへ連絡してください。';

  @override
  String get nextDose => '次の服薬';

  @override
  String get todayCompleted => '今日は完了 ✅';

  @override
  String get hourUnit => '時間';

  @override
  String get minuteUnit => '分';

  @override
  String hrtDay(int days) {
    return 'HRT $days 日目';
  }

  @override
  String get takenDoses => '服薬済み';

  @override
  String get pendingDoses => '未服薬';

  @override
  String get allDay => '終日';

  @override
  String get noMedicationRecords => '服薬記録がありません';

  @override
  String get addFirstDrugCta => '最初の薬を追加';

  @override
  String get profile => 'マイページ';

  @override
  String get myMedications => '私の薬';

  @override
  String drugCount(int count) {
    return '$count 件を使用中';
  }

  @override
  String inventoryDaysRemaining(int days) {
    return '残り $days 日';
  }

  @override
  String get inventoryDataUnavailable => '在庫データを取得できません';

  @override
  String inventoryUpdateHint(String unit) {
    return '新しい数量 ($unit)';
  }

  @override
  String get medicationPlan => '服薬プラン';

  @override
  String get manageEditSchedules => 'スケジュールを管理・編集';

  @override
  String get privacySecurity => 'プライバシーとセキュリティ';

  @override
  String get appLock => 'アプリロック';

  @override
  String get privacyMode => 'プライバシーモード';

  @override
  String get privacyModeEnabled => '最近使ったアプリで内容を隠す';

  @override
  String get privacyModeDisabled => '最近使ったアプリで内容を表示する';

  @override
  String get wipeAllData => 'すべてのデータを削除';

  @override
  String get wipeAllDataTitle => 'すべてのデータを削除';

  @override
  String get wipeAllDataMessage => 'アプリ内の暗号化データをすべて完全に削除します。元に戻せません。';

  @override
  String get dataBackup => 'データバックアップ';

  @override
  String get exportBackup => 'バックアップを書き出す';

  @override
  String get importBackup => 'バックアップを読み込む';

  @override
  String get generatePdf => 'PDF を生成';

  @override
  String get backupToolsComingSoon => 'バックアップ機能は開発中です';

  @override
  String get settingsComingSoon => '設定機能は近日公開です';

  @override
  String get notificationsComingSoon => '通知機能は近日公開です';

  @override
  String get inventoryComingSoon => '在庫機能は近日公開です';

  @override
  String get about => '情報';

  @override
  String get version => 'バージョン';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfUse => '利用規約';

  @override
  String get privacyPolicyPending => 'プライバシーポリシーは公開前に追加されます';

  @override
  String get termsPending => '利用規約は公開前に追加されます';

  @override
  String get timeline => 'タイムライン';

  @override
  String get myGrowthTrajectory => '私の成長記録';

  @override
  String get noTimelineEvents => 'タイムラインの記録がありません';

  @override
  String get logMedication => '服薬を記録';

  @override
  String get writeJournal => '日記を書く';

  @override
  String get addBloodTest => '血液検査を追加';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get medicationReminders => '服薬リマインダー';

  @override
  String get noActiveReminders => 'アクティブな服薬リマインダーはありません';

  @override
  String get reminderTimes => 'リマインダー時間';

  @override
  String get exportInProgress => 'データをエクスポート中...';

  @override
  String get exportSuccess => 'データのエクスポートが完了しました';

  @override
  String get exportFailed => 'エクスポートに失敗しました';

  @override
  String get data => 'データ';

  @override
  String get dataAndTrends => 'データとトレンド';

  @override
  String get myStatus => 'マイステータス';

  @override
  String get bodyChanging => '素敵な変化が起きています…';

  @override
  String get hormoneOverview => 'ホルモン概要';

  @override
  String get addReport => 'レポートを追加';

  @override
  String get history => '履歴';

  @override
  String get historyReports => '過去のレポート';

  @override
  String get pkSimulator => 'PK シミュレーター';

  @override
  String get pkSimulatorTitle => 'PK シミュレーション';

  @override
  String get pkSimulatorSubtitle => '血中薬物濃度を予測…';

  @override
  String get trendSection => '指標トレンド';

  @override
  String get trendStable => '最近のトレンドは安定';

  @override
  String get trendDecreasing => '低下傾向';

  @override
  String get lastHalfYear => '過去半年';

  @override
  String get noTrendData => 'トレンドデータなし';

  @override
  String get filterOneMonth => '1か月';

  @override
  String get filterThreeMonths => '3か月';

  @override
  String get filterSixMonths => '6か月';

  @override
  String get filterOneYear => '1年';

  @override
  String get filterAll => 'すべて';

  @override
  String get journeyStart => '旅の始まり';

  @override
  String get noUpdatesYet => 'まだ更新がありません';

  @override
  String lastUpdated(String date) {
    return '最終更新: $date';
  }

  @override
  String get noBloodTestHistory => '血液検査の履歴がありません';

  @override
  String get startDate => '開始日';

  @override
  String get selectDate => '日付を選択';

  @override
  String get endDateOptional => '終了日（任意）';

  @override
  String get noEndDate => '終了日なし';

  @override
  String get daily => '毎日';

  @override
  String get everyNDays => 'N日ごと';

  @override
  String get weekly => '毎週';

  @override
  String get timesPerDay => '1日の回数:';

  @override
  String get everyPrefix => '';

  @override
  String get daySuffix => ' 日';

  @override
  String get dayOfWeek => '曜日:';

  @override
  String get scheduleTimes => '服薬時間';

  @override
  String get required => '必須';

  @override
  String get validationDosageRequired => '用量は0より大きくしてください';

  @override
  String get validationUnitRequired => '単位を選択してください';

  @override
  String get validationFrequencyRequired => '頻度を選択してください';

  @override
  String get validationStartDateRequired => '開始日を選択してください';

  @override
  String get validationScheduleTimeRequired => '少なくとも1つの服薬時間が必要です';

  @override
  String get validationFieldsIncomplete => 'すべての必須項目を入力してください';

  @override
  String get recordTitle => '今日の記録';

  @override
  String get recordGreeting => 'こんにちは、\n今日はどんな思い出を残しますか？';

  @override
  String get recordPhoto => '写真記録';

  @override
  String get recordPhotoSub => '暗号化保存、あなただけが見られます';

  @override
  String get recordMeasurement => 'ボディ測定';

  @override
  String get recordMeasurementSub => 'からだの変化を記録しよう';

  @override
  String get recordDiary => '気持ち日記';

  @override
  String get recordDiarySub => '今日は何を書きたい？';

  @override
  String get recordDiaryEmpty => '最初の日記を書こう';

  @override
  String get recordPhotoEmpty => '写真記録はまだありません';

  @override
  String get recordMeasureEmpty => '測定記録はまだありません';

  @override
  String recordStreak(int days) {
    return '$days日連続記録中';
  }

  @override
  String recordLastPhoto(String date) {
    return '前回：$date';
  }

  @override
  String get recordFooter => '一つ一つの記録が未来への優しい約束';

  @override
  String get defaultUserName => 'HanaNote ユーザー';

  @override
  String get dailyQuote0 => 'あなたの一歩一歩が、未来にそっと花を咲かせます。';

  @override
  String get dailyQuote1 => '今日も自分を優しく労ってね。変化は起きています。';

  @override
  String get dailyQuote2 => 'からだの小さな反応は、あなたが丁寧に生きている証です。';

  @override
  String get dailyQuote3 => 'ゆっくりでも大丈夫。着実に進むことが力になります。';

  @override
  String get dailyQuote4 => '服薬と記録はタスクじゃなく、自分への約束です。';

  @override
  String get dailyQuote5 => '自分のリズムで成長していい。誰とも比べなくていい。';

  @override
  String get dailyQuote6 => 'なりたい自分に近づいている。それはお祝いに値します。';

  @override
  String get dailyQuote7 => '普通の一日も、自分を大切にすることで輝きます。';

  @override
  String get dailyQuote8 => 'からだを大切にすることは、未来への手紙です。';

  @override
  String get dailyQuote9 => '今日の忍耐は、明日の安心になります。';

  @override
  String get dailyQuote10 => '記録を重ねることは、本当の自分を見つめること。';

  @override
  String get dailyQuote11 => '今日も自分を褒めてあげてね。よくがんばっています。';

  @override
  String get enumCatEstrogen => 'エストロゲン';

  @override
  String get enumCatAntiAndrogen => '抗アンドロゲン';

  @override
  String get enumCatProgestogen => 'プロゲストーゲン';

  @override
  String get enumCatAuxiliary => '補助薬';

  @override
  String get enumRouteOral => '経口';

  @override
  String get enumRouteSublingual => '舌下';

  @override
  String get enumRoutePatch => 'パッチ';

  @override
  String get enumRouteGel => 'ジェル';

  @override
  String get enumRouteIM => '筋肉注射';

  @override
  String get enumRouteSC => '皮下注射';

  @override
  String get enumRouteRectal => '直腸';

  @override
  String get enumUnitPump => 'プッシュ';

  @override
  String get enumUnitPatch => '枚';

  @override
  String get enumHormoneEstradiol => 'エストラジオール';

  @override
  String get enumHormoneTestosterone => 'テストステロン';

  @override
  String get enumHormoneProlactin => 'プロラクチン';

  @override
  String get enumHormoneProgesterone => 'プロゲステロン';

  @override
  String get enumStatusNormal => '正常';

  @override
  String get enumStatusWarning => '目標から逸脱';

  @override
  String get enumStatusCritical => '要注意';

  @override
  String get enumTimelineMedication => '服薬記録';

  @override
  String get enumTimelineBloodTest => '血液検査';

  @override
  String get enumTimelineJournal => '日記';

  @override
  String get enumTimelineMilestone => 'マイルストーン';

  @override
  String get featureComingSoon => 'この機能は近日公開です';

  @override
  String get weekdayMonday => '月';

  @override
  String get weekdayTuesday => '火';

  @override
  String get weekdayWednesday => '水';

  @override
  String get weekdayThursday => '木';

  @override
  String get weekdayFriday => '金';

  @override
  String get weekdaySaturday => '土';

  @override
  String get weekdaySunday => '日';

  @override
  String get tabToday => '今日';

  @override
  String get tabRecord => '記録';

  @override
  String get tabTimeline => '軌跡';

  @override
  String get tabData => 'データ';

  @override
  String get tabProfile => 'マイページ';

  @override
  String get settingsTitle => '設定';

  @override
  String get globalNotification => 'グローバル通知';

  @override
  String get reminderEnabled => '有効';

  @override
  String get reminderDisabled => '無効';

  @override
  String get personalInfo => '個人情報';

  @override
  String get editDisplayName => '表示名を編集';

  @override
  String get editHrtStartDate => 'HRT開始日を編集';

  @override
  String get appearance => '外観';

  @override
  String get languageSetting => '言語';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get darkModeComingSoon => 'ダークモードは近日公開';

  @override
  String get featureInDevelopment => '開発中';

  @override
  String get featureInDevelopmentDesc => 'この機能は開発中です。次のバージョンで利用可能になります';

  @override
  String get onboardingWelcome => 'HanaNote へようこそ';

  @override
  String get onboardingWelcomeSub => 'プロフィールを設定しましょう';

  @override
  String get onboardingSetName => 'あなたの呼び名は？';

  @override
  String get onboardingNameHint => 'ニックネームを入力';

  @override
  String get onboardingNameNote => '設定でいつでも変更できます';

  @override
  String get onboardingSetHrtDate => 'HRTはいつ始めましたか？';

  @override
  String get onboardingSkipHrt => 'まだ始めていません、スキップ';

  @override
  String get onboardingAddDrug => '最初のお薬を追加';

  @override
  String get onboardingDrugOptional => 'あとで追加する';

  @override
  String get onboardingComplete => '設定完了！';

  @override
  String get onboardingNext => '次へ';

  @override
  String get onboardingDone => 'はじめる';

  @override
  String get importInProgress => 'インポート中...';

  @override
  String get importSuccess => 'インポート成功';

  @override
  String get importFailed => 'インポート失敗';

  @override
  String importedCount(int count) {
    return '$count 件インポートしました';
  }

  @override
  String get pdfGenerating => 'レポート生成中...';

  @override
  String get pdfSuccess => 'レポート生成完了';

  @override
  String get pdfFailed => 'レポート生成失敗';

  @override
  String get pdfTitle => 'HanaNote ヘルスレポート';

  @override
  String get pdfMedSection => '服薬プラン';

  @override
  String get pdfBloodSection => '血液検査記録';

  @override
  String get pdfMeasureSection => 'ボディ測定';

  @override
  String get pdfJournalSection => '気持ち日記';

  @override
  String get pdfNoData => 'データなし';
}
