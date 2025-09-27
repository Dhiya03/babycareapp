import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/day_history.dart';
import 'storage_service.dart';

class WebStorageService implements StorageService {
  static const _keyPrefix = "baby_history_";

  String _dateKey(DateTime date) =>
      "$_keyPrefix${date.year}-${date.month}-${date.day}";

  @override
  Future<void> saveEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = _dateKey(event.start);
    final existing = prefs.getString(dayKey);
    final history = existing != null
        ? DayHistory.fromJson(jsonDecode(existing) as Map<String, dynamic>)
        : DayHistory(date: event.start, events: []);
    history.events.add(event);
    await prefs.setString(dayKey, jsonEncode(history.toJson()));
  }

  @override
  Future<DayHistory> loadDayHistory(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_dateKey(date));
    if (data == null) return DayHistory(date: date, events: []);
    return DayHistory.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> updateDayHistory(DayHistory dayHistory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _dateKey(dayHistory.date), jsonEncode(dayHistory.toJson()));
  }

  @override
  Future<void> deleteEvent(DateTime date, String eventId) async {
    final history = await loadDayHistory(date);
    history.events.removeWhere((e) => e.id == eventId);
    await updateDayHistory(history);
  }

  @override
  Future<void> updateEvent(DateTime originalDate, Event updatedEvent) async {
    await deleteEvent(originalDate, updatedEvent.id);
    await saveEvent(updatedEvent);
  }

  @override
  Future<List<DateTime>> getAvailableDates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .map((k) {
      final parts = k.replaceFirst(_keyPrefix, '').split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList();
  }

  @override
  Future<String?> getFilePathForDate(DateTime date) async => null;

  @override
  Future<String?> getDayHistoryContent(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dateKey(date));
  }

  @override
  Future<String> getAppDirectoryPath() async {
    throw UnsupportedError("Web does not support file system paths");
  }

  @override
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToRemove = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    for (final k in keysToRemove) {
      await prefs.remove(k);
    }
  }
}
