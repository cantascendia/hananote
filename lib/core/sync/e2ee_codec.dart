// HanaNote v2 — End-to-end encryption codec.
// Wraps the existing CryptoEngine (Argon2id-derived KEK + AES-256-GCM)
// to produce ciphertext+nonce blobs ready to push to Supabase.
//
// Server-side promise: encrypted_records.ciphertext is opaque. The
// server NEVER possesses the master key — derived only from the
// user's PIN/biometric on the device.
//
// SECURITY NOTES (TODO double-review per 铁律 #14):
//   - The DEK (data encryption key) here is derived from the PIN-
//     derived KEK in flutter_secure_storage. This file MUST NOT
//     ever transmit the DEK over network.
//   - Each record uses a fresh 12-byte random nonce. Reusing a
//     nonce + key combination compromises GCM security.
//   - Key rotation: not implemented in v2. R53 to add.
//
// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class EncryptedBlob {
  const EncryptedBlob({required this.ciphertext, required this.nonce});

  final Uint8List ciphertext;
  final Uint8List nonce;
}

class E2eeCodec {
  /// Constructs the codec with a 32-byte master key (a DEK obtained
  /// from CryptoEngine.deriveKeyFromPin → KeyManager.unwrapDek).
  E2eeCodec(this._masterKey)
      : assert(
          _masterKey.length == 32,
          'AES-256-GCM requires a 32-byte master key (got '
          '${_masterKey.length}). See SPEC-cloud-sync.md §9.',
        );

  final Uint8List _masterKey;

  static final _rng = math.Random.secure();

  /// Encrypts a JSON-serializable Map → bytes ready for sync push.
  EncryptedBlob encode(Map<String, dynamic> payload) {
    final plaintext = utf8.encode(json.encode(payload));
    final nonce = _randomBytes(12);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(_masterKey),
          128,
          nonce,
          Uint8List(0),
        ),
      );
    final out = cipher.process(Uint8List.fromList(plaintext));
    return EncryptedBlob(ciphertext: out, nonce: nonce);
  }

  /// Decrypts a blob back to its original Map. Throws if MAC fails.
  Map<String, dynamic> decode(EncryptedBlob blob) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(_masterKey),
          128,
          blob.nonce,
          Uint8List(0),
        ),
      );
    final plain = cipher.process(blob.ciphertext);
    return json.decode(utf8.decode(plain)) as Map<String, dynamic>;
  }

  Uint8List _randomBytes(int n) {
    final out = Uint8List(n);
    for (var i = 0; i < n; i++) {
      out[i] = _rng.nextInt(256);
    }
    return out;
  }
}
