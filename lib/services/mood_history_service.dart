import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:mood_app/models/mood_history_entry.dart';

class MoodHistoryService {
  static const String _key = 'mood_history_entries_v1';

  Future<List<MoodHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((m) => MoodHistoryEntry.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<MoodHistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> addEntry(
    MoodHistoryEntry entry, {
    int maxEntries = 20,
  }) async {
    final entries = await load();
    final updated = [entry, ...entries];
    final capped = updated.take(maxEntries).toList();
    await save(capped);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

