// HanaNote v2 — Sync telemetry.
// Per ARE audit (handbook §43.4): silent-failure detection is the
// most important reliability primitive for any background-sync UX.
// Without it, "user thinks data synced, it didn't" goes undetected.
//
// This module holds in-memory counters + persists the LAST timestamps
// to flutter_secure_storage so the Profile UI can surface
// "上次同步: X 分钟前". Counters reset on app restart (acceptable —
// the timestamps are the durable source of truth).
//
// ignore_for_file: public_member_api_docs

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SyncTelemetry {
  SyncTelemetry({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Process-wide default instance. Tests can construct their own.
  static final SyncTelemetry instance = SyncTelemetry();

  final FlutterSecureStorage _storage;

  static const _kLastPushOkAt = 'sync_last_push_ok_at';
  static const _kLastPullOkAt = 'sync_last_pull_ok_at';
  static const _kLastFailureReason = 'sync_last_failure_reason';
  static const _kLastFailureAt = 'sync_last_failure_at';

  // In-memory counters; reset on cold start.
  int pushOk = 0;
  int pushFail = 0;
  int pullOk = 0;
  int pullFail = 0;
  int decryptFail = 0;
  int totalAccepted = 0;
  int totalApplied = 0;
  int totalRejected = 0;

  /// Called by SyncEngine after a successful push round.
  Future<void> recordPushOk({required int acceptedCount}) async {
    pushOk++;
    totalAccepted += acceptedCount;
    await _storage.write(
      key: _kLastPushOkAt,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Called when push fails or any record is rejected by the server.
  Future<void> recordPushFail({
    required String reason,
    int rejectedCount = 0,
  }) async {
    pushFail++;
    totalRejected += rejectedCount;
    await _storage.write(key: _kLastFailureReason, value: reason);
    await _storage.write(
      key: _kLastFailureAt,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Called by SyncEngine after a successful pull round.
  Future<void> recordPullOk({required int appliedCount}) async {
    pullOk++;
    totalApplied += appliedCount;
    await _storage.write(
      key: _kLastPullOkAt,
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<void> recordPullFail({required String reason}) async {
    pullFail++;
    await _storage.write(key: _kLastFailureReason, value: reason);
    await _storage.write(
      key: _kLastFailureAt,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Per-record decrypt failure during a pull (does NOT abort the batch).
  void recordDecryptFail() {
    decryptFail++;
  }

  /// Used by Profile UI to render "上次同步：X 分钟前".
  /// Returns the most recent of push-ok / pull-ok; null if neither happened.
  Future<DateTime?> lastSuccessfulSyncAt() async {
    final push = await _storage.read(key: _kLastPushOkAt);
    final pull = await _storage.read(key: _kLastPullOkAt);
    DateTime? max;
    if (push != null) {
      max = DateTime.tryParse(push);
    }
    if (pull != null) {
      final pulled = DateTime.tryParse(pull);
      if (pulled != null && (max == null || pulled.isAfter(max))) {
        max = pulled;
      }
    }
    return max;
  }

  /// Last failure pair for diagnostics (Profile → 「最近一次失败」row).
  Future<({String reason, DateTime at})?> lastFailure() async {
    final reason = await _storage.read(key: _kLastFailureReason);
    final atStr = await _storage.read(key: _kLastFailureAt);
    if (reason == null || atStr == null) return null;
    final at = DateTime.tryParse(atStr);
    if (at == null) return null;
    return (reason: reason, at: at);
  }

  /// Reset (used by sign-out / wipe).
  Future<void> reset() async {
    pushOk = 0;
    pushFail = 0;
    pullOk = 0;
    pullFail = 0;
    decryptFail = 0;
    totalAccepted = 0;
    totalApplied = 0;
    totalRejected = 0;
    await _storage.delete(key: _kLastPushOkAt);
    await _storage.delete(key: _kLastPullOkAt);
    await _storage.delete(key: _kLastFailureReason);
    await _storage.delete(key: _kLastFailureAt);
  }

  Map<String, dynamic> snapshot() => {
        'push_ok': pushOk,
        'push_fail': pushFail,
        'pull_ok': pullOk,
        'pull_fail': pullFail,
        'decrypt_fail': decryptFail,
        'total_accepted': totalAccepted,
        'total_applied': totalApplied,
        'total_rejected': totalRejected,
      };
}
