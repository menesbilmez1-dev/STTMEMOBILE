import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import 'config_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  bool _isTesting = false;
  bool _isFetchingConfig = false;

  @override
  void initState() {
    super.initState();
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    _urlController = TextEditingController(text: entryProvider.serverUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _saveSettings() async {
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    final newUrl = _urlController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isTesting = true;
    });

    try {
      await entryProvider.updateServerUrl(newUrl);
      
      if (!mounted) return;

      setState(() {
        _isTesting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.serverUpdateSuccess),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isTesting = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTesting = false;
      });
      _showErrorSnackBar(l10n.serverUpdateError);
    }
  }

  Future<void> _fetchConfig() async {
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isFetchingConfig = true;
    });

    try {
      await entryProvider.fetchAndSaveConfig();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.configUpdateSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } on ApiException catch (error) {
      if (mounted) _showErrorSnackBar(error.message);
    } catch (error) {
      if (mounted) _showErrorSnackBar(l10n.configUpdateError);
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingConfig = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.serverConnectionTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.serverConnectionDesc,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: l10n.serverUrlLabel,
                border: const OutlineInputBorder(),
                hintText: l10n.serverUrlHint,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isTesting ? null : _saveSettings,
                child: _isTesting
                    ? const CircularProgressIndicator()
                    : Text(l10n.testAndSaveButton),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              l10n.appConfigTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isFetchingConfig ? null : _fetchConfig,
                icon: _isFetchingConfig
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(l10n.configUpdateButton),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConfigScreen()),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: Text(l10n.viewConfigButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}