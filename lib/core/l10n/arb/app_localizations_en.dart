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
  String get noTimelineEvents => 'No timeline events yet';

  @override
  String get logMedication => 'Log medication';

  @override
  String get writeJournal => 'Write journal';

  @override
  String get addBloodTest => 'Add blood test';

  @override
  String get data => 'Data';

  @override
  String get hormoneOverview => 'Hormone overview';

  @override
  String get addReport => 'Add report';

  @override
  String get history => 'History';

  @override
  String get pkSimulator => 'PK Simulator';

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
  String get tabToday => 'Today';

  @override
  String get tabRecord => 'Record';

  @override
  String get tabTimeline => 'Timeline';

  @override
  String get tabData => 'Data';

  @override
  String get tabProfile => 'Profile';
}
