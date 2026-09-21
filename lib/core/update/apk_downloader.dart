/// Platform-aware APK downloader.
///
/// On native platforms, downloads to the file system.
/// On web, this is a no-op (updates not supported).
library;

export 'apk_downloader_native.dart'
    if (dart.library.js_interop) 'apk_downloader_web.dart';
