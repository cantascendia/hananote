import 'package:hananote/core/l10n/arb/app_localizations.dart';

/// Converts authentication failures to localized, privacy-safe UI text.
String authErrorMessage(AppLocalizations l10n, String code) {
  return switch (code) {
    '密码错误' => l10n.authIncorrectPin,
    '两次输入的密码不一致' => l10n.pinMismatch,
    'PIN must be exactly 6 digits.' => l10n.pinFormatRequired,
    _ => l10n.authOperationFailed,
  };
}
