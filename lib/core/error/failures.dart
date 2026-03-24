import 'package:equatable/equatable.dart';

/// Base type for domain and data failures.
abstract class Failure extends Equatable {
  /// Creates a failure with a stable [code].
  const Failure(this.code);

  /// Stable machine-readable failure code.
  final String code;

  @override
  List<Object> get props => <Object>[code];
}

/// Failure raised by encrypted database operations.
final class DatabaseFailure extends Failure {
  /// Creates a database failure.
  const DatabaseFailure() : super('database_failure');
}

/// Failure raised by encryption or key management operations.
final class CryptoFailure extends Failure {
  /// Creates a crypto failure.
  const CryptoFailure() : super('crypto_failure');
}

/// Failure raised by invalid input data.
final class ValidationFailure extends Failure {
  /// Creates a validation failure.
  const ValidationFailure() : super('validation_failure');
}
