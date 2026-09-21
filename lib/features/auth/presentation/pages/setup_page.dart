// HanaNote v2 — First-run PIN setup page (HoYo redesign).
// Cream background + Petal Stamp + HoyoCard form with HoyoInput
// for the two PIN fields + biometric toggle + gold pill save CTA.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_card.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_eyebrow.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_input.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_pill_button.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart';

/// First-run PIN setup page.
class SetupPage extends StatefulWidget {
  /// Creates [SetupPage].
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();

  var _biometricEnabled = false;
  String? _errorText;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorText == null) return;
    setState(() => _errorText = null);
  }

  String? _validatePin(AppLocalizations l10n) {
    if (_pinController.text.length != 6 ||
        _confirmController.text.length != 6) {
      return l10n.pinFormatRequired;
    }
    if (_pinController.text != _confirmController.text) {
      return l10n.pinMismatch;
    }
    return null;
  }

  void _submit() {
    final errorText = _validatePin(AppLocalizations.of(context)!);
    if (errorText != null) {
      setState(() => _errorText = errorText);
      return;
    }

    context.read<AuthCubit>().setupPin(
          _pinController.text,
          _confirmController.text,
          biometricEnabled: _biometricEnabled,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: HanaColors.backgroundOf(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  SvgPicture.asset(
                    'assets/logo/hana_petal_stamp.svg',
                    width: 64,
                    height: 64,
                  ),
                  const SizedBox(height: 14),
                  const HoyoEyebrow('Set up · 设置密码', center: true),
                  const SizedBox(height: 8),
                  Text(
                    l10n.setupSecurePassword,
                    textAlign: TextAlign.center,
                    style: HanaTypography.headlineLg.copyWith(
                      color: HanaColors.primaryOf(context),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.setupPinDescription,
                      textAlign: TextAlign.center,
                      style: HanaTypography.bodyMd.copyWith(
                        color: HanaColors.onSurfaceVariantOf(context),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  HoyoCard(
                    cornerMark: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HoyoInput(
                          label: l10n.password.toUpperCase(),
                          controller: _pinController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          prefixIcon: Icons.lock_outline_rounded,
                          hint: '••••••',
                          onChanged: (_) => _clearError(),
                        ),
                        const SizedBox(height: 14),
                        HoyoInput(
                          label: l10n.confirmPassword.toUpperCase(),
                          controller: _confirmController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          prefixIcon: Icons.verified_user_outlined,
                          hint: '••••••',
                          onChanged: (_) => _clearError(),
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _errorText!,
                            style: HanaTypography.labelMd.copyWith(
                              color: HanaColors.tertiaryOf(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        // Biometric toggle row
                        Row(
                          children: [
                            const Icon(
                              Icons.fingerprint,
                              size: 22,
                              color: HanaColorsV2.goldDeep,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.enableBiometric,
                                style: HanaTypography.bodyMd.copyWith(
                                  color: HanaColors.onSurfaceOf(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: _biometricEnabled,
                              onChanged: (v) =>
                                  setState(() => _biometricEnabled = v),
                              activeThumbColor: HanaColorsV2.gold,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  HoyoPillButton(
                    label: l10n.save,
                    icon: Icons.check_circle,
                    variant: HoyoPillVariant.gold,
                    expand: true,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
