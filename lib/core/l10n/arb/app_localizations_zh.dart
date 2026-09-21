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
  String get reminderSyncFailed => '提醒更新失败，请重试。';

  @override
  String get authOperationFailed => '暂时无法访问受保护的存储，请重试。';

  @override
  String get authIncorrectPin => 'PIN 不正确，请重试。';

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
  String get settingsCrashReporting => '崩溃报告';

  @override
  String get settingsCrashReportingDesc => '匿名上报应用崩溃以帮助修复问题。可随时关闭。';

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
  String get exportBackup => '导出加密记录备份';

  @override
  String get importBackup => '导入记录备份';

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
  String get enumMeasureBust => '胸围';

  @override
  String get enumMeasureUnderbust => '下胸围';

  @override
  String get enumMeasureWaist => '腰围';

  @override
  String get enumMeasureHip => '臀围';

  @override
  String get enumMeasureThigh => '大腿围';

  @override
  String get enumMeasureUpperArm => '上臂围';

  @override
  String get enumMeasureShoulder => '肩宽';

  @override
  String get enumMeasureNeck => '颈围';

  @override
  String get enumMeasureWeight => '体重';

  @override
  String get enumMoodVeryBad => '很差';

  @override
  String get enumMoodBad => '不太好';

  @override
  String get enumMoodNeutral => '一般';

  @override
  String get enumMoodGood => '不错';

  @override
  String get enumMoodVeryGood => '很好';

  @override
  String get enumEsterValerate => '戊酸雌二醇肌注';

  @override
  String get enumEsterCypionate => '环戊丙酸雌二醇肌注';

  @override
  String get enumEsterEnanthate => '庚酸雌二醇肌注';

  @override
  String get enumEsterOral => '口服雌二醇';

  @override
  String get enumEsterSublingual => '舌下雌二醇';

  @override
  String get enumEsterPatch => '雌二醇贴片';

  @override
  String get enumEsterGel => '雌二醇凝胶';

  @override
  String get toggleHanaPkEngine => '切换 Hana-PK 实验引擎';

  @override
  String get simulatorDisclaimer =>
      '免责声明：模拟结果基于药代动力学模型，仅供参考，不构成医疗建议。由于个体差异（如代谢率、体重、注射部位脂肪比例），真实血药浓度可能存在较大偏差。调整方案前请务必咨询专业医生。';

  @override
  String get simulatorSchemeParams => '方案参数';

  @override
  String get simulatorDrugType => '药物类型';

  @override
  String get simulatorSingleDose => '单次剂量 (mg)';

  @override
  String get simulatorInterval => '间隔 (天)';

  @override
  String get simulatorWeight => '体重 (kg)';

  @override
  String get simulatorPatchWear => '贴片佩戴 (天)';

  @override
  String get simulatorSublingualHold => '舌下含服时间';

  @override
  String get holdTimeVeryFast => '极快';

  @override
  String get holdTimeCasual => '随意';

  @override
  String get holdTimeStandard => '标准';

  @override
  String get holdTimeStrict => '严格';

  @override
  String get updateSimulation => '更新模拟';

  @override
  String get concentrationCurve => '浓度-时间曲线';

  @override
  String get hanaPkLabel => 'Hana-PK';

  @override
  String get v2StandardLabel => 'V2 标准';

  @override
  String get chartAxisLabel => 'Y轴: 雌二醇体循环浓度 (pg/mL)   X轴: 持续天数';

  @override
  String get steadyStateSummary => '稳态摘要';

  @override
  String get peakLabel => '峰值 (Peak)';

  @override
  String get troughLabel => '谷值 (Trough)';

  @override
  String get averageLabel => '均值 (Avg)';

  @override
  String reachSteadyDays(String days) {
    return '达稳: $days天';
  }

  @override
  String get bodyMeasurementsTitle => '身体测量';

  @override
  String get newMeasurement => '新建测量';

  @override
  String get startRecordingChanges => '开始记录你的身体变化';

  @override
  String get measurementEmptyHint => '保存第一条测量后，这里会显示围度和体重的历史变化。';

  @override
  String get deleteMeasurementTitle => '删除测量记录';

  @override
  String get deleteMeasurementConfirm => '确认删除这条身体测量记录吗？';

  @override
  String get measurementRecorded => '已记录一次身体测量';

  @override
  String get editMeasurement => '编辑测量';

  @override
  String get createMeasurement => '新建测量';

  @override
  String get coreMeasurements => '核心围度';

  @override
  String get extendedIndicators => '扩展指标';

  @override
  String get measurementDate => '测量日期';

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get enterFullPin => '请输入完整的6位密码';

  @override
  String get setupSecurePassword => '创建安全密码';

  @override
  String get setupPinDescription => '设置 6 位 PIN 以保护你的私密健康数据。';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get enableBiometric => '启用后使用生物识别';

  @override
  String get pinFormatRequired => '请输入 6 位 PIN';

  @override
  String get pinMismatch => '两次输入的密码不一致';

  @override
  String get editDiary => '编辑日记';

  @override
  String get diaryPlaceholder => '今天想说点什么...';

  @override
  String get addTags => '添加标签';

  @override
  String get presetTagHappy => '开心';

  @override
  String get presetTagAnxious => '焦虑';

  @override
  String get presetTagCalm => '平静';

  @override
  String get presetTagTired => '疲惫';

  @override
  String get presetTagHopeful => '充满希望';

  @override
  String get reminderChannelName => '服药提醒';

  @override
  String get reminderChannelDesc => '每日服药提醒通知';

  @override
  String get reminderNotifTitle => 'HanaNote';

  @override
  String get reminderNotifBody => '你有一条提醒';

  @override
  String get milestoneSubtitle => '一路走到这里，已经很了不起了';

  @override
  String get noReadingSummary => '暂无指标摘要';

  @override
  String get medicationStatusTaken => '已记录服用';

  @override
  String get medicationStatusSkipped => '本次已跳过';

  @override
  String get medicationStatusLate => '延迟服用';

  @override
  String get medicationStatusDefault => '服药记录';

  @override
  String medicationLogTitle(String drugName, String dosage) {
    return '服药: $drugName $dosage';
  }

  @override
  String get abbrevBust => '胸';

  @override
  String get abbrevWaist => '腰';

  @override
  String get abbrevHip => '臀';

  @override
  String get editBloodReport => '编辑血检报告';

  @override
  String get addBloodReport => '添加血检报告';

  @override
  String get testDate => '检测日期';

  @override
  String get labName => '检测机构';

  @override
  String get addReading => '添加指标';

  @override
  String get hormoneValue => '数值';

  @override
  String get selectHormone => '选择激素类型';

  @override
  String get atLeastOneReading => '请至少添加一项指标';

  @override
  String get invalidValue => '请输入有效数字';

  @override
  String saveFailed(String message) {
    return '保存失败：$message';
  }

  @override
  String get loadFailed => '加载报告失败';

  @override
  String get knowledgeBase => '用药参考';

  @override
  String get knowledgeBaseSubtitle => '循证安全用药指南';

  @override
  String get openKnowledgeBase => '查看 HRT 药典';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get updateAvailable => '发现新版本';

  @override
  String get updateNow => '立即更新';

  @override
  String get updateLater => '稍后再说';

  @override
  String get privacyPolicyContent =>
      '隐私说明 — Android v1.2.3\n\n更新：2026 年 9 月\n\nHanaNote 将健康记录保存在本机加密数据库中，保存的私密照片也会加密。应用 PIN 用于解锁本地密钥。应用重启后需要输入 PIN；支持生物识别的设备可在同一内存会话内使用生物识别再次解锁。\n\n云账户和同步属于独立的 v2 开发范围，本次 v1 Android 版本未启用。崩溃上报默认关闭，本次构建不包含上报地址。新安装时自动检查更新默认关闭；你可以手动检查，或在设置中主动开启。打开外部知识页面或下载链接会使用网络。\n\n应用排除 Android 系统备份和设备迁移备份。后台遮罩隐藏应用内容；开启应用锁时，普通切后台会返回 PIN 页。主动打开相机、文件选择器和分享面板时会保留发起操作的会话，同时继续隐藏后台内容。应用不从系统相册导入照片。相机拍摄可能生成应用缓存内的临时文件，读取后会删除。\n\n记录备份采用独立密码和 AES-256-GCM 加密，生成 .vault 文件。备份包括药物、方案、服药日志、库存、血检、日记及身体测量；该格式不恢复照片、个人资料和应用设置。请保存好备份密码，我们无法找回。旧版 JSON 备份可通过明确的兼容导入路径读取。\n\nPDF 报告和纪念图片是可直接阅读的导出内容。请只分享给你选择的对象。分享面板返回后，应用删除自己的临时分享副本；接收应用保存或发送的副本不受 HanaNote 控制。\n\n本地通知使用通用文案，不包含药名或剂量。相机、生物识别和通知权限仅服务于对应功能，可在 Android 设置中管理。\n\n联系：https://hrtyaku.com';

  @override
  String get downloadingUpdate => '正在下载更新...';

  @override
  String downloadProgress(String percent) {
    return '已下载 $percent%';
  }

  @override
  String get installUpdate => '安装更新';

  @override
  String get downloadFailed => '下载失败，请重试';

  @override
  String get drugTemplateTitle => '选择药品';

  @override
  String get drugTemplateSubtitle => '点击常用 HRT 药品快速添加，或自定义';

  @override
  String get drugCustomAdd => '手动添加自定义药品';

  @override
  String get updateSectionTitle => '软件更新';

  @override
  String get updateAutoCheck => '自动检查更新';

  @override
  String get updateAutoCheckDesc => '启动时自动检测新版本';

  @override
  String get updateCheckNow => '立即检查更新';

  @override
  String get updateChecking => '正在检查更新...';

  @override
  String get updateAlreadyLatest => '已是最新版本';

  @override
  String get updateCheckFailed => '检查更新失败，请检查网络';

  @override
  String get updateCurrentVersion => '当前版本';

  @override
  String get updateNewVersion => '最新版本';

  @override
  String get updateWhatsNew => '更新内容';

  @override
  String get updateSkipVersion => '跳过此版本';

  @override
  String get updateRetry => '重新下载';

  @override
  String get updateReadyToInstall => '下载完成';

  @override
  String updateEstimatedTime(String time) {
    return '预计剩余 $time';
  }

  @override
  String get webDownloadBannerTitle => '下载 HanaNote Android 版';

  @override
  String get webDownloadBannerSubtitle => '获得完整的原生体验';

  @override
  String get webDownloadButton => '下载';

  @override
  String get downloadApp => '下载应用';

  @override
  String get downloadAndroidApp => '下载 Android 应用';

  @override
  String get downloadAndroidAppDesc => '原生应用获得最佳体验';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingSkipHrt => '稍后设置';

  @override
  String get onboardingDone => '开始使用';

  @override
  String get onboardingDrugOptional => '稍后添加';

  @override
  String get onboardingWelcome => '欢迎来到 HanaNote';

  @override
  String get onboardingWelcomeSub => '你的私密 HRT 健康记录空间';

  @override
  String get onboardingSetName => '你想被怎么称呼？';

  @override
  String get onboardingNameHint => '可以是昵称或别名';

  @override
  String get onboardingNameNote => '随时可以在设置中修改';

  @override
  String get onboardingSetHrtDate => '你的 HRT 起始日是？';

  @override
  String get onboardingAddDrug => '添加你的第一种药物';

  @override
  String get pdfTitle => 'HanaNote 健康报告';

  @override
  String get pdfMedSection => '用药列表';

  @override
  String get pdfBloodSection => '血液检测';

  @override
  String get pdfMeasureSection => '身体围度';

  @override
  String get pdfJournalSection => '近期日记';

  @override
  String get pdfNoData => '暂无数据';

  @override
  String get pdfGenerating => '正在生成 PDF...';

  @override
  String get pdfSuccess => 'PDF 已生成';

  @override
  String get pdfFailed => 'PDF 生成失败';

  @override
  String get pdfPlaintextConfirmTitle => '生成可分享 PDF？';

  @override
  String get pdfPlaintextConfirmMessage =>
      'PDF 是可在 HanaNote 外保存或分享的明文报告。请只在你信任保存位置时继续。';

  @override
  String get pdfPlaintextConfirmAction => '生成 PDF';

  @override
  String get importInProgress => '正在导入...';

  @override
  String importSuccess(int count) {
    return '已导入 $count 项';
  }

  @override
  String get importFailed => '导入失败';

  @override
  String get importPickFile => '选择备份文件';

  @override
  String get importConfirmTitle => '确认导入？';

  @override
  String get importConfirmMessage =>
      '仅导入结构化记录，不恢复照片、个人资料和应用设置。相同 ID 的现有记录可能被替换。';

  @override
  String get importConfirmAction => '导入';

  @override
  String get backupPasswordTitle => '创建备份密码';

  @override
  String get backupPasswordUnlockTitle => '解锁备份';

  @override
  String get backupPasswordRememberWarning =>
      '此备份包含药物、方案、服药日志、库存、血检、日记和身体测量，不含照片与应用设置。备份密码独立于应用 PIN，请妥善保存，HanaNote 无法找回。';

  @override
  String get backupPasswordLabel => '备份密码';

  @override
  String get backupPasswordConfirmLabel => '确认备份密码';

  @override
  String get backupPasswordTooShort => '请至少输入 8 个字符。';

  @override
  String get backupPasswordMismatch => '两次输入的备份密码不一致。';

  @override
  String get backupPasswordCreateAction => '创建加密备份';

  @override
  String get backupPasswordUnlockAction => '解锁备份';

  @override
  String get termsOfUseContent =>
      '使用条款\n\n最后更新：2026年4月\n\n使用 HanaNote（以下简称\"本应用\"），即表示您同意以下使用条款。\n\n1. 用途\n本应用是一款个人健康追踪工具，专为激素替代治疗（HRT）管理而设计。它不是医疗设备，不提供医疗建议。\n\n2. 医疗免责声明\n本应用不能替代专业医疗建议、诊断或治疗。在更改用药方案前，请务必咨询您的医疗服务提供者。药代动力学模拟结果仅供参考。\n\n3. 用户责任\n您对输入的数据的准确性以及设备和应用密码的安全性负责。\n\n4. 数据所有权\n您保留在应用中创建的所有数据的完全所有权。我们不对您的内容主张任何权利。\n\n5. 可用性\n本应用按\"原样\"提供，不附带任何形式的保证。我们不保证不间断或无错误的运行。\n\n6. 责任限制\n在法律允许的最大范围内，本应用的开发者不对因使用或无法使用本应用而产生的任何损害承担责任。\n\n7. 更新\n我们可能会发布更新以改进功能。更新后继续使用即表示接受任何修改后的条款。\n\n8. 适用法律\n本条款受当地适用法律管辖。\n\n9. 联系\n如果您对本条款有任何疑问，请通过我们的官方渠道联系我们。';
}
