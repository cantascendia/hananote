import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/l10n/enum_l10n.dart';
import 'package:hananote/core/utils/id_generator.dart';
import 'package:hananote/features/medication/domain/entities/drug.dart';
import 'package:hananote/features/medication/domain/entities/drug_templates.dart';
import 'package:hananote/features/medication/domain/entities/enums.dart';
import 'package:hananote/features/medication/presentation/bloc/drug_list_cubit.dart';

/// Page to add a new medication.
///
/// Shows a template picker first for quick setup, with option
/// to create a custom drug via manual form.
class AddDrugPage extends StatefulWidget {
  /// Creates an [AddDrugPage].
  const AddDrugPage({super.key});

  @override
  State<AddDrugPage> createState() => _AddDrugPageState();
}

class _AddDrugPageState extends State<AddDrugPage> {
  /// Whether the user has switched to the manual form.
  bool _showManualForm = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _notesController = TextEditingController();

  DrugCategory _category = DrugCategory.estrogen;
  AdministrationRoute _route = AdministrationRoute.oral;
  DosageUnit? _unit;

  @override
  void initState() {
    super.initState();
    _unit = _route.supportedUnits.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectTemplate(DrugTemplate template) {
    final newDrug = Drug(
      id: IdGenerator.generate(),
      name: template.name,
      genericName: template.genericName,
      category: template.category,
      administrationRoute: template.route,
      defaultDosageUnit: template.unit,
      isActive: true,
      createdAt: DateTime.now(),
    );

    context.read<DrugListCubit>().addDrug(newDrug);
    Navigator.of(context).pop();
  }

  void _onRouteChanged(AdministrationRoute route) {
    setState(() {
      _route = route;
      if (!route.supportedUnits.contains(_unit)) {
        _unit = route.supportedUnits.first;
      }
    });
  }

  void _submitManual() {
    if (!_formKey.currentState!.validate()) return;
    if (_unit == null) return;

    final newDrug = Drug(
      id: IdGenerator.generate(),
      name: _nameController.text.trim(),
      genericName: _genericNameController.text.trim(),
      category: _category,
      administrationRoute: _route,
      defaultDosageUnit: _unit!,
      isActive: true,
      createdAt: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    context.read<DrugListCubit>().addDrug(newDrug);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: HanaColors.backgroundOf(context),
      appBar: AppBar(
        title: Text(l10n.addDrug),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: _showManualForm
            ? [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _submitManual,
                  tooltip: l10n.save,
                ),
              ]
            : null,
      ),
      body:
          _showManualForm ? _buildManualForm(l10n) : _buildTemplatePicker(l10n),
    );
  }

  // -- Template Picker --

  Widget _buildTemplatePicker(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // Header
        Text(
          l10n.drugTemplateTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: HanaColors.onSurfaceOf(context),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.drugTemplateSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: HanaColors.onSurfaceVariantOf(context),
          ),
        ),
        const SizedBox(height: 20),

        // Category sections
        for (final entry in HrtDrugTemplates.byCategory.entries) ...[
          _buildCategoryHeader(entry.key, l10n),
          const SizedBox(height: 10),
          ...entry.value.map(
            (t) => _buildTemplateCard(t, l10n),
          ),
          const SizedBox(height: 16),
        ],

        // Custom drug option
        const SizedBox(height: 8),
        _buildCustomDrugButton(l10n),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryHeader(DrugCategory cat, AppLocalizations l10n) {
    final color = _categoryColor(cat);
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          cat.localizedName(l10n),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: HanaColors.onSurfaceOf(context),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(DrugTemplate template, AppLocalizations l10n) {
    final color = _categoryColor(template.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: HanaColors.surfaceContainerLowestOf(context),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _selectTemplate(template),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Emoji icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      template.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Drug info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: HanaColors.onSurfaceOf(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        template.genericName,
                        style: TextStyle(
                          fontSize: 12,
                          color: HanaColors.onSurfaceVariantOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
                // Route badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    template.route.localizedName(l10n),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.add_circle_outline,
                  size: 22,
                  color: HanaColors.primaryOf(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDrugButton(AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _showManualForm = true),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: HanaColors.outlineVariantOf(context),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: HanaColors.onSurfaceVariantOf(context),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.drugCustomAdd,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: HanaColors.onSurfaceVariantOf(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(DrugCategory cat) {
    return switch (cat) {
      DrugCategory.estrogen => HanaColors.primaryOf(context),
      DrugCategory.antiAndrogen => const Color(0xFF4A90D9),
      DrugCategory.progestogen => HanaColors.secondaryOf(context),
      DrugCategory.auxiliary => const Color(0xFF2CBAA0),
    };
  }

  // -- Manual Form (existing) --

  Widget _buildManualForm(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '${l10n.drugName} *',
              border: const OutlineInputBorder(),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return l10n.required;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _genericNameController,
            decoration: InputDecoration(
              labelText: l10n.genericName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.category, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<DrugCategory>(
            segments: DrugCategory.values.map((cat) {
              return ButtonSegment(
                value: cat,
                label: Text(cat.localizedName(l10n)),
              );
            }).toList(),
            selected: {_category},
            onSelectionChanged: (set) {
              setState(() => _category = set.first);
            },
          ),
          const SizedBox(height: 24),
          Text(l10n.route, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AdministrationRoute.values.map((route) {
              return ChoiceChip(
                label: Text(route.localizedName(l10n)),
                selected: _route == route,
                onSelected: (val) {
                  if (val) _onRouteChanged(route);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(l10n.unit, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _route.supportedUnits.map((unit) {
              return ChoiceChip(
                label: Text(unit.localizedName(l10n)),
                selected: _unit == unit,
                onSelected: (val) {
                  if (val) setState(() => _unit = unit);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.notes,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: _submitManual,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }
}
