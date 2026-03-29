// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'HanaNote';

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String get ok => '确定';

  @override
  String get cancel => '取消';

  @override
  String get goodMorning => '早安';

  @override
  String get goodAfternoon => '午安';

  @override
  String get goodEvening => '晚上好';

  @override
  String get addDrug => '添加药物';

  @override
  String get editDrug => '编辑药物';

  @override
  String get drugName => '药物名称';

  @override
  String get genericName => '通用名';

  @override
  String get dosage => '剂量';

  @override
  String get frequency => '频率';

  @override
  String get takeDose => '服药';

  @override
  String get skipDose => '跳过';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get confirm => '确认';

  @override
  String get inventory => '库存';

  @override
  String get remaining => '剩余';

  @override
  String get lowStock => '库存偏低';

  @override
  String daysLeft(int days) {
    return '剩余 $days 天';
  }

  @override
  String nextTime(String time) {
    return '下次：$time';
  }

  @override
  String get completedDose => '已完成';

  @override
  String get noActiveDrugs => '暂无启用药物';

  @override
  String get addFirstDrug => '添加你的第一种药物';

  @override
  String get category => '类别';

  @override
  String get route => '给药方式';

  @override
  String get unit => '单位';

  @override
  String get notes => '备注';

  @override
  String get injectionSite => '注射部位';

  @override
  String get patchSite => '贴片部位';

  @override
  String get quantity => '数量';

  @override
  String get active => '启用中';

  @override
  String get inactive => '未启用';

  @override
  String get today => '今天';

  @override
  String get medications => '用药';

  @override
  String get photoGallery => '加密相册';

  @override
  String get addPhoto => '添加照片';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromLibrary => '从相册选择';

  @override
  String get photoEmptyTitle => '还没有加密照片';

  @override
  String get photoEmptyDescription => '你的照片经过端到端加密，只有你能看到。';

  @override
  String get photoDeleteTitle => '删除照片';

  @override
  String get photoDeleteMessage => '这将同时删除加密文件和记录。';

  @override
  String get retry => '重试';

  @override
  String get fileSize => '文件大小';

  @override
  String get errorFallbackTitle => '出了点问题';

  @override
  String get errorFallbackDescription => '请重新打开应用。如果问题持续存在，请联系支持。';

  @override
  String get nextDose => '下次用药';

  @override
  String get todayCompleted => '今日已完成 ✅';

  @override
  String get hourUnit => '小时';

  @override
  String get minuteUnit => '分钟';

  @override
  String hrtDay(int days) {
    return 'HRT 第 $days 天';
  }

  @override
  String get takenDoses => '已服药';

  @override
  String get pendingDoses => '待服药';

  @override
  String get allDay => '全天';

  @override
  String get noMedicationRecords => '暂无用药记录';

  @override
  String get profile => '我的';

  @override
  String get myMedications => '我的用药';

  @override
  String drugCount(int count) {
    return '$count 种在用';
  }

  @override
  String inventoryDaysRemaining(int days) {
    return '剩余 $days 天';
  }

  @override
  String get inventoryDataUnavailable => '库存数据暂不可用';

  @override
  String get medicationPlan => '用药方案';

  @override
  String get manageEditSchedules => '管理与编辑方案';

  @override
  String get privacySecurity => '隐私与安全';

  @override
  String get appLock => '应用锁';

  @override
  String get privacyMode => '隐私模式';

  @override
  String get privacyModeEnabled => '最近任务中隐藏应用内容';

  @override
  String get privacyModeDisabled => '最近任务中显示应用内容';

  @override
  String get wipeAllData => '清除全部数据';

  @override
  String get wipeAllDataTitle => '清除全部数据';

  @override
  String get wipeAllDataMessage => '此操作会永久删除应用中的所有加密数据，且无法恢复。';

  @override
  String get dataBackup => '数据备份';

  @override
  String get exportBackup => '导出备份';

  @override
  String get importBackup => '导入恢复';

  @override
  String get generatePdf => '生成 PDF';

  @override
  String get backupToolsComingSoon => '备份工具仍在开发中';

  @override
  String get settingsComingSoon => '设置功能即将上线';

  @override
  String get notificationsComingSoon => '通知功能即将上线';

  @override
  String get inventoryComingSoon => '库存功能即将上线';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfUse => '使用条款';

  @override
  String get privacyPolicyPending => '隐私政策将在发布前上线';

  @override
  String get termsPending => '使用条款将在发布前上线';

  @override
  String get timeline => '时间线';

  @override
  String get noTimelineEvents => '暂无时间线事件';

  @override
  String get logMedication => '记录服药';

  @override
  String get writeJournal => '写日记';

  @override
  String get addBloodTest => '添加血检';

  @override
  String get data => '数据';

  @override
  String get hormoneOverview => '激素概览';

  @override
  String get addReport => '添加报告';

  @override
  String get history => '历史记录';

  @override
  String get pkSimulator => 'PK 模拟器';

  @override
  String get noUpdatesYet => '暂无更新';

  @override
  String lastUpdated(String date) {
    return '最后更新：$date';
  }

  @override
  String get noBloodTestHistory => '暂无血检历史记录';

  @override
  String get startDate => '开始日期';

  @override
  String get selectDate => '选择日期';

  @override
  String get endDateOptional => '结束日期（可选）';

  @override
  String get noEndDate => '无结束日期';

  @override
  String get daily => '每天';

  @override
  String get everyNDays => '每隔 N 天';

  @override
  String get weekly => '每周';

  @override
  String get timesPerDay => '每日次数：';

  @override
  String get everyPrefix => '每隔 ';

  @override
  String get daySuffix => ' 天';

  @override
  String get dayOfWeek => '星期几：';

  @override
  String get scheduleTimes => '服药时间';

  @override
  String get required => '必填';

  @override
  String get tabToday => '今日';

  @override
  String get tabRecord => '记录';

  @override
  String get tabTimeline => '轨迹';

  @override
  String get tabData => '数据';

  @override
  String get tabProfile => '我的';
}
