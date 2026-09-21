import 'dart:typed_data';

import 'package:hananote/core/platform/file_helper.dart';
import 'package:hananote/core/privacy/native_interaction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

/// Image source options exposed to presentation logic without plugin types.
enum PhotoPickerSource {
  /// Capture a new photo from the camera.
  camera,

  /// Legacy source; unavailable under the private-camera-only policy.
  gallery,
}

/// Abstraction over `image_picker` to keep bloc tests plugin-free.
// Release prep note: kept as a tiny interface so the picker stays mockable in
// bloc tests without leaking plugin types into test setup.
// ignore: one_member_abstracts
abstract interface class PhotoPickerService {
  /// Opens the selected source and returns image bytes, or `null` if cancelled.
  Future<Uint8List?> pickImage(PhotoPickerSource source);
}

/// `image_picker` backed implementation for selecting or capturing a photo.
@LazySingleton(as: PhotoPickerService)
class ImagePickerService implements PhotoPickerService {
  /// Creates an [ImagePickerService].
  ImagePickerService() : _picker = ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> pickImage(PhotoPickerSource source) async {
    if (source == PhotoPickerSource.gallery) return null;
    final pickedFile = await NativeInteraction.run(() => _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 2048,
          maxHeight: 2048,
          requestFullMetadata: false,
        ));

    if (pickedFile == null) return null;
    try {
      return await pickedFile.readAsBytes();
    } finally {
      await deleteTemporaryFile(pickedFile.path);
    }
  }
}
