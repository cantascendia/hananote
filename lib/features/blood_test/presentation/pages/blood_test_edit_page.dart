import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/di/injection.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/l10n/enum_l10n.dart';
import 'package:hananote/core/utils/id_generator.dart';
import 'package:hananote/features/blood_test/domain/entities/blood_test_report.dart';
import 'package:hananote/features/blood_test/domain/entities/enums.dart';
import 'package:hananote/features/blood_test/domain/entities/hormone_reading.dart';
import 'package:hananote/features/blood_test/domain/repositories/blood_test_repository.dart';
import 'package:hananote/features/blood_test/domain/usecases/add_blood_test_report.dart';
import 'package:hananote/features/blood_test/domain/usecases/update_blood_test_report.dart';
import 'package:hananote/features/blood_test/presentation/bloc/blood_test_bloc.dart';
import 'package:hananote/features/blood_test/presentation/bloc/blood_test_event.dart';
import 'package:intl/intl.dart';

/// Page for creating or editing a blood test report.
class BloodTestEditPage extends StatefulWidget {
  /// Creates a [BloodTestEditPage].
  const BloodTestEditPage({super.key, this.reportId});

  /// Existing report id when editing.
  final String? reportId;

  @override
  State<BloodTestEditPage> createState() => _BloodTestEditPageState();
}

class _ReadingEntry {
  _ReadingEntry({
    required this.type,
    required this.value,
    required this.unit,
  });

  HormoneType type;
  double value;
  String unit;
}

class _BloodTestEditPageState extends State<BloodTestEditPage> {
  late DateTime _testDate;
  late final TextEditingController _labNameController;
  late final TextEditingController _notesController;
  final List<_ReadingEntry> _readings = [];
  bool _isLoading = false;
  bool _isSaving = false;

  /// Original report when editing, used to preserve id / createdAt.
  BloodTestReport? _existingReport;

  bool get _isEditing => widget.reportId != null;

  @override
  void initState() {
    super.initState();
    _testDate = DateTime.now();
    _labNameController = TextEditingController();
    _notesController = TextEditingController();

    if (_isEditing) {
      _loadExistingReport();
    }
  }

  Future<void> _loadExistingReport() async {
    setState(() => _isLoading = true);

    final result =
        await getIt<BloodTestRepository>().getReportById(widget.reportId!);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loadFailed)),
        );
      },
      (report) {
        _existingReport = report;
        _testDate = report.testDate;
        _labNameController.text = report.labName ?? '';
        _notesController.text = report.notes ?? '';
        _readings.clear();
        for (final reading in report.readings) {
          _readings.add(
            _ReadingEntry(
              type: reading.type,
              value: reading.value,
              unit: reading.unit,
            ),
          );
        }
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _labNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _testDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _testDate = picked);
    }
  }

  void _addReading() {
    // Pick the first hormone type not yet used, or default to estradiol.
    final usedTypes = _readings.map((r) => r.type).toSet();
    final available =
        HormoneType.values.where((t) => !usedTypes.contains(t)).toList();
    final defaultType =
        available.isNotEmpty ? available.first : HormoneType.estradiol;

    setState(() {
      _readings.add(
        _ReadingEntry(
          type: defaultType,
          value: 0,
          unit: defaultType.defaultUnit,
        ),
      );
    });
  }

  void _removeReading(int index) {
    setState(() => _readings.removeAt(index));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;

    if (_readings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.atLeastOneReading)),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final reportId = _isEditing ? _existingReport!.id : IdGenerator.generate();
    final createdAt = _isEditing ? _existingReport!.createdAt : now;

    final readings = _readings.map((entry) {
      return HormoneReading(
        id: IdGenerator.generate(),
        reportId: reportId,
        type: entry.type,
        value: entry.value,
        unit: entry.unit,
      );
    }).toList();

    final report = BloodTestReport(
      id: reportId,
      testDate: _testDate,
      readings: readings,
      createdAt: createdAt,
      labName: _labNameController.text.trim().isEmpty
          ? null
          : _labNameController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final result = _isEditing
        ? await getIt<UpdateBloodTestReport>()(report)
        : await getIt<AddBloodTestReport>()(report);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.saveFailed(failure.message))),
        );
      },
      (_) {
        getIt<BloodTestBloc>().add(const BloodTestEvent.loadDashboard());
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: HanaColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HanaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? l10n.editBloodReport : l10n.addBloodReport,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: HanaColors.primary,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(
                Icons.check_circle_outline,
                color: HanaColors.primary,
              ),
              onPressed: _save,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  _buildDateField(l10n),
                  const SizedBox(height: 16),
                  _buildLabField(l10n),
                  const SizedBox(height: 16),
                  _buildNotesField(l10n),
                  const SizedBox(height: 24),
                  _buildReadingsSection(l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildDateField(AppLocalizations l10n) {
    return _CardWrapper(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: const Icon(
          Icons.calendar_today,
          color: HanaColors.primary,
          size: 20,
        ),
        title: Text(
          l10n.testDate,
          style: const TextStyle(
            fontSize: 13,
            color: HanaColors.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          DateFormat.yMMMd().format(_testDate),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: HanaColors.onSurface,
          ),
        ),
        onTap: _pickDate,
      ),
    );
  }

  Widget _buildLabField(AppLocalizations l10n) {
    return _CardWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: _labNameController,
          decoration: InputDecoration(
            labelText: l10n.labName,
            labelStyle: const TextStyle(color: HanaColors.onSurfaceVariant),
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.local_hospital_outlined,
              color: HanaColors.primary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesField(AppLocalizations l10n) {
    return _CardWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: _notesController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n.notes,
            labelStyle: const TextStyle(color: HanaColors.onSurfaceVariant),
            border: InputBorder.none,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(
                Icons.notes_outlined,
                color: HanaColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadingsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.addReading,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: HanaColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ..._readings.asMap().entries.map(
              (entry) => _buildReadingTile(l10n, entry.key, entry.value),
            ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: _addReading,
            icon: const Icon(Icons.add_circle_outline),
            label: Text(l10n.addReading),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingTile(
    AppLocalizations l10n,
    int index,
    _ReadingEntry entry,
  ) {
    // Each reading gets its own value controller seeded from the entry.
    return Dismissible(
      key: ValueKey('reading_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeReading(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: HanaColors.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: HanaColors.error),
      ),
      child: _CardWrapper(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<HormoneType>(
                      initialValue: entry.type,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.selectHormone,
                        labelStyle: const TextStyle(
                          color: HanaColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: HormoneType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.localizedName(l10n),
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (newType) {
                        if (newType != null) {
                          setState(() {
                            entry
                              ..type = newType
                              ..unit = newType.defaultUnit;
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: HanaColors.error,
                      size: 20,
                    ),
                    onPressed: () => _removeReading(index),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue:
                          entry.value == 0 ? '' : entry.value.toString(),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.hormoneValue,
                        labelStyle: const TextStyle(
                          color: HanaColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (text) {
                        final parsed = double.tryParse(text);
                        if (parsed != null) {
                          entry.value = parsed;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: Text(
                      entry.unit,
                      style: const TextStyle(
                        fontSize: 14,
                        color: HanaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardWrapper extends StatelessWidget {
  const _CardWrapper({required this.child, this.margin});

  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: HanaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: HanaColors.onSurface.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
