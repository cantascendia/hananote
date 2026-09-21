/// Tracks explicit user actions that temporarily open a trusted platform UI.
///
/// Camera, document picker, and share-sheet round trips preserve the initiating
/// session. The privacy overlay remains active throughout. Ordinary background
/// transitions still lock the app.
abstract final class NativeInteraction {
  static var _depth = 0;

  /// Whether a user-initiated native activity is awaiting a result.
  static bool get isActive => _depth > 0;

  /// Runs [action] while preserving its session, including nested platform UIs.
  static Future<T> run<T>(Future<T> Function() action) async {
    _depth++;
    try {
      return await action();
    } finally {
      _depth--;
    }
  }
}
