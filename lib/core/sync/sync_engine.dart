// HanaNote v2 — Sync engine.
// Orchestrates push/pull cycles between local SQLCipher records and
// Supabase encrypted_records via E2EE codec + Edge Functions.
//
// Per SPEC-cloud-sync.md §10 + ARE audit 2026-05-06:
// - Push uses PER-ID ack contract (server returns accepted_ids[] —
//   client only marks those clean, the rest stay dirty for retry).
// - Pull isolates decrypt failures (one bad nonce/GCM-tag does NOT
//   abort the whole batch; per-record counters surface to telemetry).
// - SyncTelemetry tracks success/failure counters + timestamps so a
//   silent stall ("user thinks data synced, it didn't") is detectable.
//
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';

// Telemetry side-effect futures are intentionally fire-and-forget; the
// sync path must not block on local secure-storage I/O for ops counters.
// ignore_for_file: unawaited_futures

import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/auth/supabase_client.dart';
import 'package:hananote/core/sync/e2ee_codec.dart';
import 'package:hananote/core/sync/sync_queue.dart';
import 'package:hananote/core/sync/sync_telemetry.dart';

sealed class SyncFailure {
  const SyncFailure(this.message);
  final String message;
}

class SyncDisabled extends SyncFailure {
  const SyncDisabled() : super('cloud sync disabled');
}

class SyncNetwork extends SyncFailure {
  const SyncNetwork(super.message);
}

class SyncCryptoFailed extends SyncFailure {
  const SyncCryptoFailed(super.message);
}

/// Detailed result of a single push cycle. The bloc / UI can show
/// "pushed N, retry M" instead of just "ok".
class PushResult {
  const PushResult({
    required this.acceptedIds,
    required this.rejectedIds,
    required this.dirtyTotal,
  });

  final List<String> acceptedIds;
  final List<String> rejectedIds;
  final int dirtyTotal;

  int get acceptedCount => acceptedIds.length;
  int get rejectedCount => rejectedIds.length;

  /// True when the server confirmed every submitted record.
  bool get fullySynced =>
      rejectedIds.isEmpty && acceptedIds.length == dirtyTotal;
}

/// Detailed result of a single pull cycle.
class PullResult {
  const PullResult({
    required this.appliedCount,
    required this.decryptFailedIds,
    required this.nextSince,
  });

  final int appliedCount;
  final List<String> decryptFailedIds;
  final DateTime nextSince;
}

class SyncEngine {
  SyncEngine({
    required E2eeCodec codec,
    required SyncQueue queue,
    SyncTelemetry? telemetry,
  })  : _codec = codec,
        _queue = queue,
        _telemetry = telemetry ?? SyncTelemetry.instance;

  final E2eeCodec _codec;
  final SyncQueue _queue;
  final SyncTelemetry _telemetry;

