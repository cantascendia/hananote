// Release prep note: This editor keeps several long schedule literals
// unwrapped because forced wrapping hurts form readability.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter/material.dart' as material show TimeOfDay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/l10n/enum_l10n.dart';
import 'package:hananote/features/medication/domain/entities/enums.dart';
import 'package:hananote/features/medication/domain/entities/medication_schedule.dart';
import 'package:hananote/features/medication/presentation/bloc/schedule_editor_cubit.dart';
import 'package:hananote/features/medication/presentation/bloc/schedule_editor_state.dart';
import 'package:intl/intl.dart';

/// Editing page for medication schedules.
class ScheduleEditorPage extends StatefulWidget {
  /// Creates a [ScheduleEditorPage].
  const ScheduleEditorPage({super.key});

  @override
  State<ScheduleEditorPage> createState() => _ScheduleEditorPageState();
}

class _ScheduleEditorPageState extends State<ScheduleEditorPage> {
  final _dosageController = TextEditingController();

  @override
  void dispose() {
    _dosageController.dispose();
    super.dispose();
  }

  void _onStateChange(BuildContext context, ScheduleEditorState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is ScheduleEditorSaved) {
      Navigator.of(context).pop();
    } else if (state is ScheduleEditorError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_localizeValidation(state.message, l10n))),
      );
    } else if (state is ScheduleEditorEditing) {
      if (state.dosageAmount != null && _dosageController.text.isEmpty) {
        _dosageController.text = state.dosageAmount.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ScheduleEditorCubit, ScheduleEditorState>(
      listener: _onStateChange,
      builder: (context, state) {
        if (state is! ScheduleEditorEditing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final errorColor = theme.colorScheme.error;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.editDrug),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => context.read<ScheduleEditorCubit>().save(),
                tooltip: l10n.save,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (state.drugName != null) ...[
                Card(
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.drugName!,
                                style: theme.textTheme.titleSmall,
                              ),
                              if (state.administrationRoute != null)
                                Text(
                                  state.administrationRoute!
                                      .localizedName(l10n),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (state.validation?.dosageError != null)
                Text(
                  _localizeValidation(state.validation!.dosageError!, l10n),
                  style: TextStyle(color: errorColor),
                ),
              TextField(
                controller: _dosageController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.dosage,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) {
                    context.read<ScheduleEditorCubit>().setDosageAmount(parsed);
                  }
                },
              ),
              if (state.administrationRoute != null) ...[
                const SizedBox(height: 12),
                Text(l10n.unit, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: state.administrationRoute!.supportedUnits
                      .map(
                        (unit) => ChoiceChip(
                          label: Text(unit.localizedName(l10n)),
                          selected: state.dosageUnit == unit,
                          onSelected: (_) => context
                              .read<ScheduleEditorCubit>()
                              .setDosageUnit(unit),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              Text(l10n.frequency, style: theme.textTheme.titleMedium),
              if (state.validation?.frequencyError != null)
                Text(
                  _localizeValidation(state.validation!.frequencyError!, l10n),
                  style: TextStyle(color: errorColor),
                ),
              const SizedBox(height: 8),
              _buildFrequencySelector(context, state, l10n),
              const SizedBox(height: 24),
              Text(l10n.startDate, style: theme.textTheme.titleMedium),
              if (state.validation?.startDateError != null)
                Text(
                  _localizeValidation(state.validation!.startDateError!, l10n),
                  style: TextStyle(color: errorColor),
                ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Text(
                  state.startDate == null
                      ? l10n.selectDate
                      : _formatDate(context, state.startDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: state.startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null && context.mounted) {
                    context.read<ScheduleEditorCubit>().setStartDate(date);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(l10n.endDateOptional, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Text(
                  state.endDate == null
                      ? l10n.noEndDate
                      : _formatDate(context, state.endDate!),
                ),
                trailing: state.endDate == null
                    ? const Icon(Icons.calendar_today)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => context
                            .read<ScheduleEditorCubit>()
                            .setEndDate(null),
                      ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: state.endDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null && context.mounted) {
                    context.read<ScheduleEditorCubit>().setEndDate(date);
                  }
                },
              ),
              const SizedBox(height: 24),
              if (state.validation?.scheduleTimesError != null)
                Text(
                  _localizeValidation(
                    state.validation!.scheduleTimesError!,
                    l10n,
                  ),
                  style: TextStyle(color: errorColor),
                ),
              _buildTimeSelectors(context, state, l10n),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () => context.read<ScheduleEditorCubit>().save(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFrequencySelector(
    BuildContext context,
    ScheduleEditorEditing state,
    AppLocalizations l10n,
  ) {
    var typeIndex = 0;
    if (state.frequency is EveryNDaysMedicationFrequency) typeIndex = 1;
    if (state.frequency is WeeklyMedicationFrequency) typeIndex = 2;

    return Column(
      children: [
        SegmentedButton<int>(
          segments: [
            ButtonSegment(value: 0, label: Text(l10n.daily)),
            ButtonSegment(value: 1, label: Text(l10n.everyNDays)),
            ButtonSegment(value: 2, label: Text(l10n.weekly)),
          ],
          selected: {typeIndex},
          onSelectionChanged: (set) {
            final idx = set.first;
            MedicationFrequency? freq;
            if (idx == 0) freq = const DailyMedicationFrequency(timesPerDay: 1);
            if (idx == 1) freq = const EveryNDaysMedicationFrequency(days: 2);
            if (idx == 2) freq = const WeeklyMedicationFrequency(dayOfWeek: 1);
            if (freq != null) {
              context.read<ScheduleEditorCubit>().setFrequency(freq);
            }
          },
        ),
        const SizedBox(height: 16),
        if (state.frequency is DailyMedicationFrequency) ...[
          Row(
            children: [
              Text(l10n.timesPerDay),
              DropdownButton<int>(
                value:
                    (state.frequency! as DailyMedicationFrequency).timesPerDay,
                items: [1, 2, 3, 4]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<ScheduleEditorCubit>().setFrequency(
                          DailyMedicationFrequency(timesPerDay: val),
                        );
                  }
                },
              ),
            ],
          ),
        ],
        if (state.frequency is EveryNDaysMedicationFrequency) ...[
          Row(
            children: [
              Text(l10n.everyPrefix),
              DropdownButton<int>(
                value: (state.frequency! as EveryNDaysMedicationFrequency).days,
                items: List.generate(14, (i) => i + 2)
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<ScheduleEditorCubit>().setFrequency(
                          EveryNDaysMedicationFrequency(days: val),
                        );
                  }
                },
              ),
              Text(l10n.daySuffix),
            ],
          ),
        ],
        if (state.frequency is WeeklyMedicationFrequency) ...[
          Row(
            children: [
              Text(l10n.dayOfWeek),
              DropdownButton<int>(
                value:
                    (state.frequency! as WeeklyMedicationFrequency).dayOfWeek,
                items: [1, 2, 3, 4, 5, 6, 7]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(_weekdayLabel(e, l10n)),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<ScheduleEditorCubit>().setFrequency(
                          WeeklyMedicationFrequency(dayOfWeek: val),
                        );
                  }
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTimeSelectors(
    BuildContext context,
    ScheduleEditorEditing state,
    AppLocalizations l10n,
  ) {
    if (state.administrationRoute != null &&
        !state.administrationRoute!.supportsScheduleTimes) {
      return const SizedBox.shrink();
    }

    var expectedTimes = 1;
    if (state.frequency is DailyMedicationFrequency) {
      expectedTimes =
          (state.frequency! as DailyMedicationFrequency).timesPerDay;
    }

    final currentTimes = List<TimeOfDay>.from(state.scheduleTimes);
    while (currentTimes.length < expectedTimes) {
      currentTimes.add(const TimeOfDay(hour: 8, minute: 0));
    }
    if (currentTimes.length > expectedTimes) {
      currentTimes.length = expectedTimes;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scheduleTimes,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < currentTimes.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              title: Text(
                material.TimeOfDay(
                  hour: currentTimes[i].hour,
                  minute: currentTimes[i].minute,
                ).format(context),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: material.TimeOfDay(
                    hour: currentTimes[i].hour,
                    minute: currentTimes[i].minute,
                  ),
                );
                if (time != null && context.mounted) {
                  final newTimes = List<TimeOfDay>.from(currentTimes);
                  newTimes[i] = TimeOfDay(hour: time.hour, minute: time.minute);
                  context
                      .read<ScheduleEditorCubit>()
                      .setScheduleTimes(newTimes);
                }
              },
            ),
          ),
      ],
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    return DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
  }

  String _weekdayLabel(int day, AppLocalizations l10n) {
    return switch (day) {
      1 => l10n.weekdayMonday,
      2 => l10n.weekdayTuesday,
      3 => l10n.weekdayWednesday,
      4 => l10n.weekdayThursday,
      5 => l10n.weekdayFriday,
      6 => l10n.weekdaySaturday,
      7 => l10n.weekdaySunday,
      _ => '$day',
    };
  }

  String _localizeValidation(String key, AppLocalizations l10n) {
    return switch (key) {
      'validationDosageRequired' => l10n.validationDosageRequired,
      'validationUnitRequired' => l10n.validationUnitRequired,
      'validationFrequencyRequired' => l10n.validationFrequencyRequired,
      'validationStartDateRequired' => l10n.validationStartDateRequired,
      'validationScheduleTimeRequired' => l10n.validationScheduleTimeRequired,
      'validationFieldsIncomplete' => l10n.validationFieldsIncomplete,
      _ => key,
    };
  }
}
