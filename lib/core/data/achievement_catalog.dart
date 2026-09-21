// Achievement catalog — 8 unlockable badges (HoYo-inspired圣遗物等级感).
// Loads assets/data/achievements.json once and exposes lookup +
// unlock-rule evaluation against a UserStats payload.
//
// Backend-side authoritative unlock writes go to the
// `achievement_unlocks` table via Edge Functions; this file is purely
// the client-side catalog + heuristic evaluator for offline preview.
//
// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Aggregate stats used to evaluate unlock rules.
class UserStats {
  const UserStats({
    required this.daysSinceHrtStart,
    required this.consecutiveRecordDays,
    required this.bloodTestCount,
    required this.flowerCollectionCount,
    required this.sharePosterCount,
    required this.lastEstradiolPgPerMl,
  });

  factory UserStats.empty() => const UserStats(
        daysSinceHrtStart: 0,
        consecutiveRecordDays: 0,
        bloodTestCount: 0,
        flowerCollectionCount: 0,
        sharePosterCount: 0,
        lastEstradiolPgPerMl: null,
      );

  final int daysSinceHrtStart;
  final int consecutiveRecordDays;
  final int bloodTestCount;
  final int flowerCollectionCount;
  final int sharePosterCount;
  final double? lastEstradiolPgPerMl;
}

class AchievementRule {
  const AchievementRule({required this.kind, required this.params});

  final String kind;
  final Map<String, dynamic> params;

  /// Returns true if this rule is satisfied by [stats].
  bool isUnlocked(UserStats stats) {
    switch (kind) {
      case 'days_since_hrt_start':
        final min = (params['min'] as num).toInt();
        return stats.daysSinceHrtStart >= min;
      case 'consecutive_record_days':
        final min = (params['min'] as num).toInt();
        return stats.consecutiveRecordDays >= min;
      case 'blood_test_count':
        final min = (params['min'] as num).toInt();
        return stats.bloodTestCount >= min;
      case 'flower_collection_count':
        final min = (params['min'] as num).toInt();
        return stats.flowerCollectionCount >= min;
      case 'share_poster_count':
        final min = (params['min'] as num).toInt();
        return stats.sharePosterCount >= min;
      case 'blood_test_in_range':
        final v = stats.lastEstradiolPgPerMl;
        if (v == null) return false;
        final min = (params['min'] as num).toDouble();
        final max = (params['max'] as num).toDouble();
        return v >= min && v <= max;
      default:
        return false;
    }
  }
}

class Achievement {
  const Achievement({
    required this.key,
    required this.labelZh,
    required this.labelEn,
    required this.labelJa,
    required this.nameZh,
    required this.nameEn,
    required this.nameJa,
    required this.icon,
    required this.rule,
  });

  factory Achievement.fromJson(Map<String, dynamic> j) {
    final r = j['rule'] as Map<String, dynamic>;
    return Achievement(
      key: j['key'] as String,
      labelZh: j['label_zh'] as String,
      labelEn: j['label_en'] as String,
      labelJa: j['label_ja'] as String,
      nameZh: j['name_zh'] as String,
      nameEn: j['name_en'] as String,
      nameJa: j['name_ja'] as String,
      icon: j['icon'] as String,
      rule: AchievementRule(
        kind: r['kind'] as String,
        params: Map<String, dynamic>.from(r),
      ),
    );
  }

  final String key;
  final String labelZh;
  final String labelEn;
  final String labelJa;
  final String nameZh;
  final String nameEn;
  final String nameJa;
  final String icon;
  final AchievementRule rule;

  String localizedLabel(String langCode) {
    switch (langCode) {
      case 'zh':
        return labelZh;
      case 'ja':
        return labelJa;
      default:
        return labelEn;
    }
  }

  String localizedName(String langCode) {
    switch (langCode) {
      case 'zh':
        return nameZh;
      case 'ja':
        return nameJa;
      default:
        return nameEn;
    }
  }
}

class AchievementCatalog {
  AchievementCatalog._(this.items);

  final List<Achievement> items;

  static AchievementCatalog? _instance;

  /// Loads and caches the catalog (idempotent).
  static Future<AchievementCatalog> load() async {
    if (_instance != null) return _instance!;
    final raw = await rootBundle.loadString('assets/data/achievements.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final list = (decoded['achievements'] as List<dynamic>)
        .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    _instance = AchievementCatalog._(list);
    return _instance!;
  }

  /// Returns the catalog with each entry evaluated against [stats].
  List<MapEntry<Achievement, bool>> evaluate(UserStats stats) {
    return items
        .map((a) => MapEntry<Achievement, bool>(a, a.rule.isUnlocked(stats)))
        .toList(growable: false);
  }

  int unlockedCount(UserStats stats) =>
      items.where((a) => a.rule.isUnlocked(stats)).length;

  int get totalCount => items.length;
}
