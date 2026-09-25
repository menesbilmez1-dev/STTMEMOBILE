import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/entry_provider.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class PendingEntriesScreen extends StatelessWidget {
  const PendingEntriesScreen({super.key});

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    final entries = entryProvider.entries;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pendingEntriesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              try {
                await entryProvider.syncEntries();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.syncSuccess),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } on ApiException catch (e) {
                if (context.mounted) {
                  _showErrorSnackBar(context, e.message);
                }
              } catch (e) {
                if (context.mounted) {
                  _showErrorSnackBar(context, l10n.syncError);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                await entryProvider.fetchAndSaveConfig();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.configUpdateSuccess),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } on ApiException catch (e) {
                if (context.mounted) {
                  _showErrorSnackBar(context, e.message);
                }
              } catch (e) {
                if (context.mounted) {
                  _showErrorSnackBar(context, l10n.configUpdateError);
                }
              }
            },
          ),
        ],
      ),
      body: entries.isEmpty
          ? Center(child: Text(l10n.noEntriesFound))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  title: Text('${entry.category.toUpperCase()} - ${entry.type}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.value),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(entry.timestamp),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => entryProvider.deleteEntry(index),
                  ),
                );
              },
            ),
      bottomNavigationBar: entryProvider.isSyncing
          ? const LinearProgressIndicator()
          : null,
    );
  }
}

