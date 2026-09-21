/// Platform-aware file operations.
///
/// Uses conditional imports to select the correct implementation:
/// - Mobile: dart:io File operations
/// - Web: in-memory storage (no file system access)
library;

export 'file_helper_native.dart'
    if (dart.library.js_interop) 'file_helper_web.dart';
