import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/crypto/key_manager.dart';
import 'package:hananote/core/database/secure_database.dart';
import 'package:hananote/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:hananote/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hananote/features/auth/domain/entities/auth_settings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

class _LocalData extends Mock implements AuthLocalDataSource {}

class _Keys extends Mock implements KeyManager {}

class _Database extends Mock implements SecureDatabase {}

class _Storage extends Mock implements FlutterSecureStorage {}

class _Biometrics extends Mock implements LocalAuthentication {}

void main() {
  late _Keys keys;
  late _LocalData localData;
  late _Database database;
  late _Biometrics biometrics;
  late AuthRepositoryImpl repository;

  setUp(() {
    keys = _Keys();
    localData = _LocalData();
    database = _Database();
    biometrics = _Biometrics();
    repository = AuthRepositoryImpl(
      localData,
      keys,
      database,
      _Storage(),
      biometrics,
    );
  });

  test('unsupported PIN rotation cannot orphan existing encrypted records',
      () async {
    final result = await repository.changePassword('123456', '654321');
    expect(result.isLeft(), isTrue);
    verifyZeroInteractions(keys);
    verifyZeroInteractions(database);
  });

  test('cold start never advertises biometrics without a decryption key',
      () async {
    when(keys.getKey).thenAnswer((_) async => null);
    final result = await repository.isBiometricAvailable();
    expect(result.getOrElse((_) => true), isFalse);
    verifyZeroInteractions(biometrics);
  });

  test('direct biometric invocation cannot bypass the cold-start PIN gate',
      () async {
    when(keys.getKey).thenAnswer((_) async => null);
    final result = await repository.authenticateBiometric();
    expect(result.getOrElse((_) => true), isFalse);
    verifyZeroInteractions(biometrics);
    verifyZeroInteractions(database);
  });

  test('missing auth settings with existing key material fails closed',
      () async {
    when(localData.hasSettings).thenAnswer((_) async => false);
    when(keys.hasStoredCredentialMaterial).thenAnswer((_) async => true);

    final result = await repository.getSettings();

    expect(result.isLeft(), isTrue);
    verifyNever(() => localData.getSettings());
    verifyNever(() => keys.initializeKey(any()));
  });

  test('setup false settings with existing key material fails closed',
      () async {
    when(localData.hasSettings).thenAnswer((_) async => true);
    when(keys.hasStoredCredentialMaterial).thenAnswer((_) async => true);
    when(localData.getSettings).thenAnswer(
      (_) async => const AuthSettings(
        isSetup: false,
        biometricEnabled: false,
        appDisplayName: 'HanaNote',
        appIconKey: 'default',
        autoLockMinutes: 0,
        maxFailedAttempts: 0,
      ),
    );

    final result = await repository.getSettings();

    expect(result.isLeft(), isTrue);
    verifyNever(() => keys.initializeKey(any()));
  });

  test('setupPassword refuses to overwrite existing key material', () async {
    when(keys.hasStoredCredentialMaterial).thenAnswer((_) async => true);

    final result = await repository.setupPassword('123456');

    expect(result.isLeft(), isTrue);
    verifyNever(() => keys.initializeKey(any()));
  });

  test('discardIncompleteSetup is non destructive without setup ownership',
      () async {
    final result = await repository.discardIncompleteSetup();

    expect(result.isLeft(), isTrue);
    verifyNever(() => database.close());
    verifyNever(() => keys.deleteKey());
    verifyNever(() => localData.clearSettings());
  });

  test('failed clean setup discards only newly owned artifacts', () async {
    final tempDir = await Directory.systemTemp.createTemp('hananote_auth_');
    addTearDown(() => tempDir.delete(recursive: true));

    when(keys.hasStoredCredentialMaterial).thenAnswer((_) async => false);
    when(() => database.getDatabasePath()).thenAnswer(
      (_) async => '${tempDir.path}${Platform.pathSeparator}missing.db',
    );
    when(() => keys.initializeKey(any()))
        .thenThrow(StateError('partial write'));
    when(() => database.close()).thenAnswer((_) async => right(null));
    when(() => keys.deleteKey()).thenAnswer((_) async {});
    when(() => localData.clearSettings()).thenAnswer((_) async {});

    final setupResult = await repository.setupPassword('123456');

    expect(setupResult.isLeft(), isTrue);
    verify(() => keys.deleteKey()).called(1);
    verify(() => localData.clearSettings()).called(1);
  });
}
