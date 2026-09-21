import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/di/injection.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/auth/supabase_client.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_pill_button.dart';
import 'package:hananote/features/medication/domain/entities/drug.dart';
import 'package:hananote/features/medication/domain/entities/enums.dart';
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:uuid/uuid.dart';

/// Three-step onboarding wizard shown on first launch.
class OnboardingPage extends StatefulWidget {
  /// Creates an [OnboardingPage].
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _saving = false;
  bool _drugSaved = false;

  final _nameController = TextEditingController();
  DateTime? _hrtStartDate;
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
    if (_saving) return;
    final bloc = context.read<SettingsBloc>();
    if (bloc.state is! SettingsLoaded) {
      bloc.add(const LoadSettingsDashboard());
      _showSaveError();
      return;
    }
    setState(() => _saving = true);

    final drugName = _drugNameController.text.trim();
    if (drugName.isNotEmpty && !_drugSaved) {
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
      final result = await getIt<MedicationRepository>().addDrug(drug);
      if (!mounted) return;
      if (result.isLeft()) {
        setState(() => _saving = false);
        _showSaveError();
        return;
      }
      _drugSaved = true;
    }
    if (!mounted) return;
    final completed = bloc.stream.firstWhere((state) =>
        state is SettingsError ||
        state is SettingsLoaded && state.settings.hasCompletedOnboarding);
    final name = _nameController.text.trim();
    bloc.add(MarkOnboardingComplete(
      displayName: name.isEmpty ? null : name,
      hrtStartDate: _hrtStartDate,
    ));
    final result = await completed;
    if (!mounted) return;
    setState(() => _saving = false);
    if (result is SettingsError) {
      _showSaveError();
    } else {
      context.go(HanaSupabase.isConfigured ? '/auth' : '/today');
    }
  }

  void _showSaveError() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.saveFailed(l10n.retry))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              HanaColors.primaryContainerOf(context),
              HanaColors.backgroundOf(context),
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
                            ? HanaColors.primaryOf(context)
                            : HanaColors.outlineVariantOf(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
      return HoyoPillButton(
        label: l10n.onboardingNext,
        icon: Icons.arrow_forward,
        expand: true,
        onPressed: () => _goToPage(1),
      );
    }

    if (_currentPage == 1) {
      return Column(
        children: [
          HoyoPillButton(
            label: l10n.onboardingNext,
            icon: Icons.arrow_forward,
            expand: true,
            onPressed: () => _goToPage(2),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _goToPage(2),
            child: Text(
              l10n.onboardingSkipHrt,
              style: TextStyle(
                color: HanaColors.onSurfaceVariantOf(context),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Final CTA — gold variant marks the journey's threshold.
        HoyoPillButton(
          label: l10n.onboardingDone,
          icon: Icons.auto_awesome,
          variant: HoyoPillVariant.gold,
          expand: true,
          onPressed: _saving ? null : _completeOnboarding,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _saving ? null : _completeOnboarding,
          child: Text(
            l10n.onboardingDrugOptional,
            style: TextStyle(
              color: HanaColors.onSurfaceVariantOf(context),
            ),
          ),
        ),
      ],
    );
  }
}

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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HanaColors.surfaceContainerLowestOf(context),
            ),
            child: Icon(
              Icons.local_florist,
              size: 48,
              color: HanaColors.primaryOf(context),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingWelcome,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              color: HanaColors.primaryOf(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingWelcomeSub,
            style: TextStyle(
              fontSize: 15,
              color: HanaColors.onSurfaceVariantOf(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HanaColors.surfaceContainerLowestOf(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: HanaColors.primaryContainerOf(context).withAlpha(77),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingSetName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HanaColors.onSurfaceOf(context),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: l10n.onboardingNameHint,
                    filled: true,
                    fillColor: HanaColors.surfaceContainerLowOf(context),
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
                    color:
                        HanaColors.onSurfaceVariantOf(context).withAlpha(179),
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HanaColors.surfaceContainerLowestOf(context),
            ),
            child: Icon(
              Icons.calendar_month,
              size: 48,
              color: HanaColors.primaryOf(context),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingSetHrtDate,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              color: HanaColors.primaryOf(context),
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
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: HanaColors.surfaceContainerLowestOf(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: HanaColors.primaryContainerOf(context).withAlpha(77),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 32,
                    color: HanaColors.primaryOf(context).withAlpha(128),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedDate != null
                        ? '${selectedDate!.year}'
                            '-${selectedDate!.month.toString().padLeft(2, '0')}'
                            '-${selectedDate!.day.toString().padLeft(2, '0')}'
                        : l10n.selectDate,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: HanaColors.onSurfaceOf(context),
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
                        color: HanaColors.primaryContainerOf(context)
                            .withAlpha(77),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.hrtDay(hrtDayCount),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: HanaColors.primaryOf(context),
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HanaColors.surfaceContainerLowestOf(context),
            ),
            child: Icon(
              Icons.medication,
              size: 48,
              color: HanaColors.primaryOf(context),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingAddDrug,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              color: HanaColors.primaryOf(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HanaColors.surfaceContainerLowestOf(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: HanaColors.primaryContainerOf(context).withAlpha(77),
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
                    fillColor: HanaColors.surfaceContainerLowOf(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: HanaColors.onSurfaceVariantOf(context),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<DrugCategory>(
                  initialValue: selectedCategory,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: HanaColors.surfaceContainerLowOf(context),
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: HanaColors.onSurfaceVariantOf(context),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<AdministrationRoute>(
                  initialValue: selectedRoute,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: HanaColors.surfaceContainerLowOf(context),
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
