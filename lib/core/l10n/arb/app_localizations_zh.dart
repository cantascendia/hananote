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
  String get closeAction => '关闭';

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
  String get confirmDeleteDrug => '确定删除这种药物吗？此操作不可撤销。';

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
  String get addFirstDrugCta => '添加你的第一种药物';

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
  String inventoryUpdateHint(String unit) {
    return '新数量 ($unit)';
  }

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
  String get myGrowthTrajectory => '我的成长轨迹';

  @override
  String get noTimelineEvents => '暂无时间线事件';

  @override
  String get logMedication => '记录服药';

  @override
  String get writeJournal => '写日记';

  @override
  String get addBloodTest => '添加验血报告';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get medicationReminders => '服药提醒';

  @override
  String get noActiveReminders => '暂无活跃用药提醒';

  @override
  String get reminderTimes => '提醒时间';

  @override
  String get exportInProgress => '正在导出数据...';

  @override
  String get exportSuccess => '数据已导出';

  @override
  String get exportFailed => '导出失败，请重试';

  @override
  String get data => '数据';

  @override
  String get dataAndTrends => '数据与趋势';

  @override
  String get myStatus => '我的状态';

  @override
  String get bodyChanging => '身体正在产生奇妙的变化...';

  @override
  String get hormoneOverview => '激素概览';

  @override
  String get addReport => '添加报告';

  @override
  String get history => '历史记录';

  @override
  String get historyReports => '历史报告';

  @override
  String get pkSimulator => 'PK 模拟器';

  @override
  String get pkSimulatorTitle => '药代动力学模拟';

  @override
  String get pkSimulatorSubtitle => '预测体内有效血药浓度...';

  @override
  String get trendSection => '指标趋势';

  @override
  String get trendStable => '近期走势平稳';

  @override
  String get trendDecreasing => '呈下降趋势';

  @override
  String get lastHalfYear => '近半年';

  @override
  String get noTrendData => '暂无趋势数据';

  @override
  String get filterOneMonth => '1月';

  @override
  String get filterThreeMonths => '3月';

  @override
  String get filterSixMonths => '6月';

  @override
  String get filterOneYear => '1年';

  @override
  String get filterAll => '全部';

  @override
  String get journeyStart => '旅程开始';

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
  String get validationDosageRequired => '剂量必须大于零';

  @override
  String get validationUnitRequired => '请选择剂量单位';

  @override
  String get validationFrequencyRequired => '请选择服药频率';

  @override
  String get validationStartDateRequired => '请选择开始日期';

  @override
  String get validationScheduleTimeRequired => '至少需要一个服药时间';

  @override
  String get validationFieldsIncomplete => '请填写所有必填项';

  @override
  String get recordTitle => '今日记录';

  @override
  String get recordGreeting => '你好，\n今天想留下什么回忆？';

  @override
  String get recordPhoto => '拍照记录';

  @override
  String get recordPhotoSub => '加密存储，只有你能看到';

  @override
  String get recordMeasurement => '身体测量';

  @override
  String get recordMeasurementSub => '记录身体的每一点变化';

  @override
  String get recordDiary => '心情日记';

  @override
  String get recordDiarySub => '今天想说点什么';

  @override
  String get recordDiaryEmpty => '开始你的第一篇日记';

  @override
  String get recordPhotoEmpty => '还没有拍照记录';

  @override
  String get recordMeasureEmpty => '还没有测量记录';

  @override
  String recordStreak(int days) {
    return '已连续记录 $days 天';
  }

  @override
  String recordLastPhoto(String date) {
    return '上次：$date';
  }

  @override
  String get recordFooter => '每一次记录都是对未来的温柔期许';

  @override
  String get defaultUserName => 'HanaNote 用户';

  @override
  String get dailyQuote0 => '你的每一次坚持，都会在未来悄悄开花。';

  @override
  String get dailyQuote1 => '今天也请温柔地照顾自己，变化正在发生。';

  @override
  String get dailyQuote2 => '身体的每一点回应，都是你认真生活的证据。';

  @override
  String get dailyQuote3 => '慢一点没有关系，稳定前进本身就是力量。';

  @override
  String get dailyQuote4 => '服药和记录不是任务，是你对自己的承诺。';

  @override
  String get dailyQuote5 => '允许自己按节奏成长，不必和任何人比较。';

  @override
  String get dailyQuote6 => '你正在成为想成为的人，这件事值得庆祝。';

  @override
  String get dailyQuote7 => '再普通的一天，也可以因为认真对待自己而闪光。';

  @override
  String get dailyQuote8 => '照顾身体不是负担，是你给未来写下的情书。';

  @override
  String get dailyQuote9 => '你今天的耐心，会变成明天的安心。';

  @override
  String get dailyQuote10 => '每一次记录都不是重复，而是在看见真实的自己。';

  @override
  String get dailyQuote11 => '今天也别忘了夸夸自己，你已经做得很好。';

  @override
  String get enumCatEstrogen => '雌激素';

  @override
  String get enumCatAntiAndrogen => '抗雄';

  @override
  String get enumCatProgestogen => '孕激素';

  @override
  String get enumCatAuxiliary => '辅助药物';

  @override
  String get enumRouteOral => '口服';

  @override
  String get enumRouteSublingual => '舌下含服';

  @override
  String get enumRoutePatch => '贴片';

  @override
  String get enumRouteGel => '凝胶';

  @override
  String get enumRouteIM => '肌肉注射';

  @override
  String get enumRouteSC => '皮下注射';

  @override
  String get enumRouteRectal => '直肠给药';

  @override
  String get enumUnitPump => '泵';

  @override
  String get enumUnitPatch => '贴';

  @override
  String get enumHormoneEstradiol => '雌二醇';

  @override
  String get enumHormoneTestosterone => '睾酮';

  @override
  String get enumHormoneProlactin => '泌乳素';

  @override
  String get enumHormoneProgesterone => '黄体酮';

  @override
  String get enumStatusNormal => '正常';

  @override
  String get enumStatusWarning => '偏离目标';

  @override
  String get enumStatusCritical => '需要关注';

  @override
  String get enumTimelineMedication => '服药记录';

  @override
  String get enumTimelineBloodTest => '血液检测';

  @override
  String get enumTimelineJournal => '日记';

  @override
  String get enumTimelineMilestone => '里程碑';

  @override
  String get featureComingSoon => '该功能即将上线';

  @override
  String get weekdayMonday => '周一';

  @override
  String get weekdayTuesday => '周二';

  @override
  String get weekdayWednesday => '周三';

  @override
  String get weekdayThursday => '周四';

  @override
  String get weekdayFriday => '周五';

  @override
  String get weekdaySaturday => '周六';

  @override
  String get weekdaySunday => '周日';

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

  @override
  String get settingsTitle => '设置';

  @override
  String get globalNotification => '全局通知';

  @override
  String get reminderEnabled => '已启用';

  @override
  String get reminderDisabled => '已禁用';

  @override
  String get personalInfo => '个人信息';

  @override
  String get editDisplayName => '修改昵称';

  @override
  String get editHrtStartDate => '修改HRT开始日期';

  @override
  String get appearance => '外观';

  @override
  String get languageSetting => '语言';

  @override
  String get darkMode => '深色模式';

  @override
  String get darkModeComingSoon => '深色模式敬请期待';

  @override
  String get featureInDevelopment => '功能开发中';

  @override
  String get featureInDevelopmentDesc => '此功能正在开发中，将在下个版本推出';

  @override
  String get onboardingWelcome => '欢迎使用 HanaNote';

  @override
  String get onboardingWelcomeSub => '让我们先设置一下你的个人信息';

  @override
  String get onboardingSetName => '你想怎么称呼自己？';

  @override
  String get onboardingNameHint => '输入你的昵称';

  @override
  String get onboardingNameNote => '可以随时在设置中修改';

  @override
  String get onboardingSetHrtDate => '你是什么时候开始 HRT 的？';

  @override
  String get onboardingSkipHrt => '还没开始，跳过';

  @override
  String get onboardingAddDrug => '添加你的第一种药物';

  @override
  String get onboardingDrugOptional => '稍后添加';

  @override
  String get onboardingComplete => '设置完成！';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingDone => '开始使用';

  @override
  String get importInProgress => '正在导入...';

  @override
  String get importSuccess => '导入成功';

  @override
  String get importFailed => '导入失败';

  @override
  String importedCount(int count) {
    return '已导入 $count 条数据';
  }

  @override
  String get pdfGenerating => '正在生成报告...';

  @override
  String get pdfSuccess => '报告已生成';

  @override
  String get pdfFailed => '报告生成失败';

  @override
  String get pdfTitle => 'HanaNote 健康报告';

  @override
  String get pdfMedSection => '用药方案';

  @override
  String get pdfBloodSection => '血检记录';

  @override
  String get pdfMeasureSection => '身体测量';

  @override
  String get pdfJournalSection => '心情日记';

  @override
  String get pdfNoData => '暂无数据';
}
