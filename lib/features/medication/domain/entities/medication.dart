import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication.freezed.dart';

/// Domain entity representing a medication plan item.
@freezed
abstract class Medication with _$Medication {
  /// Creates a medication entity.
  const factory Medication({required String id, required DateTime createdAt}) =
      _Medication;
}
