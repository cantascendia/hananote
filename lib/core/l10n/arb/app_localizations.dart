import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HanaNote'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @addDrug.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addDrug;

  /// No description provided for @editDrug.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get editDrug;

  /// No description provided for @drugName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get drugName;

  /// No description provided for @genericName.
  ///
  /// In en, this message translates to:
  /// **'Generic Name'**
  String get genericName;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @takeDose.
  ///
  /// In en, this message translates to:
  /// **'Take Dose'**
  String get takeDose;

  /// No description provided for @skipDose.
  ///
  /// In en, this message translates to:
  /// **'Skip Dose'**
  String get skipDose;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmDeleteDrug.
  ///
  /// In en, this message translates to:
  /// **'Delete this medication? This cannot be undone.'**
  String get confirmDeleteDrug;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(int days);

  /// No description provided for @nextTime.
  ///
  /// In en, this message translates to:
  /// **'Next: {time}'**
  String nextTime(String time);

  /// No description provided for @completedDose.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedDose;

  /// No description provided for @noActiveDrugs.
  ///
  /// In en, this message translates to:
  /// **'No active medications'**
  String get noActiveDrugs;

  /// No description provided for @addFirstDrug.
  ///
  /// In en, this message translates to:
  /// **'Add your first medication'**
  String get addFirstDrug;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @injectionSite.
  ///
  /// In en, this message translates to:
  /// **'Injection Site'**
  String get injectionSite;

  /// No description provided for @patchSite.
  ///
  /// In en, this message translates to:
  /// **'Patch Site'**
  String get patchSite;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Gallery'**
  String get photoGallery;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from Library'**
  String get chooseFromLibrary;

  /// No description provided for @photoEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No encrypted photos yet'**
  String get photoEmptyTitle;

  /// No description provided for @photoEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your photos are end-to-end encrypted. Only you can see them.'**
  String get photoEmptyDescription;

  /// No description provided for @photoDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get photoDeleteTitle;

  /// No description provided for @photoDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete the encrypted file and its record.'**
  String get photoDeleteMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get fileSize;

  /// No description provided for @errorFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorFallbackTitle;

  /// No description provided for @errorFallbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Please reopen the app. If the problem continues, contact support.'**
  String get errorFallbackDescription;

  /// No description provided for @nextDose.
  ///
  /// In en, this message translates to:
  /// **'Next dose'**
  String get nextDose;

  /// No description provided for @todayCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed for today ✅'**
  String get todayCompleted;

  /// No description provided for @hourUnit.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hourUnit;

  /// No description provided for @minuteUnit.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minuteUnit;

  /// No description provided for @hrtDay.
  ///
  /// In en, this message translates to:
  /// **'HRT Day {days}'**
  String hrtDay(int days);

  /// No description provided for @takenDoses.
  ///
  /// In en, this message translates to:
  /// **'Taken doses'**
  String get takenDoses;

  /// No description provided for @pendingDoses.
  ///
  /// In en, this message translates to:
  /// **'Pending doses'**
  String get pendingDoses;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @noMedicationRecords.
  ///
  /// In en, this message translates to:
  /// **'No medication records yet'**
  String get noMedicationRecords;

  /// No description provided for @addFirstDrugCta.
  ///
  /// In en, this message translates to:
  /// **'Add your first medication'**
  String get addFirstDrugCta;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @myMedications.
  ///
  /// In en, this message translates to:
  /// **'My Medications'**
  String get myMedications;

  /// No description provided for @drugCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String drugCount(int count);

  /// No description provided for @inventoryDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String inventoryDaysRemaining(int days);

  /// No description provided for @inventoryDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Inventory data unavailable'**
  String get inventoryDataUnavailable;

  /// No description provided for @inventoryUpdateHint.
  ///
  /// In en, this message translates to:
  /// **'New amount ({unit})'**
  String inventoryUpdateHint(String unit);

  /// No description provided for @medicationPlan.
  ///
  /// In en, this message translates to:
  /// **'Medication Plan'**
  String get medicationPlan;

  /// No description provided for @manageEditSchedules.
  ///
  /// In en, this message translates to:
  /// **'Manage and edit schedules'**
  String get manageEditSchedules;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @privacyMode.
  ///
  /// In en, this message translates to:
  /// **'Privacy mode'**
  String get privacyMode;

  /// No description provided for @privacyModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Hide app content in recents'**
  String get privacyModeEnabled;

  /// No description provided for @privacyModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Show app content in recents'**
  String get privacyModeDisabled;

  /// No description provided for @wipeAllData.
  ///
  /// In en, this message translates to:
  /// **'Wipe all data'**
  String get wipeAllData;

  /// No description provided for @wipeAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Wipe all data'**
  String get wipeAllDataTitle;

  /// No description provided for @wipeAllDataMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all encrypted app data and cannot be undone.'**
  String get wipeAllDataMessage;

  /// No description provided for @dataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data backup'**
  String get dataBackup;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importBackup;

  /// No description provided for @generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePdf;

  /// No description provided for @backupToolsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Backup tools are still in development'**
  String get backupToolsComingSoon;

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Settings are coming soon'**
  String get settingsComingSoon;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications are coming soon'**
  String get notificationsComingSoon;

  /// No description provided for @inventoryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Inventory management is coming soon'**
  String get inventoryComingSoon;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicyPending.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy will be available before release'**
  String get privacyPolicyPending;

  /// No description provided for @termsPending.
  ///
  /// In en, this message translates to:
  /// **'Terms of use will be available before release'**
  String get termsPending;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @myGrowthTrajectory.
  ///
  /// In en, this message translates to:
  /// **'My Growth Journey'**
  String get myGrowthTrajectory;

  /// No description provided for @noTimelineEvents.
  ///
  /// In en, this message translates to:
  /// **'No timeline events yet'**
  String get noTimelineEvents;

  /// No description provided for @logMedication.
  ///
  /// In en, this message translates to:
  /// **'Log medication'**
  String get logMedication;

  /// No description provided for @writeJournal.
  ///
  /// In en, this message translates to:
  /// **'Write journal'**
  String get writeJournal;

  /// No description provided for @addBloodTest.
  ///
  /// In en, this message translates to:
  /// **'Add blood test'**
  String get addBloodTest;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @medicationReminders.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminders'**
  String get medicationReminders;

  /// No description provided for @noActiveReminders.
  ///
  /// In en, this message translates to:
  /// **'No active medication reminders'**
  String get noActiveReminders;

  /// No description provided for @reminderTimes.
  ///
  /// In en, this message translates to:
  /// **'Reminder times'**
  String get reminderTimes;

  /// No description provided for @exportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Exporting data...'**
  String get exportInProgress;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @dataAndTrends.
  ///
  /// In en, this message translates to:
  /// **'Data & Trends'**
  String get dataAndTrends;

  /// No description provided for @myStatus.
  ///
  /// In en, this message translates to:
  /// **'My Status'**
  String get myStatus;

  /// No description provided for @bodyChanging.
  ///
  /// In en, this message translates to:
  /// **'Amazing changes are happening…'**
  String get bodyChanging;

  /// No description provided for @hormoneOverview.
  ///
  /// In en, this message translates to:
  /// **'Hormone overview'**
  String get hormoneOverview;

  /// No description provided for @addReport.
  ///
  /// In en, this message translates to:
  /// **'Add report'**
  String get addReport;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @historyReports.
  ///
  /// In en, this message translates to:
  /// **'History Reports'**
  String get historyReports;

  /// No description provided for @pkSimulator.
  ///
  /// In en, this message translates to:
  /// **'PK Simulator'**
  String get pkSimulator;

  /// No description provided for @pkSimulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'PK Simulation'**
  String get pkSimulatorTitle;

  /// No description provided for @pkSimulatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Predict blood drug levels…'**
  String get pkSimulatorSubtitle;

  /// No description provided for @trendSection.
  ///
  /// In en, this message translates to:
  /// **'Indicator Trends'**
  String get trendSection;

  /// No description provided for @trendStable.
  ///
  /// In en, this message translates to:
  /// **'Recent trend is stable'**
  String get trendStable;

  /// No description provided for @trendDecreasing.
  ///
  /// In en, this message translates to:
  /// **'Decreasing trend'**
  String get trendDecreasing;

  /// No description provided for @lastHalfYear.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get lastHalfYear;

  /// No description provided for @noTrendData.
  ///
  /// In en, this message translates to:
  /// **'No trend data yet'**
  String get noTrendData;

  /// No description provided for @filterOneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get filterOneMonth;

  /// No description provided for @filterThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get filterThreeMonths;

  /// No description provided for @filterSixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get filterSixMonths;

  /// No description provided for @filterOneYear.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get filterOneYear;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @journeyStart.
  ///
  /// In en, this message translates to:
  /// **'Journey start'**
  String get journeyStart;

  /// No description provided for @noUpdatesYet.
  ///
  /// In en, this message translates to:
  /// **'No updates yet'**
  String get noUpdatesYet;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @noBloodTestHistory.
  ///
  /// In en, this message translates to:
  /// **'No blood test history yet'**
  String get noBloodTestHistory;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @endDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End date (optional)'**
  String get endDateOptional;

  /// No description provided for @noEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDate;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @everyNDays.
  ///
  /// In en, this message translates to:
  /// **'Every N days'**
  String get everyNDays;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @timesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Times per day:'**
  String get timesPerDay;

  /// No description provided for @everyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Every '**
  String get everyPrefix;

  /// No description provided for @daySuffix.
  ///
  /// In en, this message translates to:
  /// **' days'**
  String get daySuffix;

  /// No description provided for @dayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Day of week:'**
  String get dayOfWeek;

  /// No description provided for @scheduleTimes.
  ///
  /// In en, this message translates to:
  /// **'Schedule times'**
  String get scheduleTimes;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @validationDosageRequired.
  ///
  /// In en, this message translates to:
  /// **'Dosage must be greater than zero'**
  String get validationDosageRequired;

  /// No description provided for @validationUnitRequired.
  ///
  /// In en, this message translates to:
  /// **'Dosage unit is required'**
  String get validationUnitRequired;

  /// No description provided for @validationFrequencyRequired.
  ///
  /// In en, this message translates to:
  /// **'Frequency is required'**
  String get validationFrequencyRequired;

  /// No description provided for @validationStartDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Start date is required'**
  String get validationStartDateRequired;

  /// No description provided for @validationScheduleTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one schedule time is required'**
  String get validationScheduleTimeRequired;

  /// No description provided for @validationFieldsIncomplete.
  ///
  /// In en, this message translates to:
  /// **'All required fields must be set'**
  String get validationFieldsIncomplete;

  /// No description provided for @recordTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Record'**
  String get recordTitle;

  /// No description provided for @recordGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello,\nWhat memory would you like to keep today?'**
  String get recordGreeting;

  /// No description provided for @recordPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo Record'**
  String get recordPhoto;

  /// No description provided for @recordPhotoSub.
  ///
  /// In en, this message translates to:
  /// **'Encrypted storage, only you can see'**
  String get recordPhotoSub;

  /// No description provided for @recordMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get recordMeasurement;

  /// No description provided for @recordMeasurementSub.
  ///
  /// In en, this message translates to:
  /// **'Track every little change'**
  String get recordMeasurementSub;

  /// No description provided for @recordDiary.
  ///
  /// In en, this message translates to:
  /// **'Mood Diary'**
  String get recordDiary;

  /// No description provided for @recordDiarySub.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind today?'**
  String get recordDiarySub;

  /// No description provided for @recordDiaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Start your first diary entry'**
  String get recordDiaryEmpty;

  /// No description provided for @recordPhotoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No photo records yet'**
  String get recordPhotoEmpty;

  /// No description provided for @recordMeasureEmpty.
  ///
  /// In en, this message translates to:
  /// **'No measurement records yet'**
  String get recordMeasureEmpty;

  /// No description provided for @recordStreak.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak'**
  String recordStreak(int days);

  /// No description provided for @recordLastPhoto.
  ///
  /// In en, this message translates to:
  /// **'Last: {date}'**
  String recordLastPhoto(String date);

  /// No description provided for @recordFooter.
  ///
  /// In en, this message translates to:
  /// **'Every record is a gentle promise to your future self'**
  String get recordFooter;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'HanaNote User'**
  String get defaultUserName;

  /// No description provided for @dailyQuote0.
  ///
  /// In en, this message translates to:
  /// **'Every step you take will bloom quietly in the future.'**
  String get dailyQuote0;

  /// No description provided for @dailyQuote1.
  ///
  /// In en, this message translates to:
  /// **'Be gentle with yourself today - change is happening.'**
  String get dailyQuote1;

  /// No description provided for @dailyQuote2.
  ///
  /// In en, this message translates to:
  /// **'Every response from your body is proof you\'re living with intention.'**
  String get dailyQuote2;

  /// No description provided for @dailyQuote3.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay to go slow. Steady progress is strength.'**
  String get dailyQuote3;

  /// No description provided for @dailyQuote4.
  ///
  /// In en, this message translates to:
  /// **'Taking meds and keeping records isn\'t a chore - it\'s a promise to yourself.'**
  String get dailyQuote4;

  /// No description provided for @dailyQuote5.
  ///
  /// In en, this message translates to:
  /// **'Grow at your own pace. No need to compare with anyone.'**
  String get dailyQuote5;

  /// No description provided for @dailyQuote6.
  ///
  /// In en, this message translates to:
  /// **'You\'re becoming the person you want to be - that\'s worth celebrating.'**
  String get dailyQuote6;

  /// No description provided for @dailyQuote7.
  ///
  /// In en, this message translates to:
  /// **'Even an ordinary day can shine when you take care of yourself.'**
  String get dailyQuote7;

  /// No description provided for @dailyQuote8.
  ///
  /// In en, this message translates to:
  /// **'Caring for your body isn\'t a burden - it\'s a love letter to your future.'**
  String get dailyQuote8;

  /// No description provided for @dailyQuote9.
  ///
  /// In en, this message translates to:
  /// **'Today\'s patience becomes tomorrow\'s peace of mind.'**
  String get dailyQuote9;

  /// No description provided for @dailyQuote10.
  ///
  /// In en, this message translates to:
  /// **'Every record isn\'t repetition - it\'s seeing your true self.'**
  String get dailyQuote10;

  /// No description provided for @dailyQuote11.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to be proud of yourself. You\'re doing great.'**
  String get dailyQuote11;

  /// No description provided for @enumCatEstrogen.
  ///
  /// In en, this message translates to:
  /// **'Estrogen'**
  String get enumCatEstrogen;

  /// No description provided for @enumCatAntiAndrogen.
  ///
  /// In en, this message translates to:
  /// **'Anti-androgen'**
  String get enumCatAntiAndrogen;

  /// No description provided for @enumCatProgestogen.
  ///
  /// In en, this message translates to:
  /// **'Progestogen'**
  String get enumCatProgestogen;

  /// No description provided for @enumCatAuxiliary.
  ///
  /// In en, this message translates to:
  /// **'Auxiliary'**
  String get enumCatAuxiliary;

  /// No description provided for @enumRouteOral.
  ///
  /// In en, this message translates to:
  /// **'Oral'**
  String get enumRouteOral;

  /// No description provided for @enumRouteSublingual.
  ///
  /// In en, this message translates to:
  /// **'Sublingual'**
  String get enumRouteSublingual;

  /// No description provided for @enumRoutePatch.
  ///
  /// In en, this message translates to:
  /// **'Patch'**
  String get enumRoutePatch;

  /// No description provided for @enumRouteGel.
  ///
  /// In en, this message translates to:
  /// **'Gel'**
  String get enumRouteGel;

  /// No description provided for @enumRouteIM.
  ///
  /// In en, this message translates to:
  /// **'Intramuscular'**
  String get enumRouteIM;

  /// No description provided for @enumRouteSC.
  ///
  /// In en, this message translates to:
  /// **'Subcutaneous'**
  String get enumRouteSC;

  /// No description provided for @enumRouteRectal.
  ///
  /// In en, this message translates to:
  /// **'Rectal'**
  String get enumRouteRectal;

  /// No description provided for @enumUnitPump.
  ///
  /// In en, this message translates to:
  /// **'pump'**
  String get enumUnitPump;

  /// No description provided for @enumUnitPatch.
  ///
  /// In en, this message translates to:
  /// **'patch'**
  String get enumUnitPatch;

  /// No description provided for @enumHormoneEstradiol.
  ///
  /// In en, this message translates to:
  /// **'Estradiol'**
  String get enumHormoneEstradiol;

  /// No description provided for @enumHormoneTestosterone.
  ///
  /// In en, this message translates to:
  /// **'Testosterone'**
  String get enumHormoneTestosterone;

  /// No description provided for @enumHormoneProlactin.
  ///
  /// In en, this message translates to:
  /// **'Prolactin'**
  String get enumHormoneProlactin;

  /// No description provided for @enumHormoneProgesterone.
  ///
  /// In en, this message translates to:
  /// **'Progesterone'**
  String get enumHormoneProgesterone;

  /// No description provided for @enumStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get enumStatusNormal;

  /// No description provided for @enumStatusWarning.
  ///
  /// In en, this message translates to:
  /// **'Off target'**
  String get enumStatusWarning;

  /// No description provided for @enumStatusCritical.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get enumStatusCritical;

  /// No description provided for @enumTimelineMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get enumTimelineMedication;

  /// No description provided for @enumTimelineBloodTest.
  ///
  /// In en, this message translates to:
  /// **'Blood Test'**
  String get enumTimelineBloodTest;

  /// No description provided for @enumTimelineJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get enumTimelineJournal;

  /// No description provided for @enumTimelineMilestone.
  ///
  /// In en, this message translates to:
  /// **'Milestone'**
  String get enumTimelineMilestone;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon'**
  String get featureComingSoon;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySunday;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get tabRecord;

  /// No description provided for @tabTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get tabTimeline;

  /// No description provided for @tabData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get tabData;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @globalNotification.
  ///
  /// In en, this message translates to:
  /// **'Global Notifications'**
  String get globalNotification;

  /// No description provided for @reminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get reminderEnabled;

  /// No description provided for @reminderDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get reminderDisabled;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @editDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Edit Display Name'**
  String get editDisplayName;

  /// No description provided for @editHrtStartDate.
  ///
  /// In en, this message translates to:
  /// **'Edit HRT Start Date'**
  String get editHrtStartDate;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode coming soon'**
  String get darkModeComingSoon;

  /// No description provided for @featureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Under Development'**
  String get featureInDevelopment;

  /// No description provided for @featureInDevelopmentDesc.
  ///
  /// In en, this message translates to:
  /// **'This feature is under development and will be available in the next release'**
  String get featureInDevelopmentDesc;

  /// No description provided for @enumMeasureBust.
  ///
  /// In en, this message translates to:
  /// **'Bust'**
  String get enumMeasureBust;

  /// No description provided for @enumMeasureUnderbust.
  ///
  /// In en, this message translates to:
  /// **'Underbust'**
  String get enumMeasureUnderbust;

  /// No description provided for @enumMeasureWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get enumMeasureWaist;

  /// No description provided for @enumMeasureHip.
  ///
  /// In en, this message translates to:
  /// **'Hip'**
  String get enumMeasureHip;

  /// No description provided for @enumMeasureThigh.
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get enumMeasureThigh;

  /// No description provided for @enumMeasureUpperArm.
  ///
  /// In en, this message translates to:
  /// **'Upper Arm'**
  String get enumMeasureUpperArm;

  /// No description provided for @enumMeasureShoulder.
  ///
  /// In en, this message translates to:
  /// **'Shoulder'**
  String get enumMeasureShoulder;

  /// No description provided for @enumMeasureNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get enumMeasureNeck;

  /// No description provided for @enumMeasureWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get enumMeasureWeight;

  /// No description provided for @enumMoodVeryBad.
  ///
  /// In en, this message translates to:
  /// **'Very bad'**
  String get enumMoodVeryBad;

  /// No description provided for @enumMoodBad.
  ///
  /// In en, this message translates to:
  /// **'Not great'**
  String get enumMoodBad;

  /// No description provided for @enumMoodNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get enumMoodNeutral;

  /// No description provided for @enumMoodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get enumMoodGood;

  /// No description provided for @enumMoodVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get enumMoodVeryGood;

  /// No description provided for @enumEsterValerate.
  ///
  /// In en, this message translates to:
  /// **'Estradiol Valerate (IM)'**
  String get enumEsterValerate;

  /// No description provided for @enumEsterCypionate.
  ///
  /// In en, this message translates to:
  /// **'Estradiol Cypionate (IM)'**
  String get enumEsterCypionate;

  /// No description provided for @enumEsterEnanthate.
  ///
  /// In en, this message translates to:
  /// **'Estradiol Enanthate (IM)'**
  String get enumEsterEnanthate;

  /// No description provided for @enumEsterOral.
  ///
  /// In en, this message translates to:
  /// **'Oral Estradiol'**
  String get enumEsterOral;

  /// No description provided for @enumEsterSublingual.
  ///
  /// In en, this message translates to:
  /// **'Sublingual Estradiol'**
  String get enumEsterSublingual;

  /// No description provided for @enumEsterPatch.
  ///
  /// In en, this message translates to:
  /// **'Estradiol Patch'**
  String get enumEsterPatch;

  /// No description provided for @enumEsterGel.
  ///
  /// In en, this message translates to:
  /// **'Estradiol Gel'**
  String get enumEsterGel;

  /// No description provided for @toggleHanaPkEngine.
  ///
  /// In en, this message translates to:
  /// **'Toggle Hana-PK Experimental Engine'**
  String get toggleHanaPkEngine;

  /// No description provided for @simulatorDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer: Simulation results are based on pharmacokinetic models and are for reference only. They do not constitute medical advice. Due to individual differences (metabolism, weight, injection site fat ratio), actual blood levels may vary significantly. Always consult your doctor before adjusting your regimen.'**
  String get simulatorDisclaimer;

  /// No description provided for @simulatorSchemeParams.
  ///
  /// In en, this message translates to:
  /// **'Regimen Parameters'**
  String get simulatorSchemeParams;

  /// No description provided for @simulatorDrugType.
  ///
  /// In en, this message translates to:
  /// **'Drug Type'**
  String get simulatorDrugType;

  /// No description provided for @simulatorSingleDose.
  ///
  /// In en, this message translates to:
  /// **'Single Dose (mg)'**
  String get simulatorSingleDose;

  /// No description provided for @simulatorInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval (days)'**
  String get simulatorInterval;

  /// No description provided for @simulatorWeight.
  ///
  /// In en, this message translates to:
  /// **'Body Weight (kg)'**
  String get simulatorWeight;

  /// No description provided for @simulatorPatchWear.
  ///
  /// In en, this message translates to:
  /// **'Patch Wear (days)'**
  String get simulatorPatchWear;

  /// No description provided for @simulatorSublingualHold.
  ///
  /// In en, this message translates to:
  /// **'Sublingual Hold Time'**
  String get simulatorSublingualHold;

  /// No description provided for @holdTimeVeryFast.
  ///
  /// In en, this message translates to:
  /// **'Very fast'**
  String get holdTimeVeryFast;

  /// No description provided for @holdTimeCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get holdTimeCasual;

  /// No description provided for @holdTimeStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get holdTimeStandard;

  /// No description provided for @holdTimeStrict.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get holdTimeStrict;

  /// No description provided for @updateSimulation.
  ///
  /// In en, this message translates to:
  /// **'Update Simulation'**
  String get updateSimulation;

  /// No description provided for @concentrationCurve.
  ///
  /// In en, this message translates to:
  /// **'Concentration-Time Curve'**
  String get concentrationCurve;

  /// No description provided for @hanaPkLabel.
  ///
  /// In en, this message translates to:
  /// **'Hana-PK'**
  String get hanaPkLabel;

  /// No description provided for @v2StandardLabel.
  ///
  /// In en, this message translates to:
  /// **'V2 Standard'**
  String get v2StandardLabel;

  /// No description provided for @chartAxisLabel.
  ///
  /// In en, this message translates to:
  /// **'Y: Systemic E2 (pg/mL)   X: Days'**
  String get chartAxisLabel;

  /// No description provided for @steadyStateSummary.
  ///
  /// In en, this message translates to:
  /// **'Steady-State Summary'**
  String get steadyStateSummary;

  /// No description provided for @peakLabel.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get peakLabel;

  /// No description provided for @troughLabel.
  ///
  /// In en, this message translates to:
  /// **'Trough'**
  String get troughLabel;

  /// No description provided for @averageLabel.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get averageLabel;

  /// No description provided for @reachSteadyDays.
  ///
  /// In en, this message translates to:
  /// **'Steady state: {days} days'**
  String reachSteadyDays(String days);

  /// No description provided for @bodyMeasurementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get bodyMeasurementsTitle;

  /// No description provided for @newMeasurement.
  ///
  /// In en, this message translates to:
  /// **'New Measurement'**
  String get newMeasurement;

  /// No description provided for @startRecordingChanges.
  ///
  /// In en, this message translates to:
  /// **'Start recording your body changes'**
  String get startRecordingChanges;

  /// No description provided for @measurementEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'After your first measurement, you\'ll see your history here.'**
  String get measurementEmptyHint;

  /// No description provided for @deleteMeasurementTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Measurement'**
  String get deleteMeasurementTitle;

  /// No description provided for @deleteMeasurementConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this body measurement record?'**
  String get deleteMeasurementConfirm;

  /// No description provided for @measurementRecorded.
  ///
  /// In en, this message translates to:
  /// **'Measurement recorded'**
  String get measurementRecorded;

  /// No description provided for @editMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Edit Measurement'**
  String get editMeasurement;

  /// No description provided for @createMeasurement.
  ///
  /// In en, this message translates to:
  /// **'New Measurement'**
  String get createMeasurement;

  /// No description provided for @coreMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Core Measurements'**
  String get coreMeasurements;

  /// No description provided for @extendedIndicators.
  ///
  /// In en, this message translates to:
  /// **'Extended Indicators'**
  String get extendedIndicators;

  /// No description provided for @measurementDate.
  ///
  /// In en, this message translates to:
  /// **'Measurement Date'**
  String get measurementDate;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @enterFullPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter the full 6-digit PIN'**
  String get enterFullPin;

  /// No description provided for @setupSecurePassword.
  ///
  /// In en, this message translates to:
  /// **'Create Secure Password'**
  String get setupSecurePassword;

  /// No description provided for @setupPinDescription.
  ///
  /// In en, this message translates to:
  /// **'Set a 6-digit PIN to protect your private health data.'**
  String get setupPinDescription;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Enable biometric unlock'**
  String get enableBiometric;

  /// No description provided for @pinFormatRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a 6-digit PIN'**
  String get pinFormatRequired;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinMismatch;

  /// No description provided for @editDiary.
  ///
  /// In en, this message translates to:
  /// **'Edit Diary'**
  String get editDiary;

  /// No description provided for @diaryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind today...'**
  String get diaryPlaceholder;

  /// No description provided for @addTags.
  ///
  /// In en, this message translates to:
  /// **'Add Tags'**
  String get addTags;

  /// No description provided for @presetTagHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get presetTagHappy;

  /// No description provided for @presetTagAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get presetTagAnxious;

  /// No description provided for @presetTagCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get presetTagCalm;

  /// No description provided for @presetTagTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get presetTagTired;

  /// No description provided for @presetTagHopeful.
  ///
  /// In en, this message translates to:
  /// **'Hopeful'**
  String get presetTagHopeful;

  /// No description provided for @reminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminder'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily medication reminder notifications'**
  String get reminderChannelDesc;

  /// No description provided for @reminderNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'HanaNote Medication Reminder'**
  String get reminderNotifTitle;

  /// No description provided for @reminderNotifBody.
  ///
  /// In en, this message translates to:
  /// **'{drugName} {dosage}{unit} — Time to take your meds 💊'**
  String reminderNotifBody(String drugName, String dosage, String unit);

  /// No description provided for @milestoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve come so far — that\'s amazing'**
  String get milestoneSubtitle;

  /// No description provided for @noReadingSummary.
  ///
  /// In en, this message translates to:
  /// **'No reading summary'**
  String get noReadingSummary;

  /// No description provided for @medicationStatusTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get medicationStatusTaken;

  /// No description provided for @medicationStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get medicationStatusSkipped;

  /// No description provided for @medicationStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Taken late'**
  String get medicationStatusLate;

  /// No description provided for @medicationStatusDefault.
  ///
  /// In en, this message translates to:
  /// **'Medication log'**
  String get medicationStatusDefault;

  /// No description provided for @medicationLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication: {drugName} {dosage}'**
  String medicationLogTitle(String drugName, String dosage);

  /// No description provided for @abbrevBust.
  ///
  /// In en, this message translates to:
  /// **'Bust'**
  String get abbrevBust;

  /// No description provided for @abbrevWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get abbrevWaist;

  /// No description provided for @abbrevHip.
  ///
  /// In en, this message translates to:
  /// **'Hip'**
  String get abbrevHip;

  /// No description provided for @editBloodReport.
  ///
  /// In en, this message translates to:
  /// **'Edit Blood Report'**
  String get editBloodReport;

  /// No description provided for @addBloodReport.
  ///
  /// In en, this message translates to:
  /// **'Add Blood Report'**
  String get addBloodReport;

  /// No description provided for @testDate.
  ///
  /// In en, this message translates to:
  /// **'Test Date'**
  String get testDate;

  /// No description provided for @labName.
  ///
  /// In en, this message translates to:
  /// **'Lab / Clinic'**
  String get labName;

  /// No description provided for @addReading.
  ///
  /// In en, this message translates to:
  /// **'Add Reading'**
  String get addReading;

  /// No description provided for @hormoneValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get hormoneValue;

  /// No description provided for @selectHormone.
  ///
  /// In en, this message translates to:
  /// **'Select Hormone'**
  String get selectHormone;

  /// No description provided for @atLeastOneReading.
  ///
  /// In en, this message translates to:
  /// **'Add at least one reading'**
  String get atLeastOneReading;

  /// No description provided for @invalidValue.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidValue;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {message}'**
  String saveFailed(String message);

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load report'**
  String get loadFailed;

  /// No description provided for @knowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Drug Reference'**
  String get knowledgeBase;

  /// No description provided for @knowledgeBaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence-based HRT safety guide'**
  String get knowledgeBaseSubtitle;

  /// No description provided for @openKnowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Open HRT Reference'**
  String get openKnowledgeBase;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy\n\nLast updated: April 2026\n\nHanaNote (\"the App\") is committed to protecting your privacy. This Privacy Policy explains how we handle your information.\n\n1. Data Storage\nAll personal health data, including medication records, journal entries, body measurements, photos, and blood test results, is stored locally on your device. We do not transmit your health data to any external servers.\n\n2. Encryption\nYour data is encrypted using industry-standard encryption. Photos are end-to-end encrypted and can only be viewed by you.\n\n3. Data Collection\nThe App does not collect, share, or sell any personally identifiable information. We do not use analytics trackers or advertising SDKs.\n\n4. Permissions\nThe App may request access to your camera (for photo records), biometric sensor (for app lock), and notification system (for medication reminders). These permissions are used solely for the stated purposes.\n\n5. Data Export\nYou may export your data at any time using the built-in export feature. You retain full ownership of your data.\n\n6. Data Deletion\nYou may permanently delete all data using the \"Wipe all data\" option in Settings. This action is irreversible.\n\n7. Changes\nWe may update this Privacy Policy from time to time. Continued use of the App constitutes acceptance of the updated policy.\n\n8. Contact\nIf you have questions about this Privacy Policy, please contact us through our official channels.'**
  String get privacyPolicyContent;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading update...'**
  String get downloadingUpdate;

  /// No description provided for @downloadProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {percent}%'**
  String downloadProgress(String percent);

  /// No description provided for @installUpdate.
  ///
  /// In en, this message translates to:
  /// **'Install Update'**
  String get installUpdate;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed, please retry'**
  String get downloadFailed;

  /// No description provided for @drugTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Medication'**
  String get drugTemplateTitle;

  /// No description provided for @drugTemplateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap a common HRT medication to add quickly, or create custom'**
  String get drugTemplateSubtitle;

  /// No description provided for @drugCustomAdd.
  ///
  /// In en, this message translates to:
  /// **'Add custom medication'**
  String get drugCustomAdd;

  /// No description provided for @updateSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Software Updates'**
  String get updateSectionTitle;

  /// No description provided for @updateAutoCheck.
  ///
  /// In en, this message translates to:
  /// **'Auto-check for updates'**
  String get updateAutoCheck;

  /// No description provided for @updateAutoCheckDesc.
  ///
  /// In en, this message translates to:
  /// **'Check for new versions on launch'**
  String get updateAutoCheckDesc;

  /// No description provided for @updateCheckNow.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get updateCheckNow;

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get updateChecking;

  /// No description provided for @updateAlreadyLatest.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the latest version'**
  String get updateAlreadyLatest;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Update check failed, please check your network'**
  String get updateCheckFailed;

  /// No description provided for @updateCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get updateCurrentVersion;

  /// No description provided for @updateNewVersion.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get updateNewVersion;

  /// No description provided for @updateWhatsNew.
  ///
  /// In en, this message translates to:
  /// **'WHAT\'S NEW'**
  String get updateWhatsNew;

  /// No description provided for @updateSkipVersion.
  ///
  /// In en, this message translates to:
  /// **'Skip this version'**
  String get updateSkipVersion;

  /// No description provided for @updateRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry download'**
  String get updateRetry;

  /// No description provided for @updateReadyToInstall.
  ///
  /// In en, this message translates to:
  /// **'Ready to install'**
  String get updateReadyToInstall;

  /// No description provided for @updateEstimatedTime.
  ///
  /// In en, this message translates to:
  /// **'About {time} remaining'**
  String updateEstimatedTime(String time);

  /// No description provided for @webDownloadBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Download HanaNote for Android'**
  String get webDownloadBannerTitle;

  /// No description provided for @webDownloadBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get the full native experience'**
  String get webDownloadBannerSubtitle;

  /// No description provided for @webDownloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get webDownloadButton;

  /// No description provided for @downloadApp.
  ///
  /// In en, this message translates to:
  /// **'Download App'**
  String get downloadApp;

  /// No description provided for @downloadAndroidApp.
  ///
  /// In en, this message translates to:
  /// **'Download Android App'**
  String get downloadAndroidApp;

  /// No description provided for @downloadAndroidAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Native app for the best experience'**
  String get downloadAndroidAppDesc;

  /// No description provided for @termsOfUseContent.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use\n\nLast updated: April 2026\n\nBy using HanaNote (\"the App\"), you agree to these Terms of Use.\n\n1. Purpose\nThe App is a personal health tracking tool designed for hormone replacement therapy (HRT) management. It is not a medical device and does not provide medical advice.\n\n2. Medical Disclaimer\nThe App is not a substitute for professional medical advice, diagnosis, or treatment. Always consult your healthcare provider before making changes to your medication regimen. Pharmacokinetic simulation results are for reference only.\n\n3. User Responsibility\nYou are responsible for the accuracy of data you enter and for maintaining the security of your device and app password.\n\n4. Data Ownership\nYou retain full ownership of all data you create within the App. We do not claim any rights to your content.\n\n5. Availability\nThe App is provided \"as is\" without warranty of any kind. We do not guarantee uninterrupted or error-free operation.\n\n6. Limitation of Liability\nTo the maximum extent permitted by law, the developers of the App shall not be liable for any damages arising from the use or inability to use the App.\n\n7. Updates\nWe may release updates to improve functionality. Continued use after updates constitutes acceptance of any modified terms.\n\n8. Governing Law\nThese terms shall be governed by applicable local laws.\n\n9. Contact\nFor questions about these Terms, please contact us through our official channels.'**
  String get termsOfUseContent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
