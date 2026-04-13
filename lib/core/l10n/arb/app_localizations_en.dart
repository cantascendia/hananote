// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HanaNote';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get closeAction => 'Close';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get addDrug => 'Add Medication';

  @override
  String get editDrug => 'Edit Medication';

  @override
  String get drugName => 'Medication Name';

  @override
  String get genericName => 'Generic Name';

  @override
  String get dosage => 'Dosage';

  @override
  String get frequency => 'Frequency';

  @override
  String get takeDose => 'Take Dose';

  @override
  String get skipDose => 'Skip Dose';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmDeleteDrug =>
      'Delete this medication? This cannot be undone.';

  @override
  String get inventory => 'Inventory';

  @override
  String get remaining => 'Remaining';

  @override
  String get lowStock => 'Low Stock';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String nextTime(String time) {
    return 'Next: $time';
  }

  @override
  String get completedDose => 'Completed';

  @override
  String get noActiveDrugs => 'No active medications';

  @override
  String get addFirstDrug => 'Add your first medication';

  @override
  String get category => 'Category';

  @override
  String get route => 'Route';

  @override
  String get unit => 'Unit';

  @override
  String get notes => 'Notes';

  @override
  String get injectionSite => 'Injection Site';

  @override
  String get patchSite => 'Patch Site';

  @override
  String get quantity => 'Quantity';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get today => 'Today';

  @override
  String get medications => 'Medications';

  @override
  String get photoGallery => 'Encrypted Gallery';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromLibrary => 'Choose from Library';

  @override
  String get photoEmptyTitle => 'No encrypted photos yet';

  @override
  String get photoEmptyDescription =>
      'Your photos are end-to-end encrypted. Only you can see them.';

  @override
  String get photoDeleteTitle => 'Delete photo';

  @override
  String get photoDeleteMessage =>
      'This will delete the encrypted file and its record.';

  @override
  String get retry => 'Retry';

  @override
  String get fileSize => 'File size';

  @override
  String get errorFallbackTitle => 'Something went wrong';

  @override
  String get errorFallbackDescription =>
      'Please reopen the app. If the problem continues, contact support.';

  @override
  String get nextDose => 'Next dose';

  @override
  String get todayCompleted => 'Completed for today ✅';

  @override
  String get hourUnit => 'hours';

  @override
  String get minuteUnit => 'minutes';

  @override
  String hrtDay(int days) {
    return 'HRT Day $days';
  }

  @override
  String get takenDoses => 'Taken doses';

  @override
  String get pendingDoses => 'Pending doses';

  @override
  String get allDay => 'All day';

  @override
  String get noMedicationRecords => 'No medication records yet';

  @override
  String get addFirstDrugCta => 'Add your first medication';

  @override
  String get profile => 'Profile';

  @override
  String get myMedications => 'My Medications';

  @override
  String drugCount(int count) {
    return '$count active';
  }

  @override
  String inventoryDaysRemaining(int days) {
    return '$days days left';
  }

  @override
  String get inventoryDataUnavailable => 'Inventory data unavailable';

  @override
  String inventoryUpdateHint(String unit) {
    return 'New amount ($unit)';
  }

  @override
  String get medicationPlan => 'Medication Plan';

  @override
  String get manageEditSchedules => 'Manage and edit schedules';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get appLock => 'App lock';

  @override
  String get privacyMode => 'Privacy mode';

  @override
  String get privacyModeEnabled => 'Hide app content in recents';

  @override
  String get privacyModeDisabled => 'Show app content in recents';

  @override
  String get wipeAllData => 'Wipe all data';

  @override
  String get wipeAllDataTitle => 'Wipe all data';

  @override
  String get wipeAllDataMessage =>
      'This will permanently delete all encrypted app data and cannot be undone.';

  @override
  String get dataBackup => 'Data backup';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get importBackup => 'Import backup';

  @override
  String get generatePdf => 'Generate PDF';

  @override
  String get backupToolsComingSoon => 'Backup tools are still in development';

  @override
  String get settingsComingSoon => 'Settings are coming soon';

  @override
  String get notificationsComingSoon => 'Notifications are coming soon';

  @override
  String get inventoryComingSoon => 'Inventory management is coming soon';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicyPending =>
      'Privacy policy will be available before release';

  @override
  String get termsPending => 'Terms of use will be available before release';

  @override
  String get timeline => 'Timeline';

  @override
  String get myGrowthTrajectory => 'My Growth Journey';

  @override
  String get noTimelineEvents => 'No timeline events yet';

  @override
  String get logMedication => 'Log medication';

  @override
  String get writeJournal => 'Write journal';

  @override
  String get addBloodTest => 'Add blood test';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get medicationReminders => 'Medication Reminders';

  @override
  String get noActiveReminders => 'No active medication reminders';

  @override
  String get reminderTimes => 'Reminder times';

  @override
  String get exportInProgress => 'Exporting data...';

  @override
  String get exportSuccess => 'Data exported successfully';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get data => 'Data';

  @override
  String get dataAndTrends => 'Data & Trends';

  @override
  String get myStatus => 'My Status';

  @override
  String get bodyChanging => 'Amazing changes are happening…';

  @override
  String get hormoneOverview => 'Hormone overview';

  @override
  String get addReport => 'Add report';

  @override
  String get history => 'History';

  @override
  String get historyReports => 'History Reports';

  @override
  String get pkSimulator => 'PK Simulator';

  @override
  String get pkSimulatorTitle => 'PK Simulation';

  @override
  String get pkSimulatorSubtitle => 'Predict blood drug levels…';

  @override
  String get trendSection => 'Indicator Trends';

  @override
  String get trendStable => 'Recent trend is stable';

  @override
  String get trendDecreasing => 'Decreasing trend';

  @override
  String get lastHalfYear => 'Last 6 months';

  @override
  String get noTrendData => 'No trend data yet';

  @override
  String get filterOneMonth => '1 month';

  @override
  String get filterThreeMonths => '3 months';

  @override
  String get filterSixMonths => '6 months';

  @override
  String get filterOneYear => '1 year';

  @override
  String get filterAll => 'All';

  @override
  String get journeyStart => 'Journey start';

  @override
  String get noUpdatesYet => 'No updates yet';

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get noBloodTestHistory => 'No blood test history yet';

  @override
  String get startDate => 'Start date';

  @override
  String get selectDate => 'Select date';

  @override
  String get endDateOptional => 'End date (optional)';

  @override
  String get noEndDate => 'No end date';

  @override
  String get daily => 'Daily';

  @override
  String get everyNDays => 'Every N days';

  @override
  String get weekly => 'Weekly';

  @override
  String get timesPerDay => 'Times per day:';

  @override
  String get everyPrefix => 'Every ';

  @override
  String get daySuffix => ' days';

  @override
  String get dayOfWeek => 'Day of week:';

  @override
  String get scheduleTimes => 'Schedule times';

  @override
  String get required => 'Required';

  @override
  String get validationDosageRequired => 'Dosage must be greater than zero';

  @override
  String get validationUnitRequired => 'Dosage unit is required';

  @override
  String get validationFrequencyRequired => 'Frequency is required';

  @override
  String get validationStartDateRequired => 'Start date is required';

  @override
  String get validationScheduleTimeRequired =>
      'At least one schedule time is required';

  @override
  String get validationFieldsIncomplete => 'All required fields must be set';

  @override
  String get recordTitle => 'Today\'s Record';

  @override
  String get recordGreeting =>
      'Hello,\nWhat memory would you like to keep today?';

  @override
  String get recordPhoto => 'Photo Record';

  @override
  String get recordPhotoSub => 'Encrypted storage, only you can see';

  @override
  String get recordMeasurement => 'Body Measurements';

  @override
  String get recordMeasurementSub => 'Track every little change';

  @override
  String get recordDiary => 'Mood Diary';

  @override
  String get recordDiarySub => 'What\'s on your mind today?';

  @override
  String get recordDiaryEmpty => 'Start your first diary entry';

  @override
  String get recordPhotoEmpty => 'No photo records yet';

  @override
  String get recordMeasureEmpty => 'No measurement records yet';

  @override
  String recordStreak(int days) {
    return '$days-day streak';
  }

  @override
  String recordLastPhoto(String date) {
    return 'Last: $date';
  }

  @override
  String get recordFooter =>
      'Every record is a gentle promise to your future self';

  @override
  String get defaultUserName => 'HanaNote User';

  @override
  String get dailyQuote0 =>
      'Every step you take will bloom quietly in the future.';

  @override
  String get dailyQuote1 =>
      'Be gentle with yourself today - change is happening.';

  @override
  String get dailyQuote2 =>
      'Every response from your body is proof you\'re living with intention.';

  @override
  String get dailyQuote3 =>
      'It\'s okay to go slow. Steady progress is strength.';

  @override
  String get dailyQuote4 =>
      'Taking meds and keeping records isn\'t a chore - it\'s a promise to yourself.';

  @override
  String get dailyQuote5 =>
      'Grow at your own pace. No need to compare with anyone.';

  @override
  String get dailyQuote6 =>
      'You\'re becoming the person you want to be - that\'s worth celebrating.';

  @override
  String get dailyQuote7 =>
      'Even an ordinary day can shine when you take care of yourself.';

  @override
  String get dailyQuote8 =>
      'Caring for your body isn\'t a burden - it\'s a love letter to your future.';

  @override
  String get dailyQuote9 =>
      'Today\'s patience becomes tomorrow\'s peace of mind.';

  @override
  String get dailyQuote10 =>
      'Every record isn\'t repetition - it\'s seeing your true self.';

  @override
  String get dailyQuote11 =>
      'Don\'t forget to be proud of yourself. You\'re doing great.';

  @override
  String get enumCatEstrogen => 'Estrogen';

  @override
  String get enumCatAntiAndrogen => 'Anti-androgen';

  @override
  String get enumCatProgestogen => 'Progestogen';

  @override
  String get enumCatAuxiliary => 'Auxiliary';

  @override
  String get enumRouteOral => 'Oral';

  @override
  String get enumRouteSublingual => 'Sublingual';

  @override
  String get enumRoutePatch => 'Patch';

  @override
  String get enumRouteGel => 'Gel';

  @override
  String get enumRouteIM => 'Intramuscular';

  @override
  String get enumRouteSC => 'Subcutaneous';

  @override
  String get enumRouteRectal => 'Rectal';

  @override
  String get enumUnitPump => 'pump';

  @override
  String get enumUnitPatch => 'patch';

  @override
  String get enumHormoneEstradiol => 'Estradiol';

  @override
  String get enumHormoneTestosterone => 'Testosterone';

  @override
  String get enumHormoneProlactin => 'Prolactin';

  @override
  String get enumHormoneProgesterone => 'Progesterone';

  @override
  String get enumStatusNormal => 'Normal';

  @override
  String get enumStatusWarning => 'Off target';

  @override
  String get enumStatusCritical => 'Needs attention';

  @override
  String get enumTimelineMedication => 'Medication';

  @override
  String get enumTimelineBloodTest => 'Blood Test';

  @override
  String get enumTimelineJournal => 'Journal';

  @override
  String get enumTimelineMilestone => 'Milestone';

  @override
  String get featureComingSoon => 'This feature is coming soon';

  @override
  String get weekdayMonday => 'Mon';

  @override
  String get weekdayTuesday => 'Tue';

  @override
  String get weekdayWednesday => 'Wed';

  @override
  String get weekdayThursday => 'Thu';

  @override
  String get weekdayFriday => 'Fri';

  @override
  String get weekdaySaturday => 'Sat';

  @override
  String get weekdaySunday => 'Sun';

  @override
  String get tabToday => 'Today';

  @override
  String get tabRecord => 'Record';

  @override
  String get tabTimeline => 'Timeline';

  @override
  String get tabData => 'Data';

  @override
  String get tabProfile => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get globalNotification => 'Global Notifications';

  @override
  String get reminderEnabled => 'Enabled';

  @override
  String get reminderDisabled => 'Disabled';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get editDisplayName => 'Edit Display Name';

  @override
  String get editHrtStartDate => 'Edit HRT Start Date';

  @override
  String get appearance => 'Appearance';

  @override
  String get languageSetting => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeComingSoon => 'Dark Mode coming soon';

  @override
  String get featureInDevelopment => 'Under Development';

  @override
  String get featureInDevelopmentDesc =>
      'This feature is under development and will be available in the next release';

  @override
  String get enumMeasureBust => 'Bust';

  @override
  String get enumMeasureUnderbust => 'Underbust';

  @override
  String get enumMeasureWaist => 'Waist';

  @override
  String get enumMeasureHip => 'Hip';

  @override
  String get enumMeasureThigh => 'Thigh';

  @override
  String get enumMeasureUpperArm => 'Upper Arm';

  @override
  String get enumMeasureShoulder => 'Shoulder';

  @override
  String get enumMeasureNeck => 'Neck';

  @override
  String get enumMeasureWeight => 'Weight';

  @override
  String get enumMoodVeryBad => 'Very bad';

  @override
  String get enumMoodBad => 'Not great';

  @override
  String get enumMoodNeutral => 'Neutral';

  @override
  String get enumMoodGood => 'Good';

  @override
  String get enumMoodVeryGood => 'Very good';

  @override
  String get enumEsterValerate => 'Estradiol Valerate (IM)';

  @override
  String get enumEsterCypionate => 'Estradiol Cypionate (IM)';

  @override
  String get enumEsterEnanthate => 'Estradiol Enanthate (IM)';

  @override
  String get enumEsterOral => 'Oral Estradiol';

  @override
  String get enumEsterSublingual => 'Sublingual Estradiol';

  @override
  String get enumEsterPatch => 'Estradiol Patch';

  @override
  String get enumEsterGel => 'Estradiol Gel';

  @override
  String get toggleHanaPkEngine => 'Toggle Hana-PK Experimental Engine';

  @override
  String get simulatorDisclaimer =>
      'Disclaimer: Simulation results are based on pharmacokinetic models and are for reference only. They do not constitute medical advice. Due to individual differences (metabolism, weight, injection site fat ratio), actual blood levels may vary significantly. Always consult your doctor before adjusting your regimen.';

  @override
  String get simulatorSchemeParams => 'Regimen Parameters';

  @override
  String get simulatorDrugType => 'Drug Type';

  @override
  String get simulatorSingleDose => 'Single Dose (mg)';

  @override
  String get simulatorInterval => 'Interval (days)';

  @override
  String get simulatorWeight => 'Body Weight (kg)';

  @override
  String get simulatorPatchWear => 'Patch Wear (days)';

  @override
  String get simulatorSublingualHold => 'Sublingual Hold Time';

  @override
  String get holdTimeVeryFast => 'Very fast';

  @override
  String get holdTimeCasual => 'Casual';

  @override
  String get holdTimeStandard => 'Standard';

  @override
  String get holdTimeStrict => 'Strict';

  @override
  String get updateSimulation => 'Update Simulation';

  @override
  String get concentrationCurve => 'Concentration-Time Curve';

  @override
  String get hanaPkLabel => 'Hana-PK';

  @override
  String get v2StandardLabel => 'V2 Standard';

  @override
  String get chartAxisLabel => 'Y: Systemic E2 (pg/mL)   X: Days';

  @override
  String get steadyStateSummary => 'Steady-State Summary';

  @override
  String get peakLabel => 'Peak';

  @override
  String get troughLabel => 'Trough';

  @override
  String get averageLabel => 'Average';

  @override
  String reachSteadyDays(String days) {
    return 'Steady state: $days days';
  }

  @override
  String get bodyMeasurementsTitle => 'Body Measurements';

  @override
  String get newMeasurement => 'New Measurement';

  @override
  String get startRecordingChanges => 'Start recording your body changes';

  @override
  String get measurementEmptyHint =>
      'After your first measurement, you\'ll see your history here.';

  @override
  String get deleteMeasurementTitle => 'Delete Measurement';

  @override
  String get deleteMeasurementConfirm => 'Delete this body measurement record?';

  @override
  String get measurementRecorded => 'Measurement recorded';

  @override
  String get editMeasurement => 'Edit Measurement';

  @override
  String get createMeasurement => 'New Measurement';

  @override
  String get coreMeasurements => 'Core Measurements';

  @override
  String get extendedIndicators => 'Extended Indicators';

  @override
  String get measurementDate => 'Measurement Date';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get enterFullPin => 'Please enter the full 6-digit PIN';

  @override
  String get setupSecurePassword => 'Create Secure Password';

  @override
  String get setupPinDescription =>
      'Set a 6-digit PIN to protect your private health data.';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get enableBiometric => 'Enable biometric unlock';

  @override
  String get pinFormatRequired => 'Please enter a 6-digit PIN';

  @override
  String get pinMismatch => 'PINs do not match';

  @override
  String get editDiary => 'Edit Diary';

  @override
  String get diaryPlaceholder => 'What\'s on your mind today...';

  @override
  String get addTags => 'Add Tags';

  @override
  String get presetTagHappy => 'Happy';

  @override
  String get presetTagAnxious => 'Anxious';

  @override
  String get presetTagCalm => 'Calm';

  @override
  String get presetTagTired => 'Tired';

  @override
  String get presetTagHopeful => 'Hopeful';

  @override
  String get reminderChannelName => 'Medication Reminder';

  @override
  String get reminderChannelDesc => 'Daily medication reminder notifications';

  @override
  String get reminderNotifTitle => 'HanaNote Medication Reminder';

  @override
  String reminderNotifBody(String drugName, String dosage, String unit) {
    return '$drugName $dosage$unit — Time to take your meds 💊';
  }

  @override
  String get milestoneSubtitle => 'You\'ve come so far — that\'s amazing';

  @override
  String get noReadingSummary => 'No reading summary';

  @override
  String get medicationStatusTaken => 'Taken';

  @override
  String get medicationStatusSkipped => 'Skipped';

  @override
  String get medicationStatusLate => 'Taken late';

  @override
  String get medicationStatusDefault => 'Medication log';

  @override
  String medicationLogTitle(String drugName, String dosage) {
    return 'Medication: $drugName $dosage';
  }

  @override
  String get abbrevBust => 'Bust';

  @override
  String get abbrevWaist => 'Waist';

  @override
  String get abbrevHip => 'Hip';

  @override
  String get editBloodReport => 'Edit Blood Report';

  @override
  String get addBloodReport => 'Add Blood Report';

  @override
  String get testDate => 'Test Date';

  @override
  String get labName => 'Lab / Clinic';

  @override
  String get addReading => 'Add Reading';

  @override
  String get hormoneValue => 'Value';

  @override
  String get selectHormone => 'Select Hormone';

  @override
  String get atLeastOneReading => 'Add at least one reading';

  @override
  String get invalidValue => 'Enter a valid number';

  @override
  String saveFailed(String message) {
    return 'Save failed: $message';
  }

  @override
  String get loadFailed => 'Failed to load report';

  @override
  String get knowledgeBase => 'Drug Reference';

  @override
  String get knowledgeBaseSubtitle => 'Evidence-based HRT safety guide';

  @override
  String get openKnowledgeBase => 'Open HRT Reference';

  @override
  String get languageSystem => 'System';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updateLater => 'Later';

  @override
  String get privacyPolicyContent =>
      'Privacy Policy\n\nLast updated: April 2026\n\nHanaNote (\"the App\") is committed to protecting your privacy. This Privacy Policy explains how we handle your information.\n\n1. Data Storage\nAll personal health data, including medication records, journal entries, body measurements, photos, and blood test results, is stored locally on your device. We do not transmit your health data to any external servers.\n\n2. Encryption\nYour data is encrypted using industry-standard encryption. Photos are end-to-end encrypted and can only be viewed by you.\n\n3. Data Collection\nThe App does not collect, share, or sell any personally identifiable information. We do not use analytics trackers or advertising SDKs.\n\n4. Permissions\nThe App may request access to your camera (for photo records), biometric sensor (for app lock), and notification system (for medication reminders). These permissions are used solely for the stated purposes.\n\n5. Data Export\nYou may export your data at any time using the built-in export feature. You retain full ownership of your data.\n\n6. Data Deletion\nYou may permanently delete all data using the \"Wipe all data\" option in Settings. This action is irreversible.\n\n7. Changes\nWe may update this Privacy Policy from time to time. Continued use of the App constitutes acceptance of the updated policy.\n\n8. Contact\nIf you have questions about this Privacy Policy, please contact us through our official channels.';

  @override
  String get downloadingUpdate => 'Downloading update...';

  @override
  String downloadProgress(String percent) {
    return 'Downloaded $percent%';
  }

  @override
  String get installUpdate => 'Install Update';

  @override
  String get downloadFailed => 'Download failed, please retry';

  @override
  String get drugTemplateTitle => 'Select Medication';

  @override
  String get drugTemplateSubtitle =>
      'Tap a common HRT medication to add quickly, or create custom';

  @override
  String get drugCustomAdd => 'Add custom medication';

  @override
  String get updateSectionTitle => 'Software Updates';

  @override
  String get updateAutoCheck => 'Auto-check for updates';

  @override
  String get updateAutoCheckDesc => 'Check for new versions on launch';

  @override
  String get updateCheckNow => 'Check for updates';

  @override
  String get updateChecking => 'Checking for updates...';

  @override
  String get updateAlreadyLatest => 'You\'re on the latest version';

  @override
  String get updateCheckFailed =>
      'Update check failed, please check your network';

  @override
  String get updateCurrentVersion => 'Current';

  @override
  String get updateNewVersion => 'New';

  @override
  String get updateWhatsNew => 'WHAT\'S NEW';

  @override
  String get updateSkipVersion => 'Skip this version';

  @override
  String get updateRetry => 'Retry download';

  @override
  String get updateReadyToInstall => 'Ready to install';

  @override
  String updateEstimatedTime(String time) {
    return 'About $time remaining';
  }

  @override
  String get webDownloadBannerTitle => 'Download HanaNote for Android';

  @override
  String get webDownloadBannerSubtitle => 'Get the full native experience';

  @override
  String get webDownloadButton => 'Download';

  @override
  String get downloadApp => 'Download App';

  @override
  String get downloadAndroidApp => 'Download Android App';

  @override
  String get downloadAndroidAppDesc => 'Native app for the best experience';

  @override
  String get termsOfUseContent =>
      'Terms of Use\n\nLast updated: April 2026\n\nBy using HanaNote (\"the App\"), you agree to these Terms of Use.\n\n1. Purpose\nThe App is a personal health tracking tool designed for hormone replacement therapy (HRT) management. It is not a medical device and does not provide medical advice.\n\n2. Medical Disclaimer\nThe App is not a substitute for professional medical advice, diagnosis, or treatment. Always consult your healthcare provider before making changes to your medication regimen. Pharmacokinetic simulation results are for reference only.\n\n3. User Responsibility\nYou are responsible for the accuracy of data you enter and for maintaining the security of your device and app password.\n\n4. Data Ownership\nYou retain full ownership of all data you create within the App. We do not claim any rights to your content.\n\n5. Availability\nThe App is provided \"as is\" without warranty of any kind. We do not guarantee uninterrupted or error-free operation.\n\n6. Limitation of Liability\nTo the maximum extent permitted by law, the developers of the App shall not be liable for any damages arising from the use or inability to use the App.\n\n7. Updates\nWe may release updates to improve functionality. Continued use after updates constitutes acceptance of any modified terms.\n\n8. Governing Law\nThese terms shall be governed by applicable local laws.\n\n9. Contact\nFor questions about these Terms, please contact us through our official channels.';
}
