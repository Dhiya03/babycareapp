import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'storage_service.dart';
import 'export_service.dart';
import 'export_report_generator.dart';

/// Web implementation of ExportService using SharedPreferences and text sharing.
class ExportServiceWeb with ReportGenerator implements ExportService {
  final StorageService _storageService;

  ExportServiceWeb(this._storageService);

  @override
  Future<bool> exportDay(DateTime date) async {
    try {
      final content = await _storageService.getDayHistoryContent(date);
      if (content != null && content.isNotEmpty) {
        await Share.share(
          content,
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
    // Web share does not support multiple files, so we combine them into one string.
    try {
      final buffer = StringBuffer();
      int fileCount = 0;
      for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
        final current = startDate.add(Duration(days: i));
        final content = await _storageService.getDayHistoryContent(current);
        if (content != null && content.isNotEmpty) {
          buffer.writeln(content);
          buffer.writeln('\n' + ('-' * 50) + '\n');
          fileCount++;
        }
      }

      if (fileCount == 0) {
        return false;
      }

      await Share.share(
        buffer.toString(),
        subject:
            'Baby history from ${DateFormat('MMM d').format(startDate)} to ${DateFormat('MMM d, y').format(endDate)}',
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
      await Share.share(
        report,
        subject:
            'Baby Care Summary - ${DateFormat('MMM d').format(startDate)} to ${DateFormat('MMM d, y').format(endDate)}',
      );
    } catch (e) {
      throw Exception('Failed to export summary report: $e');
    }
  }

  @override
  Future<bool> exportAllData() async {
    // Combine all data into a single text block for web sharing.
    try {
      final availableDates = await _storageService.getAvailableDates();
      if (availableDates.isEmpty) {
        return false;
      }

      final buffer = StringBuffer();
      for (final date in availableDates) {
        final content = await _storageService.getDayHistoryContent(date);
        if (content != null && content.isNotEmpty) {
          buffer.writeln(content);
          buffer.writeln('\n' + ('-' * 50) + '\n');
        }
      }

      if (buffer.isEmpty) {
        return false;
      }

      await Share.share(
        buffer.toString(),
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
      // On web, we share the raw CSV data as text.
      await Share.share(
        csvData,
        subject: 'Baby Care CSV Export',
      );
    } catch (e) {
      throw Exception('Failed to export as CSV: $e');
    }
  }

  @override
  Future<void> exportMedicalReport(DateTime startDate, DateTime endDate) async {
    // On web, the medical report is the same as the summary report.
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
