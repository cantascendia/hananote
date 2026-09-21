// HanaNote v2 — Supabase client singleton (region-aware).
// Initialized once in main() *after* RegionResolver picks the user's
// region. The URL/anon-key are passed via --dart-define:
//
//   --dart-define=SUPABASE_URL_GLOBAL=https://abcdef.supabase.co
//   --dart-define=SUPABASE_URL_CN=https://cn-api.hrtyaku.com
//   --dart-define=SUPABASE_ANON_KEY=<same anon key for both regions>
//
// (CN endpoint is a transparent Cloudflare-Worker proxy to the same
// Supabase project — see cloudflare-proxy/.)
//
// In dev (no defines), defaults to placeholders so the app still
// boots; auth/sync calls fail gracefully and the user stays in
// pure-local mode.
// ignore_for_file: public_member_api_docs

import 'package:hananote/core/region/region.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HanaSupabase {
  HanaSupabase._();

  static const String _urlGlobal =
      String.fromEnvironment('SUPABASE_URL_GLOBAL', defaultValue: '');
  static const String _urlCn =
      String.fromEnvironment('SUPABASE_URL_CN', defaultValue: '');
  // Backward-compat: legacy single-region build.
  static const String _urlLegacy =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String _anonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static bool _initialized = false;
  static Region _activeRegion = Region.global;

  /// True iff at least one region URL + anon key were provided.
  static bool get isConfigured =>
      _anonKey.isNotEmpty &&
      (_urlGlobal.isNotEmpty || _urlCn.isNotEmpty || _urlLegacy.isNotEmpty);

  /// Returns the resolved endpoint URL for the active region.
  static String _urlFor(Region region) {
    switch (region) {
      case Region.cn:
        return _urlCn.isNotEmpty ? _urlCn : _urlLegacy;
      case Region.global:
        return _urlGlobal.isNotEmpty ? _urlGlobal : _urlLegacy;
    }
  }

  /// The currently active region (set during init).
  static Region get activeRegion => _activeRegion;

  /// Idempotent init for [region]. Call once in main(), AFTER
  /// RegionResolver picks. Subsequent calls with a different region
  /// will reinitialize (rare — typically only on user override).
  static Future<void> ensureInitialized({Region region = Region.global}) async {
    if (_initialized && _activeRegion == region) return;

    final url = _urlFor(region);
    if (url.isEmpty || _anonKey.isEmpty) {
      _initialized = true;
      _activeRegion = region;
      return;
    }

    if (_initialized) {
      // Region changed mid-session: dispose then recreate.
      await Supabase.instance.dispose();
    }

    await Supabase.initialize(
      url: url,
      anonKey: _anonKey,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
      ),
    );
    _initialized = true;
    _activeRegion = region;
  }

  /// Returns the Supabase client. Throws StateError if not configured.
  static SupabaseClient get client {
    if (!isConfigured) {
      throw StateError(
        'Supabase not configured. Build with --dart-define=SUPABASE_URL_GLOBAL=… '
        '(and optionally SUPABASE_URL_CN=https://cn-api.hrtyaku.com) + '
        'SUPABASE_ANON_KEY=… , or stay in local-only mode.',
      );
    }
    return Supabase.instance.client;
  }
}
