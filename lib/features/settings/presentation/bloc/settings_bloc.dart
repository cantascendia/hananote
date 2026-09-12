import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/settings/domain/usecases/export_data.dart';
import 'package:hananote/features/settings/domain/usecases/generate_pdf_report.dart';
import 'package:hananote/features/settings/domain/usecases/get_profile_dashboard.dart';
import 'package:hananote/features/settings/domain/usecases/import_data.dart';
import 'package:hananote/features/settings/domain/usecases/update_app_settings.dart';
import 'package:hananote/features/settings/domain/usecases/update_user_profile.dart';
import 'package:hananote/features/settings/domain/usecases/wipe_all_data.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// BLoC for managing the settings dashboard state.
@lazySingleton
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  /// Creates a [SettingsBloc].
  SettingsBloc(
    this._getProfileDashboard,
    this._updateAppSettings,
    this._updateUserProfile,
    this._wipeAllData,
    this._exportData,
    this._importData,
    this._generatePdfReport,
  ) : super(const SettingsInitial()) {
    on<LoadSettingsDashboard>(_onLoadDashboard);
    on<ToggleAppLock>(_onToggleAppLock);
    on<TogglePrivacyMode>(_onTogglePrivacyMode);
    on<ToggleBlurOverlay>(_onToggleBlurOverlay);
    on<UpdateDisplayName>(_onUpdateDisplayName);
    on<UpdateHrtStartDate>(_onUpdateHrtStartDate);
    on<WipeSettingsData>(_onWipeData);
    on<ExportDataEvent>(_onExportData);
    on<ImportDataEvent>(_onImportData);
    on<GeneratePdfEvent>(_onGeneratePdf);
    on<MarkOnboardingComplete>(_onMarkOnboardingComplete);
  }

  final GetProfileDashboard _getProfileDashboard;
  final UpdateAppSettings _updateAppSettings;
  final UpdateUserProfile _updateUserProfile;
  final WipeAllData _wipeAllData;
  final ExportData _exportData;
  final ImportData _importData;
  final GeneratePdfReport _generatePdfReport;

  Future<void> _onLoadDashboard(
    LoadSettingsDashboard event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final failureOrDashboard = await _getProfileDashboard();

    failureOrDashboard.fold(
      (failure) => emit(SettingsError(failureMessage(failure))),
      (dashboard) => emit(
        SettingsLoaded(
          profile: dashboard.profile,
          settings: dashboard.settings,
          activeDrugCount: dashboard.activeDrugCount,
          inventoryDaysRemaining: dashboard.inventoryDaysRemaining,
        ),
      ),
    );
  }

  Future<void> _onToggleAppLock(
    ToggleAppLock event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        appLockEnabled: event.enabled,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onTogglePrivacyMode(
    TogglePrivacyMode event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        privacyModeEnabled: event.enabled,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onToggleBlurOverlay(
    ToggleBlurOverlay event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        blurOverlayEnabled: event.enabled,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onUpdateDisplayName(
    UpdateDisplayName event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newProfile = currentState.profile.copyWith(
        displayName: event.name,
      );

      final failureOrProfile = await _updateUserProfile(newProfile);

      failureOrProfile.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedProfile) => emit(
          currentState.copyWith(profile: updatedProfile),
        ),
      );
    }
  }

  Future<void> _onUpdateHrtStartDate(
    UpdateHrtStartDate event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newProfile = currentState.profile.copyWith(
        hrtStartDate: event.date,
      );

      final failureOrProfile = await _updateUserProfile(newProfile);

      failureOrProfile.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedProfile) => emit(
          currentState.copyWith(profile: updatedProfile),
        ),
      );
    }
  }

  Future<void> _onWipeData(
    WipeSettingsData event,
    Emitter<SettingsState> emit,
  ) async {
    final failureOrSuccess = await _wipeAllData();

    failureOrSuccess.fold(
      (failure) => emit(SettingsError(failureMessage(failure))),
      (_) => emit(const SettingsWiped()),
    );
  }

  Future<void> _onExportData(
    ExportDataEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(SettingsState.actionResult(
      actionKey: 'export_in_progress',
      previousState: currentState,
    ));

    final failureOrExport = await _exportData();

    await failureOrExport.fold(
      (failure) async {
        emit(SettingsState.actionResult(
          actionKey: 'export_failed',
          previousState: currentState,
        ));
      },
      (jsonString) async {
        try {
          final tempDir = await getTemporaryDirectory();
          final fileName = 'hananote_backup_${DateTime.now().millisecondsSinceEpoch}.json';
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsString(jsonString);

          await Share.shareXFiles([XFile(file.path)], text: 'HanaNote Backup');
          emit(SettingsState.actionResult(
            actionKey: 'export_success',
            previousState: currentState,
          ));
        } catch (e) {
          emit(SettingsState.actionResult(
            actionKey: 'export_failed',
            previousState: currentState,
          ));
        }
      },
    );

    // After handling the action and showing snackbar, restore visual state
    emit(currentState);
  }

  Future<void> _onImportData(
    ImportDataEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(
      SettingsState.actionResult(
        actionKey: 'import_in_progress',
        previousState: currentState,
      ),
    );

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        emit(currentState);
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        emit(
          SettingsState.actionResult(
            actionKey: 'import_failed',
            previousState: currentState,
          ),
        );
        emit(currentState);
        return;
      }

      final jsonString = await File(filePath).readAsString();
      final failureOrCount = await _importData(jsonString);

      failureOrCount.fold(
        (failure) {
          emit(
            SettingsState.actionResult(
              actionKey: 'import_failed',
              previousState: currentState,
            ),
          );
        },
        (count) {
          emit(
            SettingsState.actionResult(
              actionKey: 'import_success',
              previousState: currentState,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        SettingsState.actionResult(
          actionKey: 'import_failed',
          previousState: currentState,
        ),
      );
    }

    // Reload dashboard to reflect imported data
    add(const LoadSettingsDashboard());
  }

  Future<void> _onGeneratePdf(
    GeneratePdfEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(
      SettingsState.actionResult(
        actionKey: 'pdf_generating',
        previousState: currentState,
      ),
    );

    final failureOrBytes = await _generatePdfReport(
      pdfTitle: 'HanaNote Health Report',
      medSection: 'Medication Plan',
      bloodSection: 'Blood Test Records',
      measureSection: 'Body Measurements',
      journalSection: 'Mood Diary',
      noData: 'No data',
    );

    await failureOrBytes.fold(
      (failure) async {
        emit(
          SettingsState.actionResult(
            actionKey: 'pdf_failed',
            previousState: currentState,
          ),
        );
      },
      (bytes) async {
        try {
          final tempDir = await getTemporaryDirectory();
          final ts = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'hananote_report_$ts.pdf';
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(bytes);

          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path)],
              text: 'HanaNote Health Report',
            ),
          );
          emit(
            SettingsState.actionResult(
              actionKey: 'pdf_success',
              previousState: currentState,
            ),
          );
        } catch (e) {
          emit(
            SettingsState.actionResult(
              actionKey: 'pdf_failed',
              previousState: currentState,
            ),
          );
        }
      },
    );

    emit(currentState);
  }

  Future<void> _onMarkOnboardingComplete(
    MarkOnboardingComplete event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        onboardingComplete: true,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }
}
