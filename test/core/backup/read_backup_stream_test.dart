import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/backup/read_backup_stream.dart';

void main() {
  test('test: oversized declared file is rejected before subscribing',
      () async {
    var subscribed = false;
    final controller = StreamController<List<int>>(
      onListen: () => subscribed = true,
    );
    await expectLater(
      readBackupStream(stream: controller.stream, declaredSize: 5, maxBytes: 4),
      throwsFormatException,
    );
    expect(subscribed, isFalse);
  });

  test('test: actual stream size is bounded despite a small declaration',
      () async {
    var cancelled = false;
    Stream<List<int>> oversized() async* {
      try {
        yield [1, 2];
        yield [3, 4];
        yield [5];
      } finally {
        cancelled = true;
      }
    }

    await expectLater(
      readBackupStream(stream: oversized(), declaredSize: 2, maxBytes: 4),
      throwsFormatException,
    );
    expect(cancelled, isTrue);
  });

  test('test: valid chunks are joined without changing bytes', () async {
    final result = await readBackupStream(
      stream: Stream<List<int>>.fromIterable([
        [0, 1],
        [2],
        [255, 3],
      ]),
      declaredSize: 5,
      maxBytes: 5,
    );

    expect(result, Uint8List.fromList([0, 1, 2, 255, 3]));
  });
}