  /// Push all pending dirty records.
  ///
  /// Per SPEC §10.2 the server returns `accepted: [id, id, ...]` (the
  /// authoritative list of upserted IDs). Only those are marked clean;
  /// rejected/unacked rows stay dirty for the next push cycle.
  Future<Either<SyncFailure, PushResult>> pushPending() async {
    if (!HanaSupabase.isConfigured) {
      _telemetry.recordPushFail(reason: 'cloud_disabled');
      return const Left(SyncDisabled());
    }
    try {
      final dirty = await _queue.takeDirty();
      if (dirty.isEmpty) {
        _telemetry.recordPushOk(acceptedCount: 0);
        return const Right(
          PushResult(acceptedIds: [], rejectedIds: [], dirtyTotal: 0),
        );
      }

      final body = dirty.map((r) {
        final blob = _codec.encode(r.payload);
        return {
          'id': r.id,
          'kind': r.kind,
          'device_id': r.deviceId,
          'occurred_at': r.occurredAt?.toIso8601String(),
          'client_version': r.clientVersion,
          'ciphertext_b64': base64Encode(blob.ciphertext),
          'nonce_b64': base64Encode(blob.nonce),
        };
      }).toList();

      final res = await HanaSupabase.client.functions.invoke(
        'sync-push',
        body: {'records': body},
      );
      final responseBody = res.data as Map<String, dynamic>;

      // SPEC §10.2: `accepted` is a list of IDs. Fallback to the legacy
      // int shape during migration windows (older edge function tags).
      List<String> acceptedIds;
      final rawAccepted = responseBody['accepted'];
      if (rawAccepted is List) {
        acceptedIds = rawAccepted.map((e) => e as String).toList();
      } else if (rawAccepted is int) {
        // Conservative legacy fallback: when only a count is given we
        // CANNOT prove which subset was accepted, so we treat the whole
        // dirty list as still dirty (data safety > convenience).
        // Surface as zero acks; counter logs it for ops to spot.
        _telemetry.recordPushFail(reason: 'legacy_count_response_no_ids');
        acceptedIds = const [];
      } else {
        acceptedIds = const [];
      }

      final rejectedRaw = responseBody['rejected'];
      final rejectedIds = rejectedRaw is List
          ? rejectedRaw.map((e) => e as String).toList()
          : const <String>[];

      if (acceptedIds.isNotEmpty) {
        await _queue.markClean(acceptedIds);
      }

      _telemetry.recordPushOk(acceptedCount: acceptedIds.length);
      if (rejectedIds.isNotEmpty) {
        _telemetry.recordPushFail(
          reason: 'server_rejected',
          rejectedCount: rejectedIds.length,
        );
      }

      return Right(
        PushResult(
          acceptedIds: acceptedIds,
          rejectedIds: rejectedIds,
          dirtyTotal: dirty.length,
        ),
      );
    } catch (e) {
      _telemetry.recordPushFail(reason: 'transport_error');
      return Left(SyncNetwork('$e'));
    }
  }

  /// Pull updates since [since] and apply locally.
  ///
  /// Per ARE audit fix: a single decrypt failure DOES NOT abort the
  /// batch. Bad records are counted (`decryptFailedIds`) and the cursor
  /// advances; the user keeps the up-to-date subset they can read.
  Future<Either<SyncFailure, PullResult>> pullSince(DateTime since) async {
    if (!HanaSupabase.isConfigured) {
      _telemetry.recordPullFail(reason: 'cloud_disabled');
      return const Left(SyncDisabled());
    }
    try {
      final res = await HanaSupabase.client.functions.invoke(
        'sync-pull',
        body: {'since': since.toIso8601String(), 'limit': 500},
      );
      final body = res.data as Map<String, dynamic>;
      final records = body['records'] as List<dynamic>;
      final nextSince = DateTime.parse(body['next_since'] as String);

      var applied = 0;
      final decryptFailed = <String>[];

      for (final r in records) {
        final m = r as Map<String, dynamic>;
        final id = m['id'] as String;
        try {
          final payload = _codec.decode(
            EncryptedBlob(
              ciphertext: base64Decode(m['ciphertext_b64'] as String),
              nonce: base64Decode(m['nonce_b64'] as String),
            ),
          );
          await _queue.applyRemote(
            SyncedRecord(
              id: id,
              kind: m['kind'] as String,
              deviceId: m['device_id'] as String?,
              occurredAt: m['occurred_at'] == null
                  ? null
                  : DateTime.parse(m['occurred_at'] as String),
              clientVersion: m['client_version'] as String?,
              payload: payload,
            ),
          );
          applied++;
        } catch (e) {
          // ISOLATE: do not abort the batch. Log + continue.
          // SPEC §10.6: bad rows stay in inbox with decrypted=0 for
          // R53 manual recovery flow.
          decryptFailed.add(id);
          _telemetry.recordDecryptFail();
        }
      }

      _telemetry.recordPullOk(appliedCount: applied);

      return Right(
        PullResult(
          appliedCount: applied,
          decryptFailedIds: decryptFailed,
          nextSince: nextSince,
        ),
      );
    } catch (e) {
      _telemetry.recordPullFail(reason: 'transport_error');
      return Left(SyncNetwork('$e'));
    }
  }

  /// Convenience: push, then pull-since-last.
  Future<Either<SyncFailure, void>> runOnce(DateTime since) async {
    final pushRes = await pushPending();
    if (pushRes.isLeft()) {
      return pushRes.fold(Left.new, (_) => const Right(null));
    }
    final pullRes = await pullSince(since);
    return pullRes.fold(Left.new, (_) => const Right(null));
  }
}
