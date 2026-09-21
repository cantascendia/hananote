import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hananote/features/medication/domain/entities/drug.dart';
import 'package:hananote/features/medication/domain/entities/medication_schedule.dart';

part 'notification_settings_state.freezed.dart';

@freezed
sealed class NotificationSettingsState with _$NotificationSettingsState {
  const factory NotificationSettingsState.initial() =
      NotificationSettingsInitial;

  const factory NotificationSettingsState.loading() =
      NotificationSettingsLoading;

  const factory NotificationSettingsState.loaded({
    required List<Drug> drugs,
    required Map<String, MedicationSchedule> schedules,
  }) = NotificationSettingsLoaded;

  const factory NotificationSettingsState.error({
    required String message,
  }) = NotificationSettingsError;
}
