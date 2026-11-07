import 'package:hive_flutter/hive_flutter.dart';

import '../models/pending_entry.dart';
import '../models/app_config.dart';

class DatabaseService {
  static const String pendingEntriesBoxName = 'pending_entries';
  static const String appConfigBoxName = 'app_config';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PendingEntryAdapter());
    Hive.registerAdapter(AppConfigAdapter());
    Hive.registerAdapter(CategoryConfigAdapter());

    await Hive.openBox<PendingEntry>(pendingEntriesBoxName);
    await Hive.openBox<AppConfig>(appConfigBoxName);
    await Hive.openBox(settingsBoxName);

    const previousDefaultUrl = 'http://192.168.1.100:5000';
    if (getServerUrl() == previousDefaultUrl) {
      await setServerUrl('http://192.168.1.100:8080');
    }
  }

  Box<PendingEntry> get pendingEntriesBox =>
      Hive.box<PendingEntry>(pendingEntriesBoxName);
  Box<AppConfig> get appConfigBox => Hive.box<AppConfig>(appConfigBoxName);
  Box get settingsBox => Hive.box(settingsBoxName);

  // Pending Entries Operations
  Future<void> addEntry(PendingEntry entry) async {
    await pendingEntriesBox.add(entry);
  }

  List<PendingEntry> getAllEntries() {
    return pendingEntriesBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deleteEntry(PendingEntry entry) async {
    final storedEntry = pendingEntriesBox.values
        .cast<PendingEntry?>()
        .firstWhere((item) => item?.id == entry.id, orElse: () => null);
    if (storedEntry == null) return;
    await pendingEntriesBox.delete(storedEntry.key);
  }

  Future<void> updateEntry(PendingEntry entry) async {
    final storedEntry = pendingEntriesBox.values
        .cast<PendingEntry?>()
        .firstWhere((item) => item?.id == entry.id, orElse: () => null);
    if (storedEntry == null) {
      throw StateError('Cannot update missing pending entry ${entry.id}.');
    }
    await pendingEntriesBox.put(storedEntry.key, entry);
  }

  // App Config Operations
  Future<void> saveConfig(AppConfig config) async {
    await appConfigBox.put('current_config', config);
  }

  AppConfig? getConfig() {
    return appConfigBox.get('current_config');
  }

  Future<void> updateConfig(AppConfig config) async {
    await appConfigBox.put('current_config', config);
  }

  // Settings Operations
  Future<void> setServerUrl(String url) async {
    await settingsBox.put('server_url', url);
  }

  String getServerUrl() {
    return settingsBox.get(
      'server_url',
      defaultValue: 'http://192.168.1.100:8080',
    );
  }
}
