import 'package:bloc_test/bloc_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/features/settings/domain/entities/app_settings.dart';
import 'package:hananote/features/settings/domain/entities/user_profile.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:hananote/features/settings/presentation/pages/profile_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this.result);

  final FilePickerResult result;
  FileType? requestedType;
  bool? requestedWithData;
  bool? requestedWithReadStream;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    void Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    requestedType = type;
    requestedWithData = withData;
    requestedWithReadStream = withReadStream;
    return result;
  }
}

void main() {
  late _MockSettingsBloc settingsBloc;

  setUpAll(() {
    registerFallbackValue(const SettingsEvent.loadDashboard());
  });

  setUp(() {
    settingsBloc = _MockSettingsBloc();
    when(() => settingsBloc.state)
        .thenReturn(const SettingsState.error('load failed'));
    when(() => settingsBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  final loadedState = SettingsState.loaded(
    profile: UserProfile(
      displayName: '小花',
      hrtDayCount: 120,
      hrtStartDate: DateTime(2025),
    ),
    settings: const AppSettings(
      appLockEnabled: true,
      privacyModeEnabled: false,
      blurOverlayEnabled: false,
      lastBackupDate: null,
    ),
    activeDrugCount: 1,
    inventoryDaysRemaining: 30,
  );

  MaterialApp buildLocalizedApp(Widget child) {
    return MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  testWidgets('shows retry UI when loading the profile dashboard fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildLocalizedApp(
        BlocProvider<SettingsBloc>.value(
          value: settingsBloc,
          child: const ProfilePage(),
        ),
      ),
    );

    expect(find.text('load failed'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(() => settingsBloc.add(const LoadSettingsDashboard())).called(1);
  });

  testWidgets('adds export data event when backup clicked', (tester) async {
    when(() => settingsBloc.state).thenReturn(loadedState);

    await tester.pumpWidget(
      buildLocalizedApp(
        BlocProvider<SettingsBloc>.value(
          value: settingsBloc,
          child: const ProfilePage(),
        ),
      ),
    );

    final scrollable = find.byType(Scrollable);
    await tester.drag(scrollable, const Offset(0, -1000));
    await tester.pump(const Duration(milliseconds: 500));

    // Tap the center of the InkWell that contains the text
    final inkWell = find
        .ancestor(
          // spec-change: the label now explicitly describes a records backup.
          of: find.text(AppLocalizations.of(
            tester.element(find.byType(ProfilePage)),
          )!
              .exportBackup),
          matching: find.byType(InkWell),
        )
        .first;
    await tester.tap(inkWell, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('创建备份密码'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'safe-password');
    await tester.enterText(find.byType(TextField).at(1), 'safe-password');
    await tester.tap(find.text('创建加密备份'));
    await tester.pump();

    verify(
      () => settingsBloc.add(
        const SettingsEvent.exportData(password: 'safe-password'),
      ),
    ).called(1);
  });

  testWidgets(
      'bug-fix: picker streams files and rejects unknown extension before import',
      (tester) async {
    when(() => settingsBloc.state).thenReturn(loadedState);
    FilePickerIO.registerWith();
    final originalPicker = FilePicker.platform;
    final picker = _FakeFilePicker(
      FilePickerResult([
        PlatformFile(
          name: 'unexpected.txt',
          size: 2,
          readStream: Stream.value([1, 2]),
        ),
      ]),
    );
    FilePicker.platform = picker;
    addTearDown(() => FilePicker.platform = originalPicker);

    await tester.pumpWidget(
      buildLocalizedApp(
        BlocProvider<SettingsBloc>.value(
          value: settingsBloc,
          child: const ProfilePage(),
        ),
      ),
    );
    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pump(const Duration(milliseconds: 500));

    final l10n = AppLocalizations.of(tester.element(find.byType(ProfilePage)))!;
    final inkWell = find
        .ancestor(
          of: find.text(l10n.importBackup),
          matching: find.byType(InkWell),
        )
        .first;
    await tester.tap(inkWell, warnIfMissed: false);
    await tester.pump();

    expect(picker.requestedType, FileType.any);
    // bug-fix: a bounded stream avoids loading an untrusted file in the picker.
    expect(picker.requestedWithData, isFalse);
    expect(picker.requestedWithReadStream, isTrue);
    expect(find.text(l10n.importFailed), findsOneWidget);
    expect(find.text(l10n.backupPasswordUnlockTitle), findsNothing);
    expect(find.text(l10n.importConfirmTitle), findsNothing);
    verifyNever(() => settingsBloc.add(any(that: isA<ImportBackupEvent>())));
  });
}
