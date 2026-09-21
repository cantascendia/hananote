import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hananote/features/auth/domain/entities/auth_settings.dart';
import 'package:injectable/injectable.dart';

/// Local storage for auth settings that must be readable before DB unlock.
abstract interface class AuthLocalDataSource {
  /// Loads persisted auth settings or returns defaults.
  Future<AuthSettings> getSettings();

  /// Returns whether persisted auth settings exist.
  Future<bool> hasSettings();

  /// Persists [settings].
  Future<void> saveSettings(AuthSettings settings);

  /// Clears stored auth settings.
  Future<void> clearSettings();
}

/// Secure-storage-backed implementation of [AuthLocalDataSource].
@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  /// Creates [AuthLocalDataSourceImpl].
  AuthLocalDataSourceImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  static const String _settingsKey = 'auth_settings';

  @override
  Future<AuthSettings> getSettings() async {
    final raw = await _secureStorage.read(key: _settingsKey);
    if (raw == null) {
      return _defaultSettings();
    }

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return AuthSettings(
      isSetup: json['isSetup'] as bool? ?? false,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      appDisplayName: json['appDisplayName'] as String? ?? 'HanaNote',
      appIconKey: json['appIconKey'] as String? ?? 'default',
      autoLockMinutes: json['autoLockMinutes'] as int? ?? 0,
      maxFailedAttempts: json['maxFailedAttempts'] as int? ?? 0,
    );
  }

  @override
  Future<bool> hasSettings() async {
    return await _secureStorage.read(key: _settingsKey) != null;
  }

  @override
  Future<void> saveSettings(AuthSettings settings) async {
    await _secureStorage.write(
      key: _settingsKey,
      value: jsonEncode(
        <String, dynamic>{
          'isSetup': settings.isSetup,
          'biometricEnabled': settings.biometricEnabled,
          'appDisplayName': settings.appDisplayName,
          'appIconKey': settings.appIconKey,
          'autoLockMinutes': settings.autoLockMinutes,
          'maxFailedAttempts': settings.maxFailedAttempts,
        },
      ),
    );
  }

  @override
  Future<void> clearSettings() => _secureStorage.delete(key: _settingsKey);

  AuthSettings _defaultSettings() {
    return const AuthSettings(
      isSetup: false,
      biometricEnabled: false,
      appDisplayName: 'HanaNote',
      appIconKey: 'default',
      autoLockMinutes: 0,
      maxFailedAttempts: 0,
    );
  }
}
