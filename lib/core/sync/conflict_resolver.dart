// HanaNote v2 — Conflict resolver (last-write-wins).
// Default policy: the record with the later `updated_at` wins.
// In v3 we will swap this for a vector-clock-aware resolver.
// ignore_for_file: public_member_api_docs

import 'package:hananote/core/sync/sync_queue.dart';

class ConflictResolver {
  const ConflictResolver();

  /// Picks the winner between local and remote for the same id.
  /// Returns true if `remote` should overwrite `local`.
  bool remoteWins(SyncedRecord local, SyncedRecord remote) {
    final lhs = local.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final rhs = remote.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return rhs.isAfter(lhs);
  }
}
