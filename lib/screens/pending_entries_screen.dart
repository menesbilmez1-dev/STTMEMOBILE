import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/entry_provider.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/entry_editor_sheet.dart';
import '../widgets/command_batch_review_sheet.dart';
import '../models/pending_entry.dart';

class PendingEntriesScreen extends StatelessWidget {
  const PendingEntriesScreen({super.key});

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showEntryEditorSheet(BuildContext context, {PendingEntry? entry}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          EntryEditorSheet(initialValue: entry?.value ?? '', entry: entry),
    );
  }

  void _showBatchReviewSheet(BuildContext context, List<PendingEntry> entries) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CommandBatchReviewSheet(entries: entries),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    final entries = entryProvider.entries;
    final l10n = AppLocalizations.of(context)!;
    final batches = <String, List<PendingEntry>>{};
    for (final entry in entries) {
      batches.putIfAbsent(entry.batchId, () => []).add(entry);
    }
    final batchEntries = batches.values.toList();

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
                      content: Text(
                        entryProvider.hasUnreviewedEntries
                            ? l10n.syncCompletedWithDrafts
                            : l10n.syncSuccess,
                      ),
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
        ],
      ),
      body: entries.isEmpty
          ? Center(child: Text(l10n.noEntriesFound))
          : ListView.builder(
              itemCount: batchEntries.length,
              itemBuilder: (context, index) {
                final batch = batchEntries[index];
                final firstEntry = batch.first;
                final isSpeechDraft = firstEntry.sourceTranscript.isNotEmpty;
                final isReviewed = batch.every((entry) => entry.isReviewed);
                return ListTile(
                  title: Text(
                    isSpeechDraft
                        ? firstEntry.sourceTranscript
                        : '${firstEntry.category.toUpperCase()} - ${firstEntry.type}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isSpeechDraft)
                        ...batch.map(
                          (entry) => Text(
                            '${entry.category} - ${entry.type}: ${entry.value}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        Text(firstEntry.value),
                      if (isSpeechDraft && !isReviewed)
                        Text(
                          l10n.awaitingReview,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm')
                            .format(firstEntry.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: !isSpeechDraft,
                  onTap: () {
                    if (isSpeechDraft) {
                      _showBatchReviewSheet(context, batch);
                    } else {
                      _showEntryEditorSheet(context, entry: firstEntry);
                    }
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSpeechDraft && !isReviewed)
                        Icon(
                          Icons.rate_review_outlined,
                          color: Colors.orange.shade700,
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            entryProvider.deleteBatch(firstEntry.batchId),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntryEditorSheet(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: entryProvider.isSyncing
          ? const LinearProgressIndicator()
          : null,
    );
  }
}
