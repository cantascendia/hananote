// HanaNote v2 — Lock screen page (HoYo redesign).
// Cream background + Petal Stamp SVG + HoyoEyebrow + headline +
// 6-dot indicator (gold-light when filled) + HoyoPinPad.
// Per CONSTITUTION §1 + privacy policy: this is the gate to all
// encrypted local data.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_eyebrow.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_pin_pad.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:hananote/features/auth/presentation/auth_error_message.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_state.dart';

/// Lock screen with a custom HoYo-styled PIN keypad.
class LockScreenPage extends StatefulWidget {
  /// Creates [LockScreenPage].
  const LockScreenPage({
    required this.biometricAvailable,
    super.key,
  });

  /// Whether the biometric button should be enabled.
  final bool biometricAvailable;

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  String _pin = '';
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dots = List.generate(
      6,
      (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: index < _pin.length
              ? HanaColorsV2.goldLight
              : HanaColors.outlineVariantOf(context),
          shape: BoxShape.circle,
          boxShadow: index < _pin.length
              ? const [
                  BoxShadow(
                    color: Color(0x66E8C887),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
      ),
    );

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showError(authErrorMessage(l10n, state.message));
        }
      },
      child: Scaffold(
        backgroundColor: HanaColors.backgroundOf(context),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Petal Stamp logo
                    SvgPicture.asset(
                      'assets/logo/hana_petal_stamp.svg',
                      width: 72,
                      height: 72,
                    ),
                    const SizedBox(height: 18),
                    const HoyoEyebrow('Verify identity', center: true),
                    const SizedBox(height: 10),
                    Text(
                      l10n.welcomeBack,
                      textAlign: TextAlign.center,
                      style: HanaTypography.headlineMd.copyWith(
                        color: HanaColors.primaryOf(context),
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        // The single place we use 您 — privacy is solemn.
                        '为了保护您的健康隐私，请验证身份',
                        textAlign: TextAlign.center,
                        style: HanaTypography.labelMd.copyWith(
                          color: HanaColorsV2.goldDeep,
                          letterSpacing: 0.66,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // 6-dot indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dots
                          .expand((dot) => [dot, const SizedBox(width: 12)])
                          .toList()
                        ..removeLast(),
                    ),
                    const SizedBox(height: 12),
                    // Error message slot (always-on layout)
                    SizedBox(
                      height: 22,
                      child: AnimatedOpacity(
                        opacity: _errorMessage == null ? 0 : 1,
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          _errorMessage ?? '',
                          style: HanaTypography.labelMd.copyWith(
                            color: HanaColors.tertiaryOf(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    HoyoPinPad(
                      onDigit: _handleDigit,
                      onBackspace: _handleBackspace,
                      onBiometric: widget.biometricAvailable
                          ? () => context.read<AuthCubit>().unlockBiometric()
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Displays a red inline error and vibrates lightly.
  void showError(String message) {
    HapticFeedback.heavyImpact();
    setState(() => _errorMessage = message);
  }

  void clearError() {
    if (_errorMessage == null) return;
    setState(() => _errorMessage = null);
  }

  void _handleDigit(int digit) {
    if (_pin.length >= 6) return;
    clearError();
    final newPin = _pin + digit.toString();
    setState(() => _pin = newPin);
    if (newPin.length == 6) {
      Future.microtask(_handleConfirm);
    }
  }

  void _handleBackspace() {
    if (_pin.isEmpty) return;
    clearError();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _handleConfirm() {
    if (_pin.length != 6) {
      showError(AppLocalizations.of(context)!.enterFullPin);
      return;
    }
    final pin = _pin;
    setState(() => _pin = '');
    context.read<AuthCubit>().unlock(pin);
  }
}
