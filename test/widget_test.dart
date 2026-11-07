import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:stt_merve/l10n/app_localizations.dart';
import 'package:stt_merve/models/app_config.dart';
import 'package:stt_merve/providers/entry_provider.dart';
import 'package:stt_merve/screens/settings_screen.dart';
import 'package:stt_merve/services/api_service.dart';
import 'package:stt_merve/services/database_service.dart';
import 'package:stt_merve/services/haptic_service.dart';

void main() {
  testWidgets('settings fetches and saves the server configuration', (
    tester,
  ) async {
    final apiService = _FakeApiService();
    final databaseService = _FakeDatabaseService();
    final entryProvider = EntryProvider(
      databaseService,
      apiService,
      _FakeHapticService(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<EntryProvider>.value(
        value: entryProvider,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Fetch Configuration'));
    await tester.pumpAndSettle();

    expect(apiService.fetchCount, 1);
    expect(databaseService.savedConfig?.categories.single.name, 'Sales');
    expect(find.text('Configuration updated'), findsOneWidget);
  });
}

class _FakeApiService extends ApiService {
  _FakeApiService() : super(baseUrl: 'http://localhost:8080');

  int fetchCount = 0;

  @override
  Future<AppConfig> fetchLatestConfig() async {
    fetchCount++;
    return AppConfig(
      categories: [
        CategoryConfig(name: 'Sales', types: ['Cash']),
      ],
    );
  }
}

class _FakeDatabaseService extends DatabaseService {
  AppConfig? savedConfig;

  @override
  Future<void> updateConfig(AppConfig config) async {
    savedConfig = config;
  }
}

class _FakeHapticService extends HapticService {
  @override
  void success() {}
}
