import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/settings/domain/entities/backup_restore_payload.dart';

/// Atomic reader and writer for backup-supported SQL records.
abstract interface class BackupRestoreRepository {
  /// Reads a consistent snapshot of all supported record collections.
  Future<Either<Failure, BackupRestorePayload>> exportRecords();

  /// Replaces matching IDs in one SQLCipher transaction.
  Future<Either<Failure, int>> restore(BackupRestorePayload payload);
}
