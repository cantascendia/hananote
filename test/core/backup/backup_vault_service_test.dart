import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/backup/backup_vault_service.dart';
import 'package:hananote/core/crypto/crypto_engine.dart';
import 'package:hananote/core/error/failures.dart';

void main() {
  late BackupVaultService service;

  setUp(() {
    service = BackupVaultService(CryptoEngine());
  });

  test('round-trips encrypted vault payload', () async {
    const payload = '{"version":"1.0","drugs":[{"name":"synthetic"}]}';

    final encrypted = await service.encryptJson(
      plaintextJson: payload,
      password: 'correct horse battery staple',
    );
    expect(encrypted.isRight(), isTrue);

    final vaultBytes = encrypted.getRight().toNullable()!;
    expect(utf8.decode(vaultBytes), isNot(contains('synthetic')));
    expect(service.looksLikeVault(vaultBytes), isTrue);

    final decrypted = await service.decryptJson(
      vaultBytes: vaultBytes,
      password: 'correct horse battery staple',
    );
    expect(decrypted.getRight().toNullable(), payload);
  });

  test('rejects wrong backup password', () async {
    final encrypted = await service.encryptJson(
      plaintextJson: '{"version":"1.0"}',
      password: 'correct horse battery staple',
    );

    final decrypted = await service.decryptJson(
      vaultBytes: encrypted.getRight().toNullable()!,
      password: 'wrong password',
    );

    expect(decrypted.isLeft(), isTrue);
    expect(decrypted.getLeft().toNullable(), isA<CryptoFailure>());
  });

  test('rejects tampered ciphertext', () async {
    final encrypted = await service.encryptJson(
      plaintextJson: '{"version":"1.0"}',
      password: 'correct horse battery staple',
    );
    final vault = jsonDecode(
      utf8.decode(encrypted.getRight().toNullable()!),
    ) as Map<String, dynamic>;
    final cipher = vault['cipher'] as Map<String, dynamic>;
    final payload = base64Decode(cipher['payloadB64'] as String);
    payload[payload.length - 1] ^= 1;
    cipher['payloadB64'] = base64Encode(payload);

    final decrypted = await service.decryptJson(
      vaultBytes: Uint8List.fromList(utf8.encode(jsonEncode(vault))),
      password: 'correct horse battery staple',
    );

    expect(decrypted.isLeft(), isTrue);
    expect(decrypted.getLeft().toNullable(), isA<CryptoFailure>());
  });

  test('rejects malicious KDF parameters before deriving key', () async {
    final encrypted = await service.encryptJson(
      plaintextJson: '{"version":"1.0"}',
      password: 'correct horse battery staple',
    );
    final vault = jsonDecode(
      utf8.decode(encrypted.getRight().toNullable()!),
    ) as Map<String, dynamic>;
    final kdf = vault['kdf'] as Map<String, dynamic>;
    kdf['memoryKiB'] = BackupVaultService.maxMemoryKiB + 1;

    final decrypted = await service.decryptJson(
      vaultBytes: Uint8List.fromList(utf8.encode(jsonEncode(vault))),
      password: 'correct horse battery staple',
    );

    expect(decrypted.isLeft(), isTrue);
    expect(decrypted.getLeft().toNullable(), isA<ValidationFailure>());
  });
  test('test: maximum accepted plaintext remains importable', () async {
    final payload = 'x' * BackupVaultService.maxPlaintextBytes;
    final encrypted = await service.encryptJson(
      plaintextJson: payload,
      password: 'boundary password',
    );
    expect(encrypted.isRight(), isTrue);
    final vaultBytes = encrypted.getRight().toNullable()!;
    expect(
        vaultBytes.length, lessThanOrEqualTo(BackupVaultService.maxVaultBytes));
    final decrypted = await service.decryptJson(
      vaultBytes: vaultBytes,
      password: 'boundary password',
    );
    expect(decrypted.getRight().toNullable(), payload);
  });
}
