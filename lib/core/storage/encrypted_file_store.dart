import 'dart:typed_data';

/// Contract for encrypted file persistence.
abstract class EncryptedFileStore {
  /// Encrypts and stores [bytes] under [relativePath].
  Future<String> store({
    required String relativePath,
    required Uint8List bytes,
  });

  /// Reads and decrypts the file at [relativePath].
  Future<Uint8List> read(String relativePath);

  /// Deletes the file at [relativePath].
  Future<void> delete(String relativePath);
}
