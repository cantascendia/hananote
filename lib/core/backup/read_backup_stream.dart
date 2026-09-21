import 'dart:typed_data';

import 'package:hananote/core/backup/backup_vault_service.dart';

/// Reads a selected backup with a hard limit even if its metadata is wrong.
Future<Uint8List> readBackupStream({
  required Stream<List<int>> stream,
  required int declaredSize,
  int maxBytes = BackupVaultService.maxVaultBytes,
}) async {
  if (declaredSize < 0 || declaredSize > maxBytes) {
    throw const FormatException('Backup file is too large.');
  }
  final builder = BytesBuilder(copy: false);
  await for (final chunk in stream) {
    if (chunk.length > maxBytes - builder.length) {
      throw const FormatException('Backup file is too large.');
    }
    builder.add(chunk);
  }
  return builder.takeBytes();
}
