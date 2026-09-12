// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hananote/app/di/register_module.dart' as _i622;
import 'package:hananote/core/crypto/crypto_engine.dart' as _i472;
import 'package:hananote/core/crypto/key_manager.dart' as _i869;
import 'package:hananote/core/database/secure_database.dart' as _i59;
import 'package:hananote/core/notifications/notification_module.dart' as _i868;
import 'package:hananote/core/notifications/notification_service.dart' as _i287;
import 'package:hananote/features/auth/data/datasources/auth_local_datasource.dart'
    as _i260;
import 'package:hananote/features/auth/data/repositories/auth_repository_impl.dart'
    as _i735;
import 'package:hananote/features/auth/domain/repositories/auth_repository.dart'
    as _i1072;
import 'package:hananote/features/auth/domain/usecases/change_pin.dart'
    as _i465;
import 'package:hananote/features/auth/domain/usecases/setup_app.dart' as _i909;
import 'package:hananote/features/auth/domain/usecases/unlock_app.dart'
    as _i177;
import 'package:hananote/features/auth/domain/usecases/wipe_data.dart' as _i69;
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart'
    as _i464;
import 'package:hananote/features/blood_test/data/datasources/blood_test_local_datasource.dart'
    as _i596;
import 'package:hananote/features/blood_test/data/repositories/blood_test_repository_impl.dart'
    as _i155;
import 'package:hananote/features/blood_test/domain/repositories/blood_test_repository.dart'
    as _i979;
import 'package:hananote/features/blood_test/domain/usecases/add_blood_test_report.dart'
    as _i798;
import 'package:hananote/features/blood_test/domain/usecases/get_all_blood_test_reports.dart'
    as _i712;
import 'package:hananote/features/blood_test/domain/usecases/get_hormone_trend.dart'
    as _i341;
import 'package:hananote/features/blood_test/presentation/bloc/blood_test_bloc.dart'
    as _i1026;
import 'package:hananote/features/journal/data/datasources/journal_local_datasource.dart'
    as _i929;
import 'package:hananote/features/journal/data/repositories/journal_repository_impl.dart'
    as _i394;
import 'package:hananote/features/journal/domain/repositories/journal_repository.dart'
    as _i1032;
import 'package:hananote/features/journal/domain/usecases/add_journal_entry.dart'
    as _i1022;
import 'package:hananote/features/journal/domain/usecases/get_all_journal_entries.dart'
    as _i73;
import 'package:hananote/features/journal/domain/usecases/get_journal_streak.dart'
    as _i910;
import 'package:hananote/features/journal/domain/usecases/update_journal_entry.dart'
    as _i628;
import 'package:hananote/features/journal/presentation/bloc/record_bloc.dart'
    as _i697;
import 'package:hananote/features/measurement/data/datasources/measurement_local_data_source.dart'
    as _i708;
import 'package:hananote/features/measurement/data/repositories/measurement_repository_impl.dart'
    as _i771;
import 'package:hananote/features/measurement/domain/repositories/measurement_repository.dart'
    as _i502;
import 'package:hananote/features/measurement/domain/usecases/delete_measurement.dart'
    as _i469;
import 'package:hananote/features/measurement/domain/usecases/get_latest_measurement.dart'
    as _i239;
import 'package:hananote/features/measurement/domain/usecases/get_measurement_history.dart'
    as _i255;
import 'package:hananote/features/measurement/domain/usecases/save_measurement.dart'
    as _i1060;
import 'package:hananote/features/measurement/presentation/blocs/measurement_bloc.dart'
    as _i590;
import 'package:hananote/features/medication/data/datasources/medication_local_datasource.dart'
    as _i1047;
import 'package:hananote/features/medication/data/repositories/medication_repository_impl.dart'
    as _i1024;
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart'
    as _i160;
import 'package:hananote/features/medication/domain/usecases/add_drug.dart'
    as _i769;
import 'package:hananote/features/medication/domain/usecases/check_inventory.dart'
    as _i136;
import 'package:hananote/features/medication/domain/usecases/delete_drug.dart'
    as _i234;
import 'package:hananote/features/medication/domain/usecases/get_all_drugs.dart'
    as _i288;
