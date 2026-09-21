// HanaNote · Region resolver.
// Picks the correct Supabase endpoint per user location:
//   - Global (en/ja/other) → direct https://<project>.supabase.co
//   - CN (zh-Hans, zh-CN)   → https://cn-api.hrtyaku.com (Cloudflare proxy)
//
// Resolution order:
//   1. User manual override (saved in flutter_secure_storage)
//   2. Locale heuristic (Localizations.localeOf or Platform.localeName)
//   3. DNS reachability probe (optional, async, for first-launch tuning)
//
// The resolver is queried ONCE at app boot before HanaSupabase.init().
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hananote/core/region/region.dart';

class RegionResolver {
  RegionResolver({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _kOverrideKey = 'region_override';

  /// Best-effort region. Cheap; sync-friendly fallback.
  ///
  /// Use [resolve] for the full async (including override read).
  Region quickGuessFromLocale() {
    final localeName = _platformLocaleName();
    return _localeToRegion(localeName);
  }

  /// Full resolution: prefer user override, else locale heuristic.
  Future<Region> resolve() async {
    final override = await _storage.read(key: _kOverrideKey);
    if (override != null) {
      switch (override) {
        case 'cn':
          return Region.cn;
        case 'global':
          return Region.global;
      }
    }
    return quickGuessFromLocale();
  }

  /// Persist a manual region override (Profile / Onboarding setting).
  Future<void> setOverride(Region region) async {
    await _storage.write(key: _kOverrideKey, value: region.code);
  }

  /// Clear override → resolver falls back to locale heuristic.
  Future<void> clearOverride() async {
    await _storage.delete(key: _kOverrideKey);
  }

  String _platformLocaleName() {
    if (kIsWeb) {
      // Web: use the navigator language via WidgetsBinding.
      final binding = WidgetsBinding.instance;
      final locales = binding.platformDispatcher.locales;
      if (locales.isNotEmpty) return locales.first.toLanguageTag();
      return 'en-US';
    }
    final binding = WidgetsBinding.instance;
    return binding.platformDispatcher.locale.toLanguageTag();
  }

  Region _localeToRegion(String localeName) {
    final lower = localeName.toLowerCase();
    // zh-cn, zh-hans-cn, zh-cn-... → CN region
    if (lower.startsWith('zh-cn') ||
        lower.startsWith('zh-hans-cn') ||
        lower == 'zh' ||
        lower.startsWith('zh-hans')) {
      return Region.cn;
    }
    return Region.global;
  }
}
