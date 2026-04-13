// Platform-aware web storage.
//
// Uses conditional imports to select the correct implementation:
// - Native: no-op stub
// - Web: window.localStorage
export 'web_storage_stub.dart'
    if (dart.library.js_interop) 'web_storage_web.dart';
