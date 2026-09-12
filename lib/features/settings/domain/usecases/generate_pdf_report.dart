import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/blood_test/domain/repositories/blood_test_repository.dart';
import 'package:hananote/features/journal/domain/repositories/journal_repository.dart';
import 'package:hananote/features/measurement/domain/entities/measurement_entry.dart';
import 'package:hananote/features/measurement/domain/repositories/measurement_repository.dart';
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart';
import 'package:hananote/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generates a PDF health report containing all user data.
@injectable
class GeneratePdfReport {
  /// Creates a [GeneratePdfReport] use case.
  const GeneratePdfReport(
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

  /// Generates the PDF and returns its bytes.
  ///
  /// [pdfTitle], [medSection], [bloodSection], [measureSection],
  /// [journalSection], and [noData] are the localized section titles.
  Future<Either<Failure, Uint8List>> call({
    required String pdfTitle,
    required String medSection,
    required String bloodSection,
    required String measureSection,
    required String journalSection,
    required String noData,
  }) async {
    try {
      // Load data
      final profileResult = await _settingsRepo.getUserProfile();
      final profile = profileResult.getOrElse(
        (_) => throw Exception('Profile load failed'),
      );

      final drugsResult = await _medicationRepo.getAllDrugs();
      final drugs = drugsResult.getOrElse((_) => []);

      final bloodTestsResult = await _bloodTestRepo.getAllReports();
      final bloodTests = bloodTestsResult.getOrElse((_) => []);

      final measurementsResult = await _measurementRepo.getAll();
      final measurements = measurementsResult.getOrElse((_) => []);

      final journalsResult = await _journalRepo.getAllEntries();
      final journals = journalsResult.getOrElse((_) => []);

      // Build document
      final pdf = pw.Document();
      final dateFormat = DateFormat.yMMMd();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildHeader(
            pdfTitle,
            profile.displayName,
            dateFormat.format(DateTime.now()),
          ),
          build: (context) => [
            // 1. Medication Summary
            _sectionTitle(medSection),
            if (drugs.isEmpty)
              _emptyText(noData)
            else
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                cellPadding: const pw.EdgeInsets.all(6),
                data: [
                  ['Name', 'Category', 'Route', 'Status'],
                  ...drugs.map(
                    (d) => [
                      d.name,
                      d.category.name,
                      d.administrationRoute.name,
                      if (d.isActive) 'Active' else 'Inactive',
                    ],
                  ),
                ],
              ),
            pw.SizedBox(height: 20),

            // 2. Blood Test Summary
            _sectionTitle(bloodSection),
            if (bloodTests.isEmpty)
              _emptyText(noData)
            else
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                cellPadding: const pw.EdgeInsets.all(6),
                data: [
                  ['Date', 'Type', 'Value', 'Unit'],
                  ...bloodTests.take(10).expand(
                        (r) => r.readings.map(
                          (reading) => [
                            dateFormat.format(r.testDate),
                            reading.type.name,
                            reading.value.toStringAsFixed(1),
                            reading.unit,
                          ],
                        ),
                      ),
                ],
              ),
            pw.SizedBox(height: 20),

            // 3. Body Measurements
            _sectionTitle(measureSection),
            if (measurements.isEmpty)
              _emptyText(noData)
            else
              ..._buildMeasurementRows(measurements.take(5).toList()),
            pw.SizedBox(height: 20),

            // 4. Recent Journal
            _sectionTitle(journalSection),
            if (journals.isEmpty)
              _emptyText(noData)
            else
              ...journals.take(5).map(
                (j) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        dateFormat.format(j.date),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        j.content.length > 200
                            ? '${j.content.substring(0, 200)}...'
                            : j.content,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );

      final bytes = await pdf.save();
      return right(Uint8List.fromList(bytes));
    } catch (e) {
      return left(UnexpectedFailure(message: e.toString()));
    }
  }

  pw.Widget _buildHeader(String title, String userName, String date) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey400),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(userName, style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
          pw.Text(date, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey800,
        ),
      ),
    );
  }

  pw.Widget _emptyText(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
      ),
    );
  }

  List<pw.Widget> _buildMeasurementRows(
    List<MeasurementEntry> entries,
  ) {
    final dateFormat = DateFormat.yMMMd();
    return entries
        .map(
          (m) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                pw.Text(
                  dateFormat.format(m.date),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                if (m.weight != null)
                  pw.Text('Weight: ${m.weight}', style: _valueStyle),
                if (m.bust != null)
                  pw.Text('Bust: ${m.bust}', style: _valueStyle),
                if (m.waist != null)
                  pw.Text('Waist: ${m.waist}', style: _valueStyle),
                if (m.hip != null)
                  pw.Text('Hip: ${m.hip}', style: _valueStyle),
                if (m.shoulder != null)
                  pw.Text(
                    'Shoulder: ${m.shoulder}',
                    style: _valueStyle,
                  ),
              ],
            ),
          ),
        )
        .toList();
  }

  pw.TextStyle get _valueStyle => const pw.TextStyle(fontSize: 9);
}