import 'package:hananote/features/medication/domain/usecases/get_today_schedule.dart'
    as _i336;
import 'package:hananote/features/medication/domain/usecases/log_medication.dart'
    as _i1050;
import 'package:hananote/features/medication/domain/usecases/sync_medication_reminders.dart'
    as _i445;
import 'package:hananote/features/medication/domain/usecases/update_drug.dart'
    as _i246;
import 'package:hananote/features/medication/presentation/bloc/inventory_cubit.dart'
    as _i848;
import 'package:hananote/features/medication/presentation/bloc/today_schedule_bloc.dart'
    as _i14;
import 'package:hananote/features/notification/presentation/bloc/notification_settings_cubit.dart'
    as _i922;
import 'package:hananote/features/photo/data/datasources/photo_local_data_source.dart'
    as _i432;
import 'package:hananote/features/photo/data/repositories/photo_repository_impl.dart'
    as _i763;
import 'package:hananote/features/photo/domain/repositories/photo_repository.dart'
    as _i203;
import 'package:hananote/features/photo/domain/services/photo_crypto_service.dart'
    as _i484;
import 'package:hananote/features/photo/domain/usecases/delete_photo.dart'
    as _i210;
import 'package:hananote/features/photo/domain/usecases/get_latest_photo.dart'
    as _i284;
import 'package:hananote/features/photo/domain/usecases/get_photo_history.dart'
    as _i937;
import 'package:hananote/features/photo/domain/usecases/load_photo_full.dart'
    as _i496;
import 'package:hananote/features/photo/domain/usecases/load_photo_thumbnail.dart'
    as _i903;
import 'package:hananote/features/photo/domain/usecases/save_photo.dart'
    as _i62;
import 'package:hananote/features/photo/presentation/blocs/photo_bloc.dart'
    as _i26;
import 'package:hananote/features/photo/presentation/services/photo_picker_service.dart'
    as _i95;
import 'package:hananote/features/settings/data/datasources/settings_local_datasource.dart'
    as _i843;
import 'package:hananote/features/settings/data/repositories/settings_repository_impl.dart'
    as _i1024;
import 'package:hananote/features/settings/domain/repositories/settings_repository.dart'
    as _i755;
import 'package:hananote/features/settings/domain/usecases/export_data.dart'
    as _i671;
import 'package:hananote/features/settings/domain/usecases/generate_pdf_report.dart'
    as _i13;
import 'package:hananote/features/settings/domain/usecases/get_profile_dashboard.dart'
    as _i287;
import 'package:hananote/features/settings/domain/usecases/import_data.dart'
    as _i414;
import 'package:hananote/features/settings/domain/usecases/update_app_settings.dart'
    as _i695;
import 'package:hananote/features/settings/domain/usecases/update_user_profile.dart'
    as _i254;
import 'package:hananote/features/settings/domain/usecases/wipe_all_data.dart'
    as _i135;
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart'
    as _i994;
import 'package:hananote/features/simulator/domain/usecases/calibrate_pk_params.dart'
    as _i987;
import 'package:hananote/features/simulator/domain/usecases/run_pk_simulation.dart'
    as _i691;
import 'package:hananote/features/simulator/presentation/blocs/simulator_bloc.dart'
    as _i622;
import 'package:hananote/features/timeline/domain/usecases/get_timeline_events.dart'
    as _i965;
