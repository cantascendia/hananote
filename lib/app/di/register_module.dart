// Release prep note: App-only DI wiring stays undocumented to avoid noisy
// dartdoc on internal registration helpers.
// ignore_for_file: public_member_api_docs

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hananote/core/sync/conflict_resolver.dart';
import 'package:hananote/core/sync/sync_queue.dart';
import 'package:hananote/core/sync/sync_queue_registry.dart';
import 'package:hananote/features/medication/data/sync/medication_sync_queue.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  LocalAuthentication get localAuthentication => LocalAuthentication();

  @lazySingleton
  ConflictResolver get conflictResolver => const ConflictResolver();

  /// SyncQueue is wired as a composite SyncQueueRegistry, with the
  /// medication queue registered under its `kind = "medication"`.
  /// Per SPEC-cloud-sync.md Appendix E §E.5.
  ///
  /// Future feature modules (journal / measurement / blood_test)
  /// add themselves here once their respective queue impls land.
  @lazySingleton
  SyncQueue syncQueue(MedicationSyncQueue medicationQueue) {
    final registry = SyncQueueRegistry()
      ..register(MedicationSyncQueue.kind, medicationQueue);
    return registry;
  }
}
