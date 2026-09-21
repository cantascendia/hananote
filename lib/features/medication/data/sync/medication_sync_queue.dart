// HanaNote v2 — MedicationSyncQueue implementation.
//
// Per SPEC-cloud-sync.md Appendix E.
// ⚠️ FORBIDDEN PATH (CONSTITUTION §5): lib/features/medication/data/sync/ +
// lib/core/sync/ are subject to spec-driven discipline. Appendix E describes
// this exact module; PR carrying this file MUST be labeled
// `requires-double-review`.
//
// Reads/writes the dirty / synced_at / is_deleted / updated_at metadata
// columns added to drugs / medication_schedules / medication_logs in
// SecureDatabase v4 migration. The model layer (DrugModel etc.) is NOT
// updated to know about these columns — they live in raw SQL only,
// hidden from the domain entities. This keeps DEC-042/043 zero-domain-
// dependency clean: sync is a data-layer concern.
//
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:hananote/core/database/secure_database.dart';
import 'package:hananote/core/sync/conflict_resolver.dart';
import 'package:hananote/core/sync/sync_queue.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite_common/sqflite.dart' show ConflictAlgorithm;

/// Set of medication tables this queue manages. Order matters for
/// applyRemote dispatch (resolved via `payload.table` string).
const _kManagedTables = {
  'drugs',
  'medication_schedules',
  'medication_logs',
};

@LazySingleton()
class MedicationSyncQueue implements SyncQueue {
  MedicationSyncQueue(this._db, [ConflictResolver? resolver])
      : _resolver = resolver ?? const ConflictResolver();

  final SecureDatabase _db;
  final ConflictResolver _resolver;

  /// SyncedRecord.kind constant for the whole medication module.
  static const String kind = 'medication';

  /// Collect every row with `dirty = 1` across the three medication
  /// tables. Each row becomes one SyncedRecord with a payload that
  /// carries the table name + the full row + op (upsert / delete).
  ///
  /// Order: drugs first (parent), then schedules, then logs. Helps
  /// the server side process FK-safe upserts when we later add
  /// per-record dependency batching.
  @override
  Future<List<SyncedRecord>> takeDirty() async {
    final db = _db.database;
    final records = <SyncedRecord>[];

    for (final table in _kManagedTables) {
      final rows = await db.query(table, where: 'dirty = 1');
      for (final row in rows) {
        final id = row['id']! as String;
        final updatedAt = row['updated_at'] as String?;
        final occurredAt = updatedAt == null || updatedAt.isEmpty
            ? null
            : DateTime.tryParse(updatedAt);
        final op = (row['is_deleted'] as int? ?? 0) == 1 ? 'delete' : 'upsert';
        records.add(
          SyncedRecord(
            id: id,
            kind: kind,
            occurredAt: occurredAt,
            payload: <String, dynamic>{
              'table': table,
              'op': op,
              'row': Map<String, dynamic>.from(row),
            },
          ),
        );
      }
    }

    return records;
  }

  /// Mark each id clean (dirty = 0, synced_at = now). Server-confirmed
  /// IDs ONLY — partial-ack contract from ARE-fix D-1 in sync_engine.
  ///
  /// We don't know which table owns each id without a lookup, so we
  /// fan the UPDATE across all three tables; SQLite's row-level
  /// matching means only the right table sees a hit.
  @override
  Future<void> markClean(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = _db.database;
    final nowIso = DateTime.now().toUtc().toIso8601String();
    // Placeholder list `?,?,?` for each id.
    final placeholders = List.filled(ids.length, '?').join(',');

    await db.transaction((txn) async {
      for (final table in _kManagedTables) {
        await txn.rawUpdate(
          'UPDATE $table SET dirty = 0, synced_at = ? '
          'WHERE id IN ($placeholders)',
          [nowIso, ...ids],
        );
      }
    });
  }

  /// Apply a remote-arrived record to local storage. Dispatches by
  /// `payload.table`; reuses `ConflictResolver` for last-write-wins.
  /// Records whose `kind != "medication"` are ignored (caller should
  /// route them via the SyncQueueRegistry to the right queue).
  @override
  Future<void> applyRemote(SyncedRecord record) async {
    if (record.kind != kind) return;
    final payload = record.payload;
    final table = payload['table'] as String?;
    if (table == null || !_kManagedTables.contains(table)) {
      if (kDebugMode) {
        // Never log row contents — only the routing failure.
        // ignore: avoid_print
        print(
          'MedicationSyncQueue.applyRemote ignoring unknown table=$table',
        );
      }
      return;
    }
    final op = payload['op'] as String? ?? 'upsert';
    final row = Map<String, dynamic>.from(
      payload['row'] as Map<dynamic, dynamic>,
    );

    final db = _db.database;
    await db.transaction((txn) async {
      // Locate the local row (may be absent on first sync into a fresh
      // install).
      final existing = await txn.query(
        table,
        where: 'id = ?',
        whereArgs: [row['id'] as String],
        limit: 1,
      );

      if (existing.isEmpty) {
        if (op == 'delete') {
          // Remote delete for a row we never had — write a tombstone
          // so subsequent syncs don't reintroduce it from a stale
          // peer.
          await txn.insert(
            table,
            {
              ...row,
              'dirty': 0,
              'is_deleted': 1,
              'synced_at': DateTime.now().toUtc().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          await txn.insert(
            table,
            {
              ...row,
              'dirty': 0,
              'synced_at': DateTime.now().toUtc().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        return;
      }

      // Conflict check: build SyncedRecord stubs for the resolver.
      final localRow = existing.first;
      final localUpdated = localRow['updated_at'] as String?;
      final localOccurred = localUpdated == null || localUpdated.isEmpty
          ? null
          : DateTime.tryParse(localUpdated);
      final localStub = SyncedRecord(
        id: localRow['id']! as String,
        kind: kind,
        occurredAt: localOccurred,
        payload: const <String, dynamic>{},
      );

      final remoteWins = _resolver.remoteWins(localStub, record);
      if (!remoteWins) {
        // Local is newer or equal — keep local (it'll push on the
        // next cycle if still dirty).
        return;
      }

      if (op == 'delete') {
        await txn.rawUpdate(
          'UPDATE $table SET is_deleted = 1, dirty = 0, synced_at = ? '
          'WHERE id = ?',
          [
            DateTime.now().toUtc().toIso8601String(),
            row['id'] as String,
          ],
        );
      } else {
        await txn.update(
          table,
          {
            ...row,
            'dirty': 0,
            'synced_at': DateTime.now().toUtc().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [row['id'] as String],
        );
      }
    });
  }
}
