import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pending_entry.dart';
import '../models/app_config.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/haptic_service.dart';

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
    final entry = PendingEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      type: type,
      value: value,
      timestamp: DateTime.now(),
    );
    await _dbService.addEntry(entry);
    _entries = _dbService.getAllEntries();
    _hapticService.success();
    notifyListeners();
  }

  Future<void> deleteEntry(PendingEntry entry) async {
    await _dbService.deleteEntry(entry);
    _entries = _dbService.getAllEntries();
    _hapticService.selection();
    notifyListeners();
  }

  Future<void> syncEntries() async {
    if (_entries.isEmpty) return;

    _isSyncing = true;
    notifyListeners();

    try {
      await _apiService.sendEntries(_entries);
      
      // Remove synced entries from local database
      final box = _dbService.pendingEntriesBox;
      for (var entry in _entries) {
        await box.delete(entry.key);
      }
      _entries = _dbService.getAllEntries();
      _hapticService.success();
    } catch (e) {
      _hapticService.error();
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> fetchAndSaveConfig() async {
    final newConfig = await _apiService.fetchLatestConfig();
    _dbService.updateConfig(newConfig);
    _config = newConfig;
    _hapticService.success();
    notifyListeners();
  }

  void updateLocalConfig(AppConfig config) {
    _dbService.updateConfig(config);
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

