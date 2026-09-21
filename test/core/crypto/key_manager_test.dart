import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/crypto/key_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late KeyManager keyManager;
  late MockFlutterSecureStorage mockSecureStorage;
  final inMemoryStorage = <String, String>{};

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    keyManager = KeyManager(mockSecureStorage);
    inMemoryStorage.clear();

    when(
      () => mockSecureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      final value = invocation.namedArguments[#value] as String?;
      if (value != null) {
        inMemoryStorage[key] = value;
      }
    });

    when(() => mockSecureStorage.read(key: any(named: 'key'))).thenAnswer((
      invocation,
    ) async {
      final key = invocation.namedArguments[#key] as String;
      return inMemoryStorage[key];
    });

    when(() => mockSecureStorage.delete(key: any(named: 'key'))).thenAnswer((
      invocation,
    ) async {
      final key = invocation.namedArguments[#key] as String;
      inMemoryStorage.remove(key);
    });
  });

  group('KeyManager', () {
    const password = 'mySuperStrongPassword123';

    test('initializeKey then getKey should return a 32-byte key', () async {
      await keyManager.initializeKey(password);
      final key = await keyManager.getKey();

      expect(key, isNotNull);
      expect(key, hasLength(32));
    });

    test('verifyPassword should return true for the correct password',
        () async {
      await keyManager.initializeKey(password);

      // Create a fresh KeyManager to clear the cache.
      keyManager = KeyManager(mockSecureStorage);

      final isValid = await keyManager.verifyPassword(password);
      expect(isValid, isTrue);
    });

    test('verifyPassword should return false for a wrong password', () async {
      await keyManager.initializeKey(password);

      keyManager = KeyManager(mockSecureStorage);

      final isValid = await keyManager.verifyPassword('wrongPassword!');
      expect(isValid, isFalse);
    });

    test('deleteKey then getKey should return null', () async {
      await keyManager.initializeKey(password);
      await keyManager.deleteKey();

      final key = await keyManager.getKey();
      expect(key, isNull);
    });

    test('initializeKey does not store the raw key in secure storage',
        () async {
      await keyManager.initializeKey(password);

      // The legacy key slot must not exist.
      expect(inMemoryStorage.containsKey('hananote_master_key'), isFalse);
      // The hash and salt must exist.
      expect(inMemoryStorage.containsKey('hananote_key_hash'), isTrue);
      expect(inMemoryStorage.containsKey('hananote_salt'), isTrue);
    });

    test('test: detects stored hash credential material', () async {
      await keyManager.initializeKey(password);

      keyManager = KeyManager(mockSecureStorage);

      expect(await keyManager.hasStoredCredentialMaterial(), isTrue);
      expect(await keyManager.getKey(), isNull);
    });

    test('test: detects legacy credential material', () async {
      inMemoryStorage['hananote_master_key'] = base64Encode(List.filled(32, 7));

      expect(await keyManager.hasStoredCredentialMaterial(), isTrue);
    });

    test('test: reports no credential material on clean storage', () async {
      expect(await keyManager.hasStoredCredentialMaterial(), isFalse);
    });

    test('getKey returns null before verifyPassword is called', () async {
      await keyManager.initializeKey(password);

      // Simulate a fresh session by creating a new KeyManager instance.
      keyManager = KeyManager(mockSecureStorage);

      final key = await keyManager.getKey();
      expect(key, isNull);
    });

    test('getKey returns key after successful verifyPassword', () async {
      await keyManager.initializeKey(password);

      keyManager = KeyManager(mockSecureStorage);

      await keyManager.verifyPassword(password);
      final key = await keyManager.getKey();
      expect(key, isNotNull);
      expect(key, hasLength(32));
    });

    group('legacy migration', () {
      test('migrates from raw key to hash on successful verify', () async {
        // Set up legacy storage: raw key + salt, no hash.
        await keyManager.initializeKey(password);
        final savedSalt = inMemoryStorage['hananote_salt']!;
        // Simulate legacy format: put key in legacy slot, remove hash.
        final key = await keyManager.getKey();
        inMemoryStorage['hananote_master_key'] = base64Encode(key!);
        inMemoryStorage.remove('hananote_key_hash');

        // Fresh manager — cache is empty.
        keyManager = KeyManager(mockSecureStorage);

        final isValid = await keyManager.verifyPassword(password);
        expect(isValid, isTrue);

        // Legacy key should be removed, hash should be stored.
        expect(inMemoryStorage.containsKey('hananote_master_key'), isFalse);
        expect(inMemoryStorage.containsKey('hananote_key_hash'), isTrue);
        // Salt should be unchanged.
        expect(inMemoryStorage['hananote_salt'], equals(savedSalt));
      });

      test('rejects wrong password on legacy format', () async {
        await keyManager.initializeKey(password);
        final key = await keyManager.getKey();
        inMemoryStorage['hananote_master_key'] = base64Encode(key!);
        inMemoryStorage.remove('hananote_key_hash');

        keyManager = KeyManager(mockSecureStorage);

        final isValid = await keyManager.verifyPassword('wrongPassword!');
        expect(isValid, isFalse);
        // Legacy key should NOT be removed on failure.
        expect(inMemoryStorage.containsKey('hananote_master_key'), isTrue);
      });
    });
  });
}
