import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/error/failures.dart';

void main() {
  group('Failure codes', () {
    test('database failure exposes a stable code', () {
      expect(const DatabaseFailure().code, 'database_failure');
    });

    test('crypto failure exposes a stable code', () {
      expect(const CryptoFailure().code, 'crypto_failure');
    });

    test('validation failure exposes a stable code', () {
      expect(const ValidationFailure().code, 'validation_failure');
    });
  });
}
