import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stt_merve/injection_container.dart';
import 'package:stt_merve/l10n/app_localizations.dart';
import 'package:stt_merve/providers/entry_provider.dart';
import 'package:stt_merve/services/api_service.dart';
import 'package:stt_merve/services/database_service.dart';
import 'package:stt_merve/services/haptic_service.dart';
import 'package:stt_merve/services/speech_service.dart';
import 'package:stt_merve/services/speech_parser_service.dart';
import 'package:stt_merve/screens/pending_entries_screen.dart';
import 'package:stt_merve/screens/settings_screen.dart';
import 'package:stt_merve/widgets/entry_editor_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: sl<DatabaseService>()),
        Provider<ApiService>.value(value: sl<ApiService>()),
        Provider<HapticService>.value(value: sl<HapticService>()),
        Provider<SpeechParserService>.value(value: sl<SpeechParserService>()),
        ChangeNotifierProvider<SpeechService>(
          create: (context) => sl<SpeechService>(),
        ),
        ChangeNotifierProvider<EntryProvider>(
          create: (context) => EntryProvider(
            sl<DatabaseService>(),
            sl<ApiService>(),
            sl<HapticService>(),
          )..loadData(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STT Merve',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _HomeWrapper(),
    );
  }
}

class _HomeWrapper extends StatelessWidget {
  const _HomeWrapper();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MyHomePage(title: l10n.homeTitle);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SpeechStatus _previousStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final speechService = context.read<SpeechService>();
      speechService.initSpeech();
      _previousStatus = speechService.status;
      speechService.addListener(_onSpeechStatusChanged);
    });
  }

  Future<void> _onSpeechStatusChanged() async {
    final speechService = context.read<SpeechService>();
    final entryProvider = context.read<EntryProvider>();
    final parserService = context.read<SpeechParserService>();

    final previousStatus = _previousStatus;
    _previousStatus = speechService.status;
    if (previousStatus != SpeechStatus.listening ||
        speechService.status != SpeechStatus.idle) {
      return;
    }

    final words = speechService.lastWords.trim();
    if (words.isEmpty ||
        words.contains('Konuşmaya başlamak için butona basın...')) {
      return;
    }

    final commands = entryProvider.config == null
        ? const <ParsedResult>[]
        : parserService.parse(words, entryProvider.config!);
    try {
      await entryProvider.addSpeechDraft(words, commands);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.draftSaved)),
        );
      }
    } catch (error) {
      debugPrint('Failed to save speech draft: $error');
    }
  }

  @override
  void dispose() {
    context.read<SpeechService>().removeListener(_onSpeechStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speechService = context.watch<SpeechService>();
    final l10n = AppLocalizations.of(context)!;

    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              speechService.lastWords,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showEntryEditor(speechService.lastWords),
            child: Text(l10n.editAndSave),
          ),
        ],
      ),
    );

    if (speechService.status == SpeechStatus.permissionDenied) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic_off, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.micPermissionDenied,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.micPermissionDeniedDesc),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => speechService.openSystemSettings(),
              icon: const Icon(Icons.settings),
              label: Text(l10n.goToSettings),
            ),
          ],
        ),
      );
    } else if (speechService.status == SpeechStatus.unavailable) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.speechUnavailable,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.speechUnavailableDesc),
          ],
        ),
      );
    } else if (speechService.status == SpeechStatus.error) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(l10n.genericError, style: const TextStyle(fontSize: 20)),
          ],
        ),
      );
    } else if (speechService.status == SpeechStatus.initializing) {
      content = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PendingEntriesScreen()),
            ),
          ),
        ],
      ),
      body: content,
      floatingActionButton:
          speechService.status == SpeechStatus.permissionDenied
          ? null
          : FloatingActionButton(
              onPressed: speechService.isListening
                  ? () => speechService.stopListening()
                  : () => speechService.startListening(),
              tooltip: speechService.isListening ? l10n.stop : l10n.talk,
              child: Icon(
                speechService.isListening ? Icons.mic_off : Icons.mic,
              ),
            ),
    );
  }

  void _showEntryEditor(String words) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EntryEditorSheet(initialValue: words),
    );
  }
}
