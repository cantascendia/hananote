import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_local_datasource.dart';

/// Skeleton repository implementation for medication data.
final class MedicationRepositoryImpl implements MedicationRepository {
  /// Creates the repository implementation.
  const MedicationRepositoryImpl({required this.localDataSource});

  /// Local encrypted data source used by this repository.
  final MedicationLocalDataSource localDataSource;
}
