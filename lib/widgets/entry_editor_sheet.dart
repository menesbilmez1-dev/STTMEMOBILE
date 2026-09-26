import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../models/pending_entry.dart';
import '../l10n/app_localizations.dart';

class EntryEditorSheet extends StatefulWidget {
  const EntryEditorSheet({
    super.key,
    required this.initialValue,
    this.entry,
  });

  final String initialValue;
  final PendingEntry? entry;

  @override
  State<EntryEditorSheet> createState() => _EntryEditorSheetState();
}

class _EntryEditorSheetState extends State<EntryEditorSheet> {
  late TextEditingController _controller;
  String _selectedCategory = '';
  String _selectedType = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    if (widget.entry != null) {
      _selectedCategory = widget.entry!.category;
      _selectedType = widget.entry!.type;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave(EntryProvider entryProvider, String category, String type) async {
    if (category.isEmpty || type.isEmpty) return;

    if (widget.entry != null) {
      // Update existing entry
      final updatedEntry = PendingEntry(
        id: widget.entry!.id,
        category: category,
        type: type,
        value: _controller.text,
        timestamp: widget.entry!.timestamp,
      );
      await entryProvider.updateEntry(updatedEntry);
    } else {
      // Add new entry
      await entryProvider.addEntryWithDetails(
        value: _controller.text,
        category: category,
        type: type,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final config = entryProvider.config;
    final categories = config?.categories ?? [];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.entry == null ? l10n.editAndSave : l10n.editEntryTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.textLabel,
              ),
            ),
            const SizedBox(height: 24),
            if (categories.isNotEmpty) ...[
              Text(
                l10n.selectCategory,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              ...categories.map((cat) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: cat.types.map((type) {
                        final isSelected = _selectedCategory == cat.name && _selectedType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _handleSave(entryProvider, cat.name, type);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }),
            ] else ...[
              Text(l10n.configMissingError),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                if (widget.entry == null) // Don't show save button for new entries, as chips do it
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedCategory.isEmpty || _selectedType.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.selectCategoryAndTypeError)),
                        );
                        return;
                      }
                      await _handleSave(entryProvider, _selectedCategory, _selectedType);
                    },
                    child: Text(l10n.save),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}