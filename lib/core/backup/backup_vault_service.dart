import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/crypto/crypto_engine.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hashlib/hashlib.dart';
import 'package:injectable/injectable.dart';

/// Encrypts and decrypts HanaNote `.vault` backup files.
@lazySingleton
class BackupVaultService {
  /// Creates a [BackupVaultService].
  const BackupVaultService(this._cryptoEngine);

  /// Magic marker for HanaNote vault backup envelopes.
  static const String magic = 'HNVLT';

  /// Current vault envelope version.
  static const int version = 1;

  /// Random salt length for Argon2id key derivation.
  static const int saltLength = 16;

  /// AES-256 key length in bytes.
  static const int keyLength = 32;

  /// Default Argon2id memory cost in KiB.
  static const int memoryKiB = 32768;

  /// Default Argon2id iteration count.
  static const int iterations = 2;

  /// Default Argon2id parallelism.
  static const int parallelism = 1;

  /// Maximum accepted Argon2id memory cost when importing a vault.
  static const int maxMemoryKiB = 65536;

  /// Maximum accepted Argon2id iteration count when importing a vault.
  static const int maxIterations = 4;

  /// Maximum accepted Argon2id parallelism when importing a vault.
  static const int maxParallelism = 2;

  /// Maximum accepted vault file size in bytes.
  static const int maxVaultBytes = 20 * 1024 * 1024;

  /// Maximum plaintext payload that fits inside the bounded vault envelope.
  static const int maxPlaintextBytes = 12 * 1024 * 1024;

  final CryptoEngine _cryptoEngine;

  /// Encrypts [plaintextJson] with an independent backup [password].
  Future<Either<Failure, Uint8List>> encryptJson({
    required String plaintextJson,
    required String password,
  }) async {
    if (password.isEmpty || utf8.encode(password).length > 1024) {
      return left(
        const Failure.validation(message: 'Backup password required.'),
      );
    }

    if (utf8.encode(plaintextJson).length > maxPlaintextBytes) {
      return left(
          const Failure.validation(message: 'Backup file is too large.'));
    }
    final salt = _randomBytes(saltLength);
    final key =
        await Isolate.run(() => _deriveKey(password: password, salt: salt));
    final aad = _aad(salt);
    final encrypted = await _cryptoEngine.encrypt(
      Uint8List.fromList(utf8.encode(plaintextJson)),
      key,
      aad: aad,
    );

    return encrypted.map((payload) {
      final vault = <String, dynamic>{
        'magic': magic,
        'version': version,
        'kdf': <String, dynamic>{
          'name': 'argon2id',
          'memoryKiB': memoryKiB,
          'iterations': iterations,
          'parallelism': parallelism,
          'saltB64': base64Encode(salt),
        },
        'cipher': <String, dynamic>{
          'algorithm': 'AES-256-GCM',
          'payloadB64': base64Encode(payload),
        },
      };
      return Uint8List.fromList(utf8.encode(jsonEncode(vault)));
    });
  }

  /// Decrypts a `.vault` payload with [password].
  Future<Either<Failure, String>> decryptJson({
    required Uint8List vaultBytes,
    required String password,
  }) async {
    try {
      if (vaultBytes.length > maxVaultBytes) {
        return left(
          const Failure.validation(message: 'Backup file is too large.'),
        );
      }
      if (password.isEmpty || utf8.encode(password).length > 1024) {
        return left(
          const Failure.validation(message: 'Backup password required.'),
        );
      }

      final vault = jsonDecode(utf8.decode(vaultBytes)) as Map<String, dynamic>;
      final kdf = _readAndValidateKdf(vault);
      final cipher = vault['cipher'] as Map<String, dynamic>? ?? const {};
      if (cipher['algorithm'] != 'AES-256-GCM') {
        return left(
          const Failure.validation(message: 'Unsupported backup cipher.'),
        );
      }

      final salt = base64Decode(kdf.saltB64);
      final payload = base64Decode(cipher['payloadB64'] as String? ?? '');
      final key = await Isolate.run(() => _deriveKey(
            password: password,
            salt: salt,
            memory: kdf.memory,
            passes: kdf.passes,
            lanes: kdf.lanes,
          ));
      final decrypted = await _cryptoEngine.decrypt(
        Uint8List.fromList(payload),
        key,
        aad: _aad(
          salt,
          memory: kdf.memory,
          passes: kdf.passes,
          lanes: kdf.lanes,
        ),
      );
      return decrypted.map((bytes) => utf8.decode(bytes));
    } on FormatException catch (e) {
      return left(Failure.validation(message: e.message));
    } catch (_) {
      return left(
        const Failure.crypto(message: 'Backup password or file is invalid.'),
      );
    }
  }

  /// Returns true when [bytes] look like a HanaNote vault JSON envelope.
  bool looksLikeVault(Uint8List bytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return decoded['magic'] == magic;
    } catch (_) {
      return false;
    }
  }

  _KdfParams _readAndValidateKdf(Map<String, dynamic> vault) {
    if (vault['magic'] != magic || vault['version'] != version) {
      throw const FormatException('Unsupported vault version.');
    }
    final kdf = vault['kdf'] as Map<String, dynamic>? ?? const {};
    if (kdf['name'] != 'argon2id') {
      throw const FormatException('Unsupported KDF.');
    }

    final memory = kdf['memoryKiB'] as int? ?? 0;
    final passes = kdf['iterations'] as int? ?? 0;
    final lanes = kdf['parallelism'] as int? ?? 0;
    final saltB64 = kdf['saltB64'] as String? ?? '';
    final salt = base64Decode(saltB64);

    final invalid = memory <= 0 ||
        memory > maxMemoryKiB ||
        passes <= 0 ||
        passes > maxIterations ||
        lanes <= 0 ||
        lanes > maxParallelism ||
        salt.length != saltLength;
    if (invalid) {
      throw const FormatException('Unsafe KDF parameters.');
    }
    return _KdfParams(
      memory: memory,
      passes: passes,
      lanes: lanes,
      saltB64: saltB64,
    );
  }

  static Uint8List _deriveKey({
    required String password,
    required Uint8List salt,
    int memory = memoryKiB,
    int passes = iterations,
    int lanes = parallelism,
  }) {
    final argon2 = Argon2(
      parallelism: lanes,
      memorySizeKB: memory,
      iterations: passes,
      hashLength: keyLength,
      salt: salt,
    );
    return Uint8List.fromList(argon2.convert(utf8.encode(password)).bytes);
  }

  Uint8List _aad(
    Uint8List salt, {
    int memory = memoryKiB,
    int passes = iterations,
    int lanes = parallelism,
  }) {
    final value = '$magic|$version|argon2id|$memory|$passes|$lanes|'
        '${base64Encode(salt)}';
    return Uint8List.fromList(utf8.encode(value));
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}

class _KdfParams {
  const _KdfParams({
    required this.memory,
    required this.passes,
    required this.lanes,
    required this.saltB64,
  });

  final int memory;
  final int passes;
  final int lanes;
  final String saltB64;
}
