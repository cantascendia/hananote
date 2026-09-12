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
  String get onboardingWelcome => 'Welcome to HanaNote';

  @override
  String get onboardingWelcomeSub => 'Let\'s set up your profile';

  @override
  String get onboardingSetName => 'What should we call you?';

  @override
  String get onboardingNameHint => 'Enter your name';

  @override
  String get onboardingNameNote => 'You can change this anytime in settings';

  @override
  String get onboardingSetHrtDate => 'When did you start HRT?';

  @override
  String get onboardingSkipHrt => 'Haven\'t started yet, skip';

  @override
  String get onboardingAddDrug => 'Add your first medication';

  @override
  String get onboardingDrugOptional => 'I\'ll add later';

  @override
  String get onboardingComplete => 'All set!';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingDone => 'Get Started';

  @override
  String get importInProgress => 'Importing...';

  @override
  String get importSuccess => 'Import successful';

  @override
  String get importFailed => 'Import failed';

  @override
  String importedCount(int count) {
    return '$count items imported';
  }

  @override
  String get pdfGenerating => 'Generating report...';

  @override
  String get pdfSuccess => 'Report generated';

  @override
  String get pdfFailed => 'Failed to generate report';

  @override
  String get pdfTitle => 'HanaNote Health Report';

  @override
  String get pdfMedSection => 'Medication Plan';

  @override
  String get pdfBloodSection => 'Blood Test Records';

  @override
  String get pdfMeasureSection => 'Body Measurements';

  @override
  String get pdfJournalSection => 'Mood Diary';

  @override
  String get pdfNoData => 'No data';
}
