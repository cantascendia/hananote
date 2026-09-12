import 'package:flutter/material.dart';

import 'hana_button.dart';
import 'hana_tokens.dart';

/// HanaDialog — v2 极少使用的居中拦截弹窗。
///
/// **仅限 destructive 高敏操作**（删除日记 / 重置数据 / 注销账号）。
/// 所有非破坏性确认走 [HanaBottomSheet]。
///
/// Spec: `docs/design/design-system/v2/components/dialog.md`.
///
/// 用法：
/// ```dart
/// final ok = await HanaDialog.confirmDestructive(
///   context,
///   title: l10n.deleteJournalTitle,
///   message: l10n.deleteJournalBody,
///   confirmLabel: l10n.delete,
///   cancelLabel: l10n.cancel,
/// );
/// if (ok) bloc.add(const DeleteJournal());
/// ```
///
/// Widget test hint:
/// ```dart
/// testWidgets('HanaDialog confirmDestructive resolves true on confirm tap',
///   (tester) async { ... });
/// testWidgets('HanaDialog scrim is non-dismissible',
///   (tester) async { ... });
/// ```
class HanaDialog extends StatelessWidget {
  const HanaDialog._({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// 唯一暴露的入口 — 永远 resolve（false on cancel/back，true on confirm）。
  static Future<bool> confirmDestructive(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: title,
      barrierColor: HanaTokens.ink(context).withValues(alpha: 0.32),
      transitionDuration: HanaTokens.motion.standard,
      pageBuilder: (_, __, ___) => HanaDialog._(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: HanaTokens.motion.easeInOut,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width.clamp(280.0, 360.0);

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: title,
      child: Center(
        child: Material(
          type: MaterialType.canvas,
          color: HanaTokens.surfaceContainerLowest(context),
          elevation: 0,
          borderRadius: HanaTokens.radius.card,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              minWidth: 280,
            ),
            child: Padding(
              padding: EdgeInsets.all(HanaTokens.spacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: HanaTokens.typography.headline.copyWith(
                      color: HanaTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: HanaTokens.spacing.md),
                  Text(
                    message,
                    style: HanaTokens.typography.body.copyWith(
                      color: HanaTokens.inkSecondary(context),
                    ),
                  ),
                  SizedBox(height: HanaTokens.spacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      HanaButton(
                        label: cancelLabel,
                        variant: HanaButtonVariant.ghost,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      SizedBox(width: HanaTokens.spacing.md),
                      HanaButton(
                        label: confirmLabel,
                        variant: HanaButtonVariant.destructive,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
