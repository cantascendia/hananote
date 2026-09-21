import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/privacy/native_interaction.dart';
import 'package:hananote/features/photo/presentation/services/photo_picker_service.dart';

void main() {
  test('legacy gallery requests return without invoking a platform plugin',
      () async {
    // No Flutter binding or plugin channel is installed: any plugin call fails.
    expect(await ImagePickerService().pickImage(PhotoPickerSource.gallery),
        isNull);
    expect(NativeInteraction.isActive, isFalse);
  });
}
