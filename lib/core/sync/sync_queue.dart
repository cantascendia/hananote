// HanaNote v2 — SyncQueue abstraction.
// The sync engine doesn't talk to specific feature DAOs directly —
// it goes through this queue interface. Each feature module that
// wants cloud sync provides a SyncQueue implementation that:
//   - lists local rows tagged dirty
//   - applies decrypted remote rows to local store
//   - marks local rows clean after server ack
//
// In R52 we ship a no-op default. R53 wires real implementations
// for medication / journal / measurement / blood_test.
// ignore_for_file: public_member_api_docs

class SyncedRecord {
  const SyncedRecord({
    required this.id,
    required this.kind,
    required this.payload,
    this.deviceId,
    this.occurredAt,
    this.clientVersion,
  });

  final String id;
  final String kind;
  final String? deviceId;
  final DateTime? occurredAt;
  final String? clientVersion;
  final Map<String, dynamic> payload;
}

abstract class SyncQueue {
  /// Returns all local records currently flagged dirty (modified
  /// since last successful sync).
  Future<List<SyncedRecord>> takeDirty();

  /// Mark these record IDs as clean (server acked).
  Future<void> markClean(List<String> ids);

  /// Persist a remote-arrived record locally. Implementations should
  /// resolve conflicts via last-write-wins on `occurredAt` /
  /// `clientVersion`.
  Future<void> applyRemote(SyncedRecord record);
}

/// No-op queue used when cloud sync is disabled or in tests.
class NoopSyncQueue implements SyncQueue {
  const NoopSyncQueue();

  @override
  Future<void> applyRemote(SyncedRecord record) async {}

  @override
  Future<void> markClean(List<String> ids) async {}

  @override
  Future<List<SyncedRecord>> takeDirty() async => const [];
}
