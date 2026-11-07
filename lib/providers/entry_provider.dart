import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/pending_entry.dart';
import '../models/app_config.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/haptic_service.dart';
import '../services/speech_parser_service.dart';

import 'package:uuid/uuid.dart';

class EntryProvider with ChangeNotifier {
  final DatabaseService _dbService;
  final ApiService _apiService;
  final HapticService _hapticService;

  EntryProvider(this._dbService, this._apiService, this._hapticService);

  List<PendingEntry> _entries = [];
  List<PendingEntry> get entries => _entries;

  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (var entry in _entries) {
      counts[entry.category] = (counts[entry.category] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> get dailyCounts {
    final counts = <String, int>{};
    final dateFormat = DateFormat('yyyy-MM-dd');
    final sortedEntries = List<PendingEntry>.from(_entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (var entry in sortedEntries) {
      final dateString = dateFormat.format(entry.timestamp);
      counts[dateString] = (counts[dateString] ?? 0) + 1;
    }
    return counts;
  }

  AppConfig? _config;
  AppConfig? get config => _config;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  bool get hasUnreviewedEntries => _entries.any((entry) => !entry.isReviewed);

  String get serverUrl => _apiService.baseUrl;

  void loadData() {
    _entries = _dbService.getAllEntries();
    _config = _dbService.getConfig();
    notifyListeners();
  }

  Future<void> addEntryWithDetails({
    required String value,
    required String category,
    required String type,
  }) async {
    final id = const Uuid().v4();
    final entry = PendingEntry(
      id: id,
      category: category,
      type: type,
      value: value,
      timestamp: DateTime.now(),
      batchId: id,
    );
    await _dbService.addEntry(entry);
    _entries = _dbService.getAllEntries();
    _hapticService.success();
    notifyListeners();
  }

  Future<void> addSpeechDraft(
    String transcript,
    List<ParsedResult> parsedCommands,
  ) async {
    final batchId = const Uuid().v4();
    final timestamp = DateTime.now();
    final commands = parsedCommands.isEmpty
        ? [ParsedResult(category: '', type: '', value: '')]
        : parsedCommands;
    final entries = [
      for (final command in commands)
        PendingEntry(
          id: const Uuid().v4(),
          category: command.category,
          type: command.type,
          value: command.value,
          timestamp: timestamp,
          batchId: batchId,
          sourceTranscript: transcript,
          isReviewed: false,
        ),
    ];

    for (final entry in entries) {
      await _dbService.addEntry(entry);
    }
    _entries = _dbService.getAllEntries();
    notifyListeners();
  }

  Future<void> reviewBatch(
    String batchId,
    List<PendingEntry> reviewedEntries,
  ) async {
    if (reviewedEntries.length < 2) {
      throw ArgumentError('A voice batch must contain at least two commands.');
    }
    if (reviewedEntries.any(
      (entry) =>
          entry.type.trim().isEmpty ||
          entry.value.trim().isEmpty ||
          !_configHasCategoryType(entry.category, entry.type),
    )) {
      throw ArgumentError(
        'Every command must match a configured category/type and have a value.',
      );
    }

    final uniqueColumns = <String>{};
    for (final entry in reviewedEntries) {
      final key =
          '${entry.category.trim().toLowerCase()}|${entry.type.trim().toLowerCase()}';
      if (!uniqueColumns.add(key)) {
        throw ArgumentError(
          'A batch cannot contain duplicate category/type pairs.',
        );
      }
    }

    final existingEntries = _entries
        .where((entry) => entry.batchId == batchId)
        .toList();
    final now = DateTime.now();
    for (var index = 0; index < reviewedEntries.length; index++) {
      final updated = reviewedEntries[index]
        ..batchId = batchId
        ..isReviewed = true
        ..sourceTranscript = existingEntries.isEmpty
            ? reviewedEntries[index].sourceTranscript
            : existingEntries.first.sourceTranscript;
      if (index < existingEntries.length) {
        updated
          ..id = existingEntries[index].id
          ..timestamp = existingEntries[index].timestamp;
        await _dbService.updateEntry(updated);
      } else {
        updated.timestamp = now;
        await _dbService.addEntry(updated);
      }
    }
    for (final removed in existingEntries.skip(reviewedEntries.length)) {
      await _dbService.deleteEntry(removed);
    }

    _entries = _dbService.getAllEntries();
    _hapticService.success();
    notifyListeners();
  }

  bool _configHasCategoryType(String categoryName, String type) =>
      _config?.categories.any(
        (category) =>
            category.name.trim().toLowerCase() ==
                categoryName.trim().toLowerCase() &&
            category.types.any(
              (configuredType) =>
                  configuredType.trim().toLowerCase() ==
                  type.trim().toLowerCase(),
            ),
      ) ??
      false;

  Future<void> deleteBatch(String batchId) async {
    final batch = _entries.where((entry) => entry.batchId == batchId).toList();
    for (final entry in batch) {
      await _dbService.deleteEntry(entry);
    }
    _entries = _dbService.getAllEntries();
    notifyListeners();
  }

  Future<void> deleteEntry(PendingEntry entry) async {
    await _dbService.deleteEntry(entry);
    _entries = _dbService.getAllEntries();
    _hapticService.selection();
    notifyListeners();
  }

  Future<void> updateEntry(PendingEntry entry) async {
    await _dbService.updateEntry(entry);
    _entries = _dbService.getAllEntries();
    _hapticService.success();
    notifyListeners();
  }

  Future<void> syncEntries() async {
    if (_isSyncing) return;
    final reviewedEntries = _entries
        .where((entry) => entry.isReviewed)
        .toList();
    if (reviewedEntries.isEmpty) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final box = _dbService.pendingEntriesBox;
      final batches = <String, List<PendingEntry>>{};
      for (final entry in reviewedEntries) {
        batches.putIfAbsent(entry.batchId, () => []).add(entry);
      }

      for (final batch in batches.entries) {
        await _apiService.sendEntries(batch.value);
        for (final entry in batch.value) {
          await box.delete(entry.key);
        }
      }
      _hapticService.success();
    } catch (e) {
      _hapticService.error();
      rethrow;
    } finally {
      _entries = _dbService.getAllEntries();
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> fetchAndSaveConfig() async {
    final newConfig = await _apiService.fetchLatestConfig();
    await _dbService.updateConfig(newConfig);
    _config = newConfig;
    _hapticService.success();
    notifyListeners();
  }

  Future<void> updateLocalConfig(AppConfig config) async {
    await _dbService.updateConfig(config);
    _config = config;
    _hapticService.selection();
    notifyListeners();
  }

  Future<void> updateServerUrl(String newUrl) async {
    // Robust URL validation using regex
    final urlRegex = RegExp(r'^(https?://)[^\s/$.?#].[^\s]*$');
    if (!urlRegex.hasMatch(newUrl)) {
      throw ApiException('Geçersiz URL formatı.');
    }

    // Test connection first using the NEW URL
    await _apiService.testConnection(newUrl);

    _apiService.updateBaseUrl(newUrl);
    await _dbService.setServerUrl(newUrl);
    _hapticService.success();
    notifyListeners();
  }
}
