import 'dart:convert';
import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/backup/backup_vault_service.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/settings/domain/repositories/backup_restore_repository.dart';
import 'package:injectable/injectable.dart';

/// Exports all supported SQL-backed health records into a password vault.
@injectable
class ExportData {
  /// Creates the export use case.
  const ExportData(this._repository, this._vault);

  final BackupRestoreRepository _repository;
  final BackupVaultService _vault;

  /// Returns a `.vault` records backup encrypted with [password].
  Future<Either<Failure, Uint8List>> call({required String password}) async {
    final result = await _repository.exportRecords();
    if (result.isLeft()) return result.fold(left, (_) => right(Uint8List(0)));
    final payload = result.getOrElse((_) => throw StateError('Export failed'));
    final data = <String, Object?>{
      'format': 'hananote.records.v1',
      'version': '1.0',
      'exportDate': DateTime.now().toUtc().toIso8601String(),
      ...payload.tables,
    };
    return _vault.encryptJson(
        plaintextJson: jsonEncode(data), password: password);
  }
}
