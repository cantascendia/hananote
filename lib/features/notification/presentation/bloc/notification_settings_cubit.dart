import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/features/medication/domain/entities/medication_schedule.dart';
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart';
import 'package:hananote/features/notification/presentation/bloc/notification_settings_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  NotificationSettingsCubit(this._repository)
      : super(const NotificationSettingsState.initial());

  final MedicationRepository _repository;

  Future<void> loadData() async {
    emit(const NotificationSettingsState.loading());
    try {
      final drugsResult = await _repository.getAllDrugs();

      await drugsResult.fold(
        (failure) async {
          emit(NotificationSettingsState.error(message: failure.message));
        },
        (allDrugs) async {
          final activeDrugs = allDrugs.where((d) => d.isActive).toList();
          final schedules = <String, MedicationSchedule>{};

          for (final drug in activeDrugs) {
            final schedResult = await _repository.getScheduleForDrug(drug.id);
            schedResult.fold(
              (f) => null,
              (schedule) {
                if (schedule != null) {
                  schedules[drug.id] = schedule;
                }
              },
            );
          }

          emit(
            NotificationSettingsState.loaded(
              drugs: activeDrugs,
              schedules: schedules,
            ),
          );
        },
      );
    } catch (e) {
      emit(NotificationSettingsState.error(message: e.toString()));
    }
  }
}
