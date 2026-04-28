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
  String get settingsCrashReporting => 'クラッシュレポート';

  @override
  String get settingsCrashReportingDesc => '匿名でクラッシュを報告し問題修正に協力。いつでもオフにできます。';

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
  String get enumMeasureBust => 'バスト';

  @override
  String get enumMeasureUnderbust => 'アンダーバスト';

  @override
  String get enumMeasureWaist => 'ウエスト';

  @override
  String get enumMeasureHip => 'ヒップ';

  @override
  String get enumMeasureThigh => '太もも';

  @override
  String get enumMeasureUpperArm => '上腕';

  @override
  String get enumMeasureShoulder => '肩幅';

  @override
  String get enumMeasureNeck => '首回り';

  @override
  String get enumMeasureWeight => '体重';

  @override
  String get enumMoodVeryBad => 'とても悪い';

  @override
  String get enumMoodBad => 'あまり良くない';

  @override
  String get enumMoodNeutral => '普通';

  @override
  String get enumMoodGood => '良い';

  @override
  String get enumMoodVeryGood => 'とても良い';

  @override
  String get enumEsterValerate => '吉草酸エストラジオール（筋注）';

  @override
  String get enumEsterCypionate => 'エストラジオールシピオン酸（筋注）';

  @override
  String get enumEsterEnanthate => 'エストラジオールエナント酸（筋注）';

  @override
  String get enumEsterOral => '経口エストラジオール';

  @override
  String get enumEsterSublingual => '舌下エストラジオール';

  @override
  String get enumEsterPatch => 'エストラジオールパッチ';

  @override
  String get enumEsterGel => 'エストラジオールジェル';

  @override
  String get toggleHanaPkEngine => 'Hana-PK実験エンジン切替';

  @override
  String get simulatorDisclaimer =>
      '免責事項：シミュレーション結果は薬物動態モデルに基づく参考値であり、医療的助言ではありません。代謝率・体重・注射部位の脂肪比率など個体差により実際の血中濃度は大きく異なる場合があります。処方変更前に必ず医師にご相談ください。';

  @override
  String get simulatorSchemeParams => 'レジメンパラメータ';

  @override
  String get simulatorDrugType => '薬剤タイプ';

  @override
  String get simulatorSingleDose => '1回投与量 (mg)';

  @override
  String get simulatorInterval => '間隔（日）';

  @override
  String get simulatorWeight => '体重 (kg)';

  @override
  String get simulatorPatchWear => 'パッチ装着（日）';

  @override
  String get simulatorSublingualHold => '舌下保持時間';

  @override
  String get holdTimeVeryFast => '極速';

  @override
  String get holdTimeCasual => '適当';

  @override
  String get holdTimeStandard => '標準';

  @override
  String get holdTimeStrict => '厳密';

  @override
  String get updateSimulation => 'シミュレーション更新';

  @override
  String get concentrationCurve => '濃度-時間曲線';

  @override
  String get hanaPkLabel => 'Hana-PK';

  @override
  String get v2StandardLabel => 'V2 標準';

  @override
  String get chartAxisLabel => 'Y軸: エストラジオール血中濃度 (pg/mL)  X軸: 日数';

  @override
  String get steadyStateSummary => '定常状態サマリー';

  @override
  String get peakLabel => 'ピーク';

  @override
  String get troughLabel => 'トラフ';

  @override
  String get averageLabel => '平均値';

  @override
  String reachSteadyDays(String days) {
    return '定常到達: $days日';
  }

  @override
  String get bodyMeasurementsTitle => 'ボディ測定';

  @override
  String get newMeasurement => '新規測定';

  @override
  String get startRecordingChanges => '体の変化を記録しよう';

  @override
  String get measurementEmptyHint => '最初の測定を保存すると、ここに履歴が表示されます。';

  @override
  String get deleteMeasurementTitle => '測定記録を削除';

  @override
  String get deleteMeasurementConfirm => 'このボディ測定記録を削除しますか？';

  @override
  String get measurementRecorded => '測定を記録しました';

  @override
  String get editMeasurement => '測定を編集';

  @override
  String get createMeasurement => '新規測定';

  @override
  String get coreMeasurements => '基本測定';

  @override
  String get extendedIndicators => '拡張指標';

  @override
  String get measurementDate => '測定日';

  @override
  String get welcomeBack => 'おかえりなさい';

  @override
  String get enterFullPin => '6桁のPINを入力してください';

  @override
  String get setupSecurePassword => 'セキュアパスワードを作成';

  @override
  String get setupPinDescription => 'プライベートな健康データを守る6桁PINを設定してください。';

  @override
  String get password => 'パスワード';

  @override
  String get confirmPassword => 'パスワード確認';

  @override
  String get enableBiometric => '生体認証を有効にする';

  @override
  String get pinFormatRequired => '6桁のPINを入力してください';

  @override
  String get pinMismatch => 'PINが一致しません';

  @override
  String get editDiary => '日記を編集';

  @override
  String get diaryPlaceholder => '今日は何を書きたい…';

  @override
  String get addTags => 'タグを追加';

  @override
  String get presetTagHappy => '嬉しい';

  @override
  String get presetTagAnxious => '不安';

  @override
  String get presetTagCalm => '穏やか';

  @override
  String get presetTagTired => '疲れた';

  @override
  String get presetTagHopeful => '希望に満ちた';

  @override
  String get reminderChannelName => '服薬リマインダー';

  @override
  String get reminderChannelDesc => '毎日の服薬リマインダー通知';

  @override
  String get reminderNotifTitle => 'HanaNote 服薬リマインダー';

  @override
  String reminderNotifBody(String drugName, String dosage, String unit) {
    return '$drugName $dosage$unit — お薬の時間です 💊';
  }

  @override
  String get milestoneSubtitle => 'ここまで来たあなたは素晴らしい';

  @override
  String get noReadingSummary => '検査値サマリーなし';

  @override
  String get medicationStatusTaken => '服薬済み';

  @override
  String get medicationStatusSkipped => 'スキップ';

  @override
  String get medicationStatusLate => '遅延服薬';

  @override
  String get medicationStatusDefault => '服薬記録';

  @override
  String medicationLogTitle(String drugName, String dosage) {
    return '服薬: $drugName $dosage';
  }

  @override
  String get abbrevBust => '胸';

  @override
  String get abbrevWaist => '腰';

  @override
  String get abbrevHip => '臀';

  @override
  String get editBloodReport => '血液検査を編集';

  @override
  String get addBloodReport => '血液検査を追加';

  @override
  String get testDate => '検査日';

  @override
  String get labName => '検査機関';

  @override
  String get addReading => '項目を追加';

  @override
  String get hormoneValue => '数値';

  @override
  String get selectHormone => 'ホルモンを選択';

  @override
  String get atLeastOneReading => '少なくとも1つの項目を追加してください';

  @override
  String get invalidValue => '有効な数値を入力してください';

  @override
  String saveFailed(String message) {
    return '保存に失敗しました：$message';
  }

  @override
  String get loadFailed => 'レポートの読み込みに失敗しました';

  @override
  String get knowledgeBase => '薬物リファレンス';

  @override
  String get knowledgeBaseSubtitle => 'エビデンスに基づくHRT安全ガイド';

  @override
  String get openKnowledgeBase => 'HRT薬典を開く';

  @override
  String get languageSystem => 'システム設定に従う';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get updateAvailable => '新バージョンがあります';

  @override
  String get updateNow => '今すぐ更新';

  @override
  String get updateLater => 'あとで';

  @override
  String get privacyPolicyContent =>
      'プライバシーポリシー\n\n最終更新日：2026年4月\n\nHanaNote（以下「本アプリ」）は、お客様のプライバシーの保護に努めています。本プライバシーポリシーは、お客様の情報の取り扱い方法について説明します。\n\n1. データの保存\n服薬記録、日記、身体測定、写真、血液検査結果を含むすべての個人健康データは、お客様のデバイスにローカルで保存されます。健康データを外部サーバーに送信することはありません。\n\n2. 暗号化\nお客様のデータは業界標準の暗号化で保護されています。写真はエンドツーエンドで暗号化され、お客様のみが閲覧できます。\n\n3. データの収集\n本アプリは、個人を特定できる情報を収集、共有、販売しません。分析トラッカーや広告SDKは使用していません。\n\n4. 権限\n本アプリは、カメラ（写真記録用）、生体認証センサー（アプリロック用）、通知システム（服薬リマインダー用）へのアクセスを要求する場合があります。これらの権限は記載された目的のみに使用されます。\n\n5. データのエクスポート\n内蔵のエクスポート機能を使用して、いつでもデータをエクスポートできます。データの完全な所有権はお客様にあります。\n\n6. データの削除\n設定の「すべてのデータを削除」オプションを使用して、すべてのデータを完全に削除できます。この操作は元に戻せません。\n\n7. 変更\n本プライバシーポリシーは随時更新される場合があります。本アプリの継続使用は、更新されたポリシーの承認とみなされます。\n\n8. お問い合わせ\n本プライバシーポリシーについてご質問がある場合は、公式チャネルからお問い合わせください。';

  @override
  String get downloadingUpdate => 'アップデートをダウンロード中...';

  @override
  String downloadProgress(String percent) {
    return 'ダウンロード $percent%';
  }

  @override
  String get installUpdate => 'アップデートをインストール';

  @override
  String get downloadFailed => 'ダウンロード失敗、再試行してください';

  @override
  String get drugTemplateTitle => 'お薬を選択';

  @override
  String get drugTemplateSubtitle => 'よく使うHRT薬をタップして追加、またはカスタム';

  @override
  String get drugCustomAdd => 'カスタム薬を追加';

  @override
  String get updateSectionTitle => 'ソフトウェア更新';

  @override
  String get updateAutoCheck => '自動更新チェック';

  @override
  String get updateAutoCheckDesc => '起動時に新バージョンを確認';

  @override
  String get updateCheckNow => '今すぐ確認';

  @override
  String get updateChecking => '更新を確認中...';

  @override
  String get updateAlreadyLatest => '最新バージョンです';

  @override
  String get updateCheckFailed => '更新確認に失敗しました';

  @override
  String get updateCurrentVersion => '現在';

  @override
  String get updateNewVersion => '最新';

  @override
  String get updateWhatsNew => '更新内容';

  @override
  String get updateSkipVersion => 'このバージョンをスキップ';

  @override
  String get updateRetry => '再ダウンロード';

  @override
  String get updateReadyToInstall => 'インストール準備完了';

  @override
  String updateEstimatedTime(String time) {
    return '残り約 $time';
  }

  @override
  String get termsOfUseContent =>
      '利用規約\n\n最終更新日：2026年4月\n\nHanaNote（以下「本アプリ」）を使用することにより、以下の利用規約に同意したものとみなされます。\n\n1. 目的\n本アプリは、ホルモン補充療法（HRT）管理のために設計された個人健康追跡ツールです。医療機器ではなく、医療上のアドバイスを提供するものではありません。\n\n2. 医療上の免責事項\n本アプリは、専門的な医療アドバイス、診断、または治療の代替ではありません。服薬レジメンを変更する前に、必ず医療提供者にご相談ください。薬物動態シミュレーションの結果は参考値です。\n\n3. ユーザーの責任\n入力するデータの正確性、およびデバイスとアプリパスワードのセキュリティの維持は、お客様の責任です。\n\n4. データの所有権\n本アプリ内で作成されたすべてのデータの完全な所有権はお客様にあります。お客様のコンテンツに対する権利を主張しません。\n\n5. 可用性\n本アプリは、いかなる種類の保証もなく「現状のまま」提供されます。中断なしまたはエラーなしの動作を保証しません。\n\n6. 責任の制限\n法律で認められる最大限の範囲において、本アプリの開発者は、本アプリの使用または使用不能から生じるいかなる損害についても責任を負いません。\n\n7. 更新\n機能改善のためにアップデートをリリースする場合があります。アップデート後の継続使用は、変更された規約の承認とみなされます。\n\n8. 準拠法\n本規約は、適用される現地法に準拠します。\n\n9. お問い合わせ\n本規約についてご質問がある場合は、公式チャネルからお問い合わせください。';
}
