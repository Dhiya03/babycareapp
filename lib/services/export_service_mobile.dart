import 'dart:io';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'storage_service.dart';
import 'export_service.dart';
import 'export_report_generator.dart';

/// Mobile implementation of ExportService using dart:io.
class ExportServiceMobile with ReportGenerator implements ExportService {
  final StorageService _storageService;

  ExportServiceMobile(this._storageService);

  @override
  Future<bool> exportDay(DateTime date) async {
    try {
      final filePath = await _storageService.getFilePathForDate(date);
      if (filePath != null && await File(filePath).exists()) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Baby history for ${DateFormat('yyyy-MM-dd').format(date)}',
          subject: 'Baby Care History - ${DateFormat('MMM d, y').format(date)}',
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Failed to export day: $e');
    }
  }

  @override
  Future<bool> exportDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final files = <XFile>[];
      for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
        final current = startDate.add(Duration(days: i));
        final filePath = await _storageService.getFilePathForDate(current);
        if (filePath != null && await File(filePath).exists()) {
          files.add(XFile(filePath));
        }
      }

      if (files.isEmpty) {
        return false;
      }

      await Share.shareXFiles(
        files,
        text:
            'Baby history from ${DateFormat('MMM d').format(startDate)} to ${DateFormat('MMM d, y').format(endDate)}',
        subject: 'Baby Care History - Date Range',
      );
      return true;
    } catch (e) {
      throw Exception('Failed to export date range: $e');
    }
  }

  @override
  Future<void> exportSummaryReport(DateTime startDate, DateTime endDate) async {
    try {
      final report = await createSummaryReport(_storageService, startDate, endDate);

      final tempDirPath = await _storageService.getAppDirectoryPath();
      final tempFile = File(
        '$tempDirPath/summary_${DateFormat('yyyy-MM-dd').format(startDate)}_to_${DateFormat('yyyy-MM-dd').format(endDate)}.txt',
      );

      await tempFile.writeAsString(report);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Baby care summary report',
        subject:
            'Baby Care Summary - ${DateFormat('MMM d').format(startDate)} to ${DateFormat('MMM d, y').format(endDate)}',
      );

      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to export summary report: $e');
    }
  }

  @override
  Future<bool> exportAllData() async {
    try {
      final availableDates = await _storageService.getAvailableDates();
      if (availableDates.isEmpty) {
        return false;
      }

      final files = <XFile>[];
      for (final date in availableDates) {
        final filePath = await _storageService.getFilePathForDate(date);
        if (filePath != null && await File(filePath).exists()) {
          files.add(XFile(filePath));
        }
      }

      if (files.isEmpty) {
        return false;
      }

      await Share.shareXFiles(
        files,
        text: 'Complete baby care history (${files.length} files)',
        subject: 'Baby Care History - Complete Export',
      );
      return true;
    } catch (e) {
      throw Exception('Failed to export all data: $e');
    }
  }

  @override
  Future<void> exportAsCSV(DateTime startDate, DateTime endDate) async {
    try {
      final csvData = await createCSVData(_storageService, startDate, endDate);
      if (csvData.isEmpty) {
        throw Exception('No data to export for the selected range.');
      }

      final tempDirPath = await _storageService.getAppDirectoryPath();
      final tempFile = File(
        '$tempDirPath/baby_care_export_${DateFormat('yyyyMMdd').format(startDate)}-${DateFormat('yyyyMMdd').format(endDate)}.csv',
      );
      await tempFile.writeAsString(csvData);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Baby Care History CSV',
        subject: 'Baby Care CSV Export',
      );

      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to export as CSV: $e');
    }
  }

  @override
  Future<void> exportMedicalReport(DateTime startDate, DateTime endDate) async {
    // For mobile, the medical report can be an enhanced version of the summary report.
    // Currently, it uses the same implementation.
    await exportSummaryReport(startDate, endDate);
  }

  @override
  Future<void> exportWeeklySummary(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 6));
    await exportSummaryReport(weekStart, weekEnd);
  }

  @override
  Future<void> exportMonthlySummary(DateTime month) async {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(
      month.year,
      month.month + 1,
      0,
    ); // Last day of month
    await exportSummaryReport(monthStart, monthEnd);
  }
}
