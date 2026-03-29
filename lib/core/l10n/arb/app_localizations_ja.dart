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
  String get noTimelineEvents => 'タイムラインの記録がありません';

  @override
  String get logMedication => '服薬を記録';

  @override
  String get writeJournal => '日記を書く';

  @override
  String get addBloodTest => '血液検査を追加';

  @override
  String get data => 'データ';

  @override
  String get hormoneOverview => 'ホルモン概要';

  @override
  String get addReport => 'レポートを追加';

  @override
  String get history => '履歴';

  @override
  String get pkSimulator => 'PK シミュレーター';

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
  String get tabToday => '今日';

  @override
  String get tabRecord => '記録';

  @override
  String get tabTimeline => '軌跡';

  @override
  String get tabData => 'データ';

  @override
  String get tabProfile => 'マイページ';
}
