// HoYo · PIN pad — 12-button grid (3×4): digits 1..9, biometric,
// digit 0, backspace. Each button is a 64×64 white circle on cream
// with subtle gold ring.
// Mirrors preview/18-pin-pad.html.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

enum HoyoPinKey { digit, biometric, backspace }

class HoyoPinPadEntry {
  const HoyoPinPadEntry({
    required this.kind,
    this.digit,
    this.icon,
  });

  final HoyoPinKey kind;
  final int? digit;
  final IconData? icon;
}

class HoyoPinPad extends StatelessWidget {
  const HoyoPinPad({
    required this.onDigit,
    required this.onBackspace,
    super.key,
    this.onBiometric,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;

  static const List<HoyoPinPadEntry> _layout = [
    HoyoPinPadEntry(kind: HoyoPinKey.digit, digit: 1),
    HoyoPinPadEntry(kind: HoyoPinKey.digit, digit: 2),
    HoyoPinPadEntry(kind: HoyoPinKey.digit, digit: 3),
    HoyoPinPadEntry(kind: HoyoPinKey.digit, digit: 4),
    HoyoPinPadEntry(kind: HoyoPinKey.digit, digit: 5),
    HoyoPinPadEntry(kind: HoyoPinKey.digit, digit: 6),
    HoyoPinPadEntry(kind: HoyoPinKey.digit, digit: 7),
    HoyoPinPadEntry(kind: HoyoPinKey.digit, digit: 8),
    HoyoPinPadEntry(kind: HoyoPinKey.digit, digit: 9),
    HoyoPinPadEntry(kind: HoyoPinKey.biometric, icon: Icons.fingerprint),
    HoyoPinPadEntry(kind: HoyoPinKey.digit, digit: 0),
    HoyoPinPadEntry(kind: HoyoPinKey.backspace, icon: Icons.backspace_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final e in _layout) _PinKey(entry: e, parent: this),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.entry, required this.parent});

  final HoyoPinPadEntry entry;
  final HoyoPinPad parent;

  @override
  Widget build(BuildContext context) {
    final disabled =
        entry.kind == HoyoPinKey.biometric && parent.onBiometric == null;
    return Center(
      child: GestureDetector(
        onTap: disabled
            ? null
            : () {
                switch (entry.kind) {
                  case HoyoPinKey.digit:
                    parent.onDigit(entry.digit!);
                  case HoyoPinKey.biometric:
                    parent.onBiometric?.call();
                  case HoyoPinKey.backspace:
                    parent.onBackspace();
                }
              },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HanaColors.surfaceContainerLowestOf(context),
            border: Border.all(
              color: HanaColorsV2.goldLight.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: HanaColors.primaryOf(context).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: switch (entry.kind) {
            HoyoPinKey.digit => Text(
                '${entry.digit}',
                style: HanaTypography.headlineMd.copyWith(
                  color: HanaColors.primaryOf(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            HoyoPinKey.biometric || HoyoPinKey.backspace => Icon(
                entry.icon,
                size: 24,
                color: disabled
                    ? HanaColors.onSurfaceVariantOf(context)
                        .withValues(alpha: 0.4)
                    : HanaColors.primaryOf(context),
              ),
          },
        ),
      ),
    );
  }
}
