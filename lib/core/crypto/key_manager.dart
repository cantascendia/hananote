import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hashlib/hashlib.dart';
import 'package:injectable/injectable.dart';
import 'package:pointycastle/export.dart' as pc;

/// Manages key derivation and secure storage.
///
/// Security model: the actual encryption key is **never** persisted to disk.
/// Only a SHA-256 verification hash of the key is stored so that PIN
/// correctness can be checked. The key itself lives only in the in-memory
/// [_cachedKey] after a successful [verifyPassword] or [initializeKey] call.
@lazySingleton
class KeyManager {
  /// Constructor for [KeyManager].
  KeyManager(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  static const String _hashStorageKey = 'hananote_key_hash';
  static const String _saltStorageKey = 'hananote_salt';

  /// Legacy key used in versions prior to the hash-based scheme.
  static const String _legacyKeyStorageKey = 'hananote_master_key';

  static const int _saltLength = 16;
  static const int _hashLength = 32;

  // Native: strong Argon2 (64 MB, 3 iterations, 4 threads).
  // Web: lighter Argon2 (4 MB, 2 iterations, 1 thread) to avoid UI freeze.
  static const int _memorySizeKb = kIsWeb ? 4096 : 65536;
  static const int _iterations = kIsWeb ? 2 : 3;
  static const int _parallelism = kIsWeb ? 1 : 4;
  Uint8List? _cachedKey;

  /// Derive key from password using Argon2id and save a verification hash.
  ///
  /// The actual key is kept only in [_cachedKey] — never written to storage.
  Future<void> initializeKey(String password) async {
    final salt = _generateSalt();
    final key = await _deriveKeyAsync(password, salt);
    final hash = _computeHash(key);

    await _secureStorage.write(
      key: _saltStorageKey,
      value: base64Encode(salt),
    );
    await _secureStorage.write(
      key: _hashStorageKey,
      value: base64Encode(hash),
    );

    // Remove any legacy key that might exist from a previous version.
    await _secureStorage.delete(key: _legacyKeyStorageKey);

    _cachedKey = key;
  }

  /// Returns the current session key from the in-memory cache.
  ///
  /// Returns `null` if [verifyPassword] or [initializeKey] has not been called
  /// in the current session — the key is **never** read back from storage.
  Future<Uint8List?> getKey() async {
    return _cachedKey;
  }

  /// Returns the current in-memory session key without reading it from storage.
  Future<Uint8List?> getCurrentKey() {
    return getKey();
  }

  /// Returns whether any persisted credential verifier material exists.
  Future<bool> hasStoredCredentialMaterial() async {
    final encodedSalt = await _secureStorage.read(key: _saltStorageKey);
    final encodedHash = await _secureStorage.read(key: _hashStorageKey);
    final encodedLegacyKey =
        await _secureStorage.read(key: _legacyKeyStorageKey);
    return encodedSalt != null ||
        encodedHash != null ||
        encodedLegacyKey != null;
  }

  /// Verifies whether [password] derives the same master key as the stored one.
  ///
  /// On success the derived key is cached in memory so that [getKey] can
  /// return it for the remainder of the session.
  ///
  /// Handles transparent migration from the legacy scheme where the raw key
  /// was persisted instead of a hash.
  Future<bool> verifyPassword(String password) async {
    final encodedSalt = await _secureStorage.read(key: _saltStorageKey);
    if (encodedSalt == null) return false;

    final salt = base64Decode(encodedSalt);
    final testKey = await _deriveKeyAsync(password, salt);

    // --- Legacy migration path ---
    final encodedLegacyKey =
        await _secureStorage.read(key: _legacyKeyStorageKey);
    if (encodedLegacyKey != null) {
      final legacyKey = base64Decode(encodedLegacyKey);
      if (_constantTimeEquals(testKey, legacyKey)) {
        // Migrate: store hash, delete raw key.
        final hash = _computeHash(testKey);
        await _secureStorage.write(
          key: _hashStorageKey,
          value: base64Encode(hash),
        );
        await _secureStorage.delete(key: _legacyKeyStorageKey);
        _cachedKey = testKey;
        return true;
      }
      return false;
    }

    // --- New hash-based path ---
    final encodedStoredHash = await _secureStorage.read(key: _hashStorageKey);
    if (encodedStoredHash == null) return false;

    final storedHash = base64Decode(encodedStoredHash);
    final testHash = _computeHash(testKey);

    if (_constantTimeEquals(testHash, storedHash)) {
      _cachedKey = testKey;
      return true;
    }
    return false;
  }

  /// Deletes the persisted key material and clears the in-memory cache.
  Future<void> deleteKey() async {
    await _secureStorage.delete(key: _hashStorageKey);
    await _secureStorage.delete(key: _saltStorageKey);
    await _secureStorage.delete(key: _legacyKeyStorageKey);
    _cachedKey = null;
  }

  Uint8List _generateSalt() {
    final random = Random.secure();
    final salt = Uint8List(_saltLength);
    for (var i = 0; i < _saltLength; i++) {
      salt[i] = random.nextInt(256);
    }
    return salt;
  }

  Future<Uint8List> _deriveKeyAsync(String password, Uint8List salt) {
    return compute(_deriveKeyTask, (password, salt));
  }

  static Uint8List _deriveKeyTask((String, Uint8List) input) {
    return _deriveKey(input.$1, input.$2);
  }

  static Uint8List _deriveKey(String password, Uint8List salt) {
    if (kIsWeb) {
      // Web: use PBKDF2-SHA256 (fast, browser-friendly, no memory issues).
      // Argon2 freezes the browser even at reduced params due to JS main thread.
      final pbkdf2 = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
        ..init(pc.Pbkdf2Parameters(salt, 100000, _hashLength));
      return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
    }

    // Native: use Argon2id (strong memory-hard KDF).
    final derivator = Argon2(
      parallelism: _parallelism,
      memorySizeKB: _memorySizeKb,
      iterations: _iterations,
      hashLength: _hashLength,
      salt: salt,
    );

    return Uint8List.fromList(derivator.convert(utf8.encode(password)).bytes);
  }

  Uint8List _computeHash(Uint8List key) {
    return Uint8List.fromList(sha256.convert(key).bytes);
  }

  bool _constantTimeEquals(Uint8List left, Uint8List right) {
    if (left.length != right.length) return false;

    var result = 0;
    for (var i = 0; i < left.length; i++) {
      result |= left[i] ^ right[i];
    }
    return result == 0;
  }
}
