import 'package:intl/intl.dart';
import 'storage_service.dart';

/// A mixin that provides methods to generate report content.
/// This logic is shared between mobile and web export services.
mixin ReportGenerator {
  Future<String> createCSVData(
    StorageService storageService,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('id,type,start,end,duration_minutes,notes');

    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final current = startDate.add(Duration(days: i));
      final dayHistory = await storageService.loadDayHistory(current);
      for (final event in dayHistory.events) {
        final startIso = event.start.toIso8601String();
        final endIso = event.end?.toIso8601String() ?? '';
        // Escape quotes in notes for CSV safety
        final notes = '"${event.notes.replaceAll('"', '""')}"';
        buffer.writeln(
          '${event.id},${event.type},$startIso,$endIso,${event.durationMinutes},$notes',
        );
      }
    }
    return buffer.toString();
  }

  Future<String> createSummaryReport(
    StorageService storageService,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('Baby Care Summary Report');
    buffer.writeln(
      'Period: ${DateFormat('MMM d, y').format(startDate)} - ${DateFormat('MMM d, y').format(endDate)}',
    );
    buffer.writeln(
      'Generated: ${DateFormat('MMM d, y HH:mm').format(DateTime.now())}',
    );
    buffer.writeln();
    buffer.writeln('=' * 50);
    buffer.writeln();

    int totalDays = 0;
    int totalFeedings = 0;
    int totalFeedingMinutes = 0;
    int totalUrinations = 0;
    int totalStools = 0;
    final dailyStats = <String>[];

    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final current = startDate.add(Duration(days: i));
      final dayHistory = await storageService.loadDayHistory(current);

      if (dayHistory.hasEvents) {
        totalDays++;
        totalFeedings += dayHistory.feedingCount;
        totalFeedingMinutes += dayHistory.totalFeedingMinutes;
        totalUrinations += dayHistory.urinationCount;
        totalStools += dayHistory.stoolCount;

        dailyStats.add(
          '${DateFormat('MMM d').format(current)}: '
          '${dayHistory.feedingCount}F (${dayHistory.totalFeedingMinutes}m), '
          '${dayHistory.urinationCount}U, ${dayHistory.stoolCount}S',
        );
      }
    }

    buffer.writeln('SUMMARY STATISTICS');
    buffer.writeln('-' * 20);
    buffer.writeln('Days with data: $totalDays');
    buffer.writeln('Total feedings: $totalFeedings');
    buffer.writeln(
      'Total feeding time: ${_formatDuration(totalFeedingMinutes)}',
    );
    buffer.writeln(
      'Average feeding time: ${totalFeedings > 0 ? _formatDuration(totalFeedingMinutes ~/ totalFeedings) : '0m'}',
    );
    buffer.writeln('Total urinations: $totalUrinations');
    buffer.writeln('Total stools: $totalStools');
    buffer.writeln();

    if (totalDays > 0) {
      buffer.writeln('Daily averages:');
      buffer.writeln(
        '- Feedings: ${(totalFeedings / totalDays).toStringAsFixed(1)} per day',
      );
      buffer.writeln(
        '- Feeding time: ${_formatDuration((totalFeedingMinutes / totalDays).round())} per day',
      );
      buffer.writeln(
        '- Urinations: ${(totalUrinations / totalDays).toStringAsFixed(1)} per day',
      );
      buffer.writeln(
        '- Stools: ${(totalStools / totalDays).toStringAsFixed(1)} per day',
      );
      buffer.writeln();
    }

    if (dailyStats.isNotEmpty) {
      buffer.writeln('DAILY BREAKDOWN');
      buffer.writeln('-' * 15);
      dailyStats.forEach(buffer.writeln);
      buffer.writeln();
    }

    buffer.writeln('Legend: F=Feedings, U=Urinations, S=Stools');
    buffer.writeln('Note: Times shown in minutes (m)');

    return buffer.toString();
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}