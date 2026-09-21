// 365-day flower almanac for the Daily 花笺 signature card.
// Loads assets/data/flowers.json once at startup and exposes a
// stable, locale-aware lookup for any day index 1..365.
//
// If a day exceeds the seeded range, falls back to the JSON-defined
// fallback entry (currently DAY 31+).
//
// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class Flower {
  const Flower({
    required this.day,
    required this.nameZh,
    required this.nameEn,
    required this.nameJa,
    required this.latin,
    required this.verseZh,
    required this.verseEn,
    required this.verseJa,
  });

  factory Flower.fromJson(Map<String, dynamic> j, {required int day}) {
    return Flower(
      day: day,
      nameZh: j['name_zh'] as String,
      nameEn: j['name_en'] as String,
      nameJa: j['name_ja'] as String,
      latin: j['latin'] as String,
      verseZh: j['verse_zh'] as String,
      verseEn: j['verse_en'] as String,
      verseJa: j['verse_ja'] as String,
    );
  }

  final int day;
  final String nameZh;
  final String nameEn;
  final String nameJa;
  final String latin;
  final String verseZh;
  final String verseEn;
  final String verseJa;

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

  String localizedVerse(String langCode) {
    switch (langCode) {
      case 'zh':
        return verseZh;
      case 'ja':
        return verseJa;
      default:
        return verseEn;
    }
  }
}

class FlowerAlmanac {
  FlowerAlmanac._(this._byDay, this._fallback, this.totalDays);

  final Map<int, Flower> _byDay;
  final Flower _fallback;

  /// Total designed days (365). Days exceeding seeded entries use fallback.
  final int totalDays;

  static FlowerAlmanac? _instance;

  /// Loads and caches the almanac. Subsequent calls return the cached
  /// instance. Safe to call from anywhere; idempotent.
  static Future<FlowerAlmanac> load() async {
    if (_instance != null) return _instance!;
    final raw = await rootBundle.loadString('assets/data/flowers.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final total = (decoded['totalDays'] as int?) ?? 365;
    final fallbackJson = decoded['fallback'] as Map<String, dynamic>;
    final daysList = decoded['days'] as List<dynamic>;

    final byDay = <int, Flower>{};
    for (final entry in daysList) {
      final m = entry as Map<String, dynamic>;
      final day = m['day'] as int;
      byDay[day] = Flower.fromJson(m, day: day);
    }

    final fallback = Flower.fromJson(fallbackJson, day: 0);
    _instance = FlowerAlmanac._(byDay, fallback, total);
    return _instance!;
  }

  /// Look up the flower for `day` (1-based). Returns the fallback when
  /// `day` is outside the seeded range.
  Flower forDay(int day) => _byDay[day] ?? _fallback.copyWithDay(day);

  /// Number of days with concrete (non-fallback) entries.
  int get seededDayCount => _byDay.length;

  /// True when the user has reached or surpassed the day with a real entry.
  bool isSeeded(int day) => _byDay.containsKey(day);
}

extension on Flower {
  Flower copyWithDay(int day) => Flower(
        day: day,
        nameZh: nameZh,
        nameEn: nameEn,
        nameJa: nameJa,
        latin: latin,
        verseZh: verseZh,
        verseEn: verseEn,
        verseJa: verseJa,
      );
}
