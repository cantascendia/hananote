import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

/// Global service locator for HanaNote.
final GetIt getIt = GetIt.instance;

/// Registers app-level dependencies.
Future<void> configureDependencies() async {
  if (!getIt.isRegistered<GoRouter>()) {
    getIt.registerLazySingleton<GoRouter>(createRouter);
  }
}
