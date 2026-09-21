// HoYo · Input — 12px radius + gold focus ring.
// Mirrors preview/17-inputs.html.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter;

import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

class HoyoInput extends StatelessWidget {
  const HoyoInput({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final fg = HanaColors.onSurfaceOf(context);
    final fgVariant = HanaColors.onSurfaceVariantOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: HanaTypography.labelMd.copyWith(
              color: HanaColorsV2.goldDeep,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: HanaTypography.bodyMd.copyWith(color: fg),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: HanaTypography.bodyMd.copyWith(color: fgVariant),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 18, color: fgVariant),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: HanaColors.surfaceContainerLowOf(context),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: HanaColorsV2.goldLight.withValues(alpha: 0.18),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: HanaColorsV2.goldLight.withValues(alpha: 0.18),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: HanaColorsV2.goldLight.withValues(alpha: 0.7),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
