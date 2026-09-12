import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/blood_test/domain/entities/blood_test_report.dart';
import 'package:hananote/features/blood_test/domain/entities/enums.dart';
import 'package:hananote/features/blood_test/domain/entities/hormone_reading.dart';
import 'package:hananote/features/blood_test/domain/repositories/blood_test_repository.dart';
import 'package:hananote/features/journal/domain/entities/enums.dart';
import 'package:hananote/features/journal/domain/entities/journal_entry.dart';
import 'package:hananote/features/journal/domain/repositories/journal_repository.dart';
import 'package:hananote/features/measurement/domain/entities/measurement_entry.dart';
import 'package:hananote/features/measurement/domain/repositories/measurement_repository.dart';
import 'package:hananote/features/medication/domain/entities/drug.dart';
import 'package:hananote/features/medication/domain/entities/enums.dart';
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart';
import 'package:hananote/features/settings/domain/entities/user_profile.dart';
import 'package:hananote/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Imports backup data from a JSON string matching the export format.
@injectable
class ImportData {
  /// Creates an [ImportData] use case.
  const ImportData(
    this._medicationRepo,
    this._bloodTestRepo,
    this._journalRepo,
    this._measurementRepo,
    this._settingsRepo,
  );

  final MedicationRepository _medicationRepo;
  final BloodTestRepository _bloodTestRepo;
  final JournalRepository _journalRepo;
  final MeasurementRepository _measurementRepo;
  final SettingsRepository _settingsRepo;

  /// Parses [jsonString] and imports all data. Returns the number of
  /// items successfully imported.
  Future<Either<Failure, int>> call(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      var count = 0;

      // Import drugs
      final drugs = data['drugs'] as List<dynamic>? ?? [];
      for (final item in drugs) {
        final drugMap = item as Map<String, dynamic>;
        final drug = Drug(
          id: drugMap['id'] as String,
          name: drugMap['name'] as String,
          genericName: (drugMap['genericName'] as String?) ?? '',
          category: _parseEnum(
            DrugCategory.values,
            drugMap['category'] as String?,
            DrugCategory.estrogen,
          ),
          administrationRoute: _parseEnum(
            AdministrationRoute.values,
            drugMap['administrationRoute'] as String?,
            AdministrationRoute.oral,
          ),
          defaultDosageUnit: _parseEnum(
            DosageUnit.values,
            drugMap['defaultDosageUnit'] as String?,
            DosageUnit.mg,
          ),
          isActive: (drugMap['isActive'] as bool?) ?? true,
          createdAt: DateTime.parse(drugMap['createdAt'] as String),
          notes: drugMap['notes'] as String?,
        );
        await _medicationRepo.addDrug(drug);
        count++;
      }

      // Import blood tests
      final bloodTests = data['bloodTests'] as List<dynamic>? ?? [];
      for (final item in bloodTests) {
        final btMap = item as Map<String, dynamic>;
        final readings = (btMap['readings'] as List<dynamic>? ?? [])
            .map((r) {
              final rMap = r as Map<String, dynamic>;
              return HormoneReading(
                id: '${btMap['id']}_${rMap['type']}',
                reportId: btMap['id'] as String,
                type: _parseEnum(
                  HormoneType.values,
                  rMap['type'] as String?,
                  HormoneType.estradiol,
                ),
                value: (rMap['value'] as num).toDouble(),
                unit: (rMap['unit'] as String?) ?? '',
              );
            })
            .toList();

        final report = BloodTestReport(
          id: btMap['id'] as String,
          testDate: DateTime.parse(btMap['testDate'] as String),
          readings: readings,
          createdAt: DateTime.parse(btMap['createdAt'] as String),
          labName: btMap['labName'] as String?,
          notes: btMap['notes'] as String?,
        );
        await _bloodTestRepo.addReport(report);
        count++;
      }

      // Import journals
      final journals = data['journals'] as List<dynamic>? ?? [];
      for (final item in journals) {
        final jMap = item as Map<String, dynamic>;
        final entry = JournalEntry(
          id: jMap['id'] as String,
          date: DateTime.parse(jMap['date'] as String),
          content: jMap['content'] as String,
          mood: _parseEnum(
            MoodLevel.values,
            jMap['mood'] as String?,
            MoodLevel.neutral,
          ),
          createdAt: DateTime.parse(jMap['createdAt'] as String),
          tags: (jMap['tags'] as List<dynamic>?)?.cast<String>(),
          updatedAt: jMap['updatedAt'] != null
              ? DateTime.parse(jMap['updatedAt'] as String)
              : null,
        );
        await _journalRepo.addEntry(entry);
        count++;
      }

      // Import measurements
      final measurements = data['measurements'] as List<dynamic>? ?? [];
      for (final item in measurements) {
        final mMap = item as Map<String, dynamic>;
        final entry = MeasurementEntry(
          id: mMap['id'] as String,
          date: DateTime.parse(mMap['date'] as String),
          createdAt: DateTime.parse(mMap['createdAt'] as String),
          bust: (mMap['bust'] as num?)?.toDouble(),
          underbust: (mMap['underbust'] as num?)?.toDouble(),
          waist: (mMap['waist'] as num?)?.toDouble(),
          hip: (mMap['hip'] as num?)?.toDouble(),
          thigh: (mMap['thigh'] as num?)?.toDouble(),
          bicep: (mMap['bicep'] as num?)?.toDouble(),
          shoulder: (mMap['shoulder'] as num?)?.toDouble(),
          neck: (mMap['neck'] as num?)?.toDouble(),
          weight: (mMap['weight'] as num?)?.toDouble(),
          notes: mMap['notes'] as String?,
          updatedAt: mMap['updatedAt'] != null
              ? DateTime.parse(mMap['updatedAt'] as String)
              : null,
        );
        await _measurementRepo.save(entry);
        count++;
      }

      // Import profile
      if (data['profile'] != null) {
        final profileMap = data['profile'] as Map<String, dynamic>;
        final profile = UserProfile.fromJson(profileMap);
        await _settingsRepo.saveUserProfile(profile);
        count++;
      }

      return right(count);
    } catch (e) {
      return left(UnexpectedFailure(message: e.toString()));
    }
  }

  T _parseEnum<T extends Enum>(List<T> values, String? name, T fallback) {
    if (name == null) return fallback;
    return values.firstWhere(
      (v) => v.name == name,
      orElse: () => fallback,
    );
  }
}