import 'package:hananote/features/timeline/presentation/bloc/timeline_bloc.dart'
    as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:local_auth/local_auth.dart' as _i152;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    final notificationModule = _$NotificationModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => registerModule.secureStorage);
    gh.lazySingleton<_i152.LocalAuthentication>(
        () => registerModule.localAuthentication);
    gh.lazySingleton<_i472.CryptoEngine>(() => _i472.CryptoEngine());
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
        () => notificationModule.flutterLocalNotificationsPlugin);
    gh.lazySingleton<_i95.PhotoPickerService>(() => _i95.ImagePickerService());
    gh.lazySingleton<_i869.KeyManager>(
        () => _i869.KeyManager(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i260.AuthLocalDataSource>(
        () => _i260.AuthLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i287.NotificationService>(() =>
        _i287.NotificationService(gh<_i163.FlutterLocalNotificationsPlugin>()));
    gh.factory<_i484.PhotoCryptoService>(() => _i484.PhotoCryptoService(
          gh<_i472.CryptoEngine>(),
          gh<_i869.KeyManager>(),
        ));
    gh.lazySingleton<_i59.SecureDatabase>(
        () => _i59.SecureDatabase(gh<_i869.KeyManager>()));
    gh.factory<_i496.LoadPhotoFull>(
        () => _i496.LoadPhotoFull(gh<_i484.PhotoCryptoService>()));
    gh.factory<_i903.LoadPhotoThumbnail>(
        () => _i903.LoadPhotoThumbnail(gh<_i484.PhotoCryptoService>()));
    gh.lazySingleton<_i1072.AuthRepository>(() => _i735.AuthRepositoryImpl(
          gh<_i260.AuthLocalDataSource>(),
          gh<_i869.KeyManager>(),
          gh<_i59.SecureDatabase>(),
          gh<_i558.FlutterSecureStorage>(),
          gh<_i152.LocalAuthentication>(),
        ));
    gh.lazySingleton<_i708.MeasurementLocalDataSource>(
        () => _i708.MeasurementLocalDataSourceImpl(gh<_i59.SecureDatabase>()));
    gh.lazySingleton<_i432.PhotoLocalDataSource>(
        () => _i432.PhotoLocalDataSourceImpl(gh<_i59.SecureDatabase>()));
    gh.lazySingleton<_i1047.MedicationLocalDataSource>(
        () => _i1047.MedicationLocalDataSourceImpl(gh<_i59.SecureDatabase>()));
    gh.lazySingleton<_i596.BloodTestLocalDataSource>(
        () => _i596.BloodTestLocalDataSourceImpl(gh<_i59.SecureDatabase>()));
    gh.lazySingleton<_i203.PhotoRepository>(
        () => _i763.PhotoRepositoryImpl(gh<_i432.PhotoLocalDataSource>()));
    gh.lazySingleton<_i929.JournalLocalDataSource>(
        () => _i929.JournalLocalDataSourceImpl(gh<_i59.SecureDatabase>()));
    gh.factory<_i465.ChangePin>(
        () => _i465.ChangePin(gh<_i1072.AuthRepository>()));
    gh.factory<_i909.SetupApp>(
        () => _i909.SetupApp(gh<_i1072.AuthRepository>()));
    gh.factory<_i177.UnlockApp>(
        () => _i177.UnlockApp(gh<_i1072.AuthRepository>()));
    gh.factory<_i69.WipeData>(() => _i69.WipeData(gh<_i1072.AuthRepository>()));
    gh.factory<_i464.AuthCubit>(() => _i464.AuthCubit(
          gh<_i1072.AuthRepository>(),
          gh<_i909.SetupApp>(),
          gh<_i177.UnlockApp>(),
          gh<_i69.WipeData>(),
        ));
    gh.lazySingleton<_i979.BloodTestRepository>(() =>
        _i155.BloodTestRepositoryImpl(gh<_i596.BloodTestLocalDataSource>()));
    gh.lazySingleton<_i160.MedicationRepository>(() =>
        _i1024.MedicationRepositoryImpl(
            gh<_i1047.MedicationLocalDataSource>()));
    gh.factory<_i987.CalibratePkParams>(
        () => _i987.CalibratePkParams(gh<_i979.BloodTestRepository>()));
    gh.lazySingleton<_i502.MeasurementRepository>(() =>
        _i771.MeasurementRepositoryImpl(
            gh<_i708.MeasurementLocalDataSource>()));
    gh.factory<_i769.AddDrug>(
        () => _i769.AddDrug(gh<_i160.MedicationRepository>()));
    gh.factory<_i136.CheckInventory>(
        () => _i136.CheckInventory(gh<_i160.MedicationRepository>()));
    gh.factory<_i234.DeleteDrug>(
        () => _i234.DeleteDrug(gh<_i160.MedicationRepository>()));
    gh.factory<_i288.GetAllDrugs>(
        () => _i288.GetAllDrugs(gh<_i160.MedicationRepository>()));
    gh.factory<_i336.GetTodaySchedule>(
        () => _i336.GetTodaySchedule(gh<_i160.MedicationRepository>()));
    gh.factory<_i1050.LogMedication>(
        () => _i1050.LogMedication(gh<_i160.MedicationRepository>()));
    gh.factory<_i246.UpdateDrug>(
        () => _i246.UpdateDrug(gh<_i160.MedicationRepository>()));
    gh.factory<_i922.NotificationSettingsCubit>(() =>
        _i922.NotificationSettingsCubit(gh<_i160.MedicationRepository>()));
    gh.factory<_i691.RunPkSimulation>(
        () => _i691.RunPkSimulation(gh<_i160.MedicationRepository>()));
    gh.lazySingleton<_i843.SettingsLocalDataSource>(
        () => _i843.SettingsLocalDataSourceImpl(
              gh<_i558.FlutterSecureStorage>(),
              gh<_i1047.MedicationLocalDataSource>(),
              gh<_i160.MedicationRepository>(),
            ));
    gh.factory<_i469.DeleteMeasurement>(
        () => _i469.DeleteMeasurement(gh<_i502.MeasurementRepository>()));
    gh.factory<_i239.GetLatestMeasurement>(
        () => _i239.GetLatestMeasurement(gh<_i502.MeasurementRepository>()));
    gh.factory<_i255.GetMeasurementHistory>(
        () => _i255.GetMeasurementHistory(gh<_i502.MeasurementRepository>()));
    gh.factory<_i1060.SaveMeasurement>(
        () => _i1060.SaveMeasurement(gh<_i502.MeasurementRepository>()));
    gh.factory<_i210.DeletePhoto>(() => _i210.DeletePhoto(
          gh<_i203.PhotoRepository>(),
          gh<_i484.PhotoCryptoService>(),
        ));
    gh.factory<_i62.SavePhoto>(() => _i62.SavePhoto(
          gh<_i203.PhotoRepository>(),
          gh<_i484.PhotoCryptoService>(),
        ));
    gh.factory<_i848.InventoryCubit>(() => _i848.InventoryCubit(
          gh<_i136.CheckInventory>(),
          gh<_i160.MedicationRepository>(),
        ));
    gh.factory<_i590.MeasurementBloc>(() => _i590.MeasurementBloc(
          gh<_i255.GetMeasurementHistory>(),
          gh<_i1060.SaveMeasurement>(),
          gh<_i469.DeleteMeasurement>(),
        ));
    gh.factory<_i284.GetLatestPhoto>(
        () => _i284.GetLatestPhoto(gh<_i203.PhotoRepository>()));
    gh.factory<_i937.GetPhotoHistory>(
        () => _i937.GetPhotoHistory(gh<_i203.PhotoRepository>()));
    gh.lazySingleton<_i1032.JournalRepository>(
        () => _i394.JournalRepositoryImpl(gh<_i929.JournalLocalDataSource>()));
    gh.lazySingleton<_i755.SettingsRepository>(
        () => _i1024.SettingsRepositoryImpl(
              gh<_i843.SettingsLocalDataSource>(),
              gh<_i1072.AuthRepository>(),
            ));
    gh.factory<_i1022.AddJournalEntry>(
        () => _i1022.AddJournalEntry(gh<_i1032.JournalRepository>()));
    gh.factory<_i73.GetAllJournalEntries>(
        () => _i73.GetAllJournalEntries(gh<_i1032.JournalRepository>()));
    gh.factory<_i910.GetJournalStreak>(
        () => _i910.GetJournalStreak(gh<_i1032.JournalRepository>()));
    gh.factory<_i628.UpdateJournalEntry>(
        () => _i628.UpdateJournalEntry(gh<_i1032.JournalRepository>()));
    gh.factory<_i965.GetTimelineEvents>(() => _i965.GetTimelineEvents(
          gh<_i160.MedicationRepository>(),
          gh<_i979.BloodTestRepository>(),
          gh<_i1032.JournalRepository>(),
          gh<_i755.SettingsRepository>(),
        ));
    gh.factory<_i798.AddBloodTestReport>(
        () => _i798.AddBloodTestReport(gh<_i979.BloodTestRepository>()));
    gh.factory<_i712.GetAllBloodTestReports>(
        () => _i712.GetAllBloodTestReports(gh<_i979.BloodTestRepository>()));
    gh.factory<_i341.GetHormoneTrend>(
        () => _i341.GetHormoneTrend(gh<_i979.BloodTestRepository>()));
    gh.factory<_i445.SyncMedicationReminders>(
        () => _i445.SyncMedicationReminders(
              gh<_i160.MedicationRepository>(),
              gh<_i287.NotificationService>(),
            ));
    gh.factory<_i622.SimulatorBloc>(
        () => _i622.SimulatorBloc(gh<_i691.RunPkSimulation>()));
    gh.factory<_i116.TimelineBloc>(() => _i116.TimelineBloc(
          gh<_i965.GetTimelineEvents>(),
          gh<_i755.SettingsRepository>(),
        ));
    gh.factory<_i671.ExportData>(() => _i671.ExportData(
          gh<_i160.MedicationRepository>(),
          gh<_i1032.JournalRepository>(),
          gh<_i979.BloodTestRepository>(),
          gh<_i502.MeasurementRepository>(),
          gh<_i755.SettingsRepository>(),
        ));
    gh.factory<_i13.GeneratePdfReport>(() => _i13.GeneratePdfReport(
          gh<_i160.MedicationRepository>(),
          gh<_i979.BloodTestRepository>(),
          gh<_i1032.JournalRepository>(),
          gh<_i502.MeasurementRepository>(),
          gh<_i755.SettingsRepository>(),
        ));
    gh.factory<_i414.ImportData>(() => _i414.ImportData(
          gh<_i160.MedicationRepository>(),
          gh<_i979.BloodTestRepository>(),
          gh<_i1032.JournalRepository>(),
          gh<_i502.MeasurementRepository>(),
          gh<_i755.SettingsRepository>(),
        ));
    gh.factory<_i1026.BloodTestBloc>(() => _i1026.BloodTestBloc(
          getAllReports: gh<_i712.GetAllBloodTestReports>(),
          getTrend: gh<_i341.GetHormoneTrend>(),
        ));
    gh.factory<_i26.PhotoBloc>(() => _i26.PhotoBloc(
          gh<_i937.GetPhotoHistory>(),
          gh<_i62.SavePhoto>(),
          gh<_i210.DeletePhoto>(),
          gh<_i903.LoadPhotoThumbnail>(),
          gh<_i95.PhotoPickerService>(),
        ));
    gh.factory<_i287.GetProfileDashboard>(
        () => _i287.GetProfileDashboard(gh<_i755.SettingsRepository>()));
    gh.factory<_i695.UpdateAppSettings>(
        () => _i695.UpdateAppSettings(gh<_i755.SettingsRepository>()));
    gh.factory<_i254.UpdateUserProfile>(
        () => _i254.UpdateUserProfile(gh<_i755.SettingsRepository>()));
    gh.factory<_i135.WipeAllData>(
        () => _i135.WipeAllData(gh<_i755.SettingsRepository>()));
    gh.lazySingleton<_i697.RecordBloc>(() => _i697.RecordBloc(
          gh<_i910.GetJournalStreak>(),
          gh<_i1032.JournalRepository>(),
          gh<_i502.MeasurementRepository>(),
          gh<_i203.PhotoRepository>(),
        ));
    gh.factory<_i14.TodayScheduleBloc>(() => _i14.TodayScheduleBloc(
          gh<_i336.GetTodaySchedule>(),
          gh<_i1050.LogMedication>(),
          gh<_i445.SyncMedicationReminders>(),
        ));
    gh.lazySingleton<_i994.SettingsBloc>(() => _i994.SettingsBloc(
          gh<_i287.GetProfileDashboard>(),
          gh<_i695.UpdateAppSettings>(),
          gh<_i254.UpdateUserProfile>(),
          gh<_i135.WipeAllData>(),
          gh<_i671.ExportData>(),
          gh<_i414.ImportData>(),
          gh<_i13.GeneratePdfReport>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i622.RegisterModule {}

class _$NotificationModule extends _i868.NotificationModule {}
