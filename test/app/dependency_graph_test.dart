import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hananote/app/di/injection.config.dart';
import 'package:hananote/core/notifications/notification_service.dart';
import 'package:hananote/core/sync/sync_queue.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:hananote/features/settings/domain/usecases/export_data.dart';
import 'package:hananote/features/settings/domain/usecases/import_data.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('release dependency graph resolves security, backup and reminders',
      () async {
    final locator = GetIt.asNewInstance()..init();
    final auth = locator<AuthCubit>();
    final settings = locator<SettingsBloc>();
    expect(locator<ExportData>(), isA<ExportData>());
    expect(locator<ImportData>(), isA<ImportData>());
    expect(locator<NotificationService>(), isA<NotificationService>());
    expect(locator<SyncQueue>(), isA<SyncQueue>());
    await auth.close();
    await settings.close();
    await locator.reset();
  });
}
