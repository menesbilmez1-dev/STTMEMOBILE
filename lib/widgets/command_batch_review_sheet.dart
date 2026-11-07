import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/app_config.dart';
import '../models/pending_entry.dart';
import '../providers/entry_provider.dart';

class CommandBatchReviewSheet extends StatefulWidget {
  const CommandBatchReviewSheet({super.key, required this.entries});

  final List<PendingEntry> entries;

  @override
  State<CommandBatchReviewSheet> createState() =>
      _CommandBatchReviewSheetState();
}

class _CommandBatchReviewSheetState extends State<CommandBatchReviewSheet> {
  late final List<_EditableCommand> _commands;

  @override
  void initState() {
    super.initState();
    _commands = widget.entries
        .map(
          (entry) => _EditableCommand(
            id: entry.id,
            timestamp: entry.timestamp,
            category: entry.category,
            type: entry.type,
            value: entry.value,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();
    final l10n = AppLocalizations.of(context)!;
    final config = provider.config;
    final transcript = widget.entries.first.sourceTranscript;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reviewSpeechDraft,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(l10n.transcriptLabel),
              const SizedBox(height: 4),
              SelectableText(transcript),
              if (_commands.every(
                (command) =>
                    command.category.isEmpty &&
                    command.type.isEmpty &&
                    command.value.isEmpty,
              )) ...[
                const SizedBox(height: 12),
                Text(l10n.unparsedTranscript),
              ],
              const SizedBox(height: 16),
              if (config == null)
                Text(l10n.configMissingError)
              else ...[
                for (var index = 0; index < _commands.length; index++)
                  _buildCommandEditor(index, config, l10n),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      final category = config.categories.firstWhere(
                        (item) => item.types.isNotEmpty,
                        orElse: () => CategoryConfig(name: '', types: []),
                      );
                      _commands.add(
                        _EditableCommand(
                          id: const Uuid().v4(),
                          timestamp: DateTime.now(),
                          category: category.name,
                          type: category.types.isEmpty
                              ? ''
                              : category.types.first,
                        ),
                      );
                    }),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addCommand),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _save(provider, l10n),
                    child: Text(l10n.saveReviewedBatch),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommandEditor(
    int index,
    AppConfig config,
    AppLocalizations l10n,
  ) {
    final command = _commands[index];
    final categories = config.categories;
    final categoryExists = categories.any(
      (category) => category.name == command.category,
    );
    final selectedCategory = categoryExists ? command.category : null;
    final matchingCategories = categories.where(
      (category) => category.name == selectedCategory,
    );
    final selectedCategoryConfig = matchingCategories.isEmpty
        ? null
        : matchingCategories.first;
    final types = selectedCategoryConfig?.types ?? const <String>[];
    final selectedType = types.contains(command.type) ? command.type : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text('${index + 1}')),
                IconButton(
                  tooltip: l10n.removeCommand,
                  onPressed: () => setState(() => _commands.removeAt(index)),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: InputDecoration(labelText: l10n.selectCategory),
              items: [
                for (final category in categories)
                  DropdownMenuItem(
                    value: category.name,
                    child: Text(
                      category.name.isEmpty
                          ? l10n.emptyCategoryLabel
                          : category.name,
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                final selected = categories.firstWhere(
                  (category) => category.name == value,
                );
                setState(() {
                  command
                    ..category = value
                    ..type = selected.types.isEmpty ? '' : selected.types.first;
                });
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: InputDecoration(labelText: l10n.selectType),
              items: [
                for (final type in types)
                  DropdownMenuItem(value: type, child: Text(type)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => command.type = value);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: command.value,
              decoration: InputDecoration(labelText: l10n.textLabel),
              onChanged: (value) => command.value = value,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(EntryProvider provider, AppLocalizations l10n) async {
    if (_commands.length < 2) {
      _showError(l10n.mustHaveTwoCommands);
      return;
    }

    final entries = [
      for (final command in _commands)
        PendingEntry(
          id: command.id,
          category: command.category,
          type: command.type,
          value: command.value.trim(),
          timestamp: command.timestamp,
          batchId: widget.entries.first.batchId,
          sourceTranscript: widget.entries.first.sourceTranscript,
          isReviewed: true,
        ),
    ];

    try {
      await provider.reviewBatch(widget.entries.first.batchId, entries);
      if (mounted) Navigator.pop(context);
    } on ArgumentError {
      if (mounted) _showError(l10n.invalidCommandBatch);
    } catch (error) {
      debugPrint('Failed to save reviewed command batch: $error');
      if (mounted) _showError(l10n.reviewSaveError);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

class _EditableCommand {
  final String id;
  final DateTime timestamp;
  String category;
  String type;
  String value;

  _EditableCommand({
    required this.id,
    required this.timestamp,
    required this.category,
    required this.type,
    this.value = '',
  });
}
