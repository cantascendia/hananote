import 'dart:typed_data';

/// Contract for byte and file encryption operations.
abstract class CryptoEngine {
  /// Encrypts raw [bytes] and returns the encrypted payload.
  Future<Uint8List> encrypt(Uint8List bytes);

  /// Decrypts encrypted [bytes] and returns the original payload.
  Future<Uint8List> decrypt(Uint8List bytes);

  /// Encrypts the file at [path] and returns the encrypted file path.
  Future<String> encryptFile(String path);

  /// Decrypts the file at [path] and returns the decrypted file path.
  Future<String> decryptFile(String path);
}
