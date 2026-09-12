// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/di/injection.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/features/medication/domain/entities/drug.dart';
import 'package:hananote/features/medication/domain/entities/enums.dart';
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:uuid/uuid.dart';

/// Three-step onboarding wizard shown on first launch.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 1 — Name
  final _nameController = TextEditingController();

  // Step 2 — HRT date
  DateTime? _hrtStartDate;

  // Step 3 — Drug
  final _drugNameController = TextEditingController();
  DrugCategory _selectedCategory = DrugCategory.estrogen;
  AdministrationRoute _selectedRoute = AdministrationRoute.oral;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _drugNameController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final bloc = context.read<SettingsBloc>();

    // Save display name
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      bloc.add(UpdateDisplayName(name: name));
    }

    // Save HRT start date
    if (_hrtStartDate != null) {
      bloc.add(UpdateHrtStartDate(date: _hrtStartDate!));
    }

    // Save drug if provided
    final drugName = _drugNameController.text.trim();
    if (drugName.isNotEmpty) {
      final drug = Drug(
        id: const Uuid().v4(),
        name: drugName,
        genericName: '',
        category: _selectedCategory,
        administrationRoute: _selectedRoute,
        defaultDosageUnit: _selectedRoute.supportedUnits.first,
        isActive: true,
        createdAt: DateTime.now(),
      );
      await getIt<MedicationRepository>().addDrug(drug);
    }

    // Mark onboarding complete
    bloc.add(const MarkOnboardingComplete());

    if (mounted) {
      context.go('/today');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              HanaColors.primaryContainer,
              HanaColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    _WelcomeStep(
                      nameController: _nameController,
                      l10n: l10n,
                    ),
                    _HrtDateStep(
                      selectedDate: _hrtStartDate,
                      onDateSelected: (date) {
                        setState(() => _hrtStartDate = date);
                      },
                      l10n: l10n,
                    ),
                    _DrugStep(
                      drugNameController: _drugNameController,
                      selectedCategory: _selectedCategory,
                      selectedRoute: _selectedRoute,
                      onCategoryChanged: (cat) {
                        setState(() => _selectedCategory = cat);
                      },
                      onRouteChanged: (route) {
                        setState(() => _selectedRoute = route);
                      },
                      l10n: l10n,
                    ),
                  ],
                ),
              ),
              // Dot indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? HanaColors.primary
                            : HanaColors.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
              // Navigation buttons
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _buildButtons(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(AppLocalizations l10n) {
    if (_currentPage == 0) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: () => _goToPage(1),
          style: FilledButton.styleFrom(
            backgroundColor: HanaColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(l10n.onboardingNext),
        ),
      );
    }

    if (_currentPage == 1) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => _goToPage(2),
              style: FilledButton.styleFrom(
                backgroundColor: HanaColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(l10n.onboardingNext),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _goToPage(2),
            child: Text(
              l10n.onboardingSkipHrt,
              style: const TextStyle(color: HanaColors.onSurfaceVariant),
            ),
          ),
        ],
      );
    }

    // Page 2 — final step
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: _completeOnboarding,
            style: FilledButton.styleFrom(
              backgroundColor: HanaColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(l10n.onboardingDone),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _completeOnboarding,
          child: Text(
            l10n.onboardingDrugOptional,
            style: const TextStyle(color: HanaColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step widgets
// ---------------------------------------------------------------------------

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.nameController, required this.l10n});

  final TextEditingController nameController;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: HanaColors.surfaceContainerLowest,
            ),
            child: const Icon(
              Icons.local_florist,
              size: 48,
              color: HanaColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingWelcome,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              color: HanaColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingWelcomeSub,
            style: const TextStyle(
              fontSize: 15,
              color: HanaColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HanaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: HanaColors.primaryContainer.withAlpha(77),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingSetName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HanaColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: l10n.onboardingNameHint,
                    filled: true,
                    fillColor: HanaColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.onboardingNameNote,
                  style: TextStyle(
                    fontSize: 12,
                    color: HanaColors.onSurfaceVariant.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HrtDateStep extends StatelessWidget {
  const _HrtDateStep({
    required this.selectedDate,
    required this.onDateSelected,
    required this.l10n,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final hrtDayCount = selectedDate != null
        ? DateTime.now().difference(selectedDate!).inDays
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: HanaColors.surfaceContainerLowest,
            ),
            child: const Icon(
              Icons.calendar_month,
              size: 48,
              color: HanaColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingSetHrtDate,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              color: HanaColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: HanaColors.primary,
                        onPrimary: HanaColors.onPrimary,
                        surface: HanaColors.surfaceContainerLowest,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: HanaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: HanaColors.primaryContainer.withAlpha(77),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 32,
                    color: HanaColors.primary.withAlpha(128),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedDate != null
                        ? '${selectedDate!.year}'
                            '-${selectedDate!.month.toString().padLeft(2, '0')}'
                            '-${selectedDate!.day.toString().padLeft(2, '0')}'
                        : l10n.selectDate,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: HanaColors.onSurface,
                    ),
                  ),
                  if (selectedDate != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: HanaColors.primaryContainer.withAlpha(77),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.hrtDay(hrtDayCount),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: HanaColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrugStep extends StatelessWidget {
  const _DrugStep({
    required this.drugNameController,
    required this.selectedCategory,
    required this.selectedRoute,
    required this.onCategoryChanged,
    required this.onRouteChanged,
    required this.l10n,
  });

  final TextEditingController drugNameController;
  final DrugCategory selectedCategory;
  final AdministrationRoute selectedRoute;
  final ValueChanged<DrugCategory> onCategoryChanged;
  final ValueChanged<AdministrationRoute> onRouteChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: HanaColors.surfaceContainerLowest,
            ),
            child: const Icon(
              Icons.medication,
              size: 48,
              color: HanaColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingAddDrug,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              color: HanaColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HanaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: HanaColors.primaryContainer.withAlpha(77),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: drugNameController,
                  decoration: InputDecoration(
                    hintText: l10n.drugName,
                    filled: true,
                    fillColor: HanaColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.category,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: HanaColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<DrugCategory>(
                  initialValue: selectedCategory,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: HanaColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: DrugCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) onCategoryChanged(val);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.route,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: HanaColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<AdministrationRoute>(
                  initialValue: selectedRoute,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: HanaColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: AdministrationRoute.values.map((route) {
                    return DropdownMenuItem(
                      value: route,
                      child: Text(route.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) onRouteChanged(val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
