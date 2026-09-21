import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/auth/domain/entities/auth_settings.dart';
import 'package:hananote/features/auth/domain/repositories/auth_repository.dart';
import 'package:hananote/features/auth/domain/usecases/setup_app.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late SetupApp useCase;

  setUpAll(() => registerFallbackValue(const AuthSettings(
        isSetup: false,
        biometricEnabled: false,
        appDisplayName: 'HanaNote',
        appIconKey: 'default',
        autoLockMinutes: 0,
        maxFailedAttempts: 0,
      )));

  setUp(() {
    repository = _MockAuthRepository();
    when(repository.hasProtectedSetupData)
        .thenAnswer((_) async => right(false));
    useCase = SetupApp(repository);
  });

  group('SetupApp', () {
    test('validates PIN format before setup', () async {
      final result = await useCase(const SetupAppParams(pin: '12'));

      expect(result.isLeft(), isTrue);
      verifyNever(() => repository.hasProtectedSetupData());
      verifyNever(() => repository.setupPassword(any()));
    });

    test('sets up password, saves settings, and opens database', () async {
      const params = SetupAppParams(
        pin: '123456',
        biometricEnabled: true,
        appDisplayName: 'Notes',
        appIconKey: 'lotus',
        autoLockMinutes: 5,
        maxFailedAttempts: 3,
      );
      const expectedSettings = AuthSettings(
        isSetup: true,
        biometricEnabled: true,
        appDisplayName: 'Notes',
        appIconKey: 'lotus',
        autoLockMinutes: 5,
        maxFailedAttempts: 3,
      );

      when(() => repository.hasProtectedSetupData()).thenAnswer(
        (_) async => const Right(false),
      );
      when(() => repository.setupPassword(params.pin)).thenAnswer(
        (_) async => const Right(null),
      );
      when(() => repository.saveSettings(expectedSettings)).thenAnswer(
        (_) async => const Right(null),
      );
      when(() => repository.openDatabase()).thenAnswer(
        (_) async => const Right(null),
      );

      final result = await useCase(params);

      expect(result.isRight(), isTrue);
      verifyInOrder([
        () => repository.hasProtectedSetupData(),
        () => repository.setupPassword(params.pin),
        () => repository.saveSettings(expectedSettings),
        () => repository.openDatabase(),
      ]);
    });

    test('test: refuses setup when protected data already exists', () async {
      when(() => repository.hasProtectedSetupData()).thenAnswer(
        (_) async => const Right(true),
      );

      final result = await useCase(const SetupAppParams(pin: '123456'));

      expect(result.isLeft(), isTrue);
      verify(() => repository.hasProtectedSetupData()).called(1);
      verifyNever(() => repository.setupPassword(any()));
      verifyNever(() => repository.discardIncompleteSetup());
    });

    test('test: returns setup password failure without public cleanup',
        () async {
      const params = SetupAppParams(pin: '123456');
      when(() => repository.hasProtectedSetupData()).thenAnswer(
        (_) async => const Right(false),
      );
      when(() => repository.setupPassword(params.pin)).thenAnswer(
        (_) async => const Left(Failure.auth(message: 'partial_write')),
      );
      when(() => repository.discardIncompleteSetup()).thenAnswer(
        (_) async => const Right(null),
      );

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      verifyNever(() => repository.discardIncompleteSetup());
      verifyNever(() => repository.saveSettings(any()));
      verifyNever(() => repository.openDatabase());
    });

    test('test: cleans incomplete setup when saving settings fails', () async {
      const params = SetupAppParams(pin: '123456');
      const expectedSettings = AuthSettings(
        isSetup: true,
        biometricEnabled: false,
        appDisplayName: 'HanaNote',
        appIconKey: 'default',
        autoLockMinutes: 0,
        maxFailedAttempts: 0,
      );
      when(() => repository.hasProtectedSetupData()).thenAnswer(
        (_) async => const Right(false),
      );
      when(() => repository.setupPassword(params.pin)).thenAnswer(
        (_) async => const Right(null),
      );
      when(() => repository.saveSettings(expectedSettings)).thenAnswer(
        (_) async => const Left(Failure.auth(message: 'save_failed')),
      );
      when(() => repository.discardIncompleteSetup()).thenAnswer(
        (_) async => const Right(null),
      );

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      verify(() => repository.discardIncompleteSetup()).called(1);
      verifyNever(() => repository.openDatabase());
    });

    test('test: cleans incomplete setup when opening database fails', () async {
      const params = SetupAppParams(pin: '123456');
      const expectedSettings = AuthSettings(
        isSetup: true,
        biometricEnabled: false,
        appDisplayName: 'HanaNote',
        appIconKey: 'default',
        autoLockMinutes: 0,
        maxFailedAttempts: 0,
      );
      when(() => repository.hasProtectedSetupData()).thenAnswer(
        (_) async => const Right(false),
      );
      when(() => repository.setupPassword(params.pin)).thenAnswer(
        (_) async => const Right(null),
      );
      when(() => repository.saveSettings(expectedSettings)).thenAnswer(
        (_) async => const Right(null),
      );
      when(() => repository.openDatabase()).thenAnswer(
        (_) async => const Left(Failure.database(message: 'open_failed')),
      );
      when(() => repository.discardIncompleteSetup()).thenAnswer(
        (_) async => const Right(null),
      );

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      verify(() => repository.discardIncompleteSetup()).called(1);
    });
  });
}
