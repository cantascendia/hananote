import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/features/auth/presentation/auth_error_message.dart';

void main() {
  for (final language in ['en', 'zh', 'ja']) {
    test('auth UI localizes known errors and hides plugin details in $language',
        () async {
      final l10n = await AppLocalizations.delegate.load(Locale(language));
      expect(authErrorMessage(l10n, '密码错误'), l10n.authIncorrectPin);
      expect(authErrorMessage(l10n, '两次输入的密码不一致'), l10n.pinMismatch);
      expect(authErrorMessage(l10n, 'synthetic private SQL exception'),
          l10n.authOperationFailed);
    });
  }
}
