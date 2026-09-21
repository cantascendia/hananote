// HanaNote v2 — SyncQueueRegistry (composite pattern).
//
// Per SPEC-cloud-sync.md Appendix E §E.5. SyncEngine's constructor
// signature accepts a single SyncQueue; this composite implements that
// same interface and fans calls across registered per-feature queues.
//
// Benefits:
// - SyncEngine stays decoupled from feature module list (open/closed).
// - Each feature owns its own SyncQueue impl in its data layer.
// - Adding journal / measurement / blood_test queues = one
//   register(...) call in DI, no changes to SyncEngine.
//
// ⚠️ FORBIDDEN PATH (CONSTITUTION §5).
// ignore_for_file: public_member_api_docs

import 'package:hananote/core/sync/sync_queue.dart';

/// Composite SyncQueue that delegates to one or more registered
/// per-kind queues.
class SyncQueueRegistry implements SyncQueue {
  SyncQueueRegistry();

  final Map<String, SyncQueue> _byKind = <String, SyncQueue>{};

  /// Register a queue under [kind]. Subsequent applyRemote / takeDirty
  /// calls route by `SyncedRecord.kind`. Re-registering the same kind
  /// replaces the previous queue (useful for tests).
  void register(String kind, SyncQueue queue) {
    _byKind[kind] = queue;
  }

  /// Number of registered queues (mostly for assertions in tests).
  int get registeredCount => _byKind.length;

  /// True if anything is registered.
  bool get hasAny => _byKind.isNotEmpty;

  /// Aggregate dirty rows from every registered queue in registration
  /// order. The SyncEngine sees a single flat list; provenance is
  /// preserved through `SyncedRecord.kind` so markClean fans back
  /// correctly.
  @override
  Future<List<SyncedRecord>> takeDirty() async {
    final all = <SyncedRecord>[];
    for (final queue in _byKind.values) {
      all.addAll(await queue.takeDirty());
    }
    return all;
  }

  /// Fan markClean to every registered queue. We don't know which
  /// kind each id belongs to without a lookup — but markClean is
  /// idempotent + no-op for ids that don't match the queue's tables,
  /// so this brute-force fan is safe (just slightly more SQL).
  ///
  /// Future optimization: callers can pass kind-partitioned maps and
  /// we route precisely. For the MVP prototype, the fan-out cost is
  /// negligible (single push round, ≤ a few hundred ids).
  @override
  Future<void> markClean(List<String> ids) async {
    if (ids.isEmpty) return;
    for (final queue in _byKind.values) {
      await queue.markClean(ids);
    }
  }

  /// Route to the queue whose kind matches `record.kind`. Records
  /// without a registered queue are dropped (logged in debug mode).
  @override
  Future<void> applyRemote(SyncedRecord record) async {
    final queue = _byKind[record.kind];
    if (queue == null) {
      // No registered handler for this kind — drop silently in
      // production. Server might be ahead of client (new kind added
      // server-side before client release ships); we don't want to
      // crash, and we don't want to write data we can't represent.
      return;
    }
    await queue.applyRemote(record);
  }
}
