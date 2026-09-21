import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/platform/file_helper_native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory sandbox;
  late Directory cache;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('hananote-file-test-');
    cache = await Directory('${sandbox.path}/cache').create();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => cache.path);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await sandbox.delete(recursive: true);
  });

  test('camera cleanup removes the capture within app cache', () async {
    final capture =
        await File('${cache.path}/capture.jpg').writeAsBytes([1, 2]);
    await deleteTemporaryFile(capture.path);
    expect(await capture.exists(), isFalse);
  });

  test('camera cleanup preserves files outside cache, including traversal',
      () async {
    final other = await File('${sandbox.path}/keep.jpg').writeAsBytes([1, 2]);
    await deleteTemporaryFile(other.path);
    await deleteTemporaryFile('${cache.path}/../keep.jpg');
    expect(await other.readAsBytes(), [1, 2]);
  });
}
