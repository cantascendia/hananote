import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hana_tokens.dart';

/// HanaInputVariant — see `docs/design/design-system/v2/components/input.md`.
enum HanaInputVariant {
  /// 单行输入。
  singleLine,

  /// 多行 textarea，`minLines: 3`。
  multiline,

  /// 末尾眼睛图标切换可见性。
  password,

  /// 数字键盘 + JetBrains Mono 字体（剂量 / 数值场景）。
  numeric,
}

/// HanaInput — v2 文本输入。
///
/// 无外框、底部 1px 烟灰线 / focus 时 2px 黛蓝呼吸线、月白底色、2px 圆角。
/// 替代 v1 9 处 Card-style TextField 与 8 处散落 `TextFormField`。
///
/// Spec: `docs/design/design-system/v2/components/input.md`.
///
/// Widget test hint:
/// ```dart
/// testWidgets('HanaInput shows 2px primary line on focus', (tester) async { ... });
/// testWidgets('HanaInput numeric variant uses JetBrains Mono', (tester) async { ... });
/// ```
class HanaInput extends StatefulWidget {
  const HanaInput({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.variant = HanaInputVariant.singleLine,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final HanaInputVariant variant;
  final Widget? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;

  @override
  State<HanaInput> createState() => _HanaInputState();
}

class _HanaInputState extends State<HanaInput> {
  late final FocusNode _node;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _node = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  TextInputType? _resolveKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType;
    switch (widget.variant) {
      case HanaInputVariant.numeric:
        return const TextInputType.numberWithOptions(decimal: true);
      case HanaInputVariant.multiline:
        return TextInputType.multiline;
      case HanaInputVariant.password:
      case HanaInputVariant.singleLine:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final isFocused = _node.hasFocus;

    Color lineColor;
    double lineHeight;
    if (hasError) {
      lineColor = HanaTokens.error(context);
      lineHeight = 2;
    } else if (isFocused) {
      lineColor = HanaTokens.primary(context);
      lineHeight = 2;
    } else {
      lineColor = HanaTokens.outline(context)
          .withValues(alpha: widget.enabled ? 1.0 : 0.38);
      lineHeight = 1;
    }

    final isMulti = widget.variant == HanaInputVariant.multiline;
    final isNumeric = widget.variant == HanaInputVariant.numeric;
    final isPassword = widget.variant == HanaInputVariant.password;

    final textStyle = (isNumeric ? HanaTokens.typography.mono : HanaTokens.typography.body)
        .copyWith(color: HanaTokens.ink(context));

    Widget? suffix = widget.suffix;
    if (isPassword) {
      suffix = GestureDetector(
        onTap: () => setState(() => _obscure = !_obscure),
        child: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: HanaTokens.inkSecondary(context),
        ),
      );
    }

    return Semantics(
      textField: true,
      label: widget.label,
      hint: widget.placeholder,
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: EdgeInsets.only(bottom: HanaTokens.spacing.xs),
              child: Text(
                widget.label!,
                style: HanaTokens.typography.label.copyWith(
                  color: HanaTokens.inkSecondary(context),
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: HanaTokens.background(context),
              borderRadius: HanaTokens.radius.input,
            ),
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.prefixIcon != null) ...[
                  Padding(
                    padding: EdgeInsets.only(left: HanaTokens.spacing.sm),
                    child: IconTheme(
                      data: IconThemeData(
                        size: 20,
                        color: HanaTokens.inkSecondary(context),
                      ),
                      child: widget.prefixIcon!,
                    ),
                  ),
                  SizedBox(width: HanaTokens.spacing.sm),
                ],
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: HanaTokens.spacing.sm,
                      horizontal: widget.prefixIcon == null
                          ? HanaTokens.spacing.xs
                          : 0,
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _node,
                      enabled: widget.enabled,
                      autofocus: widget.autofocus,
                      obscureText: isPassword && _obscure,
                      keyboardType: _resolveKeyboardType(),
                      textInputAction: widget.textInputAction,
                      minLines: isMulti ? 3 : 1,
                      maxLines: isMulti ? null : 1,
                      style: textStyle,
                      cursorColor: HanaTokens.primary(context),
                      inputFormatters: isNumeric
                          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                          : null,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: widget.placeholder,
                        hintStyle: textStyle.copyWith(
                          color: HanaTokens.inkSecondary(context),
                        ),
                      ),
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                    ),
                  ),
                ),
                if (suffix != null)
                  Padding(
                    padding: EdgeInsets.only(right: HanaTokens.spacing.sm),
                    child: suffix,
                  ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: HanaTokens.motion.instant,
            curve: HanaTokens.motion.easeOut,
            height: lineHeight,
            color: lineColor,
          ),
          if (hasError || (widget.helperText?.isNotEmpty ?? false))
            Padding(
              padding: EdgeInsets.only(top: HanaTokens.spacing.xs),
              child: Text(
                hasError ? widget.errorText! : widget.helperText!,
                style: HanaTokens.typography.bodySm.copyWith(
                  color: hasError
                      ? HanaTokens.error(context)
                      : HanaTokens.inkSecondary(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
